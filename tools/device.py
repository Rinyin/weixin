"""Small HDC helper for manual emulator acceptance; uses the current DevEco SDK."""
import argparse
import json
import os
from pathlib import Path
import re
import shlex
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]
HDC = Path(os.environ.get('DEVECO_HOME', 'C:/Program Files/Huawei/DevEco Studio')) / 'sdk/default/openharmony/toolchains/hdc.exe'
BUNDLE = 'com.example.weixin'
LOCAL = ROOT / '.local'


def hdc(*args):
    result = subprocess.run([str(HDC), *args], capture_output=True, text=True, encoding='utf-8', errors='replace', check=True)
    return result.stdout.strip()


def shell(*args):
    return hdc('shell', ' '.join(shlex.quote(str(arg)) for arg in args))


def dump_layout():
    LOCAL.mkdir(exist_ok=True)
    # A unique remote path and cleared local file prevent actions on a stale dump.
    remote = f'/data/local/tmp/weixin-layout-{os.getpid()}-{time.time_ns()}.json'
    local = LOCAL / 'layout.json'
    local.unlink(missing_ok=True)
    try:
        shell('uitest', 'dumpLayout', '-p', remote)
        hdc('file', 'recv', remote, str(local))
        root = json.loads(local.read_text(encoding='utf-8'))
        if not isinstance(root, dict):
            raise ValueError('Layout root is not an object')
        return root
    finally:
        shell('rm', '-f', remote)


def parse_bounds(value):
    match = re.fullmatch(r'\[\s*(-?\d+)\s*,\s*(-?\d+)\s*\]\s*\[\s*(-?\d+)\s*,\s*(-?\d+)\s*\]', str(value).strip())
    if not match:
        raise ValueError(f'Invalid bounds: {value!r}')
    left, top, right, bottom = map(int, match.groups())
    if left < 0 or top < 0 or right <= left or bottom <= top:
        raise ValueError(f'Empty or invalid bounds: {value!r}')
    return left, top, right, bottom


def target_center(field, value):
    if not value:
        raise ValueError('Target id/text must not be empty')
    root = dump_layout()
    matches = []

    def walk(node, enabled=True):
        attr = node.get('attributes', {})
        if attr.get('visible') in (False, 'false'):
            return
        enabled = enabled and attr.get('enabled') not in (False, 'false')
        if attr.get(field) == value:
            matches.append((attr, enabled))
        for child in node.get('children', []):
            walk(child, enabled)

    walk(root)
    if len(matches) != 1:
        raise ValueError(f'{field}={value!r}: expected one visible node, found {len(matches)}')
    attr, enabled = matches[0]
    if not enabled:
        raise ValueError(f'{field}={value!r}: target is disabled')
    left, top, right, bottom = parse_bounds(attr.get('bounds'))
    x, y = (left + right) // 2, (top + bottom) // 2
    screen_left, screen_top, screen_right, screen_bottom = parse_bounds(root.get('attributes', {}).get('bounds'))
    if not (screen_left <= x < screen_right and screen_top <= y < screen_bottom):
        raise ValueError(f'{field}={value!r}: target center is outside the screen')
    return x, y


def snapshot(shot=None):
    root = dump_layout()
    lines = []

    def walk(node):
        attr = node.get('attributes', {})
        text = attr.get('text') or attr.get('hint') or attr.get('description')
        if attr.get('visible') != 'false' and (text or attr.get('type') in ('TextInput', 'TextArea', 'Video', 'Slider')):
            lines.append({key: attr.get(key, '') for key in ('type', 'text', 'hint', 'id', 'bounds', 'enabled')})
        for child in node.get('children', []):
            walk(child)

    walk(root)
    for item in lines:
        # Credentials stay in the ignored device dump, never in console output.
        label = '[验证码已隐藏]' if item['id'] == 'login-code' and item['text'] else item['text'] or item['hint']
        print(f"{item['type']} {item['id']} {label} {item['bounds']} enabled={item['enabled']}")
    if shot:
        target = ROOT / 'docs/screenshots' / (shot + '.png')
        target.parent.mkdir(parents=True, exist_ok=True)
        remote_png = '/data/local/tmp/weixin-screen.png'
        shell('uitest', 'screenCap', '-p', remote_png)
        hdc('file', 'recv', remote_png, str(target))
        print('Screenshot:', target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['launch', 'stop', 'snapshot', 'tap', 'text', 'back', 'swipe',
                                          'click-id', 'text-id', 'replace-text-id', 'click-text'])
    parser.add_argument('values', nargs='*')
    parser.add_argument('--shot')
    args = parser.parse_args()
    if args.action == 'stop':
        print(shell('aa', 'force-stop', BUNDLE))
        return
    if args.action == 'launch':
        print(shell('aa', 'start', '-a', 'EntryAbility', '-b', BUNDLE))
    elif args.action in ('click-id', 'text-id', 'replace-text-id', 'click-text'):
        expected = 2 if args.action in ('text-id', 'replace-text-id') else 1
        if len(args.values) != expected:
            parser.error(f'{args.action} requires {"<id> <text>" if expected == 2 else "<exact text>" if args.action == "click-text" else "<id>"}')
        field = 'text' if args.action == 'click-text' else 'id'
        try:
            x, y = target_center(field, args.values[0])
        except (OSError, ValueError, subprocess.CalledProcessError) as error:
            parser.error(str(error))
        if args.action == 'replace-text-id':
            shell('uitest', 'uiInput', 'click', x, y)
            shell('uitest', 'uiInput', 'keyEvent', 2072, 2017)  # Ctrl+A selects the existing value.
            if args.values[1]:
                print(shell('uitest', 'uiInput', 'text', args.values[1]))
            else:
                print(shell('uitest', 'uiInput', 'keyEvent', 2055))  # Delete selected text.
        elif args.action == 'text-id':
            print(shell('uitest', 'uiInput', 'inputText', x, y, args.values[1]))
        else:
            print(shell('uitest', 'uiInput', 'click', x, y))
    elif args.action == 'tap':
        print(shell('uitest', 'uiInput', 'click', *args.values))
    elif args.action == 'text':
        print(shell('uitest', 'uiInput', 'inputText', *args.values))
    elif args.action == 'back':
        print(shell('uitest', 'uiInput', 'keyEvent', 'Back'))
    elif args.action == 'swipe':
        print(shell('uitest', 'uiInput', 'swipe', *args.values))
    if args.action != 'snapshot':
        time.sleep(0.6)
    snapshot(args.shot)


if __name__ == '__main__':
    main()

"""Small HDC helper for manual emulator acceptance; uses the current DevEco SDK."""
import argparse
import json
import os
from pathlib import Path
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


def snapshot(shot=None):
    LOCAL.mkdir(exist_ok=True)
    remote = '/data/local/tmp/weixin-layout.json'
    shell('uitest', 'dumpLayout', '-p', remote)
    hdc('file', 'recv', remote, str(LOCAL / 'layout.json'))
    root = json.loads((LOCAL / 'layout.json').read_text(encoding='utf-8'))
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
        print(f"{item['type']} {item['id']} {item['text'] or item['hint']} {item['bounds']} enabled={item['enabled']}")
    if shot:
        target = ROOT / 'docs/screenshots' / (shot + '.png')
        target.parent.mkdir(parents=True, exist_ok=True)
        remote_png = '/data/local/tmp/weixin-screen.png'
        shell('uitest', 'screenCap', '-p', remote_png)
        hdc('file', 'recv', remote_png, str(target))
        print('Screenshot:', target)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['launch', 'stop', 'snapshot', 'tap', 'text', 'back', 'swipe'])
    parser.add_argument('values', nargs='*')
    parser.add_argument('--shot')
    args = parser.parse_args()
    if args.action == 'stop':
        print(shell('aa', 'force-stop', BUNDLE))
        return
    if args.action == 'launch':
        print(shell('aa', 'start', '-a', 'EntryAbility', '-b', BUNDLE))
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

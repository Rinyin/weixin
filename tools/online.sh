#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

deveco_root="${DEVECO_HOME:-C:/Program Files/Huawei/DevEco Studio}"
hdc_bin="${HDC_BIN:-$deveco_root/sdk/default/openharmony/toolchains/hdc.exe}"
health_url="${AUTH_API_HEALTH_URL:-http://127.0.0.1:3000/doc/swagger-api-json}"
target="${HDC_TARGET:-}"
launch_app=true

if [[ "${1:-}" == "--prepare-only" ]]; then
  launch_app=false
elif [[ $# -gt 0 ]]; then
  printf 'Usage: bash tools/online.sh [--prepare-only]\n' >&2
  exit 2
fi

if [[ ! -f "$hdc_bin" ]]; then
  printf 'HDC was not found: %s\n' "$hdc_bin" >&2
  printf 'Set DEVECO_HOME or HDC_BIN to the DevEco installation.\n' >&2
  exit 1
fi

if ! command -v curl >/dev/null 2>&1; then
  printf 'curl is required to check the local word-api service.\n' >&2
  exit 1
fi

if ! curl --fail --silent --show-error --max-time 5 --output /dev/null "$health_url"; then
  printf 'The word-api service is not reachable at %s\n' "$health_url" >&2
  printf 'Start the course service, then run this command again.\n' >&2
  exit 1
fi
printf 'word-api is reachable: %s\n' "$health_url"

targets="$("$hdc_bin" list targets)"
mapfile -t online_targets < <(printf '%s\n' "$targets" | awk 'NF && $1 !~ /^(\[Empty\]|List)$/ { print $1 }')
if [[ -z "$target" ]]; then
  if [[ ${#online_targets[@]} -eq 1 ]]; then
    target="${online_targets[0]}"
  elif [[ ${#online_targets[@]} -gt 1 ]]; then
    printf 'Multiple HDC targets are online; set HDC_TARGET to choose one.\n' >&2
    printf '%s\n' "${online_targets[@]}" >&2
    exit 1
  fi
fi
if [[ -z "$target" ]]; then
  printf 'No online HDC target was found. Start the HarmonyOS emulator first.\n' >&2
  exit 1
fi
if ! printf '%s\n' "${online_targets[@]}" | awk -v wanted="$target" '$1 == wanted { found = 1 } END { exit found ? 0 : 1 }'; then
  printf 'HDC target is not online: %s\n' "$target" >&2
  printf '%s\n' "$targets" >&2
  exit 1
fi
printf 'HDC target: %s\n' "$target"

has_reverse_mapping() {
  printf '%s\n' "$1" | awk '/\[Reverse\]/ && /tcp:3000[[:space:]]+tcp:3000/ { found = 1 } END { exit found ? 0 : 1 }'
}

forwarding="$("$hdc_bin" -t "$target" fport ls)"
if has_reverse_mapping "$forwarding"; then
  printf 'Reverse forwarding already exists: tcp:3000 -> tcp:3000\n'
else
  "$hdc_bin" -t "$target" rport tcp:3000 tcp:3000 >/dev/null
  printf 'Reverse forwarding created: tcp:3000 -> tcp:3000\n'
fi

forwarding="$("$hdc_bin" -t "$target" fport ls)"
if ! has_reverse_mapping "$forwarding"; then
  printf 'HDC reverse forwarding was not registered successfully.\n' >&2
  printf '%s\n' "$forwarding" >&2
  exit 1
fi

if [[ "$launch_app" == true ]]; then
  "$hdc_bin" -t "$target" shell aa start -a EntryAbility -b com.example.weixin
  printf 'Application started: com.example.weixin\n'
else
  printf 'Forwarding prepared; application was not started.\n'
fi

#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
deveco_root="${DEVECO_HOME:-C:/Program Files/Huawei/DevEco Studio}"
export DEVECO_SDK_HOME="$deveco_root/sdk"
export JAVA_HOME="$deveco_root/jbr"
export PATH="$deveco_root/tools/node:$deveco_root/tools/ohpm/bin:$JAVA_HOME/bin:$PATH"
"$deveco_root/tools/node/node.exe" "$deveco_root/tools/hvigor/bin/hvigorw.js" --mode module -p product=default -p module=entry@default assembleHap --no-daemon "$@"

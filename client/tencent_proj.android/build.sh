#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
sh "${QUICK_COCOS2DX_ROOT}/lib/GamePlay-master/gameplay/android/build.sh"
sh "${DIR}/build_native.sh"

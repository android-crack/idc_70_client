#!/bin/bash
DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TOLUA="$QUICK_COCOS2DX_ROOT/bin/mac/tolua++"

cd "$DIR/"
${TOLUA} -L "$DIR/basic.lua" -o "$DIR/../LuaQ2Common.cpp" Q2Common.tolua

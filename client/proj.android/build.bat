@echo off

call %QUICK_COCOS2DX_ROOT%\lib\GamePlay-master\gameplay\android\build.bat
call %~dp0\build_native.bat

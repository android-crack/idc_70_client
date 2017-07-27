@echo off

set DIR=%~dp0
set APP_ROOT=%DIR%..\
set APP_ANDROID_ROOT=%DIR%

echo - config:

echo   ANDROID_NDK_ROOT    = %ANDROID_NDK_ROOT%
echo   QUICK_COCOS2DX_ROOT = %QUICK_COCOS2DX_ROOT%
echo   COCOS2DX_ROOT       = %COCOS2DX_ROOT%
echo   APP_ROOT            = %APP_ROOT%
echo   APP_ANDROID_ROOT    = %APP_ANDROID_ROOT%




"%ANDROID_NDK_ROOT%\ndk-build" %ANDROID_NDK_BUILD_FLAGS% -C %APP_ANDROID_ROOT% NDK_MODULE_PATH=%QUICK_COCOS2DX_ROOT%;%QUICK_COCOS2DX_ROOT%/lib/qtz_component;%QUICK_COCOS2DX_ROOT%/lib/cocos2d-x;%QUICK_COCOS2DX_ROOT%/lib/cocos2d-x/cocos2dx/platform/third_party/android/prebuilt;
pause

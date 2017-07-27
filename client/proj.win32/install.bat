@echo off

set DIR=%~dp0

xcopy %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x\scripting\lua\luajit\win32\*.* %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x\cocos2dx\platform\third_party\win32\libraries\*.* %DIR%\Debug

::xcopy %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x\extensions\CocoStudio\win32\cocostudio.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\glew\lib\windows\x86\*.* %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\png\lib\windows\x86\*.* %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\openal\lib\windows\x86\*.* %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\fmod\lib\windows\x86\*.* %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\luaHttp\win32\luaHttp.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\castar\win32\castar.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\pcre\win32\pcre.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\regx\win32\regx.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\openssl\win32\libeay32.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\openssl\win32\ssleay32.lib %DIR%\Debug

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\memory_stack\detours.lib %DIR%\Debug

@echo release

xcopy %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x\scripting\lua\luajit\win32\*.* %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x\cocos2dx\platform\third_party\win32\libraries\*.* %DIR%\Release

::xcopy %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x\extensions\CocoStudio\win32\cocostudio.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\glew\lib\windows\x86\*.* %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\png\lib\windows\x86\*.* %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\openal\lib\windows\x86\*.* %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\gameplay-external-deps\fmod\lib\windows\x86\*.* %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\luaHttp\win32\luaHttp.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\castar\win32\castar.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\pcre\win32\pcre.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\regx\win32\regx.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\openssl\win32\libeay32.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\openssl\win32\ssleay32.lib %DIR%\Release

xcopy %QUICK_COCOS2DX_ROOT%\lib\qtz_component\memory_stack\detours.lib %DIR%\Release
pause

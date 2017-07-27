dhh 项目android工程 准备流程：
   安装包或工具目录：
   \\192.168.0.251\175share\soft\O编程软件\coco2d-x
   以下统称安装包目录，安卓编译打包目录下的安装包都是32位的，官方推荐
1、安装 Visual Studio 2013（可选安装）
   安装前需要先安装IE11，IE11的安装包也在该目录下，安装IE11时需要打几个补丁，
   按照提示到官网下载和安装IE11的补丁即可。
2、安装 Java SDK（必须安装）
   复制到本地安装即可。
3、安装Android ADT bundle（Android SDK） 和 Android NDK（必须安装）
   解压缩 adt-bundle-windows-x86-20130219.zip
   将目录 adt-bundle-windows-x86-20130219 改名为 android
   删除   android\sdk
   解压缩 android-sdk-windows_补丁包.7z
   将目录 android-sdk-windows 移动到 android\android-sdk-windows
   解压缩 android-ndk-r9b-windows-x86.zip
   将目录 android-ndk-r9b 移动到 android\android-ndk-r9b
   最终的目录结构为：
   android
   --android-ndk-r9b
   --android-sdk-windows
   --eclipse
   --SDK Manager.exe
   添加环境变量（打开 系统属性 -> 高级 -> 环境变量）：
       变量名                     变量值
   ANDROID_NDK_ROOT          android-ndk-r9b目录（例如：D:\android\android-ndk-r9b）
   ANDROID_SDK_ROOT          android-sdk-windows目录（例如：D:\android\android-sdk-windows）
   QUICK_COCOS2DX_ROOT       quick-cocos2dx引擎目录，即下面编译步骤1的check quick-cocos2d-root目录（例如：D:\gameplay3d_branch）
   COCOS2DX_ROOT             %QUICK_COCOS2DX_ROOT%\lib\cocos2d-x
   ANDROID_HOME              %ANDROID_SDK_ROOT%
   android                   %ANDROID_SDK_ROOT%\platform-tools
   PATH                      %QUICK_COCOS2DX_ROOT%\bin\win32;%android%（如果 PATH 变量已经存在，则在 PATH 变量最后添加 ;%QUICK_COCOS2DX_ROOT%\bin\win32;%android%）
4、安装apk打包工具Apache Ant（必须安装）
   解压缩 apache-ant-1.9.4.zip 到你想放置的盘符（例如：D:\apache-ant-1.9.4）
   添加环境变量（打开 系统属性 -> 高级 -> 环境变量）：
       变量名                     变量值
      ANT_HOME               apache-ant-1.9.4解压放置的目录（例如：D:\apache-ant-1.9.4）
      PATH                   %ANT_HOME%\bin（如果 PATH 变量已经存在，则在 PATH 变量最后添加 ;%ANT_HOME%\bin）

5、安装类UNIX模拟环境的命令行工具cygwin，可以不安装直接用cmd亦可（可选安装）
   解压缩 cygwin.7z 到你想放置的盘符（例如：D:\cygwin）

----------------------------------------------------------------------------------------------------------------

dhh 项目android工程 编译步骤：

1.svn co https://192.168.0.3/qtz/mg01/program/gameplay3d/trunk gameplay3d 

2.svn co https://192.168.0.3/qtz/mg01/program/client/trunk client 

3.用控制台，进去client/proj.android目录，执行 android update project -p "proj.androidpath" 指令。
其中，proj.androidpath就是你所check下来的client/proj.android目录，例如 D:/client/proj.android.

4.双击client/proj.android/build.bat指令。(这一步是编译C++代码,并产生出libs/armeabi/libgame.so)


对于使用命令行的同学，执行以下操作。

5.用控制台，进去client/proj.android目录，执行:ant debug.(这一步是编译JAVA代码,并产生bin/dhh-debug.apk)

至此，apk制作完毕。安装手机调试。


对于使用eclips的同学。执行以下操作。
3.在eclips中，import client/proj.android工程。

4.在eclips中，import gameplay_branch\lib\cocos2d-x\cocos2dx\platform\android\java 工程。

5.在eclipst中右击 quickcocos2dx 工程，即 gameplay_branch\lib\cocos2d-x\cocos2dx\platform\android\java工程。进入propertices选项.
勾选 islibrary.(这一步是把cocos2dx的java工程编成一个库，给dhh的java工程使用。)

6.在eclipst中右击 DHH 工程，即import client/proj.android工程。进入propertices选项.
把quickcocos2dx工程，设为dhh工程的依赖。

7.然后，便可以用eclips 来run到手机中。

8.安装到安卓后进行调试，打开命令行adb logcat进行调试，例如：adb logcat | grep cocos

dhh项目android工程概述：

子模块：
	dhh的所有C++代码，各好多个子模块（gameplay,gaf,luasocekt,astar...）,其中每个模块需要单独编译出该模块都是一个单独的android工程，每个子模块的目录中都有如下	文件(以gameplay_branch\lib\GamePlay-master\gameplay\android 为例)： 
	1.build.bat这个执行脚本，是用于编译出这个子模块的.a文件。
	2.libgameplay.a这个是已经编译好的该子模块的.a文件。
一般情况下，子模块的功能都不常改动，所以在仓库上都会提交一个已经编译好的.a文件。以方便后面做包的同学，可以直接执行上面的编译步骤做包，而不用遂个子模块去编译。
而对于某些子模块的功能有改动的情况下，

同样以gameplay为例，那就只能先到gameplay_branch\lib\GamePlay-master\gameplay\android目录下，执行build.bat编译出新的。libgameplay.a。然后再执行上面的做包步骤去做新的apk包。

下面给出一些主要的子模块的列表：

gameplay_branch/lib/gameplay-external-deps/png/lib/android/arm
gameplay_branch/lib/qtz_component/libevent/android
gameplay_branch/lib/qtz_component/luasocket/android)			
gameplay_branch/lib/qtz_component/castar/android)			
gameplay_branch/lib/qtz_component/gafplayer/android)			
gameplay_branch/lib/gameplay-external-deps/bullet/lib/android/arm)	
gameplay_branch/lib/gameplay-external-deps/openal/lib/android/arm)	
gameplay_branch/lib/GamePlay-master/gameplay/android)	
gameplay_branch/lib/gameplay-external-deps/zlib/lib/android/arm)	
gameplay_branch/lib/gameplay-external-deps/oggvorbis/lib/android/arm)	
gameplay_branch/luaHttp/android)			
gameplay_branch/lib/qtz_component/qtz_util/android)


主模块：
	主模块主要包括cocos2dx的代码，和dhh的代码（主要是client\sources里面的代码,以client/proj.anroid/jni/android.mk中列出的为准）。
每次执行上面的第4步，都会做以下事情：

1.编译主模块的代码（cocos2dx, client\sources）。
2.把各个子模块的.a文件链接成 libgame.so文件。


使用ant debug时注意修改gameplay_branch\lib\cocos2d-x\cocos2dx\platform\android\java下的local.properties文件里面的sdk.dir的路径为你当前Android sdk的位置
如果遇到 “invalid resource directory name bin/res/crunch”错误：直接在项目中删除报错的client\proj.android\bin\res\crunch文件夹

*********遇到android crash的时候************
设备接入之后，如果要查看crash时的栈信息，可以使用在proj.android目录下使用命令adb logcat | ndk-stack -sym ./obj/local/armeabi。注意使用前需要把ndk的路径
在环境变量path设置一下


windows平台下build/core/build-binary.mk:386: *** target pattern contains no `%'. Stop
android.mk文件中的LOCAL_SRC_FILES的路径  不能含有环境变量



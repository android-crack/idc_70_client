dhh 项目win32工程 编译步骤：

1.check quick-cocos2d-root目录：https://192.168.0.3/qtz/mg01/program/gameplay3d/trunk 

2.check client目录：https://192.168.0.3/qtz/mg01/program/client/trunk  

3.设置系统环境变量：QUICK_COCOS2DX_ROOT=quick-cocos2d-root  （quick-cocos2d-root为第1步中，check下来之后所在的文件夹路径.F:\gameplay3d_branch,需要"\"斜杆,不能够用"/"）

4.quick-cocos2d-root 目录与 client 放在同级目录

5.执行client/proj.win32目录下面的：install.bat文件

6.用vs2013打开client/proj.win32/quick-x-player2010.vcxproj工程  编译 运行
一，做包 打 patch流程

第一次装机时，需要做下面几步，来配置环境：

1.配置：
参照bash_profile,配置好环境变量.

2.建立安卓资源包的软链接
（1）cd 进到client/project.android  执行 rm -rf assets  删除原来的assets目录

（2）执行 ln -s /Users/qtz/work/client/tool/shell/test/resource assets      建立好软链接
这条指令的意思就是，在当前目录下，建立一个为assets的文件夹，而这个文件夹是：/Users/qtz/work/client/tool/shell/test/resource的指针。
/Users/qtz/work/client/tool/shell/test/resource这个路径，跟据各人的开发目录而定。
/Users/qtz/work/client/tool/shell/test/resource这个路径，也就是打包加密流程，执行完成后，加密后的资源和脚本存放的地方，把assets目录指向这里，就可以省去做包里还需要拷贝资源和脚本这一步。



配置好环境后，在后面的使用过程中，执行以下流程：

1.在终端cd进入此目录，执行release.py脚本：
执行：python release.py  为默认流程：更新资源与代码，并打好patch
执行：python release.py --skipresource     为只更新脚本 并打好patch   不处理资源相关   一般在改了脚本  没有改资源的情况下  为了快速测试用的。
执行：python release.py --createapk		更新资源与代码，并打好patch   同时  制作好安卓apk包    一般在维护时 或是需要作包时用


二，开服
第一次装机时，需要做下面几点，来配置环境：
1.cd 进入nginx的安装目录 执行以下命令
(1) .configure
(2) make
(3) make install

执行以上3步来完成 nginx的安装

2.改nginx.conf_tmp中的配置
 (1)
 location /client
 {
     alias  Y:/design/packTool/client;
     autoindex on;
}
把Y:/design/packTool/client  改到 自己的/Users/qtz/work/client/tool/shell/test/resource目录
这个是资源服务器下载目录的索引地址，就设置自己的打包加密好的资源代码目录。这样客户端可以从这里下了。

(2)把nginx.conf_tmp  改名   nginx.conf    ,nginx.conf才是nginx服务器使用的真正的配置文件

(3)把这个改名后的nginx.conf复制到/usr/local/nginx/conf下面
mv nginx.conf /usr/local/nginx/conf



配置好环境后，在后面的使用过程中，执行以下流程：
1.cd 到/usr/local/nginx/sbin
2.执行 nginx 开服
致此 开服完成

开服成功，可以通过以下方式确认，服务器有没有启动成功：
1.打开浏览器，输入http://127.0.0.1:8888/  确认 nginx服务器有没有启动成功
2.执行完上面的 打包流程后
打开浏览器，输入http://127.0.0.1:8888/client/  确认服务器上的资源有没有索引成功

客户端的下载地址：
以我的电脑的ip为192.168.12.156为例，在客户端配置一载地址为："http://192.168.12.156:8888/client" 客户端即从自己的电脑上的nginx服务器上下载资源了













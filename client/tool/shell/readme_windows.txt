1.制作MD5 
进入/client/tool/shell/module目录
python calc_md5.py --path=../../../resource/ --file=../../../resource/filelist.lua

2.把resource下面的内容复制到assets下面做包

3.开启nginx服务器，并且，把下载资源的索引指向client/resource
        location /client
        {
            alias  D:/dhh/client/resource;
            autoindex on;
        }

4.自己的客户目录  改下载地址从自己电脑上下载
HTTP_DOMAIN = "http://192.168.12.66:8888/client"

如此 不用每次都烧机了，当脚本和资源改动   只需要执行1，重做filelist,并从手机上重启游戏即可
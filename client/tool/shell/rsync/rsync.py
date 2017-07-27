# -*- coding: utf-8 -*-
import os
import platform
from optparse import OptionParser
import sys
sys.path.append("../")
import module.checkDiff as checkDiff
import module.res_manage as res_manage
import shutil
import parser_config.getRsyncServerList as getRsyncServerList
import parser_config.parserConfig as parserConfig
import utils


CUR_PATH = os.path.abspath(os.path.dirname(__file__))
#SERVER_URL = "dhh@119.29.34.163::patch"    付费腾讯云
#SERVER_URL = "dhh@119.29.116.14::patch"    付费腾讯云备机
#ALI_SERVER_URL = "dhh@47.88.189.137::patch"    阿里云
#QTZ_SERVER_URL = "dhh@61.143.222.41::patch"        公司服务器
#SERVER_URL = "dhh@52.74.36.20::patch"    付费亚马逊云
#SERVER_URL = "dhh@52.77.133.204::patch"    付费亚马逊备机

#SERVER_URLS = ["dhh@119.29.34.163::patch", "dhh@119.29.116.14::patch", "dhh@61.143.222.41::patch"]
#SERVER_URLS = ["dhh@119.29.34.163::patch","dhh@61.143.222.41::patch"]
#SERVER_PORT = "8730"

#同步出去的resource目录的后缀1:tencent  2:online  3:moni  4:test  5:alicloud  6:qtz 
#CHANNEL_PATHS = ["tencent", "moni", "qtz", "online", "alicloud"]
#CHANNEL_PATHS = ["moni","qtz"]

# 注意文件在mac下的权限，特别是rsyncd.pwd文件，rsyncd.pwd设置为（chmod 600 rsyncd.pwd）
PRIKEY_PATH = os.path.join(CUR_PATH, "rsyncd.pwd")
DONE_FILE_NAME = "done.txt"
DONE_PATH = os.path.join(CUR_PATH, DONE_FILE_NAME)
LOG_PATH = os.path.join(CUR_PATH, "rsync.log")
EXCLUDE_PATH = os.path.join(CUR_PATH, "exclude.txt")

# 打印中文
def printCn(print_str):
    print(print_str.encode(sys.getfilesystemencoding()))

# 获取Rsync能识别的路径
def getRsyncPath(path_str):
    '''
    if ('Windows' in platform.system()) and (len(path_str) > 0):
        path_len = len(path_str)
        last_char = path_str[path_len - 1]
        path_str = path_str.replace("\\", "/")
        for i in range(0, path_len - 1):
            now_char = path_str[i]
            if now_char == ':':
                head_str = path_str[:i]
                tail_str = path_str[i+1:]
                if tail_str[0] != "/":
                    tail_str = "/" + tail_str
                result_str = "/cygdrive/" + head_str.lower() + tail_str
                return result_str
    '''
    return path_str
    
def safeExec(cmd,JustShow=False):
    cmd = cmd.encode(sys.getfilesystemencoding())
    print(cmd)
    if JustShow: 
        print cmd 
        return 0
    status = os.system(cmd)
    status >>= 8
    assert status == 0, "system execute '%s' return %d" % ( cmd, status )
    return status

def makeFile(path, content_str):
    try :
        f = file(path, "w+b")
    except :
        msg = "\rcan not write to " + filename
        print msg
        raise()
    f.write(content_str)
    printCn(u"写入文件："+ path)
    f.close()
    
def deleteFile(path_str):
    if os.path.exists(path_str):
        os.remove(path_str)
        printCn(u"成功删除："+path_str)
    
def checkLocalIsExists(path_str):
    if os.path.exists(path_str):
        return True
    printCn(u"本地不存在路径：" + path_str)
    return False
    
def confirmTips(tips_str):
    printCn(tips_str + u" --- (Y/N)?")
    input = raw_input()
    if input.lower() == "y":
        return True
    printCn(u"-----输入否-----")
    return False


def startRsync(publicPath, server_list):
    if not checkLocalIsExists(publicPath):
        printCn(u"不存在 "+publicPath+u" 的路径")
        return
    if False == confirmTips(u"是否同步 " + publicPath + u" 的内容？"):
        return

    #channel_path_base = "resource_"
    rsync_paths_ensure_str = u"你是否要发布到以下地址中去:\n"

    for k in server_list:
        server_path = server_list[k]
        rsync_paths_ensure_str = u"%s%s\n" %(rsync_paths_ensure_str, server_path["show_path"])


    #if confirmTips(u"是否同步 \""+SERVER_URL + u"/" +channel_path_base+local_path+u" \" 的服务器中去"):
    if confirmTips(rsync_paths_ensure_str):
        # 输入同步密码
        printCn(u"请输入同步密码：")
        password_str = raw_input()
        os.putenv("RSYNC_PASSWORD", password_str)
        
        # --delete: 删除同步文件之后服务器里多余的文件
        # --exclude-from: 同步文件时排除的不同步的文件
        #--log-file log写入文件
        #--perms 保留权限
        #--chmod  修改文件或目录的权限值
        #-vzrtopg  修更加详细的说明
        #--recursive 递归模式
        #--password-file 密码文件
        #--port 端口
        #最后是要同步的文件或文件夹， 和服务器的地址

        for i in server_list:
            config = server_list[i]

            resource_path = publicPath

            temp_path = os.path.join(CUR_PATH, "temp", config["res_path"])

            print(resource_path)
            print(temp_path)

            utils.copyFile(resource_path, temp_path)

            add_cmd_str = u'''--exclude-from=%s --delete ''' % getRsyncPath(EXCLUDE_PATH)

            cmd_str = u'''rsync --log-file="%s" --perms --chmod=u=rw,Da+x -vzrtopg %s--recursive --port=%s %s %s'''

            #同步文件
            safeExec(cmd_str%(getRsyncPath(LOG_PATH), add_cmd_str, config["port"], getRsyncPath(temp_path), config["rsync_path"]))
        
            # done文件同步
            makeFile(DONE_PATH, "1")
            safeExec(cmd_str%(getRsyncPath(LOG_PATH), "", config["port"], getRsyncPath(DONE_PATH), config["rsync_path"]))
            deleteFile(DONE_PATH)
        
        if os.path.exists(temp_path):
            shutil.rmtree(temp_path)

########################################华丽分割线###############################################
 
    
if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("", "--version", action = "store", dest = "version", help = u'版本号')
    (options, args) = parser.parse_args() 

    if options.version :
        version = options.version
    else :  
        print u"error:必须输入版号"
        exit(0)

    print(("ensure your publish version %s? (Y/N)" %version))
    ensure = raw_input()
    if ensure != "Y":
        exit(0)

    #重新更新配置
    parserConfig.startWriteCfg(version)


    platform = res_manage.GetPublishPlatform()
    backupPath = os.path.join(CUR_PATH, "..", "resource_backup")
    oldPath = os.path.join(backupPath, platform, "old")
    newPath = os.path.join(backupPath, platform, "new")
    #同步资源
    if confirmTips(u"是否要同步资源 Y／N ?"):
        # 与上次发布的版本对比
        if confirmTips(u"是否要对比上次备份的resource内容?"):
            checkDiff.checkFilelistDiff(newPath, oldPath)

        publicPath = os.path.join(newPath, "resource")
        serverList = getRsyncServerList.getRsynPathList()
        startRsync(publicPath, serverList)
        print(u"资源同步完成！！！")

    #同步配置
    if confirmTips(u"是否要同步 version %s 配置config（updateInfo.json and fixInfo.lua）Y/N ?" %version):
        publicPath = os.path.join(newPath, "updateinfo")
        serverList = getRsyncServerList.getRsynConfigPathList()
        startRsync(publicPath, serverList)
        print(u"updateInfo同步完成！！！")



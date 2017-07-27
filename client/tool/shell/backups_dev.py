#coding=utf-8
import shutil
import os
import sys
from optparse import OptionParser
from module.common import SafeExec
import module.config as config
import module.common as common

CUR_PATH = os.path.abspath(os.path.dirname(__file__))
BRANCH_BACKUPS_PATH = "%s/../../../branch_backups/" %(CUR_PATH)

def Encode(c_str):
    return c_str.encode(sys.getfilesystemencoding())

def CreateDir( path ):
    if not os.path.exists(path):
        os.mkdir(path)
        return 1 

def SvnCopy( trunkPath, branchPath, message):
    print "svn cp branch" + trunkPath + "--->" + branchPath
    strIgnor = "--ignore-externals"
    cmd = "svn cp %s %s %s -m %s" %(strIgnor, trunkPath, branchPath, message)
    ret = SafeExec(Encode(cmd))
    return ret

def SvnRm( url ):
    print "svn rm:" + url
    cmd = "svn rm %s -m removetestbranch" %(url)
    ret = SafeExec(cmd)
    return ret

def SvnCheckOut( url, path ):
    print "svn checkout" + url + "---------->" + path
    cmd = "svn co --ignore-externals %s %s" %( url, path)
    ret = SafeExec(cmd)
    return ret

def SvnCheckOutWithExternals( url, path ):
    print "svn checkout" + url + "---------->" + path
    cmd = "svn co %s %s" %( url, path)
    ret = SafeExec(cmd)
    return ret
    
def SvnExport( url, path ):
    print "svn export --force" + url + "---------->" + path
    cmd = "svn export --force --ignore-externals %s %s" %( url, path)
    ret = SafeExec(cmd)
    return ret

def SvnExportRpcJson( path ):
    url = config.SVN_ROOT_PATH + "/program/server/logic/trunk/rc/rpc/rpcJson.cfg"
    print "svn export --force" + url + "---------->" + path
    cmd  = "svn export --force %s %s" %( url, path )
    ret = SafeExec(cmd)
    return ret


def RmPath(path):
    shutil.rmtree(path) 
    return ret

def CreateAndroidPropertie( clientPath ):
    propertiePath = os.path.join(clientPath, "proj.android", "project.properties")
    shutil.rmtree(propertiePath) 
    f = open(propertiePath, "w")
    propertiesContent = "target=android-14\nandroid.library=false\nandroid.library.reference.1=../../gameplay3d/lib/cocos2d-x/cocos2dx/platform/android/java"
    f.write( propertiesContent )
    f.close()

def PatchPack(clientPath, enginPath, isCreateApk, isCreateIpa):
    createApk = ""
    if isCreateApk:
        createApk = "--createapk"
        cmd = "android update project -p %s/proj.android -t 1" %(clientPath)
        SafeExec(cmd)
        CreateAndroidPropertie(clientPath)
        cmd = "android update project -p %s/lib/cocos2d-x/cocos2dx/platform/android/java -t 1" %(enginPath)
        SafeExec(cmd)

    createIpa = ""
    if isCreateIpa:
        createIpa = "--createipa"

    #设置环境变量
    evn_cmd1 = "export QUICK_COCOS2DX_ROOT=%s" %(enginPath)
    evn_cmd2 = "export COCOS2DX_ROOT=${QUICK_COCOS2DX_ROOT}/lib/cocos2d-x"

    #传入相应的路径
    patchScriptPath = "%s/tool/shell/release.py" %(clientPath)
    targetPath = "%s/tool/shell/test" %(clientPath)

    cmd = "%s; %s; python %s --clientpath %s --targetpath %s --skipsvnup %s %s" %( evn_cmd1, evn_cmd2, patchScriptPath, clientPath, targetPath, createApk, createIpa)
    ret = SafeExec(cmd)
    return ret

if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option("", "--version", action = "store", dest = "version", help = u'发布版号', type = "string")
    parser.add_option("", "--clean", action = "store_true", dest = "clean", help = u'清删版本')
    parser.add_option("", "--checkout", action = "store_true", dest = "checkout", help = u'check')
    parser.add_option("", "--export", action = "store_true", dest = "export", help = u'export')
    parser.add_option("", "--exportscript", action = "store_true", dest = "exportscript", help = u'exportscript')
    parser.add_option("", "--exportres", action = "store_true", dest = "exportres", help = u'exportres')
    parser.add_option("", "--copy", action = "store_true", dest = "copy", help = u'copy')
    parser.add_option("", "--uprpc", action = "store_true", dest = "uprpc", help = u"uprpc" )
    (options, args) = parser.parse_args() 

    version = ""
    cleanBranch = False
    export = False
    exportscript = False
    exportres = False
    copy = False
    checkout = False
    uprpc = False
    if options.version :
        version = options.version
    else :  
        print "error:必须输入版号"
        exit(0)

    if options.clean:
        cleanBranch = True

    if options.export:
        export = True

    if options.exportscript:
        exportscript = True

    if options.exportres:
        exportres = True

    if options.checkout:
        checkout = True

    if options.copy:
        copy = True
    if options.uprpc:
        uprpc = True

    releasePath = "%srelease_%s/" %(BRANCH_BACKUPS_PATH, version)

    trunkPaths = [
        config.SVN_ROOT_PATH + "/program/client/trunk",
        config.SVN_ROOT_PATH + "/design/res",
        config.SVN_ROOT_PATH + u"/design/导表数据/scripts/data/battles",
        config.SVN_ROOT_PATH + u"/design/导表数据/scripts/data/battle_ai",
        config.SVN_ROOT_PATH + "/program/gameplay3d/trunk",
    ]
    
    branchPaths = [
    config.SVN_ROOT_PATH + "/backup/client/release_%s" %(version),
    config.SVN_ROOT_PATH + "/backup/res/res_release_%s" %(version),
    config.SVN_ROOT_PATH + "/backup/battles/battles_release_%s" %(version),
    config.SVN_ROOT_PATH + "/backup/ai/battle_ai_release_%s" %(version),
    config.SVN_ROOT_PATH + "/backup/engine/release_%s" %(version),
    ]

    checkOutPaths = [
        "%sclient" %(releasePath),
        "%sclient/resource/res" %(releasePath),
        "%sclient/resource/scripts/game_config/battles" %(releasePath),
        "%sclient/resource/scripts/game_config/battle_ai" %(releasePath),
        #暂时不用checkout 引挚 
        #"%sgameplay3d" %(releasePath),
    ]
    message = "release_%s" %(version)

    #清除删版本
    if cleanBranch:
        for url in branchPaths:
            SvnRm( url )
        exit(0)

    if os.path.exists(releasePath):
        print("This version has arlready exported, do you want to overwrite it? (Y/N)")
        ensure = raw_input()

        if ensure == "N":
            exit(0) 
    else:
        #先创建目录
        CreateDir( releasePath )    
    #打客户分支
    if (copy):
        for i in range(len(trunkPaths)):
            SvnCopy( trunkPaths[i], branchPaths[i], message)
        
        #checkout目录
        SvnCheckOut( branchPaths[0], checkOutPaths[0])
        #开始指定外链
        #一个命令的直接打
        cmd_str = '''cd %s && svn propset svn:externals %s release_%s/client/resource/%s'''
        item_format = "%s %s"
        path_str = '''"%s"'''%(item_format % (branchPaths[1], "res"))
        res_cmd_str = cmd_str % (BRANCH_BACKUPS_PATH, path_str, version, "")
        SafeExec(res_cmd_str)
        
        # 两条的需要借助临时一个文件来同时对一个目录设置多个属性
        temp_file_name = "%sexternals_temp.txt"%BRANCH_BACKUPS_PATH
        path_str = item_format % (branchPaths[2], "battles") + "\n" + item_format % (branchPaths[3], "battle_ai")
        common.CreateFile(temp_file_name, path_str.encode(sys.getfilesystemencoding()))
        res_cmd_str = cmd_str % (BRANCH_BACKUPS_PATH, "-F %s"%temp_file_name, version, "scripts/game_config")
        SafeExec(res_cmd_str.encode(sys.getfilesystemencoding()))
        common.DeleteFile(temp_file_name)

    if checkout:       
        #checkout客户端分支  暂不checkout引挚
        SvnCheckOutWithExternals( branchPaths[0], checkOutPaths[0])

        #协议文件  打不了分支 直接checkout  trunk上的来备份
        # trunkClientPath = config.DEFAULT_ClENTT_PATH
        # cmd  = "svn update %s" %( trunkClientPath )
        # print( cmd  )
        # SafeExec(cmd)
        # trunkRpcJsonPath = "%s/resource/res/rpcJson.cfg" %(trunkClientPath)
        # branchRpcJsonPath = "%s/resource/res/rpcJson.cfg" %(checkOutPaths[0])
        # cmd = "cp %s %s" %(trunkRpcJsonPath, branchRpcJsonPath)
        # print(cmd)
        # SafeExec(cmd)

    if exportscript:
        SvnExport( branchPaths[0], checkOutPaths[0])
        SvnExport( branchPaths[2], checkOutPaths[2])
        SvnExport( branchPaths[3], checkOutPaths[3])
    if exportres:
        if not uprpc:
            print("need to update rpcJson file？ Y/N" )
            ensure = raw_input()

            if ensure == "Y":
                branchRpcJsonPath = "%s/resource/res/rpcJson.cfg" %(checkOutPaths[0])
                SvnExportRpcJson(branchRpcJsonPath)

        SvnExport( branchPaths[1], checkOutPaths[1])
    
    if export:       
        #checkout客户端分支  暂不checkout引挚
        for i in range(len(checkOutPaths)):
            SvnExport( branchPaths[i], checkOutPaths[i])

        branchRpcJsonPath = "%s/resource/res/rpcJson.cfg" %(checkOutPaths[0])
        if not os.path.exists(branchRpcJsonPath):
            SvnExportRpcJson(branchRpcJsonPath)
    

    if uprpc:
        branchRpcJsonPath = "%s/resource/res/rpcJson.cfg" %(checkOutPaths[0])
        SvnExportRpcJson(branchRpcJsonPath)
    #修改加密图片文件的权限
    #cmd = "chmod +x %s/tool/shell/encrypt_tool/res_encrypt.py" %(checkOutPaths[0])
    #print(cmd)
    #SafeExec(cmd)

    #cmd = "chmod +x %s/tool/shell/encrypt_tool/res_encrypt" %(checkOutPaths[0])
    #print(cmd)
    #SafeExec(cmd)


    #开始打patch
    ##enginPath = "%sgameplay3d" %(releasePath)
    #clientPath = "%sclient" %(releasePath)
    ##PatchPack(clientPath, enginPath,  False, False)
    #patchScriptPath = "%s/tool/shell/release.py" %(clientPath)
    #targetPath = "%s/tool/shell/test" %(clientPath)
    #cmd = "python release.py --clientpath %s --targetpath %s --skipsvnup --createapk" %( clientPath, targetPath)
    #print(cmd)
    #SafeExec(cmd)



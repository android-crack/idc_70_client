#coding=utf-8
import shutil
import os
import json
from optparse import OptionParser
from module.common import SafeExec
import module.config as config

CUR_PATH = os.path.abspath(os.path.dirname(__file__))
BRANCH_BACKUPS_PATH = "%s/../../../../branch_backups/" %(CUR_PATH)

SCRIPT_EXPORT_MAX_IDX = 2
RES_EXPORT_IDX = 3
ENGIN_EXPORT_IDX = 4

def CreateDir( path ):
    if not os.path.exists(path):
        cmd = "mkdir -p %s" %(path)
        ret = SafeExec( cmd )
        return ret 

def SvnCopy( trunkPath, branchPath, message):
    print "svn cp branch" + trunkPath + "--->" + branchPath
    strIgnor = "--ignore-externals"
    cmd = "svn cp %s %s %s -m %s" %(strIgnor, trunkPath, branchPath, message)
    ret = SafeExec(cmd)
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

def SvnExport( url, path ):
    print "svn export --force" + url + "---------->" + path
    cmd = "svn export --force --ignore-externals %s %s" %( url, path)
    ret = SafeExec(cmd)
    return ret

def RmPath(path):
    cmd = "rm -rf " + path
    print cmd
    ret = SafeExec(cmd)
    return ret

def CreateAndroidPropertie( clientPath ):
    propertiePath = os.path.join(clientPath, "proj.android", "project.properties")
    cmd = "rm -rf %s" %(propertiePath)
    SafeExec(cmd)
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
    #parser.add_option("", "--version", action = "store", dest = "version", help = u'发布版号', type = "string")
    #parser.add_option("", "--exportdir", action = "store", dest = "exportdir", help = u'下载目录', type = "string")
    parser.add_option("", "--clean", action = "store_true", dest = "clean", help = u'清删版本')
    parser.add_option("", "--checkout", action = "store_true", dest = "checkout", help = u'check')
    parser.add_option("", "--export", action = "store_true", dest = "export", help = u'export')
    parser.add_option("", "--exportscript", action = "store_true", dest = "exportscript", help = u'exportscript')
    parser.add_option("", "--exportres", action = "store_true", dest = "exportres", help = u'exportres')
    parser.add_option("", "--copy", action = "store_true", dest = "copy", help = u'copy')
    (options, args) = parser.parse_args() 

    version = ""
    cleanBranch = False
    export = False
    exportscript = False
    exportres = False
    copy = False
    checkout = False
    exportdir = ""

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

    useConfig = False
    if (os.path.exists("backups_config.json")):
        backupsConfigData = json.load(open("backups_config.json"))
        version = backupsConfigData["version"]
        exportdir = backupsConfigData["exportdir"]
        print(u"backups_config.json配置文件，配置如下：")
        print(u"版本号(version)为：%s"%version)
        print(u"下载地址(exportdir)为：%s"%exportdir)
        while(True):
            print(u"是否采用配置文件的配置(Y为是, N为否) Y or N ?")
            inputStr = raw_input()
            useConfig = (inputStr == "Y")
            break

    if not useConfig:
        while(True):
            print(u"请输入资源版本号：")
            version = raw_input()
            break

        while(True):
            print(u"请输入下载地址：")
            exportdir = raw_input()
            break



    releasePath = "%srelease_%s/" %(BRANCH_BACKUPS_PATH, exportdir)

    trunkPaths = [
        config.SVN_ROOT_PATH + "/program/client/trunk", #client
        "https://192.168.0.3/qtz/mg01/config/trunk",
        "https://192.168.0.3/qtz/mg01/res/trunk",
        "https://192.168.0.3/qtz/mg01/program/gameplay3d/trunk", #engin
        "https://192.168.0.3/qtz/mg01/design/res_en", #language res
    ]
    
    branchPathsConfig = [
        config.SVN_ROOT_PATH + "/backup/client/release_%s", #client
        "https://192.168.0.3/qtz/mg01/config/config_release_%s",
        "https://192.168.0.3/qtz/mg01/res/release_%s",
        config.SVN_ROOT_PATH + "/backup/engine/release_%s", #engin
        "https://192.168.0.3/qtz/mg01/res/res_en_release_%s", #language res
    ]

    branchCopyPathsConfig = [
        config.SVN_ROOT_PATH + "/backup/client/release_%s"%version, #client
        "https://192.168.0.3/qtz/mg01/config/config_release_%s/out_lua/data/battles"%version,
        "https://192.168.0.3/qtz/mg01/config/config_release_%s/out_lua/data/battle_ai"%version,
        "https://192.168.0.3/qtz/mg01/res/release_%s"%version,
        config.SVN_ROOT_PATH + "/backup/engine/release_%s"%version, #engin
        "https://192.168.0.3/qtz/mg01/res/res_en_release_%s"%version, #language res
    ]
    
    branchPaths = []
    
    design_trunk_url = config.SVN_ROOT_PATH + "/design"
    design_branch_url_config = config.SVN_ROOT_PATH + "/backup/design/design_release_%s"
    
    for i in range(0, len(branchPathsConfig)):
        path_config = branchPathsConfig[i]
        branchPaths.append(path_config%version)

    checkOutPaths = [
        "%sclient" %(releasePath), #client
        "%sclient/resource/scripts/game_config/battles" %(releasePath),
        "%sclient/resource/scripts/game_config/battle_ai" %(releasePath),
        "%sclient/resource/res" %(releasePath),
        "%sgameplay3d" %(releasePath), #暂时不用checkout 引挚 
    ]
    
    message = "release_%s" %(version)

    #清除删版本
    if cleanBranch:
        print("你是否要删除这个分支?，一旦删除将无法恢复! (Y/N)")
        ensure = raw_input()

        if ensure == "Y":
            for url in branchPaths:
                SvnRm( url )

            #策划目录的分支
            #design_branch_url = design_branch_url_config %(version)
            #SvnRm( design_branch_url )
            exit(0)
        else:
            exit(0)

    if os.path.exists(releasePath):
        print("This version has arlready exported，do you want to overwrite it? (Y/N)")
        ensure = raw_input()

        if ensure == "N":
            exit(0) 
    else:
        #先创建目录
        CreateDir( releasePath )    

    #打客户分支
    if (copy):
        sourcePaths = trunkPaths
        design_source_url = design_trunk_url
        
        print("is use target branch copy to a new branch? (Y/N)")
        ensure = raw_input()
        if ensure == "Y":
            print("please to input target branch version ...")
            version_str = raw_input()
            sourcePaths = []
            for i in range(0, len(branchPathsConfig)):
                path_config = branchPathsConfig[i]
                sourcePaths.append(path_config%version_str)
                #design_source_url = design_branch_url_config%version_str
        
        #策划目录的分支
        #design_branch_url = design_branch_url_config %(version)
        for i in range(0, len(sourcePaths)):
            print("--- %s ===> %s"%(sourcePaths[i], branchPaths[i]))
        #print("--- %s ===> %s"%(design_source_url, design_branch_url))
        print("Are you sure? (Y/N)")
        ensure = raw_input()
        if ensure == "Y":
            for i in range(len(sourcePaths)):
                SvnCopy( sourcePaths[i], branchPaths[i], message)
            
            #策划目录的分支
            #SvnCopy( design_source_url, design_branch_url, message)

    #checkout
    if checkout:    
        for i in range(0, ENGIN_EXPORT_IDX+1):
            print("%s=========>%s") %(branchCopyPathsConfig[i], checkOutPaths[i])  
        while(True):
            print(u"是否确定要checkout：")
            inputStr = raw_input()
            ensure = (inputStr == "Y")
            if ensure:
                break
            else:
                exit(0)     
        #checkout客户端分支  暂不checkout引挚
        for i in range(0, ENGIN_EXPORT_IDX+1):
            SvnCheckOut( branchCopyPathsConfig[i], checkOutPaths[i])



    #export
    if exportscript:
        for i in range(0, SCRIPT_EXPORT_MAX_IDX+1):
           print("%s=========>%s") %(branchCopyPathsConfig[i], checkOutPaths[i])
    if exportres:
        print("%s=========>%s") %( branchCopyPathsConfig[RES_EXPORT_IDX], checkOutPaths[RES_EXPORT_IDX])

    if export:   
        #checkout客户端分支  暂不checkout引挚
        for i in range(0, ENGIN_EXPORT_IDX+1):
            print("%s=========>%s") %( branchCopyPathsConfig[i], checkOutPaths[i])   

    while(True):
        print(u"是否确定要export：")
        inputStr = raw_input()
        ensure = (inputStr == "Y")
        if ensure:
            break
        else:
            exit(0) 
               
    if exportscript:
        for i in range(0, SCRIPT_EXPORT_MAX_IDX+1):
            SvnExport( branchCopyPathsConfig[i], checkOutPaths[i])

    if exportres:
        SvnExport( branchCopyPathsConfig[RES_EXPORT_IDX], checkOutPaths[RES_EXPORT_IDX])
    
    if export:     
        #checkout客户端分支  暂不checkout引挚
        for i in range(0, ENGIN_EXPORT_IDX+1):
            SvnExport( branchCopyPathsConfig[i], checkOutPaths[i])






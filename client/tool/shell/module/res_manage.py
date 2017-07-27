#coding=utf-8
import sys
import os
import base64
import shutil
import config
import json
import language_dict
import common
from common import SafeExec
from common import CheckPathEnd
from common import CreateFile
from common import GetFiles
from calc_md5 import CalcMd5
from calc_md5 import CalcSingleFileMd5
from calc_md5 import CalcMd5AndRename
from calc_md5 import CalcStringMd5

sys.path.append("..")
import parser_config.utils as utils


CUR_PATH = os.path.abspath(os.path.dirname( __file__ ))
SHELL_PATH = os.path.join(CUR_PATH, "..")

IS_ENCRYPT_RES = True
IS_ENCRYPT_SCRIPT = True
IS_ENCRYPT_PATH_SCRIPT = True
IS_CALC_MD5 = True

def InitResEncodeConfig(is_encypt_res = True, is_encrypt_script = True, is_calc_md5 = True):
    global IS_ENCRYPT_RES
    global IS_ENCRYPT_SCRIPT
    global IS_CALC_MD5
    IS_ENCRYPT_RES = is_encypt_res
    IS_ENCRYPT_SCRIPT = is_encrypt_script
    IS_CALC_MD5 = is_calc_md5
    

def MakeEncodeRes(dst):
    MakeBaseConfig(dst)
    UpdateEncryptToolAccessRight()  # 更新加密工具的读取权限
    EncyptResource(dst) #加密资源
    EncyptScrpitForLuac(dst) #加密脚本 
    EncyptScriptPath(dst) #加密脚本路径

    updateInfo = os.path.join(dst, "resource", "updateInfo.json")
    common.DeleteFile(updateInfo)

    GenMd5FileListAndVersionFile(os.path.join(dst, "resource")) #生成filelist.lua \updateInfo.json

def GetPublishPlatform():
    proj= json.load( open( os.path.join(SHELL_PATH, "multi_pack", "project.json" ))) 
    projConfig = proj["config"]
    return projConfig["platform"]

def BackupResource(targetPath):
    platform = GetPublishPlatform()
    backupPath = os.path.join(SHELL_PATH, "resource_backup")
    oldPath = ""
    newPath = ""
    if platform == "ios":
        oldPath = os.path.join(backupPath, "ios", "old")
        newPath = os.path.join(backupPath, "ios", "new")
    else:
        oldPath = os.path.join(backupPath, "android", "old")
        newPath = os.path.join(backupPath, "android", "new")
    CopyEncodeResToNewPath(newPath, oldPath)
    CopyEncodeResToNewPath(targetPath, newPath)


def ExportResAndEncode(url, dst_path):
    print "svn export --force" + url + "---------->" + dst_path + "and encode"
    cmd = "svn export --force --ignore-externals %s %s" %( url, dst_path)
    ret = SafeExec(cmd)
    EncyptRes(dst_path)

def CopyEncodeResToNewPath(src, dst):
    if not os.path.exists(src):
        return
    if os.path.exists(dst):
        shutil.rmtree(dst)
    if not os.path.exists(dst):
        os.makedirs(dst)
    CopyDir(src, dst)

def AddAllFileMd5Tail(target):
    default_resource_path = os.path.join(target, "resource")
    print "CalcMd5AndRename %s" %default_resource_path
    CalcMd5AndRename(default_resource_path)

    #语言类型与res目录后缀的对应关系
    lang_dict = language_dict.LANGUAGE_DICT
    for lang in lang_dict.values():
        lang_resource_path = os.path.join(target, ("resource_%s"%lang))
        if os.path.exists(lang_resource_path):
            print "CalcMd5AndRename %s" %lang_resource_path
            CalcMd5AndRename(lang_resource_path)

    print "CalcMd5AndRename success"
    
    
def ClearUselessLangConfig(script_path, pathlang_key = "zh-CN"):
    lang_path = os.path.join(script_path, "game_config", "language")
    head_str = "language_"
    head_len = len(head_str)
    current_files = os.listdir(lang_path)
    for file_name in current_files:
        path_str = os.path.join(lang_path, file_name)
        if os.path.isfile(path_str) and (len(file_name) > head_len):
            if head_str == file_name[:head_len] :
                tail_str = file_name[head_len:head_len+len(pathlang_key)]
                check_key = pathlang_key.replace("-", "_")
                if tail_str == check_key:
                    continue
                os.remove(path_str)
    
    
#下面是做包的调用函数

def CopyApkRes(android_path, resource_path, remove_files_cfg = []): #准备资源
    android_assets_path = os.path.join(android_path, "assets")
    #删除老的asstes
    if os.path.exists(android_assets_path) :
        print "try remove %s"%android_assets_path
        shutil.rmtree(android_assets_path)
    if not os.path.exists(android_assets_path):
        os.makedirs(android_assets_path)
    #拷贝
    CopyDir(resource_path, android_assets_path)
    #删除mp3,m4a
    mp3_path = os.path.join(android_path, "assets", "res", "sound", "mp3")
    shutil.rmtree( mp3_path )
    m4a_path = os.path.join(android_path, "assets", "res", "sound", "m4a")
    shutil.rmtree( m4a_path )
    
    #删除指定文件
    if len(remove_files_cfg):
        for remove_dir in remove_files_cfg:
            shutil.rmtree(os.path.join(android_assets_path, remove_dir))
            
def CopyIpaRes(client_path, res_path): # 准备打包资源操作
    resource_path = os.path.join(client_path, "resource")
    resource_bak_path = os.path.join(client_path, "_resource_bak")
    if os.path.exists(resource_bak_path) :
        assert False, "pack ipa error, %s has exist, please check resource"%resource_bak_path
    try :
        os.rename(resource_path, resource_bak_path)
        #拷贝
        CopyDir( os.path.join(res_path, "resource"), resource_path )
        #删除mp3,ogg
        mp3_path = os.path.join(resource_path, "res", "sound", "mp3")
        shutil.rmtree( mp3_path )
        m4a_path = os.path.join(resource_path, "res", "sound", "ogg")
        shutil.rmtree( m4a_path )
    except Exception, e:
        print "packet error	%s"%e

def RestoreIpaRes(client_path): # 完成包的处理后的操作
    resource_path = os.path.join(client_path, "resource")
    resource_bak_path = os.path.join(client_path, "_resource_bak")
    if os.path.exists(resource_path) :
        print "try remove %s"%resource_path
        shutil.rmtree(resource_path)
    os.rename(resource_bak_path, resource_path)
    
#下面的是工具的函数
def CopyDir(src, dst):
    if os.path.exists(dst):
        print "try remove %s"%dst
        shutil.rmtree(dst)
    print "copytree:%s->%s"%(src, dst)	
    shutil.copytree(src, dst)

def MergeDir(src, dst):
    cmd = "cp -rfp %s/* %s/"%(src, dst)
    print cmd
    ret = SafeExec(cmd)
    return ret
    
def ClearDotSvnFile(path):
    cmd = "find %s -name \"*.svn*\"|xargs rm -rf"%path
    print cmd
    ret = SafeExec(cmd)
    return ret

def MakeMd5FileList(target):
    if IS_CALC_MD5 : 
        skip_files = GetSkipFiles()
        md5_file = os.path.join(target, config.FILE_LIST)
        target = CheckPathEnd(target)
        CalcMd5(target, skip_files, md5_file)
        print "calc md5 to %s success" % target

#基础配置
def MakeBaseConfig(target):
    configs = json.load( open( os.path.join(SHELL_PATH, "multi_pack", "base_config.json" )))
    content = configs["config"]
    luaStr = utils.objToLuaStr(content)
    path = "%s/resource/scripts/root/baseConfig.lua" %(target)
    CreateFile(path, "return%s" %(luaStr))

#patch 信息
def MakeUpdateInfo(target):
    filelist = os.path.join(target, config.FILE_LIST)
    filelistMd5 = CalcSingleFileMd5(filelist)
    configs = json.load( open( os.path.join(SHELL_PATH, "multi_pack", "update_info.json" ))) 
    content = configs["config"]
    content["filelist_md5"] = filelistMd5

    path = os.path.join(target, "..", "updateinfo")
    if not os.path.exists(path):
        os.makedirs(path)

    updateInfoPath = os.path.join(path, "updateInfo.json")
    CreateFile(updateInfoPath, utils.objToJson(content))

    fixInfoPath = os.path.join(path, "fixInfo.lua")
    if not os.path.exists(fixInfoPath):
        CreateFile(fixInfoPath, "")

#filelist 加密
def EncyptFilelist(target):
    CompileLuaFileForLuac(target, target)

def GenMd5FileListAndVersionFile(target):
    MakeMd5FileList(target)
    EncyptFilelist(target)
    MakeUpdateInfo(target)
    
    
def CopyResourceWithClean(sourcePath, targetPath):
    if os.path.exists(targetPath):
        shutil.rmtree(targetPath)
    sourcePath = os.path.join(sourcePath, "resource")
    targetResPath = os.path.join(targetPath, "resource")
    CopyDir(sourcePath, targetResPath)
    targetResTestPath = os.path.join(targetResPath, "test")
    if os.path.exists(targetResTestPath):
        shutil.rmtree(targetResTestPath)

def CompileLuaFileForLuac(src, dst):
    cmds = [
    os.path.join(SHELL_PATH, "compile_scripts", "compile_scripts.sh"),
    "-i %s" % src,
    "-o %s" % dst,
    #"-x %s" % ",".join(exclude_files),
    "-m files",
    "-e xxtea_chunk",
    "-ek dhh",]
    ret = SafeExec(" ".join(cmds))
    return ret 
    
def EncyptResource(targetPath):
    if IS_ENCRYPT_RES:
        paths = ["resource/res/"]
        for path in paths:
            targetResourcePath = targetPath + path
            ClearDotSvnFile(targetResourcePath)
            cmd = "python %s e %s"%(config.RES_ENCYPT_TOOLS, targetResourcePath)
            SafeExec(cmd)
        print "encypt resource success"

def EncyptRes(res_path):
    ClearDotSvnFile(res_path)
    cmd = "python %s e %s"%(config.RES_ENCYPT_TOOLS, res_path)
    SafeExec(cmd)
        
def EncyptScrpitForLuac(targetPath):
    if IS_ENCRYPT_SCRIPT:
        paths = ["resource/scripts/"]
        for path in paths:
            targetScriptPath = targetPath + path
            ClearDotSvnFile(targetScriptPath)
            CompileLuaFileForLuac(targetScriptPath, targetScriptPath)
        print "encypt script success"


def EncyptPath(path):
    str = CalcStringMd5(path)
    return str 

#加密lua路径
def EncyptScriptPath(targetPath):
    if IS_ENCRYPT_PATH_SCRIPT:
        resourcePath = os.path.join(targetPath, "resource")
        scriptsPath = os.path.join(resourcePath, "scripts")
        frameworkPath = os.path.join(scriptsPath, "base", "framework_precompiled.zip")

        scriptBakPath = os.path.join(resourcePath, "scripts_bak")
        frameworkBakPath = os.path.join(scriptBakPath, "base", "framework_precompiled.zip")
        resourceBakPath = os.path.join(targetPath,"resource_bak")
        #CopyDir(resourcePath, resourceBakPath)

        #filelistPath = os.path.join(resourcePath, "filelist.lua")
        #filelistNewPath = os.path.join(resourcePath, EncyptPath(filelistPath))
        #os.rename(filelistPath, filelistNewPath)

        if not os.path.exists(scriptBakPath):
            os.makedirs(scriptBakPath)

        path = os.path.join(scriptBakPath, "base")
        if not os.path.exists(path):
            os.makedirs(path)
            os.rename(frameworkPath, frameworkBakPath)

        fileContents = {}
        filePath = os.path.join(targetPath, "scriptPath.json")

        files = GetFiles(scriptsPath)
        for f in files:
            if f.find(".lua") != -1:
                path = f.replace(scriptsPath + "/", "")
                encyptPath = EncyptPath(path)
                newPath = os.path.join(scriptBakPath, encyptPath)
                os.rename(f, newPath)

                fileContents["scripts/" + encyptPath] = "scripts/" + path
        
        fp = open(filePath, "w")
        json.dump(fileContents, fp)
        fp.close()
       
        if os.path.exists(scriptsPath):
            shutil.rmtree(scriptsPath)
        os.rename(scriptBakPath, scriptsPath)

    
#忽略MD5总配置文件，跳过更新   
def GetSkipFiles():
    skipFiles = [config.FILE_LIST, config.BASE_CONFIG, config.DSSTORE_FILE] 
    if IS_ENCRYPT_PATH_SCRIPT:
        skipFiles.append(EncyptPath(config.BASE_CONFIG))
    return skipFiles

def UpdateEncryptToolAccessRight():
    SafeExec("chmod u+x encrypt_tool/res_encrypt")
    SafeExec("chmod u+x encrypt_tool/res_encrypt.py")

def PrepareLanguageRes( target_path, version ):
    #语言类型与res目录后缀的对应关系
    lang_dict = language_dict.LANGUAGE_DICT

    #收集要制作的其它语言的类型
    language_keys = []
    channel_ids = json.load( open( os.path.join(SHELL_PATH, "multi_pack", "release.json" ) ) )
    configs = json.load( open( os.path.join(SHELL_PATH, "multi_pack", "proj_cfg.json" ) ) ) 
    for channel_id in channel_ids:
        channel_config = configs[ channel_id ]
        try:
            language_type = lang_dict[channel_config["language"]]
            print(language_type)
            language_keys.append(channel_config["language"])
        except KeyError:
            print("needn't update res language type %s" %channel_config["language"])

    #准备好每个语言的资源
    default_resource_path = os.path.join(target_path, "resource") #resource
    for language_key in language_keys:
        language = lang_dict[language_key]
        #co resource to resource_en resource_...
        lang_resource_path = os.path.join(target_path, ("resource_%s" %language))
        CopyDir(default_resource_path, lang_resource_path)

        #RES_BRANCH_BACKUP_PATH = "https://192.168.0.3/qtz/mg01/backup/res/"
        #RES_TRUNK_PATH = "https://192.168.0.3/qtz/mg01/design/"
        lang_res_path = os.path.join(lang_resource_path, ("res_%s" %language))
        lang_res_url = config.RES_TRUNK_PRE_PATH + "res_" + language
        if version != "debug":
            lang_res_url = config.RES_BRANCH_BACKUP_PRE_PATH + "res_" + language +"_release_" + version

        #export 语言资源并加密 resource_en/res_en
        ExportResAndEncode(lang_res_url, lang_res_path)
        MergeDir( lang_res_path, os.path.join(lang_resource_path, "res"))

        print "try remove %s" %lang_res_path
        shutil.rmtree(lang_res_path)
        ClearUselessLangConfig(os.path.join(lang_resource_path, "scripts"), language_key)#删除多余的多语言配置
        GenMd5FileListAndVersionFile(lang_resource_path)
    ClearUselessLangConfig(os.path.join(default_resource_path, "scripts"))#删除简体中文区的多语言配置文件
    GenMd5FileListAndVersionFile(default_resource_path)#重新生成配置文件






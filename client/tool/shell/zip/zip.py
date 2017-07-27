# -*- coding: utf-8 -*-
import sys
import os
import zipfile
import time
import shutil
import json
import urllib2

sys.path.append("..")
import module.res_manage as res_manage
import module.config as config
import module.checkDiff as checkDiff
import module.common as common
from optparse import OptionParser
import utils

CUR_PATH = os.path.abspath(os.path.dirname( __file__ )) 
RES_PATH = os.path.join(CUR_PATH, "..", "resource_backup")

def Zip( filename, src_path ):
    with zipfile.ZipFile( filename, 'w', zipfile.ZIP_DEFLATED ) as zip:
        pDir = os.path.dirname( src_path )
        for root, dirs, files in os.walk( src_path ):
            for file in files:
                absDir = os.path.join(root, file)
                relativeDir = absDir.replace(pDir, "")
                zip.write( absDir, relativeDir )

def printCn(print_str):
    print(print_str.encode(sys.getfilesystemencoding()))


# 判断这个版本是否已经发布过
def CheckFilelistOnline(target):
    updateInfo = os.path.join(target, "updateinfo", "updateInfo.json")
    jsonData = json.load(open(updateInfo))
    fileMd5 = jsonData["filelist_md5"]
    fileName = "filelist.lua.%s" %fileMd5
    url = jsonData["resource_url"][0]["url"] + "/" + fileName
    if url.find("http") == -1:
        url = "http://" + url
        
    try:
        resp = urllib2.urlopen(url)
        if resp.code == 200:
            return True
    except:
        print("\tError retrieving the URL:%s" %url)
    return False


def CoypResAndCheckDiff(destPath, platform, isZipDiff = True, useConfig = False, isContinue = True):
    newPath = os.path.join(RES_PATH, platform, "new")
    oldPath = os.path.join(RES_PATH, platform, "old")
    srcPath = os.path.join(newPath, "resource")
    if not os.path.exists(srcPath):
        print("源文件目录%s不存在！！!"%srcPath)
        return
        
    diffPaths = checkDiff.checkFilelistDiff(newPath, oldPath)
    if os.path.exists(oldPath):
        #检查oldPath 是否已经已经发布过
        print("检查oldPath 是否已经已经发布过")
        isOk = CheckFilelistOnline(oldPath)
        print(isOk)
        if not isOk:
            if not useConfig:
                while(True):
                    printCn(u"上次的资源并没有分布过，是否要继续？ Y or N ?")
                    inputStr = raw_input()
                    isContinue = (inputStr == "Y")
                    break
        if not isContinue:
            assert isOk, "检查oldPath 还没有发布过，很危险！！！！！！！"

    if len(diffPaths) > 0 and not os.path.exists(destPath):
        os.makedirs(destPath)

    if isZipDiff:
        for path in diffPaths:
            destFile = os.path.join(destPath, path)
            srcFile = os.path.join(srcPath, path)
            utils.copyFile(srcFile, destFile)
    else:
        res_manage.CopyEncodeResToNewPath(srcPath, destPath)
    

def Start(force=False):
    printCn(u"----------------------   开始压缩  -----------------------------")
    useConfig = False
    envName = ""
    osName = "all"
    versionName = ""
    #是否只压缩不同资源
    isZipDiff = True
    isContinue = True
    isZipInfo = "Y"
    if (os.path.exists("zip_config.json")):
        zipConfigData = json.load(open("zip_config.json"))
        envName = zipConfigData["envName"]
        osName = zipConfigData["osName"]
        versionName = zipConfigData["versionName"]
        isZipDiffStr = zipConfigData["isZipDiffStr"]
        isZipInfo = zipConfigData["isZipInfo"]
        isContinueStr = zipConfigData["isContinueStr"]
        isZipDiff = (isZipDiffStr == "Y")
        isContinue = (isContinueStr == "Y")
        printCn("检测到有zip_config.json配置文件，配置如下：")
        printCn("环境为：%s"%envName)
        printCn("手机平台(android/ios/all)为：%s"%osName)
        printCn("资源版本号为：%s"%versionName)
        printCn("是否只压缩不同资源(Y为和上一次资源对比压缩修改的资源, N为全部资源都压缩)为：%s"%isZipDiffStr)
        printCn("是否压缩updateInfo内容：%s"%isZipInfo)
        printCn("如果上次的资源并没有分布过，是否要继续:%s"%isContinueStr)
        if force:
            printCn("采用了--force的参数，将直接采用配置文件的配置，若需要修改，请修改配置文件")
            useConfig = True
        else:
            while(True):
                printCn(u"是否采用配置文件的配置(Y为时, N为否) Y or N ?")
                inputStr = raw_input()
                useConfig = (inputStr == "Y")
                break

    if not useConfig:
        while(True):
            printCn(u"请输入环境：test  or  release ")
            envName = raw_input()
            if envName != "test" and envName != "release" :
                printCn("输入环境非法：%s"%envName)
            else :
                break

        while(True):
            printCn(u"请输入手机平台：android / ios / all (输入all则android ios 都压) ")
            osName = raw_input()
            printCn("选择平台：%s"%osName)
            break

        while(True):
            printCn(u"请输入资源版本号：")
            versionName = raw_input()
            break

        while(True):
            printCn(u"是否只压缩不同资源 (Y为和上一次资源对比压缩修改的资源, N为全部资源都压缩) Y or N ?")
            inputStr = raw_input()
            isZipDiff = (inputStr == "Y")
            break

	
    #删除之前的目录
    if os.path.exists(envName):
        shutil.rmtree(envName)

    #压缩包名
    today = time.strftime("%Y%m%d_%H%M")
    zipDir = "dhh_%s_%s_%s" %(envName, versionName, today)
    zipDirName = "%s.zip" %zipDir

    #拷贝路径    
    if osName == "android" or osName == "ios":
        platform = osName
        destPath = os.path.join(CUR_PATH, envName, platform, versionName)
        CoypResAndCheckDiff(destPath, platform, isZipDiff, useConfig, isContinue)
    else:
        platform = "android"
        destPath = os.path.join(CUR_PATH, envName, platform, versionName)
        CoypResAndCheckDiff(destPath, platform, isZipDiff, useConfig, isContinue)

        platform = "ios"
        destPath = os.path.join(CUR_PATH, envName, platform, versionName)
        CoypResAndCheckDiff(destPath, platform, isZipDiff, useConfig, isContinue)

    #压缩并命名
    if os.path.exists(envName):
        Zip(zipDirName, envName)
    else:
        printCn("没有可压缩的资源！！！！！！！")
    

    #@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    #压缩updateInfo
    updateInfoPath = os.path.join(CUR_PATH, "updateinfo")
    if os.path.exists(updateInfoPath):
        shutil.rmtree(updateInfoPath)

    if not useConfig: 
        while(True):
            printCn(u"是否压缩updateInfo内容 Y or N ?")
            isZipInfo = raw_input()
            break

    if isZipInfo == "Y":
         #拷贝路径    
        if osName == "android" or osName == "ios":
            platform = osName
            destPath = os.path.join(updateInfoPath, platform)
            srcPath = os.path.join(RES_PATH, platform, "new", "updateinfo")
            res_manage.CopyEncodeResToNewPath(srcPath, destPath)
        else:
            platform = "android"
            destPath = os.path.join(updateInfoPath, platform)
            srcPath = os.path.join(RES_PATH, platform, "new", "updateinfo")
            res_manage.CopyEncodeResToNewPath(srcPath, destPath)

            platform = "ios"
            destPath = os.path.join(updateInfoPath, platform)
            srcPath = os.path.join(RES_PATH, platform, "new", "updateinfo")
            res_manage.CopyEncodeResToNewPath(srcPath, destPath)

    #压缩并命名
    zipDirName = "updateinfo_%s_%s_%s.zip" %(envName, versionName, today)
    Zip(zipDirName, updateInfoPath)

    print("done")


if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("", "--force", action = "store_true", dest = "force", help = u'强制使用zip_config.json里面的配置')
    (options, args) = parser.parse_args() 
    force = False;
    if options.force:
        force = True
    Start(force)

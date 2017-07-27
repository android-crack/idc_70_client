#coding=utf-8
import os
import json
import res_manage
import config
from common import SafeExec
from common import CheckPathEnd
import plistlib
import time

CUR_PATH = os.path.abspath(os.path.dirname( __file__ ))
SHELL_PATH = os.path.join(CUR_PATH, "..")

#内服测试包
def MakeDebugIpa(ios_path, client_path, res_path):
    res_manage.CopyIpaRes(client_path, res_path)
    try:
        BuildIpa(ios_path, client_path)
        print "create ipa finish"
    except Exception, e:
        print "packet error	%s"%e
    res_manage.RestoreIpaRes(client_path)

#外服正式包
def MakePublishIpa(client_path, res_path):
    res_manage.CopyIpaRes(client_path, res_path)
    _proj_config = json.load( open( os.path.join( SHELL_PATH, "multi_pack", "project.json" ) ) )
    _base_config = json.load( open( os.path.join( SHELL_PATH, "multi_pack", "base_config.json" ) ) )
    proj_config = _proj_config["config"]
    base_config = _base_config["config"]

    try:
        #res_manage.GenMd5FileListAndVersionFile(os.path.join(client_path, "resource"))
        BuildPublishIpa(client_path, proj_config, base_config)
    except Exception, e:
        print "!!!!!!!!!!!!!!!!!!!!"
        print "error %s"%e
    res_manage.RestoreIpaRes(client_path)
    
def BuildPublishIpa(clientpath, proj_config, base_config):
    targetproject = proj_config["project_name"]
    if proj_config["platform"] == "ios":
        iosPath = CheckPathEnd(os.path.join(clientpath, targetproject))
        BuildIpa(iosPath, clientpath, proj_config, base_config["channel_id"])
        
#流程：把客户端resouces目录先改名，再创建一个指向加密完的资源的软链接，再打包，
#打完包后，删除软链接，原本的目录名字改回来
def BuildIpa(iosPath, clientPath, proj_config = False, channel_id = "debug") :
    '''
    path=`pwd`
    xcodebuild -workspace ${path}/dhh.xcodeproj/project.xcworkspace -scheme dhh -configuration Release -sdk iphoneos8.1 -archivePath ${path}/dhh archive 
    xcrun -sdk iphoneos8.1 PackageApplication -v -o ${path}/apps/dhh.ipa  ${path}/dhh.xcarchive/Products/Applications/dhh.app
    -v 对应的是app文件的绝对相对路径 –o 对应ipa文件的路径跟文件名 –sign 
    对应的是 发布证书中对应的公司名或是个人名  –embed 对应的是发布证书文件 
    注意如果对应的Distribution 配置中已经配置好了相关证书信息的话 –sign 和 –embed可以忽略 
    '''	

    #默认的证书
    CODE_SIGN_IDENTITY="\"iPhone Distribution: Guangzhou Qingtianzhu Network Technology Co.,Ltd.\"",
    PROVISIONING_PROFILE= _getUUIDFromMobileprovision( os.path.join(clientPath, "ios_profile", "DHH_QTZ_DIST.mobileprovision") )
    embed = os.path.join(clientPath, "ios_profile", "DHH_QTZ_DIST.mobileprovision")
    displayName = "dhh"
    appId = "com.qtz.game.dhh"
    appVersion = "1.0.0"
    appBuildVersion = "1.0.0"
    exportMethod = "enterprise"

    if proj_config:
        CODE_SIGN_IDENTITY = proj_config["sign"]
        embed = os.path.join(clientPath, "ios_profile", proj_config["sign_file"])
        PROVISIONING_PROFILE = _getUUIDFromMobileprovision( embed )

        displayName = proj_config["app_name"]
        appId = proj_config["app_id"]
        appVersion = proj_config["app_version"]
        appBuildVersion = appVersion
        exportMethod = proj_config["export_method"]

    projectName = "dhh"

    #修改Info.plist
    infoPlist = os.path.join( iosPath, projectName, "Resources", "Info.plist" )
    infoData = plistlib.readPlist( infoPlist )
    infoData["CFBundleDisplayName"] = displayName
    infoData["CFBundleIdentifier"]  = appId
    infoData["CFBundleShortVersionString"]  = appVersion
    infoData["CFBundleVersion"]  = appBuildVersion
    plistlib.writePlist( infoData, infoPlist ) 

    exportOptionsPlist = os.path.join(CUR_PATH, "exportOptions.plist")
    exportDate = plistlib.readPlist(exportOptionsPlist)
    exportDate["method"] = exportMethod
    plistlib.writePlist( exportDate, exportOptionsPlist ) 

    cmds = [
        "xcodebuild archive",
        "-workspace %s"%os.path.join(iosPath, "%s.xcodeproj"%projectName, "project.xcworkspace"),
        "-scheme %s"%projectName,
        "-configuration Release",
        "-sdk iphoneos%s"%config.IOS_SDK_VERSION,
        "-archivePath %s archive"%os.path.join(iosPath, projectName),
        "CODE_SIGN_IDENTITY=%s"%CODE_SIGN_IDENTITY,
        "PROVISIONING_PROFILE=%s"%PROVISIONING_PROFILE,
        "PRODUCT_BUNDLE_IDENTIFIER=%s"%appId
    ]
    SafeExec( " ".join(cmds) )
    #CODE_SIGN_IDENTITY PROVISIONING_PROFILE

    curTime = time.strftime("%Y%m%d%H%M%S")
    fileName = "dhh_%s_%s_%s" %(channel_id, appVersion, curTime)
    ipaPath = os.path.join(clientPath, "tool/shell/apps")
    if not os.path.exists(ipaPath):
        os.makedirs(ipaPath)
    ipaPath = os.path.join(ipaPath, fileName)

    cmds = [
        "xcodebuild -exportArchive",
        "-archivePath %s archive"%os.path.join(iosPath, "%s.xcarchive"%projectName),
        "-exportOptionsPlist %s"%exportOptionsPlist,
        "-exportPath %s"%ipaPath
    ]

    SafeExec( " ".join(cmds) )
    

def _getUUIDFromMobileprovision( provisioningFile ):
    provision_dict = None
    with open(provisioningFile) as provision_file:
        provision_data = provision_file.read()

        start_tag = '<?xml version="1.0" encoding="UTF-8"?>'
        stop_tag = '</plist>'

        try:
            start_index = provision_data.index(start_tag)
            stop_index = provision_data.index(stop_tag, start_index + len(start_tag)) + len(stop_tag)
        except ValueError:
            raise MobileProvisionReadException(
                    'This is not a valid mobile provision file'
            )

        plist_data = provision_data[start_index:stop_index]
        provision_dict = plistlib.readPlistFromString(plist_data)
    return provision_dict[ "UUID" ]
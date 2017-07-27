#coding=utf-8
import os
import json
import res_manage
import package_mgr
import language_dict
import apk
from common import SafeExec
from common import CheckPathEnd

CUR_PATH = os.path.abspath(os.path.dirname( __file__ ))
SHELL_PATH = os.path.join(CUR_PATH, "..")

#内服测试包
def MakeDebugApk(android_path, res_path):
    UpdateAndroidProjectConfig()
    try:
        res_manage.CopyApkRes(android_path, res_path) #准备好apk的资源
        BuildDebugApk(android_path, True)
        print "create Debug apk finish"
    except Exception, e:
        print "packet error	%s"%e
    
def BuildDebugApk(androidPath, is_debug_sign = False):
    create_game_so_cmd = "sh %sbuild.sh"%androidPath
    SafeExec(create_game_so_cmd)
    if False == is_debug_sign:
        create_apk_cmd = "ant release -f %sbuild.xml"%androidPath
    else:
        create_apk_cmd = "ant debug -f %sbuild.xml"%androidPath
    SafeExec(create_apk_cmd)

#外服正式包
def MakePublishApk(client_path, target_path):
    UpdateAndroidProjectConfig()
    _proj_config = json.load( open( os.path.join( SHELL_PATH, "multi_pack", "project.json" ) ) )
    _base_config = json.load( open( os.path.join( SHELL_PATH, "multi_pack", "base_config.json" ) ) )
    proj_config = _proj_config["config"]
    base_config = _base_config["config"]

    channel_id = base_config["channel_id"]
    targetproject = proj_config["project_name"]
    android_path = os.path.join(client_path, targetproject)
    print(android_path, target_path)
        
    #做小包的时候用到，排除多余的资源
    remove_files_cfg = ["updateInfo.json"]
    try:
        exclude_files = proj_config["exclude_files"]
        print(os.path.join( SHELL_PATH, "multi_pack", exclude_files ))
        remove_files_cfg = json.load( open( os.path.join( SHELL_PATH, "multi_pack", exclude_files ) ) ) 
    except KeyError:
        print(channel_id, "none exclude")
        remove_files_cfg = []
        
    #根据语类型来决定assets里面的内容
    resource_path = os.path.join(target_path, "resource")
    '''
    lang = base_config["language"]
    lang_dict = language_dict.LANGUAGE_DICT
    try:
        resource_tail = lang_dict[lang]
        #test/resource_en
        resource_path = os.path.join(target_path, "resource_%s"%resource_tail)
    except KeyError:
        print(channel_id, "none language resource")
    '''
    res_manage.CopyApkRes(android_path, resource_path, remove_files_cfg)
    android_assets_path = os.path.join(android_path, "assets")
    #res_manage.GenMd5FileListAndVersionFile(android_assets_path)

    #打包啦
    BuildReleaseApk(client_path, channel_id, proj_config)

            
def BuildReleaseApk(clientpath, channel_id, config):
    print "android channel_id"
    print channel_id
    targetproject = config["project_name"]

    if config["platform"] == "android":
        android_path = CheckPathEnd(os.path.join(clientpath, targetproject))
        #编译gameplay
        create_game_so_cmd = "sh %sbuild.sh"%android_path
        print "build so..."
        SafeExec(create_game_so_cmd)

        ant_properties = os.path.join(android_path, "ant.properties")
        if os.path.exists(ant_properties):
            print "remove ant%s"%ant_properties
            os.remove(ant_properties)
        #打包
        package_mgr.config_package( channel_id, config )
        apk.release(channel_id, config)
    
def UpdateAndroidProjectConfig():
    #添加执行权限
    cmd_str = '''cd ../../%s && android update project -p . -t "android-21"%s'''
    SafeExec(cmd_str % ("tencent_proj.android", ""))
    SafeExec(cmd_str % ("proj.android", ""))
    SafeExec(cmd_str % ("efun_proj.android", ""))
    SafeExec(cmd_str % ("android_sdk/DhhLibrary", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/MSDKLibrary", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/XFYunLibrary", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/MidasLibrary", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/SafeSDKLibrary", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/E-PD-V2-OS-EPD-SDK-2.6.8.1", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/Efun-smhy-Google-561171", " --subprojects"))
    SafeExec(cmd_str % ("android_sdk/FacebookSDK-4.5.1", " --subprojects"))
    SafeExec(cmd_str % ("../gameplay3d/lib/cocos2d-x/cocos2dx/platform/android/java", ""))

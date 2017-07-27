# -*- coding: utf-8 -*-
import os
import rsync
import sys
import shutil
import json
from optparse import OptionParser

sys.path.append("../")
import module.common as common
import module.checkDiff as checkDiff
import module.res_manage as res_manage
import parser_config.getRsyncServerList as getRsyncServerList
import parser_config.parserConfig as parserConfig
import parser_config.utils as configUtils

import utils

CUR_PATH = os.path.abspath(os.path.dirname(__file__))
SHELL_PATH = os.path.join(CUR_PATH, "..")

    
if __name__ == "__main__":
    parser = OptionParser()
    parser.add_option("", "--version", action = "store", dest = "version", help = u'版本号')
    (options, args) = parser.parse_args() 

    if options.version :
        version = options.version
    else :  
        print(u"error:必须输入版号")
        exit(0)

    #重新更新配置
    parserConfig.startWriteCfg(version)

    platform = res_manage.GetPublishPlatform()
    backupPath = os.path.join(CUR_PATH, "..", "resource_backup")
    newPath = os.path.join(backupPath, platform, "new")
   
    #同步配置
    if rsync.confirmTips(u"是否要同步 version %s 配置config（updateInfo.json and fixInfo.lua）Y/N ?" %version):
        resourcePath = os.path.join(newPath, "updateinfo")
        publicPath = os.path.join(CUR_PATH, "test")
        utils.copyFile(resourcePath, publicPath)

        if not os.path.exists(publicPath):
            os.makedirs(publicPath)
            fixInfoPath = os.path.join(publicPath, "fixInfo.lua")
            common.CreateFile(fixInfoPath, "")

        #用对应版本的配置重新生成
        testConfig = json.load( open(os.path.join(CUR_PATH, "testConfig.json")))
        filelistMd5 = testConfig["filelist_md5"]
        config = json.load( open( os.path.join(SHELL_PATH, "multi_pack", "update_info.json" ))) 
        content = config["config"]
        content["filelist_md5"] = filelistMd5
        updateInfoPath = os.path.join(publicPath, "updateInfo.json")
        common.CreateFile(updateInfoPath, configUtils.objToJson(content))

        serverList = getRsyncServerList.getRsynConfigPathList()
        rsync.startRsync(publicPath, serverList)
        if os.path.exists(publicPath):
            shutil.rmtree(publicPath)
        print(u"同步完成！！！")



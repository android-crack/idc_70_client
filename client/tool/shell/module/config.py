#!/usr/local/bin/python
#-*- coding: utf-8 -*

import os
ROOT_PATH = os.path.dirname(os.path.realpath("__file__"))
SVN="svn"
DEFAULT_TARGET_PATH="test"
PUBLISH_TARGET_PATH="publish"
RELEASE_TARGET_PATH="release"
DEFAULT_ClENTT_PATH="../../"
LUAJIT_TOOL= os.path.join(ROOT_PATH, "luajit")
RES_ENCYPT_TOOLS = os.path.join(ROOT_PATH, "encrypt_tool", "res_encrypt.py")
FILE_LIST = "filelist.lua"
BASE_CONFIG = "root/baseConfig.lua"
DSSTORE_FILE = ".DS_Store"
IOS_SDK_VERSION = "10.1"
SVN_ROOT_PATH = "https://192.168.0.3/qtz/mg01"
RES_BRANCH_BACKUP_PRE_PATH = SVN_ROOT_PATH + "/res/"
RES_TRUNK_PRE_PATH = SVN_ROOT_PATH + "/design/"
APK_TEMP_FILE_SVN = SVN_ROOT_PATH + "/backup/client/release_%s/%s"


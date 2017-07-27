# -*- coding: utf-8 -*-
import os
import sys
CUR_PATH = os.path.abspath(os.path.dirname(__file__))
tools_path = CUR_PATH + "/trunk/client/tool/shell/"
sys.path.append(tools_path)
import module.config as config

ROOT_PATH = os.path.abspath(os.path.dirname(__file__))
WRITE_PACK_PATH = os.path.join(ROOT_PATH + "/..","multi_pack")
WRITE_MODULE_PATH = os.path.join(ROOT_PATH + "/..","module")
# SVN_EXCEL_PATH = u"https://192.168.0.3/qtz/mg01/design/技术/维护/cfgExcel.xlsx"
# SVN_EXCEL_PATH = u"https://192.168.0.3/qtz/mg01/design/%E6%8A%80%E6%9C%AF/%E7%BB%B4%E6%8A%A4/cfgExcel.xlsx"
SVN_EXCEL_PATH = config.SVN_ROOT_PATH + u"/design/技术/维护/cfgExcel/"
# SVN_EXCEL_PATH = config.SVN_ROOT_PATH + u"/design/%E6%8A%80%E6%9C%AF/%E7%BB%B4%E6%8A%A4/cfgExcel/"
# SVN_EXCEL_PATH = config.SVN_ROOT_PATH + u"/design/技术/维护/cfgExcel.xlsx"
LOCAL_EXCEL_PATH = os.path.join(ROOT_PATH,"cfgExcel")


SHEET_PROJECT = "project"
SHEET_DOMAIN = "domain_map" #域名映射表
SHEET_BASE_CONFIG = "base_config"
SHEET_UPDATE_INFO = "update_info"

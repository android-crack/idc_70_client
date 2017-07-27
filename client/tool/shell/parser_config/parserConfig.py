# -*- coding: utf-8 -*-
import os
import json
import utils
import rootConfig
from parserExcel import ParserExcel
import sys
reload(sys)
sys.setdefaultencoding("utf-8")

def writeProjCfg():
	global excel_data
	file_name = "project.json"
	obj = excel_data.getObjBySheetName(rootConfig.SHEET_PROJECT,True)
	utils.writeFile(rootConfig.WRITE_PACK_PATH,file_name,utils.objToJson(obj))
	
def writeBaseCfg():
	global excel_data
	file_name = "base_config.json"
	obj = excel_data.getObjBySheetName(rootConfig.SHEET_BASE_CONFIG,True)
	utils.writeFile(rootConfig.WRITE_PACK_PATH,file_name,utils.objToJson(obj))
	
def writeUpdateInfo():
	global excel_data
	file_name = "update_info.json"
	obj = excel_data.getObjBySheetName(rootConfig.SHEET_UPDATE_INFO,True)
	utils.writeFile(rootConfig.WRITE_PACK_PATH, file_name,utils.objToJson(obj))


#生成域名映射表
def writeDomainMap():
	global excel_data
	domain_map_name = "domain_map.json"

	domain_map_obj = excel_data.getObjBySheetName(rootConfig.SHEET_DOMAIN,True)

	real_domain_map = {} #重新生成一份新的映射表
	for name_key,domain_value in domain_map_obj.items():
		domain_data = {}
		domain_data["server_list"] = {} #单独存一个,后续进行排序用
		real_domain_map[str(domain_value["domain"].replace(" ",""))] = domain_data #以域名为key,取出空格
		del domain_value["domain"] #删掉域名key
		for key,value in domain_value.items():
			key_list = key.split("_")
			if len(key_list) > 1:
				server_list = domain_data["server_list"]
				key_type = key_list[0]
				key_index = int(key_list[1])
				if server_list.has_key(key_index) == False:
					server_list[key_index] = {"index":key_index} #加上index用做排序
				temp_dict = server_list[key_index]
				temp_dict[key_type] = value
			else:
				domain_data[key] = value

	for domain_url,domain_list in real_domain_map.items():
		server_list = []
		for server_key,server_data in domain_list["server_list"].items():
			server_list.append(server_data)

		# server_list.sort(reverse=True) #测试排序
		server_list.sort(key=lambda x:x["index"]) 
		# domain_list["server_list"] = server_list
		real_domain_map[domain_url] = server_list

	utils.writeFile(rootConfig.WRITE_PACK_PATH,domain_map_name,utils.objToJson(real_domain_map))

def startWriteCfg(version = "debug", force_publish = False):
	cfg_excel_name = "cfgExcel_" + version + ".xlsx" #拼接出带版本号的excel文件

	local_cfg_path = os.path.join(rootConfig.LOCAL_EXCEL_PATH, cfg_excel_name) #获得本地的excel文件，删掉

	svn_cfg_path = rootConfig.SVN_EXCEL_PATH + cfg_excel_name # 拼接svn上的excel文件地址

	utils.createPath(rootConfig.LOCAL_EXCEL_PATH)

	#强制使用最新的配置
	if force_publish:
		utils.svnExportForce(svn_cfg_path,rootConfig.LOCAL_EXCEL_PATH, local_cfg_path)
	else:
		utils.svnExport(svn_cfg_path,rootConfig.LOCAL_EXCEL_PATH, local_cfg_path)


	if utils.checkPathExists(local_cfg_path):
		global excel_data
		excel_data = ParserExcel(local_cfg_path)

		writeProjCfg()

		writeBaseCfg()

		writeUpdateInfo()

		writeDomainMap()

		print(u"parser config done!")
	else:
		print(u"get cfgExcel.xlsx failure!!!")

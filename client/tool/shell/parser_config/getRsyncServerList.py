# -*- coding: utf-8 -*-
import os
import json
import rootConfig
import utils
from parserExcel import ParserExcel
import sys
reload(sys)
sys.setdefaultencoding("utf-8")

#获取同步服务器路径列表(config)
def getRsynConfigPathList():
	base_config = json.load(open(os.path.join(rootConfig.WRITE_PACK_PATH, "base_config.json")))
	domain_config = json.load(open(os.path.join(rootConfig.WRITE_PACK_PATH,"domain_map.json")))

	server_list = {}

	#todo 目前先固定第一个url
	for k in base_config:
		config = base_config[k]
		url = config["update_info_url"]
		url_split = url.split("/")
		resource_domain = url_split[0]
		if (len(url_split) < 3):
			print("url: %s error!!!!!!!!!" %url)
			break;

		if domain_config.has_key(resource_domain):
			domain_list = domain_config[resource_domain]
			for i in range(0, len(domain_list)):
				clone_obj = utils.cloneObject(domain_list[i])
				ip = clone_obj["ip"]
				real_path = url.replace(resource_domain + "/", ip + "::")
				
				if server_list.has_key(real_path) == False:
					res_path = ""
					for k in range(1, len(url_split) - 1):
						res_path = res_path + url_split[k] + "/"

					clone_obj["res_path"] = url_split[len(url_split) - 1]
					clone_obj["rsync_path"] = "dhh@" + ip + "::" + res_path
					clone_obj["show_path"] = real_path
					server_list[real_path] = clone_obj

				else:
					print("error:has not domain config for %s,please check domain_map sheet"%resource_domain)#
		else:
			print("error:has not project config for %s,please check server sheet"%resource_domain)
	print(server_list)
	return server_list



#获取同步服务器路径列表(res)
def getRsynPathList():
	update_config = json.load(open(os.path.join(rootConfig.WRITE_PACK_PATH, "update_info.json")))
	domain_config = json.load(open(os.path.join(rootConfig.WRITE_PACK_PATH,"domain_map.json")))

	server_list = {}

	#todo 目前先固定第一个url
	for k in update_config:
		config = update_config[k]
		resource_config = config["resource_url"][0]
		url = resource_config["url"]
		url_split = url.split("/")
		resource_domain = url_split[0]
		if (len(url_split) < 3):
			print("url: %s error!!!!!!!!!" %url)
			break;
		if domain_config.has_key(resource_domain):
			domain_list = domain_config[resource_domain]
			for i in range(0, len(domain_list)):
				clone_obj = utils.cloneObject(domain_list[i])
				ip = clone_obj["ip"]
				real_path = url.replace(resource_domain + "/", ip + "::")
				
				if server_list.has_key(real_path) == False:
					res_path = ""
					for k in range(1, len(url_split) - 1):
						res_path = res_path + url_split[k] + "/"

					clone_obj["res_path"] = url_split[len(url_split) - 1]
					clone_obj["rsync_path"] = "dhh@" + ip + "::" + res_path
					clone_obj["show_path"] = real_path
					server_list[real_path] = clone_obj

				else:
					print("error:has not domain config for %s,please check domain_map sheet"%resource_domain)#
		else:
			print("error:has not project config for %s,please check server sheet"%resource_domain)
	print(server_list)
	return server_list


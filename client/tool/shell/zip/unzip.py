# -*- coding: utf-8 -*-
import sys
reload(sys) 
sys.setdefaultencoding('utf8')
import os
import zipfile
import json
import time

CUR_PATH = os.path.abspath(os.path.dirname( __file__ ))

def printCn(print_str):
    print(print_str.encode(sys.getfilesystemencoding()))

def UnZip( file_name, extract_path ):
    if file_name[-4:] != '.zip':
        printCn("错误：%s不是zip文件"%file_name)
        return
    zip_files = zipfile.ZipFile(file_name, "r")
    zip_files.extractall(extract_path)
    zip_files.close()

def Start():
    json_data = json.load(open("unzip_config.json"))
    version = json_data["versionName"]
    unzip_path = json_data["unzipPath"]
    extract_path = os.path.join(CUR_PATH, unzip_path)
    prefix_source = "dhh_" + version
    prefix_updateinfo = "updateinfo_" + version
    length_prefix_source = len(prefix_source)
    length_prefix_updateinfo = len(prefix_updateinfo)
    file_names=os.listdir(CUR_PATH)
    last_source_file = ""
    last_updateinfo_file = ""
    #通过比较文件名，获取最新的dhh_{version}_{timestamp}.zip和updateinfo_{version}_{timestamp}.zip文件
    for name in file_names:
        if prefix_source == name[0:length_prefix_source]:
            #cmp(x,y)如果X < Y,返回值是负数 如果X>Y 返回的值为正数
            if cmp(name, last_source_file) > 0:
                last_source_file = name
        elif prefix_updateinfo == name[0:length_prefix_updateinfo]:
            if cmp(name, last_updateinfo_file) > 0:
                last_updateinfo_file = name
    if (last_source_file[-8:] != last_updateinfo_file[-8:]):
        printCn("请注意%s和%s不是同个时间生成的" % (last_source_file, last_updateinfo_file))
    printCn("资源文件压缩包是%s" % last_source_file)
    printCn("updateinfo文件压缩包是%s" % last_updateinfo_file)
    UnZip(last_source_file, extract_path)
    UnZip(last_updateinfo_file, extract_path)

if __name__ == "__main__":
    Start()
# -*- coding: utf-8 -*-
import shutil
import os
import json

CUR_PATH = os.path.abspath(os.path.dirname( __file__ ))
SHELL_PATH = os.path.join(CUR_PATH, "..")

def getFileNameInfo(file_name):
    file_name = file_name.strip()
    file_name_len = len(file_name)
    for i in range(file_name_len):
        true_index = file_name_len - 1 - i
        if file_name[true_index] == ".":
            return file_name[:true_index], file_name[true_index+1:]
    return file_name, ""

def getAllFilesInfo(find_path):
    files = []
    files_dic = {}
    find_path_len = len(find_path)
    for par_dir, dir_names, file_names in os.walk(find_path):
        for file_name in file_names:
            cut_file_path = par_dir[find_path_len:]
            true_file_name, md5_str = getFileNameInfo(file_name)
            true_file_path = os.path.join(cut_file_path, true_file_name)
            files.append(true_file_path)
            file_info = {}
            file_info["file_name"] = file_name
            file_info["true_file_name"] = true_file_name
            file_info["cut_file_path"] = cut_file_path
            file_info["md5"] = md5_str
            file_info["is_delete"] = True
            files_dic[true_file_path] = file_info
    return files, files_dic


def checkPathDiff(path1, path2):
    path1_files, path1_files_dic = getAllFilesInfo(path1)
    path2_files, path2_files_dic = getAllFilesInfo(path2)
    
    diff_arr = []
    add_arr = []
    del_arr = []
    #记录下那些是变的
    for k in path1_files:
        path1_file_info = path1_files_dic[k]
        if path2_files_dic.has_key(k):
            path2_file_info = path2_files_dic[k]
            path2_file_info["is_delete"] = False
            if path1_file_info["md5"] != path2_file_info["md5"]:
                diff_arr.append(k)
        else:
            add_arr.append(k)
    for k in path2_files:
        path2_file_info = path2_files_dic[k]
        if path2_file_info["is_delete"]:
            del_arr.append(k)
    
    #打印啦
    print("check path : %s <------- %s"%(path1, path2))
    print("add file count = %d  ---------------------------"%len(add_arr))
    for k in add_arr:
        file_info = path1_files_dic[k]
        print("    %s :   md5=%s "%(k, file_info["md5"]))
        
    print("delete file count = %d ---------------------------"%len(del_arr))
    for k in del_arr:
        file_info = path2_files_dic[k]
        print("    %s :   md5=%s "%(k, file_info["md5"]))
    
    print("change file count = %d ---------------------------"%len(diff_arr))
    for k in diff_arr:
        path1_file_info = path1_files_dic[k]
        path2_file_info = path2_files_dic[k]
        print("    %s :   md5 --- %s <-- %s "%(k, path1_file_info["md5"], path2_file_info["md5"]))


#根据filelist 对比文件
def checkFilelistDiff(newPath, oldPath):
    oldFilelist = os.path.join(oldPath, "filelistJson.json")
    newFilelist = os.path.join(newPath, "filelistJson.json")

    newFiles = {}
    oldFiles = {}

    retArr = []
    diffArr = []
    addArr = []
    delArr = []
    retPaths = []

    if not os.path.exists(newFilelist):
        print("filelist %s is not exits!!!" %newFilelist)
        return retPaths
    newFiles = json.load(open(newFilelist))

    if os.path.exists(oldFilelist):
         oldFiles = json.load(open(oldFilelist))

    #check add or change
    for k in newFiles:
        newValue = newFiles[k]
        if oldFiles.has_key(k):
            oldValue = oldFiles[k]
            if oldValue["md5"] != newValue["md5"]:
                diffArr.append(k)
                retArr.append("%s.%s" %(k, newValue["md5"]))
        else:
            addArr.append(k)
            retArr.append("%s.%s" %(k, newValue["md5"]))

    #check del
    for k in oldFiles:
        oldValue = oldFiles[k]
        if not newFiles.has_key(k):
            delArr.append(k)

    #打印啦
    print("check path : %s <------- %s"%(newPath, oldPath))
    print("add file count = %d  ---------------------------"%len(addArr))
    for k in addArr:
        fileInfo = newFiles[k]
        if fileInfo.has_key("scriptPath"):
            k = fileInfo["scriptPath"]
        print("    %s :   md5=%s "%(k, fileInfo["md5"]))
        
    print("delete file count = %d ---------------------------"%len(delArr))
    for k in delArr:
        fileInfo = oldFiles[k]
        if fileInfo.has_key("scriptPath"):
            k = fileInfo["scriptPath"]
        print("    %s :   md5=%s "%(k, fileInfo["md5"]))
    
    print("change file count = %d ---------------------------"%len(diffArr))
    for k in diffArr:
        newFileInfo = newFiles[k]
        oldFileInfo = oldFiles[k]
        if newFileInfo.has_key("scriptPath"):
            k = newFileInfo["scriptPath"]
        print("    %s :   md5 --- %s <-- %s "%(k, newFileInfo["md5"], oldFileInfo["md5"]))    

    return retArr

        
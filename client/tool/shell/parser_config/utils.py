# -*- coding: utf-8 -*-
import os
import shutil
import json
import types

#写入文件 路径,文件名,内容
def writeFile(path,filename,content):
    real_path = os.path.join(path,filename)
    deleteFile(real_path)

    createPath(path) #创建目录

    file = open(real_path,"w")
    file.write(content)
    file.close()

#检查路径是否存在
def createPath(path):
    if os.path.exists(path) == False:
        os.makedirs(path)

#检查路径是否存在
def checkPathExists(path):
    print path
    return os.path.exists(path)

#删除文件
def deleteFile(path):
    if os.path.exists(path):
        if os.path.isdir(path):
            shutil.rmtree(path)
        else:
            os.remove(path)
#obj转json
def objToJson(obj):
	return json.dumps(obj,indent = 4,sort_keys=True,ensure_ascii=False)

OFF_CHAR = "    "

def objToLuaStr(obj,off_char = OFF_CHAR):
    OFF_CHAR = off_char
    return off_char + "{\n" + objToLua(obj,off_char + off_char) + OFF_CHAR + "}"

#逼我自己写转lua
def objToLua(obj,off_char = ""):
    content = ""
    for key,value in obj.items():
        content += off_char
        if type(key) is types.IntType:
            content += "{" + str(key) + "}"
        else:
            content += str(key)
        content += " = "
        value_type = type(value)
        if value_type is types.DictType: #如果还是词典
            content += "\n" + off_char + "{\n" + objToLua(value,off_char + OFF_CHAR) + off_char + "}"
        elif value_type is types.ListType: #如果是数组
            content += "{"
            for i in range(0,len(value)):
                content += objToLua(value[i],off_char + OFF_CHAR)
            content += "}"
            add_end = len(value) > 1
        elif value_type is types.BooleanType: #布尔值
            if value == True:
                content += "true"
            else:
                content += "false"
        elif value_type is types.IntType or value_type is types.LongType or value_type is types.FloatType:
            content += str(value)
        else:
            content += "\"" + str(value) + "\""

        content += ",\n"

    return content

#克隆对象
def cloneObject(obj):
    temp = None
    if type(obj) is types.DictType:
        temp = {}
        for key,value in obj.items():
            temp[key] = cloneObject(value)
    elif type(obj) is types.ListType:
        temp = []
        for i in range(0,len(obj)):
            temp.append(cloneObject(obj[i]))
    else:
        temp = obj
    return temp


def safeExec(cmd,JustShow=False):
    if JustShow: 
        print cmd 
        return 0
    status = os.system(cmd)
    status >>= 8
    assert status == 0, "system execute '%s' return %d" % ( cmd, status )
    return status


def svnExport( url, path, localpath ):
    print "svn export " + url + "---------->" + path
    if os.path.exists(path):
        print("路径已经存在，是否要覆盖export ---------(Y/N)?")
        ensure = raw_input()
        if ensure == "Y":
            deleteFile(localpath)
            cmd = "svn export --force --ignore-externals %s %s" %( url, path)
            ret = safeExec(cmd)
            return ret
        else:
            print "没有重新export,使用本地的！！！"
            return
    
def svnExportForce( url, path, localpath ):
    print "svn export --force" + url + "---------->" + path
    if os.path.exists(path):
        print("路径已经存在，强制删除并重新export")
        deleteFile(localpath)
    cmd = "svn export --force --ignore-externals %s %s" %( url, path)
    ret = safeExec(cmd)
    return ret


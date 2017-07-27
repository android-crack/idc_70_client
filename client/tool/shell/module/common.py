#coding=utf-8
import os
import sys
import shutil
import re

reload(sys)
sys.setdefaultencoding('utf-8')

def SafeExec(cmd,JustShow=False):
	if JustShow: 
		print cmd 
		return 0
	status = os.system(cmd)
	status >>= 8
	assert status == 0, "system execute '%s' return %d" % ( cmd, status )
	return status

def GetFiles(path):
    files = []
    for f in os.listdir(path):
        f = os.path.join(path, f)
        f = f.replace("\\", "/")
        if os.path.isdir(f):
            files.extend(GetFiles(f))
        else:
            files.append(f)
    return files

def GetDirs(path):
    dirs = []
    for f in os.listdir(path):
        dirPath = os.path.join(path, f)
        dirPath = dirPath.replace("\\", "/")
        if os.path.isdir(dirPath):        
            dirs.append(f)
    return dirs

def CheckPathEnd(path):
	if not path.endswith("/") and not path.endswith("\\") : 
		path += "/"
	return path	


def CreateFile( path, content ):
    DeleteFile(path)
    f = open(path, "w")
    f.write( content )
    f.close()
    
def DeleteFile(file_path):
    if os.path.isfile(file_path): 
        os.remove(file_path)
		
#替换文本内容
def ModifFile(file_path, sstr, rstr):
    if os.path.isfile(file_path):
        f = open(file_path, "r")
        text = f.read().replace(sstr, rstr)
        f.close()
        DeleteFile(file_path)
        f = open(file_path, "w")
        f.write(text)
        f.close()
	

# 打印中文
def printCn(print_str):
    print(print_str.encode(sys.getfilesystemencoding()))

# 确认框
def confirmTips(tips_str):
    printCn(tips_str + u" --- (Y/N)?")
    input = raw_input()
    if input.lower() == "y":
        return True
    printCn(u"-----输入否-----")
    return False

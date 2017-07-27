#coding=utf-8
import os
import json
from hashlib import md5
from common import GetFiles
from optparse import OptionParser
from common import CheckPathEnd

def CalcStringMd5(str):
	m = md5()
	m.update(str)
	return m.hexdigest()

def CalcSingleFileMd5(filename) :
    m = md5()
    myfile = open(filename, "rb")
    m.update(myfile.read())
    myfile.close()
    return m.hexdigest()


def CalcMd5(targetPath, skipFiles, fileList) :
	
	filelistJson = os.path.join(targetPath, "..", "filelistJson.json")
	scriptPath = os.path.join(targetPath, "..", "scriptPath.json")

	scriptPathMap = {}
	jsonContents = {}
	isMakeJson = False 
	if os.path.exists(scriptPath):
		isMakeJson = True
		scriptPathMap = json.load(open(scriptPath))
	
	files = GetFiles(targetPath)
	rowFormat = '["%s"]={md5="%s",size="%s"},\n'
	fileContents = "return {\n"
	for f in files:
		skip = False
		for name in skipFiles:
			if f.find(name) != -1 :
				skip = True	
				break
		if f.startswith("."):
				skip = True
		if skip :
			continue
		filePath = f.replace(targetPath, "")
		fileMd5 = CalcSingleFileMd5(f)
		fileSize = os.path.getsize(f)
		fileContents += rowFormat%(filePath, fileMd5, fileSize)

		if isMakeJson:
			jsonValue = {"md5":fileMd5, "fileSize":fileSize}
			if scriptPathMap.has_key(filePath):
				jsonValue["scriptPath"] =  scriptPathMap[filePath]
			jsonContents[filePath] = jsonValue

	fileContents += "}"
	outputFile = open(fileList, "w")
	outputFile.write(fileContents)
	outputFile.close()

	if isMakeJson:
		filelistPath = os.path.join(targetPath, "filelist.lua")
		filelistMd5 = CalcSingleFileMd5(filelistPath)
		filelistSize = os.path.getsize(filelistPath)
		jsonContents["filelist.lua"] = {"md5":filelistMd5, "fileSize":filelistSize}
		fp = open(filelistJson, "w")
		json.dump(jsonContents, fp, indent = 4, sort_keys = True)
		fp.close()
		os.remove(scriptPath)

def CalcMd5AndRename(targetPath) :
	skipFiles = []
	files = GetFiles(targetPath)
	for f in files:
		skip = False
		for name in skipFiles:
			if f.find(name) != -1 :
				skip = True
				break
		if f.startswith("."):
			skip = True
		if skip :
			continue
		fileMd5 = CalcSingleFileMd5(f)
		os.rename(f, "%s.%s" %(f, fileMd5))


if __name__ == '__main__':
	parser = OptionParser()
	parser.add_option("", "--path", action = "store", dest="path",  help = u'md5计算的路径', type = "string")
	parser.add_option("", "--file", action = "store", dest="file",  help = u'计算结果存储的文件', type = "string")
	(options, args) = parser.parse_args() 
	if not options.path :
		print "error, need path"	
	if not options.file :
		print "error, need file name"
	options.path = CheckPathEnd(options.path)
	CalcMd5(options.path, [], options.file)

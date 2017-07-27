#!/usr/bin/evn python
# -*- encoding:utf-8 -*-

import sys
import os

CUR_PATH		= os.path.abspath( os.path.dirname( __file__ ) )
ResEncryptTool = os.path.join( CUR_PATH, "res_encrypt" )
ResEncryptCocosCmd = ResEncryptTool + " -o %s -l 128 -p %s"
ResEncrypt3dCmd = ResEncryptTool + " -o %s -l 0 -p %s"

SupportPostFix = ['png', 'jpg']
SupportPostFixAll = ['cfg']
SkipEncrypt = ['port_bg_']
#SupportPostFixAll = []

def SafeExec(cmd,JustShow=False):
	if JustShow: 
		print cmd 
		return 0
	status = os.system(cmd)
	status >>= 8
	assert status == 0, "system execute '%s' return %d" % ( cmd, status )
	return status


def FilterFileName(filename):
	specCharTable = ["(", ")"]
	for ch in specCharTable:
		filename = filename.replace(ch, "\\%s"%ch)
	return filename

def TranslateAllFiles(imageDir, translateFlag):
	if translateFlag == 'e':
		logPrefix = 'encrypting: '
	else:
		logPrefix = 'decrypting: '

	for parent, dirNames, fileNames in os.walk(imageDir):
		if parent.find(".svn") > 0:
			continue
			
		if parent.find("3d") > 0 or parent.find("shaders") > 0:
			for fileName in fileNames:
				for postFix in SupportPostFix:	
					fullFilePath = os.path.join(parent, fileName)
					fullFilePath = FilterFileName(fullFilePath)
					print(logPrefix + fullFilePath)
					SafeExec(ResEncrypt3dCmd%(translateFlag, fullFilePath))

		#分享资源不加密
		elif parent.find("sdk_share") > 0: 
			print("")						
		else:
			for fileName in fileNames:
				for postFix in SupportPostFix:

					#是否跳过加密
					isSkipEncrypt = False
					for skipFile in SkipEncrypt:
						if skipFile in fileName:
							isSkipEncrypt = True
							break;
					if isSkipEncrypt == True:
						continue;

					if fileName.endswith(postFix):
						fullFilePath = os.path.join(parent, fileName)
						fullFilePath = FilterFileName(fullFilePath)
						print(logPrefix + fullFilePath)
						SafeExec(ResEncryptCocosCmd%(translateFlag, fullFilePath))
					else:
						for postFix in SupportPostFixAll:
							if fileName.endswith(postFix):
								fullFilePath = os.path.join(parent, fileName)
								fullFilePath = FilterFileName(fullFilePath)
								print(logPrefix + fullFilePath)
								SafeExec(ResEncrypt3dCmd%(translateFlag, fullFilePath))
	
def Usage():
	help = "usage:\n"
	help += "python ImageEncrypt.py e[d] dir"
	print help

if __name__ == '__main__':
	if len(sys.argv) != 3 :
		Usage()
		sys.exit(1)

	dirName = sys.argv[2]
	if not os.path.isabs(dirName):
		dirName = os.path.join(os.getcwd(), dirName)
	
	if os.path.isdir(dirName):
		TranslateAllFiles(dirName, sys.argv[1])

#coding=utf-8
from optparse import OptionParser
import module.config as config
from module.common import GetDirs
from module.common import SafeExec
import parser_config.parserConfig as parser_config

if __name__ == '__main__':
	parser = OptionParser()
	parser.add_option("", "--createapk", action = "store_true", dest = "createapk", help = u'生成apk包')
	parser.add_option("", "--createipa", action = "store_true", dest = "createipa", help = u'生成ipa包')
	parser.add_option("", "--version", action = "store", dest = "version", help = u'版本号')
	parser.add_option("", "--force", action = "store_true", dest = "force", help = u'强制更新配置')
	(options, args) = parser.parse_args() 
	
	if options.version :
		version = options.version
	else :  
		version = "debug"

	force_publish = False
	if options.force:
		force_publish = True

	
	parser_config.startWriteCfg(version, force_publish)

	versionoption = "--version %s" %version 
	createoption = ""
	servertype = "--publish"
	if options.createipa :
		createoption = createoption + "--createipa" + " "
	if options.createapk :
		createoption = createoption + "--createapk" + " "
		
	#打patch
	cmd = "python release.py  --skipsvnup " + versionoption + " " + servertype + " " + createoption 
	print(cmd)
	SafeExec(cmd)

	print("done!")
	
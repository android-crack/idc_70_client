#coding=utf-8

from optparse import OptionParser
import os
import module.res_manage as res_manage
import module.android_manage as android_manage
import module.ios_manage as ios_manage
import module.config as config
from module.common import SafeExec
from module.common import CheckPathEnd
from module.common import ModifFile

CUR_PATH = os.path.abspath( os.path.dirname( __file__ ) )

def SvnUp(path, ignoreExt=False, cleanup=False):
    print "svn up " + path
    if ignoreExt:
        strIgnor = "--ignore-externals"
    else:
        strIgnor = ""
        cmd = "svn update %s %s" %(strIgnor, path)
    if cleanup:
        cmd = "svn cleanup %s && %s" %(path, cmd)
    ret = SafeExec(cmd)
    return ret
        
if __name__ == '__main__':
    parser = OptionParser()
    parser.add_option("", "--clientpath", action = "store", dest="clientpath",  help = u'客户端client目录', type = "string")
    parser.add_option("", "--androidpath", action = "store", dest = "androidpath", help = u'客户端android目录', type = "string")
    parser.add_option("", "--iospath", action = "store", dest = "iospath", help = u'客户端ios目录', type = "string")
    parser.add_option("", "--targetproject", action = "store", dest = "targetproject", help = u'客户端android project名字',type = "string")
    parser.add_option("", "--targetpath", action = "store", dest = "targetpath", help = u'加密资源的临时目录', type = "string")
    parser.add_option("", "--skipresource", action = "store_true", dest = "skipresource", help = u'跳过资源更新')
    parser.add_option("", "--createapk", action = "store_true", dest = "createapk", help = u'生成apk包')
    parser.add_option("", "--createipa", action = "store_true", dest = "createipa", help = u'生成ipa包')
    parser.add_option("", "--skipcalcmd5", action = "store_true", dest = "skipcalcmd5", help = u'跳过计算md5')
    parser.add_option("", "--skipsvnup", action = "store_true", dest = "skipsvnup", help = u'跳过svnup')
    parser.add_option("", "--publish", action = "store_true", dest = "publish", help = u'发布')
    parser.add_option("", "--version", action = "store", dest = "version", help = u'版本号')
    (options, args) = parser.parse_args() 

    clientPath = ""
    androidPath = ""
    iosPath = ""
    targetproject = ""
    targetPath = ""
    encyptResource = True
    encyptScript = True
    createApk = False
    calcMd5 = True
    createIpa = False
    skipsvnup = False
    publish = False
    version = "debug"

    if options.version :
        version = options.version
    if options.skipresource : 
        encyptResource = False	
    if options.createapk :
        createApk = True
    if options.skipcalcmd5:
        calcMd5 = False
    if options.createipa :
        createIpa = True
    if options.skipsvnup:
        skipsvnup = True
    if options.publish :
        publish = True

    if not options.clientpath :
        options.clientpath = config.DEFAULT_ClENTT_PATH
        print "not input clientpath, use default %s"%options.clientpath
    clientPath = CheckPathEnd( os.path.abspath( options.clientpath ) )

    if options.targetproject :
        targetproject = options.targetproject
    else :
        targetproject = "proj.android"
        print "not input targetproject, use default %s"%targetproject
        
    if options.androidpath :
        androidPath = options.androidpath
    else :
        androidPath = os.path.join( clientPath, targetproject )
        print "not input androidPath, use default %s"%androidPath
    androidPath = CheckPathEnd( os.path.abspath( androidPath ) )
    
    if options.iospath :
        iosPath = options.iospath
    else :
        iosPath = os.path.join(clientPath,  "proj.ios")
        print "not input iosPath, use default %s"%iosPath
    iosPath = CheckPathEnd( os.path.abspath(iosPath) )

    if options.targetpath :
        targetPath = options.targetpath
    else :
        targetPath = config.DEFAULT_TARGET_PATH
        print "not input targetPath, use default %s"%targetPath
    targetPath = CheckPathEnd( os.path.abspath(targetPath) )

            
    if not skipsvnup:
        SvnUp(clientPath)
        SvnUp(os.getenv("QUICK_COCOS2DX_ROOT"))
        print "update finish"

    #初始化是否加密的标志位
    res_manage.InitResEncodeConfig(encyptResource, encyptScript, calcMd5)
    
    #在对应位置（通常为test）生成可以发包用的全部资源
    res_manage.CopyResourceWithClean(clientPath, targetPath)

    #根据是否debug版本 而屏蔽bugly的功能
    msdkFile = "%sresource/msdkconfig.ini" %targetPath
    debugStr = "CLOSE_BUGLY_REPORT=true"
    publishStr = "CLOSE_BUGLY_REPORT=false"
    if version == "debug" :
        ModifFile(msdkFile, publishStr, debugStr)
    else:
        ModifFile(msdkFile, debugStr, publishStr)

    #加密
    res_manage.MakeEncodeRes(targetPath)

    srcPath = targetPath
    destPath = "%s/resource" %config.PUBLISH_TARGET_PATH

    #准备多语言相关资源
    #res_manage.PrepareLanguageRes(targetPath, version)

    #把打包用的资源拷一份到新的目录（通常为test->relesae 或 test->publish）
    res_manage.CopyEncodeResToNewPath(srcPath, destPath)
    
    #把资源添加上md5的尾巴
    res_manage.AddAllFileMd5Tail(destPath)

    #资源备份
    res_manage.BackupResource(destPath)

    #以上打patch的功能结束，下面是打手机包的内容啦
    if createApk: #android包创建
        android_manage.MakePublishApk(clientPath, targetPath)
        """
            if options.publish:
                android_manage.MakePublishApk(clientPath, targetPath)
            else:
                android_manage.MakeDebugApk(androidPath, targetPath)
        """


    if createIpa: #ios包创建
        ios_manage.MakePublishIpa(clientPath, targetPath)
        """
        if options.publish:
            ios_manage.MakePublishIpa(clientPath, targetPath)
        else:
            ios_manage.MakeDebugIpa(iosPath, clientPath, targetPath)
        """
    print "done"


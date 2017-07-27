#!/usr/bin/env python
#-*- coding: utf-8 -*-
import os
import time
import shutil
import json
import utils
import config

CUR_PATH  = os.path.abspath( os.path.dirname( __file__ ) )
PRJ_PATH  = os.path.join( CUR_PATH, "..", "..", "..")
TEMP_SVN_PATH = os.path.join(PRJ_PATH,".svn")

LAST_PATH = os.path.join(CUR_PATH, "..")

def exec_cmd( cmd ):
	try:
		os.system( cmd )
	except:
		print( "execute %s error!" % cmd )


def _getProjectCfg( channelId ):
    configs = json.load( open( os.path.join( CUR_PATH, "android_projects.json" ) ) )
    for cfg in configs:
        if cfg[ "channel_id" ] == channelId:
            return cfg


def _getProjectPath( cfg ):
    return os.path.join( PRJ_PATH, cfg[ "project_name" ] ) 


"""
def _getProjectName( chanelId ):
    return os.path.basename( _getProjectPath( channelId ) )
"""


def _getApkFilePath( channelId ):
    date        = time.strftime("%Y%m%d", time.localtime(time.time())) 
    projectName = "zlsg" 
    apkFilePath = "%s.apk" % "_".join( [projectName, channelId, date] )  
    appsPath    = os.path.join( LAST_PATH, "apps" )    
    if not os.path.exists( appsPath ):
        os.makedirs( appsPath )
    return os.path.join( appsPath, apkFilePath )


def _getApkFile():
    binPath = os.path.join( os.getcwd(), "bin" )
    files   = [ f for f in os.listdir( binPath ) if os.path.isfile( os.path.join( binPath, f ) ) and f.endswith( ".apk" ) ]
    return os.path.join( os.path.join( binPath, files[ len( files ) - 1 ] ) )


def _debug():
    exec_cmd( "ant debug" )
    return _getApkFile()


def _getFilename( filename ):
    ret = os.path.splitext( filename )[0].split( "-" )
    length = len( ret )
    if length > 0:
        length = length - 1
    
    return "%s.apk" % "-".join( ret[ : length ] )


def _release():
    exec_cmd( "ant release 1>&0" )
    unsignedApkFile     = _getApkFile()
    unsignedApkFilename = os.path.basename( unsignedApkFile )
    apkFileDir          = os.path.dirname( unsignedApkFile )
    signedApkFile       = _getFilename( unsignedApkFilename )
    sign( unsignedApkFile, os.path.join( apkFileDir, signedApkFile ) )
    alignedApkFile      = _getFilename( signedApkFile ) 
    zipalign( os.path.join( apkFileDir, signedApkFile ), 
              os.path.join( apkFileDir, alignedApkFile ) )
    return os.path.join( apkFileDir, alignedApkFile )


def _configProj( projectPath, channelId ):
    qtzConfigPath = os.path.join( projectPath, "assets", "qtz_config.properties" )  
    QTZConfig( channelId ).writeToFile( qtzConfigPath )
    

def pack( channelId ):
    projectConfig   = _getProjectCfg( channelId )
    projectPath     = _getProjectPath( projectConfig )

    # config project
    _configProj( projectPath, channelId )

    currentPath = os.getcwd()
    os.chdir( projectPath )
    exec_cmd( "ant clean" )
    apkFile = None
    if True:
        apkFile = _debug()
    else:
        apkFile = _release()
    os.chdir( currentPath )
    
    #utils.copyFile( apkFile, _getApkFilePath( channelId ) )


class APK():
    def __init__( self, channel_id, config):
        self._channel_id    = channel_id
        self._config        = config
        self._app_version   = config["app_version"]

        _proj_path          = os.path.join( PRJ_PATH, self._config[ "project_name" ] ) 
        self._proj_path     = os.path.abspath( _proj_path )


    def _get_keystore_full_path( self, filename ):
        return os.path.join( LAST_PATH, "keystore_files", filename )


    def _get_apk_file( self ):
        bin_path = os.path.join( os.getcwd(), "bin" )
        files   = [ f for f in os.listdir( bin_path ) if os.path.isfile( os.path.join( bin_path, f ) ) and f.endswith( ".apk" ) ]
        return os.path.join( os.path.join( bin_path, files[ len( files ) - 1 ] ) )


    def _get_app_name( self, sign_name ):
        date     = time.strftime("%Y%m%d%H%M", time.localtime(time.time())) 
        apk_name = "%s.apk" % "_".join( ["dhh", self._channel_id, self._app_version, date] )
        return apk_name

    #-verbose:it indicates "Verbose" mode,which causes jasigner to output extra information as to the progress of the JARS signing or verification.
    #-keystore:Specifies the URL that tells the keystore location.
    #-storepass:Specifies the pwd which is required to access the keystore.
    #-sigalg algorithm: Specified the name of the signature algorithm to user to sign the JAR file.
    #-degestalg algorithm: Sepcifies the name of the message digest algorithm to use when digesting the entries of a jar file.
    #-signedjar file: Specifies the name to be used for signed JAR files. 
    def _sign( self, src_apk, dest_apk, sign_file, passwd, alias):
        sign_path = self._get_keystore_full_path( sign_file ) 
        cmds = [
            "jarsigner -verbose",
            "-digestalg SHA1",
            "-sigalg MD5withRSA",
            "-storepass %s" % passwd,
            "-keystore %s" % sign_path,
            "-signedjar",
            "%s %s 1>&0" % ( dest_apk, src_apk ),
            alias
        ]

        exec_cmd( " ".join( cmds ) )

    #zipalign [-f] [-v] <alignment> infile.apk outfile.apk
    # To align infile.apk and save it as outfile.apk
    #-f: overwrite existing outfile.zip
    #-v: verbose output
    # <alignment>: it is an integer that defines the byte-alignment boundried.This must be 4(which provides 32-bit alignment) or else it effectively does nothing.
    def _zipalign( self, src_apk, dest_apk ):
        cmds = "zipalign -f 4 %s %s" %( src_apk, dest_apk )
        exec_cmd( cmds)


    def _clean_env( self ):
        del_file_list = ["src","bin","gen","res","AndroidManifest.xml"]

        print "Start to clean env...."
        for file in del_file_list:
            utils.removeFile(os.path.join(self._proj_path,file))

        # shutil.rmtree( os.path.join( self._proj_path, "src" ))
        # shutil.rmtree(os.path.join(self._proj_path, "bin"))
        # shutil.rmtree(os.path.join(self._proj_path, "gen"))
        # shutil.rmtree(os.path.join(self._proj_path, "res"))
        # # shutil.rmtree( os.path.join( self._proj_path, "libs" ) )
        # os.remove( os.path.join( self._proj_path, "AndroidManifest.xml" ))
        

        if os.path.exists(TEMP_SVN_PATH):
            #存在.svn文件,用更新
            exec_cmd("svn up %s 1>&0" % self._proj_path)
        else:
            #不存在.svn文件,用导出
            svn_url = config.APK_TEMP_FILE_SVN%(self._version,self._config[ "project_name" ])
            exec_cmd("svn export --force --ignore-externals %s %s" %( svn_url, self._proj_path))
        

    def pack( self ):
        current_path  = os.getcwd()

        app_path = os.path.join( LAST_PATH, "apps" )
        if not os.path.exists( app_path ):
            os.makedirs( app_path ) 

        os.chdir( self._proj_path )
        exec_cmd( "ant clean" )
        exec_cmd( "ant release 1>&0" )
       
        for item in self._config[ "sign_files" ]:
            #bin下找到的未签名的apk文件
            orig_apk_file = self._get_apk_file()

            #定义签名后apk的存储路径
            tmp_apk_file = os.path.join( app_path, "tmp.apk" )
            self._sign( orig_apk_file, tmp_apk_file, item[ "sign_file" ], item[ "passwd" ], item[ "alias" ] )

            dest_apk_filename = self._get_app_name( item[ "name" ])

            #对齐后的apk文件，apps/dhh-XXXX.apk(终极apk)
            dest_apk_file = os.path.join( app_path, dest_apk_filename)
            self._zipalign( tmp_apk_file, dest_apk_file )

            os.remove( tmp_apk_file )
            os.chdir( os.path.dirname( dest_apk_file ) )
        os.chdir( current_path )
        #self._clean_env()


def release(channel_id, config):
    APK(channel_id, config).pack()


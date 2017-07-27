#!/usr/bin/env python
#-*- coding: utf-8 -*-
import os
import shutil
import codecs
import utils
from xml.dom import minidom

# import plistlib
try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET

CUR_PATH = os.path.abspath( os.path.dirname( __file__ ) )
PRJ_PATH = os.path.abspath( os.path.join( CUR_PATH, "..", "..", ".." ) )


def replace_packagename( filename, src_packagename, dist_packagename ):
    with open( filename, "r" ) as file:
        data = file.read()

    data = data.replace( src_packagename, dist_packagename )
    
    with open( filename, "w" ) as file:
        file.write( data )



def packagename2path( src_path, packagename ):
    return os.path.join( src_path, *packagename.split(".") ) 


def rename_packagename( src_path, src_packagename, dist_packagename ):
    old_path = packagename2path( src_path, src_packagename )
    if not os.path.exists( old_path ):
        return
    new_path = packagename2path( src_path, dist_packagename )
    shutil.move( old_path, new_path )


def get_packagename( project_path ):
    filename = os.path.join( project_path, "AndroidManifest.xml" )
    tree = ET.ElementTree( file = filename )
    return tree.getroot().attrib[ "package" ]


def replace_applicationname( project_path, applicationname ):
    filename = os.path.join( project_path, "res", "values", "strings.xml" )
    tree = ET.ElementTree( file = filename )
    root = tree.getroot()
    name = None
    for elem in root.iterfind('string[@name="app_name"]'):
        name = elem.text

    with codecs.open( filename, "r", "utf-8" ) as fd:
        data = fd.read()
    data = data.replace( name, applicationname )
    with codecs.open( filename, "w", "utf-8" ) as fd:
        fd.write( data )


def change_packagename( project_path, dist_packagename, app_name = None ):
    src_path = os.path.join( project_path, "src" ) 
    
    # rename app name
    if app_name != None:
        replace_applicationname( project_path, app_name )

    # rename package
    src_packagename = get_packagename( project_path )
    if src_packagename == dist_packagename:
        return

    rename_packagename( src_path, src_packagename, dist_packagename )
    files  = utils.getFiles( src_path, ".java" )
    files.append( os.path.join( project_path, "AndroidManifest.xml" ) )
    for f in files:
        replace_packagename( f, src_packagename, dist_packagename )


def changeAndroidManifest(project_path , config):
    filename = os.path.join( project_path, "AndroidManifest.xml" )
    doc = minidom.parse(filename)
    root = doc.documentElement

    versionCode = "1"
    versionName = "1.0.0"

    if config.has_key("app_version"):
        versionName = config[ "app_version" ]

    if config.has_key("version_code"):
        versionCode = config[ "version_code" ]

    root.setAttribute('android:versionCode', versionCode)
    root.setAttribute('android:versionName', versionName)

    f = file(filename, "w")
    writer = codecs.lookup('utf-8')[3](f)
    doc.writexml(writer, newl='', indent='\n', encoding='utf-8')
    writer.close()
    f.close()

    
class PackageMgr( object ):

    def __init__( self, channel_id, config ):
        self._channel_id    = channel_id
        self._config        = config
    
        self._app_id        = self._config[ "app_id" ]
        self._app_name      = self._config[ "app_name" ]

        self._proj_path     = os.path.join( PRJ_PATH, self._config[ "project_name" ] ) 

    def config_package( self ):
        pass


# class IOSPackageMgr( PackageMgr ):

#     def _get_resource_path( self, proj_path ):
#         for f in os.listdir( proj_path ):
#             file_path = os.path.join( proj_path, f )  
#             resource_path = os.path.join( file_path, "Resources" )
#             if  os.path.exists( file_path ) and         \
#                 os.path.isdir( file_path ) and          \
#                 os.path.exists( resource_path ) and     \
#                 os.path.isdir( resource_path ):
#                 return resource_path


#     def config_package( self ):
#         resource_path = self._get_resource_path( self._proj_path )
#         info_plist = os.path.join( resource_path, "Info.plist" )
#         info_config = plistlib.readPlist( info_plist )
#         info_config[ "CFBundleDisplayName" ] = self._app_name 
#         info_config[ "CFBundleIdentifier" ]  = self._app_id 
#         plistlib.writePlist( info_config, info_plist )


class AndroidPackageMgr( PackageMgr ):
    
    def config_package( self ):
        change_packagename( self._proj_path, str( self._app_id ), self._app_name )
        changeAndroidManifest( self._proj_path, self._config )
    

def config_package( channel_id, config):
    if config[ "platform" ] == "android":
        AndroidPackageMgr( channel_id, config ).config_package()

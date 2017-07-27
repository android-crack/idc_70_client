#!/usr/bin/env python
#-*- coding: utf-8 -*-
import os
import stat
import shutil
import zipfile
try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET


FILE_MODE = stat.S_IRUSR | stat.S_IWUSR | stat.S_IRGRP | stat.S_IROTH

def execute( cmd ):
	try:
		os.system( cmd )
	except:
		print( "execute %s error!" % cmd )

def getFiles( path, fileType=None, filters = [ ".svn", ".git" ]):
	files = []
	path = os.path.abspath( path )
	if not os.path.exists( path ):
		return files 
	for f in os.listdir( path ):
		if f in filters:
			continue
		f = os.path.join( path, f )
		if os.path.isdir( f ):
			files.extend( getFiles ( f, fileType, filters ) )
		elif os.path.isfile( f ):
			if fileType:
				if f.endswith( fileType ):
					files.append( f )
			else:
				files.append( f )

	return files

def chmod( fileName, mode=FILE_MODE ):
	if os.path.isfile( fileName ):
		os.chmod( fileName, mode )
		return
	
	for root, dirs, files in os.walk( fileName ):
		for f in files:
			f = os.path.join( root, f )
			os.chmod( f, mode )

def removeFile( fileName ):
	fileName = os.path.abspath( fileName )
	if not os.path.exists( fileName ):
		print("File: %s is not existed" % fileName )
		return

	chmod( fileName )
	if os.path.isfile( fileName ):
		os.remove( fileName )
	elif os.path.isdir( fileName ):
		print fileName
		shutil.rmtree( fileName )
	else:
		print("removeFile error: %s" % filePath)

def copyFile( srcFile, destFile, ignores = [".svn", ".git", ".get_date.dat", "Thumbs.db"] ):
	srcFile = os.path.abspath( srcFile )
	destFile = os.path.abspath( destFile )
	if not os.path.exists( srcFile ):
		return
    
	if not os.path.exists( os.path.dirname( destFile) ):
		os.makedirs( os.path.dirname( destFile ) )

	if os.path.exists( destFile ):
		removeFile( destFile )
	
	if os.path.isfile( srcFile ):
		shutil.copyfile( srcFile, destFile )
	elif os.path.isdir( srcFile ):
		ignores = shutil.ignore_patterns( *ignores) 
		shutil.copytree( srcFile, destFile, ignore = ignores  )

	chmod( destFile )


def copyDir( srcDir, destDir, ignores = [".svn", ".git", ".get_date.dat", "Thumbs.db"] ):
    for f in getFiles( srcDir, None, ignores ):
        copyFile( f, f.replace( srcDir, destDir ) )


def zip( filename, src_path ):
    with zipfile.ZipFile( filename, 'w', zipfile.ZIP_DEFLATED ) as zip:
        pDir = os.path.dirname( src_path )
        for root, dirs, files in os.walk( src_path ):
            for file in files:
                absDir = os.path.join(root, file)
                relativeDir = absDir.replace(pDir, "")
                zip.write( absDir, relativeDir )


def get_tmp_path( src_path ):
    tmp = 1000 
    while True:
        tmp_path = os.path.join( src_path, "%s" % tmp )
        if not os.path.exists( tmp_path ):
            break
        tmp = tmp + 1
    return tmp_path


class SVNCommands( object ):
    
    @classmethod
    def export( cls, url, dest_dir ):
        execute( "svn export %s %s" % (url, dest_dir ) )
    

    @classmethod
    def checkout( cls, url, dest_dir ):
        execute( "svn co %s %s" % (url, dest_dir ) )


def get_android_version_code( xmlPath ):
    tree = ET.ElementTree( file = xmlPath )
    xmlns = "http://schemas.android.com/apk/res/android"
    attName = "{%s}versionCode" % (xmlns)
    versionCode = tree.getroot().attrib[ attName ]
    return versionCode


def showAndGetMenus(menus, prompt=None):
    prompt = prompt or "please choose one item:"
    while True:
        print prompt
        for k, v in enumerate(menus):
            print "%s. %s" % (k + 1, v)
        
        index = raw_input(">>")
        try:
            index = int(index)
        except ValueError:
            pass

        if index in range(1, len(menus) + 1):
            return menus[index - 1]
    return None


if __name__ == "__main__":
	pass

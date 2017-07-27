#!/usr/bin/env python
#-*- coding:utf-8 -*-
import os
import sys
import utils

CUR_PATH	= os.path.abspath( os.path.dirname( __file__ ) )


def compileProject( prjPath, toPath):
    curWorkPath = os.getcwd()
    os.chdir( prjPath )

    key = "dhh"
    exclude_files = [
        "data.composite_effect_debug",
        #"module.net.rpc_lua_table"
    ]
    scripts = "/compile_scripts.bat"
    if sys.platform == "darwin":
        scripts = "compile_scripts.sh" 

    cmds = [
        "%s/compile_scripts/%s" % (CUR_PATH, scripts),
        "-i %s" % prjPath,
        "-o %s" % toPath,
        "-x %s" % ",".join(exclude_files),
        "-m files",
        "-e xxtea_chunk",
        "-ek %s" % key
    ]
    os.system(" ".join(cmds))

    framework = os.path.join(CUR_PATH, "compile_impl", "framework_precompiled.zip")
    utils.copyFile(framework, os.path.join(toPath, "gameobj", "framework_precompiled.zip"))
    #pto_file = os.path.join("module", "net", "rpc_lua_table.lua")
    #utils.copyFile(pto_file, os.path.join(toPath, "module", "net", "rpc_lua_table.lua"))
    os.chdir( curWorkPath )
    return True


def main():
	prjPath = os.path.join( CUR_PATH, ".." )
	compileProject( os.path.join( prjPath, "scripts" ), os.path.join( prjPath, "new" ) ) 

if __name__ == "__main__":
	main()

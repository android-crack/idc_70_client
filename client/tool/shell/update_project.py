#!/usr/bin/env python
import os
import sys
import getopt
import utils
import string

CUR_DIR = os.path.abspath(os.path.dirname(__file__))
PRJ_DIR = os.path.abspath(os.path.join(CUR_DIR, "..", ".."))

def getAllExistsLibs(libDir):
    menifest = os.path.abspath(os.path.join(libDir, "AndroidManifest.xml"))
    libs = []
    if os.path.exists(menifest):
        return [libDir]

    dirs = [os.path.join(libDir, d) for d in os.listdir(libDir)]
    dirs = [d for d in dirs if os.path.isdir(d)]
    for d in dirs:
        libs.extend(getAllExistsLibs(d))

    return libs


def findProjectAndroidLibs(projDir):
    prop = os.path.abspath(os.path.join(projDir, "project.properties")) 
    libs = []

    if not os.path.exists(prop):
        return libs

    with open(prop, "r") as fd:
        curLibs = [os.path.abspath(os.path.join(projDir, line.split("=")[1].strip())) for line in fd.readlines() if line.startswith("android.library.reference")]

    libs.extend(curLibs) 
    for lib in curLibs:
        libs.extend(findProjectAndroidLibs(lib))
    return libs


def getAllAndroidProjects(projDir):
    return [d for d in os.listdir(projDir) if d.endswith(".android")]


def getAllAndroidSDKTargets():
    utils.execute("android list target > target_list.log") 
    with open("target_list.log", "r") as fd:
        return [line.strip() for line in fd.readlines() if line.startswith("id:")]
    utils.removeFile("target_list.log")


def getTargetIdFromString(targetS):
    return int(targetS.split(" ")[1])


def updateProject(proj, target):
    projs = [proj]
    projs.extend(findProjectAndroidLibs(proj))
    
    def update(p):
        srcPath = os.path.join(p, "src")
        if not os.path.exists(srcPath):
            os.makedirs(srcPath) 

        utils.execute("android update project -p %s -t %d" % (os.path.join(p), target))

    map(update, projs)


def main():
    opts, args = getopt.getopt(sys.argv[1:], "ar")
    isAll = False
    for op, value in opts:
        if op == "-a":
            isAll = True

    projs = getAllAndroidProjects(PRJ_DIR)
    targets = getAllAndroidSDKTargets()
    target = utils.showAndGetMenus(targets)

    if not isAll:
        proj = os.path.join(PRJ_DIR, utils.showAndGetMenus(projs))
        updateProject(proj, getTargetIdFromString(target))
    else:
        for proj in projs:
            updateProject(os.path.join(PRJ_DIR, proj), getTargetIdFromString(target))


if __name__ == "__main__":
    main()

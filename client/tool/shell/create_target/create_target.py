#coding=utf-8
import sys
import os
# tools_path = os.getenv("QTZ_PY_SHELL")
# 当前的路径
CUR_PATH = os.path.abspath(os.path.dirname(__file__))
tools_path = CUR_PATH + "/trunk/client/tool/shell/"
sys.path.append(tools_path)

import module.common as common

# 用于统一打包的流程，减少人手的使用

# 当前的路径
CUR_PATH = os.path.abspath(os.path.dirname(__file__))
if os.path.isfile(CUR_PATH):
    CUR_PATH = os.path.dirname(CUR_PATH)
BRANCH_BACKUPS_PATH = os.path.join(CUR_PATH, "branch_backups")
TARGET_PATH = os.path.join(CUR_PATH, "target")

# 打印中文
def printCn(print_str):
    print(print_str.encode(sys.getfilesystemencoding()))
    
def printDirFile(path_str):
    dirs = common.GetDirs(path_str)
    for dir in dirs:
        printCn(dir)
        
def createDir(path_str):
    if os.path.exists(path_str):
        return
    os.makdirs(path_str)
        
def SafeExec(cmd_str):
    printCn(cmd_str)
    common.SafeExec(cmd_str)

#创建软链接
def createSoftLink():
    printCn(u"----------------------   软链接设置开始   -----------------------------")
    printCn(u"branch_backups里的分支有：")
    printDirFile(BRANCH_BACKUPS_PATH)
    printCn(u"请输入你要创建的软链接的分支：")
    branch_name = raw_input()
    branch_path = BRANCH_BACKUPS_PATH + "/" + branch_name
    if False == os.path.exists(branch_path):
        printCn("branch_backups里不存在分支：%s"%branch_name)
        return 0
    cmd_str = u"ln -s -i %s %s"
    printCn(u"正在软链接的client目录...")
    SafeExec(cmd_str%(branch_path + "/client", TARGET_PATH))
    printCn(u"正在软链接的gameplay3d目录...")
    SafeExec(cmd_str%(branch_path + "/gameplay3d", TARGET_PATH))
    printCn(u"----------------------   软链接设置结束   -----------------------------\n")
    return 1

if __name__ == '__main__':
    printCn(u"工具库路径：%s"%tools_path)
    createSoftLink()
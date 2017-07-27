#coding=utf-8
import sys
import os
CUR_PATH = os.path.abspath(os.path.dirname(__file__))
tools_path = CUR_PATH + "/trunk/client/tool/shell/"
sys.path.append(tools_path)
sys.path.append("../")

import module.config as config


CUR_PATH = os.path.abspath(os.path.dirname(__file__))
    
BRANCH_PATHS = [
    config.SVN_ROOT_PATH + "/backup/client/release_%s",
    "https://192.168.0.3/qtz/mg01/res/release_%s",
    "https://192.168.0.3/qtz/mg01/config/config_release_%s/out_lua/data/battles",
    "https://192.168.0.3/qtz/mg01/config/config_release_%s/out_lua/data/battle_ai",
    # "https://192.168.0.3/qtz/mg01/backup/engine/release_%s",
]

def DeleteFile(file_str):
    os.remove(file_str)
    
def WriteFile(file_str, content_str):
    f = file(file_str, "w")
    f.write(content_str)
    f.close()

# 无返回值
def SafeExec(cmd, JustShow = False):
    if JustShow:
        print cmd
        return 0
    status = os.system(cmd)
    print(cmd)
    status >>= 8
    assert status == 0, u"system execute '%s' return %d" % ( cmd, status )
    return status

def printCn(print_str):
    print(print_str.encode(sys.getfilesystemencoding()))

def SvnCheckOut( url, path, is_ignore_externals_b = False ):
    print "svn checkout " + url + "---------->" + path
    cmd = ""
    if is_ignore_externals_b:
        cmd = "svn co --ignore-externals %s %s" %( url, path)
    else:
        cmd = "svn co %s %s" %( url, path)
    ret = SafeExec(cmd)
    return ret
    
def getWindowPath(path_str):
    if len(path_str) > 10: #兼容装了cygdrive的客户端
        if path_str[0:10] == "/cygdrive/":
            true_path = path_str[10] + ":"
            true_path += path_str[11:]
            return true_path
    return path_str
    
if __name__ == '__main__':
    printCn(u"请输入你要checkout分支的本地路径：（如：f:/books/www/qqqq, 假如装了cygwin写：/cygdrive/f/books/www/qqqq）")
    path_str = raw_input()
    if os.path.exists(path_str):
        if os.path.isfile(path_str):
            printCn(u"%s 是文件，并不是路径！！！！！"%path_str)
            exit(0)
    else:
        os.makedirs(path_str)
    printCn(u"请输入你要checkout的版本（如2011_11_11）:")
    version_str = raw_input()
    message_str = "/release_%s/client/" %(version_str)
    out_path_str = path_str + message_str
    if os.path.exists(out_path_str):
        printCn(u"分支目录已存在： %s"%out_path_str)
        exit(0)
    branch_url = BRANCH_PATHS[0]% version_str
    SvnCheckOut( branch_url, out_path_str, True)
    
    #开始指定外链
    #一个命令的直接打
    cmd_str = '''cd /d %s && svn propset svn:externals %s resource/%s'''
    item_format = "%s %s"
    cmd_path_str = '''"%s"'''%(item_format % (BRANCH_PATHS[1]%version_str, "res"))
    res_cmd_str = cmd_str % (getWindowPath(out_path_str), cmd_path_str, "")
    SafeExec(res_cmd_str)
    
    # 两条的需要借助临时一个文件来同时对一个目录设置多个属性
    temp_file_name = "externals_temp.txt"
    temp_file_path = getWindowPath(out_path_str) + "externals_temp.txt"
    path_str = item_format % (BRANCH_PATHS[2]%version_str, "battles") + "\n" + item_format % (BRANCH_PATHS[3]%version_str, "battle_ai")
    WriteFile(temp_file_path, path_str.encode(sys.getfilesystemencoding()))
    res_cmd_str = cmd_str % (getWindowPath(out_path_str), "-F %s"%temp_file_name, "scripts/game_config")
    SafeExec(res_cmd_str.encode(sys.getfilesystemencoding()))
    DeleteFile(temp_file_path)
    
    SvnCheckOut( branch_url, out_path_str)
    printCn(u"成功checkout分支！！！！！！！！！！")
CONFIG_SCREEN_WIDTH  = 960
CONFIG_SCREEN_HEIGHT = 540
CONFIG_SCREEN_AUTOSCALE = "SHOW_ALL"

CCLuaLoadChunksFromZip("scripts/base/framework_precompiled.zip")
require("framework.init")
require("lfs")


function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: "..tostring(errorMessage).."\n")
    local trackback = debug.traceback("", 2)
    print(trackback)
    print("----------------------------------------")
end 


local function initLanguage()
    local utils = require("update/utils")
    local default_language_key = utils.getDefaultLanguageName()
    local user_default = CCUserDefault:sharedUserDefault()
    user_default:setStringForKey("language_key", default_language_key)
    user_default:flush()
end

local function initResPathConfig()
    local docpath = CCFileUtils:sharedFileUtils():getWritablePath()
    local destFile = docpath
    if device.platform == "ios" then
        ok, ret = luaoc.callStaticMethod("QPathUtils", "addSkipBackupAttributeToItemAtPath", {filepath = destFile})
    end
    package.path = "scripts/?.lua"..package.path
    local spath_list = 
    {
        "%sdhh.game.qtz.com/?.lua",
        "%sdhh.game.qtz.com/scripts/?.lua",
    }
    for _, v in ipairs(spath_list) do
        local spath = string.format(v,docpath)
        package.path = spath..";"..package.path
    end

    local search_paths = 
    {
        "dhh.game.qtz.com/",
        "dhh.game.qtz.com/res/",
    }
    for _, v in ipairs(search_paths) do
        CCFileUtils:sharedFileUtils():addSearchPath( docpath..v )
    end
    CCFileUtils:sharedFileUtils():addSearchPath( "res/" )
	
	-- 3d
	FileSystem.addSearchPath( docpath.."dhh.game.qtz.com/" )
	FileSystem.addSearchPath( docpath.."dhh.game.qtz.com/res/" )
	FileSystem.addSearchPath( "res/" )
end


local function startScene()
	initResPathConfig()
	initLanguage()
	local scene = require("update/startScene").new()
	CCDirector:sharedDirector():runWithScene(scene)
end

-- 开场动画
local function opAnimation()
	local res = GTab.OPEN_ANIMATION_RES	
	if res ~= nil and res ~= "" then 
		if device.platform == "ios" or device.platform == "android" then 
			return playVideo(res, startScene)
		end
	end 
	startScene()
end

local function initVersion()
	local user_data = CCUserDefault:sharedUserDefault()
	local cur_app_version = user_data:getStringForKey("appVersion", "")
	
	-- userDefault 格式出错，整个文件删除
	if cur_app_version == "" then
		local path = CCUserDefault:getXMLFilePath()
		os.remove(path)
		user_data = CCUserDefault:sharedUserDefault()
	end 
	
	--不同版本覆盖安装问题
	if GTab.APP_VERSION ~= cur_app_version then 
		removeDir( GTab.UPDATE_RES_PATH )
		user_data:setStringForKey("appVersion", GTab.APP_VERSION)	
		user_data:setStringForKey("version", GTab.VERSION_PACK)
	end 
	
	local version = user_data:getStringForKey("version", "")
	GTab.VERSION_UPDATE = version 
end  

xpcall(function()
	require("root/baseGlobal")
	require("root/baseFunctions")
	require("root/http")
	initVersion()
	
	-- hotfix 
	require("root/hotfix"):start(opAnimation)
	
end, __G__TRACKBACK__)

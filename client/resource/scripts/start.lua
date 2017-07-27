math.randomseed(os.time())
math.random(100)
math.random(100)
require("language")
require("scripts/errorhandle")

-- avoid memory leak
--collectgarbage("setpause", 80)
--collectgarbage("setstepmul", 150)
--collectgarbage("setpause", 150)
--collectgarbage("setstepmul", 200)

require("base/gc")
gc.enable_gc_manager()

UIWidget.onExit = function()
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ onExit")
	print("这里onExit 用法有问题，请找对应的程序修改")
	local trackback = debug.traceback("", 2)
    print(trackback)
	print("@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@")
end
 
-- for CCLuaEngine
function __G__TRACKBACK__(errorMessage)
	print("----------------------------------------")
    print("LUA ERROR: "..tostring(errorMessage).."\n")
	local trackback = debug.traceback("", 2)
    print(trackback)
    print("----------------------------------------")
	sendErrorToServer(errorMessage, trackback)
end

local startGame = function() 
	updateVersonInfo(LOG_1002)
	local module_start_game = require("module/login/startGame") 
	module_start_game.startGame()
end

xpcall(function()
	require("init")

	local version_layer = require("gameobj/versionInfoLayer").new()
	GameUtil.getNotification():addChild(version_layer)

	local userDefault = CCUserDefault:sharedUserDefault()
	local noEffect = userDefault:getBoolForKey("noEffect")
	local noMusic = userDefault:getBoolForKey("noMusic")
	local noVedio = userDefault:getBoolForKey("noVedio")
	if DEBUG > 0 then
		CCDirector:sharedDirector():setDisplayStats(true)
	else
		CCDirector:sharedDirector():setDisplayStats(false)
	end

	LoadPlist({
        ["ui/common_ui.plist"] = 1,
        ["ui/txt_common.plist"] = 1,
    })
    
	audioExt.setMusicEnabled((not noMusic))
	audioExt.setEffectEnabled((not noEffect))

 	
	updateVersonInfo(LOG_1001)
	if noVedio then
		startGame()
		return
	end

	audioExt.stopMusic()
	if device.platform == "ios" then 
		playVideo("res/movie/movie.mp4", function()	
			startGame()
		end)
	
	elseif device.platform == "android" then
		playVideo("res/movie/movie.mp4", function()
			startGame()
		end)
	else
		startGame()
	end
	CCUserDefault:sharedUserDefault():setBoolForKey("noVedio", true )
	CCUserDefault:sharedUserDefault():flush()

end, __G__TRACKBACK__)

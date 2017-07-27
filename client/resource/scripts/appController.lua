-- 脚本层 appController 

local AppController = {}

-- 进入后台
function AppController.applicationDidEnterBackground()
	audioExt.pauseMusic()
	audioExt.pauseAllEffects()

	--只对移台平台起效果
	if device.platform ~="ios" and device.platform ~="android" then
		-- return
	end

	local notifiction = require("ui/tools/clsNotificationMgr")
	notifiction.pushAllNotifications()

	-- local ModuleLoginBase = require("module/login/loginBase")
	-- ModuleLoginBase.logOutEnterBackground()
end 

-- 后台回来
function AppController.applicationWillEnterForeground()
	audioExt.resumeMusic()
	audioExt.resumeAllEffects()


	local notifiction = require("ui/tools/clsNotificationMgr")
	notifiction.removeAllNotifications()
	
	--只对移台平台起效果
	if device.platform ~="ios" and device.platform ~="android" then
		
		-- return
	end

	require("gameobj/tips/clsPostCardTips")
	resetPostCard()
	-- local ModuleLoginBase = require("module/login/loginBase")
	-- ModuleLoginBase.relinkEnterForeground()
end 


CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, AppController.applicationDidEnterBackground, "APP_ENTER_BACKGROUND")
CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(nil, AppController.applicationWillEnterForeground, "APP_ENTER_FOREGROUND")
-- 游戏中打开各连接统一管理

local OpenURLMgr = {}

-- 打开评论app界面
function OpenURLMgr:openAppEvaluateUrl()
	if device.platform == "ios" then 
		local url = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1176484857"
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.openURL(url)
	end 
end 

-- 打开官网
function OpenURLMgr:openWebsiteUrl()
	local url = "http://qmdhh.qq.com/"
	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.openURL(url) 
end 

return OpenURLMgr
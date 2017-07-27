-- 游戏一启动的场景

require("module/font_util")
require("language_base")

local ClsStarttScene = class( "ClsStarttScene", function() return CCScene:create() end )

function ClsStarttScene:ctor()
	self:registerScriptHandler(function(event)
        if event == "enter" then
            self:onEnter()
        elseif event == "exit" then
            self:onExit()
        end
    end)
end 

-- 跳过更新，用本地配置文件（内部开发用）
function ClsStarttScene:skipUpdate()
	local function callback()
		local res = "updateInfo.json"
		local data = loadJsonFromFile(res)
		require("update/updateInfo"):loadInfoFile(data)
		if device.platform == "ios" or device.platform == "android" then
			require("update/updateInfo"):reloadUpdateInfoFromLocal()
		end
		require("start")
	end 
	require("framework.scheduler").performWithDelayGlobal(callback, 0.5)
end 

function ClsStarttScene:showLogo()
	self.logo_res = "update/qtz_logo.png"
	self.logo = display.newSprite(self.logo_res, display.cx, display.cy)
	local scale = display.width / self.logo:getContentSize().width
	self.logo:setScale(scale)
	self:addChild(self.logo)

	local function callback()
		self:initUI()
	end
	require("framework.scheduler").performWithDelayGlobal(callback, 1)
end

function ClsStarttScene:initUI()
	self.logo:removeFromParentAndCleanup(true)

	self.login_bg_res = "update/login_bg.jpg"
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGB565)
    self.login_bg = display.newSprite(self.login_bg_res, display.cx, display.cy)
	self:addChild(self.login_bg)
	local scale = display.width/self.login_bg:getContentSize().width
	self.login_bg:setScale(scale)
	CCTexture2D:setDefaultAlphaPixelFormat(kCCTexture2DPixelFormat_RGBA8888)

	local ClsUpdateAlert = require("update/updateAlert")
	ClsUpdateAlert:showStopSvrNoticeInfo(function( ... )
		self:initStart()
	end)	
end

function ClsStarttScene:initStart()	
	-- 跳过更新
	if GTab.SKIP_UPDATE then 
		self:skipUpdate()
	else 
		self:startUpdate()
	end 
end

-- 开始更新
function ClsStarttScene:startUpdate()
	local layer = require("update/updateUI").new()
	self:addChild(layer, 10)
end 

function ClsStarttScene:onEnter()
	local utils = require("update/utils")
    utils.makeOutSideEdge("update/screen_edge.jpg")

    self:showLogo()
end 

function ClsStarttScene:onExit()
	CCTextureCache:sharedTextureCache():removeTextureForKey(self.logo_res)
	CCTextureCache:sharedTextureCache():removeTextureForKey(self.login_bg_res)

	-- 更新模块，所有require过的逻辑都要清掉
	package.loaded["module/font_util"] = nil
	package.loaded["game_config/font_config"] = nil
	package.loaded["scripts/base/ui/tools"] = nil
	package.loaded["language_base"] = nil
	package.loaded["language"] = nil
	package.loaded["errorhandle"] = nil
end 


return ClsStarttScene
-- login layer

local UI_WORD = require("game_config/ui_word")
local userDefault = CCUserDefault:sharedUserDefault()
local CompositeEffect = require("gameobj/composite_effect")
local ModuleDataHandle = require("module/dataManager")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsLoginServerUI = class("ClsLoginServerUI", ClsBaseView)

ClsLoginServerUI.getViewConfig = function(self, ...)
	return {
		type =  UI_TYPE.DIALOG,   
	}
end

ClsLoginServerUI.onEnter = function(self)
	audioExt.stopMusic()
	audioExt.stopAllEffects()
	self:mkNormalUI()
end


ClsLoginServerUI.touchServerBtnCB = function(self, index, selectList)
	for i,v in ipairs(self.server_btn_list) do
		v:setSelected(false)
	end
	self.server_btn_list[index]:setSelected(true)

	local tag= index
	if self.severTag ==tag then return end
	self.severTag =tag

	if selectList[self.severTag] ~= nil then
		-- local start_and_login_data = getGameData():getStartAndLoginData()
		-- start_and_login_data:setLoginIpPort( selectList[self.severTag])

		userDefault:setStringForKey(STR_SERVER_NAME, selectList[self.severTag].name)
		userDefault:setIntegerForKey(STR_SERVER, self.severTag)
		userDefault:flush()
	end
end

--创建平台无台的控件：背景，选服，防沉迷。。。。
ClsLoginServerUI.mkNormalUI = function(self)
	--背景相关
	local bg = CCNode:create()
	bg:setContentSize(CCSize(display.width,display.height))
	self:addChild(bg)

	--背景特效
	self.bgEffect = CompositeEffect.new("tx_0035", display.cx, display.cy, bg)
	self.bgEffect:setScale(1)
	self.bgEffect:runAction(CCScaleTo:create(4, 0.8))


	--服务器选择
	local selectList = GTab.SERVER_LIST

	local server_count = 0 

	-- 服务器选项的行数
	local row = 12
	self.server_btn_list = {}
	for k, v in ipairs(selectList) do
		
	   local button_config = {image = "#common_btn_orange3.png",
						imageSelected="#common_btn_orange4.png",
						x = 50 + 130 * (math.floor((k - 1) / row)),
						y = display.height - ((k - 1) % row + 1) * 40,
						text = v.name, 
						fontFile = FONT_COMMON, 
						fsize = 14, 
						scale = 0.65--, 
		}

		self.server_btn_list[k] = self:createButton(button_config)
		self:addChild(self.server_btn_list[k])
		self.server_btn_list[k]:regCallBack(function (index)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.clearAutoLoginInfo()
			self:touchServerBtnCB(k, selectList)

		end)
		server_count = server_count + 1
	end

	self.sure_btn = self:createButton({image = "#common_btn_orange3.png",
						imageSelected="#common_btn_orange4.png",
						x = display.cx,
						y = display.cy,
						text = UI_WORD.LOGIN_ENTER_SERVER_TIPS, 
						fontFile = FONT_COMMON, 
						fsize = 16, 

		})
	self:addChild(self.sure_btn)

	self.sure_btn:regCallBack(function()
			self:setViewTouchEnabled(false)
			require("gameobj/login/LoginScene").startLoginScene()
		end)

	local serverId=userDefault:getIntegerForKey(STR_SERVER)
	serverId = tonumber(serverId)
	serverId = math.min(serverId, server_count)
	serverId = math.max(serverId, 1)
	
	self:touchServerBtnCB(serverId, selectList)
	if server_count <= 1 then
		for i,v in ipairs(self.server_btn_list) do
			v:setVisible(false)
		end
	else
		for i,v in ipairs(self.server_btn_list) do
			v:setVisible(true)
		end
	end



	self.logo = display.newSprite("ui/txt/txt_login_logo.png", 481, 410)
	self:addChild(self.logo)


	--healthy playing tips
	self.healthy_title = createBMFont({text = UI_WORD.SEP_HEALTHY_TITLE, fontFile = FONT_TITLE, size = 16, align = ui.TEXT_ALIGN_CENTER,
		x = display.width / 2 + 5, y = 140})
	self:addChild(self.healthy_title)


	for i=1,4 do
		self["healthy_tips"..i] = createBMFont({text = UI_WORD["SEP_HEALTHY_TIPS_"..i], fontFile = FONT_TITLE, size = 16,
			x = display.width / 2 + 5, y = 112 - (i - 1)*20})
		local healthy_tips = self["healthy_tips"..i] 
		self:addChild(healthy_tips)        
	end

end

ClsLoginServerUI.onExit = function(self)
	ReleaseTexture(self)
end

ClsLoginServerUI.onFinish = function(self, ...)
	if not tolua.isnull(self.bgEffect) then
		self.bgEffect:removeTexture()
	end
end

return ClsLoginServerUI

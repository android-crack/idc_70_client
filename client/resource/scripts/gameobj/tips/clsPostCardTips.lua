--
-- Author: Ltian
-- Date: 2017-01-10 15:35:36
--

local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local module_game_sdk = require("module/sdk/gameSdk")
local ClsPostCardTips = class("ClsPostCardTips", function () return UILayer:create() end)


ClsPostCardTips.ctor = function(self, port_id)
	self.plistTab = {
		["ui/postcard.plist"] = 1,
	}
	LoadPlist(self.plistTab)
	self.login_platform = module_game_sdk.getPlatform() --登录类型
	self.port_id = port_id or 15
	self:mkUI()
	self:regEvent()
	self:registerScriptHandler(function(event)
		if event == "exit" then self:onExit() end
	end)
	self:setExploreRun(false)
end

ClsPostCardTips.setExploreRun = function(self, enable)
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		if not enable then
			explore_layer:getShipsLayer():setStopShipReason("ClsPostCardTips")
			explore_layer:getShipsLayer():setStopFoodReason("ClsPostCardTips")
		else
			explore_layer:getShipsLayer():releaseStopShipReason("ClsPostCardTips")
			explore_layer:getShipsLayer():releaseStopFoodReason("ClsPostCardTips")
		end
		
	end
end

local widget_name = {
	"btn_close",
	"btn_wechat",
	"btn_friend",
	"btn_wechat_text",
	"port_introduce_text",
	"player_name",
	"coordinates_num",
	"bg_panel",
	"btn_friend_text",
	"city_text"
}

ClsPostCardTips.mkUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/postcard.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	local port_info = ClsDataTools:getPort(self.port_id)
	local port_type = port_info.portType
	local fix_x = port_info.flipX
	local port_set = ClsDataTools:getPortSet(port_type)
	
	--背景
	
	self.bg = display.newSprite(port_set.res, display.cx, display.cy)
	self.bg_panel:addCCNode(self.bg)

	--得到缩放的比例
	self.bg_scale = CONFIG_SCREEN_WIDTH/self.bg:getContentSize().width
	self.bg:setScale(self.bg_scale)

	if fix_x == 1 then
		self.bg:setFlipX(true)
	end

	--描述
	self.port_introduce_text:setText(port_info.port_des)

	-- 港口名
	self.city_text:setText(port_info.name)

	--坐标
	self.coordinates_num:setText(port_info.name .."  ".. port_info.coordinates)
	
	--名字
	local str_name = string.format(ui_word.FROM_PLAYER_NAME, getGameData():getPlayerData():getName())
	self.player_name:setText(str_name)

	--朋友圈文本
	local CRICLE_text = ui_word.SHUOSHUO
	if self.login_platform == PLATFORM_WEIXIN then
		CRICLE_text = ui_word.FRIEND_CRICLE
	end
	self.btn_wechat_text:setText(CRICLE_text)


end

ClsPostCardTips.btnVisable = function(self, enable)
	self.btn_close:setVisible(enable)
	self.btn_wechat:setVisible(enable)
	self.btn_friend:setVisible(enable)
	self.btn_friend_text:setVisible(enable)
	self.btn_wechat_text:setVisible(enable)

	self.btn_close:setTouchEnabled(enable)
	self.btn_wechat:setTouchEnabled(enable)
	self.btn_friend:setTouchEnabled(enable)

end

ClsPostCardTips.regEvent = function(self)
	self:setTouchPriority(TOUCH_PRIORITY_RPCWAIT + 9)
	local touch_layer = display.newLayer()
	self:addChild(touch_layer)
	touch_layer:registerScriptTouchHandler(function(event, x, y)
		
		return true
	end, false, TOUCH_PRIORITY_RPCWAIT + 10, true)
	touch_layer:setTouchEnabled(true)
	--关闭
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		self:removeFromParentAndCleanup(true)
	end, TOUCH_EVENT_ENDED)

	-- 朋友圈
	self.btn_wechat:setPressedActionEnabled(true)
	self.btn_wechat:addEventListener(function()
		self:btnVisable(false)
		self:share(SHARE_SCENE_ZONE)
	end, TOUCH_EVENT_ENDED)

	--好友
	self.btn_friend:setPressedActionEnabled(true)
	self.btn_friend:addEventListener(function()
		self:btnVisable(false)
		self:share(SHARE_SCENE_SESSION)
	end, TOUCH_EVENT_ENDED)
end

ClsPostCardTips.share = function(self, scene)
	local rect = CCRect(0, 0, display.width, display.height)
	-- iOS retina resolution 2048x1536
	local version = "1.7.10"
	if compareTwoVersion(GTab.APP_VERSION, version) < 0 then
		if display.widthInPixels >= 2048 and display.heightInPixels >= 1536 and device.platform == "ios" then
			local scaleFactor = 1536 / 540
			local module_game_sdk = require("module/sdk/gameSdk")
			local platform = module_game_sdk.getPlatform()
			if platform == PLATFORM_QQ then
				rect = CCRect(30 / scaleFactor, 360 / scaleFactor, 2000 / scaleFactor, 980 / scaleFactor)
			elseif platform == PLATFORM_WEIXIN then
				rect = CCRect(0, 0, 2048 / scaleFactor, 1536 / scaleFactor)
			end
		end
	end

	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.05), CCCallFunc:create(function()
		local share_data = getGameData():getShareData()
		local cur_share_port_id = self.port_id
		share_data:shareImg(scene, "", rect, function(share_result)
			if share_result then
				share_data:askPortShareSucc(cur_share_port_id)
				if not tolua.isnull(self) then
					self:removeFromParentAndCleanup(true)
				end
				return
			end
			if tolua.isnull(self) then return end
			self:btnVisable(true)
		end)
	end)))
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(4), CCCallFunc:create(function ( )
		self:btnVisable(true)
	end)))
	
end

ClsPostCardTips.onExit = function(self)
	UnLoadPlist(self.plistTab)
	self:setExploreRun(true)
end


local post_card = nil
createPostCard = function(port_id)
	post_card = ClsPostCardTips.new(port_id)
	post_card:setZOrder(TOPEST_ZORDER + 100)

	local running_scene = GameUtil.getRunningScene()
	running_scene:addChild(post_card)
end

resetPostCard = function()
	if not tolua.isnull(post_card) then
		post_card:btnVisable(true)
	end
end

closePostCard = function()
	if not tolua.isnull(post_card) then
		post_card:removeFromParentAndCleanup(true)
	end
end

return ClsPostCardTips

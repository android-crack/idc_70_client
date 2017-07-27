--
-- Author: Ltian
-- Date: 2016-12-23 16:11:11
--
local ClsBaseView = require("ui/view/clsBaseView")
local ui_word = require("game_config/ui_word")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")

local ClsCommunityUI = class("ClsCommunityUI", ClsBaseView)

function ClsCommunityUI:getViewConfig()
    return {
       
        type = UI_TYPE.TIPS,    
        effect = UI_EFFECT.SCALE,  
    }
end

function ClsCommunityUI:onEnter(pos_x)
	self.plistTab = {
		["ui/port_main.plist"] = 1,
	}
	LoadPlist(self.plistTab)	
	self.pos_x = pos_x
	self:mkUI()
	ClsGuideMgr:tryGuide("ClsCommunityUI")
end

local widget_name = {
	"btn_paper",
	"btn_horde",
	"hidden_panel",
	"effect_layer",
	"btn_horde_text",
	"btn_service",
	"btn_website",
	"btn_strategy",
}
local default_touch_rect = CCRect(494, 387, 228, 82)
function ClsCommunityUI:mkUI()
	local music_info=require("game_config/music_info")
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_port_community.json")
	self:setPosition(ccp(display.cx, display.cy))
	--self:setAnchorPoint(ccp(1, 1))
	local default_view_x = 240
	local default_view_y = 196
	local touch_rect = default_touch_rect
	self.m_view_root_spr:setPosition(ccp(default_view_x, default_view_y))
	if self.pos_x then
		self.m_view_root_spr:setPosition(ccp(self.pos_x, default_view_y))
		touch_rect = CCRect(default_touch_rect.origin.x + (self.pos_x - default_view_x), default_touch_rect.origin.y, default_touch_rect.size.width, default_touch_rect.size.height)
	end
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.hidden_panel:setPosition(ccp(1, 1))
	self:regTouchEvent(self, function(eventType, x, y)	
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		print(x, y, is_in)
		if is_in then return end
		self:close()
	end)

	self.btn_paper:setPressedActionEnabled(true)
	self.btn_paper:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
 		getUIManager():create("gameobj/question/clsQuestionUI")
	end, TOUCH_EVENT_ENDED)

	self.btn_horde:setPressedActionEnabled(true)
	self.btn_horde:addEventListener(function()
		print("------btn_horde---------")
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local module_game_sdk = require("module/sdk/gameSdk")
	    local platform = module_game_sdk.getPlatform()
	    if platform == PLATFORM_QQ then
	    	module_game_sdk.openURL("https://buluo.qq.com/p/barindex.html?bid=356512&from=share_copylink")
	    elseif platform == PLATFORM_WEIXIN then
	    	module_game_sdk.openURL("https://game.weixin.qq.com/cgi-bin/h5/static/circle/index.html?jsapi=1&appid=wxa228fbbb06c2cb79&auth_type=2&ssid=12")
	    end
	end, TOUCH_EVENT_ENDED)

	self.btn_service:setPressedActionEnabled(true)
	self.btn_service:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local module_game_sdk = require("module/sdk/gameSdk")
	    module_game_sdk.openSystemSetService()
	end, TOUCH_EVENT_ENDED)

	self.btn_website:setPressedActionEnabled(true)
	self.btn_website:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local openURLMgr = require("gameobj/openURLMgr")
		openURLMgr:openWebsiteUrl()
	end, TOUCH_EVENT_ENDED)
    
	self.btn_strategy:setPressedActionEnabled(true)
	self.btn_strategy:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local on_off_info = require("game_config/on_off_info")
		getGameData():getMissionData():tryBtnClickComplete(on_off_info.STRATEGY_BUTTON.value)
		getUIManager():create("gameobj/strategy/clsStrategyUI")
	end, TOUCH_EVENT_ENDED)
	
	--问卷按钮是否能显示
	local question_data = getGameData():getQuestionPaperData()
	local url = question_data:getUrl()
	local composite_effect = require("gameobj/composite_effect")
	self.gaf = composite_effect.new("tx_wenjuan_liuguang", 0, 0, self.effect_layer, -1, nil, nil, nil, true)
	if not url or true then --or true是暂时屏蔽
		self.btn_paper:setVisible(false)
		self.btn_paper:setTouchEnabled(false)
	end
	
	local module_game_sdk = require("module/sdk/gameSdk")
    local platform = module_game_sdk.getPlatform()
    if platform == PLATFORM_QQ then
    	self.btn_horde:setVisible(true)
    elseif platform == PLATFORM_WEIXIN then
    	self.btn_horde:setVisible(true)
    	self.btn_horde:changeTexture("main_icon_circle.png", "main_icon_circle.png","main_icon_circle.png", UI_TEX_TYPE_PLIST)
    	self.btn_horde_text:setText(ui_word.PLAY_CRICLE)
    else
    	--self.btn_horde:setVisible(true)
    end
end

function ClsCommunityUI:onExit()
	UnLoadPlist(self.plistTab)	
end

return ClsCommunityUI
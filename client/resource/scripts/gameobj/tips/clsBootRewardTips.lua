--
-- Author: Ltian
-- Date: 2017-01-04 16:52:37
--
--
-- Author: Ltian
-- Date: 2017-01-04 14:32:22
--

local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

local ClsBootRewardTips = class("ClsBootRewardTips", ClsBaseView)

function ClsBootRewardTips:getViewConfig()
    return {
        name = "ClsBootRewardTips",
        type = UI_TYPE.TIPS,   
        effect = UI_EFFECT.SCALE, 
        is_back_bg = true,
    }
end

function ClsBootRewardTips:onEnter(funs)
	self.plistTab = {
       
        ["ui/game_center.plist"] = 1,
    }
   
    LoadPlist(self.plistTab)
	self:mkUI()
	self:initEvent()
end

local widget_name = {
	"title_text",
	"left_icon",
	"btn_close",
	"tips_text"
}
local touch_rect = CCRect(display.cx - 290, display.cy - 170, 580, 340)
function ClsBootRewardTips:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_start.json")
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	local module_game_sdk = require("module/sdk/gameSdk")
    local platform = module_game_sdk.getPlatform()
    if platform == PLATFORM_QQ then
    	self.title_text:setText(ui_word.STR_BOOT_QQ)
    	self.left_icon:changeTexture("game_center_qq.png", UI_TEX_TYPE_PLIST)
    	self.tips_text:setVisible(false)
    elseif platform == PLATFORM_WEIXIN then
    	
    else
    	self:close()
    end
end

function ClsBootRewardTips:initEvent()
	self:regTouchEvent(self, function(eventType, x, y)	
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if is_in then return end
		self:close()
	end)
	self.btn_close:setTouchEnabled(true)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self:close()
	end, TOUCH_EVENT_ENDED)
end

function ClsBootRewardTips:onExit()
	UnLoadPlist(self.plistTab)
end



return ClsBootRewardTips
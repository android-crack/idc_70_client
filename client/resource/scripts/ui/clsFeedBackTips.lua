--
-- Author: Ltian
-- Date: 2016-12-30 17:52:40
--
local music_info=require("scripts/game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

local ClsFeedBackTips = class("ClsFeedBackTips", ClsBaseView)

function ClsFeedBackTips:getViewConfig()
    return {
        name = "ClsFeedBackTips",
        type = UI_TYPE.TIPS,   
        effect = UI_EFFECT.SCALE, 
    }
end

function ClsFeedBackTips:onEnter()
	self:mkUI()
end

local widget_name = {
	"btn_close",
	"btn_confirm",
	"btn_cancel",
	"text_1",
	"text_2",
	"text_3"
}
local touch_rect = CCRect(display.cx - 210, display.cy - 130, 420, 260)
function ClsFeedBackTips:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_common.json")
	self.panel:setPosition(ccp(display.cx - 210, display.cy - 130))
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:regTouchEvent(self, function(eventType, x, y)	
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if is_in then return end
		self:close()
	end)
	
	
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.btn_cancel:setPressedActionEnabled(true)
	self.btn_cancel:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()
	end, TOUCH_EVENT_ENDED)


	self.btn_confirm:setPressedActionEnabled(true)
	self.btn_confirm:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:FeedBack()
		
	end, TOUCH_EVENT_ENDED)
	self.text_1:setVisible(false)
	self.text_2:setVisible(false)
	self.text_3:setVisible(true)
	self:updateEditBox()

end

function ClsFeedBackTips:updateEditBox( )
    local frame = display.newSpriteFrame("guild_9_20.png")
    local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
    edit_box = CCEditBox:create(CCSize(356, 125), sprite)
    edit_box:setPosition(480, 305)
    edit_box:setPlaceholderFont("ui/font/title.fnt", 14)
    edit_box:setFont("ui/font/title.fnt", 14)
    edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_GRASS)))
    edit_box:setFontColor(ccc3(dexToColor3B(COLOR_WHITE)))
    edit_box:setInputFlag(kEditBoxInputFlagSensitive)
    edit_box:setAnchorPoint(ccp(0.5, 0.5))
   
    self.text_3:setText(ui_word.CHAT_PLEASE_INPUT_CONTENT_WORLD)
    edit_box:setMaxLength(200) 
    edit_box:registerScriptEditBoxHandler(function(eventType, data)
        if eventType == "ended" then
            local text = edit_box:getText()
            self.text = text
            self.text_3:setText(text)
            edit_box:setText("")
        elseif eventType == "began" then
        	self.text_3:setText("")
        	edit_box:setText(self.text)
        end
       
    end)
    self.edit_box = edit_box
    self:addChild(edit_box, 1)
end

function ClsFeedBackTips:FeedBack()
	if self.text and self.text ~= "" then
		getGameData():getPlayerData():setFeedBackTime()
		local module_game_sdk = require("module/sdk/gameSdk")
		module_game_sdk.feedback(self.text)
		Alert:warning({msg = ui_word.FEED_BACK_OK, size = 26})
		self:close()
	else
		Alert:warning({msg = ui_word.PLEASE_INPUT_MSG, size = 26})
	end
	
end

function ClsFeedBackTips:onTouchChange(enable)
	if not tolua.isnull(self.edit_box) then
		self.edit_box:setTouchEnabled(enable)
	end
end

function ClsFeedBackTips:onExit()
end

return ClsFeedBackTips
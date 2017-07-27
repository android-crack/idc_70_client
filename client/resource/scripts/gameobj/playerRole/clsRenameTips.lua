--
-- Author: Ltian
-- Date: 2017-01-09 15:35:07
--
--
local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsCommonFuns = require("scripts/gameobj/commonFuns")
local news = require("game_config/news")
local ClsRenameTips = class("ClsRenameTips", ClsBaseView)

local COST_DIAMOUND_NUM = 300

ClsRenameTips.getViewConfig = function(self)
	return {
		type = UI_TYPE.VIEW,   
		effect = UI_EFFECT.SCALE, 
		is_back_bg =  true,
	}
end

ClsRenameTips.onEnter = function(self)
	self.is_share_to_friend = 1
	self:mkUI()
end

local widget_name = {
	"btn_close",
	"btn_middle",
	"btn_check",
	"coin_num",
}
local touch_rect = CCRect(display.cx - 210, display.cy - 130, 420, 260)
ClsRenameTips.mkUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_rename.json")
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
	
	--关闭
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		self:close()
	end, TOUCH_EVENT_ENDED)

	--确定
	self.btn_middle:setPressedActionEnabled(true)
	self.btn_middle:addEventListener(function ()
		self:changeName()
		
	end, TOUCH_EVENT_ENDED)

	--复选框
	self.btn_check:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.is_share_to_friend = 1
	end, CHECKBOX_STATE_EVENT_SELECTED)

	self.btn_check:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.is_share_to_friend = 0
	end, CHECKBOX_STATE_EVENT_UNSELECTED)
	self.btn_check:setSelectedState(true)
	self:updateEditBox()
	self:updateDiamoundLab()

	RegTrigger(GOLD_UPDATE_EVENT, function()
		if tolua.isnull(self) then return end
		self:updateDiamoundLab()
	end)

end

ClsRenameTips.updateDiamoundLab = function(self)
	local gold_count = getGameData():getPlayerData():getGold()
	if gold_count < COST_DIAMOUND_NUM then
		self.coin_num:setColor(ccc3(dexToColor3B(COLOR_RED)))
	else
		self.coin_num:setColor(ccc3(dexToColor3B(COLOR_GREEN)))
	end
end

ClsRenameTips.updateEditBox = function(self)
	local frame = display.newSpriteFrame("common_9_grey.png")
	local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
	edit_box = CCEditBox:create(CCSize(200, 48), sprite)
	edit_box:setPosition(480, 305)
	edit_box:setPlaceholderFont("ui/font/title.fnt", 16)
	edit_box:setFont("ui/font/title.fnt", 16)
	edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_ARENA_UNSELECTED)))
	edit_box:setFontColor(ccc3(dexToColor3B(COLOR_ARENA_UNSELECTED)))
	edit_box:setInputFlag(kEditBoxInputFlagSensitive)
	edit_box:setAnchorPoint(ccp(0.5, 0.5))
	edit_box:setText(ui_word.PLEASE_INPUT_NAME)
	self.edit_box = edit_box
	edit_box:setMaxLength(200) 
	edit_box:registerScriptEditBoxHandler(function(eventType, data)
		if eventType == "ended" then
			local is_ok, name_str = self:checkInputText(true)
			self.edit_box:setText(name_str)
			self.name = name_str
			
		elseif eventType == "began" then
			if not self.name then
				self.edit_box:setText("")
			end
		end
	end)
	
	self:addChild(edit_box, 1)
end

ClsRenameTips.changeName = function(self)
	if self.name == "" or not self.name then
		Alert:warning({msg = ui_word.RENAME_NO_TIPS})
		return
	end
	local gold_count = getGameData():getPlayerData():getGold()
	if gold_count < COST_DIAMOUND_NUM then
		Alert:showJumpWindow(DIAMOND_NOT_ENOUGH)
		return
	end
	local is_ok, name_str = self:checkInputText(true, self.name)
	if not is_ok then return end
	Alert:showAttention(ui_word.SURE_CHANGE_NAME, function()
				getGameData():getPlayerData():changeName(self.name, self.is_share_to_friend)
			end)
	self:close()
end

ClsRenameTips.checkInputText = function(self, is_trip, name)
	local text = name or self.edit_box:getText()
	if text == "" then
		text = self.edit_box:getPlaceHolder()
	elseif is_trip then
		text = string.gsub(text, "%s", "")--去掉空格字符
	end
	text = ClsCommonFuns:returnUTF_8CharValid(text)
	local has = check_string_has_invisible_char(text)
	if has then
		Alert:warning({msg = ui_word.INPUT_ILLEGAL, color = ccc3(dexToColor3B(COLOR_RED))})
		return false, text
	end
		
	local len_n = ClsCommonFuns:utfstrlen(text)
	if len_n < 2 then
		Alert:warning({msg = news.LOGIN_IPUT_NAME.msg})
		return false, text
	elseif len_n > 7.5 then
		Alert:warning({msg = news.ROLE_NAME_LONG.msg})
		return false, text
	elseif not checkNameTextValid(text) or not checkChatTextValid(text) then
		return false, text
	end
	return true, text
end

ClsRenameTips.onTouchChange = function(self, enable)
	if not tolua.isnull(self.edit_box) then
		self.edit_box:setTouchEnabled(enable)
	end
end

ClsRenameTips.onExit = function(self)
	UnRegTrigger(GOLD_UPDATE_EVENT)
end

return ClsRenameTips
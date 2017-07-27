--聊天主界面中各个面板的基类
local Alert = require("ui/tools/alert")
local testTools = require("gameobj/testTools")
local music_info = require("game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsScrollView = require("ui/view/clsScrollView")
local common_funs = require("gameobj/commonFuns")
local ClsChatBase = require("gameobj/chat/clsChatBase")

local MAX_TXT_LENGTH = 26

local ClsChatScrollView = class("ClsChatScrollView", ClsScrollView)
function ClsChatScrollView:updateLayerMove()
	if not self.m_drag then return end
	if self.m_drag.is_tap then return end
	if type(self.move_call) == "function" then
		self.move_call(self.m_drag)
	end
	if not self.m_is_vertical then
		self.m_inner_layer:setPosition(ccp(self.m_drag.end_x - self.m_drag.start_x + self.m_drag.start_layer_x, self.m_drag.start_layer_y))
	else
		self.m_inner_layer:setPosition(ccp(self.m_drag.start_layer_x, self.m_drag.end_y - self.m_drag.start_y + self.m_drag.start_layer_y))
	end
	self:openUpdateTimer()
end

function ClsChatScrollView:setMoveCall(call)
	if type(call) == "function" then
		self.move_call = call
	end
end

local ClsChatPanelBase = class("ClsChatPanelBase", function() return UIWidget:create() end)
function ClsChatPanelBase:ctor(parameter)
	self.channel = parameter.channel
	self.data_kind = parameter.data
	self.list_height = parameter.list_height

	local path = string.format("json/%s", parameter.json_res)
	self.panel = GUIReader:shareReader():widgetFromJsonFile(path)
	self:addChild(self.panel)
end

function ClsChatPanelBase:initEvent()
	local btn_chat = getConvertChildByName(self.panel, "btn_chat")
	--录音
	local chat_data = getGameData():getChatData()
	self.btn_record:addEventListener(function()
		chat_data:stopRecord()
	end, TOUCH_EVENT_ENDED)

	--录音
	self.btn_record:addEventListener(function() 
		chat_data:recordMessage(self.channel)
	end, TOUCH_EVENT_BEGAN)

	--录音
	self.btn_record:addEventListener(function() 
		chat_data:cancelRecord()
	end, TOUCH_EVENT_CANCELED)
end

function ClsChatPanelBase:createEditBox()
	if not tolua.isnull(self.edit_box) then 
		self.edit_box_copy_str = nil
		return 
	end
	local sprite = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("common_9_block3.png"))
	self.edit_box = CCEditBox:create(CCSize(380, 40), sprite)
	self.edit_box:setPosition(290, 495)
	self.edit_box:setFont(font_tab[FONT_COMMON], 20)
	self.edit_box:setFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.edit_box:setInputFlag(kEditBoxInputFlagSensitive)

	self.edit_box:setPlaceHolder(ui_word.CHAT_PLEASE_INPUT_CONTENT_WORLD)
	self.edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self:addCCNode(self.edit_box)
	local component_ui = getUIManager():get("ClsChatComponent")
	self.edit_box:setTouchPriority(component_ui:getTouchPriority() - 2)
	self.edit_box:registerScriptEditBoxHandler(function(eventType, target)
		if eventType == "ended" then
			local txt = target:getText()
			local start_index, _, _ = string.find(txt, "#")
			if start_index ~= 1 then
				local commonBase  = require("gameobj/commonFuns")
				local len = commonBase:utfstrlen(txt)
				if len > MAX_TXT_LENGTH then
					Alert:warning({msg = ui_word.CHAT_INPUT_NUM_MORE_THAN_MAX, color = ccc3(dexToColor3B(COLOR_RED))})
					txt = common_funs:utf8sub(txt, 1, MAX_TXT_LENGTH)
				end
			else
				cclog("默认是巫师指令")
			end

			txt = replaceValidText(txt)
			target:setText(txt)

			if testTools:parseMessage(txt) then return end
			
			self:sendMessageFunc()
		end
	end)

	local chat_date = getGameData():getChatData()
	local msg = chat_date:getNotSendMsg()
	if self.edit_box_copy_str then
		self.edit_box:setText(self.edit_box_copy_str)
	elseif msg then
		self.edit_box:setText(msg)
	end
	self.edit_box_copy_str = nil
end

function ClsChatPanelBase:getEidtBox()
	return self.edit_box
end

function ClsChatPanelBase:setEidtBoxStr(copy_str)
	if tolua.isnull(self.edit_box) then
		self.edit_box_copy_str = copy_str
		return
	end
	self.edit_box_copy_str = nil
	self.edit_box:setText(copy_str)
end

function ClsChatPanelBase:removeEditBox()
	if not tolua.isnull(self.edit_box) then
		self.edit_box:removeFromParentAndCleanup(true)
		self.edit_box_copy_str = nil
		self.edit_box = nil
	end
end

function ClsChatPanelBase:cleanEidtBox()
	if not tolua.isnull(self.edit_box) then
		self.edit_box:setText("")
	end
end

function ClsChatPanelBase:sendMessageFunc()
	local chat_data = getGameData():getChatData()
	local msg = self.edit_box:getText()

	msg = string.gsub(msg, "%$", "")
	if msg == nil or msg == "" then
		Alert:warning({msg = ui_word.PLEASE_INPUT_MSG, color = ccc3(dexToColor3B(COLOR_RED)), x = display.cx - 200})
		return
	end

	local commonBase  = require("gameobj/commonFuns")
	msg = commonBase:returnUTF_8CharValid(msg)

	local has = check_string_has_invisible_char(msg)
	if has or commonBase:checkAllCharacterIsNul(msg) then
		Alert:warning({msg = ui_word.INPUT_ILLEGAL, color = ccc3(dexToColor3B(COLOR_RED))})
		return
	end

	chat_data:setNotSendMsg(msg)

	chat_data:askRpc(msg, self.channel)
end

function ClsChatPanelBase:createList(kind, chat_content)
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	local chat_data = getGameData():getChatData()

	--传数据进来我就用，没有我就根据类型自己去找
	local content = nil
	if not chat_content then
		if not kind then cclog("数据类型不能为空") end
		content = chat_data:getList(kind)
	else
		content = chat_content
	end

	if not content or #content < 1 then cclog("聊天信息数据为空") return end

	local list_width = 355
	local list_height = self.list_height or 395
	local cell_size = CCSize(355, 90)
	self.list_view = ClsChatScrollView.new(list_width, list_height, true, function()

	end, {is_fit_bottom = true})

	self.cells = {}
	for k = #content, 1, -1 do
		local cell_class = self:getBubbleType(content[k])
		local cell = cell_class.new(cell_size, content[k])
		self.cells[#self.cells + 1] = cell
	end

	self.list_view:addCells(self.cells)
	self.list_view:setPosition(ccp(112, 25))
	self:addChild(self.list_view)
end

--添加一般cell的方式，具体模块根据需要自己定制
function ClsChatPanelBase:addCell(msg)
	if not tolua.isnull(self.list_view) then
		local cell_class = self:getBubbleType(msg)
		local cell = cell_class.new(CCSize(355, 85), msg)
		self.list_view:addCellByIndex(cell, 1)
		self.list_view:scrollToCellIndex(1)
	else
		self:createList(self.data_kind)
	end
end

function ClsChatPanelBase:getListView()
	return self.list_view
end

function ClsChatPanelBase:setBtnEnable(target, enable)
	if tolua.isnull(target) then return end
	target.img:removeFromParent()
	target:setPressedActionEnabled(enable)
	if not enable then
		target.img = CCGraySprite:createWithSpriteFrameName(target.res)
	else
		target.img = display.newSprite(string.format("#%s", target.res))
	end
	target.img:setPositionY(11)
	target:addCCNode(target.img)
end

function ClsChatPanelBase:getBubbleType(msg)
	local playerData = getGameData():getPlayerData()
	if msg.sender == playerData:getUid() then
		return require("gameobj/chat/clsMyChatBubble")
	elseif msg.sender == GAME_SYSTEM_ID then 
		return require("gameobj/chat/clsSystemListCell")
	else
		return require("gameobj/chat/clsOtherChatBubble")
	end
end

return ClsChatPanelBase
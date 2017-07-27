--聊天信息绿字事件
local ui_word = require("game_config/ui_word")
local touch_event_for_chat_message = require("gameobj/chat/touchEventForChatMessage")
local RichlabelElementCallbackMsg = class("RichlabelElementCallbackMsg", function(param)
	return display.newSprite()
end)

local EVENT_TYPE = 1--事件类型的index

function RichlabelElementCallbackMsg:ctor(param)
	self.text = param.text
	self.params = param.params
	self.type = param.type
	self.key = param.key
	self.font = param.font or FONT_CFG_1
	self.font_size = param.size or 14
	self.color = param.color
	self.touch_callback = nil
	self.show_lab = param.label_node
	self.m_richlabel = param.richlabel
	self:init()
end

function RichlabelElementCallbackMsg:init()
	if nil == self.show_lab then
		local label = createBMFont({text = self.text, size = self.font_size, fontFile = self.font, color = ccc3(dexToColor3B(self.color))})
		self.show_lab = label
	end

	local label_size = self.show_lab:getContentSize()
	local x = label_size.width / 2
	local y = label_size.height / 2
	local item = require("ui/view/clsViewButton").new({labelNode = self.show_lab, x = x, y = y + self.show_lab:getStrokeSize() / 2})
	item.last_time = 0
	item:regCallBack(function()
		if CCTime:getmillistimeofCocos2d() - item.last_time < 500 then return end
		item.last_time = CCTime:getmillistimeofCocos2d()
		if not self:filter() then return end

		local is_tab, kind = self:judgeParaIsTab(self.key)
		if is_tab then
			local para = self:getJsonParameter(self.key)
			touch_event_for_chat_message.touchEvent[kind](json.decode(para))
		else
			local para = json.decode(self.key)
			local event_type = para[EVENT_TYPE]
			local temp = {}
			for k, v in ipairs(para) do
				if k ~= EVENT_TYPE then
					table.insert(temp, v)
				end
			end
			touch_event_for_chat_message.touchEvent[event_type](unpack(temp))
		end
	end)
	self:addChild(item)
	
	self.m_richlabel:regTouchEvent(item, function(...) return item:onTouch(...) end)
end

local tips_tab = {
	["baowuTips"] = true,
	["boatBaowuTips"] = true,
	["boatTips"] = true,
	["itemTips"] = true,
	["sailorTips"] = true,
}

-- parameter = ["WORLD_TEAM_INVITATION","%d","%d"]

function RichlabelElementCallbackMsg:judgeParaIsTab(parameter)
	local _, _, match = string.find(parameter, "%[(.-),")
	if tips_tab[match] then
		return true, match
	end
	return false
end

function RichlabelElementCallbackMsg:getJsonParameter(parameter)
	local _, _, match = string.find(parameter, ",(%{.+)%]")
	return match
end

function RichlabelElementCallbackMsg:filter()
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	local Alert = require("ui/tools/alert")
	if auto_trade_data:getIsAutoTrade() then--自动经商中无法进行跳转操作
		Alert:warning({msg = ui_word.APPOINT_TRADE_NOT_TOUCH_MSG})
		return
	end
	
	local prizon_ui = getUIManager():get("ClsPrizonUI")
	if not tolua.isnull(prizon_ui) then
		Alert:warning({msg = ui_word.NOT_DO})
		return
	end

	local far_arena_view = getUIManager():get("clsFarArenaInfo")
	if not tolua.isnull(far_arena_view) then
		Alert:warning({msg = ui_word.NOT_DO})
		return
	end

	local missionDataHandler = getGameData():getMissionData()
    local is_auto_status = missionDataHandler:getAutoPortRewardStatus()
    if is_auto_status then
    	Alert:warning({msg = ui_word.NOT_DO})
		return
    end
    
	return true
end

function RichlabelElementCallbackMsg:getContentSize()
	return self.show_lab:getContentSize()
end

function RichlabelElementCallbackMsg:getText()
	return self.text
end

function RichlabelElementCallbackMsg:getTextColor()
	return self.color
end

function RichlabelElementCallbackMsg:setTextColor(new_color)
	if new_color and self.show_lab then
		local parseString = require("ui/tools/richlabel/parse_string")
		new_color = parseString.getColorNum(new_color)
		self.color = new_color
		self.show_lab:setColor(ccc3(dexToColor3B(new_color)))
	end
end
	
return RichlabelElementCallbackMsg
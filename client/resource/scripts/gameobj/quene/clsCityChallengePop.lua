local ClsBaseView = require("ui/view/clsBaseView")
local ClsCityChallengePop = class("ClsCityChallengePop", ClsBaseView)
local ui_word = require("scripts/game_config/ui_word")
local alert = require("ui/tools/alert")
local port_info = require("game_config/port/port_info")
local error_info =require("game_config/error_info")
local on_off_info = require("game_config/on_off_info")

local widget_name = {
	"btn_close",
	"btn_1",
	"btn_2",
	"item_pic",
	"text_2",
	"item_amount",
	"btn_3",
	"btn_1_text",
	"btn_2_text",
	"text",
	"city_pic",
	"bar_bg",
	"bar_text",
	"bar_pic",
	"btn_3_text",
}

local PANEL_INFO_TBL = {
	["challenge"] = {
		desc = ui_word.STR_CITY_CHALLENGE_FIGHT,
		hide_widget = {"item_pic", "item_amount", "text"},
		show_widget = {"bar_bg"},
		btn_1_func = function()
			getGameData():getCityChallengeData():askFight()
		end,
		btn_2_func = function()
			if getGameData():getGuildInfoData():hasGuild() then
				local onOffData = getGameData():getOnOffData()
				if not onOffData:isOpen(on_off_info.ORGANIZETEAM.value) then
					alert:warning({msg = error_info[619].message})
					return
				end

				if getGameData():getTeamData():isTeamFull() then
					alert:warning({msg = ui_word.STR_CITY_CHALLENGE_GUILD})
				else
					getGameData():getCityChallengeData():askGuildChat()
				end
			else
				local ERROR_ID = 119
				alert:warning({msg = error_info[ERROR_ID].message})
			end
		end,
		not_close_panel = true,
		pic = "ui/seaman/seaman_25.png",
	},
	["transmit"] = {
		desc = ui_word.STR_CITY_CHALLENGE_TRANSMIT,
		btn_1_text = ui_word.STR_CITY_CHALLENGE_BTN_1, 
		btn_2_text = ui_word.STR_CITY_CHALLENGE_BTN_2,
		btn_1_func = function()
			getGameData():getCityChallengeData():toTargetPort()
		end,
		btn_2_func = function()
			local is_enough, cost = getGameData():getTeamData():checkCostIsEnough()
			if is_enough then
				getUIManager():close("ClsCityChallengePop")
				getGameData():getCityChallengeData():askToTargetPort()
			else
				alert:showJumpWindow(DIAMOND_NOT_ENOUGH, nil, {need_cash = cost, come_type = alert:getOpenShopType().VIEW_3D_TYPE})
			end
		end,	
		not_close_panel = true,	
		pic = "ui/seaman/seaman_55.png",
	},
	["next_accept"] = {
		desc = ui_word.STR_CITY_CHALLENGE_ACCEPT,
		hide_widget = {"item_pic", "item_amount", "text"},
		btn_1_text = ui_word.STR_CITY_CHALLENGE_BTN_3, 
		btn_2_text = ui_word.STR_CITY_CHALLENGE_BTN_4,		
		btn_1_func = function()
			getGameData():getCityChallengeData():askCityTask()
		end,
		pic = "ui/seaman/seaman_55.png",
	},
	["final_close"] = {
		desc = ui_word.STR_CITY_CHALLENGE_FINAL,
		hide_widget = {"item_pic", "item_amount", "btn_1", "btn_2", "text"},
		show_widget = {"btn_3"},
		pic = "ui/seaman/seaman_55.png",
		is_time_close = true,
	},
	["exchange"] = {
		desc = ui_word.STR_CITY_CHALLENGE_EXCHANGE,
		btn_3_text = ui_word.STR_CITY_CHALLENGE_BTN_5,
		btn_3_func = function()
			getGameData():getCityChallengeData():askChangeTask()
		end,
		hide_widget = {"item_pic", "item_amount", "btn_1", "btn_2", "text"},
		show_widget = {"btn_3"},
		pic = "ui/seaman/seaman_25.png",
	},
}

function ClsCityChallengePop:getViewConfig()
	return {
		name = "ClsCityChallengePop",
		is_swallow = true,
		is_back_bg = true,
	}
end

function ClsCityChallengePop:onEnter(params)
	self.mission = params.data
	self.panel_type = params.panel_type
	self.call_back = params.call_back
	self:mkUI()
	self:initEvent()
	self:autoCloseView()
end

function ClsCityChallengePop:autoCloseView()
	if PANEL_INFO_TBL[self.panel_type].is_time_close then
		local close_array = CCArray:create()
		close_array:addObject(CCDelayTime:create(3)) 
		close_array:addObject(CCCallFunc:create(function ()
			self:closeUI()
		end))
		self:runAction(CCSequence:create(close_array))
	end
end

function ClsCityChallengePop:initPanelByType()
	local panel_info = PANEL_INFO_TBL[self.panel_type]
	local desc = panel_info.desc
	if self.panel_type == "transmit" then
		desc = string.format(panel_info.desc, port_info[self.mission.port_id].name)

		local is_enough, cost = getGameData():getTeamData():checkCostIsEnough()
		local res_id = '#common_item_feather.png'
		local DIAMOND_COST = 5
		if is_enough then
			if cost > 1 then
				res_id = '#common_icon_diamond.png'
			else
				local user_own = getGameData():getPropDataHandler():get_propItem_by_id(233) or {count = 0}
				cost = string.format("%s/%s", user_own.count, cost)
			end
		else
			res_id = '#common_icon_diamond.png'
			cost = DIAMOND_COST
		end
		self.item_pic:changeTexture(convertResources(res_id), UI_TEX_TYPE_PLIST)
		self.item_amount:setText(cost)
	end

	if self.panel_type == "challenge" then
		desc = string.format(desc, getGameData():getPlayerData():getName())

		local cur_progress, max_progress = self.mission.missionProgress[1]['value'], self.mission.complete_sum[1]
		self.bar_pic:setPercent(cur_progress / max_progress * 100)
		self.bar_text:setText(string.format("%s/%s", cur_progress, max_progress))
	end
	self.text_2:setText(desc)
	self.city_pic:changeTexture(panel_info.pic, UI_TEX_TYPE_LOCAL)
	if panel_info.btn_1_text and panel_info.btn_2_text then
		self.btn_1_text:setText(panel_info.btn_1_text)
		self.btn_2_text:setText(panel_info.btn_2_text)
	end
	if panel_info.btn_3_text then
		self.btn_3_text:setText(panel_info.btn_3_text)
	end
	for _, name in ipairs(panel_info.hide_widget or {}) do
		if not tolua.isnull(self[name]) then
			self[name]:setVisible(false)
		end
	end
	for _, name in ipairs(panel_info.show_widget or {}) do
		if not tolua.isnull(self[name]) then
			self[name]:setVisible(true)
		end
	end
end

function ClsCityChallengePop:mkUI()
	local json_ui = GUIReader:shareReader():widgetFromJsonFile("json/tips_city_challenge.json")
	self:addWidget(json_ui)
	for k,name in ipairs(widget_name) do
		self[name] = getConvertChildByName(json_ui, name)
	end
	self:initPanelByType()
end

function ClsCityChallengePop:initEvent()
	local panel_info = PANEL_INFO_TBL[self.panel_type]

	self.btn_1:setPressedActionEnabled(true)
	self.btn_1:addEventListener(function()
		self:closeUI()
		if type(panel_info.btn_1_func) == "function" then 
			panel_info.btn_1_func()
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_2:setPressedActionEnabled(true)
	self.btn_2:addEventListener(function()
		if not panel_info.not_close_panel then
			self:closeUI()
		end
		if type(panel_info.btn_2_func) == "function" then 
			panel_info.btn_2_func()
		end
	end, TOUCH_EVENT_ENDED)

	self.btn_3:setPressedActionEnabled(true)
	self.btn_3:addEventListener(function()
		self:closeUI()
		if type(panel_info.btn_3_func) == "function" then 
			panel_info.btn_3_func()
		end
	end, TOUCH_EVENT_ENDED)	

	self.btn_close:addEventListener(function()
		self:closeUI()
	end, TOUCH_EVENT_ENDED)
end

function ClsCityChallengePop:closeUI()
	self:close()
end

function ClsCityChallengePop:onExit()
	if type(self.call_back) == "function" then
		self.call_back()
	end
end

return ClsCityChallengePop
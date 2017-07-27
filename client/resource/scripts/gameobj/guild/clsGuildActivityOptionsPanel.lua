--
-- 商会活动三个选项
--

local ClsBaseView 					= require("ui/view/clsBaseView")
local music_info 					= require("scripts/game_config/music_info")
local error_info 					= require("game_config/error_info")
local ClsAlert 						= require("ui/tools/alert")
local on_off_info 					= require("game_config/on_off_info")
local ClsGuildActivityOptionsPanel 	= class("ClsGuildActivityOptionsPanel", ClsBaseView)

local JSON_URL 						= "json/guild_hall_activity.json"

ClsGuildActivityOptionsPanel.getViewConfig = function(self)
	return {
		is_swallow = false,
		is_back_bg = false,
		effect = 0,
	}
end

ClsGuildActivityOptionsPanel.onEnter = function(self)
	self["btn_boss"] 		= nil 
	self["btn_portfight"] 	= nil 
	self["btn_war"] 		= nil 
	self["open_panel"] 		= nil 
	self["touch_btn"] 		= false

	self:initUI()
end

ClsGuildActivityOptionsPanel.initUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile( JSON_URL )
	self:addWidget(panel)
	panel:setPosition(ccp(100, -175))
	self:setPosition(ccp(display.cx, display.cy))

	local btn_info = {
		["btn_boss"] = self.btnBossClick, 
		["btn_portfight"] = self.btnPortFlightClick, 
		["btn_war"] = self.btnWarClick
	}
	for name, func in pairs(btn_info) do
		self[name] = getConvertChildByName(panel, name)
		self[name]:setPressedActionEnabled(true)
		self[name]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			func(self)
			self:close()
		end, TOUCH_EVENT_ENDED)
	end

	local task_data = getGameData():getTaskData()
	local task_keys = {on_off_info.GRADUATE_BUILD_BUILDBUTTON.value, on_off_info.GUILD_ACTIVITY_PORTFIGHT_ENROLL.value}
	task_data:regTask(self.btn_portfight, task_keys, KIND_CIRCLE, on_off_info.GUILD_ACTIVITY_PORTFIGHT.value, nil, nil, true)
end

ClsGuildActivityOptionsPanel.btnBossClick = function(self)
	if getGameData():getGuildInfoData():getGuildGrade() < 10 then 
		ClsAlert:warning({msg = error_info[873].message})
		getUIManager():create("ui/clsGuildWillOpenTips", nil, 2)
	else
		getUIManager():create("gameobj/guild/clsGuildBossUI")
	end
end

ClsGuildActivityOptionsPanel.btnPortFlightClick = function(self)
	if getGameData():getGuildInfoData():getGuildGrade() < 30 then 
		ClsAlert:warning({msg = error_info[870].message})
	else
		getUIManager():create("gameobj/port/clsPortBattleMainUI")
	end
end

ClsGuildActivityOptionsPanel.btnWarClick = function(self)
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:askEnterGuildFightUI()
end

return ClsGuildActivityOptionsPanel
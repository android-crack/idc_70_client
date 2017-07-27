--
-- 港口战，港口特权tip
--

local ClsBaseView 					= require("ui/view/clsBaseView")
local music_info 					= require("game_config/music_info")
local ui_word 						= require("game_config/ui_word")
local ClsScrollView 				= require("ui/view/clsScrollView")
local ClsScrollViewItem 			= require("ui/view/clsScrollViewItem")
local port_fight_info 				= require("game_config/port/port_fight_info")

---------------------- ClsGuildPortPrivilegeCell ---------------------------
local ClsGuildPortPrivilegeCell 	= class("ClsGuildPortPrivilegeCell", ClsScrollViewItem)

ClsGuildPortPrivilegeCell.initUI = function(self, data)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_portfight_list.json")
	self:addChild(panel)

	self["port_name"] 		= getConvertChildByName(panel, "port_name")
	self["privilege_desc"] 	= getConvertChildByName(panel, "right_content")

	self.port_name:setText(data.name)
	self.privilege_desc:setText(data.desc)
end

---------------------- ClsGuildPortPrivilegeTip ----------------------------
local ClsGuildPortPrivilegeTip 		= class("ClsGuildPortPrivilegeTip", ClsBaseView)

ClsGuildPortPrivilegeTip.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

ClsGuildPortPrivilegeTip.onEnter = function(self, guild_id)
	self["no_enroll_text"] 	= nil 		-- 暂无报名港口
	self["no_hold_text"] 	= nil 		-- 暂无占领港口

	self["txt_week_port"] 	= nil 
	self["txt_week_right"] 	= nil 

	self["port_list"] 		= nil 

	self["btn_close"] 		= nil 

	self.guild_id = guild_id

	self:initUI()
	self:askBaseData()
end

ClsGuildPortPrivilegeTip.askBaseData = function(self)
	getGameData():getPortBattleData():askCurPortsInfo(self.guild_id)
end

ClsGuildPortPrivilegeTip.initUI = function(self)
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_portfight.json")
	self:addWidget(panel)

	local widgets = {"no_enroll_text", "no_hold_text", "txt_week_port", "txt_week_right", "btn_close"}
	for k, v in pairs(widgets) do
		self[v] = getConvertChildByName(panel, v)
	end

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	self.port_list = ClsScrollView.new(536, 210, true, function () end, {is_widget = true, is_fit_bottom = true })
	self.port_list:setPosition(ccp(210, 175))
	self:addWidget(self.port_list)
end

ClsGuildPortPrivilegeTip.updateUI = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	local challenge_list = port_battle_data:getChallegeList()
	local occupy_list = port_battle_data:getOccupyList()

	if occupy_list and #occupy_list > 0 then
		self:createPortList(occupy_list)
	else
		self.port_list:setVisible(false)
		self.no_hold_text:setVisible(true)
	end
	if challenge_list and challenge_list[1] then
		self:setApplyPort(challenge_list[1])
	else
		self.no_enroll_text:setVisible(true)
		self.txt_week_port:setVisible(false)
		self.txt_week_right:setVisible(false)
	end
end

ClsGuildPortPrivilegeTip.createPortList = function(self, list)
	self.no_hold_text:setVisible(false)
	self.port_list:setVisible(true)

	self.port_list:removeAllCells()

	local cells = {}
	for k, v in pairs(list) do
		local data = self:getPortPrivilegeDesc(v)
		if data then
			table.insert(cells, ClsGuildPortPrivilegeCell.new(CCSize(536, 40), data))
		end
	end
	self.port_list:addCells(cells)
end

ClsGuildPortPrivilegeTip.setApplyPort = function(self, port_id)
	self.no_enroll_text:setVisible(false)
	self.txt_week_port:setVisible(true)
	self.txt_week_right:setVisible(true)
	local data = self:getPortPrivilegeDesc(port_id)
	self.txt_week_port:setText(data.name)
	self.txt_week_right:setText(data.desc)
end

ClsGuildPortPrivilegeTip.getPortPrivilegeDesc = function(self, port_id)
	if not port_id or not port_fight_info[port_id] then return end
	local desc_txt = {
		["pub"] = ui_word.PUB_PORT_DESC,
		["ship"] = ui_word.SHIP_PORT_DESC,
		["market"] = ui_word.MARKET_PORT_DESC,
	}
	local info = port_fight_info[port_id]
	return {
		name = info.name,
		desc = string.format(desc_txt[info.type], info.privilege)
	}
end

return ClsGuildPortPrivilegeTip
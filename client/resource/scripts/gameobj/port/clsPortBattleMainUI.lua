local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local clsBaseView = require("ui/view/clsBaseView")
local error_info =require("game_config/error_info")
local composite_effect = require("gameobj/composite_effect")
local ClsPortBattleMainUI = class("ClsPortBattleMainUI", clsBaseView)

local WIDGET_NUM = 4
local widget = {
	"flag_pic_",
	"flag_white_",
	"effects_",
}
local status2kind = {
	[PORT_BATTLE_STATUS.PRE_BATTLE_APPLY] = 1,--宣战阶段
	[PORT_BATTLE_STATUS.BUILD_DONATE] = 2,--建造阶段
	[PORT_BATTLE_STATUS.START_WAR_1] = 3,--开战阶段
	[PORT_BATTLE_STATUS.START_WAR_2] = 3,--开战阶段
	[PORT_BATTLE_STATUS.FINISH_1] = 4,--结束阶段
	[PORT_BATTLE_STATUS.FINISH_2] = 4,--结束阶段
}

--宣战界面
ClsPortBattleMainUI.clickPreBattleEvent = function(self, index)
	if not self.cur_status then return end
	getUIManager():create("gameobj/port/clsPortBattleSignUI")
end

--检查是否已经报名
local function checkHasEnroll()
	local cur_port = getGameData():getPortBattleData():getPortList()[1]
	if cur_port then
		return true
	end
	ClsAlert:warning({msg = error_info[641].message})
end

ClsPortBattleMainUI.clickBuildEvent = function(self, index)
	if not self.cur_status then return end
	local _kind = status2kind[self.cur_status]
	if _kind == index then
		if checkHasEnroll() then
			getUIManager():create("gameobj/guild/clsBoatDonateUI")
		end
	elseif _kind < index then
		ClsAlert:warning({msg = ui_word.PORT_BATTLE_PRE_BUILD})
	else
		ClsAlert:warning({msg = ui_word.PORT_BATTLE_AFTER_BUILD})
	end
end

ClsPortBattleMainUI.clickGoBattleEvent = function(self, index)
	if not self.cur_status then return end
	local _kind = status2kind[self.cur_status]
	if _kind == index then
		if checkHasEnroll() then
			getUIManager():create("gameobj/port/clsPortBattleUI")
		end
	elseif _kind < index then
		ClsAlert:warning({msg = ui_word.PORT_BATTLE_PRE_WAR})
	else
		ClsAlert:warning({msg = ui_word.PORT_BATTLE_FINAL})
	end
end

ClsPortBattleMainUI.clickFinishEvent = function(self, index)
	if not self.cur_status then return end
	local _kind = status2kind[self.cur_status]
	if _kind == index then
		if checkHasEnroll() then
			getUIManager():create("gameobj/port/clsPortBattleUI")
		end
	elseif _kind < index then
		ClsAlert:warning({msg = ui_word.PORT_BATTLE_PRE_FINISH})
	end
end

ClsPortBattleMainUI.getViewConfig = function(self)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

ClsPortBattleMainUI.onEnter = function(self)
	self.cur_status = nil
	self.plist = {
		["ui/guild_ui.plist"] = 1,
	}
	LoadPlist(self.plist)

	self:mkUI()
	self:initUI()
	self:regEvent()
	self:askData()
end

ClsPortBattleMainUI.askData = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:askPortBattleStatus()
end

ClsPortBattleMainUI.mkUI = function(self)
	local panel = createPanelByJson("json/portfight_flow.json")
	self:addWidget(panel)
	for i = 1, WIDGET_NUM do
		for _, v in pairs(widget) do
			self[v..i] = getConvertChildByName(panel, v..i)
		end
	end
	self.btn_close = getConvertChildByName(panel, "btn_close")
	-- self.lbl_enroll_tip_1 = getConvertChildByName(panel, "flag_info_a_1")
	-- self.lbl_enroll_port_1 = getConvertChildByName(panel, "flag_info_b_1")
	-- self.lbl_enroll_tip_2 = getConvertChildByName(panel, "flag_info_a_now_1")
	-- self.lbl_enroll_port_2 = getConvertChildByName(panel, "flag_info_b_now_1")
end

local tab_event = {
	[1] = ClsPortBattleMainUI.clickPreBattleEvent,
	[2] = ClsPortBattleMainUI.clickBuildEvent,
	[3] = ClsPortBattleMainUI.clickGoBattleEvent,
	[4] = ClsPortBattleMainUI.clickFinishEvent,
}

ClsPortBattleMainUI.regEvent = function(self)
	for i = 1, WIDGET_NUM do
		self["flag_pic_"..i]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_CLOSE.res)
			tab_event[i](self, i)
		end, TOUCH_EVENT_ENDED)
		self["flag_pic_"..i]:setTouchEnabled(true)

		self["flag_white_"..i]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_CLOSE.res)
			tab_event[i](self, i)
		end, TOUCH_EVENT_ENDED)
		self["flag_white_"..i]:setTouchEnabled(true)
	end

	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end

ClsPortBattleMainUI.initUI = function(self)
	for i = 1, WIDGET_NUM do
		self["flag_pic_"..i]:setTouchEnabled(false)
		self["flag_white_"..i]:setTouchEnabled(false)
	end
end

local function setBtnStatus(btn, bool)
	btn:setVisible(bool)
	btn:setTouchEnabled(bool)
end

ClsPortBattleMainUI.updateUI = function(self)
	local port_battle_data = getGameData():getPortBattleData()
	self.cur_status = port_battle_data:getPortBattleStatus()

	local _kind = status2kind[self.cur_status]
	for i = 1, WIDGET_NUM do
		setBtnStatus(self["flag_pic_"..i], true)
		setBtnStatus(self["flag_white_"..i], false)
	end
	setBtnStatus(self["flag_pic_".._kind], false)
	setBtnStatus(self["flag_white_".._kind], true)
	--显示特效
	if not tolua.isnull(self.select_effect) then
		self.select_effect:removeFromParentAndCleanup(true)
		self.select_effect = nil
	end
	self.select_effect = composite_effect.new("tx_portfight_helm", 0, 20, self["effects_".._kind])

	-- if self.cur_status == PORT_BATTLE_STATUS.PRE_BATTLE_APPLY then
	-- 	self.lbl_enroll_tip_2:setText(ui_word.STR_PORT_BATTLE_SIGN_TIP)
	-- 	self.lbl_enroll_port_1:setText()
	-- else
	-- 	self.lbl_enroll_tip_1:setText(ui_word.STR_PORT_BATTLE_SIGN_TIP)
	-- 	self.lbl_enroll_port_2:setText()
	-- end
end

ClsPortBattleMainUI.onExit = function(self)
	UnLoadPlist(self.plist)
end

return ClsPortBattleMainUI
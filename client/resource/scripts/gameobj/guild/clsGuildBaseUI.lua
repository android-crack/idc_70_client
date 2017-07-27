--
-- 商会主界面基类
-- 完成clsGuildMainUI和clsGuildOtherUI中的基本信息
--
local ui_word 			= require("game_config/ui_word")
local guild_badge_info 	= require("game_config/guild/guild_badge")
local music_info 		= require("game_config/music_info")
local ClsBaseView 		= require("ui/view/clsBaseView")

local ClsGuildBaseUI	= class("ClsGuildBaseUI", ClsBaseView)

ClsGuildBaseUI.guild_bg_json 	= "json/guild_main.json"
ClsGuildBaseUI.guild_info_json 	= "json/guild_hall.json"

local GUILD_STATUS_ICON = {
	[ui_word.STR_GUILD_STATE_GOOD] = {res = "guild_hall_green.png", color = COLOR_GREEN_STROKE},
	[ui_word.STR_GUILD_STATE_NORMAL] = {res = "guild_hall_yellow.png", color = COLOR_YELLOW_STROKE},
	[ui_word.STR_GUILD_STATE_BAD] = {res = "guild_hall_red.png", color = COLOR_RED_STROKE},
}

ClsGuildBaseUI.onEnter = function(self, data)
	-- 成员变量声明
	self["guild_data"] 			= data or {}
	self["info_panel"] 			= nil
	self["mine_panel"]			= nil
	self["other_panel"]			= nil

	self["lv_instruction_btn"] 	= nil
	self["btn_close"] 			= nil
	self["btn_instruction"] 	= nil
	self["badge_txt"] 			= nil 		-- 商会头像名称
	self["badge_icon"] 			= nil 		-- 商会头像

	self["guild_level"] 		= nil 		-- 商会等级
	self["donation_num"] 		= nil 		-- 商会经验
	self["donation_progress"] 	= nil 		-- 进度条
	self["guild_name"] 			= nil 		-- 商会名
	self["president_name"] 		= nil 		-- 会长名
	self["requtation_num"] 		= nil 		-- 声望值
	self["military_num"] 		= nil 		-- 战绩
	self["member_amount"] 		= nil 		-- 成员数
	self["guild_state"] 		= nil 		-- 商会状态
	self["btn_port_view"] 		= nil 		-- 查看占领港口

	self["res_plist"] 	= {
		["ui/guild_ui.plist"] 	= 1,
		["ui/guild_main.plist"] = 1,
		["ui/guild_badge.plist"] = 1,
		["ui/skill_icon.plist"] = 1
	}
	LoadPlist(self.res_plist)

	self.armature_tab 	= {
		"effects/tx_0100.ExportJson"
	}
	LoadArmature(self.armature_tab)

	self:initUI()
	self:askBaseData()
end

ClsGuildBaseUI.initUI = function(self)
	local bg_widget = GUIReader:shareReader():widgetFromJsonFile( ClsGuildBaseUI.guild_bg_json )
	self:addWidget(bg_widget)

	self:initGuildHallView()
end

-- 设置基本UI，获取基本信息控件
ClsGuildBaseUI.initGuildHallView = function(self)
	local info_widget 		= GUIReader:shareReader():widgetFromJsonFile( ClsGuildBaseUI.guild_info_json )
	self:addWidget(info_widget)

	self.info_panel 		= getConvertChildByName(info_widget, "guild_info")
	self.mine_panel 		= getConvertChildByName(info_widget, "btn_panel")
	self.other_panel 		= getConvertChildByName(info_widget, "institute_panel")

	self.lv_instruction_btn = getConvertChildByName(info_widget, "lv_instruction_btn")
	self.btn_close 			= getConvertChildByName(info_widget, "btn_close")
	self.btn_instruction	= getConvertChildByName(info_widget, "lv_instruction_btn")
	self.badge_txt 			= getConvertChildByName(info_widget, "badge_txt")
	self.badge_icon 		= getConvertChildByName(info_widget, "badge_icon")

	self.guild_level 		= getConvertChildByName(self.info_panel, "guild_level")
	self.donation_num 		= getConvertChildByName(self.info_panel, "donation_progress_num")
	self.donation_progress 	= getConvertChildByName(self.info_panel, "donation_progress")
	self.guild_name 		= getConvertChildByName(self.info_panel, "guild_name")
	self.president_name 	= getConvertChildByName(self.info_panel, "guild_president_name")
	self.requtation_num 	= getConvertChildByName(self.info_panel, "reputation_nun")
	self.military_num 		= getConvertChildByName(self.info_panel, "military_win")
	self.member_amount 		= getConvertChildByName(self.info_panel, "people_amount")
	self.guild_state 		= getConvertChildByName(self.info_panel, "state_txt")
	self.btn_port_view 		= getConvertChildByName(self.info_panel, "btn_view")
	self.status_btn			= getConvertChildByName(self.info_panel, "state_touch")
	self.status_icon 		= getConvertChildByName(self.info_panel, "state_dot")
	self.lbl_enroll_status 	= getConvertChildByName(self.info_panel, "enroll_status")

	self.btn_port_view:setPressedActionEnabled(true)
	self.btn_close:setPressedActionEnabled(true)
	self.lv_instruction_btn:setPressedActionEnabled(true)

	self.status_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/guild/clsGuildStatusTipUI")
	end, TOUCH_EVENT_ENDED)

	self.lv_instruction_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/guild/clsGuildInfoLevelInstruction")
	end, TOUCH_EVENT_ENDED)

	self.btn_port_view:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local guild_id = self:getCurGuildId()
		getUIManager():create("gameobj/guild/clsGuildPortPrivilegeTip", nil, guild_id)
	end, TOUCH_EVENT_ENDED)

	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:effectClose()
	end, TOUCH_EVENT_ENDED)

	self:updateEnrollStatus()
end

ClsGuildBaseUI.updateGuildBaseInfo = function(self, info)
	self.guild_data = info
	local data_handler = getGameData():getGuildInfoData()

	self.guild_name:setText( info.name )
	self.president_name:setText( data_handler:getCaptionName(info.members) )
	self.requtation_num:setText( info.group_prestige )
	self.military_num:setText( string.format(ui_word.STR_GUILD_INFO_BATTLE_AMOUNT, info.win_amount))
	self.member_amount:setText( #info.members.."/"..info.maxMembers )

	local guild_status_txt = data_handler:getGuildState(info.cdofusg)
	self.guild_state:setText( guild_status_txt )
	self.guild_state:setColor(ccc3(dexToColor3B(GUILD_STATUS_ICON[guild_status_txt].color)))
	self.status_icon:changeTexture( convertResources(GUILD_STATUS_ICON[guild_status_txt].res), UI_TEX_TYPE_PLIST )

	local badge_info = guild_badge_info[tonumber(info.icon)]
	self.badge_txt:setText( badge_info.name )
	self.badge_icon:changeTexture( convertResources(badge_info.res), UI_TEX_TYPE_PLIST )

	self:updateGuildLevel(info.grade, info.curExp, info.maxExp)
	self:updateGuildPort(info.occupy_ports, info.apply_port)
end

ClsGuildBaseUI.updateGuildLevel = function(self, grade, cur, max)
	self.guild_level:setText( string.format(ui_word.STR_LV, grade) )
	if tonumber(max) == -1 then 
		self.donation_num:setText("0/0")
		self.donation_progress:setPercent(0)
	else
		self.donation_num:setText( cur.."/"..max )
		self.donation_progress:setPercent( cur / max * 100 )
	end
end

ClsGuildBaseUI.updateGuildPort = function(self, occupy_ports, apply_port)
	-- local guild_port_tip = getUIManager():get("ClsGuildPortPrivilegeTip")
	-- if not tolua.isnull(guild_port_tip) then
	-- 	guild_port_tip:updatePortInfo(occupy_ports, apply_port)
	-- end
end

ClsGuildBaseUI.updateEnrollStatus = function(self, is_enroll_succeed)
	local port_battle_data = getGameData():getPortBattleData()
	local challenge_list = port_battle_data:getChallegeList()
	self.lbl_enroll_status:setText(ui_word.STR_PORT_BATTLE_SIGN_NONE)
	setUILabelColor(self.lbl_enroll_status , ccc3(dexToColor3B(COLOR_RED)))
	if is_enroll_succeed or (challenge_list and challenge_list[1]) then
		self.lbl_enroll_status:setText(ui_word.STR_PORT_BATTLE_SIGN_ALREADY)
		setUILabelColor(self.lbl_enroll_status , ccc3(dexToColor3B(COLOR_ORANGE_STROKE)))
	end
end

ClsGuildBaseUI.askBaseData = function(self)
	local guild_id = self:getCurGuildId()
	getGameData():getPortBattleData():askCurPortsInfo(guild_id)
end

--子类实现
ClsGuildBaseUI.getCurGuildId = function(self)
end

ClsGuildBaseUI.onExit = function(self)
	UnLoadPlist(self.res_plist)
	UnLoadArmature(self.armature_tab)
	ReleaseTexture()
end

return ClsGuildBaseUI
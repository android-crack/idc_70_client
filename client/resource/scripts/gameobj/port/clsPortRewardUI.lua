----
----Author: 0496
----CrateTime: 2015-11-13 10:25:01
----Function: 市政厅悬赏界面
----
local alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local voice_info = getLangVoiceInfo()
local music_info = require("game_config/music_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsDailyMission = require("gameobj/mission/dailyMission")
local daily_mission = require("game_config/mission/daily_mission")
local dataTools = require("module/dataHandle/dataTools")
local compositeEffect = require("gameobj/composite_effect")
local tips = require("game_config/tips")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsCommonRewardPop = require("gameobj/quene/clsCommonRewardPop")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")

local OPEN_TEAM_TIPS_LEVEL = 20
local COMUSE_POWER_NUM = 15 ---消耗体力数目

local MISSION_B_DIFFICULTY = 3 ---b级任务

local clsPortRewardUI = class("clsPortRewardUI", ClsBaseView)

local current_effect 		= nil

-- static
clsPortRewardUI.clearEffectOnce = function(self)
	current_effect = 0
end

-- static
clsPortRewardUI.getViewConfig = function(self)
	return {
		is_swallow = false, 
		effect = current_effect or UI_EFFECT.DOWN
	}
end

clsPortRewardUI.onCtor = function(self)
	current_effect = nil
end

clsPortRewardUI.onEnter = function(self, panel_pos)
	self.difficultIconConfig ={
		[1] = "common_letter_d2.png",
		[2] = "common_letter_c2.png",
		[3] = "common_letter_b2.png",
		[4] = "common_letter_a2.png",
		[5] = "common_letter_s2.png",
	}

	self.m_panel_pos = panel_pos or ccp(0, 0)
	self.m_is_show_reward_box = false
	self.m_is_play_get_sound = false
	self.m_is_play_fresh_eff = false
	self.m_reward_ui = nil
	self.click_auto_btn = false
	self.plistTab = {
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
	}
	LoadPlist(self.plistTab)

	self:markUI()
	self:configEvent()
	self:setVisible(false)

	GameUtil.callRpc("rpc_server_get_daily_mission", {}, "rpc_client_get_daily_mission")    
end


clsPortRewardUI.setIsPlayGetSound = function(self, value_b)
	self.m_is_play_get_sound = value_b
end

clsPortRewardUI.setIsPlayFreshEff = function(self, value_b)
	self.m_is_play_fresh_eff = value_b
end

clsPortRewardUI.playGetSoundOnce = function(self)
	if self.m_is_play_get_sound and (false == self.m_is_show_reward_box) then
		audioExt.playEffect(voice_info.VOICE_PLOT_1031.res)
		self.m_is_play_get_sound = false
	end
end

clsPortRewardUI.markUI = function(self)

	self.cityhall_reward = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_xuanshang.json")
	self.cityhall_reward:setPosition(self.m_panel_pos)
	self:addWidget(self.cityhall_reward)

	local needWidgetName = {
		"list_mission_1",
		"list_mission_2",
		"list_mission_3",
		"list_mission_4",
		"btn_refresh",
		"free_coin_num",
		"refresh_panel",
		--"coin_pic",
		"accept_btn",
		"story_text",
		"xuanshang_hint",
		"consume_panel",
		"bar_num",
		"bar_pic",  --藏宝图进度条
		"auto_check",---复选框
		--"auto_accept_amount",

		"give_up_btn", --放弃按钮
	}

	for k, v in pairs(needWidgetName) do
		self[v] = getConvertChildByName(self.cityhall_reward, v)
	end
	--添加特效对象
	for i = 1, 3 do
		local eff_spr = display.newSprite()
		self["list_mission_" .. i]:addCCNode(eff_spr)
		self["list_mission_" .. i].eff_spr = eff_spr
		eff_spr:setZOrder(100)
	end
	local index = math.random(145, 150)  --进入界面刷新提示
	local str = tips[index].msg
	self.xuanshang_hint:setText(str)
	-- self.m_close_btn = self.parent:getBtnClose()
	ClsGuideMgr:tryGuide("clsPortRewardUI")
	self:updateAutoRewardUI()
end

clsPortRewardUI.updateAutoRewardUI = function(self)
	local onOffData = getGameData():getOnOffData()
	local is_auto_open = onOffData:isOpen(on_off_info.AUTO_TREAT.value)
	self.auto_check:setVisible(is_auto_open)
	self.auto_check:setTouchEnabled(is_auto_open)
end


clsPortRewardUI.configEvent = function(self)

	self.btn_refresh:setPressedActionEnabled(true)
	self.btn_refresh:addEventListener(function (  )
		self.btn_refresh:setTouchEnabled(false)
	end,TOUCH_EVENT_BEGAN)

	self.btn_refresh:addEventListener(function (  )
		self.btn_refresh:setTouchEnabled(true)
	end,TOUCH_EVENT_CANCELED)

	self.btn_refresh:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local missionDataHandler = getGameData():getMissionData()
		local playerData = getGameData():getPlayerData()
		local gold_num = playerData:getGold()   ---钻石数
		local missionDataHandler = getGameData():getMissionData()
		local free_times = missionDataHandler:getHotelFreeNumbers().times
		local is_free = 0

		self.btn_refresh:setTouchEnabled(true)
		if free_times > 0 then
			is_free = 1
			for k, v in pairs(missionDataHandler:getHotelRewardMissionInfo()) do
				if v.difficulty >= MISSION_B_DIFFICULTY then
					alert:showAttention(ui_word.DAILY_REWARD_IS_CHANGE_MISSION, function()
							missionDataHandler:refreshTaskByDiamond(is_free)
						end, nil, nil, {hide_cancel_btn = true})
					return
				end
			end

			missionDataHandler:refreshTaskByDiamond(is_free)
		else
			alert:warning({msg = ui_word.MISSION_NO_FIRE_TIMES, size = 26})
		end

	end,TOUCH_EVENT_ENDED)

	self.accept_btn:setPressedActionEnabled(true)
	--self.accept_btn.can_touch_b = true
	self.accept_btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if tolua.isnull(self.current_btn_reward) then
			return
		end

		local missionDataHandler = getGameData():getMissionData()
		local value = self.current_btn_reward.value
		if value.status == 1 then
			missionDataHandler:dailyMissionGoOn(value)
		elseif value.status == 2 then

			self.completeReward = table.clone(value.reward)
			missionDataHandler:getRewardMission()    ---领取奖励
			self.accept_btn:setTouchEnabled(false)
			self:updateComplatedTimes(true)

		else

			missionGuide:clearGuideLayer()
			local power_num = getGameData():getPlayerData():getPower()
			if power_num >= COMUSE_POWER_NUM then
				local sound = voice_info["VOICE_PLOT_1022"].res
				audioExt.playEffect(sound) 
				self.click_auto_btn = true               
				self:popTaskTips()
			else
				local parameter = {} 
				if isExplore then
					parameter.ignore_sea = true 
				end
				alert:showJumpWindow(POWER_NOT_ENOUGH, nil, parameter)
			end

		end
	end, TOUCH_EVENT_ENDED)

	self.give_up_btn:setPressedActionEnabled(true)
	self.give_up_btn:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local missionDataHandler = getGameData():getMissionData()
		local value = self.current_btn_reward.value
		if value.status == 1 then
			alert:showAttention(ui_word.TASK_IS_GIVEUP, function()
				--如果放弃海盗将清除海盗pve的信息数据
				local vjson = value.json_info
				if vjson and vjson.battleInfo then
					getGameData():getExploreNpcData():removeNpc(-1)
				end
				missionDataHandler:giveUpMission()   --放弃任务
			end, nil, nil, {hide_cancel_btn = true})
		end

	end,TOUCH_EVENT_ENDED)


	self.auto_check:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local missionDataHandler = getGameData():getMissionData()
		local is_auto = missionDataHandler:isAutoPortRewardStatus()
		if not is_auto then
			self.auto_check:setSelectedState(false)

			alert:showAttention(ui_word.MISSION_AUTO_NO_TIMES_OR_VIP,function()
				--print("-跳转到vip------")
				local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
				missionSkipLayer:skipLayerByName("vip_monthcard")
			end,nil,nil,{ok_text = ui_word.MISSION_GO_TO_OPEN ,cancel_text = ui_word.MISSION_GO_TO_NEXT })

			return 
		end
		missionDataHandler:setSelectAutoMission(true)
		self:updateAcceptLab()
	end,CHECKBOX_STATE_EVENT_SELECTED)

	self.auto_check:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local missionDataHandler = getGameData():getMissionData()
		missionDataHandler:setSelectAutoMission(false) 
		self:updateAcceptLab()
	end,CHECKBOX_STATE_EVENT_UNSELECTED)

	local missionDataHandler = getGameData():getMissionData()
	local is_select_auto = missionDataHandler:getSelectAutoMission() 
	local is_auto = missionDataHandler:isAutoPortRewardStatus()

	local defult_select_auto = false
	if is_auto and is_select_auto then
		defult_select_auto = true
	end

	self.auto_check:setSelectedState(defult_select_auto)

	missionGuide:pushGuideBtn(on_off_info.PORT_HOTEL_TREATCONFIRM.value, {guideBtn = self.accept_btn, guideLayer = self, isUIWidget = true, x = 645, y = 45, zorder = 1})
end

clsPortRewardUI.updateAcceptLab = function(self)
	self:updateMissionInfo()
end

clsPortRewardUI.autoMission = function(self)
	local power_num = getGameData():getPlayerData():getPower()
	if power_num >= COMUSE_POWER_NUM then
	   self:popTaskTips() 
	else
		local parameter = {} 
		if isExplore then
			parameter.ignore_sea = true 
		end
		alert:showJumpWindow(POWER_NOT_ENOUGH, nil, parameter)
	end

end


clsPortRewardUI.popTaskTips = function(self)
	local missionDataHandler = getGameData():getMissionData()
	local is_open = missionDataHandler:getWindowTipsStatus()

	local team_data = getGameData():getTeamData()
	local open_tips = 0
	local playerData = getGameData():getPlayerData()
	local playerLevel = playerData:getLevel()
	if not team_data:isInTeam() and is_open == open_tips and playerLevel >= OPEN_TEAM_TIPS_LEVEL and self.click_auto_btn then
		self:createTips()
		return
	end
	self:acceptMission()
end


clsPortRewardUI.acceptMission = function(self)
	local missionDataHandler = getGameData():getMissionData()
	local value = self.current_btn_reward.value                    
	missionDataHandler:StartMissionInfo(table.clone(value))

	local portData = getGameData():getPortData()
	local port_id = portData:getPortId() -- 当前港口id

	if isExplore then        
		port_id = missionDataHandler:getReceiveMissionPortId()
	end

	---判断自动悬赏
	local is_auto = missionDataHandler:isAutoPortRewardStatus()
	local is_select_auto = missionDataHandler:getSelectAutoMission()
	if is_auto and is_select_auto then
		missionDataHandler:acceptAutoMission(value.index, port_id)
		local ClsAutoPortRewardLayer = getUIManager():get("ClsAutoPortRewardLayer")
		if tolua.isnull(ClsAutoPortRewardLayer) then
			getUIManager():create("gameobj/port/clsAutoPortRewardLayer")
		end
	else
		missionDataHandler:acceptMission(value.index, port_id)              
	end

	local GuildMainUI = getUIManager():get("ClsGuildMainUI")
	if not tolua.isnull(GuildMainUI) then
		GuildMainUI:close()
	end 
	local ClsPortTeamUI = getUIManager():get("ClsPortTeamUI")
	if not tolua.isnull(ClsPortTeamUI) then
		ClsPortTeamUI:close()
	end 

	local ClsGuildTaskPanel = getUIManager():get("ClsGuildTaskPanel")
	if not tolua.isnull(ClsGuildTaskPanel) then
		ClsGuildTaskPanel:close()
	end

	if isExplore then
		local supplyData = getGameData():getSupplyData()
		supplyData:askSupplyFull()
	end
end

---接受按钮弹窗
clsPortRewardUI.createTips = function(self)
	local tips_name = {
		"btn_check",
		"btn_go",
		"btn_close_tips",
		"btn_close",
	}

	local layer = UIWidget:create()
	self.tips_panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_task.json") 
	convertUIType(self.tips_panel)
	layer:addChild(self.tips_panel)

	local bg_size = self.tips_panel:getContentSize()
	layer:setPosition(ccp(display.cx - bg_size.width/2 , display.cy - bg_size.height/2))

	for k, v in pairs(tips_name) do
		layer[v] = getConvertChildByName(self.tips_panel, v)
	end

	local windows_tips_status = 0 
	local missionDataHandler = getGameData():getMissionData()

	layer.btn_go:setPressedActionEnabled(true)
	layer.btn_go:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		missionDataHandler:askTaskTipsStatus(windows_tips_status)
		getUIManager():close("ClsPortRewardTips")

		if isExplore then
			alert:warning({msg = ui_word.MISSION_TEAM_TIPS, size = 26})
			return 
		end

		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		missionSkipLayer:skipLayerByName("team_wanted")

		local GuildMainUI = getUIManager():get("ClsGuildMainUI")
		if not tolua.isnull(GuildMainUI) then
			GuildMainUI:close()
		end 

		local ClsGuildTaskPanel = getUIManager():get("ClsGuildTaskPanel")
		if not tolua.isnull(ClsGuildTaskPanel) then
			ClsGuildTaskPanel:close()
		end   

	end,TOUCH_EVENT_ENDED)

	layer.btn_close_tips:setPressedActionEnabled(true)
	layer.btn_close_tips:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		missionDataHandler:askTaskTipsStatus(windows_tips_status)
		self:acceptMission()
		getUIManager():close("ClsPortRewardTips")

	end,TOUCH_EVENT_ENDED)

	layer.btn_close:setPressedActionEnabled(true)
	layer.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		missionDataHandler:askTaskTipsStatus(windows_tips_status)
		getUIManager():close("ClsPortRewardTips")

	end,TOUCH_EVENT_ENDED)

	layer.btn_check:addEventListener(function ()
		windows_tips_status = 1
	end,CHECKBOX_STATE_EVENT_SELECTED)

	layer.btn_check:addEventListener(function ()
		windows_tips_status = 0
	end,CHECKBOX_STATE_EVENT_UNSELECTED)

	getUIManager():create("ui/view/clsBaseTipsView", nil, "ClsPortRewardTips", {is_back_bg = false}, layer, true)
end

---免费处理
clsPortRewardUI.updataBtnAndLable = function(self, enable)
	local missionDataHandler = getGameData():getMissionData()
	local free = missionDataHandler:getHotelFreeNumbers()
	local times = free.times
	---免费刷新次数
	if times < 0 then
		times = 0
	end
	self.free_coin_num:setText(string.format("%s", times))
end

clsPortRewardUI.updateComplatedTimes = function(self, is_get_reward)
	local missionDataHandler = getGameData():getMissionData()
	local complated_times, all_times = missionDataHandler:getComplatedTimes()
	local times = complated_times
	--print("==========悬赏任务的完成次数，总数=======",complated_times, all_times)
	self.bar_num:setText(string.format("%s/%s", times, all_times))
	self.bar_pic:setPercent(times/all_times*100) 
end

clsPortRewardUI.initUI = function(self, is_show_eff)
	self:setVisible(true)    
	local missionDataHandler = getGameData():getMissionData()
	self.missionData = missionDataHandler:getHotelRewardMissionInfo()  ---悬赏任务
	if self.missionData == nil then
		return
	end

	self.refresh_panel:setVisible(#self.missionData ~= 1)
	self.consume_panel:setVisible(#self.missionData ~= 1)
	self:updataBtnAndLable()
	self:updateComplatedTimes()

	if #self.missionData ~= 1 then
		self:playGetSoundOnce()
	end

	for i = 1, 3 do
		self["list_mission_" .. i]:setVisible(false)
		if is_show_eff then
			self["list_mission_" .. i].eff_spr:removeAllChildrenWithCleanup(true)
		end
	end
	--self.accept_btn:setTouchEnabled(true)

	for key,value in pairs(self.missionData) do
		local missionConfig = daily_mission[tonumber(value.missionId)]   ---任务详情表
		local btn_name = getConvertChildByName(self["list_mission_" .. key],string.format("misison_name_%s",tostring(key)))
		btn_name:setText(missionConfig.mission_name[1])   ---任务名称
		local btn_icon = getConvertChildByName(self["list_mission_" .. key],string.format("mission_rank_%s",tostring(key)))
		btn_icon:loadTexture(self.difficultIconConfig[value.difficulty], UI_TEX_TYPE_PLIST)  ---任务等级图片
		self["list_mission_" .. key].missionConfig = missionConfig
		self["list_mission_" .. key].name_lab = btn_name
		self["list_mission_" .. key].value = value
		self["list_mission_" .. key].descIndex = math.random(#missionConfig.mission_desc)
		self["list_mission_" .. key]:setVisible(true)
		--播放特效
		if is_show_eff and self.m_is_play_fresh_eff then
			local effect_res_name_str = "tx_0151_normal"
			if value.difficulty >= #self.difficultIconConfig then
				effect_res_name_str = "tx_0151_s"
			end
			audioExt.playEffect(music_info.COMMON_CASH.res)
			compositeEffect.new(effect_res_name_str, -48, 0, self["list_mission_" .. key].eff_spr, 2)
		end
		if not self["list_mission_" .. key]:isTouchEnabled() then
			self["list_mission_" .. key]:setTouchEnabled(true)
			self["list_mission_" .. key]:setFocused(false)
		end

		self["list_mission_" .. key]:addEventListener(function()
				for i=1,#self.missionData do
					self["list_mission_" .. i]:setFocused(false)
				end
				self["list_mission_" .. key]:setFocused(true)
			end, TOUCH_EVENT_BEGAN)

		self["list_mission_" .. key]:addEventListener(function()
				for i=1,#self.missionData do
					if self.current_btn_reward and self.current_btn_reward == self["list_mission_" .. i] then
						self.current_btn_reward:setFocused(true)
					else
						self["list_mission_" .. i]:setFocused(false)

					end
				end 
			end, TOUCH_EVENT_CANCELED)

		self["list_mission_" .. key]:addEventListener(function()
			for i=1,#self.missionData do
				if i == key then
					self["list_mission_" .. i]:setTouchEnabled(false)
				else
					self["list_mission_" .. i]:setTouchEnabled(true)
				end
			end           
			self.current_btn_reward = self["list_mission_" .. key]
			self.current_btn_reward:setFocused(true)
			self:updateMissionInfo()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
		end, TOUCH_EVENT_ENDED)

		if key == 1 then
			self.current_btn_reward = self["list_mission_" .. key]
			self.current_btn_reward:setTouchEnabled(false)
			self.current_btn_reward:setFocused(true)
			self:updateMissionInfo()
		end

	end

	---放弃按钮的显示
	local value = self.current_btn_reward.value
	if value.status == 1 then
		self.give_up_btn:setVisible(true)
	else
		self.give_up_btn:setVisible(false)
	end


	for i=1,3 do
		if i ~= 1 then
			self["list_mission_" .. i]:setFocused(false)
		end
	end

	if is_show_eff and self.m_is_play_fresh_eff then
		self.m_is_play_fresh_eff = false
	end
	---自动悬赏领取奖励
	local is_auto = missionDataHandler:getAutoPortRewardStatus()
	if is_auto then
		missionDataHandler:getRewardMission()
	end
end

local widget_name = {
	"mission_name",
	"target_content",
	"hint_content",
}

clsPortRewardUI.isGuildReward = function(self, reward_item)
	local key = reward_item.key
	if key == ITEM_INDEX_GROUP_EXP or 
		key == ITEM_INDEX_BOSS_INVEST or 
		key == ITEM_INDEX_GROUP_PRESTIGE then
		
		return true
	end
	return false
end

clsPortRewardUI.updateMissionInfo = function(self)
	local missionDataHandler = getGameData():getMissionData()
	local value = self.current_btn_reward.value
	local missionConfig = self.current_btn_reward.missionConfig
	local story_pic = getConvertChildByName(self.cityhall_reward,"story_pic")
	story_pic:loadTexture(missionConfig.scene_icon,UI_TEX_TYPE_LOCAL)    ---背景图
	local rank_letter = getConvertChildByName(self.cityhall_reward,"story_rank")
	rank_letter:loadTexture(self.difficultIconConfig[value.difficulty],UI_TEX_TYPE_PLIST)    ---背景图
	
	self.story_text:setText(ClsDailyMission:transformMissionInfo(missionConfig, value).missionStr) --missionStr  ---任务描述

	local btn_accept_text = getConvertChildByName(self.accept_btn,"accept_text")
	btn_accept_text:setVisible(true)

	--local consume_panel = getConvertChildByName(self.cityhall_reward,"consume_panel")
	--consume_panel:setVisible(false)

	if value.status == 1 then
		btn_accept_text:setText(ui_word.MISSION_GO_TO_PORT)  --前往任务
	elseif value.status == 2 then
		btn_accept_text:setText(ui_word.LOGIN_VIP_AWARD_GET_BUTTON_2) ---领取奖励
	else
		--btn_accept_text:setVisible(false)
		--consume_panel:setVisible(true)
		btn_accept_text:setText(ui_word.STR_ACCEPT)  ----接受任务
		---自动悬赏
		-- local is_auto = missionDataHandler:isAutoPortRewardStatus()
		-- local is_select_auto = missionDataHandler:getSelectAutoMission()
		-- if is_auto and is_select_auto then    
		--     btn_accept_text:setText(ui_word.MISSION_AUTO_LAB)  
		-- end
	end


	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.cityhall_reward,v)
		self[v]:setVisible(false)
	end

	self.mission_name:setVisible(true)
	self.target_content:setVisible(true)
	self.mission_name:setText(missionConfig.mission_name[1])
	self.target_content:setText(ClsDailyMission:transformMissionInfo(missionConfig, value).progressDes) ---目标
   
	--设置奖励啦
	if not self.m_reward_ui then
		self:initMissionRewardUi()
	end
	--必发奖励
	local reward_tab = self.current_btn_reward.value.reward
	table.sort(reward_tab, function(a, b)
			return a.key < b.key
		end)

	local guild_count = 1
	local person_count = 1
	for i, v in ipairs(reward_tab) do
		local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon(v)
		
		local reward_ui = nil
		if self:isGuildReward(v) then
			reward_ui = self.m_reward_ui.guild.rewards[guild_count]
			guild_count = guild_count + 1
		else
			reward_ui = self.m_reward_ui.person.rewards[person_count]
			person_count = person_count + 1
			if v.key == ITEM_INDEX_EXP then
				amount = getGameData():getBuffStateData():getExpUpResult(amount)
			end
		end
		reward_ui.num_lab:setText(amount)
		reward_ui.num_lab:setVisible(true)
		reward_ui.name_lab:setText(name)
		reward_ui.name_lab:setVisible(true)
		reward_ui.pic_spr:setVisible(true)
		reward_ui.pic_spr:loadTexture(convertResources(icon), UI_TEX_TYPE_PLIST) 
		autoScaleWithLength(reward_ui.pic_spr, 26)
	end
	--隐藏多余的内容
	if person_count <= #self.m_reward_ui.person.rewards then
		for i = person_count, #self.m_reward_ui.person.rewards do
			local reward_ui = self.m_reward_ui.person.rewards[i]
			reward_ui.num_lab:setVisible(false)
			reward_ui.name_lab:setVisible(false)
			reward_ui.pic_spr:setVisible(false)
		end
	end

	if guild_count <= #self.m_reward_ui.guild.rewards then
		for i = guild_count, #self.m_reward_ui.guild.rewards do
			local reward_ui = self.m_reward_ui.guild.rewards[i]
			reward_ui.num_lab:setVisible(false)
			reward_ui.name_lab:setVisible(false)
			reward_ui.pic_spr:setVisible(false)
		end
	end

end

clsPortRewardUI.initMissionRewardUi = function(self)
	self.m_reward_ui = {}
	local guild_panel = getConvertChildByName(self.cityhall_reward,"guild_panel")
	local person_panel = getConvertChildByName(self.cityhall_reward,"person_panel")
	self.m_reward_ui.guild = {}
	self.m_reward_ui.guild.total_panel = guild_panel
	self.m_reward_ui.person = {}
	self.m_reward_ui.person.total_panel = person_panel
	
	self.m_reward_ui.guild.btn = getConvertChildByName(guild_panel,"guild_btn")
	self.m_reward_ui.guild.cut_panel = getConvertChildByName(self.cityhall_reward,"guild_cut_panel")
	self.m_reward_ui.guild.btn_tip_spr = getConvertChildByName(self.m_reward_ui.guild.btn,"guild_tip_pic")
	self.m_reward_ui.guild.reward_panel = getConvertChildByName(self.m_reward_ui.guild.cut_panel,"guild_reward_panel")

	self.m_reward_ui.person.btn = getConvertChildByName(person_panel,"person_btn")
	self.m_reward_ui.person.cut_panel = getConvertChildByName(person_panel,"person_cut_panel")
	self.m_reward_ui.person.btn_tip_spr = getConvertChildByName(self.m_reward_ui.person.btn,"person_tip_pic")
	self.m_reward_ui.person.reward_panel = getConvertChildByName(self.m_reward_ui.person.cut_panel,"person_reward_panel")
	
	--获取奖励
	local guild_rewards = {}
	local person_rewards = {}
	for i = 1, 4 do
		guild_rewards[i] = {}
		person_rewards[i] = {}
		guild_rewards[i].pic_spr = getConvertChildByName(self.m_reward_ui.guild.reward_panel,"reward_pic_"..i)
		person_rewards[i].pic_spr = getConvertChildByName(self.m_reward_ui.person.reward_panel,"reward_pic_"..i)
		guild_rewards[i].num_lab = getConvertChildByName(self.m_reward_ui.guild.reward_panel,"reward_num_"..i)
		person_rewards[i].num_lab = getConvertChildByName(self.m_reward_ui.person.reward_panel,"reward_num_"..i)
		guild_rewards[i].name_lab = getConvertChildByName(self.m_reward_ui.guild.reward_panel,"reward_type_"..i)
		person_rewards[i].name_lab = getConvertChildByName(self.m_reward_ui.person.reward_panel,"reward_type_"..i)
	end
	self.m_reward_ui.guild.rewards = guild_rewards
	self.m_reward_ui.person.rewards = person_rewards
	
	self.m_reward_ui.is_moving = false
	self.m_reward_ui.is_show_person = true
	local offset_y = 110
	local time_n = 0.3

	local guild_info_data = getGameData():getGuildInfoData()
	local has_guild = guild_info_data:hasGuild()

	if not has_guild then
		self.m_reward_ui.guild.btn:setVisible(false)
		self.m_reward_ui.person.btn:setTouchEnabled(false)
	end
	
	self.m_reward_ui.touch_callback = function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.m_reward_ui.is_moving then
			return
		end
		self.m_reward_ui.is_moving = true
		local moving_array = CCArray:create()
		if self.m_reward_ui.is_show_person then
			self.m_reward_ui.is_show_person = false
			self.m_reward_ui.person.btn_tip_spr:setScaleY(1)
			self.m_reward_ui.guild.btn_tip_spr:setScaleY(1)
			self.m_reward_ui.person.reward_panel:stopAllActions()
			self.m_reward_ui.person.reward_panel:setPosition(ccp(0,0))
			self.m_reward_ui.person.reward_panel:runAction(CCEaseBackIn:create(CCMoveTo:create(time_n, ccp(0, offset_y))))
			moving_array:addObject(CCEaseBackIn:create(CCMoveTo:create(time_n, ccp(0, offset_y))))
			moving_array:addObject(CCCallFunc:create(function()
					self.m_reward_ui.person.cut_panel:setVisible(false)
					self.m_reward_ui.is_moving = false
				end))
			self.m_reward_ui.guild.reward_panel:setVisible(true)
			self.m_reward_ui.guild.total_panel:runAction(CCSequence:create(moving_array))
		else
			self.m_reward_ui.is_show_person = true
			self.m_reward_ui.person.btn_tip_spr:setScaleY(-1)
			self.m_reward_ui.guild.btn_tip_spr:setScaleY(-1)
			moving_array:addObject(CCEaseBackOut:create(CCMoveTo:create(time_n, ccp(0, 0))))
			moving_array:addObject(CCCallFunc:create(function()
					self.m_reward_ui.guild.reward_panel:setVisible(false)
					self.m_reward_ui.is_moving = false
				end))
			self.m_reward_ui.guild.total_panel:runAction(CCSequence:create(moving_array))
			self.m_reward_ui.person.cut_panel:setVisible(true)
			self.m_reward_ui.guild.reward_panel:setVisible(true)
			self.m_reward_ui.person.reward_panel:setPosition(ccp(0, offset_y))
			self.m_reward_ui.person.reward_panel:stopAllActions()
			self.m_reward_ui.person.reward_panel:runAction(CCEaseBackOut:create(CCMoveTo:create(time_n, ccp(0, 0))))
		end
	end
	
	self.m_reward_ui.guild.btn:addEventListener(self.m_reward_ui.touch_callback, TOUCH_EVENT_ENDED)
	self.m_reward_ui.person.btn:addEventListener(self.m_reward_ui.touch_callback, TOUCH_EVENT_ENDED)
	
	--设置初始显示
	self.m_reward_ui.guild.btn_tip_spr:setScaleY(-1)
	self.m_reward_ui.person.btn_tip_spr:setScaleY(-1)
	self.m_reward_ui.guild.reward_panel:setVisible(false)
end

local tab = {
	["material"] = ITEM_INDEX_MATERIAL,
	["darwing"] = ITEM_INDEX_DARWING,
	["keepsake"] = ITEM_INDEX_KEEPSAKE,
	["item"] = ITEM_INDEX_PROP,
	["equip"] = ITEM_INDEX_EQUIP,
	["exp"] = ITEM_INDEX_EXP,
	["cash"] = ITEM_INDEX_CASH,
	["gold"] = ITEM_INDEX_GOLD,
	["tili"] = ITEM_INDEX_TILI,
	["honour"] = ITEM_INDEX_HONOUR,
	["sailor"] = ITEM_INDEX_SAILOR,
	["status"] = ITEM_INDEX_STATUS,
	["food"] = ITEM_INDEX_FOOD,
	["baowu"] = ITEM_INDEX_BAOWU,
	["contribute"] = ITEM_INDEX_CONTRIBUTE,
	["prestige"] = ITEM_INDEX_DONATE,   
}


clsPortRewardUI.putSameReward = function(self, tempReward, reward)
	for i,v in ipairs(tempReward) do
		if v.key == reward.key and v.id == reward.id then
			if v.value < reward.value then
				v.value = reward.value
			end
			return
		end
	end
	tempReward[#tempReward + 1] = reward
end

clsPortRewardUI.addGetRewardView = function(self, random_rewards)
	self.m_addition_random_rewards = random_rewards
end
--guild_material:商会建材 64，guild_honor:商会声望
clsPortRewardUI.showGetRewardView = function(self, exp_rate, is_flag, rewards, friend_rate)  ---获得奖励弹框 is_flag :是否多人任务

	local tempReward = {}
	local tempReward = table.clone(self.current_btn_reward.value.reward)
	local exp_reward = nil
	for k,v in ipairs(tempReward) do
		if v.key == ITEM_INDEX_EXP then
			exp_reward = v
		end
	end
	exp_rate = exp_rate or 0
	exp_reward.value = getGameData():getBuffStateData():getExpUpResult(exp_reward.value)
	if exp_rate > 0 then
		exp_reward.add_num = math.ceil(exp_reward.value*(exp_rate)/100)
		alert:warning({msg = string.format(ui_word.TEAM_REWARD_ADD_EXP_TIPS, exp_rate), size = 26}) ---你的经验额外增加
	end

	if friend_rate and friend_rate > 0 then
		alert:warning({msg = string.format(ui_word.DAILY_MISSION_ADD_FRIENT_POINT, friend_rate), size = 26})
	end
	   
	local filtrator = {
		[1] = ITEM_INDEX_GROUP_EXP,
		[2] = ITEM_INDEX_BOSS_INVEST,
		[3] = ITEM_INDEX_GROUP_PRESTIGE,
	}
	
	if self.m_addition_random_rewards then
		for _, v in ipairs(self.m_addition_random_rewards) do
			if v.amount > 0 then
				self:putSameReward(tempReward, {key = v.type, id = v.id, value = v.amount})
			end
		end
	end
	self.m_addition_random_rewards = nil
	
	--如果没奖励则不播
	if (#tempReward) <= 0 then return end
	self.m_is_show_reward_box = true
	local endCall
	endCall = function()
		self.m_is_show_reward_box = false
		--self.accept_btn.can_touch_b = true

		local clsPortRewardUI = getUIManager():get("clsPortRewardUI")
		if not tolua.isnull(clsPortRewardUI) then
			clsPortRewardUI:setAcceptBtnTouch()
		end

		self:playGetSoundOnce()
		local okCallBack
		okCallBack = function()
			local clsGuildTaskPanel = getUIManager():get("ClsGuildTaskPanel")
			if not tolua.isnull(clsGuildTaskPanel) then
				clsGuildTaskPanel:showUI("multi_person_task")
			end
		end
		
		if is_flag == 1 then   ----悬赏任务有多人任务
			alert:warning({msg = ui_word.TASK_MORE_MISSION, size = 26})
		end

		---判断自动悬赏
		local missionDataHandler = getGameData():getMissionData()
		local is_auto_status = missionDataHandler:getAutoPortRewardStatus()
		--local is_auto_times = missionDataHandler:getAutoMissionTimes()
		local is_vip = getGameData():getPlayerData():isVip()

		if is_auto_status then
			if is_vip then
				self:autoMission()
			else
				local str = ui_word.MISSION_AUTO_GO_TO_PORT
				alert:showAttention(str, function()
					local missionDataHandler = getGameData():getMissionData()
					missionDataHandler:askCancelAutoBounty()
					local port_id = missionDataHandler:getReceiveMissionPortId()
					getGameData():getWorldMapAttrsData():tryToEnterPort(port_id)

				end, nil, nil, {ok_text = ui_word.YES, cancel_text = ui_word.NO, is_notification = true})
			end
			
		end
	end
	

	local temp_reward = {}
	for k, v in ipairs(tempReward) do
		local save = true
		for i, j in ipairs(filtrator) do
			if j == v.key then
				save = false
				break
			end
		end
		if save then
			temp_reward[#temp_reward + 1] = v
		end
	end
	tempReward = temp_reward
	ClsDialogSequence:insertTaskToQuene(ClsCommonRewardPop.new({reward = rewards, callBackFunc = endCall}))
end

clsPortRewardUI.setAcceptBtnTouch = function(self)
	self.accept_btn:setTouchEnabled(true) 
end

clsPortRewardUI.onExit = function(self)
	UnLoadPlist(self.plistTab)
	ReleaseTexture(self)
end

--淡入效果完后增加音效
clsPortRewardUI.playOpenSound = function(self)
	local effecet = audioExt.playEffect(voice_info.VOICE_PLOT_1031.res)
end

return clsPortRewardUI

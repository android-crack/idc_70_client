local ui_word = require("scripts/game_config/ui_word")
local music_info=require("scripts/game_config/music_info")
local dataTools = require("module/dataHandle/dataTools")
local Alert = require("ui/tools/alert")
local ClsUiTools = require("gameobj/uiTools")
local guildBossConfig = require("game_config/guild/guild_boss_battle")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local BossState = {
	BossUnOpen = 0,
	BossFighting = 1,--讨伐中
	BossReceive = 2,--宝箱领取
}

local SHOW_BOSS_UI = 0
local SHOW_BOSS_RANK = 1

local boss_remain_time = -1 --公会boss距离结束时间

local BOSS_FIRST_OPEN_STATUS = 1
local BOSS_SECOND_OPEN_STATUS = 2

local BOSS_OPEN_TIME = {
	[1] = { ["hour"] = 12 , ["min"] = 30},
	[2] = { ["hour"] = 19 , ["min"] = 00},
}

local playCommonButtonEffect = function()
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
end

local BossStateTips = {
	[1] = ui_word.STR_GUILD_BOSS_FIGHTING_STATE_TIPS, --讨伐中
	[2] = ui_word.STR_GUILD_BOSS_RECEIVE_STATE_TIPS,--宝箱领取
}

local rankBoxNumConfig = {
	[1] = {start = 1, back = 3, num = 5},
	[2] = {start = 4, back = 10, num = 4},
	[3] = {start = 11, back = 20, num = 3},
	[4] = {start = 21, back = 30, num = 2},
	[5] = {start = 31, back = 50, num = 1},
}

local ClsBossRankItem = class("ClsBossRankItem", ClsScrollViewItem)
ClsBossRankItem.initUI = function(self, listCell)
	local data = listCell.data
	self.ui_layer = UIWidget:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_boss_rank.json")
	convertUIType(self.panel)
	self.ui_layer:addChild(self.panel)
	self:addChild(self.ui_layer)

	local rank_name = getConvertChildByName(self.panel, "rank_name")
	rank_name:setText(data.name)

	local rank_num = getConvertChildByName(self.panel, "rank_num")
	rank_num:setText(listCell.rank)

	local rank = tonumber(listCell.rank)
	if rank <= 3 and rank > 0 then
		local spr_rank = display.newSprite("#common_top_" .. rank .. ".png")
		spr_rank:setPosition(ccp(rank_num:getPosition().x, rank_num:getPosition().y))
		spr_rank:setScale(0.5)
		rank_num:getParent():addCCNode(spr_rank)
		rank_num:setVisible(false)
	end

	local rank_level = getConvertChildByName(self.panel, "rank_level")
	rank_level:setText(data.level)

	local pointValue = 0
	pointValue = data.point

	pointValue = tonumber(string.format("%0.3f", pointValue))
	local rank_percent = getConvertChildByName(self.panel, "rank_grade")
	rank_percent:setText(pointValue)

	local boxNum = 0
	for k,v in pairs(rankBoxNumConfig) do
		if listCell.rank >= v.start and  listCell.rank <= v.back then
			boxNum = v.num
			break
		end
	end

	local playerData = getGameData():getPlayerData()
	if data.uid == playerData:getUid() then --自己有排行榜里则让自己变绿。
		setUILabelColor(rank_percent, ccc3(dexToColor3B(COLOR_GREEN)))
		setUILabelColor(rank_level, ccc3(dexToColor3B(COLOR_GREEN)))
		setUILabelColor(rank_num, ccc3(dexToColor3B(COLOR_GREEN)))
		setUILabelColor(rank_name, ccc3(dexToColor3B(COLOR_GREEN)))
	end
end

local ClsGuildBossUI = class("GuildBossUI", ClsBaseView)
ClsGuildBossUI.getViewConfig = function(self, ...)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end


ClsGuildBossUI.onEnter = function(self, show_type)
	self.show_type = show_type
	self.GuildBossData = getGameData():getGuildBossData()

	self.resPlist = {
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/baowu.plist"] = 1,
		--最新ui资源
		["ui/hotel_ui.plist"] = 1,
		["ui/box.plist"] = 1,
	}
	LoadPlist(self.resPlist)

	local groupBossInfo = self.GuildBossData:getGroupBossInfo()
	local isOpen = groupBossInfo.status ~= BossState.BossUnOpen and  groupBossInfo.status ~= BossState.BossReceive

	self.isOpen = isOpen
	if isOpen then
		self:configUI()
		self.GuildBossData:askGuildBossCD()
		self.GuildBossData:sendRankInfo()
		self.GuildBossData:askGuildBossInfo()
	else
		self:configUnOpenUI()
	end

	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end, TOUCH_EVENT_ENDED)
end

ClsGuildBossUI.setRemoveUI = function(self)
	self:close()
	local GuildMainUI = getUIManager():get("ClsGuildMainUI")
	GuildMainUI:createGuildBoss()
end

ClsGuildBossUI.configUnOpenUI = function(self)
	self.uiLayer = UILayer:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_boss_close.json")
	convertUIType(self.panel)
	self.uiLayer:addWidget(self.panel)
	self:addChild(self.uiLayer)
	cocosAddSelfUIParams(self, self.panel)
end

ClsGuildBossUI.configUI = function(self)
	self.uiLayer = UILayer:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_boss_open.json")
	convertUIType(self.panel)
	self.uiLayer:addWidget(self.panel)

	self:addChild(self.uiLayer)
	cocosAddSelfUIParams(self, self.panel)
	self.state_info:setVisible(false)
	self.play_left1 = self.rule_left_panel
	self.play_left1:setVisible(false)
	self.play_left2 = self.rank_left_panel
	self.play_left2:setVisible(true)
	self.play_right1 = self.info_panel

	self.time_num:setVisible(false)
	self.kill_num:setVisible(false)
	self.rank_num:setVisible(false)
	self.integral_box_num:setVisible(false)
	self.integral_bar:setPercent(0)
	self:configPlayRight1View()

	self.integral_box_close:addEventListener(function() 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:showReward()
	end, TOUCH_EVENT_BEGAN)
	self.integral_box_close:addEventListener(function() 
		if not tolua.isnull(self.reward_ui) then
			self.reward_ui:removeFromParent()
		end
	end, TOUCH_EVENT_ENDED)

	self.integral_box_close:addEventListener(function() 
		if not tolua.isnull(self.reward_ui) then
			self.reward_ui:removeFromParent()
		end
	end, TOUCH_EVENT_CANCELED)
end

ClsGuildBossUI.showReward = function(self)
	if not tolua.isnull(self.reward_ui) then
		self.reward_ui:removeFromParent()
	end
	self.reward_ui = createPanelByJson("json/new_star_box_info.json")
	self.panel:addChild(self.reward_ui)
	self.reward_ui:setPosition(ccp(420, 135))
	local icon = getConvertChildByName(self.reward_ui, "award_icon_1")
	icon:changeTexture("box_full4.png", UI_TEX_TYPE_PLIST)
	icon:setScale(0.2)
	local name = getConvertChildByName(self.reward_ui, "award_text")
	name:setText(ui_word.STR_GUILD_GIFT)
	local num = getConvertChildByName(self.reward_ui, "award_num_1")
	num:setText("1")
end

ClsGuildBossUI.configPlayRight1View = function(self)
	--讨伐按钮
	self.btn_against:addEventListener(function()
		local zoomAction = CCScaleTo:create(0.05, 0.92, 0.92);
		self.btn_against:runAction(zoomAction)
	end, TOUCH_EVENT_BEGAN)
	self.btn_against:addEventListener(function()
		local zoomAction = CCScaleTo:create(0.05, 0.8, 0.8);
		self.btn_against:runAction(zoomAction)
	end, TOUCH_EVENT_CANCELED)
	self.btn_against:addEventListener(function()
		local zoomAction = CCScaleTo:create(0.05, 0.8, 0.8);
		local groupBossInfo = self.GuildBossData:getGroupBossInfo()
		self.btn_against:runAction(zoomAction)
		playCommonButtonEffect()

		--开启讨伐
		if self.GuildBossData:getFightCD() > 0 then
			self:resetFightCD()
		elseif groupBossInfo.status == BossState.BossUnOpen then
			Alert:warning({msg = ui_word.STR_GUILD_BOSS_FIGHTED, size = 26})
			self:setRemoveUI()
		elseif groupBossInfo.status == BossState.BossFighting then
			local guild_boss_data = getGameData():getGuildBossData()
			guild_boss_data:askForGuildBossBattle()
		end
	end, TOUCH_EVENT_ENDED)
	self.play_left:setTexture("")
end

ClsGuildBossUI.showUI = function(self)
	if not self.isOpen then
		local groupBossInfo = self.GuildBossData:getGroupBossInfo()
		if groupBossInfo.status == BossState.BossFighting then
			self:setRemoveUI()
		end
		return
	end
	self:stopAllActions()

	local groupBossInfo = self.GuildBossData:getGroupBossInfo()
	boss_remain_time = groupBossInfo.remainTime

	local isOpen = groupBossInfo.status ~= BossState.BossUnOpen
	if isOpen then
		self.play_right1:setVisible(true)
		self:playLeft1View()
		self:playRight1View()
		self:updateRankUI()
	end
end

ClsGuildBossUI.playLeft1View = function(self)
	local groupBossInfo = self.GuildBossData:getGroupBossInfo()

	local nameStr = groupBossInfo.bossName
	self.name_text:setText(groupBossInfo.bossName)

	local boss_level_conf = require("game_config/boss_level")
	local user_lev = getGameData():getPlayerData():getLevel()
	self.kill_level_num:setText("Lv." .. tostring(boss_level_conf[user_lev].bossLv))
	
	local str_time = dataTools:getTimeStr2(boss_remain_time)
	self.time_num:setText(str_time)
	self.time_num:setVisible(true)
end


ClsGuildBossUI.updateBossHpUI = function(self)
	self:playRight1View()
end

ClsGuildBossUI.playRight1View = function(self)
	if tolua.isnull(self.play_right1) then
		return
	end
	if not tolua.isnull(self.lbl_tips) then
		self.lbl_tips:removeFromParentAndCleanup(true)
		self.lbl_tips = nil
	end
	self.btn_against:setTouchEnabled(true)
	local groupBossInfo = self.GuildBossData:getGroupBossInfo()
	if groupBossInfo.status == BossState.BossReceive then
		self.GuildBossData:setFightCD(nil)
		self.btn_against:setTouchEnabled(false)
		self.against_bg:setVisible(false)
		local pos_battle = self.against_bg:getPosition()
		self.lbl_tips = createBMFont({text = ui_word.STR_GUILD_BOSS_RECEIVE_STATE_TIPS_1,
			fontFile = FONT_CFG_1,color = ccc3(dexToColor3B(COLOR_GREEN)), size = 20, x = pos_battle.x, y = pos_battle.y})
		self.against_bg:getParent():addCCNode(self.lbl_tips)
	end

	--伤害贡献
	self:updatePlayRight2ViewRank()
	self:createUpdateScheduler()


	local btnTips = ""

	if self.GuildBossData:getFightCD() > 0 then
		btnTips = string.format(ui_word.STR_GUILD_BOSS_FIHTING_BTN_TIME_TIPS, dataTools:getMostCnTimeStr(self.GuildBossData:getFightCD()))
		self.btn_against_text:setText(btnTips)
	else
		if groupBossInfo.status == BossState.BossFighting or groupBossInfo.status == BossState.BossUnOpen then
			btnTips = ui_word.STR_GUILD_BOSS_FIHTING_BTN_GO_TIPS --"前往讨伐
		end
		self.btn_against_text:setText(btnTips)
	end

end

ClsGuildBossUI.updatePlayRight2ViewRank = function(self)
	local playerData = getGameData():getPlayerData()
	local attackInfo = self.GuildBossData:getGuildBossRankByUid(playerData:getUid())
	local pointValue = 0
	local rankValue = 0
	if attackInfo then
		pointValue  = attackInfo.point
		rankValue = attackInfo.rank
	end
	self.kill_num:setText(tostring(pointValue))
	self.rank_num:setText(tostring(rankValue))
	self.kill_num:setVisible(true)
	self.rank_num:setVisible(true)

end

ClsGuildBossUI.resetFightCD = function(self)
	Alert:warning({msg = ui_word.PVE_CP_SH_CD})
	-- local ShopRule = require("module/dataHandle/shopRule")
	-- local gold = math.ceil(self.GuildBossData:getFightCD() / 3)
	-- local texts = string.format(ui_word.CAMP_QUICK_COMPLETE, gold)

	-- Alert:showAttention(texts, function()
	--     local playerData = getGameData():getPlayerData()
	--     if gold > playerData:getGold() then
	--         local boss_ui =  getUIManager():get("GuildBossUI")
	--         Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, boss_ui)
	--         return
	--     end
	--     self.GuildBossData:askGuildBossReSetCD()
	-- end)
end

ClsGuildBossUI.updateLabelTime = function(self, value)
	 if not tolua.isnull(self.btn_against_text) then
		value = value or 0
		local timeStr = dataTools:getMostCnTimeStr(value)
		timeStr = string.format(ui_word.STR_GUILD_BOSS_FIHTING_BTN_TIME_TIPS, timeStr)
		
		self.btn_against_text:setText(timeStr)
	end
end

ClsGuildBossUI.removeList = function(self)
	 if not tolua.isnull(self.list) then
		self.list:removeFromParentAndCleanup(true)
		self.list = nil
	end
end

ClsGuildBossUI.progressAction = function(self, progressBar, cur)
	if not tolua.isnull(progressBar) then
		local time = 1.0
		local lastPercent = progressBar:getPercent()
		local runTime = (cur - lastPercent) * time / 100
		local LoadingAction = require("gameobj/LoadingBarAction")
		LoadingAction.new(cur, lastPercent, runTime, progressBar)
	end
end

ClsGuildBossUI.createUpdateScheduler = function(self)
	local groupBossInfo = self.GuildBossData:getGroupBossInfo()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.UpdateHander then
		scheduler:unscheduleScriptEntry(self.UpdateHander)
		self.UpdateItemHander = nil
	end
	local function updateTime(dt)
		local groupBossInfo = self.GuildBossData:getGroupBossInfo()
		if groupBossInfo.status == BossState.BossUnOpen then
			if self.UpdateHander then
				scheduler:unscheduleScriptEntry(self.UpdateHander)
				self.UpdateItemHander = nil
			end
			boss_remain_time = 0
			self:close()
			return
		end
		boss_remain_time = boss_remain_time - 1
		if boss_remain_time <= 0 then
			groupBossInfo.remainTime = 0
			boss_remain_time = 0
			scheduler:unscheduleScriptEntry(self.UpdateHander)
			self.UpdateItemHander = nil
			self:close()
			return
		end
		local stateTips = BossStateTips[groupBossInfo.status]
		self.state_info:setText(stateTips)
		self.state_info:setVisible(true)
		local time = dataTools:getTimeStr2(boss_remain_time)
		self.time_num:setText(time)
		self.time_num:setVisible(true)

	end
	self.UpdateHander = scheduler:scheduleScriptFunc(updateTime, 1, false)
end

ClsGuildBossUI.updateRankUI = function(self)
	self:playLeft2View()
	self:updatePlayRight2ViewRank()
end

ClsGuildBossUI.showRewardView = function(self)
	self:playLeft2View()
end

ClsGuildBossUI.playLeft2View = function(self)

	self.play_right1:setVisible(true)
	--self.play_left2:setVisible(true)
	--listView
	local bgSize = self.play_left2:getContentSize()
	local pos = self.play_left2:getPosition()
	local listCellTab = {}
	local sailorCellTab = {}

	local listData = self.GuildBossData:getGuildBossRank()
	local playRankInfo = nil
	local playerData = getGameData():getPlayerData()

	for k , v in ipairs(listData) do
		if v.uid == playerData:getUid() then
			playRankInfo = table.clone(v)
			playRankInfo.rank = k
		end

		local cellData = {}
		cellData.rank = k
		cellData.data = v
		local listCell = ClsBossRankItem.new(CCSize(440, 36), cellData)
		listCellTab[#listCellTab + 1] = listCell
	end

	pos = self.play_left2:convertToWorldSpace(ccp(0, 0))
	self:removeList()
	local listRect = CCRect(10, 120, 450, 230)
	self.list = ClsScrollView.new(listRect.size.width,listRect.size.height,true,nil,{is_fit_bottom = true})
	self.list:setPosition(listRect.origin)
	self.list:addCells(listCellTab)

	self.play_left2:addChild(self.list)
	self:setSumPointUI()
end

ClsGuildBossUI.setSumPointUI = function(self)
	local cur_sum_point, max_sum_point = self.GuildBossData:getSumPoint()
	self.integral_box_num:setText(cur_sum_point .. "/" .. max_sum_point)
	self.integral_box_num:setVisible(true)
	self.integral_bar:setPercent(cur_sum_point / max_sum_point * 100)
	if cur_sum_point >= max_sum_point then
		self.integral_box_close:changeTexture("box_full4.png", UI_TEX_TYPE_PLIST)
		self.integral_bar:setPercent(100)
	else
		self.integral_box_close:changeTexture("box_closed4.png", UI_TEX_TYPE_PLIST)
	end
end

ClsGuildBossUI.onExit = function(self)
	self.BOSS_bloodline = nil
	self.progress_line = nil
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.UpdateHander then
		scheduler:unscheduleScriptEntry(self.UpdateHander)
		self.UpdateItemHander = nil
	end
	UnLoadPlist(self.resPlist)
end


return ClsGuildBossUI

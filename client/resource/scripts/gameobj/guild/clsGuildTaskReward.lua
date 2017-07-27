--公会任务领奖界面
local ClsDataTools = require("module/dataHandle/dataTools")
local LoadingAction = require("gameobj/LoadingBarAction")
local sailor_info = require("game_config/sailor/sailor_info")
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local music_info=require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local guild_task_team_info = require("game_config/guild/guild_task_team_info")

local ClsBaseView = require("ui/view/clsBaseView")

local ClsGuildTaskReward = class("ClsGuildTaskReward", ClsBaseView)

local HEAD_SCALE = 0.16
local HEAD_SCALE_2 = 0.3



ClsGuildTaskReward.getViewConfig = function(self)
	return {
		is_swallow = true, 
	}
end

ClsGuildTaskReward.onEnter = function(self, data)

	self:initUI()
	self:updateView(data)
	self:initEvents()   
end

ClsGuildTaskReward.onTouch = function(self, event, x, y)

	if event == "began"  then

		self:close()
		local guildTaskData = getGameData():getGuildTaskData()
		guildTaskData:askMissionList()

		return true
	end
end

ClsGuildTaskReward.nTouchCallBack = function()
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:askMissionList()
end
ClsGuildTaskReward.touchCallBack = function()
	local guildTaskData = getGameData():getGuildTaskData()
	guildTaskData:askMissionList()
end

ClsGuildTaskReward.initEvents = function(self)
	self:registerScriptHandler(function(event)
		if event == "exit" then
			UnLoadPlist(self.plist)
		end

	end)

	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) 
	end)

end

ClsGuildTaskReward.updateView = function(self, data)
	self.data = data
	self.config = guild_task_team_info[data.missionId]
	local complete_bg = getConvertChildByName(self.panel, "complete_bg")
	self.m_complete_bg = complete_bg
	
	--任务背景图
	local multi_pic_spr = getConvertChildByName(complete_bg, "multi_pic")
	multi_pic_spr:changeTexture("ui/guild_task_pic/"..self.config.image, UI_TEX_TYPE_LOCAL)

	--任务名字
	local mission_name = getConvertChildByName(multi_pic_spr, "multi_name")
	mission_name:setText(self.config.name)

	--效率
	local efficiency_percent = getConvertChildByName(multi_pic_spr, "efficiency_text")
	efficiency_percent:setText(string.format(ui_word.STR_GUILD_TASK_EFF_TIPS, data.efficien))

	--耗时
	local mission_cost_time = getConvertChildByName(multi_pic_spr, "time_text")
	local time = ClsDataTools:getMostCnTimeStr(data.totalTime)
	mission_cost_time:setText(string.format(ui_word.STR_GUILD_TASK_TIME_TIPS, time))

	--奖励值
	local mission_exp = getConvertChildByName(multi_pic_spr, "exp_num")
	mission_exp:setText(self.data.sailorExp)
	
	--经验水手
	local arr_action = CCArray:create()
	arr_action:addObject(CCDelayTime:create(0.4))
	arr_action:addObject(CCCallFunc:create(function() 
		self:updateSailorExp()
	end))
	self:runAction(CCSequence:create(arr_action))
	
	self:updateMultiRewards()
end

ClsGuildTaskReward.updateSailorExp = function(self)

	local sailorData = getGameData():getSailorData()
	local ownSailors = sailorData:getOwnSailors()

	local captainInfoData = getGameData():getCaptainInfoData()

	local sailor_star_exp = {
		"d_exp",
		"d_exp",
		"c_exp",  
		"b_exp",  
		"a_exp",
		"s_exp",
	}
	
	for i = 1, 3 do
		local sailor_id = self.data.sailors[i]
		local sailor_info_spr = getConvertChildByName(self.m_complete_bg, string.format("sailor_info_%s", i))
		if sailor_id then
			sailor_info_spr:setVisible(true)

			local oldSailor = sailorData:getDataBeforeReward(sailor_id)

			local sailor = ownSailors[sailor_id]
			if sailor then
				
				--头像
				local head = getConvertChildByName(sailor_info_spr, string.format("sailor_head_%s", i))
				head:changeTexture(sailor.res, UI_TEX_TYPE_LOCAL)
				head:setVisible(true)

				head:setScale(1)
				local size = head:getContentSize()
				 head:setScale(50/size.width)
				--等级
				local level = getConvertChildByName(sailor_info_spr, string.format("sailor_lv_%s", i))
				level:setText("Lv." .. oldSailor.level)

				--print(" ========oldSailor.level = %s, oldSailor.exp = %s",oldSailor.level, oldSailor.exp)

				--level up
				local level_up = getConvertChildByName(self.m_complete_bg, string.format("lvl_up_%s", i))
				level_up:setVisible(false)

				local progress = getConvertChildByName(sailor_info_spr, string.format("bar_content_%s", i))
				self.progress = progress

				local sailor_star = sailor_info[sailor_id].level
				
				--print("============sailor_star = %s", sailor_star)
				--原来的当前等级的最大exp
				local nextLevelExp = 1
				nextLevelExp = sailor_exp_info[oldSailor.level + 1] and sailor_exp_info[oldSailor.level + 1][sailor_star_exp[sailor_star]] or sailor_exp_info[oldSailor.level][sailor_star_exp[sailor_star]]

				local origPercent = 100 * (oldSailor.exp / nextLevelExp)
				progress:setPercent(origPercent)

				--加经验后的当前等级的最大exp
				--print(" ========sailor.level = %s, sailor.exp = %s",sailor.level, sailor.exp)
				local curNextLevelExp = 1
				curNextLevelExp = sailor_exp_info[sailor.level + 1] and sailor_exp_info[sailor.level + 1][sailor_star_exp[sailor_star]] or sailor_exp_info[sailor.level][sailor_star_exp[sailor_star]]
				local endPercent = 100 * (sailor.exp / curNextLevelExp)

				local dLevel = sailor.level - oldSailor.level
				local time = 0.3
				if dLevel > 0 then
					local arr = CCArray:create()
					for i =1, dLevel do
						arr:addObject(CCCallFunc:create(function()
							self:progressAction(progress, 100, time)
							audioExt.playEffect(music_info.NAVIGATOR_EXP_UP.res)
						end))
						arr:addObject(CCDelayTime:create(time))
						arr:addObject(CCCallFunc:create(function()
							level_up:setVisible(true)
							progress:setPercent(0)
						end))
					end

					arr:addObject(CCCallFunc:create(function()

						self:progressAction(progress, endPercent, time)
						--level up
						level:setText("Lv." .. sailor.level)

						sailorData:clearDataAfterReward(sailor_id)
					end))

					local endSeq = CCSequence:create(arr)
					progress:runAction(endSeq)
				else
					self:progressAction(progress, endPercent, time)
					sailorData:clearDataAfterReward(sailor_id)
				end
			end
		else
			sailor_info_spr = false
		end
	end
end

ClsGuildTaskReward.updateMultiRewards = function(self)
	local no_reward = getConvertChildByName(self.m_complete_bg, "no_reward")
	no_reward:setVisible(#self.data.rewards < 1)

	local reward_bg_spr = getConvertChildByName(self.m_complete_bg, "reward_bg")
	local reward_pos_panel = getConvertChildByName(self.m_complete_bg, "reward_pos_panel")
	reward_bg_spr:setVisible(true)
	
	if #self.data.rewards < 3 then
		reward_pos_panel:setPosition(ccp(60, 0))
	end

	for i = 1, 3 do
		local reward_info = self.data.rewards[i]
		local reward_item_ui = getConvertChildByName(reward_bg_spr, "reward_bg_"..i)
		local icon_spr = getConvertChildByName(reward_item_ui, "reward_pic_"..i)
		local num_lab = getConvertChildByName(reward_item_ui, "reward_num_"..i)
		if reward_info then
			reward_item_ui:setVisible(true)
			local icoStr, amount, scale_n =  getCommonRewardIcon(reward_info)
			icon_spr:changeTexture(convertResources(icoStr), UI_TEX_TYPE_PLIST)
			autoScaleWithLength(icon_spr, 45)
			num_lab:setText("X" .. amount)
		else
			reward_item_ui:setVisible(false)
		end
	end
end

ClsGuildTaskReward.progressAction = function(self, progressBar, cur, time)
	if not tolua.isnull(progressBar) then
		local lastPercent = progressBar:getPercent()
		local runTime = (cur - lastPercent) * time / 100
		
		LoadingAction.new(cur, lastPercent, runTime, progressBar)
	end
end

ClsGuildTaskReward.initUI = function(self)
	self.plist = {
		["ui/baowu.plist"] = 1,
	}
	LoadPlist(self.plist)

	local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_task_multi_complete.json")
	self:addWidget(panel)
	self.panel = panel

end

return ClsGuildTaskReward

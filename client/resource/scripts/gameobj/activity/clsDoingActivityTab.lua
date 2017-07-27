-- 正在活动界面
-- Author: Ltian
-- Date: 2016-07-01 10:07:17
local ClsDynSwitchView = require("ui/tools/DynSwitchView")
local ui_word = require("game_config/ui_word")
local relic_info = require("game_config/collect/relic_info")
local scheduler = CCDirector:sharedDirector():getScheduler()
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local alert = require("ui/tools/alert")
local composite_effect = require("gameobj/composite_effect")
local activityUtils = require("gameobj/activity/activityUtils")
local ClsBaseView = require("ui/view/clsBaseView")
local music_info = require("scripts/game_config/music_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local clsDoingActivityItem = class("clsDoingActivityItem", function() return UIWidget:create() end)

local STATUS_CLOSE = 0
local STATUS_OPEN = 1
-- 即将开放的活动
local STATUS_NO_ACTIVITY = 2
local STATUS_END = 3
local STATUS_SOON = 4

local SHOW_TIMES = 1
local ARENA_ACTIVITY = 2
local WANT_TEAM_ACTIVITY = 17
local JINGSHANG_ACTIVITY = 15

local TREASURE_ID = 80 ---藏宝图id
local TREASURE_VIP_ID = 164 ---高级藏宝图id

-- 可以在 activity 表中加字段. 活动开放等级 暂时在客户端特殊处理
-- local IS_MEET_LEVEL = {
-- 	[1] = { ["level"] = 25, ["id"] = 8 }, -- 据点战
-- 	-- [2] = { ["level"] = 20, ["id"] = 19 }, -- 深渊乱斗
-- 	[2] = { ["level"] = 20, ["id"] = 6 }, -- 商会战场
-- }

--可以购买次数的活动id
local can_buy_times_activity = {
	[ARENA_ACTIVITY] = true,
	[WANT_TEAM_ACTIVITY] = true,
	[JINGSHANG_ACTIVITY] = true,
}

local widget_name = {
	"open_item",
	"activity_icon",
	"activity_name",
	-- "activity_time",
	"activity_finished",
	"award_icon_1",
	"award_icon_2",
	"award_icon_3",
	-- "award_icon_4",
	"activity_num",
	"btn_go",
	-- "start_time",
	-- "end_time",
	-- "activity_all_day",
	"activity_award",
	-- "activity_team",
	"btn_buy_text",
	"btn_go_text",
	-- "single_pic",
	"team_pic",
	"cost_power",
	"power_icon",
}

local ARENA_OPEN = 0
local ARENA_COMPLETED = 1
local ARENA_COMPLETED_AND_GET_REWARD = 2

function clsDoingActivityItem:ctor(data)
	self.data = data
	self:mkUI()
	self:regFunc()
end


function clsDoingActivityItem:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_open.json")
	convertUIType(self.panel)
	self:addChild(self.panel)
	local activity_main_ui = getUIManager():get("ClsActivityMain")
	-- if(activity_main_ui)then self.touch_priority = activity_main_ui:getTouchPriority()end
	-- self:setTouchPriority((self.touch_priority or 0) - 5)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:updateView()

	self.btn_go:setPressedActionEnabled(true)
	self.btn_go:addEventListener(function()

		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if getGameData():getTeamData():isLock(true) then return end

		if getGameData():getPlayerData():getLevel() < self.data.level_limit then
			alert:warning({msg = string.format(ui_word.ACTIVITY_LEVEL_LIMIT,self.data.level_limit), size = 26})
			return
		end

		self:onBtnGoClicked()
		self:checkRemoveNewOpenEffect()

	end, TOUCH_EVENT_ENDED)

	if getGameData():getTeamData():isLock() then
		self.btn_go:disable()
	end
end

function clsDoingActivityItem:onBtnGoClicked()
	if isExplore then
		-- 如果在海上则根据标记判断是否回港
		if getGameData():getTeamData():isLock(true) then
			return
		end
		if self.data.explore_skip == 1 then
			-- 如果需要回港
			local port_info = require("game_config/port/port_info")
			local portData = getGameData():getPortData()
			local portName = port_info[portData:getPortId()].name
			local tips = require("game_config/tips")
			local str = string.format(tips[77].msg, portName)
			alert:showAttention(str, function()
				portData:askBackEnterPort()
			end, nil, nil, {hide_cancel_btn = true})
		else
			-- 如果不需要回港，则转到对应界面
			self:gotoMission()
		end
	else
		self:gotoMission()
	end
end

function clsDoingActivityItem:handleEndStatus()
	-- self.start_time:setVisible(true)
	self.activity_finished:setVisible(true)
	-- self.activity_time:setText(self.data.time_announce)
	self:showNextOpenTime()
	self:setGray(true)
end

function clsDoingActivityItem:handleCloseStatus()
	if self.data.doing_status.start_remain_time > 0 then
		-- self.start_time:setVisible(true)
		self.remain_time = self.data.doing_status.start_remain_time

		local start_time = self.data.doing_status.start_time
		local end_time = self.data.doing_status.end_time
		if start_time and end_time then
			local startTime = ClsDataTools:getTimeStrNormal(start_time, false, true)
			local endTime = ClsDataTools:getTimeStrNormal(end_time, false, true)
			-- self.activity_time:setText(string.format("%s~%s", startTime, endTime))
		end
		-- self.timer = scheduler:scheduleScriptFunc(function()
		-- 	self:toOpenActivity()
		-- end, 1, false)

		self:checkCanBuyOrGray()

	end
end

--检测是否置灰或者显示购买次数按钮
function clsDoingActivityItem:checkCanBuyOrGray()
	if self.data.times_show == SHOW_TIMES and self.data.doing_status.times <= 0 then
		if can_buy_times_activity[self.data.id] then
			self.btn_buy_text:setVisible(true)
			self.btn_go_text:setVisible(false)
		else
			self.btn_go:setVisible(false)
			self:setGray(true)
		end
	end
end

function clsDoingActivityItem:setGray(bGray)
	local imgs = {"award_icon_1" , "award_icon_2" , "award_icon_3" , "activity_icon" , "team_pic", "power_icon"}
	for __ , name in ipairs(imgs) do
		self[name]:setGray(bGray)
	end

	local texts = {"activity_name"}
	for __ , name in ipairs(texts) do
		setUILabelColor(self[name] , ccc3(dexToColor3B(COLOR_GREY_STROKE)))
	end
end


--检测添加特效
function clsDoingActivityItem:checkShowEffect()
	local LIMIT_TIME = 2
	local no_effect_activity = {
		[ARENA_ACTIVITY] = true,
	}

	local effect_id = nil
	if getGameData():getActivityData():isNewOpenActivity(self.data.id) then
		effect_id = "tx_huodong_kaiqi"
	elseif self.data.doing_status.status == STATUS_OPEN and not (self.data.times_show > 0 and self.data.doing_status.times == 0) then
	--当前状态是开启的或者是新活动

		if not no_effect_activity[self.data.id] and self.data.type == LIMIT_TIME then
			effect_id = "tx_0189"
		end
	end

	if effect_id then
		self:addShowEffect(effect_id)
	else
		self:removeShowEffect()
	end
end

--检测是否要移除新手特效
function clsDoingActivityItem:checkRemoveNewOpenEffect()
	if getGameData():getActivityData():isNewOpenActivity(self.data.id) then
		getGameData():getActivityData():changeNewActivity(self.data.id) --修改新活动状态
		self:checkShowEffect() --重新检查下活动特效该怎么显示
	end
end

--添加特效
function clsDoingActivityItem:addShowEffect(effect_id)
	self:removeShowEffect()--清除之前的特效
	if tolua.isnull(self.activity_effect) then
		self.activity_effect = composite_effect.new(effect_id, 177, 63, self, nil, nil, nil, nil, true)
	end
end
--清除特效
function clsDoingActivityItem:removeShowEffect()
	if not tolua.isnull(self.activity_effect) then
		self.activity_effect:removeFromParentAndCleanup(true)
		self.activity_effect = nil
	end
end

function clsDoingActivityItem:handleOpenStatus()
	if self.data.doing_status.remain_time > 0 then
		self.btn_go:setVisible(true)
		-- self.end_time:setVisible(true)
		self.remain_time = self.data.doing_status.remain_time
		-- self.activity_time:setText(ClsDataTools:getTimeStrNormal(self.remain_time))

		self:checkCanBuyOrGray()

		self.timer = scheduler:scheduleScriptFunc(function()
			self:freashUI()
		end, 1, false)
	else
		self.btn_go:setVisible(true)
		-- self.activity_time:setVisible(false)
		-- self.activity_all_day:setVisible(true)
		-- self.activity_all_day:setText(self.data.time_announce)
		--todo 这里有次数服务端发错的问题（等于0） 先容错，没问题了再改
		self:checkCanBuyOrGray()
	end
	-- 据点战前往按钮的等级限制(大于等于20级可见)

	-- 开放等级表处理
	-- for k,v in pairs(IS_MEET_LEVEL) do
	if getGameData():getPlayerData():getLevel() < self.data.level_limit then
		self.btn_go:setVisible(false)
		self.btn_go_text:setVisible(false)
	end
	-- end

	--体力要跟前往按钮同显隐
	self.cost_power:setVisible(self.data.cost_power > 0 and self.btn_go:isVisible())
	self.power_icon:setVisible(self.data.cost_power > 0 and self.btn_go:isVisible())
end

local event_by_status = {
	[STATUS_CLOSE] = clsDoingActivityItem.handleCloseStatus,
	[STATUS_OPEN] = clsDoingActivityItem.handleOpenStatus,
	[STATUS_END] = clsDoingActivityItem.handleEndStatus,
	[STATUS_SOON] = clsDoingActivityItem.handleCloseStatus,
}

local TEAM_ACTIVITY = 2
local SINGLE_ACTIVITY = 1
local activity_type_word = {
	[TEAM_ACTIVITY] = ui_word.ACTIVITY_TEAM,
	[SINGLE_ACTIVITY] = ui_word.ACTIVITY_SINGLE,
}

function clsDoingActivityItem:showNextOpenTime()
	if self.data.doing_status and self.data.doing_status.status == STATUS_END then --最后一个任务了,结束了
		local start_time = self.data.open_time
		if start_time and #start_time > 1 and #self.data.week_day == 0 then
			-- self.activity_time:setText(ui_word.ACTIVITY_TOMORROW_START .. ClsDataTools:getTimeStrNormal(start_time[1],false,true))
		else
			-- self.activity_time:setText(self.data.time_announce)
		end
	else
		-- self.activity_time:setText(self.data.time_announce)
	end
end

function clsDoingActivityItem:updateView()

	-- self.start_time:setVisible(false)
	-- self.end_time:setVisible(false)
	self.btn_go:setVisible(false)

	self.activity_num:setVisible(false)
	-- self.activity_team:setVisible(false)
	self.activity_icon:changeTexture(self.data.activity_icon, UI_TEX_TYPE_PLIST)
	self.activity_name:setText(self.data.name)
	self.cost_power:setText(tostring(self.data.cost_power))
    local player_data = getGameData():getPlayerData()
    if(player_data:getPower() < self.data.cost_power)then
        setUILabelColor(self.cost_power, ccc3(dexToColor3B(COLOR_RED)))
    end

	-- self.activity_time:setColor(ccc3(dexToColor3B(COLOR_RED)))
	for i=1,3 do
		self[string.format("award_icon_%d",i)]:setVisible(false)
	end
	for i,v in ipairs(self.data.activity_reward) do
		if i >=3 then break end -- 去掉 award_icon_4
		self["award_icon_"..i]:setVisible(true)
		self["award_icon_"..i]:changeTexture(v, UI_TEX_TYPE_PLIST)
	end
	--暂时容错，活动还没有做出来
	if not self.data.doing_status then
		-- self.activity_time:setText(self.data.time_announce)
		return
	end

	event_by_status[self.data.doing_status.status](self)

	if self.data.times_show == SHOW_TIMES then
		self.activity_num:setVisible(true)
		local time_str = activityUtils:getActivityCycleStr(self.data.activity_cycle,self.data.doing_status.times,self.data.doing_status.all_times)

		-- 如果有活动次数参数,并且次数为0 该项变灰
		if self.data.doing_status.times == 0 then
			self:setGray(true)
			self.btn_go_text:setText(ui_word.REWARD_FINISH)
		end

		self.activity_num:setText(time_str)

		local ACTIVITY_ID_AUTO_TRADE = 15
		if self.data.id == ACTIVITY_ID_AUTO_TRADE then
			self.activity_num:setText(string.format(ui_word.ACTIVITY_TIMES_1,self.data.doing_status.times))
		end

	end


	
	if self.data.skip_info[1] == "arena" then
		--table.print(self.data)
		local activity_arena_status = ARENA_OPEN
		if self.data.doing_status.is_completed == 0 then --未完成
			activity_arena_status = ARENA_OPEN
		elseif self.data.doing_status.is_completed == 1 then --完成了
			if self.data.doing_status.has_reward == 1  then  --未领奖
				activity_arena_status = ARENA_COMPLETED
			else  --领奖了
				activity_arena_status = ARENA_COMPLETED_AND_GET_REWARD
			end
		end
		
		if activity_arena_status == ARENA_COMPLETED then -- 完成未领奖
			self.btn_go_text:setText(ui_word.CAMP_GET_REWARD)
		elseif activity_arena_status == ARENA_COMPLETED_AND_GET_REWARD then  --完成,领奖了
			self:setGray(true)
			self.btn_go:setVisible(false)
		end
	end

	if self.data.skip_info[1] == "world_mission" then
		local status = getGameData():getWorldMissionData():isNewWorldMissionExit()
		if not status then
			self:setGray(true)
			self.btn_go:setVisible(false)
			
		end
	end

	if activity_type_word[self.data.team_or_single] then
		if self.data.doing_status.status ~= STATUS_END then
			self:setTeamOrSingle(self.data.team_or_single)
		end
	else
		-- self.activity_team:setVisible(true)
		-- local battleData = getGameData():getBattleData()
		-- if battleData:isUntilFight() then
		-- 	self:setTeamOrSingle(SINGLE_ACTIVITY)
		-- else
		-- 	self:setTeamOrSingle(TEAM_ACTIVITY)
		-- end

		-- 改为都是单人前往,无组队.
		self:setTeamOrSingle(SINGLE_ACTIVITY)
	end

	
	self:checkShowEffect()--检查特效
end

function clsDoingActivityItem:setTeamOrSingle(var)
	-- self.single_pic:setVisible(var == SINGLE_ACTIVITY)
	self.team_pic:setVisible(var == TEAM_ACTIVITY)
end

--开放时间到，请求服务端刷新数据
function clsDoingActivityItem:toOpenActivity()
	local activity_info = getGameData():getActivityData():getActivityById(self.data.id)
	if activity_info then
		local remain_time = activity_info.remain_time
		if remain_time < 0 then
			self:unscheduleTimer()
			local activity_data = getGameData():getActivityData()
			activity_data:requestActivityInfo()
		-- else
		-- 	self.remain_time = self.remain_time - 1
		end
	end
end

function clsDoingActivityItem:freashUI()
	local activity_info = getGameData():getActivityData():getActivityById(self.data.id)

	if activity_info then
		local remain_time = activity_info.remain_time
		if remain_time <= 0 then
			self:unscheduleTimer()
			local activity_data = getGameData():getActivityData()
			activity_data:requestActivityInfo()
		else
			-- self.activity_time:setText(ClsDataTools:getTimeStrNormal(remain_time))
			-- self.remain_time = self.remain_time - 1
		end
	end
end

function clsDoingActivityItem:unscheduleTimer()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

function clsDoingActivityItem:setTouch(enable)
	-- if not tolua.isnull(self.btn_go) then
	-- 	self.btn_go:setTouchEnabled(enable)
	-- end
end

function clsDoingActivityItem:showTip()
	local tip_layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/activity_tips.json")
	local title_label = getConvertChildByName(panel, "title")
	local rule_info_label = getConvertChildByName(panel, "rule_info")
	local start_info_label = getConvertChildByName(panel, "start_info")

	title_label:setText(self.data.name)
	start_info_label:setText(self.data.time_all)
	rule_info_label:setText(self.data.activity_desc)
	convertUIType(panel)
	tip_layer:addChild(panel)

	getUIManager():create("ui/view/clsBaseTipsView", nil, "DoingActivityTip", {is_back_bg = false}, tip_layer, true)
end

function clsDoingActivityItem:gotoMission()
	local del_activity_panel_skip = {
		["team_treasure"] = true,
		["team_market"] = true,
		["team_haishen"] = true,
		["team_wanted"] = true,
		["arena"] = true,
	}
	local down_in_up_out_activty = {
		["team_plunder_trade"] = true,
		-- ["everyday_race"] = true,
		["fight"] = true,
	}

	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local layer_name = self.data.skip_info[1]
	local main_tab = getUIManager():get("ClsActivityMain")
	if not tolua.isnull(main_tab) then
		-- main_tab:setTouch(false)
	end

	if del_activity_panel_skip[layer_name] then
		local layer = missionSkipLayer:skipLayerByName(layer_name)
		if not tolua.isnull(main_tab) then
			main_tab:destroy()
			main_tab = nil
		end
		return
	end

	if down_in_up_out_activty[layer_name] then
		local layer = missionSkipLayer:skipLayerByName(layer_name)
		-- main_tab:setTouch(true) --临时处理。。。
		return
	end
	if layer_name == "ports" then
		if isExplore then
			if not tolua.isnull(main_tab) then
				main_tab:destroy()
				main_tab = nil
			end
			alert:warning({msg = ui_word.LEGACY_EXPLORE, size = 26})
		else
			local mapAttrs = getGameData():getWorldMapAttrsData()
			local portData = getGameData():getPortData()
			local port_id = portData:getPortId() -- 当前港口id
			mapAttrs:goOutPort(port_id, EXPLORE_NAV_TYPE_NONE, function()
			end, function()
				if tolua.isnull(self) then return end
				if not tolua.isnull(main_tab) then
					main_tab:setTouch(true)
				end
			end)
		end
	elseif layer_name == "team_seven" then
		if not tolua.isnull(main_tab) then
			-- main_tab:setTouch(true)
		end

		-- 默认港口为伦敦
		local port_id = 20
		local guild_info_data = getGameData():getGuildInfoData()
		local guild_id = guild_info_data:getGuildId()
		local port_data = getGameData():getPortData()

		if guild_info_data:hasGuild() then
			local guild_info_data = getGameData():getGuildInfoData()
			local guild_port_id = guild_info_data:getGuildPortId()
			if tonumber(guild_port_id) > 0 then
				port_id = guild_port_id
			end
		end
		local local_port_id = port_data:getPortId()
		-- todo 应急处理，稍后优化
		if not isExplore then
			if local_port_id == port_id then
				local layer = missionSkipLayer:skipLayerByName(layer_name)
				if not tolua.isnull(main_tab) then
					main_tab:destroy()
					main_tab = nil
				end
				local teamData = getGameData():getTeamData()
				if teamData:isInTeam() then
					teamData:setTeamType(8)
					teamData:askChangeTeamType()
				end
				return
			end
		end

		local str = ui_word.GOTO_TARGER_PORT
		if getGameData():getPlayerData():getLevel() >= 23 then --写死的...
			-- 组队界面一定要在港口界面打开
			alert:showAttention(str, function()
				getGameData():getPortData():saveBattleEndLayer("team_seven_sea")
				getGameData():getWorldMapAttrsData():tryToEnterPort(port_id)
			end, nil, nil, {hide_cancel_btn = true})
		end

	elseif layer_name =="reward" then
		EventTrigger(EVENT_MAIN_SELECT_LAYER, TYPE_LAYER_PORT)
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsLoginAwardUIQuene = require("gameobj/quene/clsLoginAwardUIQuene")
        DialogQuene:insertTaskToQuene(clsLoginAwardUIQuene.new({func = function() EventTrigger(EVENT_DEL_PORT_ITEM) end}))
	elseif layer_name == "arena" then
		getUIManager():create("gameobj/arena/clsArenaMainUI")
	elseif layer_name == "town" then
		-- 关闭主界面
		getUIManager():get("ClsActivityMain"):close()
		-- 等后续Ui框架优化,现在先这么处理
		-- 尝试获取
		local target_ui = getUIManager():get('clsPortTownUI')
		-- 如果不为空
		if not tolua.isnull(target_ui) then
			-- 先移除
			getUIManager():get("clsPortTownUI"):close()
		end
		-- 再添加
		getUIManager():create('gameobj/port/clsPortTownUI',nil,1)
	elseif layer_name == "guild_treasure" then
		if not tolua.isnull(main_tab) then
			self:tryOpenBayUI(main_tab)
		end
	elseif layer_name == "treasure_map" then
		if not tolua.isnull(main_tab) then
			self:tryOpenTreasureMapUI(main_tab)
		end
	elseif layer_name == "team_haishen" then
		local main_panel = getUIManager():get("ClsActivityMain")
		if not tolua.isnull(main_panel) then
			main_panel:close()
		end
		local portLayer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(portLayer) then
			local layer = missionSkipLayer:skipLayerByName(layer_name)
		end
	elseif layer_name == "team_far_arena" then
		local main_panel = getUIManager():get("ClsActivityMain")
		if not tolua.isnull(main_panel) then
			main_panel:close()
		end
		local layer = missionSkipLayer:skipLayerByName(layer_name)
	elseif layer_name == "auto_trade" then
		local layer = missionSkipLayer:skipLayerByName(layer_name)
	elseif layer_name == "guild_stronghold_fire" then
		local guild_info_data = getGameData():getGuildInfoData()
		local guild_id = guild_info_data:getGuildId()
		if guild_info_data:hasGuild() then
			local layer = missionSkipLayer:skipLayerByName(layer_name)
			return
		end
		alert:warning({msg = ui_word.NO_INJION_SHANGHUI})
	elseif layer_name == "relic" then
		if not tolua.isnull(main_tab) then
			-- main_tab:setTouch(true)
		end
		local is_explore = getGameData():getSceneDataHandler():isInExplore()

		local collect_data = getGameData():getCollectData()
		local relic_id = collect_data:findNavigateRelicID(is_explore)
		local mapAttrs = getGameData():getWorldMapAttrsData()
		local supply_data = getGameData():getSupplyData()
		local explore_data = getGameData():getExploreData()
		if not is_explore then
			if not relic_id then
				collect_data:askAdviseRelic()
				return
			end

			local exploreData = getGameData():getExploreData()
			exploreData:addEnterExploreCallBack({call = function()
				collect_data:askAdviseRelic()
			end, is_reamin = false})

			supply_data:askSupplyInfo(true, function()
				mapAttrs:goOutPort(relic_id, EXPLORE_NAV_TYPE_RELIC)
			end)
		else
			if relic_id then
				collect_data:askAdviseRelic()
				local goal_info = {id = relic_id,navType = EXPLORE_NAV_TYPE_RELIC}
    			EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, goal_info)
    		else
				collect_data:askAdviseRelic()
			end
			if not tolua.isnull(main_tab) then
				main_tab:destroy()
				main_tab = nil
			end
			
		end
	elseif layer_name == "mineral_point" then
		local my_guild_port_id = getGameData():getGuildInfoData():getGuildPortId()
		if not my_guild_port_id or my_guild_port_id == 0 then
			if not tolua.isnull(main_tab) then
				-- main_tab:setTouch(true)
			end
			return
		end

		if isExplore then
			--提示回港
		    alert:showAttention(ui_word.STR_GO_GUILD_PORT_TIPS, function()
		    	local mapAttrs = getGameData():getWorldMapAttrsData()
		    	mapAttrs:tryToEnterPort(my_guild_port_id)
		    	getGameData():getPortData():setEnterPortCallBack(function()
		    		if not tolua.isnull(main_tab) then
						main_tab:destroy()
						main_tab = nil
		    		end
		    		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
		    		return missionSkipLayer:skipLayerByName("activity")
		    	end)
		    end, function()
			    	if not tolua.isnull(main_tab) then
			    		-- main_tab:setTouch(true)
			    	end
		    	end)
		    return
		end

		local cur_port_id = getGameData():getPortData():getPortId()
		if cur_port_id == my_guild_port_id then
			local buff_state_data = getGameData():getBuffStateData()
	        local contend_status_info = buff_state_data:getBuffStateByStatusId("contend_status")
	        if not contend_status_info then
	            getGameData():getAreaCompetitionData():askTryJoinMineral()
	        else
	        	local layer = missionSkipLayer:skipLayerByName("team_mineral_point")
	        end
	     	return
	    end
	    --提示回港
	    alert:showAttention(ui_word.STR_GO_GUILD_PORT_TIPS, function()
	    	local mapAttrs = getGameData():getWorldMapAttrsData()
	    	mapAttrs:tryToEnterPort(my_guild_port_id)
	    	getGameData():getPortData():setEnterPortCallBack(function()
	    		if not tolua.isnull(main_tab) then
					main_tab:destroy()
					main_tab = nil
	    		end
	    		local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	    		return missionSkipLayer:skipLayerByName("activity")
	    	end)
	    end, function() if not tolua.isnull(main_tab) then main_tab:setTouch(true) end end)
	elseif  layer_name == "shipyard_shop" then

		-- local boatData = getGameData():getBoatData()
		-- local is_open = boatData:getBlackShopIsOpen()
		-- local is_black_shop_open = boatData:getAllBlackShopStatus()
		-- if is_black_shop_open == 1 and not is_open then
			local news_info = require("game_config/news")
			alert:warning({msg = news_info.ACTIVITY_BLACK_MARKET.msg, size = 26})
		-- 	if not tolua.isnull(main_tab) then
		-- 		-- main_tab:setTouch(true)
		-- 	end
			return
		-- end
		-- local layer = missionSkipLayer:skipLayerByName(layer_name)

	else
		local layer = missionSkipLayer:skipLayerByName(layer_name)
	end
end

function clsDoingActivityItem:tryOpenTreasureMapUI(main_tab)
	local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
	local propDataHandle = getGameData():getPropDataHandler()
	local treasure_info = propDataHandle:getTreasureInfo()
	-- print(' ---------- treasure_info ')
	-- table.print(treasure_info)

	if treasure_info and treasure_info.treasure_id ~= 0 then
		missionSkipLayer:skipLayerByName("treasure_map")
	else
		local have_num = 0
		local item_id = TREASURE_ID

		local item = propDataHandle:hasPropItem(TREASURE_ID)
		if item then
			have_num = item.count
		end
		if have_num == 0 then
			item = propDataHandle:hasPropItem(TREASURE_VIP_ID)
			if item then
				have_num = item.count
				item_id = TREASURE_VIP_ID
			end
		end

		if have_num > 0 then
			local function ok_call_back_func()
				propDataHandle:askTreasureUse(item_id)
			end
			local function close_call_back_func()
			end
			alert:showAttention(ui_word.TREASUREMAP_ITEM_TIPS, ok_call_back_func, close_call_back_func, nil, {name_str = "ClsTreasureMapConfirm", need_check_guide = true})
		else
			if isExplore then
				alert:warning({msg = ui_word.TREASURE_MAP_TIPS_LBL})
			else
				alert:showJumpWindow(CANGBAOTU_NOT_ENOUGH)
			end
		end
	end
end

function clsDoingActivityItem:tryOpenBayUI(main_tab)
	local team_data = getGameData():getTeamData()
	local team_info = team_data:getMyTeamInfo().info

	local MAX_MEMBER = 3 --满员是3个人
	--玩家身为队长并且组队满3人才可以发出邀请协议
	if self.data.doing_status.times <= 0 then
		-- main_tab:setTouch(true)
		alert:warning({msg = ui_word.STR_COPY_SCENE_NO_FREQUENCY, size = 26})
		return
	end

	if team_data:isTeamLeader() and #team_info == MAX_MEMBER then
		local bay_data = getGameData():getBayData()
		bay_data:sendTeamAsk()
		return
	end

	-- getUIManager():create("gameobj/team/portTeamUI", nil, 2, 1, nil, nil, true)
end

function clsDoingActivityItem:regFunc()
	-- self:registerScriptHandler(function(event)
	-- 	if event == "exit" then self:onExit() end
	-- end)
end


local clsDoingActivityCell = class("clsDoingActivityCell", ClsScrollViewItem)
function clsDoingActivityCell:clearTimer()
	if self.items then
		for i,v in ipairs(self.items) do
			v:unscheduleTimer()
		end
	end
end

function clsDoingActivityCell:initUI(cell_date)
	self.data = cell_date
	self.items = {}
	self:mkUi()
end

function clsDoingActivityCell:mkUi()
	local offset_X = 380
	for i,v in ipairs(self.data) do
		self.items[i] = clsDoingActivityItem.new(v)
		self.items[i]:setPosition(ccp(offset_X * (i -1 ),10))
		-- self.items[i]:setPositionY(10)
		self:addChild(self.items[i])
	end
	ClsGuideMgr:tryGuide("ClsActivityMain")
end

function clsDoingActivityCell:onTap(x, y)
	local pos = self:getWorldPosition()
	-- local pos = ccp(x,y)
	local click_item = nil
	if x < 545 and pos.y >10 then
		click_item = self.items[1]
	elseif x > 565 and pos.y >10 then
		click_item = self.items[2]
	end
	if not tolua.isnull(click_item) then
		click_item:showTip()
		click_item:checkRemoveNewOpenEffect()
	end
end

function clsDoingActivityCell:setTouch(enable)
	-- if type(self.items) == "table" then
	-- 	for i,v in ipairs(self.items) do
	-- 		v:setTouch(enable)
	-- 	end
	-- end
end

local clsDoingActivityTab = class("clsDoingActivityTab", function() return UIWidget:create() end)

function clsDoingActivityTab:ctor()
	self.is_enable = true
	self:askData()
	self:mkUI()

	self.node = display.newNode()
	self:addCCNode(self.node)
	self.node:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)

	getUIManager():get("ClsActivityMain"):regChild("clsDoingActivityTab",self)
end

function clsDoingActivityTab:askData()
	local activity_data = getGameData():getActivityData()
	activity_data:requestActivityInfo()
end

function clsDoingActivityTab:mkUI()
	-- self:updateView() --等协议过来再添加
end

function clsDoingActivityTab:getGuideInfo(condition)
	if tolua.isnull(self.list_view) then return end
	local parent_ui = self.list_view:getInnerLayer()
	local activity_guide_id = condition.aid
	for k, cell in ipairs(self.cells) do
		for index, info in pairs(cell.data or {}) do
			if info.id == activity_guide_id then
				local world_pos = cell:convertToWorldSpace(ccp(294 + (index - 1)*382, 45))
				local parent_pos = parent_ui:convertToWorldSpace(ccp(0,0))
				local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
				return parent_ui, guide_node_pos, {['w'] = 90, ['h'] = 33}
			end
		end
	end
end

function clsDoingActivityTab:updateView()
	local activity_data = getGameData():getActivityData()
	self.activity_list = activity_data:getActivityList()
	if not self.activity_list then return end

	local doing_activity = activity_data:getDoingActivity()
	self:cleanListView()

	self.cells = {}


	if #doing_activity < 1 then return end
	for i,v in ipairs(doing_activity) do
		v.doing_status = self.activity_list[v.id]
	end

	local _rect = CCRect(195, 30, 747, 457)
	local cell_size = CCSize(740, 135)
	if not self.list_view then
		self.list_view = ClsScrollView.new(747,457,true,nil,{is_fit_bottom = true})
		self.list_view:setPosition(ccp(195,30))
		-- self:addWidget(self.list_view)
		self:addChild(self.list_view)
	end
	-- self.list_view = ClsDynSwitchView.new({rect = _rect, direct = 2, isButton = false, priority = self.touch_priority})
	-- self.list_view:setTouchEnabled(true)
	local activity_list = self:sortActivity(doing_activity)
	local raw = 2		--一列放2个cell
	local toalCol = math.ceil((#activity_list)/raw) --cell的总数
	for i=1,toalCol do
		local data = {}
		for j=1,2 do
			local index = (i - 1) * raw + j
			if activity_list[index] then
				table.insert(data, activity_list[index])
			end
		end
		self.cells[i] = clsDoingActivityCell.new(cell_size, data)
		self.list_view:addCell(self.cells[i])
	end
	self.getGuideObj = function(condition)
		return self:getGuideInfo(condition)
	end
	-- self:setTouch(self.is_enable)
end

--客户端判断变灰放后面
function checkLocalJudge(activity)
	if activity.skip_info[1] == "arena" then
		local activity_arena_status = ARENA_OPEN
		if activity.doing_status.is_completed == 0 then --未完成
			activity_arena_status = ARENA_OPEN
		elseif activity.doing_status.is_completed == 1 then --完成了
			if activity.doing_status.has_reward == 1  then  --未领奖
				activity_arena_status = ARENA_COMPLETED
			else  --领奖了
				activity_arena_status = ARENA_COMPLETED_AND_GET_REWARD
			end
		end
		
		if activity_arena_status == 2 then  --完成,领奖了
			return true
		end
	
	elseif activity.skip_info[1] == "world_mission" then
		local status = getGameData():getWorldMissionData():isNewWorldMissionExit()
		if not status then
			return true
		end
	elseif activity.skip_info[1] == "auto_trade" or 
			activity.skip_info[1] == "team_treasure" or 
			activity.skip_info[1] == "team_haishen" then
		
		if activity.doing_status.times == 0 then
			return true
		end		
	end
end

function clsDoingActivityTab:sortActivity(activity_list)

	local show_list = {}
	local gray_list = {}
	for k,v in pairs(activity_list) do
		if not checkLocalJudge(v) then
			show_list[#show_list + 1] = v
		else
			gray_list[#gray_list + 1] = v
		end
	end
	
	table.sort(show_list,function (a, b)
		return a.unlock_order < b.unlock_order
	end)

	for i,v in ipairs(gray_list) do
		show_list[#show_list + 1] = v
	end
	
	local new_list = {}
	for k,v in ipairs(show_list) do
		local status = getGameData():getOnOffData():isOpen(on_off_info[v.switch].value)
		if status then
			new_list[#new_list+1] = v
		end
	end
	for i,v in ipairs(new_list) do
		-- print(i,v.unlock_order)
	end
	return new_list
end

function clsDoingActivityTab:setTouch(enable)
end

function clsDoingActivityTab:cleanListView()
	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
		self.cells = {}
	end
end

function clsDoingActivityTab:preClose()
	self:cleanListView()
end

function clsDoingActivityTab:onExit()
	getUIManager():get("ClsActivityMain"):unRegChild("clsDoingActivityTab")
end

return clsDoingActivityTab

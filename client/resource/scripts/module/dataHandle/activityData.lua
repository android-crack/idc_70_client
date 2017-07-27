local error_info=require("game_config/error_info")
local Alert = require("ui/tools/alert")
local new_activity = require("game_config/activity/new_activity")
local on_off_info=require("game_config/on_off_info")
local ui_word = require("scripts/game_config/ui_word")

local scheduler = CCDirector:sharedDirector():getScheduler()

local OPEN_STATE_TRUE = 1
local OPEN_STATE_FLASE = 0

local ACTIVITY_XUANSHANG = 10
local ACTIVITY_SHOPMATCH = 9
-- local ACTIVITY_TRADE = 4
local ACTIVITY_GUILD_BOSS = 6
local ACTIVITY_GUILD_STRONGHOLD = 8
local ACTIVITY_GUILD_ZHENGBA = 20

-- local ACTIVITY_STATUS_CLOSE       = 0
-- local ACTIVITY_STATUS_OPEN        = 1
-- local ACTIVITY_STATUS_NO_ACTIVITY = 2
-- local ACTIVITY_STATUS_END         = 3
-- -- 即将开始
-- local ACTIVITY_STATUS_SOON 		 = 4

local activityData = class("ActivityData")

function activityData:ctor()
	self.activity_table = table.clone(new_activity)
	self.limit_time_activity_list = {} --所以的限时活动
	self:initLimitTimeActivityData() --初始化限时活动
	self:startHeartBeat()
	self.new_open_list = {}
	
end

---海神活动奖励
function activityData:setSeagodRewardId(id)
	self.seagod_reward_sailor_id = id
end

function activityData:getSeagodRewardId()
	return self.seagod_reward_sailor_id
end

function activityData:clearSeagodRewardId()
	self.seagod_reward_sailor_id = nil
end

--保留值给港口创建后回调用
function activityData:getTipDic()
	return self.needShowPortTip
end

function activityData:getActivityById(id)
	if self.activity_list then
		return self.activity_list[id]
	end
end

-- 获取30分钟内将开始的活动列表
function activityData:getSoonActivities()
	local ret_tab = {}
	if self.activity_list then --这里加个注释,可能rpc_client_get_activity_list协议没有下发
		for id , val in pairs(self.activity_list) do
			local switch = new_activity[id].switch
			local status = getGameData():getOnOffData():isOpen(on_off_info[switch].value)
			if status then
				if val.status == ACTIVITY_STATUS_SOON
					-- todo ，竞技场除外 临时解决，稍后优化
					and id ~= 2 then
					table.insert(ret_tab , val)
				end
			end
		end
	end
	return ret_tab
end

-- 获取正在进行中的活动
function activityData:getDoingActivities()
	local ret_tab = {}
	if self.activity_list then --这里加个注释,可能rpc_client_get_activity_list协议没有下发
		local doing_list = self:getDoingActivity() --至获取当前进行中的活动进行筛选
		for key , activity in pairs(doing_list) do
			local temp_activity = self.activity_list[activity.id]
			if temp_activity then
				if temp_activity.status == ACTIVITY_STATUS_OPEN and temp_activity.start_time ~= 0
					-- todo ，竞技场除外 临时解决，稍后优化
					and activity.id ~= 2 then
					table.insert(ret_tab , activity)
				end
			end
			-- end
		end
	end
	return ret_tab
end

--检查是否符合进入条件
function activityData:checkCanJoin(activity_id)
	local onOffData = getGameData():getOnOffData()
	local guildInfoData = getGameData():getGuildInfoData()

	local daily_race_tbl = {
		[ACTIVITY_SHOPMATCH] = true,
		[ACTIVITY_XUANSHANG] = true,
	}

	local special_activity = {
		[ACTIVITY_GUILD_BOSS] = {["condiction"] = guildInfoData:hasOpenGuildBossBtn()}, --前两个判断是否有商会,同时判断商会内的活动是否开启
		[ACTIVITY_GUILD_ZHENGBA] = {["condiction"] = guildInfoData:hasGuild()}, --海域争霸就只判断有没有帮会
	}

	local activity_data = self.activity_table[activity_id]
	local open_status = onOffData:isOpen(on_off_info[activity_data.switch].value)
	local activity_status = self.activity_list[activity_id]
	if open_status and activity_status then
		if daily_race_tbl[activity_id] and (activity_status.status == ACTIVITY_STATUS_NO_ACTIVITY) then
			return false
		-- elseif special_activity[activity_id] and not special_activity[activity_id].condiction or activity_status.status == ACTIVITY_STATUS_NO_ACTIVITY then
		-- 	--如果是特殊处理,未开放对应的条件或者活动状态为没开启
		-- 	return false
		else
			return true
		end
	else
		return false
	end
end

--更新所有活动状态
function activityData:updateActivityData()
	self.doing_activitys = {}
	self.not_open_activitys = {}
	for i,v in ipairs(self.activity_table) do

		if v.is_using == 1 then
			v.id = i
			if new_activity[v.id].type == ACTIVITY_TYPE_DAILY then
				self.doing_activitys[#self.doing_activitys + 1] = v
			elseif new_activity[v.id].type == ACTIVITY_TYPE_TIMED then
				self.not_open_activitys[#self.not_open_activitys + 1] = v
			end
		
		end
	end
end

function activityData:limitTimeHandle()
	local port_layer = getUIManager():get("ClsPortLayer")
	local exporeUI = getUIManager():get("ExploreUI")
	if not tolua.isnull(port_layer) then
		port_layer:checkShowActivityEffect()
	end
	if not tolua.isnull(exporeUI) then
		exporeUI:checkShowActivityEffect()
	end
end

--得到正在进行的活动
function activityData:getDoingActivity()
	self:updateActivityData()
	return self.doing_activitys
end



--------------------------------------限时活动begin-------------------------------------------
-- 每天多少秒
local DAY_SECOND = 24 * 60 * 60

-- 获取当天时间
local function getTimeIntraday(time)
	return (time + 28800) % DAY_SECOND
end

--判断限时活动今天是否可以参加
function activityData:isTodayActivity(activity)
	local today = os.date("%w") 
	local activity_time = activity.week_day
	local is_all_time = #activity_time == 0 --每天都有的活动
	local in_time = false
	for k1,v1 in pairs(activity_time) do
		if v1 == tonumber(today) then
			in_time = true
		end
	end
	return is_all_time or in_time
end


--获取今天可以的限时活动（会过滤掉不是今天的活动，和未开放的活动）
function activityData:getLimitTimeActivityList()
	local limit_time_list = {}
	local on_off_data = getGameData():getOnOffData()
	for i,v in ipairs(self.limit_time_activity_list) do
		if on_off_data:isOpen(on_off_info[v.switch].value) and self:isTodayActivity(v) then
			local data = self:getActivityById(v.id)
			if data then
				v.is_completed = self:getActivityById(v.id).is_completed
				local this_time = getTimeIntraday(self:getGameTime()) --获取这个时间点的时间
				if this_time > v.end_time[#v.end_time] then --活动过期了当做他完成了
					v.is_completed = 1
				end
			end
			limit_time_list[#limit_time_list + 1] = v
		end
	end
	return limit_time_list
end

--通过本地配置表初始化限时活动(把所有的限时活动过滤出来)
function activityData:initLimitTimeActivityData()
	for i,v in ipairs(self.activity_table) do
		if v.type == ACTIVITY_TYPE_TIMED and v.is_using ~= 0 then
			v.id = i
			self.limit_time_activity_list[#self.limit_time_activity_list + 1] = v
		end
	end

end

--获取游戏的时间
function activityData:getGameTime()
	return os.time() --现在暂时用系统时间，以后时间可能服务器下发
end

--当前时间点活动状态
local ACTIVITY_IN_TIME = 1   --在活动期间
local ACTIVITY_NOT_IN_TIME = 2  --不在活动期间

--活动状态变化情况
local ACTIVITY_STATUS_NO_CHANGE = 0 --活动状态未变化
local ACTIVITY_STATUS_FORM_OUT_TO_IN = 1  --活动开始了
local ACTIVITY_STATUS_FROM_IN_TO_OUT = 2 --从在活动结束了
local ACTIVITY_STATUS_WILL_OPEN = 3 --活动将要开始

local activity_will_open_time = 15 * 60

-- 判断活动状态是否改变
	    -- 表里活动时间格式
		-- ['open_time'] = {36000,43200,50400,57600,64800,72000,79200}, --开始时间
		-- ['end_time'] = {36600,43800,51000,58200,65400,72600,79800}, --结束时间
function activityData:updateNowActivityStatus(activity)
	local activity_status_change_status = ACTIVITY_STATUS_NO_CHANGE
	local this_time = getTimeIntraday(self:getGameTime()) --获取这个时间点的时间
	target_ui = getUIManager():get("ExploreUI")
	if target_ui then
		activity.show_will_open_tips = false
	end
	for i,v in ipairs(activity.open_time) do
		if this_time > v and this_time < activity.end_time[i] then --这一时刻在活动时间内	
			activity.show_will_open_tips = false
			if not activity.is_in_activity_time then --上一次不在活动内			
				activity_status_change_status = ACTIVITY_STATUS_FORM_OUT_TO_IN

			else			
				activity_status_change_status = ACTIVITY_STATUS_NO_CHANGE
			end	
			activity.remain_time = activity.end_time[i] - this_time
			activity.is_in_activity_time = true
			return activity_status_change_status
		elseif this_time < v and v - this_time < activity_will_open_time and not activity.show_will_open_tips then --判断即将开放
			activity.will_open_time = v
			activity.remain_time = 0
			activity.is_in_activity_time = false
			return ACTIVITY_STATUS_WILL_OPEN
		else
		end
	end
	--活动不在时间内
	activity.remain_time = 0
	if activity.is_in_activity_time then --上一次记录的是状态在活动时间内		
		activity_status_change_status = ACTIVITY_STATUS_FROM_IN_TO_OUT
	else
		activity_status_change_status = ACTIVITY_STATUS_NO_CHANGE
	end
	activity.is_in_activity_time = false
	return activity_status_change_status
	
end

function activityData:startHeartBeat()
	self.heart_beat_timer = scheduler:scheduleScriptFunc(function( )
		self:HeartBeat()
	end, 1, false)
end

function activityData:stopHeartBeat()
	if self.heart_beat_timer then
		scheduler:unscheduleScriptEntry(self.heart_beat_timer)
	end
	self.timer = heart_beat_timer
end

--限时活动心跳
function activityData:HeartBeat()
	local limit_activity_list = self:getLimitTimeActivityList()
	for i,v in ipairs(limit_activity_list) do
		local activi_change_status = self:updateNowActivityStatus(v)
		if activi_change_status == ACTIVITY_STATUS_FORM_OUT_TO_IN then --有活动开始了
			self:callActivityOpen(v.id)
		elseif activi_change_status == ACTIVITY_STATUS_FROM_IN_TO_OUT then  --有活动结束了
			self:callActivityClose(v.id)
		elseif activi_change_status == ACTIVITY_STATUS_WILL_OPEN  then
			self:callActivityWillOpen(v)
		end
	end
	self:setActivityBtnEffect() --活动按钮特效

	self:updataNewActivityBtnEffect() --新活动开启特效


end

-- 通知活动即将开始
function activityData:callActivityWillOpen(activity)
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:showActivityTips(activity.id, activity.will_open_time)
		activity.show_will_open_tips =  true
	end
end
--通知活动开始
function activityData:callActivityOpen(activity_id)
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:showActivityTips(activity_id)
	end	
end
-- 通知活动结束
function activityData:callActivityClose(activity_id)
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:closeFeatureTips(nil, true)
	end
	self.has_show_tips_activity_id = nil --重置保存已经活动开始提示
end

-- 活动按钮火烧特效
function activityData:setActivityBtnEffect()
	
	local status = self:isHasDoingLimitActivity()
	local target_ui = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(target_ui) then
		target_ui = target_ui:getMainUI()
		if not tolua.isnull(target_ui) then
			target_ui:setFireEffectState(status)
		end
	end
	target_ui = getUIManager():get("ExploreUI")
	if not tolua.isnull(target_ui) then
		target_ui:setFireEffectState(status)
	end
	--活动tab红点
	local task_data = getGameData():getTaskData()
	task_data:setTask(on_off_info.ACTIVE_TIMEACTIVE.value, status)
end

--是否有正在进行的限时活动
function activityData:isHasDoingLimitActivity()
	local limit_activity_list = self:getLimitTimeActivityList()
	local is_has_doing_limit_activity = false
	local activity_id = 0
	for i,v in ipairs(limit_activity_list) do
		if tonumber(v.remain_time) > 0 and v.is_completed == 0 then
			is_has_doing_limit_activity = true
			activity_id = v.id
		end
	end
	return is_has_doing_limit_activity, activity_id
end

function activityData:setActivityOpenTipsHasShow(activity_id)
	self.has_show_tips_activity_id = activity_id
end

function activityData:isShowThisActivityOpenTips(activity_id)
	return tonumber(self.has_show_tips_activity_id) == activity_id
end

--------------------------------------限时活动end---------------------------------------------

-- 请求活动列表
function activityData:requestActivityInfo()
	GameUtil.callRpc("rpc_server_get_activity_list", {})
end

function activityData:setActivityList(list)
	self.activity_list = {}
	for __ , activity in ipairs(list) do
		activity.start_remain_time = nil
		activity.start_real_time = nil
		activity.start_time = nil
		activity.end_time = nil

		local switch = new_activity[activity.id].switch
		local status = getGameData():getOnOffData():isOpen(on_off_info[switch].value)
		self.old_on_off_status = status
		self.activity_list[activity.id] = activity
		
	end
	local is_update_now = true
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) and tolua.isnull(port_layer:getMainUI()) then
		is_update_now = false
	end
	
	if not tolua.isnull(getUIManager():get("ClsPortTeamUI")) and not tolua.isnull(getUIManager():get("ClsPortTeamUI"):getListUi()) then
		getUIManager():get("ClsPortTeamUI"):getListUi():updateActivityInfo()
	end
end

function activityData:getDoingActivityNum()
	if not self.doing_activitys then return end
	return #self.doing_activitys
end

function activityData:getActivityList()
	return self.activity_list
end

function activityData:updataNewActivityBtnEffect()
	
	local target_ui = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(target_ui) then
		target_ui = target_ui:getMainUI()
		if not tolua.isnull(target_ui) then
			target_ui:checkShowActivityEffect()
		end
	end
	
end

function activityData:setNewOpenListItem(key)
	-- print('-------setNewOpenListItem ---- ')
	for i=1,#new_activity do
		local switch = new_activity[i].switch
		if switch ~= "" and new_activity[i].type == 1 then
			if on_off_info[switch].value == key then
				self.new_open_list[i] = true
				break
			end
		end
	end
end


--检测是否是新活动
function activityData:isNewOpenActivity(activity_id)
	return self.new_open_list[activity_id]
end

--改写新活动状态
function activityData:changeNewActivity(activity_id)
	self.new_open_list[activity_id] = false
end


function activityData:getNewActivityCount()
	local count = 0
	for k,v in pairs(self.new_open_list) do
		if v then
			count = count + 1
		end
		
	end
	return count
end

function activityData:getActivityLeaveTimes(aid)
	if not aid or not self.activity_list then return end
	if self.activity_list[aid] then
		return self.activity_list[aid].times
	end
end
--海神活动请求挑战
function activityData:askSeaGodActivityStart()
	GameUtil.callRpc("rpc_server_seagod_start", {})
end

function activityData:acceptSeaGodRequst(is_accept)
	local status = 0
	if is_accept then
		status = 1
	end
	GameUtil.callRpc("rpc_server_seagod_enter_confirm", {status})
end

--海神活动失败提示框按钮操作
function activityData:askSeaGodActivityConfirm(is_exit)
	GameUtil.callRpc("rpc_server_seagod_gate_failed_confirm", {is_exit})
end

--海神活动失败提示
function activityData:showSeaGodActivityAlert(is_leader)
	local function askContinueFight()
		self:askSeaGodActivityConfirm(0)
	end
	local function askExitFight()
		self:askSeaGodActivityConfirm(1)
	end
	-- 结算单独一个场景,通用一个战斗结算方法
	local function mkScene()
		local run_scene = GameUtil.getRunningScene()
		run_scene:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function ( )
			Alert:showBayInvite(runScene, askContinueFight, askExitFight, askContinueFight, true, 10,
			ui_word.SEAGOD_FAILED_CONFIRM_CONTENT, ui_word.SEAGOD_FAILED_CONFIRM_FIGHT_NAME,
			ui_word.SEAGOD_FAILED_CONFIRM_REFUSE_NAME, not is_leader)
		end)))
		return run_scene
	end

	GameUtil.runScene(mkScene, SCENE_TYPE_BATTLE_ACCOUNT)

end

---------------------------航海士觉醒-----------------------
function activityData:setSailorAwakeActivityInfo(activity_info)
	self.sailor_awake_activity_info = activity_info
end

function activityData:getSailorAwakeActivityInfo()
	
	if not self.sailor_awake_activity_info then
		self:askSailorAwakeActivityInfo()
	end
	return self.sailor_awake_activity_info
end

function activityData:askSailorAwakeActivityInfo()
	GameUtil.callRpc("rpc_server_sailor_awake_huodong", {})
end

return activityData

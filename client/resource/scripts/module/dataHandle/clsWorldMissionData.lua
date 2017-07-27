local alert = require("ui/tools/alert")
local cfg = require("game_config/world_mission/world_mission_info")
local tm_cfg = require("game_config/world_mission/world_mission_team")
local dialog_quene = require("gameobj/quene/clsDialogQuene")
local NPC_TYPE = require("gameobj/explore/exploreNpc/exploreNpcType")
local scheduler = CCDirector:sharedDirector():getScheduler()
local ui_word = require("game_config/ui_word")

local WM_TYPE = { ["explore_event"] = "explore_event", ["business"] = "business", ["battle"] = "battle", ["teambattle"] = "teambattle",}
local clsWorldMissionData = class("clsWorldMissionData")
-- @status
-- 	0 未接受
-- 	1 进行中
-- 	2 完没并领奖 -- 不发
-- 	3 完成并领奖

function clsWorldMissionData:ctor()
	self:initData()
end

function clsWorldMissionData:resetData()

	self.m_list = {} -- 世界任务总表
	self.m_cur_item = nil -- 当前世界任务

	self.m_list_other = {} -- 其他任务总表

	-- self.is_list_update_other = false -- 是否更新其他任务
	self.is_list_update = false -- 是否更新世界任务

	self.is_remove_npc = true -- 是否移除世界任务npc
	self.is_remove_npc_other = false -- 是否移除任务npc
	self.ask_guild_time = 0 --商会援助cd时间

	self.rewards_cache = nil

	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
		self.timer = nil
	end
end

function clsWorldMissionData:setAskGuildTime(pre_time)
	self.ask_guild_time = pre_time
end

function clsWorldMissionData:getAskGuildTime()
	return self.ask_guild_time
end

function clsWorldMissionData:initData()
	self:resetData()
end

function clsWorldMissionData:clearData()
	self:resetData()
end

-- 请求世界任务列表
function clsWorldMissionData:askWorldMissionList()
	GameUtil.callRpc("rpc_server_world_mission_list")
end

-- 请求接受任务 
function clsWorldMissionData:askAcceptMission(id)
	local player_data = getGameData():getPlayerData()
	local cur_strength = player_data:getPower()
	local mission_conf = cfg[id] or tm_cfg[id]
	local need_strength = mission_conf.star * 10 --配表 -- 星星*10
	local data = getGameData():getWorldMissionData()

	if self.m_cur_item and self.m_cur_item.id and self.m_cur_item.id ~= id then --身上已经接有一个世界任务
		local error_id = 686
		local error_info =require("game_config/error_info")
		alert:warning({msg = error_info[error_id].message})
		return
	end

	if mission_conf.type == data:getType().teambattle then
		if self:getMissionStatusById(id) == 1 then
			local m_info = {}
			m_info.type = EXPLORE_NAV_TYPE_WORLD_MISSION
			m_info.id = id
			m_info.is_has_accepted = true
			data:popTeamMissionTip(m_info)
		else
			alert:showAttention(ui_word.STR_TEAM_WORLD_MISSION_TIP, function()
				GameUtil.callRpc("rpc_server_team_world_mission_accept",{id})
			end)
		end
		return
	end
	-- 如果体力不足
	if cur_strength < need_strength then
		-- 参数表
		local parms = {}
		parms.need_power = need_strength
		parms.come_type = alert:getOpenShopType().VIEW_3D_TYPE
		parms.come_name = "world_mission_power_consume"
		parms.ignore_sea = true
		-- 体力不足通用对话框
		alert:showJumpWindow(POWER_NOT_ENOUGH, nil, parms)
	else
		-- 体力消耗二次确认框,确认的回调里发送接受协议
		local function callback()
			GameUtil.callRpc("rpc_server_world_mission_accept",{id})
		end
		local str = string.format(ui_word.WORLDMISSION_DEAL_TIPS_ACCEPT_TIPS,tostring(need_strength))

		alert:showAttention(str,callback)
	end
end

-- 请求放弃任务
function clsWorldMissionData:askGiveUpMission(id)
	GameUtil.callRpc("rpc_server_world_mission_cancel",{id})
end

-- 请求放弃组队任务
function clsWorldMissionData:askGiveUpTeamMission(id)
	GameUtil.callRpc("rpc_server_team_world_mission_cancel", {id})
end

-- 请求进入战斗
function clsWorldMissionData:askFigt(id)
	GameUtil.callRpc("rpc_server_world_mission_fight",{id})
end

function clsWorldMissionData:askTeamFight(id)
	GameUtil.callRpc("rpc_server_team_world_mission_fight", {id})
end

function clsWorldMissionData:getType()
	return WM_TYPE
end

-- 缓存世界任务列表
function clsWorldMissionData:setWorldMissionList(list)
	local is_exist_accept = false
	if #list == 0 then
		self.m_list = {}
		self.m_cur_item = nil
	end
	self.m_list = {}
	for k,v in pairs(list) do
		v.cfg = cfg[v.id] or tm_cfg[v.id]
		self.m_list[v.id] = v
		if v.status == 1 and not is_exist_accept then
			self.m_cur_item = v
			is_exist_accept = true
		end
	end
	-- 如果不存在已接受任务 清空
	if not is_exist_accept then
		self.m_cur_item = nil
	end
	-- 更新标志位
	self.is_list_update = true
	self.world_mission_list = list
end

function clsWorldMissionData:getAllWorldMissionList()
	return self.world_mission_list
end


-- 获取世界任务列表
function clsWorldMissionData:getWorldMissionList()
	return self.m_list
end

-- 移除npc对象(ps 所有任务共用一个npc模型)
function clsWorldMissionData:removeWorldMissionNpc()
	local npc_type = NPC_TYPE.WORLD_MISSION
	local npc_id = NPC_TYPE.NPC_CUSTOM_ID[npc_type]
	getGameData():getExploreNpcData():removeNpc(npc_id)
end

-- 获取表长度
function clsWorldMissionData:getWorldMissionListSize()
	local size = 0
	for k,v in pairs(self.m_list) do
		size = size + 1
	end
	return size
end

-- 获取显示接任务据点模型和小地图图标的列表
function clsWorldMissionData:getShowInMapAndSeaList()
	local show_table = {}
	for k,v in pairs(self.m_list) do
		local is_add = false
		if v.status == 0 then
			is_add = true
		end
		if v.status == 1 and (v.cfg.type == WM_TYPE.battle or v.cfg.type == WM_TYPE.teambattle) then
			is_add = true
		end
		if is_add then
			show_table[#show_table+1] = v
		end
	end
	return show_table
end

-- 获取npc要遍历判断的tile坐标集合
function clsWorldMissionData:getNpcTilePos()

	local pos_info_table = {}
	for k,v in pairs(self:getShowInMapAndSeaList()) do
		if v.cfg then
			pos_info_table[v.id] = v.cfg.position_explore
		else
		end
	end
	return pos_info_table
end

-- 初始化npc对象 由于所有世界任务npc都不会同屏 而且npc模块的机制是一个npc就启动一个定时器每帧检测坐标,太耗费性能,所以只创建一个npc 在该npc里判断 所有nec的位置 统一做隔帧检测.
function clsWorldMissionData:createWorldMissionNpc()
	-- 保护性校验
	if self:getWorldMissionListSize() == 0 then
		return
	end

	local npc_type = NPC_TYPE.WORLD_MISSION
	local npc_id = NPC_TYPE.NPC_CUSTOM_ID[npc_type]
	local npc_data = {}
	-- npc中 用到cfg中的tile坐标 作显示位置判断
	-- 也可以用netData中的id.作 是否移除该坐标的判断(这个现在没用到.不传.)(移除npc的判断是针对接受战斗类型任务做特殊处理(不移除),其他都移除)
	npc_data.id_pos_table = self:getNpcTilePos()
	-- npc模型按钮的回调函数
	local function callback(id)
		-- 如果存在当前任务 并且当前任务的id 和传入的id一致,并且类型为战斗类型 则发送战斗协议
		if self.m_cur_item and self.m_cur_item.id then
			if self.m_cur_item.id == id then
				if self.m_cur_item.cfg.type == WM_TYPE.battle then
					self:askFigt(id)
					return
				end
			end
		end
		-- 普通请求 请求接受任务
		self:askAcceptMission(id)
	end
	npc_data.callback = callback
	npc_data.msg = "  " -- test
	getGameData():getExploreNpcData():addStandardNpc(npc_id, nil, npc_type, npc_data, nil, nil)
end

-- 更新任务信息 逐条 判断状态是否由未完成变成完成,是的话播放对应的对白和奖励
function clsWorldMissionData:updateWorldMissionList(item)
	v = item
	v.cfg = cfg[v.id] or tm_cfg[v.id]

	-- 判断是否完成任务
	local is_complete = false
	local old_v = self.m_list[v.id]

	if old_v then
		if old_v.status == 1 and v.status == 3 then
			is_complete = true
		end
	else
		print(' updateWorldMissionList a new item ')
	end

	-- 如果是完成状态 播放对话 发放奖励
	if is_complete then
		self:whenCompleteMission(v)
	end

	-- update data
	self.m_list[v.id] = v
	if self.m_cur_item and self.m_cur_item.id == v.id then
		self.m_cur_item = v
	end
	-- 更新标志位
	self.is_list_update = true
end

-- 删除任务 下发要删除的任务id列表 对 总列表 和 已接受任务 做遍历 判断 id相同则删除
function clsWorldMissionData:delItemOfWorldMissionList(ids)
	for k,v in pairs(ids) do
		self:delItemOfWorldMissionListById(v)
	end
	-- 更新标志位
	self.is_list_update = true
end

-- 根据传入的id删除数据
function clsWorldMissionData:delItemOfWorldMissionListById(id)
	-- 判断是否完成任务
	local is_complete = false
	local old_v = self.m_list[id]

	if not old_v then
		-- print("delItemOfWorldMissionListById no such id",id)
		-- print("list \n")
		-- table.print(self.m_list)
		return
	end

	-- if old_v.status == 1 and v.status == 3 then
	-- 	is_complete = true
	-- end

	-- -- 如果是完成状态 播放对话 发放奖励
	-- if is_complete then
	-- 	self:whenCompleteMission(v)
	-- end

	self.m_list[id] = nil

	if self.m_cur_item then
		if self.m_cur_item.id == id then
			self.m_cur_item = nil
		end
	end
end

-- 设置已接受的任务信息 item 清空之前的任务 并在总列表中删除掉
function clsWorldMissionData:setItemAcceptedWorldMission(item)
	item.cfg = cfg[item.id] or tm_cfg[item.id]
	-- 清空之前接受的任务
	if self.m_cur_item ~= nil and self.m_cur_item.id ~= item.id then
		self:delItemOfWorldMissionListById(self.m_cur_item.id)
		self.m_cur_item = nil
	end
	self.m_list[item.id] = item
	self.m_cur_item = item
	-- 更新标志位
	self.is_list_update = true
end

-- 设置是否移除npc的状态 接受战斗类型任务时候特殊处理)(初始化为true)
function clsWorldMissionData:setIsRemoveNpc(isRemove)
	self.is_remove_npc = isRemove
end

-- 取消任务 后端下发取消已经接受的任务会执行这个方法 在当前任务和所有任务中删除该任务
function clsWorldMissionData:cancelById(id)
	if self.m_cur_item then
		if self.m_cur_item.id then
			if self.m_cur_item.id == id then
				self.m_cur_item = nil
				self.m_list[id] = nil
			else
				print("error clsWorldMissionData cancelById")
			end
		end
	end
	self.is_list_update = true
end

-- 获取当前任务 ( 显示到任务面板时用的 )(外部接口)
function clsWorldMissionData:getAcceptedWorldMissionInfo()
	return self.m_cur_item
end

-- 当数据变动时候 刷新
function clsWorldMissionData:whenChangeData()

	if self.is_list_update then
		-- 重置标志位
		self.is_list_update = false
		-- 当前要在地图和场景中显示的数据的列表
		local show_list = (self:getShowInMapAndSeaList())
		local size = #show_list
		-- 处理npc逻辑
		if size == 0 then
			-- 为0 则删除npc
			self:removeWorldMissionNpc()
		else
			-- 重新创建npc
			if self.is_remove_npc then
				self:removeWorldMissionNpc()
				self:createWorldMissionNpc()
			else
				-- 重置状态
				self.is_remove_npc = true
			end
		end

		-- 重新初始化地图哈希查找表 和 图标
		getGameData():getWorldMapAttrsData():resetWmHash()

		-- 如果有刷新地图 就刷新探索状态的任务栏
		local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
		if not tolua.isnull(explore_map) then
			-- 刷新整个类型的图标,可以做数据对比刷新也行
			explore_map:resetPoint(EXPLORE_NAV_TYPE_WORLD_MISSION)
			-- EventTrigger(EVENT_MISSION_UPDATE) -- 刷新小地图
		end
		-- 刷新任务栏
		EventTrigger(EVENT_MISSION_OR_DAILY_UPDATE)
	end
end

--当前保存的导航信息为任务信息则清空
function clsWorldMissionData:isClearExploreInfo(complete_mission_id)
	local pre_goal_info = getGameData():getExploreData():getGoalInfo()
	if pre_goal_info and pre_goal_info.is_world_mission and pre_goal_info.is_world_mission == complete_mission_id then
		return true
	end
end

-- 完成任务时候 播放完成任务的对话
function clsWorldMissionData:whenCompleteMission(complete_item)
	-- print(" --------------------- whenCompleteMission ---------")
	local exploreLayer = getUIManager():get("ExploreLayer")
	if not tolua.isnull(exploreLayer) then
		local explore_land = exploreLayer:getLand()
		explore_land:breakAuto(true)
	end

	if self:isClearExploreInfo(complete_item.id) then
		getGameData():getExploreData():setGoalInfo(nil)
		getGameData():getExploreData():setAutoPos(nil)
	end

	local id = complete_item.id
	local function complete_reward_callback()
		-- print(" --------------------- complete_reward_callback ---------")
		if self:getfightRewardCache() ~= nil then
			local data = {reward = self:getfightRewardCache()}
			dialog_quene:insertTaskToQuene(require("gameobj/quene/clsAutoTradeRewardPopViewQuene").new(data))
			self:setfightRewardCache(nil)
		end
	end

	local pre_goal_info = getGameData():getExploreData():getGoalInfo()
	if pre_goal_info then
		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, pre_goal_info)
	end

	local mission_conf = cfg[id] or tm_cfg[id]
	self:showPlot(mission_conf.mission_complete_dialog,complete_reward_callback)
end

-- 拼接需要显示的文本字段,是否显示进度,是否是富文本.
function clsWorldMissionData:getParseStrById(id,is_show_progress,is_rich)
	-- 是否是进度文本
	is_show_progress = is_show_progress or false
	-- 是否是富文本
	is_rich = is_rich or false
	-- 初始化目标字符串
	local target_str = ""
	local mission_conf = cfg[id] or tm_cfg[id]
	-- 拼接任务目标字段
	for k,v in pairs(mission_conf.mission_target_tips) do
		if is_rich then
			target_str = target_str.."$(c:COLOR_WHITE)"..v
		else
			target_str = target_str..v
		end
	end
	-- 获取类型
	local _type = mission_conf.type
	-- 获取自身数据(包括服务器数据和配置表数据)
	local item = self.m_list[id]
	if is_rich then
		target_str = string.format("%s$(c:COLOR_GREEN)",target_str)
	else
		target_str = string.format("%s",target_str)
		target_str = string.gsub(target_str,'#','')
	end

	if _type == WM_TYPE.explore_event then
		local progress_str
		if is_show_progress then
			progress_str = string.format("(%d/%d)",item.progress[1].value,item.cfg.progress[1][2].times)
		else
			progress_str = item.cfg.progress[1][2].times..""
		end
		target_str = string.format(target_str,progress_str)
	elseif _type == WM_TYPE.business then
		local json_table = json.decode(item.data)
		if json_table then
			local progress_str
			if is_show_progress then
				progress_str = string.format(ui_word.NUM_TO_TARGET_TIP,item.progress[1 ].value, item.cfg.progress[1][2].amount)
			else
				progress_str = item.cfg.progress[1][2].amount..""
			end
			if json_table.port then
				local port_info = require("game_config/port/port_info")
				local port_name = port_info[json_table.port].name
				target_str = string.format(target_str,port_name,progress_str)
			end
		end
	elseif _type == WM_TYPE.battle or _type == WM_TYPE.teambattle then
		target_str = string.format(target_str,item.cfg.name)
	end

	return target_str
end

-- 显示剧情文本 直接传入文本调用, 增加回调,第一次接受任务的时候,播放完对话就立刻进入战斗
function clsWorldMissionData:showPlot(plot_str,callback)
	local data = {}
	data.plot_str_table = plot_str
	data.callback = callback
	dialog_quene:insertTaskToQuene(require("gameobj/quene/clsWorldMissionPlot").new(data))
end

function clsWorldMissionData:setfightRewardCache(rewards)
	self.rewards_cache = rewards
end

function clsWorldMissionData:getfightRewardCache()
	return self.rewards_cache
end

function clsWorldMissionData:insertTeamMission2List(mission_list)
	local is_exist_accept = false
	for k,v in pairs(mission_list) do
		v.cfg = tm_cfg[v.id]
		self.m_list[v.id] = v
		if v.status == 1 and not is_exist_accept then
			self.m_cur_item = v
			is_exist_accept = true
		end
	end
	-- -- 如果不存在已接受任务 清空
	-- if not is_exist_accept then
	-- 	self.m_cur_item = nil
	-- end
	-- 更新标志位
	self.is_list_update = true
end

function clsWorldMissionData:askTeamWorldMissionList()
	GameUtil.callRpc("rpc_server_team_world_mission")
end

--商会求助
function clsWorldMissionData:askGuildHelp(_type, mid)
	GameUtil.callRpc("rpc_server_group_ask_for_help", {_type, mid})
end

function clsWorldMissionData:setTeamWorldMissionSchedule(schedule)
	self.team_mission_schedule = schedule
	local parent_ui = getUIManager():get("PortMap") or getUIManager():get("ExploreMap")
	if not tolua.isnull(parent_ui) and parent_ui:isShowWorldMax() then
		parent_ui:updateTeamWorldMissionSchedule(schedule)
	end
end

function clsWorldMissionData:popTeamMissionTip(data)
	getUIManager():create("gameobj/explore/clsMissionTipUI", nil, data)
end

function clsWorldMissionData:getMissionStatusById(mid)
	if not self.m_list or not self.m_list[mid] then return end
	return self.m_list[mid].status
end

--检查玩家身上是否还有未接受领取的世界任务
function clsWorldMissionData:isNewWorldMissionExit()
	if not self.m_list then return end
	for _, v in pairs(self.m_list or {}) do
		if v.status == 0 then
			return true
		end
	end
end

return clsWorldMissionData

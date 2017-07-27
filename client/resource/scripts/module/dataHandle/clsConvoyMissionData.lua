-- @date: 2016年12月30日1:40:05
-- @author: mid
-- @desc: 运镖任务数据缓存

-- include
local alert = require("ui/tools/alert")
local cfg = require("game_config/loot/time_plunder_info")
local explore_npc_type = require("gameobj/explore/exploreNpc/exploreNpcType")
local ui_word = require("scripts/game_config/ui_word")

-- const
local npc_type = explore_npc_type.CONVOY_MISSION
local npc_id = explore_npc_type.NPC_CUSTOM_ID[npc_type]

-- define
local clsConvoyMissionData = class("clsConvoyMissionData")

function clsConvoyMissionData:resetData()
	self.m_area_id_list = {} -- 所有列表
	self.m_show_list = {} -- 要显示的列表
	self.m_time = {}
	self.m_cur_item = nil -- 当前任务
	self.m_rewards = nil -- 奖励缓存
end

function clsConvoyMissionData:ctor()
	self:resetData()
end

function clsConvoyMissionData:dtor()
	self:resetData()
end

-- 请求
function clsConvoyMissionData:request(opType,data)
	if opType == "list" then
		GameUtil.callRpc("rpc_server_plunder_task_list")
	elseif opType == "accept" then
		GameUtil.callRpc("rpc_server_plunder_time_apply")
		-- rpc_client_plunder_time_apply(0,1)
	elseif opType == "giveup" then
		GameUtil.callRpc("rpc_server_plunder_time_giveup")
	end
end

-- 数据存取
function clsConvoyMissionData:getIdByAreaId(areaId)

	local id = 1

	for k,v in pairs(cfg) do
		-- print("-------------v--------------cfg")
		-- table.print(v)
		if v.area == areaId then
			id = k
			-- print(" ---------------- id",id)
			break
		end
	end
	-- print(" ------------- getIdByAreaId ----------- ",areaId,id)
	return id
end
function clsConvoyMissionData:setList(area_list)
	-- print(" ---------------- clsConvoyMissionData setList --------- ")
	-- for i,v in ipairs(list) do
	-- 	-- print(i,v)
	-- end
	area_list = area_list or {}
	self.m_area_id_list = {}
	for k,v in pairs(area_list) do
		local item = {}
		-- item.id = v.id or self:getIdByAreaId(v.id)
		local area_id = v
		local id = self:getIdByAreaId(area_id) -- 假id
		item.id = id
		item.cfg = cfg[id]
		-- item.id = self:getIdByAreaId(v.id)
		item.areaId = area_id
		item.net = v
		self.m_area_id_list[#self.m_area_id_list+1] = item
	end
	self:setShowList()
end

function clsConvoyMissionData:getList()
	return self.m_area_id_list
end

function clsConvoyMissionData:setTimeData(begin,duration)
	-- print("---------------- setTimeData ---------- ",begin,duration)
	self.m_time = self.m_time or {}
	self.m_time.begin = begin
	self.m_time.duration = duration
end

function clsConvoyMissionData:getTimeData()
	return self.m_time
end

function clsConvoyMissionData:setCurItem(id)
	-- print(" -------------- setCurItem ---------- ",id)
	local cur_item = {}
	if cfg[id] then
		cur_item.cfg = cfg[id]
		cur_item.id = id
	else
		cur_item = nil
	end
	self.m_cur_item = cur_item
	self:setShowList()
end

function clsConvoyMissionData:getCurItem()
	return self.m_cur_item
end

function clsConvoyMissionData:isDoingMission()
	if self.m_cur_item then
		return self.m_cur_item.id ~= 0
	else
		return false
	end
end

function clsConvoyMissionData:cleanCurItem()
	self.m_cur_item = nil
end

function clsConvoyMissionData:setShowList()
	-- print( "------------- setShowList ----------- ")
	-- print(" -- m_cur_item")
	-- table.print(self.m_cur_item)
	-- print(" -- m_area_id_list")
	-- table.print(self.m_area_id_list)
	local list = {}
	-- print("-------- self.m_cur_item",)
	for k,v in pairs(self.m_area_id_list) do
		-- table.print(self.m_cur_item)
		if self.m_cur_item then
			if v.areaId == self.m_cur_item.cfg.area then
				-- print(" ------------- changeid ----------",v.id)
				v.id = self.m_cur_item.id
			end
		end
		list[v.id] = v
	end
	self.m_show_list = list
	-- return list
end

function clsConvoyMissionData:getShowList()
	-- print(" ---------- clsConvoyMissionData getShowList -----------------")
	-- table.print(self.m_show_list)
	return self.m_show_list
end

function clsConvoyMissionData:setRewards(rewards)
	self.m_rewards = rewards
end

function clsConvoyMissionData:getRewards(rewards)
	return self.m_rewards
end

-- 数据变动后相关操作
function clsConvoyMissionData:updateRelative()

	-- print(" ----------------- updateRelative ----------------------- ")
	-- NPC相关
	local size = #(self.m_area_id_list)
		self:removeNPC()
	if size == 0 then
	else
		self:removeNPC()
		self:createNPC()
	end

	-- print("------------- ", #self.m_area_id_list)

	-- 重新建立哈希表
	getGameData():getWorldMapAttrsData():resetCMHash()

	-- 刷新地图上 的 运镖图标
	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		explore_map:resetPoint(EXPLORE_NAV_TYPE_CONVOY_MISSION)
	end
	self:updateLockSpeedInfo()
	-- 任务栏的不用刷新了-- 服务器会推相关逻辑
end

function clsConvoyMissionData:updateLockSpeedInfo()
	local explore_layer = getExploreLayer()
	if not tolua.isnull(explore_layer) then
		local ships_layer = explore_layer:getShipsLayer()
		if tolua.isnull(ships_layer) then return end
		if self.m_cur_item then
			ships_layer:setLockSpeed(true, 120)
		else
			ships_layer:setLockSpeed(false)
		end
	end
end

-- 移除npc
function clsConvoyMissionData:removeNPC()
	getGameData():getExploreData():setAutoPos(nil) -- 清空导航信息
	getGameData():getExploreNpcData():removeNpc(npc_id)
end

-- 创建npc
function clsConvoyMissionData:createNPC()
	local npc_data = {}
	npc_data.pos_table = self:getNPCPos()
	local function click_callback()
		-- 体力消耗二次确认框,确认的回调里发送接受协议
		local function accept_callback()
			self:request("accept")
		end

		alert:showAttention(ui_word.CONVOYMISSION_DEAL_TIPS, accept_callback)
	end
	npc_data.callback = click_callback
	getGameData():getExploreNpcData():addStandardNpc(npc_id, nil, npc_type, npc_data, nil, nil)
end

-- 获取npc位置
function clsConvoyMissionData:getNPCPos()
	local pos_table = {}
	for k,v in pairs(self:getShowList()) do
		pos_table[v.id] = v.cfg.position_explore
		-- for k1,v1 in pairs(cfg) do
		-- 	if v1.area == k then

		-- 	end
		-- end
	end
	return pos_table
end

-- 接受任务,播放接收任务剧情对白,无回调操作
function clsConvoyMissionData:acceptMission(id)
	-- print(" -------------- acceptMission ------------- id",id)
	self:showPlot(cfg[id].mission_accept_plot,nil)
	-- self:removeNPC()
end

-- 完成任务,播放完成任务剧情,后再,播放奖励
function clsConvoyMissionData:completeMission(id,callback)
	-- print(" -------------- completeMission ------------- id",id,callback)
	-- local function complete_callback()
	-- 	if rewards then
	-- 		require("gameobj/quene/clsDialogQuene"):insertTaskToQuene(require("gameobj/quene/clsAutoTradeRewardPopViewQuene").new({rewards = rewards}))
	-- 		self:setRewards(nil)
	-- 	end
	-- end
	self:showPlot(cfg[id].mission_complete_plot,callback)
end

-- 播放剧情,播放后执行回调.
function clsConvoyMissionData:showPlot(plot_str,callback)
	-- print(" --------------------showPlot----------- ")
	local data = {}
	data.plot_str_table = plot_str
	data.callback = callback
	require("gameobj/quene/clsDialogQuene"):insertTaskToQuene(require("gameobj/quene/clsWorldMissionPlot").new(data))
end

function clsConvoyMissionData:getStrById(id)
	-- body
end

return clsConvoyMissionData

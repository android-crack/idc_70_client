--
-- 自动经商出海管理器
-- Author: chenlurong
-- Date: 2016-05-24 17:31:01
local ClsAutoTradeAIHandler = class("ClsAutoTradeAIHandler")

function ClsAutoTradeAIHandler:ctor()
	self.new_ai = {}
	self.running_ai = {}
	self.target_port = 0
	self._data = {}
	self.log_data = {}
end

function ClsAutoTradeAIHandler:setData(key, value)
	self._data[key] = value
end

function ClsAutoTradeAIHandler:getData(key)
	return self._data[key]
end

--查询自动经商数据
function ClsAutoTradeAIHandler:askAutoTradeData()
	GameUtil.callRpc("rpc_server_business_auto_online_info", {})
end

--查询自动经商数据
function ClsAutoTradeAIHandler:askStartTrade()
	GameUtil.callRpc("rpc_server_business_auto_online_start", {})
end

--购买自动经商次数
function ClsAutoTradeAIHandler:askBuyTimes(times)
	GameUtil.callRpc("rpc_server_business_auto_online_buy", {times})
end

--停止自动经商
function ClsAutoTradeAIHandler:askStopTrade()
	GameUtil.callRpc("rpc_server_business_auto_online_stop", {})
end

--组队经商邀请反馈
function ClsAutoTradeAIHandler:teamTradeInviteResponse(response)
	GameUtil.callRpc("rpc_server_auto_business_response", {response})
end

--委任经商中同步队员的交易行为
function ClsAutoTradeAIHandler:askTeamMemeberTrade()
	GameUtil.callRpc("rpc_server_business_auto_online_deal", {})
end

-- class business_auto_online_info_t {
--  44         int status;
--  45         int remainTimes; 
--  46         int remainTime;
--  47 }
function ClsAutoTradeAIHandler:setTradeData( info )
	self.trade_data = info
	local appoint_trade_ui = getUIManager():get("ClsAppointTradeUI")
	if not tolua.isnull(appoint_trade_ui) then
		appoint_trade_ui:updateUI(info)
	end
	local appoint_trade_layer = getUIManager():get("ClsAppointTradeLayer")
	if not tolua.isnull(appoint_trade_layer) then
		appoint_trade_layer:updateTime(info.remainTime)
	end
	--是否在自动经商中
	if self.trade_data.status == 0 then
		if self:inAutoTradeAIRun()  then
			self:stopTradeAI()
		else
			self:closeAIMaskLayer()
		end
	elseif not self:inAutoTradeAIRun() then
		if tonumber(self.trade_data.noAI) > 0 then
			self:showAIMaskLayer()
		else
			self:startTradeAI()
		end
		
	end
end

function ClsAutoTradeAIHandler:getTradeRemainTime()
	return self.trade_data.remainTime
end

function ClsAutoTradeAIHandler:updateTradeData( times )
	self.trade_data.remainTimes = times
	local appoint_trade_ui = getUIManager():get("ClsAppointTradeUI")
	if not tolua.isnull(appoint_trade_ui) then
		appoint_trade_ui:updateUI(self.trade_data)
	end
end

function ClsAutoTradeAIHandler:getCurPortId()
	local port_data = getGameData():getPortData()
	local cur_port_id = port_data:getPortId()
	return cur_port_id
end

function ClsAutoTradeAIHandler:getCurArea()
	local port_data = getGameData():getPortData()
	local cur_area_id = port_data:getPortAreaId()
	return cur_area_id
end

function ClsAutoTradeAIHandler:getTargetArea()
	local target_area = -1
	local port_info = require("game_config/port/port_info")
	local area_info = port_info[self.target_port]
	if area_info then
		target_area = area_info.areaId
	end
	return target_area
end

function ClsAutoTradeAIHandler:getTargetPort()
	return self.target_port
end

function ClsAutoTradeAIHandler:setTargetPort(port)
	self.target_port = port
end

function ClsAutoTradeAIHandler:getPortGoodsNum()
	local market_data = getGameData():getMarketData()
	local cur_num, max_num = market_data:getStoreGoodNumByPortId(self.target_port)
	return cur_num
end

function ClsAutoTradeAIHandler:isTaskPort()
	local mission_data_handler = getGameData():getMissionData()
	local explore_map_data = getGameData():getExploreMapData()
	--任务
	local task_port_dic = explore_map_data:getTaskPort()
	local is_mission_to_port = mission_data_handler:isMissionEnterBattlePort(self.target_port)
	local is_task = true
	if not task_port_dic[self.target_port] and not is_mission_to_port then
		is_task = false
	end
	return is_task
end
----------------------------------- 新版本AI系统有关函数 Begin -------------------------------------

require("gameobj/battle/ai/ai_base")

-- AI心跳
function ClsAutoTradeAIHandler:updateAI(deltaTime)
	-- 新AI系统的心跳
	local runningAICnt = 0
	-- print("Prophet: ClsAutoTradeAIHandler:updateAI", deltaTime)
	for ai_id, ai_obj in pairs(self.running_ai) do
		--print("ClsShip:runningAI", self:getId(), ai_id)
		ai_obj:heartBeat( deltaTime )
		runningAICnt = runningAICnt + 1
	end

	-- 触发策略AI
	--self:tryOpportunity(AI_OPPORTUNITY.TACTIC, {})
end

local lastHeartBeatFrame = getCurrentFrame()
local lastHeartBeatTime = getCurrentLogicTime()
local is_pause = false

function autoTradeAIHandlerHeartBeat(event)
	local curFrame = getCurrentFrame()
	local now = getCurrentLogicTime()

	--if (curFrame - lastHeartBeatFrame) < FRAME_CNT_PER_SEC then return end
	-- print("updateTimer:", curFrame - lastHeartBeatFrame)

	-- 战斗停止心跳帧数照跳，这样就不会因为剧情暂停导致，各种心跳不合理
	lastHeartBeatFrame = curFrame

	if is_pause then
		return
	end

	local delta_time = now - lastHeartBeatTime
	lastHeartBeatTime = now

	delta_time = delta_time * 1000
	-- print("heartBeat:", delta_time)

	local obj = getGameData():getAutoTradeAIHandler()
	obj:updateAI(delta_time)
end

-- 添加AI
function ClsAutoTradeAIHandler:addAI(ai_id, params)
	local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
	local ClsAI = require(clazz_name)
	local aiObj = ClsAI.new(params, self)   

	--if self.id == 6 then print("addAI:", self:getId(), self:getName(), ai_id) end

	-- 将AI数据记录下来
	-- 到真正运行时再实例化
	self.new_ai[ai_id] = aiObj
end

-- 删除AI
function ClsAutoTradeAIHandler:deleteAI(ai_id)
	self.new_ai[ai_id] = nil
end


function ClsAutoTradeAIHandler:setRunningAI( aiObj )
	
	local ai_id = aiObj:getId()

	-- TODO:清除正在执行的比自己优先级别更低的AI
	--print("ClsShip:setRunningAI setRunningAI", ai_id)

	self.running_ai[ai_id] = aiObj
end

function ClsAutoTradeAIHandler:isRunningAI()
	return table.nums(self.running_ai) > 0
end

-- 尝试执行某个时机的AI
function ClsAutoTradeAIHandler:tryOpportunity( opportunity, params )
	local tmp_new_ai = table.keys(self.new_ai)
	for _, ai_id in pairs( tmp_new_ai ) do
		-- print("TO tryRun", self:getId(), self:getName(), ai_id, opportunity, self.running_ai[ai_id])

		if (not self.running_ai[ai_id] ) and self.new_ai[ai_id] then
			local res = self.new_ai[ai_id]:tryRun( opportunity, params )
			-- print("TO tryRun 2", self:getId(), self:getName(), ai_id, opportunity, res)
		end
	end
end

-- AI执行完毕
-- 1 将此AI从正在执行AI中删除
-- 2 查看new_ai中是否有本AI，如果有删除重新构建新实例插入,否则不做任何事情
--   这样保证每次AI都是重新开始,如果此ai删除了自己,不会再被执行
function ClsAutoTradeAIHandler:completeAI( aiObj )
	local ai_id = aiObj:getId();    

	-- 删除正在执行AI
	self.running_ai[ai_id] = nil    
end

function ClsAutoTradeAIHandler:getAI( ai_id )
	return self.new_ai[ai_id]
end

function ClsAutoTradeAIHandler:getId()
	return -1
end
----------------------------------- 新版本AI系统有关函数 End   -------------------------------------
--设置暂停AI
function ClsAutoTradeAIHandler:setPause(state)
	if not state and self:inAutoTradeAIRun() then
		for _, target_ai_obj in pairs(self.running_ai) do            
			if target_ai_obj then 
				local cur_running_act = target_ai_obj:getRunningAction()
				if cur_running_act and type(cur_running_act.dispos) == "function" then
					cur_running_act:dispos()
				end
				self:completeAI( target_ai_obj )
			end
		end

		-- print("==================ClsAutoTradeAIHandler:isRunningAI()", self:isRunningAI())

		local ai_id = "market_battle_end"
		-- self:addAI(ai_id, {})
		local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
		local ClsAI = require(clazz_name)
		local aiObj = ClsAI.new({}, self) 
		aiObj:tryRun(AI_OPPORTUNITY.RUN)
		-- print("==================ClsAutoTradeAIHandler:isRunningAI()", self:isRunningAI())
	end
	is_pause = state
end

function ClsAutoTradeAIHandler:startTradeAI()
	if self.heart_handle then return end

	is_pause = false
	lastHeartBeatFrame = getCurrentFrame()
	lastHeartBeatTime = getCurrentLogicTime()
	self.log_data = {}

	--用于查询已开港口的相关信息，用于搜索选择港口id时使用
	local explore_map_data = getGameData():getExploreMapData()
	local world_map_attrs_data = getGameData():getWorldMapAttrsData()
	local sea_area_list = world_map_attrs_data:getSeaArea()
	local open_ports = {}
	for k,v in pairs(sea_area_list) do
		for i,id in ipairs(v) do
			open_ports[#open_ports + 1] = id
		end
	end
	explore_map_data:askMapPortInfos(open_ports)

	local ai_id = "market_buy"
	local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
	local ClsAI = require(clazz_name)

	self.heart_handle = getSystemContext():addEventListener("frame_update", autoTradeAIHandlerHeartBeat)

	local aiObj = ClsAI.new({}, self) 
	aiObj:tryRun(AI_OPPORTUNITY.RUN)

	self:showAIMaskLayer()
end

function ClsAutoTradeAIHandler:addTradeLog(msg)
	self.log_data[#self.log_data + 1] = msg
end

function ClsAutoTradeAIHandler:getTradeLog()
	local log_str = ""
	local log_len = #self.log_data
	local index = log_len
	local log_info
	for i=1,35 do
		log_info = self.log_data[index]
		if log_info then
			log_str = log_str .. " \n"
			log_str = log_str .. log_info
		end
		index = log_len - i
	end
	return log_str
end

function ClsAutoTradeAIHandler:getShipStopReasons()
	local reason_str = ""
	local explore_layer = getUIManager():get("ExploreLayer")
	if not tolua.isnull(explore_layer) then
		local reason = explore_layer:getShipsLayer():getShipStopReasons()
		for k,v in pairs(reason) do
			if string.len(reason_str) > 0 then
				reason_str = reason_str .. " \n"
			end
			reason_str = reason_str .. k
		end
	end
	return reason_str
end

function ClsAutoTradeAIHandler:stopTradeAI()
	self:setIsAutoTrade(false)
	if self.heart_handle then
		for _, target_ai_obj in pairs(self.running_ai) do            
			if target_ai_obj then 
				local cur_running_act = target_ai_obj:getRunningAction()
				if cur_running_act and type(cur_running_act.dispos) == "function" then
					cur_running_act:dispos()
				end
				self:completeAI( target_ai_obj )
			end
		end

		getSystemContext():removeEventListener("frame_update", self.heart_handle)
		self.heart_handle = nil
	end
	self:closeAIMaskLayer()
	
end

function ClsAutoTradeAIHandler:closeAIMaskLayer()
	self:setIsAutoTrade(false)
	self.log_data = {}
	local appoint_trade_layer = getUIManager():get("ClsAppointTradeLayer")
	if not tolua.isnull(appoint_trade_layer) then
		getUIManager():close("ClsAppointTradeLayer")
		self.auto_trade_mask_layer = nil
	end
	if isExplore then
		local market_ui = getUIManager():get("ClsPortMarket")
		if not tolua.isnull(market_ui) then
			market_ui:closeView()
		end
	end
end

function ClsAutoTradeAIHandler:inAutoTradeAIRun()
	return self.heart_handle ~= nil
end

function ClsAutoTradeAIHandler:setIsAutoTrade(status)
	self.is_auto_trade = status
end

function ClsAutoTradeAIHandler:getIsAutoTrade()
	return self.is_auto_trade
end

function ClsAutoTradeAIHandler:showAIMaskLayer()
	self:setIsAutoTrade(true)
	local appoint_trade_layer = getUIManager():get("ClsAppointTradeLayer")
	if tolua.isnull(appoint_trade_layer) then
		self.auto_trade_mask_layer = getUIManager():create("gameobj/autoTrade/clsAppointTradeLayer")
	end
end

return ClsAutoTradeAIHandler

-- 海上航行
-- Author: chenlurong
-- Date: 2016-05-25 16:18:53
--
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeMove = class("ClsAIActionTradeMove", ClsAIActionBase) 

function ClsAIActionTradeMove:getId()
	return "trade_move"
end


-- 初始化action
function ClsAIActionTradeMove:initAction()
	self.duration = 99999999
	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	self.port_id = auto_trade_data:getTargetPort()
	self.move_to_port = true
	self.limit_dt_max = 10000
	self.ship_pos_dt = 0
	self.stop_move_time = 0
	self.stop_move_max = 20000
	self.wait_to_send_port_rpc = true
	self.last_ship_x = nil
	self.last_ship_y = nil
	self.goal_dis_max = 250
	self.event_key = tostring(self)
end

local function exploreToPort(self, port_id)
	self.move_to_port = false
end

function ClsAIActionTradeMove:__beginAction( target, delta_time )
	if self.port_id then
		local port_info = require("game_config/port/port_info")
		self.goal_pos = port_info[self.port_id].ship_pos

		EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = self.port_id, navType = EXPLORE_NAV_TYPE_PORT})
	else
		sendMsgToServer("ClsAIActionTradeMove __beginAction EVENT_EXPLORE_AUTO_SEARCH 找不到 goal_port_id")
	end 
	self.scene_data = getGameData():getSceneDataHandler()
	RegTrigger(EVENT_PORT_EXPLORE_ENTER, function(port_id)
			local auto_trade_data = getGameData():getAutoTradeAIHandler()
			auto_trade_data:addTradeLog("AI is : ClsAIActionTradeMove  EventTrigger EVENT_PORT_EXPLORE_ENTER :" .. port_id)
			if port_id == self.port_id then
				local port_data = getGameData():getPortData()
	    		port_data:setPortIdByTradeAI(port_id)
				exploreToPort(self, port_id)
				UnRegTrigger(EVENT_PORT_EXPLORE_ENTER, self.event_key)
			end
		end, self.event_key)
	RegTrigger(EVENT_PORT_TRADE_RPC_PORT, function(port_id)
			local auto_trade_data = getGameData():getAutoTradeAIHandler()
			auto_trade_data:addTradeLog("AI is : ClsAIActionTradeMove  EventTrigger EVENT_PORT_TRADE_RPC_PORT :" .. port_id .. "  self.port_id" .. tostring(self.port_id) .. " self.event_key" .. tostring(self.event_key))
			if port_id == self.port_id then
				self.wait_to_send_port_rpc = false
				UnRegTrigger(EVENT_PORT_TRADE_RPC_PORT, self.event_key)
			else
				sendMsgToServer("ClsAIActionTradeMove rpc_server_team_bounty_special_handle 港口id不一致 " .. port_id .. "  委任港口：" .. tostring(self.port_id) .. "  event_key:" .. tostring(self.event_key) .. " \n" .. auto_trade_data:getTradeLog())
			end
		end, self.event_key)

	local auto_trade_data = getGameData():getAutoTradeAIHandler()
	auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeMove:__beginAction")
end

function ClsAIActionTradeMove:__dealAction( target, delta_time )
	-- print("===============================ClsAIActionTradeMove:=========================")
	if self.scene_data:isInExplore() then
		local auto_trade_data = getGameData():getAutoTradeAIHandler()
		local goal_port_id = auto_trade_data:getTargetPort()
		if self.move_to_port and not IS_AUTO and self.wait_to_send_port_rpc then
			if goal_port_id then
				auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeMove:__dealAction line 80 : " .. goal_port_id)
				EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = goal_port_id, navType = EXPLORE_NAV_TYPE_PORT})
			end
		end
		local explore_layer = getUIManager():get("ExploreLayer")
		if tolua.isnull(explore_layer) then
			return self.move_to_port
		end
		if self.goal_pos and self.wait_to_send_port_rpc then
			local player_ship = explore_layer:getPlayerShip()
			local cur_x, cur_y = player_ship:getPos()
			if not self.last_ship_x then--赋值初始坐标点
				self.last_ship_x = cur_x
				self.last_ship_y = cur_y
			end
			local pos = explore_layer:getLand():cocosToTile2(ccp(self.goal_pos[1], self.goal_pos[2]))	
			local cur_dis = Math.distance(pos.x, pos.y, cur_x, cur_y)--当前船只距离目标港口的距离
			local last_dis = Math.distance(self.last_ship_x, self.last_ship_y, cur_x, cur_y)--船只移动的距离
			if cur_dis <= self.goal_dis_max then--当距离小于250的时候，10秒一到也算完成
				self.ship_pos_dt = self.ship_pos_dt + delta_time
				if self.ship_pos_dt >= self.limit_dt_max and (not IS_AUTO) then--累加到时间且没有自动导航就自动触发协议
					self.wait_to_send_port_rpc = false
					local str_1 = string.format("  IS_AUTO %s 玩家：%s 间隔：%s 目标：%s,%s  当前坐标：%s %s  上次坐标：%s %s  距离：%s", tostring(IS_AUTO), getGameData():getPlayerData():getUid(), os.time(), pos.x, pos.y, cur_x, cur_y, self.last_ship_x, self.last_ship_y, cur_dis)
					auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeMove:__dealAction line 102 : " .. self.ship_pos_dt .. " \n 坐标：" .. str_1 .. " \n " .. auto_trade_data:getTradeLog())
					local mission_data_handler = getGameData():getMissionData()
					mission_data_handler:askTeamMissionComplateStatus(self.port_id)
					return self.move_to_port
				end
			elseif last_dis == 0 then
				self.stop_move_time = self.stop_move_time + delta_time
				if self.stop_move_time >= self.stop_move_max then
					--停留在一个坐标点上超过限制时间了，这时候强制做处理
					if goal_port_id then
						local str_1 = string.format("IS_AUTO %s 玩家：%s 间隔：%s 目标：%s,%s  当前坐标：%s %s  上次坐标：%s %s  距离：%s", tostring(IS_AUTO), getGameData():getPlayerData():getUid(), os.time(), pos.x, pos.y, cur_x, cur_y, self.last_ship_x, self.last_ship_y, cur_dis)
						if IS_AUTO then--自动中，但是暂停了，这里再增加其他上报数据
							sendMsgToServer("ClsAIActionTradeMove 在海上停留不动超过时间" .. self.limit_dt_max .. " 目标港口是：" .. tostring(goal_port_id) .. " 内容:\n" .. str_1 .. " \n " .. auto_trade_data:getTradeLog() .. " \n  getShipStopReasons : \n" .. auto_trade_data:getShipStopReasons())
						else
							sendMsgToServer("ClsAIActionTradeMove 118 :\n" .. str_1 .. " \n目标港口是：" .. goal_port_id  .. " \n " .. auto_trade_data:getTradeLog() .. " \n  getShipStopReasons : \n" .. auto_trade_data:getShipStopReasons())
							EventTrigger(EVENT_EXPLORE_AUTO_SEARCH, {id = goal_port_id, navType = EXPLORE_NAV_TYPE_PORT})
						end
					else
						sendMsgToServer("ClsAIActionTradeMove EVENT_EXPLORE_AUTO_SEARCH 找不到 goal_port_id")
					end
					self.stop_move_time = 0
				end
			else
				self.ship_pos_dt = 0
				self.stop_move_time = 0
			end
			-- local str_1 = string.format("IS_AUTO %s 玩家：%s 间隔：%s 目标：%s,%s  当前坐标：%s %s  上次坐标：%s %s  距离：%s", tostring(IS_AUTO), getGameData():getPlayerData():getUid(), os.time(), pos.x, pos.y, cur_x, cur_y, self.last_ship_x, self.last_ship_y, cur_dis)
			-- local log_str = "ClsAIActionTradeMove 118 :" .. str_1 .. " 目标港口是：" .. tostring(goal_port_id)  .. " \t " .. auto_trade_data:getTradeLog() .. " \t  getShipStopReasons : " .. auto_trade_data:getShipStopReasons()
			-- print(log_str)
			self.last_ship_x = cur_x
			self.last_ship_y = cur_y
		end
	else
		return false
	end
	return self.move_to_port
end

function ClsAIActionTradeMove:dispos()
	UnRegTrigger(EVENT_PORT_EXPLORE_ENTER, self.event_key)
	UnRegTrigger(EVENT_PORT_TRADE_RPC_PORT, self.event_key)
end

return ClsAIActionTradeMove
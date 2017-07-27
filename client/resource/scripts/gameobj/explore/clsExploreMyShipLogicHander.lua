--2016/11/22
--create by wmh0497
--用于显示在探索里同步的玩家船

local ClsExploreMyShipLogicHander = class("ClsExploreMyShipLogicHander")

function ClsExploreMyShipLogicHander:ctor(explore_layer, ships_layer)
	self.m_explore_layer = explore_layer
	self.m_ships_layer = ships_layer
	
	self.m_port_pos = {}
	self.m_play_port_id = 0
	self.m_max_ship_timer = 0
	self.check_trace_dt = 0
	self.m_is_change_max_ship = false
	self:initPortPosInfo()
end

function ClsExploreMyShipLogicHander:initPortPosInfo()
	local port_info = require("game_config/port/port_info")
	for port_id, port_cfg_item in pairs(port_info) do
		local px, py = self.m_ships_layer:tileToCocos(port_cfg_item.ship_pos[1], port_cfg_item.ship_pos[2])
		self.m_port_pos[port_id] = {x = px, y = py}
	end
end

--地图更新回调
function ClsExploreMyShipLogicHander:update(dt)
	self:checkIsBreakAutoAndDrop()
	self:updateExploreMapPosDesc()
	self:updateAutoCloseToPortSound()
	self:updateMaxShowShipCount(dt)

	--每隔5*dt检查一次
	self.check_trace_dt = self.check_trace_dt + dt
	if self.check_trace_dt >= 1000 * dt then
		self.check_trace_dt = 0
		self:updateTraceEvent()
	end
end

--检测追踪目标位置
function ClsExploreMyShipLogicHander:updateTraceEvent()
	--进行cocos坐标计算
	local pos_info = self.m_ships_layer:getMyShipPosInfo()
	local loot_data = getGameData():getLootData()
	loot_data:updateTraceEvent(self.m_ships_layer, ccp(pos_info.x, pos_info.y))
end

function ClsExploreMyShipLogicHander:checkIsBreakAutoAndDrop()
	if IS_AUTO then
		if getGameData():getTeamData():isLock() then
			self.m_explore_layer:getLand():breakAuto(true)
		end
	end
	if self.m_ships_layer:getIsDroping() and getGameData():getTeamData():isLock() then
		getExploreUI():releaseDropAchnor()
	end
end

function ClsExploreMyShipLogicHander:updateExploreMapPosDesc()
	local explore_ui = getExploreUI()
	if not tolua.isnull(explore_ui) then
		local pos_info = self.m_ships_layer:getMyShipPosInfo()
		explore_ui:updateMapPointLab(pos_info.tx, pos_info.ty)
	end
end

local EFFECT_DIS2 = 300*300
function ClsExploreMyShipLogicHander:updateAutoCloseToPortSound()
	local pos_info = self.m_ships_layer:getMyShipPosInfo()
	if IS_AUTO then
		local auto_pos = getGameData():getExploreData():getAutoPos()
		if auto_pos and auto_pos.portId and (auto_pos.portId ~= self.m_play_port_id) then
			local port_pos = self.m_port_pos[auto_pos.portId]
			if port_pos then
				local dis2 = (port_pos.x - pos_info.x)*(port_pos.x - pos_info.x) + (port_pos.y - pos_info.y)*(port_pos.y - pos_info.y)
				if dis2 < EFFECT_DIS2 then
					getExploreUI():playAudio({m = "VOICE_EXPLORE_1000", f = "VOICE_EXPLORE_1020"})
					self.m_play_port_id = auto_pos.portId
				end
			end
		end
	else
		self.m_play_port_id = 0
	end
end

function ClsExploreMyShipLogicHander:updateMaxShowShipCount(dt)
	if self.m_is_change_max_ship then return end
	self.m_max_ship_timer = self.m_max_ship_timer + dt
	if self.m_max_ship_timer > 5 then
		self.m_max_ship_timer = 0
		local fps_n = Math.ceil(1/CCDirector:sharedDirector():getSecondsPerFrame())
		if fps_n < 30 then
			self.m_explore_layer:getShipsLayer():setMaxShowShipCount(5)
			self.m_is_change_max_ship = true
		end
	end
end

return ClsExploreMyShipLogicHander

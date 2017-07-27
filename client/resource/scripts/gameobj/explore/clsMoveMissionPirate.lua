--create by wmh0497
--2016/12/04
--时段海盗移动npc显示

local seaforce_boat_config = require("game_config/mission/seaforce_boat_config")

local ClsMoveMissionPirate = class("ClsMoveMissionPirate", function() return display.newSprite() end)

function ClsMoveMissionPirate:ctor(map)
	self.m_map = map
	self.m_scale_n = 1
	self.m_pirate_points = {}
	self:initUI()
end

function ClsMoveMissionPirate:initUI()
	self.m_scale_layer = display.newSprite()
	self:addChild(self.m_scale_layer)
	local repeat_act = require("ui/tools/UiCommon"):getRepeatAction(0.01, function() self:updatePos() end)
	self.m_scale_layer:runAction(repeat_act)
end

function ClsMoveMissionPirate:setIconScale(scale_n)
	if scale_n > 1 then
		scale_n = 1 + (scale_n - 1)*1.2
	end
	
	if scale_n == self.m_scale_n then return end
	self.m_scale_n = scale_n
	for _, point_info in pairs(self.m_pirate_points) do
		if point_info then
			point_info.head_spr:setScale(1/self.m_scale_n)
			for _, point_spr in ipairs(point_info.path_points) do
				point_spr:setScale(1/self.m_scale_n)
			end
		end
	end
end

function ClsMoveMissionPirate:updatePos()
	local missionPirateData = getGameData():getMissionPirateData()
	for cfg_id, _ in pairs(seaforce_boat_config) do
		local pirate_data = missionPirateData:getPirateByCfgId(cfg_id)
		if pirate_data then
			if not self.m_pirate_points[cfg_id] then
				self:createPoint(cfg_id, pirate_data)
			end
			local point_info = self.m_pirate_points[cfg_id]
			local x, y = missionPirateData:getPosInMap(cfg_id)
			point_info.head_spr:setPosition(x, y)
		else
			if self.m_pirate_points[cfg_id] then
				self:removePoint(cfg_id)
			end
		end
	end
end

function ClsMoveMissionPirate:createPoint(cfg_id, pirate_data)
	local info = {path_points = {}, head_spr = nil}
	local head_spr = display.newSprite("#map_boss.png")
	head_spr:setAnchorPoint(ccp(0.5, 0.5))
	head_spr:setScale(1/self.m_scale_n)
	self.m_scale_layer:addChild(head_spr, 1)
	info.head_spr = head_spr
	
	local missionPirateData = getGameData():getMissionPirateData()
	local pos_data = missionPirateData:getPosData(cfg_id)
	if pos_data.is_change then
		for _, v in ipairs(missionPirateData:getMapPathPointPos(cfg_id)) do
			local point_spr = display.newSprite("#common_point.png")
			point_spr:setAnchorPoint(ccp(0.5, 0.5))
			point_spr:setPosition(v.x, v.y)
			point_spr:setScale(1/self.m_scale_n)
			self.m_scale_layer:addChild(point_spr, 0)
			table.insert(info.path_points, point_spr)
		end
	end
	
	self.m_pirate_points[cfg_id] = info
end

function ClsMoveMissionPirate:removePoint(cfg_id)
	local info = self.m_pirate_points[cfg_id]
	if not info then return end
	
	info.head_spr:removeFromParentAndCleanup(true)
	for k, v in ipairs(info.path_points) do
		v:removeFromParentAndCleanup(true)
	end
	self.m_pirate_points[cfg_id] = nil
end

function ClsMoveMissionPirate:updateTargetPos()
end

return ClsMoveMissionPirate

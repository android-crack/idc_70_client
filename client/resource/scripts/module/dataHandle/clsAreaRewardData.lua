--2017/01/17
--create by wmh0497
--海域奖励信息存储地

local ClsAreaRewardData = class("clsAreaRewardData")

function ClsAreaRewardData:ctor()
	self.m_area_reward_data = {}
	self.m_area_status_data = {}
	self:initRewardData()
end

function ClsAreaRewardData:initRewardData()
	local area_reward_cfg = require("game_config/collect/area_reward_cfg")
	local area_info = require("game_config/port/area_info")
	for area_id, area_item in pairs(area_info) do
		local reward_info = {}
		reward_info.port = {}
		for i, invest_point in ipairs(area_item.port_invest_points) do
			local info = {}
			info.point = invest_point
			info.gold = 0
			for _, reward_cfg_item in pairs(area_reward_cfg) do
				if reward_cfg_item.area_id == area_id and reward_cfg_item.invest_num == invest_point then
					info.gold = reward_cfg_item.cnt
					break
				end
			end
			reward_info.port[i] = info
		end
		
		reward_info.relic = {}
		for i, discover_point in ipairs(area_item.relic_discover_points) do
			local info = {}
			info.point = discover_point
			info.gold = 0
			for _, reward_cfg_item in pairs(area_reward_cfg) do
				if reward_cfg_item.area_id == area_id and reward_cfg_item.relic_num == discover_point then
					info.gold = reward_cfg_item.cnt
					break
				end
			end
			reward_info.relic[i] = info
		end
		
		self.m_area_reward_data[area_id] = reward_info
	end
end

function ClsAreaRewardData:getAreaReward(area_id)
	return self.m_area_reward_data[area_id]
end

function ClsAreaRewardData:setAreaRewardStatus(area_id, data)
	self.m_area_status_data[area_id] = data

	local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
	if not tolua.isnull(explore_map) then
		explore_map:updateAreaReward(data)
	end
end

function ClsAreaRewardData:getAreaRewardStatus(area_id)
	return self.m_area_status_data[area_id]
end

function ClsAreaRewardData:askGetAreaPortReward(area_id)
	self:askGetAreaReward(1, area_id)
end

function ClsAreaRewardData:askGetAreaRelicReward(area_id)
	self:askGetAreaReward(2, area_id)
end


function ClsAreaRewardData:askGetAreaReward(type_n, area_id)
	GameUtil.callRpc("rpc_server_area_get_reward", {type_n, area_id})
end

function ClsAreaRewardData:askAreaRewardInfo(area_id)
	GameUtil.callRpc("rpc_server_area_reward_info", {area_id})
end

function ClsAreaRewardData:askAllAreaRewardInfo()
	for i = 1, 7 do
		self:askAreaRewardInfo(i)
	end
end

return ClsAreaRewardData
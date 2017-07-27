 --
-- Author: 0496
-- Date: 2016-03-08 19:44:13
-- Function: 海上新星系统数据管理
--

local clsSeaStarDataHandle = class("clsSeaStarDataHandle")
local sea_star_info = require("game_config/seaStar/new_star_data")

clsSeaStarDataHandle.ctor = function(self)
	self.info_data = {}
	self.SEA_STAR_VIEW_IS_VISIBLE = false
end

clsSeaStarDataHandle.initInfoData = function(self, info)
	self.info_data = info
	local seaStarUI = getUIManager():get("ClsSeaStarUI")
	if not tolua.isnull(seaStarUI) then
		seaStarUI:initUI()
	end

	local wefareMainUI = getUIManager():get("ClsWefareMain")
	if not tolua.isnull(wefareMainUI) then
		wefareMainUI:updateSeaStar()
	end

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:updataSeaStarTask()
	end
end

clsSeaStarDataHandle.getSeaStarStatus = function(self)
	return self.SEA_STAR_VIEW_IS_VISIBLE
end

clsSeaStarDataHandle.setSeaStarStatus = function(self, status)
	self.SEA_STAR_VIEW_IS_VISIBLE = status
end


clsSeaStarDataHandle.getInfoData = function(self)
	return self.info_data
end

clsSeaStarDataHandle.getMissionData = function(self, missionId)
	for k, v in pairs(self.info_data.progress) do
		if v.id == missionId then
			return v
		end
	end
end

clsSeaStarDataHandle.getFinishStarPointNum = function(self)
	return self.info_data.point, #self.info_data.progress
end

clsSeaStarDataHandle.getDayInfo = function(self, index) --获取某一天的配置任务信息
	local days = {}
	local ends = index * 5
	local start = ends - 4
	for i = start, ends do
		days[#days + 1] = table.clone(sea_star_info[i])
		days[#days].id = i
	end
	return days
end

clsSeaStarDataHandle.getUnlockDay = function(self)
	local new_today = 1
	local today = self.info_data.today
	
	for i = 1, 5 do
		local days = self:getDayInfo(i)
		for j = 1, #days do
			local day_data = self:getMissionData(days[j].id)
			if day_data.max_progress > day_data.progress then
				return new_today
			end
		end
		new_today = new_today + 1
	end
	
	return new_today
end

--是否把海上新星总进度的奖励该领的领完
clsSeaStarDataHandle.getIsNotReward = function(self)
	local SEA_STAR_OPEN = 1
	local SEA_STAR_PROGRESS_RECEIVE = 0
	local seaStarInfo = self:getInfoData()
	local sea_star_reward = require("game_config/seaStar/new_star_reward")
	local rewards = {}
	local is_not_reward = false
	for k, v in ipairs(sea_star_reward) do
		if v.point <= seaStarInfo.point then
			rewards[#rewards + 1] = true
		end
	end

	local today = seaStarInfo.today
	local new_today = self:getUnlockDay()
	if today > 5 then
		today = 5
	end
	
	if new_today <= today then
		new_today = today
	end

	if new_today > 5 then
		new_today = 5
	end

	if seaStarInfo.isOpen == SEA_STAR_OPEN then
		for i = 1, new_today do
			local days = self:getDayInfo(i)
			for j, v in ipairs(days) do
				local day_data = self:getMissionData(v.id)
				if day_data.status == SEA_STAR_PROGRESS_RECEIVE and day_data.progress >= day_data.max_progress then
					return is_not_reward
				end
			end
		end
	end

	return (#sea_star_reward == #seaStarInfo.rewardIndex) or (#rewards == #seaStarInfo.rewardIndex)
end


-------------------------------------------------------协议请求 BEGIN -------------------------------------------------------------

--请求海上新星任务的协议
clsSeaStarDataHandle.askSeaStarList = function(self)
	GameUtil.callRpc("rpc_server_new_star_list", {})
end

--单任务海上新星奖励请求
clsSeaStarDataHandle.askSeaStarSingleTaskReward = function(self, mission_id)
	GameUtil.callRpc("rpc_server_new_star_progress_get", {mission_id}, "rpc_client_new_star_progress_get")
end

--总进度领取奖励
clsSeaStarDataHandle.askSeaStarTotalTaskReward = function(self, index)
	GameUtil.callRpc("rpc_server_new_star_total_get", {index}, "rpc_client_new_star_total_get")
end


-----------------------------------------------------协议请求 END -----------------------------------------------------

return clsSeaStarDataHandle
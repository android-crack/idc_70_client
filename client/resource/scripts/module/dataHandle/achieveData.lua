local achievement_info = require("game_config/collect/achievement_info")

require("ui/rewardPopLayer")
local _rewardLayer = rewardPopLayer.new()

local AchieveData = class("AchieveData")

ACHIEVE_NO_FINISH = 0-- 未完成
ACHIEVE_FINISH_REWARD = 1 -- 完成未领取奖励
ACHIEVE_FINSH_NO_REWARD = 2-- 完成并领取

--[[class achieve_info_t{
       int achieveId;
       int step;
       int totalStar
       int status;
       int progress;
   }]]

function AchieveData:ctor()
	self.maxStar = 3
	self.achieveInfoDic = {}
	self.statsIdToAchieveIdDic = {}
	self.show_achieve_dic = {}
	
	for k, v in pairs(achievement_info) do
		for k1,v1 in ipairs(v.stats) do
			if not self.statsIdToAchieveIdDic[v1] then
				self.statsIdToAchieveIdDic[v1] = {}
			end
			self.statsIdToAchieveIdDic[v1][#self.statsIdToAchieveIdDic[v1] + 1] = k
		end
		if not self.show_achieve_dic[v.cell_index] then
			self.show_achieve_dic[v.cell_index] = {}
		end
		self.show_achieve_dic[v.cell_index][#self.show_achieve_dic[v.cell_index] + 1] = k
	end
	for k, v in pairs(self.show_achieve_dic) do
		table.sort(v, function(a, b) return tostring(a) < tostring(b) end)
	end

	local playerData = getGameData():getPlayerData()
	self:initWho(playerData:getUid())
end 

function AchieveData:getShowAchieveDic()
	return self.show_achieve_dic
end

function AchieveData:initWho(who)
	if not who then
		return false
	end
	if self.achieveInfoDic[who] then
		return true
	end
	self.achieveInfoDic[who] = {}
	self.achieveInfoDic[who].achieveVersionDic = {[""]=0}
	self.achieveInfoDic[who].achieveDic = {}

	for k,v in pairs(achievement_info) do
		self.achieveInfoDic[who].achieveDic[k] = v
		self.achieveInfoDic[who].achieveDic[k].id = k
		self.achieveInfoDic[who].achieveDic[k].status = ACHIEVE_NO_FINISH
		self.achieveInfoDic[who].achieveDic[k].step = 0
		self.achieveInfoDic[who].achieveDic[k].totalStar = #self.show_achieve_dic[v.cell_index] or self.maxStar

		self.achieveInfoDic[who].achieveDic[k].progressInfos = {}
		for k1,v1 in ipairs(v.stats) do
			self.achieveInfoDic[who].achieveDic[k].progressInfos[k1] = {progress=0, totalProgress=v.statslimit[k1] or 0}
		end

		if #v.achieve > 0 then
			self.achieveInfoDic[who].achieveDic[k].progressInfos[1] = {progress=0, totalProgress= 1}
		end
	end

	return true
end

function AchieveData:judgeAchieveReward()   --判断是否有成就领取
	local playerData = getGameData():getPlayerData()
	local achieveDic = self:getAchieveData(playerData:getUid())

	if not achieveDic then
		return false
	end

	for k, achieve in pairs(achieveDic) do
		if achieve.status == ACHIEVE_FINISH_REWARD then
			return true
		end
	end
	return false
end

function AchieveData:getAchieveInfo(who)
	if not who then return end
	return self.achieveInfoDic[who]
end

function AchieveData:getAchieveData(who, acheiveId) --获取具体某个或所以成就信息
	if not who then return end
	if not self.achieveInfoDic[who] then return end

	if acheiveId then
		return self.achieveInfoDic[who].achieveDic[acheiveId]
	else
		return self.achieveInfoDic[who].achieveDic
	end
end

--[[function AchieveData:getAchieveIds(kind)    --获取归类好的成就id列表
	if kind then 
		return achieveIds[kind]
	else
		return achieveIds
	end
end]]

function AchieveData:askGetReward(achieveId)   --领取成就
    GameUtil.callRpc("rpc_server_achieve_reward", {achieveId})
end

function AchieveData:getRewardLayer()
	return _rewardLayer
end

----------------------------------------新版成就----begin

function AchieveData:askAchieveInfo(aType)
	local playerData = getGameData():getPlayerData()
	local version = 0
	local who = playerData:getUid()
	local achieveInfo = self:getAchieveInfo(who)
	
	if achieveInfo then
		version = achieveInfo.achieveVersionDic[aType]
	end

	GameUtil.callRpc("rpc_server_achieve_get", {version,aType,who},"rpc_client_achieve_get")
end

function AchieveData:receiveAchieveInfo(who, achievement)
	local finishedAchieveIds = {}

	if not self:initWho(who) then
		return finishedAchieveIds
	end

	if achievement.type and achievement.version then
		self.achieveInfoDic[who].achieveVersionDic[achievement.type] = achievement.version
	end

	local achieveDic = self.achieveInfoDic[who].achieveDic

	local statsDic = {}
	for k,v in ipairs(achievement.stats) do
		statsDic[v.event] = v.value
	end

	local playerData = getGameData():getPlayerData()
	local isPlayer = false
	if who == playerData:getUid() then
		isPlayer = true
	end

	for k,v in ipairs(achievement.stats) do
		local achieveIds = self.statsIdToAchieveIdDic[v.event] or {}
		for k1,v1 in ipairs(achieveIds) do
			local achieveData = achieveDic[v1]
			if achieveData then
				for k2,v2 in ipairs(achieveData.stats) do
					achieveData.progressInfos[k2].progress = statsDic[v2] or 0

					if achieveData.progressInfos[k2].progress > achieveData.progressInfos[k2].totalProgress then
						achieveData.progressInfos[k2].progress = achieveData.progressInfos[k2].totalProgress
					end
				end
			end
		end
	end

	for k, v in ipairs(achievement.achieve) do
		local achieveData = achieveDic[v.event]
		if achieveData then
			local status = 0
			if v.finishtime == 0 then
				status = ACHIEVE_NO_FINISH
			else
				if achieveData.hasReward ~= 1 or v.rewarded ~= 0 then
					status = ACHIEVE_FINSH_NO_REWARD
				else
					status = ACHIEVE_FINISH_REWARD
				end
			end

			achieveData.status = status

			if status ~= ACHIEVE_NO_FINISH then
				for k1, v1 in ipairs(self.show_achieve_dic[achieveData.cell_index]) do
					if v1 == v.event then
						if status == ACHIEVE_FINSH_NO_REWARD then
							achieveData.step = k1
						else
							achieveData.step = k1 - 1
						end
						break
					end
				end
				
				if #achieveData.achieve > 0 then
					achieveData.progressInfos[1].progress = achieveData.progressInfos[1].totalProgress
				end
				finishedAchieveIds[#finishedAchieveIds + 1] = achieveData.id
			end
		end
	end

	if isPlayer then
		--更新界面
		local achievementUi = getUIManager():get("ClsAchievement")
		if not tolua.isnull(achievementUi) then
			achievementUi:updateAchieve()
		end
	end

	return finishedAchieveIds
end

function AchieveData:receiveAchieveFinishInfo(achievement) --成就达成
	local playerData = getGameData():getPlayerData()
	local finishedAchieveIds = self:receiveAchieveInfo(playerData:getUid(), {stats=achievement.stats, achieve={achievement.achieve}})
	for k,v in ipairs(finishedAchieveIds) do
		_rewardLayer:push(v)
		if isExplore then
			_rewardLayer:stop()
		else
			_rewardLayer:start()
		end
	end
end

----------------------------------------新版成就----end

return AchieveData


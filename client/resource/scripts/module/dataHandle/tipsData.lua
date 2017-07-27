local TipsData = class("TipsData")

function TipsData:ctor()
	self.sailorInfo = {}
	self.layer = {}
	self.drinkConsume = nil
end

function TipsData:recieveDrinkConsum(value)
	self.drinkConsume = value
end

function TipsData:getDrinkConsum()
	return self.drinkConsume
end

function TipsData:recieveSailorInfo(id, value)
	self.sailorInfo[id] = value
end

function TipsData:getSailorInfo()
	return self.sailorInfo
end

function TipsData:SetTable(name, table)
	self.layer[name] = table 
end

function TipsData:GetTable(name)
	return self.layer[name]
end

local scheduler = CCDirector:sharedDirector():getScheduler()
local function updateTimer()
	local tipsData = getGameData():getTipsData()
	local layer = tipsData:GetTable("portLayer")
	if tolua.isnull(layer) then return end

	if CheckHaveAnyMission() then
		layer.MissionButton.effect:setVisible(true)
	else
		layer.MissionButton.effect:setVisible(false)
	end
end
scheduler:scheduleScriptFunc(updateTimer, 1, false)

return TipsData
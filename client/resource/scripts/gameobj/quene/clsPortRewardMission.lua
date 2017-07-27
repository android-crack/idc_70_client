
---悬赏任务队列
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local dailyMission = require("gameobj/mission/dailyMission")
local ClsPortRewardMission = class("ClsPortRewardMission", ClsQueneBase)

function ClsPortRewardMission:ctor(data)
	self.data = data
end

function ClsPortRewardMission:getQueneType()
	return self:getDialogType().daily
end

function ClsPortRewardMission:excTask()
	dailyMission:createCompleteLayer(self.data.missionId, self.data.reward, self.data.isEnd, self.data.missionInfo, function()
		if self.data.callBackFunc ~= nil then
			self.data.callBackFunc()
		end
		self:TaskEnd()
	end)
end

return ClsPortRewardMission
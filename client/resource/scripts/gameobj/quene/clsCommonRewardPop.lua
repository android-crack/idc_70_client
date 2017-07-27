local Alert = require("ui/tools/alert")
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsCommonRewardPop = class("ClsCommonRewardPop", ClsQueneBase)

function ClsCommonRewardPop:ctor(data)
	self.data = data
end

function ClsCommonRewardPop:getQueneType()
	return self:getDialogType().commonReward
end

function ClsCommonRewardPop:excTask()
	Alert:showCommonReward(self.data.reward, function()
		if self.data.callBackFunc ~= nil then
			self.data.callBackFunc()
		end
		self:TaskEnd()
	end)
end

return ClsCommonRewardPop


--
-- Author: Ltian
-- Date: 2016-11-23 21:33:06
--
local Alert = require("ui/tools/alert")
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsAutoTradeRewardPopViewQuene = class("ClsAutoTradeRewardPopViewQuene", ClsQueneBase)

function ClsAutoTradeRewardPopViewQuene:ctor(data)
	self.data = data
end

function ClsAutoTradeRewardPopViewQuene:getQueneType()
	return self:getDialogType().auto_trade_reward_pop
end

function ClsAutoTradeRewardPopViewQuene:excTask()
	Alert:showCommonReward(self.data.reward, function()
		if self.data.callBackFunc ~= nil then
			self.data.callBackFunc()
		end
		self:TaskEnd()
	end)
end

return ClsAutoTradeRewardPopViewQuene
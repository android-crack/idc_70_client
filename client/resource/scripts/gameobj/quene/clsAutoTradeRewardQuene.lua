-- 自动经商奖励
-- Author: Ltian
-- Date: 2016-11-23 14:31:24
--

local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local Alert = require("ui/tools/alert")
local ClsAutoTradeRewardQuene = class("ClsAutoTradeReward", ClsQueneBase)
--数据初始化
function ClsAutoTradeRewardQuene:ctor(rewards)
	self.rewards = rewards
end

function ClsAutoTradeRewardQuene:getQueneType()
	return self:getDialogType().auto_trade_reward
end

function ClsAutoTradeRewardQuene:excTask()
	getUIManager():create("gameobj/autoTrade/clsAutoTradeReward", nil, self.rewards, function ( )
		self:TaskEnd()
	end)
end

return ClsAutoTradeRewardQuene

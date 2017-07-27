local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsShipRewardPop = class("ClsShipRewardPop", ClsQueneBase)

function ClsShipRewardPop:ctor(data)
	self.data = data
end

function ClsShipRewardPop:getQueneType()
	return self:getDialogType().ship_reward
end

function ClsShipRewardPop:excTask()
	getUIManager():create("gameobj/shipyard/clsDockCreateShipEffectLayer", nil, {boat_info = self.data.boatInfo, opacity = 180, call_back = function()
		if self.data.callBackFunc ~= nil then
			self.data.callBackFunc()
		end
		self:TaskEnd()
	end})
end

return ClsShipRewardPop


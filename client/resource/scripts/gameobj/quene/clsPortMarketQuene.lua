---交易所结算界面
local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsPortMarketQuene = class("ClsPortMarketQuene", ClsQueneBase)

function ClsPortMarketQuene:ctor(data)
	self.data = data
end

function ClsPortMarketQuene:getQueneType()
	return self:getDialogType().port_market_reward
end

function ClsPortMarketQuene:excTask()
	getUIManager():create("gameobj/port/clsPortMarketAccountView", {}, self.data.reward, self.data.profit_info, function ( )
		if self.data.call_back ~= nil then
			print()
			self.data.call_back()
		end
		self:TaskEnd()
	end)
end

return ClsPortMarketQuene
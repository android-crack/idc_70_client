local ClsQueneBase = require("gameobj/quene/clsQueneBase")
local ClsMarketHotSellQuene = class("ClsMarketHotSellQuene", ClsQueneBase)
local Alert = require("ui/tools/alert")

function ClsMarketHotSellQuene:ctor(data)
	self.data = data
end

function ClsMarketHotSellQuene:getQueneType()
	return self:getDialogType().shopping_guild_alert
end

function ClsMarketHotSellQuene:excTask()
	Alert:showDialogTips(self.data.sailor, self.data.rich_str, self.data.btn_name, self.data.data, self.data.btn_fun,
    		self.data.sail_fun, self.data.color, function()
    			self:TaskEnd()
    		end)
end

return ClsMarketHotSellQuene


-- 打开交易所，等待仓库物品数据协议返回
-- Author: chenlurong
-- Date: 2016-05-24 18:15:19
--

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionTradeOpenMarket = class("ClsAIActionTradeOpenMarket", ClsAIActionBase) 

function ClsAIActionTradeOpenMarket:getId()
	return "trade_open_market"
end


-- 初始化action
function ClsAIActionTradeOpenMarket:initAction()
	self.duration = 9999
	self.wait_rpc_store = true
	self.wait_rpc_cargo = true
end

function ClsAIActionTradeOpenMarket:__beginAction( target, delta_time )
	self.scene_data = getGameData():getSceneDataHandler()
	if getUIManager():isLive("ClsPortMarket") then
		print("================getUIManager:isLive(ClsPortMarket)")
		sendMsgToServer("ClsAIActionTradeOpenMarket ：gameobj/port/portMarket is live！！！！")
		getUIManager():close("ClsPortMarket")
	end
	getUIManager():create("gameobj/port/portMarket")
	if self.scene_data:isInExplore() then
		local ui_word = require("game_config/ui_word")
		local Alert =  require("ui/tools/alert")
		Alert:warning({msg = ui_word.AUTI_TRADE_FOOD_AUTO_TIPS ,size = 26})
	end

    RegTrigger(EVENT_PORT_MARKET_PORT_STORE,function(stores)
        self.wait_rpc_store = false
        UnRegTrigger(EVENT_PORT_MARKET_PORT_STORE)
    end)

    RegTrigger(EVENT_PORT_MARKET_PORT_CARGO,function(cargos)
        self.wait_rpc_cargo = false
        UnRegTrigger(EVENT_PORT_MARKET_PORT_CARGO)
    end)
    local auto_trade_data = getGameData():getAutoTradeAIHandler()
	auto_trade_data:addTradeLog("AI start is : ClsAIActionTradeOpenMarket:__beginAction")
	-- print("ClsAIActionTradeOpenMarket:__beginAction: to open market")
end

function ClsAIActionTradeOpenMarket:__dealAction( target, delta_time )
	-- print("===========ClsAIActionTradeOpenMarket:__dealAction", delta_time)
	return (self.wait_rpc_store or self.wait_rpc_cargo)
end

function ClsAIActionTradeOpenMarket:dispos()
	UnRegTrigger(EVENT_PORT_MARKET_PORT_CARGO)
	UnRegTrigger(EVENT_PORT_MARKET_PORT_STORE)
end

return ClsAIActionTradeOpenMarket
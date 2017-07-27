local tool=require("module/dataHandle/dataTools")
local Alert = require("ui/tools/alert")
local news=require("game_config/news")
local ui_word=require("game_config/ui_word")
local on_off_info=require("game_config/on_off_info")
local music_info = require("game_config/music_info")


local SUPPLY_GO_NOW = 1
local SUPPLY_GO_SAILING = 2
local SUPPLY_ONE_KEY = 3

local ClsSupplyData = class("SupplyData")

function ClsSupplyData:ctor()
    self.curFood = 0
    self.totalFood = 0
    self.curSailor = 0
    self.totalSailor = 0
    self.comsumeCash = 0
    self.askSupplyInfoCb = nil
    self.m_explore_ok_callback = nil
end

function ClsSupplyData:setTotalSailorAndFood(sailor_n, food_n)
    self.totalFood = food_n
    self.totalSailor = sailor_n
end

function ClsSupplyData:getTotalSailor()
    return self.totalSailor
end

function ClsSupplyData:getTotalFood()
    return self.totalFood
end

function ClsSupplyData:setCurFood(food_n)
    self.curFood = food_n
    self:updateMapInfo()
    local explore_ui = getUIManager():get("ExploreUI")
    if not tolua.isnull(explore_ui) then
        explore_ui:updateFood()
    end
end

function ClsSupplyData:getCurFood()
    return self.curFood
end

function ClsSupplyData:setCurSailor(sailor_n)
    self.curSailor = sailor_n
    self:updateMapInfo()
    self:updateSailorSpeedRate()
    local explore_ui = getUIManager():get("ExploreUI")
    if not tolua.isnull(explore_ui) then
        explore_ui:updateSailor()
    end
end

function ClsSupplyData:getCurSailor(sailor_n)
     return self.curSailor
end

function ClsSupplyData:getSailorSpeedRate()
    return math.pow(self.curSailor / self.totalSailor, 0.3) * 1
end

function ClsSupplyData:updateSailorSpeedRate()
    if self.totalSailor > 0 then
        local speed_rate = self:getSailorSpeedRate()
        local explore_layer = getExploreLayer()
        if not tolua.isnull(explore_layer) then
            local ships_layer = explore_layer:getShipsLayer()
            if not tolua.isnull(ship_layer) then
                ship_layer:setMyShipSailorSpeedRate(speed_rate)
            end
        end
    end
end

function ClsSupplyData:updateMapInfo()
    local ExploreMap = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
    if not tolua.isnull(ExploreMap) then
        EventTrigger(EVENT_PORT_SAILOR_FOOD, {self.curSailor, self.totalSailor, self.curFood, self.totalFood})
    end
end

--请求服务器水手食物
--wmh todo 这个方法已经没用啦
function ClsSupplyData:askSupplyInfo(mustAsk, callBack)
    if callBack then
        callBack()
    end
end

function ClsSupplyData:changeBoat()
    getGameData():getPlayerData():askPortExploreConsume()
end

--获取补充食物水手消耗多少银币
function ClsSupplyData:getSupplyConsumeCash()
    local cash = 0
    if self.curSailor >= 0 and self.curSailor < self.totalSailor then
        local gapSailor = self.totalSailor - self.curSailor
        local sailorCash = math.floor(math.min(math.floor(math.pow(2, math.floor(gapSailor / 25)) * 40), gapSailor * 200)/10)
        cash = cash + sailorCash
    end

    if self.curFood >= 0 and self.curFood < self.totalFood then
        local gapFood = self.totalFood - self.curFood
        local foodCash = math.floor(math.min(math.floor(math.pow(1.4, math.floor(gapFood / 500)) * 100), gapFood * 1)/10)
        cash = cash + foodCash
    end
    return math.floor(cash)
end

function ClsSupplyData:saveConsumeCash()
    self.comsumeCash = self:getSupplyConsumeCash()
end

function ClsSupplyData:getComsumeCash()
    return self.comsumeCash
end

--补给水手食物
function ClsSupplyData:askSupply(type)
    GameUtil.callRpc("rpc_server_port_explore_supply", {type},"rpc_client_port_explore_supply")
end

function ClsSupplyData:askSupplyFull()
    GameUtil.callRpc("rpc_server_collect_relic_supply", {},"rpc_client_collect_relic_supply")
end

--changeFood
function ClsSupplyData:subFood(num)
    GameUtil.callRpc("rpc_server_area_consume_sub", {1, num})
end
function ClsSupplyData:subSailor(num)
    GameUtil.callRpc("rpc_server_area_consume_sub", {2, num})
end

--不要直接用这个，用 explore_layer:getShipsLayer():setStopFoodReason("xxxxx")
function ClsSupplyData:askIsStopFood(is_stop)
    -- op == 1 停止消耗，2 继续消耗
    -- void rpc_server_area_consume_op(object user, int op);
    local is_stop_n = 2
    if is_stop then
        is_stop_n = 1
    end
    GameUtil.callRpc("rpc_server_area_consume_op", {is_stop_n})
end



function ClsSupplyData:receiveSupplyResult(supplyType)
    if self.m_explore_ok_callback and "function" == type(self.m_explore_ok_callback) then
        self.m_explore_ok_callback()
    end
    self.m_explore_ok_callback = nil
    self.curFood = self.totalFood
    self.curSailor = self.totalSailor
    if supplyType ~= SUPPLY_ONE_KEY then
        local text = string.format(news.EXPLORER_SUPPLY_CASH.msg, self:getComsumeCash())
        Alert:explorerSupplyAttention(text, function()
            getGameData():getExploreData():askStartExplore()
        end)
    else
        EventTrigger(EVENT_RELIC_SUPLY_DONE)
    end
end

--[[
--立即起航
]]
function ClsSupplyData:startExplore(callback, supplyType, returnCallBack, is_ignore_distance)
    self:saveConsumeCash()
    self.m_explore_ok_callback = nil
    local exploreData = getGameData():getExploreData()
    if supplyType and supplyType == SUPPLY_GO_SAILING then
        local result = self:getSupplyConsumeCash()
        --不需要补给，补给已满
        if result == 0 then
            exploreData:askStartExplore()
            if callback and type(callback) == "function" then
                callback()
            end
        else
            self.m_explore_ok_callback = callback
            self:askSupply(supplyType)
        end
        return
    end
    --预计补给是否大于最大补给的
    local predictSupply = getGameData():getExploreMapData():getExploreExpectFood()
    if predictSupply > self.totalFood * 0.7 and (supplyType ~= SUPPLY_GO_LOOT) and (is_ignore_distance ~= true) then --少于30%时就提示
        Alert:showAttention(ui_word.TOO_FAR_TOAST, returnCallBack, returnCallBack, function()
            local result = self:getSupplyConsumeCash()
            --不需要补给，补给已满
            if result == 0 then 
                exploreData:askStartExplore()
                if callback and type(callback) == "function" then
                    callback()
                end
            else
                self.m_explore_ok_callback = callback
                self:askSupply(supplyType)
            end
        end, {ok_text = ui_word.EXPLORE_SELECT_AGAIN, cancel_text = ui_word.GO_SAILING, use_orange_btn = true})
        return
    end

    --玩家补给未满
    local result = self:getSupplyConsumeCash()
    if result == 0 then
        exploreData:askStartExplore()
        if callback and type(callback) == "function" then
            callback()
        end
    else
        self.m_explore_ok_callback = callback
        if self.curSailor < self.totalSailor then
            self:askSupply(supplyType)
            return
        end

        if self.totalFood > predictSupply and predictSupply > self.curFood then
            self:askSupply(supplyType)
            return
        end

        if self.curFood < self.totalFood then
            self:askSupply(supplyType)
        end
    end
end

return ClsSupplyData

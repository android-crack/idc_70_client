local dataTools = require("module/dataHandle/dataTools")
local port_goods_info = require("game_config/port/port_goods_info")
local goods_supply_demand_info = require("game_config/port/goods_supply_demand_info")
local port_area = require("game_config/port/port_area")
local goods_info = require("game_config/port/goods_info")
local port_info = require("game_config/port/port_info")
local music_info = require("game_config/music_info")
local news = require("game_config/news")
local Alert = require("ui/tools/alert")
local daily_mission = require("game_config/mission/daily_mission")
local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")

local MarketData = class("MarketData")

local NOT_HOT_SELL = 0

function MarketData:ctor()
    self.lockGoods = nil       --港口为解锁的商品
    self.storeGoods = nil      --交易所销售的商品
    self.cargoGoods = nil      --玩家自己的商品
    self.emptyGridNum = 0      --多少个控格子
    self.totalGridNum = 0      --id不为0时候格子统计
    self.totalBulk = 0         --总容量
    self.can_buy_store_goods = false        --是否有物品可以购买

    self.money = {             --一键交金额数据
        firstCash = nil,
        secondCash = nil,
        thirdCash = nil,
        profit = nil,
    }

    self.maxProfitGood = nil
    self.cargoNeedGoodPortDic = nil
    self.port_all_good_info_dic = {}
    self.port_good_info_dic = {}
    self.cargo_area_list = {}
    
    self.hot_sell_ports = {}
end


--未解锁的商品
function MarketData:setLockGoods(portId, invest_step)
    self.lockGoods = {}
    local portLockGoods = dataTools:getPortLockGoods(portId)
    for step,lock in pairs(portLockGoods) do
        if step > invest_step then
            local store = dataTools:getGoods(lock.id)
            store.step = step
            store.kind = STORE_LOCK
            store.type = self:getGoodType(portId, lock.id)
            self.lockGoods[#self.lockGoods + 1] = store
        end
    end
    table.sort(self.lockGoods,function(a,b)
        return a.step < b.step
    end)
end

function MarketData:getGoodType(portId, goodId)  --判断是不是区域特产和港口特产
    local port=port_goods_info[portId].port
    for k,id in pairs(port) do
        if id==goodId then return GOODS_MODE_PORT end
    end
    local area=port_goods_info[portId].area
    for k,id in pairs(area) do
        if id==goodId then return GOODS_MODE_AREA end
    end
    return GOODS_MODE_NORMAL
end

function MarketData:getLockGoods()
    return self.lockGoods
end

--获取可以购买该商品的所有港口id（优先获取距离portId最近、中立或被占领的港口）
function MarketData:getGoodSupplyPorts(goodId, portId)
    local ports = {}
    if not goodId then
        return ports
    end
    local exploreMapData = getGameData():getExploreMapData()
    local mapAttrs = getGameData():getWorldMapAttrsData()
    local portStatus = 0
    local portDistance = 0
    local minPortId = nil
    local minPortDistance = nil
    for k,v in ipairs(goods_supply_demand_info[goodId].supplyPorts) do
        portStatus = mapAttrs:getPortStatus(v)
        if portStatus == PORT_STATUS_ZHONGLI or portStatus == PORT_STATUS_ZHANLING then
            ports[#ports + 1] = v
            if portId then
                portDistance = exploreMapData:getPort2PortDistance(portId, v)
                if not minPortDistance or portDistance <= minPortDistance then
                    minPortDistance = portDistance
                    minPortId = v
                end
            end
        end
    end
    if minPortId then
        return {minPortId}
    end
    if #ports > 0 then
        return ports
    end
    return goods_supply_demand_info[goodId].supplyPorts
end

--获取需求该商品的所有港口id（优先获取当前海域中立或被占领的港口, 若当前海域没有需求主要货物、次要货物的港口，则选择距离portId最近的三个港口）
function MarketData:getGoodDemandPorts(goodId, portId)
    local ports = {}
    local sameAreaPorts = {}
    if not goodId then
        return ports
    end

    local exploreMapData = getGameData():getExploreMapData()
    local portData = getGameData():getPortData()
    local mapAttrs = getGameData():getWorldMapAttrsData()

    local function sortPorts(a,b)
        return a.distance<b.distance
    end

    local portStatus = 0
    local portDistance = 0
    local portInfo = nil
    local portInfos = {}
    for k,v in ipairs(goods_supply_demand_info[goodId].demandPorts) do
        portStatus = mapAttrs:getPortStatus(v)
        if portStatus == PORT_STATUS_ZHONGLI or portStatus == PORT_STATUS_ZHANLING then
            if portId then
                if goods_info[goodId].breed ~= GOOD_TYPE_AREA or port_info[v].areaId ~= portData:getPortAreaId() then
                    portDistance = exploreMapData:getPort2PortDistance(portId, v)
                    portInfos[#portInfos + 1] = {portId=v, distance=portDistance}
                end
            end
        end
    end

    if #portInfos > 0 then
        table.sort(portInfos, sortPorts)

        for k,v in pairs(portInfos) do
            ports[#ports + 1] = v.portId
        end

        return ports
    end

    return goods_supply_demand_info[goodId].demandPorts
end

function MarketData:getNeedGoodPorts(goodId, portId, goodClass)
    local ports = {}
    if not goodId then
        return ports
    end

    local exploreMapData = getGameData():getExploreMapData()
    local portData = getGameData():getPortData()
    local mapAttrs = getGameData():getWorldMapAttrsData()

    local function sortPorts(a,b)
        return a.distance < b.distance
    end

    if goodId and goodClass then
        local needPortIds = self:getNeedPortEx(goodId, goodClass)

        if #needPortIds > 0 then
            local portStatus = 0
            local portDistance = 0
            local portInfos = {}
            for k,v in pairs(needPortIds) do
                portStatus = mapAttrs:getPortStatus(v)
                if portStatus == PORT_STATUS_ZHONGLI or portStatus == PORT_STATUS_ZHANLING then
                    if portId then
                        portDistance = exploreMapData:getPort2PortDistance(portId, v)
                        portInfos[#portInfos + 1] = {portId=v, distance=portDistance}
                    end
                end
            end
            if #portInfos > 0 then
                table.sort(portInfos, sortPorts)

                for k,v in pairs(portInfos) do
                    ports[#ports + 1] = v.portId
                end

                return ports
            end
        end
    end

    return ports
end
function MarketData:askEnterMarket()
    GameUtil.callRpc("rpc_server_port_enter_market", {})
end

function MarketData:askBoatGoodsInfo()
    GameUtil.callRpc("rpc_server_boat_goods_info", {},"rpc_client_boat_goods_info")
end

function MarketData:askStoreGoods(port_id)
    if not port_id then return end
    GameUtil.callRpc("rpc_server_port_goods_list", {port_id},"rpc_client_port_goods_list")
end

--交易所左边商品
function MarketData:receiveStoreGoods(stores, invest_step, port_id)
    --  print("商店货物---------->")
    local tab={}
    local isFind=false

    local portData = getGameData():getPortData()
    port_id = port_id or portData:getPortId()

    self.can_buy_store_goods = false
    for k,v in ipairs(stores) do
        local good = dataTools:getGoods(v.goodsId)
        good.price = v.price
        good.amount = v.amount
        good.type = v.type
        good.isHotSell = v.isHotSell
        if good.amount == 0 then   --卖光
            good.kind = STORE_EMPTY
        else                     --可以买
            good.kind=STORE_NORMAL
            self.can_buy_store_goods = true
        end
        tab[#tab+1]=good
        self:setStoreGoodNumByPortId(port_id, v.goodsId, good.amount)
        --      print("商品名字",good.name,"    商品id",good.id,"  数量",good.amount," 商品类型  ",good.type)
    end

    self.storeGoods = tab
    --排序 按解锁的顺序排序
    local port_lock_good=require("game_config/port/port_lock_good")
    local portLockGoods = port_lock_good[port_id]
    local sortGoods = {}
    for step,lock in pairs(portLockGoods) do
        sortGoods[lock.id] = step
    end
    table.sort(self.storeGoods, function(a,b)
        if (not sortGoods[a.id]) or
            (sortGoods[b.id] and sortGoods[a.id]< sortGoods[b.id]) then
            return true
        end
    end)

    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    if auto_trade_data:inAutoTradeAIRun() then
        self:setLockGoods(port_id, invest_step)
    end

    local marketLayer = getUIManager():get("ClsPortMarket")
    if not tolua.isnull(marketLayer) then
        marketLayer:updateStore(self.storeGoods)
    end
    EventTrigger(EVENT_PORT_MARKET_PORT_STORE2, self.storeGoods)
    EventTrigger(EVENT_PORT_MARKET_PORT_STORE, self.storeGoods)--用于通知自动经商AI已有数据了
end

--是否有可以购买的物品
function MarketData:isStoreGoods()
    return self.can_buy_store_goods
end

function MarketData:getStoreGoods()
    return self.storeGoods
end

--交易所右边玩家自己的货物
function MarketData:getBoxGood(item)
    local box_item = table.clone(item)
    if item.good_id > 0 then
        box_item.good_info = dataTools:getGoods(item.good_id)
        box_item.profit = item.price - item.base_price
        box_item.tradeAmount = 0
        box_item.tipsCount = 0  --交易所流行商品提示次数初始化
    end
--            print("商品名字",good.name,"    商品id",good.id,"  数量",good.amount," 类型",good.class)
    return box_item
end


function MarketData:getMaxProfitGood()

    return self.maxProfitGood
end

function MarketData:receiveCargo(boxs)
    self.totalBulk = 0
    self.emptyGridNum = 0
    self.totalGridNum = 0
    self.maxProfitGood = nil
    self.cargoNeedGoodPortDic = nil
    self.cargo_area_list = nil

    local portData = getGameData():getPortData()
    local cur_port_id = portData:getPortId()
    local cur_area_id = portData:getPortAreaId()
    local cargos = {}

    local refresh_ports, not_refresh_ports = {}, {}
    self.business_ports = self.business_ports or {}

    table.sort(boxs, function(a,b)
        return a.index < b.index
    end)

    local function setCargoNeedGoodPortDic(good)
        if good.good_info.breed == GOOD_TYPE_AREA then
            if not self.cargo_area_list then
                self.cargo_area_list = {}
            end
            local cargo_good_area = {}
            local port_ids = {}
            local is_cur_area_good = false

            for k,v in ipairs(goods_supply_demand_info[good.good_id].supplyPorts) do
                cargo_good_area[port_info[v].areaId] = true
                --print("===============cur_area_id == port_info[v].areaId", cur_area_id, port_info[v].areaId)
                if cur_area_id == port_info[v].areaId then
                    is_cur_area_good = true
                end
            end

            for area_id, ports in ipairs(port_area) do
                if not cargo_good_area[area_id] then
                    for i,port_id in ipairs(ports) do
                        port_ids[port_id] = true
                    end
                end
            end
            self.cargo_area_list[good.good_id] = port_ids
            good.is_cur_area_good = is_cur_area_good

            return
        end
        local needGoodPorts = self:getNeedGoodPorts(good.good_id, cur_port_id, good.good_info.class)
        if needGoodPorts then
            for k, v in pairs(needGoodPorts) do
                if not self.cargoNeedGoodPortDic then
                    self.cargoNeedGoodPortDic = {}
                end
                self.cargoNeedGoodPortDic[v] = good.good_id

                if self.business_ports[v] then
                    self.business_ports[v] = nil
                    not_refresh_ports[v] = v
                else
                    refresh_ports[v] = v
                end
            end
        end
    end

    for k, box in pairs(boxs) do
        local box_data = self:getBoxGood(box)
        if box.boat_type and box.boat_type ~= 0 then  --正常船上的货物
            self.totalGridNum = self.totalGridNum + 1
            if box_data.good_id > 0 then --数据格式改为：直接clone一次数据，增加good_info为读表的数据
                setCargoNeedGoodPortDic(box_data)
            else
                self.emptyGridNum = self.emptyGridNum + 1
            end
            self.totalBulk = self.totalBulk + box_data.load
            cargos[#cargos + 1] = box_data
        else  --非正常交易的货物 如打捞获得的
            cargos[#cargos + 1] = box_data
            setCargoNeedGoodPortDic(box_data)
        end
    end
    self.cargoGoods = cargos

    local marketLayer = getUIManager():get("ClsPortMarket")
    if not tolua.isnull(marketLayer) then
        marketLayer:updateCargo(self.cargoGoods)
    end

    ---商会研究所： 队长操作数据时，刷新队员的界面显示
    local ClsGuildResearchGoodsTips = getUIManager():get("ClsGuildResearchGoodsTips")
    if not tolua.isnull(ClsGuildResearchGoodsTips) then
        ClsGuildResearchGoodsTips:updateGoodsInfo()
    end


    EventTrigger(EVENT_PORT_MARKET_PORT_CARGO, self.cargoGoods)--用于通知自动经商AI已有数据了

    local explore_map = getUIManager():get("ExploreMap")
    if not explore_map then
        self.business_ports = {}
    else
        explore_map:updatePortUnderCurArea(self.business_ports)
        self.business_ports = refresh_ports
        explore_map:updatePortUnderCurArea(self.business_ports)
        for k, v in pairs(not_refresh_ports) do
            self.business_ports[k] = v
        end
    end
end

function MarketData:isPortDemandCargoGood(portId)
    if self.cargoNeedGoodPortDic and self.cargoNeedGoodPortDic[portId] then
        return true
    end
    return false
end

-- function MarketData:isPortDemandGood(goodId, portId)
--     if not goods_supply_demand_info[goodId] then
--         return false
--     end
--     for k,v in ipairs(goods_supply_demand_info[goodId].demandPorts) do
--         if portId == v then
--             return true
--         end
--     end

--     return false
-- end

function MarketData:isPortSupplyGood(goodId, portId)
    if not goods_supply_demand_info[goodId] then
        return false
    end
    for k,v in ipairs(goods_supply_demand_info[goodId].supplyPorts) do
        if portId == v then
            return true
        else
            local good_info = goods_info[goodId]
            if good_info.breed == GOOD_TYPE_AREA and port_info[v].areaId == port_info[portId].areaId then
                return true
            end
        end
    end

    return false
end

function MarketData:getNeedPortEx(goodId, goodClass)
    local portIds = getGameData():getWorldMapAttrsData():getNeedPort(goodClass)
    local demandPortIds = {}

    if portIds then
        local _isPortSupplyGood = nil
        for k,v in ipairs(portIds) do
            _isPortSupplyGood = self:isPortSupplyGood(goodId, v)
            if not _isPortSupplyGood then
                demandPortIds[#demandPortIds + 1] = v
            end
        end
    end

    return demandPortIds
end

local function getMinDisPortId(portIds, curPortId)
    local portStatus = 0
    local portDistance = 0
    local minPortId = nil
    local min_good_id = nil
    local minPortDistance = nil
    for k,v in ipairs(portIds) do
        portStatus = getGameData():getWorldMapAttrsData():getPortStatus(v.id)
        if portStatus == PORT_STATUS_ZHONGLI or portStatus == PORT_STATUS_ZHANLING then
            if curPortId then
                if not require("game_config/port/port2port_distance_info")[curPortId] then
                    portDistance = 1
                else
                    portDistance = require("game_config/port/port2port_distance_info")[curPortId][v.id]
                end
                if portDistance and (not minPortDistance or minPortDistance > portDistance) then
                    minPortDistance = portDistance
                    minPortId = v.id
                    min_good_id = v.good_id
                end
            end
        end
    end
    return minPortId, min_good_id
end

--临时函数
function MarketData:judgePortGoodIdForTemp(goodId,portId) --判断当前的港口是否有某些商品
    local portData = getGameData():getPortData()
    portId =portId or portData:getPortId()
    local class=goods_info[goodId].class
    for k ,goodIds in pairs(port_goods_info[portId]) do
        for k,id in pairs(goodIds) do
            if goods_info[id].class==class then return true end
        end
    end
end

function MarketData:judgeAreaGoodId(goodId)
    local portData = getGameData():getPortData()
    local areaId=portData:getPortAreaId()
    for k,portId in pairs(port_area[areaId]) do
        if self:judgePortGoodIdForTemp(goodId,portId) then
            return true
        end
    end
end

function MarketData:getMinDistancePortId()
    local portData = getGameData():getPortData()
    local curPortId = portData:getPortId()
    local port_id = nil
    local good_id = nil
    local port_ids = {}
    if self.cargo_area_list then
        -- print("==================self.cargo_area_list")
        -- table.print(self.cargo_area_list)
        for k,ports in pairs(self.cargo_area_list) do
            for port,state in pairs(ports) do
                port_ids[#port_ids + 1] = {id = port, good_id = k}
            end
        end
        port_id, good_id = getMinDisPortId(port_ids, curPortId)
        if port_id then
            return port_id, good_id
        end
    end

    if self.cargoNeedGoodPortDic then
        for k,v in pairs(self.cargoNeedGoodPortDic) do
            port_ids[#port_ids + 1] = {id = k, good_id = v}
        end
        port_id, good_id = getMinDisPortId(port_ids, curPortId)
    end
    return port_id, good_id
end

--是否已经买了海域商品了
function MarketData:hasAreaGoodsInCargo()
    if self.cargo_area_list then
        for k,v in pairs(self.cargo_area_list) do
            return true
        end
    end
    return false
end

--交易所一键购买
function MarketData:oneKeySell(is_trade)
    if not self.cargoGoods then return end--数据还没有过来，做容错处理
    local marketLayer = getUIManager():get("ClsPortMarket")
    if marketLayer == nil or tolua.isnull(marketLayer) then return end

    local playerData = getGameData():getPlayerData()
    self.money.firstCash = playerData:getCash()
    self.money.profit = 0
    local indexs = {} --统计卖出的细胞位置来做商品飞动
    local tempCargoGoods = table.clone(self.cargoGoods)
    if not tempCargoGoods then
        return
    end
    local cargoData = {}
    for index ,box in pairs(tempCargoGoods) do
        if box.good_id > 0 and box.profit > 0 then--卖出有利润的商品
            cargoData[#cargoData + 1] = {
                boatId = box.boat_type,
            }
            table.insert(indexs, index)
            self.money.profit = self.money.profit + box.amount * box.profit
        end
    end
    if #cargoData > 0 then
        local toDeleteObj = {}
        for k, cell in pairs(marketLayer:getCargoCellList()) do
            cell:autoTap(toDeleteObj)
        end
        for _, cell in pairs(toDeleteObj) do
            marketLayer:delCargoCell(cell)
        end
    else
    end
    self:oneKeyBuy(is_trade)
end

function MarketData:oneKeyBuy(is_trade)
    local marketLayer = getUIManager():get("ClsPortMarket")
    if marketLayer==nil or tolua.isnull(marketLayer) then return end
    --买进 先星级--港口特产 区域特产  普通商品
    local tempStoreGoods = table.clone(self.storeGoods)
    if not tempStoreGoods then
        return
    end
    table.sort(tempStoreGoods, function(a,b)
        if a.isHotSell ~= b.isHotSell then
            return a.isHotSell > b.isHotSell
        end
        return a.level > b.level
    end)

    local cargoGoodsBuy = {}

    if not is_trade then
        --悬赏任务商品
        local mission_data_handler = getGameData():getMissionData()
        local cur_daily_mission_data = mission_data_handler:getHotelRewardAccept()
        if cur_daily_mission_data then
            local daily_mission_base = daily_mission[cur_daily_mission_data.missionId]
            if daily_mission_base and daily_mission_base.mission_type == DAILY_MISSION_TYPE_SHOPPING and cur_daily_mission_data.json_info then
                for k,store in pairs(tempStoreGoods) do
                    if store.id == cur_daily_mission_data.json_info.goodsId then
                        cargoGoodsBuy[#cargoGoodsBuy + 1] = {store = store, mission_need_num = cur_daily_mission_data.json_info.amount}
                        break
                    end
                end
            end
        end
    end

    --热销
    for k,store in pairs(tempStoreGoods) do
        if store.type == GOODS_MODE_SELL_HOT and store.breed ~= GOOD_TYPE_AREA then
            cargoGoodsBuy[#cargoGoodsBuy + 1] = {store = store}
            break
        end
    end
    if not is_trade then
        --区域特产
        for k,store in ipairs(tempStoreGoods) do
            if store.breed == GOOD_TYPE_AREA then
                cargoGoodsBuy[#cargoGoodsBuy + 1] = {store = store}
            end
        end
    end
    --港口特产
    for k,store in ipairs(tempStoreGoods) do
        if store.breed == GOOD_TYPE_PORT then
            cargoGoodsBuy[#cargoGoodsBuy + 1] = {store = store}
        end
    end
    --其他商品
    for i=1,#tempStoreGoods do   --商品根据等级从后面开始买
        if not (is_trade and tempStoreGoods[i].breed == GOOD_TYPE_AREA) then
            cargoGoodsBuy[#cargoGoodsBuy + 1] = {store = tempStoreGoods[i]}
        end
    end

    -- print("++++++++++++++++++++++++++++一键买入打印")
    -- table.print(cargoGoodsBuy)

    local cargoGoodsBuyLen = #cargoGoodsBuy
    -- print("++++++++++++++++++++++++++++一键买入打印", cargoGoodsBuyLen, cargoNum)
    if cargoGoodsBuyLen > 0 then
        self.has_show_nonenough = false
        self.has_music = false
        for i=1, cargoGoodsBuyLen do
            if cargoGoodsBuy[i].store then
                for k,cell in ipairs(marketLayer:getStoreCellList()) do
                    cell:autoTap(cargoGoodsBuy[i].store.id, cargoGoodsBuy[i].mission_need_num)
                end
            end
        end
    end
end

function MarketData:setAccountTips()
    local marketLayer = getUIManager():get("ClsPortMarket")
    if marketLayer==nil or tolua.isnull(marketLayer) then return end
    marketLayer:setSellBuyValue((self.money.thirdCash or self.money.secondCash)-self.money.firstCash,self.money.profit)
    self.money={}
end

function MarketData:receiveBuyResult()
    if self.money.secondCash then
        local playerData = getGameData():getPlayerData()
        self.money.thirdCash = playerData:getCash()
        self:setAccountTips()
    end
    self:marketSuccessBack()
end

function MarketData:getCargoAmount(goodId) --估计船运活动删除 这个东西就要删除
    if not self.cargoGoods then return end
    local amount=0
    for _,box in ipairs(self.cargoGoods) do
        --for key,good in pairs(box.good)do
            if box.good and box.good.id==goodId then
                amount=amount+box.good.amount
            end
        --end
    end
    return amount
end


function MarketData:getCargoGoodsInfoById(id)
    local goods_num = 0
    if #self.cargoGoods  < 1 then return end

    for k,v in pairs(self.cargoGoods) do
       if v.good_id ~= 0 and v.good_id == id then
            goods_num = goods_num + v.amount
       end
    end
    return goods_num
end

----获得物品的全部数量
function MarketData:getGoodsInfoById(id)
    local goods_all_num = 0
    if self.cargoGoods and #self.cargoGoods > 0 then
        for k,v in pairs(self.cargoGoods) do
           if v.good_id ~= 0 and v.good_id == id then
                goods_all_num = goods_all_num + v.amount
           end
        end
    end

    if self.storeGoods and #self.storeGoods > 0 then
        for k,v in pairs(self.storeGoods) do
           if v.id ~= 0 and v.id == id then
                goods_all_num = goods_all_num + v.amount
           end
        end
    end
    return goods_all_num   
end

---获的交易所中所有的物品
function MarketData:getGuildNeedGoods()
    local guild_research_data = getGameData():getGuildResearchData()
    
    local guild_need_goods_1 = {}
    if self.cargoGoods and #self.cargoGoods > 0 then
        for k,v in pairs(self.cargoGoods) do
            guild_need_goods_1[#guild_need_goods_1+ 1] = {id = v.good_id}
        end
    end

    local guild_need_goods_2 = {}
    if self.storeGoods and #self.storeGoods > 0 then
        for k,v in pairs(self.storeGoods) do
            guild_need_goods_2[#guild_need_goods_2+ 1] = {id = v.id}
        end
    end

    local id = 0
    local id_list = {}

    if #guild_need_goods_1 > 0 then
        for k,v in pairs(guild_need_goods_1) do
            if self:getGoodId(guild_need_goods_2,v.id) then
                guild_need_goods_2[#guild_need_goods_2 + 1] = {id = v.id}
            end
        end
    end

    return guild_need_goods_2
end

function MarketData:getGoodId(list, id)
    for k,v in pairs(list) do
        if v.id == id then
            return false
        end
    end
    return true 
end


function MarketData:getAllGoods()
    return self.cargoGoods,self.storeGoods
end


function MarketData:getCargoGoods()
    return self.cargoGoods
end

function MarketData:isFull()  --有空格子就为空
    return self.emptyGridNum == 0
end

function MarketData:isEmpty()   --所有格子为空
    return self.emptyGridNum == self.totalGridNum
end

function MarketData:getEmptyGridNum()
    return self.emptyGridNum
end

function MarketData:getTotalBulk()
    return self.totalBulk
end

function MarketData:findGood(id)
    if not self.storeGoods then return end
    for k,good in pairs(self.storeGoods) do
        if id==good.id then return true end
    end
end

function MarketData:buyGoods(store_id_data, store_order_data, market_parent)
    self.market_parent = market_parent
    if #store_id_data==0 then return end
    if #store_order_data==0 then return end

    GameUtil.callRpc("rpc_server_boat_buy_goods", {store_id_data, store_order_data},"rpc_client_business_buy_goods")
end

function MarketData:sellGoods(dataCargo, market_parent)
    self.market_parent = market_parent
    if #dataCargo == 0 then return end

    GameUtil.callRpc("rpc_server_boat_sell_goods", {dataCargo},"rpc_client_business_sell_goods")
end

--合并后的买卖
function MarketData:buyAndSellGoods(dataCargo,store_id_data,store_order_data,market_parent)
    self.market_parent = market_parent
    GameUtil.callRpc("rpc_server_boat_goods_sell_and_buy", {dataCargo,store_id_data,store_order_data}, "rpc_client_boat_goods_sell_and_buy")
end

--交易所交易成功后，进行相关跳转过来的界面的刷新处理
function MarketData:marketSuccessBack()
    if self.market_parent then
        if not tolua.isnull(self.market_parent) and type(self.market_parent.updateLabelCallBack) == "function" then
            self.market_parent:updateLabelCallBack()
        end
        self.market_parent = nil
    end
end

function MarketData:judgePortGoodId(goodId,portId) --判断当前的港口是否有某些商品
    local portData = getGameData():getPortData()
    portId = portId or portData:getPortId()
    local class=goods_info[goodId].class
    for k,good in pairs(self.storeGoods) do
        if good.class==class then
            return true
        end
    end
end
--临时函数
function MarketData:judgePortGoodIdForTemp(goodId,portId) --判断当前的港口是否有某些商品
    local portData = getGameData():getPortData()
    portId =portId or portData:getPortId()
    local class=goods_info[goodId].class
    for k ,goodIds in pairs(port_goods_info[portId]) do
        for k,id in pairs(goodIds) do
            if goods_info[id].class==class then return true end
        end
    end
end

function MarketData:judgeAreaGoodId(goodId)
    local portData = getGameData():getPortData()
    local areaId=portData:getPortAreaId()
    for k,portId in pairs(port_area[areaId]) do
        if self:judgePortGoodIdForTemp(goodId,portId) then
            return true
        end
    end
end

function MarketData:askPortGoodInfos(port_ids)
    GameUtil.callRpc("rpc_server_select_port_goods_list", {port_ids})
end

function MarketData:receivePortGoodInfos(port_good_infos)
    local all_good_list = nil
    local good_dic = nil
    local cur_good_num = 0
    local max_good_num = 0
    local good_base = nil
    self.hot_sell_ports = {}
    for k1,v1 in ipairs(port_good_infos) do
        good_dic = {}
        cur_good_num = 0
        max_good_num = 0

        local is_hot_sell = false
        for k2,v2 in ipairs(v1.list) do
            good_base = goods_info[v2.goodsId]
            v2.level = good_base.level
            if v2.amount <= 0 then
                v2.kind = STORE_EMPTY
            else
                v2.kind = STORE_NORMAL

                if v2.isHotSell ~= NOT_HOT_SELL and not is_hot_sell then
                    is_hot_sell = true
                end
            end
            good_dic[v2.goodsId] = true
        end

        all_good_list = self:getStoreAllGoodsByPortId(v1.portId)
        for k3,v3 in ipairs(all_good_list) do
            if not good_dic[v3] then
                --未解锁
                good_base = goods_info[v3]
                v1.list[#v1.list + 1] = {goodsId = v3, amount = 0, max = 0, type = 0, price = 0, basePrice = 0, kind = STORE_LOCK, level = good_base.level}
            end
        end

        for k4,v4 in pairs(v1.list) do
            if v4.kind ~= STORE_LOCK then
                port_good_base = goods_info[v4.goodsId]
                v4.cur_good_num = v4.amount
                v4.max_good_num = v4.max
                cur_good_num = cur_good_num + v4.cur_good_num
                max_good_num = max_good_num + v4.max_good_num
            else
                v4.cur_good_num = 0
                v4.max_good_num = 0
            end
        end

        self.port_good_info_dic[v1.portId] = {port_id = v1.portId, invest_step = v1.investStep or 0, list = v1.list, cur_good_num = cur_good_num, max_good_num = max_good_num}
        if is_hot_sell then
            self.hot_sell_ports[v1.portId] = true
        end
        EventTrigger(EVENT_PORT_GOOD_INFO_UPDATE, v1.portId)
    end
end

function MarketData:isHotSellPort(port_id)
    return self.hot_sell_ports[port_id] or false
end

--获取港口出售商品列表
function MarketData:getStoreAllGoodsByPortId(port_id)
    if self.port_all_good_info_dic[port_id] then
        return self.port_all_good_info_dic[port_id]
    end
    local all_good_list = {}
    for k1,v1 in pairs(port_goods_info[port_id]) do
        for k2,v2 in pairs(v1) do
            all_good_list[#all_good_list + 1] = v2
        end
    end
    self.port_all_good_info_dic[port_id] = all_good_list

    return all_good_list
end

--获取港口出售商品列表
function MarketData:getStoreGoodsByPortId(port_id)
    local good_list = {}
    if self.port_good_info_dic[port_id] then
        good_list = self.port_good_info_dic[port_id].list
    end
    return good_list
end

--获取商品存量
function MarketData:getStoreGoodNumByPortId(port_id)
    local cur_num, max_num = 0, 0
    local info = self:getStoreGoodInfoByPortId(port_id)
    if info then
        cur_num = info.cur_good_num
        max_num = info.max_good_num
    end
    return cur_num, max_num
end

--设置商品存量
function MarketData:setStoreGoodNumByPortId(port_id, good_id, good_num)
    local good_info = self:getStoreGoodInfoByPortId(port_id)
    if not good_info then return end
    local good_list = good_info.list
    if good_list then
        for i,v in ipairs(good_list) do
            if v.goodsId == good_id then
                good_info.cur_good_num = good_info.cur_good_num - (v.cur_good_num - good_num)
                v.cur_good_num = good_num
            end
        end
    end
end

--获取港口投资阶段
function MarketData:getInvestStepByPortId(port_id)
    local step = 0
    local info = self:getStoreGoodInfoByPortId(port_id)
    if info then
        step = info.invest_step
    end
    return step
end

--获取港口商品信息
function MarketData:getStoreGoodInfoByPortId(port_id)
    return self.port_good_info_dic[port_id]
end

--获得热销物品提示对话框处理
function MarketData:showMarketHotDialog(goods_id, production)
    local rich_str = news.PORT_MARKET_HOT_SELL_RANDOM.msg--
    if goods_id and goods_id > 0  then
        local tip_str = news.PORT_MARKET_HOT_SELL_PRODUCT.msg
        local tips_table = split(tip_str, ":")
        local good = goods_info[goods_id]
        local good_pro = goods_info[production]
        rich_str = string.format("$(c:0x%x)%s$(c:0x%x)%s$(c:0x%x)%s$(c:0x%x)%s$(c:0x%x)%s$(c:0x%x)%s$(c:0x%x)%s", COLOR_WHITE_STROKE, tips_table[1], COLOR_GREEN, good.name, COLOR_WHITE_STROKE, tips_table[2], COLOR_GREEN, good_pro.name, COLOR_WHITE_STROKE, tips_table[3], COLOR_GREEN, good_pro.name, COLOR_WHITE_STROKE, tips_table[4])
    end

    local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
    local ClsMarketHotSellQuene = require("gameobj/quene/clsMarketHotSellQuene")
    ClsDialogSequence:insertTaskToQuene(ClsMarketHotSellQuene.new({rich_str = rich_str}))
end

--获得热销物品，通过聊天点击
function MarketData:askPortHotSellShareGet(sharekey)
    GameUtil.callRpc("rpc_server_port_hot_sell_share_get", {sharekey}, "rpc_client_port_hot_sell_share_get")
end

function MarketData:showCurPortMarketDialog( funs )
    if self:isNeedToShowMarketDialog() then
        Alert:showDialogTips(nil, news.EXPLORER_EMPTY.msg, nil, nil, nil, funs, ccc4(0, 0, 0, 0), funs)
    else
        funs()
    end
end

--是否满足需要弹框的条件，第一当前的物品是需求品，第二是当前交易所还有空格且有物品可以购买
function MarketData:isNeedToShowMarketDialog()
    local onOffData = getGameData():getOnOffData()
    if not onOffData:isOpen(on_off_info.PORT_MARKET_TIPS.value) then
        return false
    end
    local investData = getGameData():getInvestData()
    if not investData:isUnlock() then
        return false
    end
    local port_data = getGameData():getPortData()
    local cur_port_id = port_data:getPortId() -- 当前港口
    local is_port_demand_good = self:isPortDemandCargoGood(cur_port_id)
    if is_port_demand_good then --推荐贸易港口
        -- table.print(is_port_demand_good)
        return true
    end

    if self:getEmptyGridNum() > 0 then
        local store_goods = self:getStoreGoodsByPortId(cur_port_id)
        if store_goods then
            local playerData = getGameData():getPlayerData()
            local player_cash = playerData:getCash()
            for k,v in ipairs(store_goods) do
                if v.kind == STORE_NORMAL then --可以买的时候
                    if v.max_good_num ~= 0 and v.cur_good_num > 0 then
                        if player_cash >= v.price then
                            return true
                        end
                    end
                end
            end
        end
    end

    return false
end

-- -- 获得自动经商目标港口id
-- function MarketData:getAutoTradePordId()
--     local port_data = getGameData():getPortData()
--     local curPortId = port_data:getPortId()
--     local port_id = nil
--     local port_ids = {}

--     local explore_map_data = getGameData():getExploreMapData()
--     if self.cargo_area_list then
--         -- print("==================self.cargo_area_list")
--         -- table.print(self.cargo_area_list)
--         for k,ports in pairs(self.cargo_area_list) do
--             for port,state in pairs(ports) do
--                 local cur_market_goods_num, max_market_goods_num = self:getStoreGoodNumByPortId(port)
--                 if cur_market_goods_num > 0 then
--                     port_ids[#port_ids + 1] = {id = port, good_id = k}
--                 end
--             end
--         end
--         port_id = getMinDisPortId(port_ids, curPortId)
--         if port_id then
--             return port_id
--         end
--     end

--     local mission_data_handler = getGameData():getMissionData()
--     if self.cargoNeedGoodPortDic then
--         --任务
--         local task_port_dic = explore_map_data:getTaskPort()

--         for k,v in pairs(self.cargoNeedGoodPortDic) do
--             local is_mission_to_port = mission_data_handler:isMissionEnterBattlePort(port_id)
--             if not task_port_dic[k] and not is_mission_to_port then--过滤掉对应的那些是任务的港口

--                 --过滤掉没有货物的需求品港口
--                 local cur_market_goods_num, max_market_goods_num = self:getStoreGoodNumByPortId(k)
--                 if cur_market_goods_num > 0 then
--                     port_ids[#port_ids + 1] = {id = k, good_id = v}
--                 end
--             end
--         end
--         port_id = getMinDisPortId(port_ids, curPortId)
--         if port_id then
--             return port_id
--         end
--     end
--     --没有需求品，优先最近且有货物的
--     local port_dis_list = require("game_config/port/port2port_distance_info")[curPortId]
--     local open_port_list = {}
--     local port_status = nil
--     local world_map_attrs_data = getGameData():getWorldMapAttrsData()
--     for k,v in pairs(port_dis_list) do
--         port_status = world_map_attrs_data:getPortStatus(k)
--         if port_status == PORT_STATUS_ZHONGLI or port_status == PORT_STATUS_ZHANLING then
--             if not mission_data_handler:isMissionEnterBattlePort(k) then
--                 open_port_list[#open_port_list + 1] = {id = k, dis = v}
--             end
--         end
--     end
--     table.sort(open_port_list, function(a, b)
--         return a.dis < b.dis
--     end)

--     local player_data = getGameData():getPlayerData()
--     for i,data in ipairs(open_port_list) do
--         local cur_market_goods_num, max_market_goods_num = self:getStoreGoodNumByPortId(data.id)
--         if cur_market_goods_num > 0 then
--             return data.id
--         end
--     end
--     return port_id
-- end

return MarketData

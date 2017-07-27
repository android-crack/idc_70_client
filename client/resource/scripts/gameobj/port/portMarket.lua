--lyl 交易所
require("gameobj/port/portMarketCell")

local news = require("game_config/news")
local ui_word=require("game_config/ui_word")
local UiCommon = require("ui/tools/UiCommon")
local voice_info = getLangVoiceInfo()
local music_info = require("game_config/music_info")
local port_info = require("game_config/port/port_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local Alert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local CompositeEffect = require("gameobj/composite_effect")
local goods_info = require("game_config/port/goods_info")
local ClsPortMarket = class("ClsPortMarket", ClsBaseView)

local OPEN_AUTO_TRADE = 1
local OPEN_GUILD_SKILL_GOODS_TIPS = 2

local COST_POWER_NUM = 3

--页面参数配置方法，注意，是静态方法
function ClsPortMarket:getViewConfig()
    return {
        name = "ClsPortMarket",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
        hide_before_view = true,
    }
end

function ClsPortMarket:onEnter(from_3d_view, tag) 
    self.plistTab={
        ["ui/market_ui.plist"] = 1,
    }
    LoadPlist(self.plistTab)
    
    self.wait_store_data = true
    self.wait_cargo_date = true
    self.lirun = 0 

    self.armatureTab={
        "effects/tx_4029.ExportJson",
        "effects/fire.ExportJson",
		"effects/tx_1010to1013.ExportJson"
    }
    LoadArmature(self.armatureTab)

    -- self.oneKeyBuyPos={}   --一键购买的位置记录
    self:initViewData(from_3d_view, tag)
    self:mkUi()
    
end

function ClsPortMarket:initViewData(from_3d_view, tag)
    self.from_3d_view = from_3d_view
    self.tag = tag

    self.buyValue = 0
    self.sellValue = 0
    self.profitValue = 0

    self.items = {}    --操作删除记录
    self.cargo_list = {}
    self.store_list = {}

    local marketData = getGameData():getMarketData()
    marketData:askEnterMarket()

    local taskData = getGameData():getTaskData()
    local taskKeys = {
        on_off_info.PORT_MARKET.value,
    }
    for i,v in ipairs(taskKeys) do
        taskData:setTask(v, false)
    end
end

function ClsPortMarket:mkUi()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/market.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    self.storeList = ClsScrollView.new(widthStoreCell, 470, true, nil, {is_fit_bottom = true})
    self.storeList:setPosition(ccp(95, 0))
    self:addWidget(self.storeList)

    self.cargoList = ClsScrollView.new(widthCargoCell, 476, true, nil, {is_fit_bottom = false})
    self.cargoList:setPosition(ccp(458, 0))
    self:addWidget(self.cargoList)

     --list
    -- self.storeList = ListView.new(CCRect(0,0, widthStoreCell, 395),3)
    -- self.storeList:setTouchEnabled(true)
    -- self.storeList:setTouchRect(CCRect(95, 92, widthStoreCell, 395))
    -- self.storeList:setPosition(ccp(95,92))
    -- self:addChild(self.storeList)

    -- self.cargoList = CargoListView.new(CCRect(0,0, widthCargoCell,476),4)
    -- self.cargoList:setTouchEnabled(true)
    -- self.cargoList:setTouchRect(CCRect(480,0, widthCargoCell,476))
    -- self.cargoList:setPosition(ccp(458, 0))
    -- self:addChild(self.cargoList)

    self.accountant_panel = GUIReader:shareReader():widgetFromJsonFile("json/market_accountant.json")
    convertUIType(self.accountant_panel)
    self:addWidget(self.accountant_panel)

    self.accountant_pic = getConvertChildByName(self.accountant_panel, "loli_pic")
    self.accountantButton = getConvertChildByName(self.accountant_panel, "btn_auto")
    self.accountantExplainLabel = getConvertChildByName(self.accountant_panel, "tips_text")
    self.tips_bg = getConvertChildByName(self.accountant_panel, "tips_bg")

    self.btn_donate = getConvertChildByName(self.accountant_panel, "btn_donate")
    self.btn_donate:setVisible(false)

    --利润、交易结算
    self.tradeLabel = getConvertChildByName(self.accountant_panel, "tips_money_num")
    self.tradeLabel:setText(self.buyValue)
    self.profitLabel = getConvertChildByName(self.accountant_panel, "tips_profit_num")
    self.profitLabel:setText(self.sellValue)

    --金币
    self.coin_panel = getConvertChildByName(self.panel, "coin_panel")
    local ClsPlayerInfoItem = require("ui/tools/clsPlayerInfoItem")
    local cash_layer = ClsPlayerInfoItem.new(ITEM_INDEX_CASH)
    self.coin_panel:addCCNode(cash_layer)

    --体力
    self.power_panel = getConvertChildByName(self.panel, "power_panel")
    local tili_layer = ClsPlayerInfoItem.new(ITEM_INDEX_TILI)
    self.power_panel:addCCNode(tili_layer)

    --委任经商
    self.btn_idle = getConvertChildByName(self.accountant_panel, "btn_idle")
    self.btn_idle:setPressedActionEnabled(true)
    self.btn_idle:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        getUIManager():create("gameobj/autoTrade/clsAppointTradeUI")
    end, TOUCH_EVENT_ENDED)

    local onOffData = getGameData():getOnOffData()
    if not onOffData:isOpen(on_off_info.APPOINT_SHOPPING.value) then
        self.btn_idle:setVisible(false)
    end

    self.btn_why = getConvertChildByName(self.panel, "btn_tips")
    self.btn_why:setPressedActionEnabled(true)
    self.btn_why:setTouchEnabled(true)
    self.btn_why:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local container = UIWidget:create()
        local panel = GUIReader:shareReader():widgetFromJsonFile('json/market_info.json')
        local btn_close = getConvertChildByName(panel, "btn_close")

        btn_close:addEventListener(function ()
            audioExt.playEffect(music_info.COMMON_CLOSE.res)
            getUIManager():close("portMarketTips")
        end,TOUCH_EVENT_ENDED)

        container:addChild(panel)
        getUIManager():create("ui/view/clsBaseTipsView", nil, "portMarketTips", {is_back_bg = true}, container, true)
        panel:setPosition(ccp(0.5*display.cx,50))
        getUIManager():get("portMarketTips"):setIgnoreClosePanel(panel)
    end,TOUCH_EVENT_ENDED)

    --关闭按钮
    self.is_power = false
    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self.btn_close:setTouchEnabled(false)

        --getUIManager():create("gameobj/port/clsPortMarketAccountView")
        local player_data = getGameData():getPlayerData()
        local value, max = player_data:getCash(), player_data:getMaxCash()
        if (tonumber(self.tradeLabel:getStringValue()) + value) > max then
            local function restoreUI()
                self:resetUi()
                self.btn_close:setTouchEnabled(true)
            end
            Alert:showAttention(news.PORT_MARKET_SILVER_ENOUGH.msg, restoreUI, restoreUI, function()
                self:okFunc()

            end, {ok_text = ui_word.MAIN_RESTORE, cancel_text = ui_word.MAIN_CONTINUE})
        else
            self:okFunc()

        end
    end,TOUCH_EVENT_ENDED)

    self.accountant_pic:addEventListener(function()
        local marketData = getGameData():getMarketData()
        marketData:oneKeySell()
    end,TOUCH_EVENT_ENDED)

    self.accountantButton:setPressedActionEnabled(true)
    self.accountantButton:addEventListener(function()
        local marketData = getGameData():getMarketData()
        marketData:oneKeySell()
    end,TOUCH_EVENT_ENDED)

    --商品飞动效果显示区域
    self.effectClipNode = display.newClippingRegionNode(CCRect(123,63,770,420)) --商品飞动特效的区域 超出就不显示
    self:addChild(self.effectClipNode)
    ClsGuideMgr:tryGuide("ClsPortMarket")
end


function ClsPortMarket:openResearchView()
    local guild_goods_info = {}
    local data = getGameData():getGuildResearchData():getResearchSelectSkillInfo()

    local type_pos = 2
    getUIManager():create("gameobj/guild/clsGuildResearchGoodsTips",{}, data, type_pos)
end


function ClsPortMarket:setSellBuyValue(tradeValue,profitValue)
    tradeValue = tradeValue or (self.sellValue + self.buyValue)
    tradeValue = math.floor(tradeValue + 0.5)
    if tradeValue >= 0 then
        setUILabelColor(self.tradeLabel, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
    else
        setUILabelColor(self.tradeLabel, ccc3(dexToColor3B(COLOR_RED_STROKE)))
    end

    profitValue = profitValue or self.profitValue
    profitValue = math.floor(profitValue + 0.5)

    self.lirun = profitValue
    UiCommon:numberEffect(self.profitLabel, tonumber(self.profitLabel:getStringValue()),profitValue)
    UiCommon:numberEffect(self.tradeLabel, tonumber(self.tradeLabel:getStringValue()), tradeValue)
end

function ClsPortMarket:setTradeValue(buyPrice, sellPrice, amount, profit,item)
    --这里面的代码等界面不在改动后在删除  不然加成值各种考虑混乱
    --print("buyPrice",buyPrice,"sellPrice",sellPrice,"amount",amount,"profit",profit,"name",item.name,")
    if not amount then return end
    if buyPrice then
        self.buyValue = self.buyValue - buyPrice * amount  --买进来是负数   换回去是正数
        if amount > 0 then
            self:setAccountantTips(string.format(news.PORT_MARKET_BUY.msg, amount, item.name))--购买xx
        else
            self:setAccountantTips(string.format(news.PORT_MARKET_CANCEL.msg, item.name))  --取消购买
        end
    end

    if profit then
        self.profitValue = self.profitValue + profit * amount
    end

    if sellPrice then
        self.sellValue = self.sellValue + sellPrice * amount
        self:setAccountantTips(string.format(news.PORT_MARKET_SELL.msg,amount, item.name))--卖出xx
    end

    self:setSellBuyValue()
end

function ClsPortMarket:getTradeValue()
	local playerData = getGameData():getPlayerData()
    local value = playerData:getCash() + self.sellValue + self.buyValue
    --print(self.sellValue,"self.sellValue","self.buyValue",self.buyValue)
    return  value
end

function ClsPortMarket:moveGood(res, startPos, endPos, delay, call_back)
    delay = delay or 0.3
    local sprite = display.newSprite(res,startPos.x,startPos.y)
    sprite:setAnchorPoint(ccp(0.5, 0.5))
    local arr = CCArray:create()
    arr:addObject(CCMoveTo:create(delay,endPos))
    arr:addObject(CCCallFunc:create(function()
        self.effectClipNode:removeChild(sprite,true)
        if call_back then
            call_back()
        end
    end))
    sprite:runAction(CCSequence:create(arr))

    local particle = CCParticleSystemQuad:create("effects/tx_1033.plist")
    particle:setPosition(ccp(0,15))
    sprite:addChild(particle)

    self.effectClipNode:addChild(sprite)
end

function ClsPortMarket:setAccountantTips(msg)  --会计师会话提示
    if msg then
        self.accountantExplainLabel:setText(msg)


        if self.effect then
            self.effect:removeFromParentAndCleanup(true)
            self.effect = nil
        end
        self.effect = CompositeEffect.new("tx_4029", 4, 0, self.tips_bg, 2.0,
            function (  )
                if self.effect then
                    self.effect:removeFromParentAndCleanup(true)
                    self.effect = nil
                end
            end, nil, nil, true)
        self.effect:setScale(0.5)

    end
end

--需求品提示
function ClsPortMarket:hotGoodsTips(has_porfit)     --需求品提示  传参数是为了商品行情的提示
    -- if not self.accountant then return false end  --没会计师没必要进行下一步

    local marketData = getGameData():getMarketData()
    if not marketData:isFull() then--货仓未满，且交易所有数量可以购买
        if marketData:isStoreGoods() then
            self:setAccountantTips(news.PORT_MARKET_NOT_FULL.msg)
        end
        return
    end

    local mapAttrs = getGameData():getWorldMapAttrsData()
    local needToPort = mapAttrs:getNeedPort()  --需求品对应的港口
    local portData = getGameData():getPortData()
    local myPortId = portData:getPortId()

    --先判断时候是当前港口的需求品
    for k,cell in ipairs(self:getCargoCellList()) do
        local good = cell.item
        if good and good.good_id > 0 and not good.isHas then
            local good_class = good.good_info.class
            local need_to_list = needToPort[good_class]
            if need_to_list then
                for k,portId in pairs(need_to_list) do
                    if myPortId == portId then
                        self:setAccountantTips(news.PORT_MARKET_SELL_1.msg)
                        return
                    end
                end
            end
        end
    end

    --再判断别的港口是否有卖
    local port_id, good_id = marketData:getMinDistancePortId()
    if port_id then
        local port_name = port_info[port_id].name
        self:setAccountantTips(string.format(news.PORT_MARKET_HOT_SELL.msg, goods_info[good_id].name, port_name))
        return
    end

    if has_porfit then--货仓物品有利润
        self:setAccountantTips(news.PORT_MARKET_SELL_1.msg)
    else
        self:setAccountantTips(news.PORT_MARKET_SELL_2.msg)
    end
end

function ClsPortMarket:updateStore(stores)
    self.storeList:removeAllCells()
    --商店货物
    local items = table.clone(stores)

    local marketData = getGameData():getMarketData()
    local lockGoods = marketData:getLockGoods()

    for k,item in ipairs(lockGoods) do
        items[#items+1]=item
    end

    self.store_list = {}
    local size = CCSize(widthStoreCell, heightStoreCell)
    for i=1,#items,2 do
        -- if i > 4 then--第三行开始特殊处理，为了不被萝莉挡住
        --     self.store_list[#self.store_list + 1] = CellStore.new(size, {store1 = nil, store2 = items[i]})
        --     -- self.storeList:addCell(CellStore.new(, nil, items[i]))
        --     if items[i+1] then
        --         self.store_list[#self.store_list + 1] = CellStore.new(size, {store1 = nil, store2 = items[i+1]})
        --         -- self.storeList:addCell(CellStore.new(CCSize(widthStoreCell,heightStoreCell), nil, items[i+1]))
        --     end
        -- else
            self.store_list[#self.store_list + 1] = CellStore.new(size, {store1 = items[i], store2 = items[i+1]})
            -- self.storeList:addCell(CellStore.new(CCSize(widthStoreCell,heightStoreCell),items[i],items[i+1]))
        -- end
    end
    self.storeList:addCells(self.store_list)
    self.wait_store_data = false
    self:setRpcState()
end


function ClsPortMarket:updateCargo(cargos)
    self.cargoList:removeAllCells()
    self.items = {} --用来保存玩家点击交易所的操作

    local hasPorfit = false   --判断是否有利润

    self.cargo_list = {}
    local size = CCSize(widthCargoCell, heightCargoCell)
    for k, cargo in ipairs(cargos) do
        local cargo = table.clone(cargos[k])
        if cargo.good_id and cargo.good_id > 0 then
            cargo.tradeAmount = 0
            if cargo.profit > 0 then
                hasPorfit = true
            end
            self.profitValue = self.profitValue - cargo.tradeAmount * cargo.profit
        end
        self.cargo_list[#self.cargo_list + 1] = CellCargo.new(size, cargo)
        -- local cell = CellCargo.new(CCSize(widthCargoCell, heightCargoCell), cargo)
        -- self.cargoList:addCell(cell)
    end
    self.cargoList:addCells(self.cargo_list)

    self.sellValue = 0
    self.buyValue = 0
    self.profitValue = 0

    --会计师提示文字
    self:hotGoodsTips(hasPorfit)
    self.wait_cargo_date = false
    self:setRpcState()
end

function ClsPortMarket:setRpcState()
    if not self.wait_store_data and not self.wait_cargo_date then
        if self.tag and self.tag == OPEN_GUILD_SKILL_GOODS_TIPS then
            self:openResearchView()
            self.tag = nil
        end
    end
end

function ClsPortMarket:getStoreCellList()
    return self.store_list
end

function ClsPortMarket:getCargoCellList()
    return self.cargo_list
end

function ClsPortMarket:delCargoCell(cell)
    local cell_index = nil
    for i, cargo in ipairs(self.cargo_list) do
        if not cell_index and cargo == cell then
            cell_index = i
        end
    end

    self.cargoList:removeCell(cell)
    table.remove(self.cargo_list, cell_index)
end

function ClsPortMarket:closeView()
    if not tolua.isnull(self.btn_close) then
        self.btn_close:executeEvent(TOUCH_EVENT_ENDED)
    end
end

function ClsPortMarket:blink() --会计师的说话背景闪烁
    local armature = CCArmature:create("tx_4029")
    armature:setPosition(190,48)
    self.accountantExplainBg:addChild(armature)
    local animation=armature:getAnimation()
    animation:playByIndex(0,-1,-1,0)
    animation:addMovementCallback(function(eventType)
        if eventType == 1 then
            armature:removeFromParentAndCleanup(true)
        end
    end)
end

function ClsPortMarket:setTouch(enable)
    self:setViewTouchEnabled(enable)
    self.cargoList:setTouch(enable)
    self.storeList:setTouch(enable)
end


function ClsPortMarket:onExit()
    curSelectTabIndex = TAB_NULL
    UnLoadPlist(self.plistTab)
    UnLoadArmature(self.armatureTab)

    ReleaseTexture(self)
end

function ClsPortMarket:okFunc()
    self.store_id_data={}
    self.store_order_data={}
    self.cargo_data={}
    local cells = self.cargo_list

    local is_need_show_tips = false

    local function buy(item)
        if not item then return end 
        item.tradeAmount = item.tradeAmount or 0
        if item.good_id == 0 then return end
        if item.tradeAmount > 0 then
            self.store_id_data[#self.store_id_data+1] = item.good_id
            self.store_order_data[#self.store_order_data + 1] = item.index
        elseif item.tradeAmount < 0 then
            --卖出货物时候，如果体力不足，要弹出体力不足弹框。除非货仓里只有普通商品，并且这些普通商品不是需求品
            local breed = item.good_info.breed
            is_need_show_tips = not (breed == GOOD_TYPE_COMMON and not item.isPortNeed)
            self.cargo_data[#self.cargo_data + 1 ] = item.index
        end
    end


    self.empty_cargo_num = 0
    self.total_cargo_num = 0
    for k,cell in pairs(cells) do
        buy(cell.item)
        if cell.item.boat_type and cell.item.boat_type ~= 0 then
            self.total_cargo_num = self.total_cargo_num + 1
            if cell.item.good_id == 0 then
                self.empty_cargo_num = self.empty_cargo_num + 1
            end
        end
    end
    for i,item in pairs(self.items) do --操作后被移除格子记录下的数据
        buy(item)
    end

    ----交易所无操作
    if #self.cargo_data < 1 and #self.store_id_data < 1 and #self.store_order_data < 1 then
        self:closeMySelf()
        return 
    end


    local power = getGameData():getPlayerData():getPower()
    local auto_trade_data = getGameData():getAutoTradeAIHandler()
    local is_auto_trade = auto_trade_data:inAutoTradeAIRun()
    if not is_auto_trade and power < COST_POWER_NUM then
        if is_need_show_tips and not self.is_power then
            Alert:portMarketPowerNoEnoughTips()
            self.btn_close:setTouchEnabled(true)
            self.is_power = true
            return
        end
    end

    self:gotoAccount()
end

function ClsPortMarket:gotoAccount(  )
    local parent = self:getParent()--其他界面不足打开后，关闭界面刷新

    local marketData = getGameData():getMarketData()
    marketData:buyAndSellGoods(self.cargo_data, self.store_id_data, self.store_order_data, parent)

    local tradeValue = tonumber(self.tradeLabel:getStringValue())
    --print("==========================tradeValue=====交易利润",tradeValue)
    if tradeValue > 0 then
        audioExt.playEffect(music_info.COMMON_CASH.res)

        UiCommon:floatRewardEfOnScene(ccp(234,34),ccp(21,508), TYPE_INFOR_CASH,function()
            --print("===============================交易利润",self.lirun)
            if self.lirun <= 0 then
                self:closeMySelf()
            end
        end)
    else
        if self.lirun then
            if self.lirun <= 0 then
                self:closeMySelf()
            end
        else
            self:closeMySelf()
        end
    end

    if self.empty_cargo_num == 0 then--满格的情况下，一定要有买入操作，才进行播放
        if #self.store_id_data > 0 and self.lirun <= 0 then
            self.accountSound = audioExt.playEffectBySequeue("VOICE_PLOT_1003")
        end
    elseif self.empty_cargo_num < self.total_cargo_num and (#self.store_id_data > 0 or #self.cargo_data > 0) then
        --未满的情况下，有买卖操作才播放
        if self.lirun <= 0 then
            self.accountSound = audioExt.playEffectBySequeue("VOICE_PLOT_1019")
        end
    end
end

function ClsPortMarket:checkUIClose()
    if self.lirun > 0 then
        print("==============利润有异常！！！！！！！！！")
        self:closeMySelf()
    end
end

function ClsPortMarket:closeMySelf()
    --self:close()
    self:effectClose()
end

function ClsPortMarket:resetUi()
    local marketData = getGameData():getMarketData()
    local store_list = marketData:getStoreGoods()
    self:updateStore(store_list)

    local goodList = marketData:getCargoGoods()
    self:updateCargo(goodList)
    self.sellValue = 0
    self.buyValue = 0
    self:setSellBuyValue()
end

--淡入效果完后增加音效
function ClsPortMarket:onStart()
    audioExt.playEffect(voice_info.VOICE_PLOT_1004.res)
    if self.tag and self.tag == OPEN_AUTO_TRADE then
        self.btn_idle:executeEvent(TOUCH_EVENT_ENDED)
    end
end

function ClsPortMarket:getParentViewType()
    if self.from_3d_view then
        return Alert:getOpenShopType().VIEW_3D_TYPE
    end
    return Alert:getOpenShopType().VIEW_NORMAL_TYPE
end

return ClsPortMarket

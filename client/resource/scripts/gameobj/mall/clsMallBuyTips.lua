--
-- Author: Ltian
-- Date: 2016-11-25 15:57:41
--

local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")

local KIND_ADD = 1
local KIND_REDUCE = 2
local KIND_MAX = 3

local ClsBaseView = require("ui/view/clsBaseView")
local ClsMallBuyTips = class("ClsMallBuyTips", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsMallBuyTips:getViewConfig()
    return {
        name = "ClsMallBuyTips",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

--页面创建时调用
function ClsMallBuyTips:onEnter(parameter)
    self.config_data = parameter.config_data
    self.buy_fun  = parameter.buy_fun
    self.is_limit = parameter.is_limit
    self:configUI()
    self:initEvent()
end

function ClsMallBuyTips:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_shop.json")
    self:addWidget(self.panel)

    local panel_size = self.panel:getContentSize()
    self.panel:setPosition(ccp((display.width - panel_size.width) / 2, (display.height - panel_size.height) / 2))
    self.not_close_rect = CCRect((display.width - panel_size.width) / 2, (display.height - panel_size.height) / 2, panel_size.width, panel_size.height)

    local wideget_info = {
        [1] = {name = "btn_reduce"}, --减号按钮
        [2] = {name = "btn_add"}, -- 加好
        [3] = {name = "max_bg"}, --最大
        [4] = {name = "btn_buy",label = "btn_buy_num"}, --购买
        [5] = {name = "mid_num"}, --数量
        [6] = {name = "goods_price_num"}, --单价
        [7] = {name = "goods_info_text"}, --物品介绍
        [8] = {name = "goods_text"}, --物品名字
        [9] = {name = "goods_icon"}, --图标  
        [10] = {name = "btn_buy_icon"}, --单价图标2按钮上的
        [11] = {name = "btn_close"}, --关闭按钮
        [12] = {name = "goods_price_text"},
        [13] = {name = "goods_amount"},
    }

    for k, v in ipairs(wideget_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item.name = v.name

        if v.label then
            item.label = getConvertChildByName(item, v.label)
        end

        if item:getDescription() == "Button" then
            item:setTouchEnabled(true)
            item:setPressedActionEnabled(true)
        end
        self[v.name] = item
    end
    if not self.is_limit then
        self.goods_price_text:setVisible(false)
        self.goods_price_num:setVisible(false)
    end
    local info = self.config_data
    self.goods_icon:changeTexture(convertResources(info.icon), UI_TEX_TYPE_PLIST)
    self.goods_text:setText(info.name)
    self.goods_info_text:setVisible(true)
    self.goods_info_text:setText(info.desc)
    self.btn_buy_icon:changeTexture(convertResources(info.price_icon), UI_TEX_TYPE_PLIST)
    self:setGoodAmount(info.amount)

    --为按钮注册事件
    local register_event = {
        [1] = {btn = self.btn_add, kind = KIND_ADD},
        [2] = {btn = self.btn_reduce, kind = KIND_REDUCE},
        [3] = {btn = self.max_bg, kind = KIND_MAX},
    }

    --购买分量
    local max_num = info.max_partner
    local discount_count = info.discount_count
    self.goods_price_num:setText(discount_count)

    local play_data = getGameData():getPlayerData()
    local gold = play_data:getGold()

    local min_num = 1
    self.mid_num:setText(min_num)
    local price = 0
    if info.price_tab then
        price = info.price_tab[1]
        local buy_max = 0 
        for i,v in ipairs(info.price_tab) do
            gold = gold - info.price_tab[i]
            if gold < 0 then
                break
            else
                buy_max = buy_max + 1
            end
        end
        if buy_max < max_num then
            max_num = math.floor(buy_max)
        end
    else
        local buy_max = gold/info.price
        if buy_max < max_num then
            max_num = math.floor(buy_max)
        end
        price = info.price
    end
    self.btn_buy.label:setText(price)--一份需要的钱

    local gold_num = getGameData():getPlayerData():getGold()
    local color = COLOR_WHITE
    if price > gold_num then
        color = COLOR_RED
    end
    self.btn_buy.label:setUILabelColor(color)

    local size = self.btn_buy.label:getContentSize()
    if size.width < 20 then
        self.btn_buy.label:setPosition(ccp(24 - size.width, 1))
    else
        self.btn_buy.label:setPosition(ccp(-6, 1))
    end
    self.cost_price = price
    self.need_cash = info.price
    self.good_id = info.id--商品ID
    self.good_part_num = 1
    for k, v in ipairs(register_event) do
        v.btn:addEventListener(function() 
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            local cur_num = tonumber(self.mid_num:getStringValue())
            local step = 0
            if v.kind == KIND_ADD then
                if max_num <= cur_num then 
                    self:alertTips()
                    return 
                end--达到最大上限
                step = 1
            elseif v.kind == KIND_REDUCE then
                if min_num >= cur_num then return end--达到最低下限
                step = -1
            elseif v.kind == KIND_MAX then--最大
                if max_num <= cur_num then
                    self:alertTips()
                    return 
                end--达到最大上限
                step = max_num - cur_num
            end

            local select_num = cur_num + step
            self.mid_num:setText(select_num)
            self.good_part_num = select_num
            local total_gold = 0
            if info.price_tab then
                total_gold = 0
                for i=1,select_num do
                    total_gold = total_gold + info.price_tab[i]
                end
            else
                total_gold = info.price * select_num
            end

            self.btn_buy.label:setText(tostring(total_gold)) --显示总价格
            self.cost_price = total_gold
            local size = self.btn_buy.label:getContentSize()
            if size.width < 20 then
                self.btn_buy.label:setPosition(ccp(24 - size.width, 1))
            else
                self.btn_buy.label:setPosition(ccp(-6, 1))
            end
            local play_data = getGameData():getPlayerData()
            local gold = play_data:getGold()
            local color = COLOR_WHITE
            if total_gold > gold then
                color = COLOR_RED
            end
            self.need_cash = total_gold
            self:setGoodAmount(info.amount * select_num)
            self.btn_buy.label:setUILabelColor(color)
        end, TOUCH_EVENT_ENDED)
    end

    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            if not self.not_close_rect:containsPoint(ccp(x, y)) then
                return true
            end
        elseif event_type == "ended" then
            self:closeView()
        end
    end)
end

function ClsMallBuyTips:alertTips()
    print("self.config_data.goods_type", self.config_data.goods_type)
    if self.config_data.goods_type == "cash" or self.config_data.goods_type == "tili" then
        Alert:warning({msg = ui_word.SP_GOOD_TIPS, size = 26})
    else
        Alert:warning({msg = ui_word.NOT_CALL_SELE, size = 26})
    end
end

function ClsMallBuyTips:setGoodAmount(amount)
    if amount > 10000 then
        amount = string.format(ui_word.AMOUNT_CASH, tostring(math.floor(amount/10000)))
    end
    self.goods_amount:setText(amount)
end

function ClsMallBuyTips:initEvent()
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:closeView()
    end, TOUCH_EVENT_ENDED)

    self.btn_buy:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)

        local gold_num = getGameData():getPlayerData():getGold()
        --print("-------------gold_num------",self.cost_price ,gold_num)
        if self.cost_price > gold_num then
            local alertType = Alert:getOpenShopType()
            Alert:showJumpWindow(DIAMOND_NOT_ENOUGH_GOSHOP, self, {come_type = alertType.VIEW_NORMAL_TYPE})
            return 
        end

        local tips = string.format(ui_word.BUY_GOODS_TIPS, tostring(self.cost_price))
        Alert:showAttention(tips, function ()
            local shop_data = getGameData():getShopData()
            shop_data:askBuyShopItem(self.good_id, self.good_part_num)
        end)
        --, nil, nil, {ok_text = ui_word.MAIN_SURE_BUG, cancel_text = ui_word.SYS_CLOSE}
        
        self:closeView()
        
    end,TOUCH_EVENT_ENDED)
end

function ClsMallBuyTips:closeView()
    self:close()
end

return ClsMallBuyTips

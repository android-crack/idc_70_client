--船厂商店TIP
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local uiTools = require("gameobj/uiTools")

local KIND_ADD = 1
local KIND_REDUCE = 2
local KIND_MAX = 3

local ClsBaseView = require("ui/view/clsBaseView")
local ClsStoreBuy = class("ClsStoreBuy", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsStoreBuy:getViewConfig()
    return {
        name = "ClsStoreBuy",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

--页面创建时调用
function ClsStoreBuy:onEnter(parameter)
    self.config_data = parameter.config_data
    self.buy_fun  = parameter.buy_fun
    self:configUI()
    self:initEvent()
end

function ClsStoreBuy:configUI()
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

    local info = self.config_data
    self.goods_icon:changeTexture(convertResources(info.icon), UI_TEX_TYPE_PLIST)
    self.goods_text:setText(info.name)
    self.goods_info_text:setVisible(true)
    self.goods_info_text:setText(info.desc)
    self.btn_buy_icon:changeTexture(convertResources(info.price_icon), UI_TEX_TYPE_PLIST)
    self.goods_price_num:setText(info.max_partner)
    self.goods_amount:setText(info.amount)

    --为按钮注册事件
    local register_event = {
        [1] = {btn = self.btn_add, kind = KIND_ADD},
        [2] = {btn = self.btn_reduce, kind = KIND_REDUCE},
        [3] = {btn = self.max_bg, kind = KIND_MAX},
    }

    --购买份量
    local max_num = info.max_partner
    local min_num = 1
    self.mid_num:setText(min_num)
    self.btn_buy.label:setText(info.price)--一份需要的钱
    local pos = self.btn_buy.label:getPosition()
    self.btn_buy.label:setPosition(ccp(pos.x - 11, pos.y))
    self.need_cash = info.price
    self.good_id = info.id--商品ID
    self.good_part_num = 1
    for k, v in ipairs(register_event) do
        v.btn:addEventListener(function() 
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            local cur_num = tonumber(self.mid_num:getStringValue())
            local step = 0
            if v.kind == KIND_ADD then
                if max_num == cur_num then 
                    Alert:warning({msg = ui_word.CLICK_BTN_NOT_GOODS, size = 26})
                    return 
                end--达到最大上限
                step = 1
            elseif v.kind == KIND_REDUCE then
                if min_num >= cur_num then return end--达到最低下限
                step = -1
            elseif v.kind == KIND_MAX then--最大
                if max_num <= cur_num then
                    Alert:warning({msg = ui_word.CLICK_BTN_NOT_GOODS, size = 26})
                    return 
                end--达到最大上限
                step = max_num - cur_num
            end

            local cur_part_num = cur_num + step
            self.mid_num:setText(cur_part_num)
            self.goods_amount:setText(cur_part_num * info.amount)
            self.good_part_num = cur_part_num
            local total_cash = info.price * cur_part_num
            self.btn_buy.label:setText(tostring(total_cash)) --显示总价格
            local play_data = getGameData():getPlayerData()
            local cash = play_data:getCash()
            local color = COLOR_WHITE
            if total_cash > cash then
                color = COLOR_RED
            end
            self.need_cash = total_cash
            self.btn_buy.label:setUILabelColor(color)
            uiTools:autoUpdatePos(self.btn_buy, self.btn_buy_icon, self.btn_buy.label)
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
    uiTools:autoUpdatePos(self.btn_buy, self.btn_buy_icon, self.btn_buy.label)
end

function ClsStoreBuy:initEvent()
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:closeView()
    end, TOUCH_EVENT_ENDED)

    self.btn_buy:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        if type(self.buy_fun) == "function" then
            self:closeView()
            self.buy_fun(self.good_part_num)
            return
        end
        local play_data = getGameData():getPlayerData()
        local cur_cash = play_data:getCash()
        if self.need_cash <= cur_cash then
            local boat_data = getGameData():getBoatData()
            boat_data:askBuyGood(self.good_id, self.good_part_num)
            self:closeView()
        else
            self:closeView()
            local ship_main_ui = getUIManager():get("ClsShipyardMainUI")
            Alert:showJumpWindow(CASH_NOT_ENOUGH, ship_main_ui, {need_cash = self.need_cash})
        end
    end,TOUCH_EVENT_ENDED)
end

function ClsStoreBuy:closeView()
    self:close()
end

return ClsStoreBuy

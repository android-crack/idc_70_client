-- 委任经商界面
-- Author: chenlurong
-- Date: 2016-05-11 11:29:32
--
local music_info=require("game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word=require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsAppointTradeUI = class("ClsAppointTradeUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsAppointTradeUI:getViewConfig()
    return {
        name = "ClsAppointTradeUI",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        effect = UI_EFFECT.DOWN,    --(选填) ui出现时的播放特效
        is_back_bg = true,
    }
end

local NEED_POWER = 30

function ClsAppointTradeUI:onEnter()
	self.res_plist = {
        ["ui/auto_trade.plist"] = 1,
    }
    LoadPlist(self.res_plist)

    self:initUI()
    self:addEvent()
    self.need_cash = 20000
    self.max_time = 99
    self.left_trade_times = 0

    local auto_trade_Data = getGameData():getAutoTradeAIHandler()
    auto_trade_Data:askAutoTradeData()
end

function ClsAppointTradeUI:initUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/auto_trade_team.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    self.text_frame = getConvertChildByName(self.panel, "text_frame")
    self.big_question = getConvertChildByName(self.panel, "big_question")
    self.big_head = getConvertChildByName(self.panel, "big_head")
    self.big_head_bg = getConvertChildByName(self.panel, "big_head_bg")
    self.left_num = getConvertChildByName(self.panel, "surplus_num")
    self.member_num = getConvertChildByName(self.panel, "member_num")
    self.businesss_add = getConvertChildByName(self.panel, "businesss_add")
    self.btn_buy_time = getConvertChildByName(self.panel, "btn_buy_time")
    self.btn_team = getConvertChildByName(self.panel, "btn_team")
    self.btn_start = getConvertChildByName(self.panel, "btn_star")
    self.btn_close = getConvertChildByName(self.panel, "close_btn")
    self.cost_power = getConvertChildByName(self.panel,"cost_power")
    self:updatePower()
    self.team_member = {}
    for i=1,3 do
    	local member = getConvertChildByName(self.panel, "member_" .. i)
    	member.head = getConvertChildByName(self.panel, "head_" .. i)
    	member.num = getConvertChildByName(self.panel, "add_" .. i)
    	self.team_member[i] = member
        member:setVisible(false)
    end

    self.left_num:setText("")

    local player_data = getGameData():getPlayerData()
    self.sailor_icon = player_data:getIcon()
    local sailor = ClsDataTools:getSailor(self.sailor_icon)
    self.big_head:changeTexture(sailor.res)
    local btn_size = self.big_head_bg:getContentSize()
    local head_size = self.big_head:getContentSize()
    self.big_head:setScale(btn_size.height / head_size.height * 0.7)
    self.big_head:setVisible(true)
    self.btn_start:setVisible(true) 
    self.big_question:setVisible(false)     

    local team_data = getGameData():getTeamData()
    local team_num = 0
    local team_add_per = 0
    local team_leader_add_base = 5 --公式为5*成员数量
    local player_data = getGameData():getPlayerData()
    local my_uid = player_data:getUid()
    if team_data:isInTeam() then
        self.btn_team:setVisible(false)
        local sailor_info = require("game_config/sailor/sailor_info")
        local team_list = team_data:getMyTeamInfo()
        local team_info = team_list.info
        local leader_uid = team_list.leader
        --table.print(team_list)
        team_num = #team_info
        for i=1,3 do
            local member_info = team_info[i]
            local member = self.team_member[i]
            if member_info then
                member:setVisible(true)
                local sailor = sailor_info[tonumber(member_info.icon)]
                member.head:changeTexture(sailor.res, UI_TEX_TYPE_LOCAL)
                member.num:setText("+ 0%")
            end
        end
        local leader_add_per = team_leader_add_base * (team_num - 1)
        self.team_member[1].num:setText(string.format("+ %s%%", leader_add_per))
        if leader_uid  == my_uid then
            team_add_per = leader_add_per
        end
    end

    self.businesss_add:setText(string.format("+ %s%%", team_add_per))
    self.member_num:setText(string.format("%s/3", team_num))
end

function ClsAppointTradeUI:addEvent()
    self.btn_buy_time:setPressedActionEnabled(true) 
    self.btn_buy_time:addEventListener(function()
            if self.left_trade_times >= self.max_time then
                local error_info=require("game_config/error_info")
                Alert:warning({msg = error_info[864].message})
                return
            end
            self:showTradeTimesBuyUI(true, self.max_time - self.left_trade_times)
        end,TOUCH_EVENT_ENDED) 
    
    self.btn_team:setPressedActionEnabled(true) 
    self.btn_team:addEventListener(function()
        self.btn_team:setTouchEnabled(true)
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
        local skip_layer = missionSkipLayer:skipLayerByName("team_market", nil)
        self:closeView()
    end,TOUCH_EVENT_ENDED)

    local function cheakAreaOpenAppoint( area_id)
        --print("===========================cheakAreaOpenAppoint", area_id)
        local area_info = require("game_config/port/area_info")
        local cur_area_info = area_info[area_id]
        local area_key = cur_area_info.auto_trade
        local on_off_data = getGameData():getOnOffData()
        local on_off_info = require("game_config/on_off_info")
        if area_key and not on_off_data:isOpen(on_off_info[area_key].value) then
            local min_area_id = nil
            local near_area_id = nil
            local near_area_name = nil
            for i,v in pairs(cur_area_info.around_areas) do
                if v > 0 then
                    if not min_area_id  then
                        min_area_id = v
                    elseif min_area_id > v then
                        min_area_id = v
                    end
                    local tmp_area_info = area_info[v]
                    if tmp_area_info and tmp_area_info.auto_trade and on_off_data:isOpen(on_off_info[tmp_area_info.auto_trade].value) then
                        near_area_id = v
                        near_area_name = tmp_area_info.name
                    end
                end
            end
            --print("=false, near_area_id, min_area_id, near_area_name", near_area_id)
            --print("=false, near_area_id, min_area_id, min_area_id", min_area_id)
            return false, near_area_id, min_area_id, near_area_name
        end
        return true
    end

    self.btn_start.last_time = 0
    self.btn_start:setPressedActionEnabled(true) 
    self.btn_start:addEventListener(function()
            if CCTime:getmillistimeofCocos2d() - self.btn_start.last_time < 1500 then return end
            self.btn_start.last_time = CCTime:getmillistimeofCocos2d()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)    
            if self.left_trade_times and self.left_trade_times == 0 then
                self:showTradeTimesBuyUI()
            else
                local player_data = getGameData():getPlayerData()
                local cash = player_data:getCash()    
                local rpc_down_info = require("game_config/rpc_down_info")
                if cash < self.need_cash then
                    Alert:warning({msg = string.format(rpc_down_info[271].msg, self.need_cash)})
                    return
                end
                local market_data = getGameData():getMarketData()
                if market_data:hasAreaGoodsInCargo() then
                    Alert:warning({msg = string.format(rpc_down_info[273].msg, self.need_cash)})
                    return
                end

                local area_info = require("game_config/port/area_info")
                local port_data = getGameData():getPortData()
                local area_id = port_data:getPortAreaId()
                local is_open, near_area_id, min_area_id, near_area_name = cheakAreaOpenAppoint(area_id)
                if not is_open then
                    local has_tips = false
                    for i=6, 1, -1 do
                        if near_area_id then
                            has_tips = true
                            Alert:warning({msg = string.format(rpc_down_info[272].msg, area_info[area_id].name, near_area_name)})
                            return
                        else
                            --print("========================min_area_id", min_area_id)
                            is_open, near_area_id, min_area_id, near_area_name = cheakAreaOpenAppoint(min_area_id)
                        end
                    end
                    --测试提示的，不要在意
                    if not has_tips then
                        Alert:warning({msg = rpc_down_info[283].msg})
                    end
                    return
                end

                self:setTouch(false)
                local auto_trade_Data = getGameData():getAutoTradeAIHandler()
                auto_trade_Data:askStartTrade()
            end
        end,TOUCH_EVENT_ENDED)  

    self.btn_close:setPressedActionEnabled(true) 
    self.btn_close:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_CLOSE.res)
        end,TOUCH_EVENT_BEGAN)
    self.btn_close:addEventListener(function()
            self:closeView()
        end,TOUCH_EVENT_ENDED) 

    RegTrigger(POWER_UPDATE_EVENT, function()
        if not tolua.isnull(self) then
            self:updatePower()
        end
    end)    
end

function ClsAppointTradeUI:updateUI(info)
    self.left_trade_times = info.remainTimes
    self.left_num:setText(string.format(ui_word.AUTI_TRADE_LEFT_TIMES_STR, info.remainTimes))
end

function ClsAppointTradeUI:updatePower()
    local player_data = getGameData():getPlayerData()
    if(player_data:getPower() < NEED_POWER)then
        setUILabelColor(self.cost_power, ccc3(dexToColor3B(COLOR_RED)))
    else
        setUILabelColor(self.cost_power, ccc3(dexToColor3B(COLOR_CAMEL)))
    end
end

function ClsAppointTradeUI:onCreateFinish()
    self.text_frame:setScale(0)
	self.text_frame:setVisible(true)
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(0.8, 1))
    arr:addObject(CCDelayTime:create(2))
    arr:addObject(CCCallFunc:create(function()
        self.text_frame:setVisible(false) 
    end))
    self.text_frame:runAction(CCSequence:create(arr))
end

function ClsAppointTradeUI:showTradeTimesBuyUI(is_buy, limit_time)
    local ui_layer = UIWidget:create()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/auto_trade_buy.json")
    convertUIType(panel)
    ui_layer:addChild(panel)

    local buy_num_times = 1
    local buy_num_max_times = limit_time or 10
    buy_num_max_times = math.min(buy_num_max_times, 10)
    local buy_gold_rate = 100
    local need_gold = buy_num_times * buy_gold_rate
    local player_data = getGameData():getPlayerData()

    local buy_info = getConvertChildByName(panel, "buy_info")
    local btn_buy = getConvertChildByName(panel, "btn_buy")
    local btn_reduce = getConvertChildByName(panel, "btn_reduce")
    local btn_add = getConvertChildByName(panel, "btn_add")
    local times_num = getConvertChildByName(panel, "num")
    local consume_num = getConvertChildByName(panel, "consume_num")

    local buy_tips = getConvertChildByName(panel, "buy_tips")
    local btn_tips_buy = getConvertChildByName(panel, "btn_tips_buy")
    local btn_vip_buy = getConvertChildByName(panel, "btn_vip_buy")

    local close_btn = getConvertChildByName(panel, "close_btn")

    if is_buy then
        buy_info:setVisible(true)
        buy_tips:setVisible(false)
        btn_tips_buy:setTouchEnabled(false)
        btn_vip_buy:setTouchEnabled(false)
    else
        if player_data:isVip() then
            btn_vip_buy:disable()
        end
        btn_buy:setTouchEnabled(false)
        btn_reduce:setTouchEnabled(false)
        btn_add:setTouchEnabled(false)
        buy_info:setVisible(false)
        buy_tips:setVisible(true)
    end

    local function updateBuyTimesInfo()
        need_gold = buy_gold_rate * buy_num_times
        consume_num:setText(need_gold)
        times_num:setText(buy_num_times)
        if player_data:getGold() < need_gold then
            setUILabelColor(consume_num, ccc3(dexToColor3B(COLOR_RED)))
        else
            setUILabelColor(consume_num, ccc3(dexToColor3B(COLOR_COFFEE)))
        end
        if buy_num_max_times == buy_num_times then
            btn_add:disable()
        else
            btn_add:active()
        end
        if buy_num_times == 1 then
            btn_reduce:disable()
        else
            btn_reduce:active()
        end
    end

    updateBuyTimesInfo()

    btn_buy:setPressedActionEnabled(true) 
    btn_buy:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            getUIManager():close("ClsAppointTradeBuyTips")
            if player_data:getGold() < need_gold then
                local alertType = Alert:getOpenShopType()
                Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, self, {come_type = alertType.VIEW_NORMAL_TYPE})
            else
                local auto_trade_Data = getGameData():getAutoTradeAIHandler()
                auto_trade_Data:askBuyTimes(buy_num_times)
            end
        end,TOUCH_EVENT_ENDED)

    btn_reduce:setPressedActionEnabled(true) 
    btn_reduce:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            buy_num_times = buy_num_times - 1
            updateBuyTimesInfo()
        end,TOUCH_EVENT_ENDED) 

    btn_add:setPressedActionEnabled(true) 
    btn_add:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            buy_num_times = buy_num_times + 1
            updateBuyTimesInfo()
        end,TOUCH_EVENT_ENDED)

    btn_tips_buy:setPressedActionEnabled(true) 
    btn_tips_buy:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)

            buy_tips:setVisible(false)
            btn_tips_buy:setTouchEnabled(false)
            btn_vip_buy:setTouchEnabled(false)

            buy_info:setVisible(true)
            btn_buy:setTouchEnabled(true)
            btn_reduce:setTouchEnabled(true)
            btn_add:setTouchEnabled(true)
        end,TOUCH_EVENT_ENDED)

    btn_vip_buy:setPressedActionEnabled(true) 
    btn_vip_buy:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            getUIManager():close("ClsAppointTradeBuyTips")
            --Alert:openShopView(self, nil, nil, ITEM_TYPE_VIP)
            getUIManager():create("gameobj/welfare/clsWelfareMain",nil,1)
        end,TOUCH_EVENT_ENDED)

    close_btn:setPressedActionEnabled(true) 
    close_btn:addEventListener(function()
            audioExt.playEffect(music_info.COMMON_CLOSE.res)
            getUIManager():close("ClsAppointTradeBuyTips")
        end,TOUCH_EVENT_ENDED)

    getUIManager():create("ui/view/clsBaseTipsView", nil, "ClsAppointTradeBuyTips", nil, ui_layer)
end

function ClsAppointTradeUI:closeView( fun )
    self.close_back = fun
    self:close()
end

function ClsAppointTradeUI:setTouch(enable)
    -- self.btn_start:setTouchEnabled(enable)
end

function ClsAppointTradeUI:onExit()
	
	UnRegTrigger(POWER_UPDATE_EVENT)
    UnLoadPlist(self.res_plist)
    ReleaseTexture()
    
end

function ClsAppointTradeUI:onFinish()
    if self.close_back and type(self.close_back) == "function" then
        self.close_back()
    end
end

return ClsAppointTradeUI
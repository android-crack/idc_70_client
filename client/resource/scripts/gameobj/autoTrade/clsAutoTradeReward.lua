--
-- Author: Ltian
-- Date: 2016-11-23 10:54:16
--
local ClsBaseView = require("ui/view/clsBaseView")
local UiCommon = require("ui/tools/UiCommon")
local ui_word=require("game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local ClsAutoTradeReward = class("ClsAutoTradeReward", ClsBaseView)


--页面参数配置方法，注意，是静态方法
function ClsAutoTradeReward:getViewConfig()
    return {
        type = UI_TYPE.TOP, 
        effect = UI_EFFECT.SCALE,   
        is_back_bg = true,
    }
end

function ClsAutoTradeReward:onEnter(rewards, callback)
	self.res_plist = {
        ["ui/auto_trade.plist"] = 1,
    }
    LoadPlist(self.res_plist)
    self.callback = callback
    self.rewards = rewards

    self:regTouchEvent(self, function(event, x, y)
    return self:onTouch(event, x, y) end)

	self:init()
end

function ClsAutoTradeReward:init()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/auto_trade_result.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    --添加的特效层
    self.effectLayer = CCLayer:create()
    self:addChild(self.effectLayer, -1)
    CompositeEffect.new("tx_result_light", display.cx , display.cy +75, self.effectLayer)

    self.gold_num = getConvertChildByName(self.panel, "gold_num")
    self.exp_num = getConvertChildByName(self.panel, "exp_num")
    self.letter_num = getConvertChildByName(self.panel, "letter_num")
    self.vip = getConvertChildByName(self.panel, "vip")
    self.sup_vip_bg = getConvertChildByName(self.panel, "sup_vip_bg")
    self.qq_vip_bg = getConvertChildByName(self.panel, "qq_vip_bg")
    self.start = getConvertChildByName(self.panel, "start")
    self.wechat_start_icon = getConvertChildByName(self.panel, "wechat_start_icon")
    self.qq_start_icon = getConvertChildByName(self.panel, "qq_start_icon")
    self.friend_degree_text = getConvertChildByName(self.panel, "friend_degree_text")

    self:updateVIPStatus()
    self:updateBootStatus()
    UiCommon:numberEffect(self.gold_num,  0, self.rewards.cash, 30)
    UiCommon:numberEffect(self.exp_num,  0, self.rewards.exp, 30)
    UiCommon:numberEffect(self.letter_num,  0, self.rewards.letter, 30)

    self.friend_degree_text:setVisible(self.rewards.iPercent ~= 0 or self.rewards.boatSkin ~= 0)
    
    local str = ""
    local str_tag = ""
    if self.rewards.iPercent ~= 0 then
        str = string.format(ui_word.MARK_FRIENT_ADD_LAB, self.rewards.iPercent)
        str_tag = "，"        
    end

    if self.rewards.boatSkin ~= 0 then
        str = str..str_tag..string.format(ui_word.MARK_SANBAO_BAOT_ADD_LAB, self.rewards.boatSkin)
        str_tag = "，"        
    end

    if self.rewards.captainGain ~= 0 then
        str = str..str_tag..string.format(ui_word.MARK_TEAM_ADD_LAB, self.rewards.captainGain)
    end

    self.friend_degree_text:setText(ui_word.AUTO_MARK_PROFIT..str)
   
end

function ClsAutoTradeReward:updateVIPStatus()
    local vip_status = getGameData():getBuffStateData():getQQVipStatus()
    if vip_status == 0 then
        self.vip:setVisible(false)
    elseif vip_status == 1 then
        self.vip:setVisible(true)
        self.sup_vip_bg:setVisible(false)
        self.qq_vip_bg:setVisible(true)
    elseif vip_status == 2 then
        self.vip:setVisible(true)
        self.sup_vip_bg:setVisible(true)
        self.qq_vip_bg:setVisible(false)
    end
end

function ClsAutoTradeReward:updateBootStatus()
    local boot_status = getGameData():getBuffStateData():getBootStatus()
    if boot_status == BOOT_QQ then --qq启动
        self.start:setVisible(true)
        self.wechat_start_icon:setVisible(false)
        self.qq_start_icon:setVisible(true)
    elseif boot_status == BOOT_WX then
        self.start:setVisible(true)
        self.wechat_start_icon:setVisible(true)
        self.qq_start_icon:setVisible(false)
    else
        self.start:setVisible(false)
    end
end

function ClsAutoTradeReward:onTouch(event, x, y)
    if event == "began" then
        self:onTouchBegan(x, y)
    end
end

function ClsAutoTradeReward:onTouchBegan(x , y)
    self:close()
    return false
end

function ClsAutoTradeReward:onFinish( ... )
     if type(self.callback) == "function" then
        self.callback()
    end
end
return ClsAutoTradeReward
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local baozang_info = require("game_config/collect/baozang_info")
local CompositeEffect=require("gameobj/composite_effect")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsRewardUI = class("ClsRewardUI", ClsBaseView)

local offset_x = 579
local offset_y = 40
local start_x = 959
local start_y = 296

--页面参数配置方法，注意，是静态方法
function ClsRewardUI:getViewConfig()
    return {
        name = "ClsRewardUI",
        type = UI_TYPE.TIP,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

function ClsRewardUI:onEnter(parameter)
	self.rewards = parameter
    
    self.resPlist = {
        ["ui/baowu.plist"] = 1,
        ["ui/equip_icon.plist"] = 1,
        ["ui/material_icon.plist"] = 1,
    }
    LoadPlist(self.resPlist)

	self:configUI()
    self:configEvent()
    self:runMoveAction()
end

local AWARD_NUM = 5
function ClsRewardUI:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/relic_award.json")
    self:addWidget(self.panel)

    self.reward_objs = {}
    for k = 1, AWARD_NUM do
        local item_name = string.format("award_%d", k)
        local item = getConvertChildByName(self.panel, item_name)
        item.icon = getConvertChildByName(item, string.format("award_icon_%d", k))
        item.num = getConvertChildByName(item, string.format("award_num_%d", k))

        function item:setText(txt, color)
            self.num:setText(txt)
            if color then
                self.num:setUILabelColor(color)
            end
        end

        function item:changeTexture(icon)
            self.icon:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
        end

        item:addEventListener(function()
            local tip_ui = getUIManager():get("ClsRewardTip")
            if not tolua.isnull(tip_ui) then return end

            tip_ui = getUIManager():create("gameobj/relic/clsRewardTip", nil, item.reward)
            local item_size = item:getSize()
            local item_pos = item:getWorldPosition()
            local tip_x = item_pos.x + item_size.width / 2
            local tip_y = item_pos.y + item_size.height - 10
            tip_y = math.min(tip_y, display.height - 300)
            tip_y = math.max(tip_y, 0)
            tip_ui.panel:setPosition(ccp(tip_x, tip_y))
        end, TOUCH_EVENT_ENDED)

        item:setTouchEnabled(false)
        item:setVisible(false)
        item:setPosition(ccp(start_x, start_y - ((k - 1) * offset_y)))
        table.insert(self.reward_objs, item)
    end

    for k, v in ipairs(self.rewards) do
        local item_res, amount, scale, name, _, _, color = getCommonRewardIcon(v)
        local item = self.reward_objs[k]
        item.reward = v
        item:setTouchEnabled(true)
        item:setVisible(true)
        local show_txt = string.format("%s x%s", name, amount)
        item:setText(show_txt, QUALITY_COLOR_NORMAL[color])
        item:changeTexture(item_res)
    end

    self.bg = getConvertChildByName(self.panel, "bg")
    self.effect_layer = getConvertChildByName(self.panel, "effect_layer")
    local top_effect = CompositeEffect.new("tx_0039xunhuan", 485, 390, self.effect_layer)
end

function ClsRewardUI:configEvent()
    local bg_size = self.bg:getSize()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            local bg_world_pos = self.bg:getWorldPosition()
            local anchor_p = self.bg:getAnchorPoint()
            local offset_x = bg_size.width * anchor_p.x
            local offset_y = bg_size.height * anchor_p.y
            local orign_x, orign_y = bg_world_pos.x - offset_x, bg_world_pos.y - offset_y
            if x >= orign_x and x <= orign_x + bg_size.width and y >= orign_y and y <= orign_y + bg_size.height then
                return false
            end
            return true
        elseif event_type == "ended" then
            local collect_data = getGameData():getCollectData()
            collect_data:cleanTenExploreReward()
            self:close()
        end
    end)
end

function ClsRewardUI:runMoveAction()
    local function move(index)
        local obj = self.reward_objs[index]
        local arr = CCArray:create()
        local audio_act = CCCallFunc:create(function() 
            -- audioExt.playEffect(music_info.PORT_INFO_UP.res)
        end)
        local move_act = CCMoveBy:create(0.2, ccp(-offset_x, 0))
        local act = CCSpawn:createWithTwoActions(audio_act, move_act)
        arr:addObject(act)
        arr:addObject(CCCallFunc:create(function() 
            local next_index = index + 1
            if next_index <= #self.reward_objs then
                move(next_index)
            end
        end))
        obj:runAction(CCSequence:create(arr))
    end
    move(1)
end

function ClsRewardUI:onExit()
    UnLoadPlist(self.resPlist)
end

return ClsRewardUI
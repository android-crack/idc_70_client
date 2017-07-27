local ui_word = require("game_config/ui_word")
local UiTools = require("gameobj/uiTools")
local sailor_info = require("game_config/sailor/sailor_info")
local composite_effect = require("gameobj/composite_effect")

--好友领取红包提示类
local ClsBaseView = require("ui/view/clsBaseView")
local ClsFriendRedpackUI = class("ClsFriendRedpackUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsFriendRedpackUI:getViewConfig()
    return {
        name = "ClsFriendRedpackUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsFriendRedpackUI:onEnter(parameter)
    self:setIsWidgetTouchFirst(true)

    self.parameter = parameter
    self:configUI()
    self:configEvent()
end

function ClsFriendRedpackUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_red_envelope.json")
    self:addWidget(self.panel)

    local widget_info = {
        [1] = {name = "effect_layer"},
        [2] = {name = "player_name"},
        [3] = {name = "friendly_num"},
        [4] = {name = "diamond_icon"},
        [5] = {name = "diamond_num"},
        [6] = {name = "tips_text"},
        [7] = {name = "head_icon"},
        [8] = {name = "title_art_pic"}
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end

    local parent_pos = self.title_art_pic:convertToWorldSpace(ccp(0,0))
    local effect_pos_1 = parent_pos.y + self.title_art_pic:getSize().height/2 + 9
    self.effect_1 = composite_effect.new("tx_arena_award", display.cx + 3, effect_pos_1, self.effect_layer)
    self.effect_2 = composite_effect.new("tx_guild_red_packet_open", display.cx, effect_pos_1 + 32, self.effect_layer)
    local data = self.parameter

    local player_photo_id = nil
    if not data.icon or data.icon == "" or tonumber(data.icon) == 0 then
        player_photo_id = 101
    else
        player_photo_id = tonumber(data.icon)
    end
    
    self.head_icon:changeTexture(sailor_info[player_photo_id].res, UI_TEX_TYPE_LOCAL)
    self.player_name:setText(data.name)
    local friend_data = getGameData():getFriendDataHandler()
    local intimacy_info = friend_data:getCurStageMaxIntimacy(data.intimacy)
    if not intimacy_info then return end

    local show_txt = string.format("(%s):  %d/%d", intimacy_info.name, data.intimacy - intimacy_info.exp[1], intimacy_info.exp[2] - intimacy_info.exp[1])
    self.friendly_num:setText(show_txt)

    local rewards = data.rewards 
    local temp_reward = {["key"] = rewards[1].type, ["value"] = rewards[1].amount}
    local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon(temp_reward)
    self.diamond_icon:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
    self.diamond_num:setText(amount)

    local gift_info = friend_data:getGiftInfo(amount)
    self.tips_text:setText(gift_info.desc)
end

function ClsFriendRedpackUI:configEvent()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            self:close()
            return false
        end
    end)
end

return ClsFriendRedpackUI
local tool = require("module/dataHandle/dataTools")
local arena_stage = require("game_config/arena/arena_stage")
local music_info = require("scripts/game_config/music_info")
local ui_word = require("game_config/ui_word")
local UiTools = require("gameobj/uiTools")
local CompositeEffect = require("gameobj/composite_effect")
local Alert = require("ui/tools/alert")

local ClsBaseView = require("ui/view/clsBaseView")
local ClsArenaUpRewardUI = class("ClsArenaUpRewardUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsArenaUpRewardUI:getViewConfig()
    return {
        name = "ClsArenaUpRewardUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true,
    }
end

--页面创建时调用
function ClsArenaUpRewardUI:onEnter(parameter)
    self:setIsWidgetTouchFirst(true)

    self.armature_tab = {
        "effects/tx_arena_award.ExportJson",
    }

    LoadArmature(self.armature_tab)

    self.parameter = parameter
    self:configUI()
    self:configEvent()
end

function ClsArenaUpRewardUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/arena_rank_award.json")
    self:addWidget(self.panel)

    self.effect_layer = getConvertChildByName(self.panel, "effect_layer")

    self.title_name = getConvertChildByName(self.panel, "title_name")
    self.title_name:setVisible(false)

    self.arena_rank_icon = getConvertChildByName(self.panel, "arena_rank_icon")
    self.arena_rank_num = getConvertChildByName(self.panel, "arena_rank_num")

    local stage_info = arena_stage[self.parameter.stage_id]
    self.title_name:setText(stage_info.name)
    self.arena_rank_icon:changeTexture(stage_info.bottom, UI_TEX_TYPE_PLIST)
    self.arena_rank_num:changeTexture(stage_info.num, UI_TEX_TYPE_PLIST)

    local effect = CompositeEffect.new("tx_arena_award", 480, 375, self.effect_layer, -1)
    audioExt.playEffect(music_info.ARENA_RANK_AWARD.res)
    local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(1))
    arr:addObject(CCCallFunc:create(function()
        for k, v in ipairs(self.parameter.rewards) do
            local pic = getConvertChildByName(self.panel, string.format("award_icon_%d", k))
            local text = getConvertChildByName(self.panel, string.format("award_num_%d", k))
            pic:setVisible(true)
            text:setVisible(true)
            local icon, amount = getCommonRewardIcon(v)
            pic:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
            text:setText(amount)
        end
        self.title_name:setVisible(true)
    end))
    self:runAction(CCSequence:create(arr))
end

function ClsArenaUpRewardUI:configEvent()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            self:close()
            return true
        end
    end)
end

function ClsArenaUpRewardUI:onExit()
    UnLoadArmature(self.armature_tab)
    ReleaseTexture()
end

return ClsArenaUpRewardUI
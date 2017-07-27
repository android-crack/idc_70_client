local tool = require("module/dataHandle/dataTools")
local arena_stage = require("game_config/arena/arena_stage")
local ui_word = require("game_config/ui_word")
local UiTools = require("gameobj/uiTools")
local music_info = require("scripts/game_config/music_info")
local scheduler = CCDirector:sharedDirector():getScheduler()

-- ARENA_STAGE_TIP = 1
-- ARENA_BOX_TIP = 2
-- ARENA_INTRODUCE_TIP = 3

--竞技场提示类
local ClsBaseView = require("ui/view/clsBaseView")
local ClsArenaTipMainUI = class("ClsArenaTipMainUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsArenaTipMainUI:getViewConfig()
    return {
        name = "ClsArenaTipMainUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--页面创建时调用
function ClsArenaTipMainUI:onEnter(parameter)
    audioExt.playEffect(music_info.TOWN_CARD.res)
    self:setIsWidgetTouchFirst(true)
    self.parameter = parameter
    self:configUI()
    self:configEvent()
end

function ClsArenaTipMainUI:showStageTip()
    local widget_info = {
        [1] = {name = "level_icon"},
        [2] = {name = "grade_title"},
        [3] = {name = "grade_text"},
        [4] = {name = "up_text"},
        [5] = {name = "level_num"},
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.grade_panel, v.name)
    end

    local arena_data = getGameData():getArenaData()
    local cur_stage_info = arena_data:getCurStageInfo()
    local arena_info = arena_data:getArenaInfo()
    if not arena_info then cclog("竞技场数据为空") return end
    
    local offset = arena_info.stage_exp - cur_stage_info.exp
    local next_stage_info = arena_stage[cur_stage_info.index + 1]
    if not next_stage_info then
        self.up_text:setVisible(false)
        local pre_stage_info = arena_stage[cur_stage_info.index - 1]
        self.grade_text:setText(string.format(ui_word.ARENA_CUR_GRADE, offset, cur_stage_info.exp - pre_stage_info.exp))
        return
    end

    local next_all = next_stage_info.exp - cur_stage_info.exp
    self.level_icon:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
    self.level_num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)


    local reward_stage_info = arena_data:getRewardStageInfo()        
    local name = reward_stage_info.name
    self.grade_title:setText(name)
    self.grade_text:setText(string.format(ui_word.ARENA_CUR_GRADE, offset, next_all))
    self.up_text:setText(string.format(ui_word.ARENA_GOAL_STAGE, next_stage_info.name))
       
    local cur_index = self.parameter.index
    local sub_panel_name = string.format("info_%d", cur_index)
    self[sub_panel_name] = getConvertChildByName(self.grade_panel, sub_panel_name)
    self[sub_panel_name]:setVisible(true)

    if cur_index == 1 then--进度条点击TIP
        local get_pic = getConvertChildByName(self.info_1, "get_pic")
        local reward_tab_name = next_stage_info.upgrade_reward
        if not reward_tab_name or reward_tab_name == "" then cclog("没有奖励") return end
        local path = string.format("game_config/arena/%s", reward_tab_name)
        local rewards = require(path)
        for k, v in pairs(rewards) do
            local pic = getConvertChildByName(self.info_1, string.format("icon_%d", k))
            local text = getConvertChildByName(self.info_1, string.format("text_%d", k))
            pic:setVisible(true)
            text:setVisible(true)
            local assemb_data = getCommonRewardData(v)
            local icon, amount = getCommonRewardIcon(assemb_data)
            pic:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
            text:setText(amount)
        end
    elseif cur_index == 2 then--平台点击TIP
        local platform = self.parameter.item
        local grade_tips_num = getConvertChildByName(self[sub_panel_name], "grade_tips_num")
        grade_tips_num:setText(string.format("+%d", platform.exp))
    end
end

function ClsArenaTipMainUI:showBoxTip()
    local arena_data = getGameData():getArenaData()
    local cur_box_reward = arena_data:getBoxRewardInfo()
    if not cur_box_reward then return end
    local box_status = arena_data:getBoxStatus()

    local widget_info = {
        [1] = {name = "level_title"},
        [2] = {name = "get_pic"}
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end

    self.get_pic:setVisible(box_status == STATUS_EMPTY)
    local arena_data = getGameData():getArenaData()
    local cur_stage_info = arena_data:getCurStageInfo()
    local reward_stage_info = arena_data:getRewardStageInfo()        
    local name = reward_stage_info.name
    
    self.level_title:setText(name)

    self.reward_items = {}
    for k = 1, #cur_box_reward do
        local item = {}
        local icon_name = string.format("icon_%d", k)
        local txt_name = string.format("text_%d", k)
        item.icon = getConvertChildByName(self.panel, icon_name)
        item.txt = getConvertChildByName(self.panel, txt_name)

        item.icon:setVisible(true)
        item.txt:setVisible(true)

        table.insert(self.reward_items, item)
    end

    for k, v in ipairs(cur_box_reward) do
        local temp_reward = {["key"] = v.type, ["value"] = v.amount, ["id"] = v.id}
        local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon(temp_reward)
        self.reward_items[k].icon:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
        self.reward_items[k].txt:setText(amount)
    end
end

function ClsArenaTipMainUI:showIntroduceTip()

end

local kind_func = {
    [ARENA_STAGE_TIP] = ClsArenaTipMainUI.showStageTip,
    [ARENA_BOX_TIP] = ClsArenaTipMainUI.showBoxTip,
    [ARENA_INTRODUCE_TIP] = ClsArenaTipMainUI.showIntroduceTip
}

function ClsArenaTipMainUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/arena_info.json")
    self:addWidget(self.panel)

    self.info_bg = getConvertChildByName(self.panel, "info_bg")
    local bg_size = self.info_bg:getSize()
    local start_x = (display.width - bg_size.width) / 2
    local start_y = (display.height - bg_size.height) / 2
    self.touch_rect = CCRect(start_x, start_y, bg_size.width, bg_size.height)

    local panel_info = {
        [1] = {name = "grade_panel", kind = ARENA_STAGE_TIP},
        [2] = {name = "introduce_panel", kind = ARENA_INTRODUCE_TIP},
        [3] = {name = "level_panel", kind = ARENA_BOX_TIP},
    }

    for k, v in ipairs(panel_info) do
        local panel = getConvertChildByName(self.panel, v.name)
        panel:setVisible(v.kind == self.parameter.kind)
        self[v.name] = panel
    end
    kind_func[self.parameter.kind](self)
    UiTools:scrollTipShowAction(self.info_bg)
end

function ClsArenaTipMainUI:configEvent()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
             self:close()
            return false
        end
    end)
end

return ClsArenaTipMainUI
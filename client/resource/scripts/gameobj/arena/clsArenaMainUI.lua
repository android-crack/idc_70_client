local ui_word = require("game_config/ui_word")
local boat_type_icon = require("game_config/boat/boat_type_icon")
local arena_stage = require("game_config/arena/arena_stage")
local role_info = require("game_config/role/role_info")
local CompositeEffect = require("gameobj/composite_effect")
local nobility_data = require("game_config/nobility_data")
local music_info = require("scripts/game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local scheduler = CCDirector:sharedDirector():getScheduler()
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local PLATFORM_NUM = 9
local FIGHT_PEOPLE = 9 --挑战的总人数
local PER_PEOPLE_TIME = 3 --每一个人能挑战的次数
local GET_REWARD_TIME = 10--每天领奖时间
local OPACITY_MAX = 255

local STATUS_PLATFORM_FIGHTED = 1--已经打过了
local STATUS_PLATFORM_LOCK = 2--还未解锁
local STATUS_PLATFORM_TIP = 3--未解锁而且有任务

local ClsArenaMainUI = class("ClsArenaMainUI", ClsBaseView)
--页面参数配置方法，注意，是静态方法
function ClsArenaMainUI:getViewConfig()
    return {
        name = "ClsArenaMainUI",
        type = UI_TYPE.VIEW,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        effect = UI_EFFECT.FADE, 
    }
end

--页面创建时调用
function ClsArenaMainUI:onEnter()
    local arena_data = getGameData():getArenaData()
    arena_data:askAreaInfo()
    self:setIsWidgetTouchFirst(true)
    self.res_plist = {
        ["ui/arena_ui.plist"] = 1,
        ["ui/box.plist"] = 1,
        ["ui/baowu.plist"] = 1,
        ["ui/arena_rank.plist"] = 1,
    }

    LoadPlist(self.res_plist)

    self.armature_tab = {
        "effects/tx_0053.ExportJson",
        "effects/tx_0096.ExportJson",
        "effects/tx_arena_bar.ExportJson",
        "effects/tx_arena_bar_grow.ExportJson"
    }

    LoadArmature(self.armature_tab)

    local audio_res = "VOICE_PLOT_1015"
    local player_data = getGameData():getPlayerData()
    local role_id = player_data:getRoleId()
    local defaults_sex = tonumber(role_info[role_id].sex)
    if defaults_sex == 1 then --男
        audio_res = "VOICE_PLOT_1012"
    end
    local voice_info = getLangVoiceInfo()
    audioExt.playEffect(voice_info[audio_res].res)

    self.is_show_legend = false --是否显示传奇界面
    self.is_show_common = false --是否显示普通界面

    self.platform_tab = {}
    self.grade_tab = {}
    self:makeUI()
end

function ClsArenaMainUI:makeUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/arena.json")
    self:addWidget(self.panel)

    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:effectClose()
    end, TOUCH_EVENT_ENDED)
end

function ClsArenaMainUI:tryShowCommonUI()
	local clsArenaLegendUI = getUIManager():get("ClsArenaLegendUI")
    if not tolua.isnull(clsArenaLegendUI) then
        clsArenaLegendUI:close()
    end

    if not self.is_show_common then
        self:configUI()
        self:configEvent()
        self:startHelm()
    end

    

    self.is_show_common = true
end

function ClsArenaMainUI:tryShowLegendUI()
    if not self.is_show_legend then
        getConvertChildByName(self.panel, "panel_hid"):setEnabled(false)
        getUIManager():create("gameobj/arena/clsArenaLegendUI")
    end
    self.is_show_legend = true
end

function ClsArenaMainUI:configUI()
    getConvertChildByName(self.panel, "panel_hid"):setEnabled(true)
    self.btn_reset = getConvertChildByName(self.panel, "btn_reset")
    self.btn_reset.text = getConvertChildByName(self.btn_reset, "reset_times")
    self.area_bg = getConvertChildByName(self.panel, "area_bg")
    local btn_reset_visible = self.btn_reset.setVisible
    function self.btn_reset:setVisible(enable)
        btn_reset_visible(self, enable)
        self:setTouchEnabled(enable)
    end
    self.btn_reset:setVisible(false)

    for k = 1, 10 do
        local name = string.format("ship_%d", k)
        self[name] = getConvertChildByName(self.panel, name)
    end

    --平台信息
    for k = 1, PLATFORM_NUM do
        local name = string.format("platform_%d", k)
        local num = string.format("num_%d", k)
        local level = string.format("level_icon_%d", k)
        local flag = string.format("flag_%d", k)
        local count_down_text = string.format("count_down_text_%d", k)
        local light_pic = string.format("light_pic_%d", k)
        local selected_circle = string.format("selected_circle_%d", k)
        local level_num = string.format("level_num_%d", k)
        local item = getConvertChildByName(self.panel, name)
        self:setTouchRect(item, {offset_x = 15, offset_y = 15})

        item.num = getConvertChildByName(item, num)
        item.level = getConvertChildByName(item, level)
        item.level.num = getConvertChildByName(item, level_num)
        item.flag = getConvertChildByName(item, flag)
        item.count_down_text = getConvertChildByName(self.panel, count_down_text)
        item.light_pic = getConvertChildByName(item, light_pic)
        item.selected_circle = getConvertChildByName(item, selected_circle)
        self.platform_tab[#self.platform_tab + 1] = item
    end

    self.rank_name = getConvertChildByName(self.panel, "rank_name")
    --段位条
    self.bar_panel = getConvertChildByName(self.panel, "bar_panel")
    self.bar = getConvertChildByName(self.panel, "bar")
    self.bar_effect_layer = getConvertChildByName(self.panel, "bar_effect_layer")
    self.bar_num = getConvertChildByName(self.panel, "bar_num")

    local grade_btn_info = {
        [1] = {name = "bar_level_start", num = "start_num"},
        [2] = {name = "bar_level_end", num = "end_num"},
    }
    for k, v in ipairs(grade_btn_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item.num = getConvertChildByName(item, v.num)
        self:setTouchRect(item)
        table.insert(self.grade_tab, item)
        self[v.name] = item
    end

    --宝箱
    self.box_panel = getConvertChildByName(self.panel, "box_panel")
    self.btn_box = getConvertChildByName(self.box_panel, "btn_box")

    function self.box_panel:setBoxStatus(status)
        for k, v in ipairs(self.box_tab) do
            v:setVisible(v.status == status)
        end
    end

    local function showBoxTip()
        cclog("显示宝箱提示")
        getUIManager():create("gameobj/arena/clsArenaTipMainUI", nil, {kind = ARENA_BOX_TIP})

        -- local rewards_list = {
        --     [1] = {
        --         ['type'] = ITEM_INDEX_GOLD,
        --         ['amount'] = 100,
        --     },
        --     [2] = {
        --         ['type'] = ITEM_INDEX_PROP,
        --         ['amount'] = 90,
        --         ['id'] = 10
        --     }
        -- }
        -- rpc_client_arena_take_stage_reward(5, rewards_list)
    end

    local function getBoxReward()
        cclog("获得宝箱奖励")
        local arena_data = getGameData():getArenaData()
        arena_data:askGetSalary()
    end

    local function showGetedTip()
        getUIManager():create("gameobj/arena/clsArenaTipMainUI", nil, {kind = ARENA_BOX_TIP})
    end

    local btn_box_info = {
        [1] = {name = "btn_box_close", status = STATUS_CLOSE, event = showBoxTip},
        [2] = {name = "btn_box_get", status = STATUS_GET, event = getBoxReward},
        [3] = {name = "btn_box_empty", status = STATUS_EMPTY, event = showGetedTip},
    }
    self.box_panel.box_tab = {}
    for k, v in ipairs(btn_box_info) do
        local item = getConvertChildByName(self.box_panel, v.name)
        item.status = v.status
        if type(v.event) == "function" then
            item:addEventListener(function() 
                v.event()
            end, TOUCH_EVENT_ENDED)
        end
        local box_visible_func = item.setVisible
        function item:setVisible(enable)
            box_visible_func(self, enable)
            self:setTouchEnabled(enable)
        end
        table.insert(self.box_panel.box_tab, item)
    end

    self.box_check_tip = getConvertChildByName(self.box_panel, "box_tips1")
    self.box_get_tip = getConvertChildByName(self.box_panel, "box_tips2")

    --删除按钮
    self.bar_tips = getConvertChildByName(self.panel, "bar_tips")
    self.bar_tips:setVisible(false)
    --头像
    self.head_panel = getConvertChildByName(self.panel, "head_panel")
    self.head_panel:setOpacity(0)
    self.black_head = getConvertChildByName(self.panel, "black_head")
    self.black_head.tip = getConvertChildByName(self.panel, "over_tip_success")
    self.black_head.tip:setVisible(false)
    
    self.rival_text = getConvertChildByName(self.panel, "rival_text")
    self.head_panel.head = getConvertChildByName(self.panel, "seaman_icon")
    self.head_panel.prestige_num = getConvertChildByName(self.panel, "prestige_num")
    self.head_panel.sailor_type = getConvertChildByName(self.panel, "sailor_type")
    self.head_panel.sailor_title = getConvertChildByName(self.panel, "sailor_title")
    self.head_panel.sailor_text = getConvertChildByName(self.panel, "sailor_text")
    self.head_panel.level_num = getConvertChildByName(self.panel, "level_num")
    self.head_panel.time_text = getConvertChildByName(self.panel, "time_text")

    self.head_panel.btn_search = getConvertChildByName(self.panel, "btn_search")
    self.title_frame_bg = getConvertChildByName(self.panel, "title_frame_bg")
    self:setTouchRect(self.title_frame_bg)

    self.head_bg_circle = getConvertChildByName(self.panel, "head_bg_circle")
    self:setTouchRect(self.head_bg_circle)

    local btn_info = {
        [1] = {name = "btn_close"},
        [2] = {name = "btn_match"}
    }

    for k, v in ipairs(btn_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
        self[v.name]:setPressedActionEnabled(true)
        self[v.name]:setTouchEnabled(true)
    end

    self.btn_match.status = STATUS_AVERAGE --开始的时候是匀速

    local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
    ClsGuideMgr:tryGuide("ClsArenaMainUI")
end

function ClsArenaMainUI:setTouchRect(item, parameter)
    if not parameter then
        parameter = {}
    end

    local offset_x = parameter.offset_x or 0
    local offset_y = parameter.offset_y or 0

    local world_pos = item:getWorldPosition()
    local item_size = item:getSize()
    local start_x = world_pos.x - item_size.width / 2
    local start_y = world_pos.y - item_size.height / 2
    item.touch_rect = CCRect(start_x - offset_x, start_y - offset_x, item_size.width + 2 * offset_x, item_size.height + 2 * offset_y)
end

function ClsArenaMainUI:getTodaySecond()
    local player_data = getGameData():getPlayerData()
    local current_time = player_data:getCurServerTime()
    return (current_time + 28800) % 86400
end

--用来判断是否到领奖时间
function ClsArenaMainUI:isCanGetBoxReward()
    local goal_second = GET_REWARD_TIME * 60 * 60
    local today_second = self:getTodaySecond()
    return (today_second >= goal_second)
end

function ClsArenaMainUI:updatePlatformView(stage_info)
    local arena_data = getGameData():getArenaData()
    local win_num = arena_data:getWinPeopleNum()
    for k, v in ipairs(self.platform_tab) do
        if k <= win_num then
            v.status = STATUS_PLATFORM_FIGHTED
            v:disable()
        else
            v.status = STATUS_PLATFORM_LOCK
            v:active()
            v:setTouchEnabled(false)--完全自己判断
        end
        v.flag:setVisible(k <= win_num)
        v.num:setVisible(k > win_num)
        local exp = arena_data:getTaskExp(k)
        if exp ~= nil and k > win_num then
            v.status = STATUS_PLATFORM_TIP
            v.count_down_text:setVisible(true)
            v.level:setVisible(true)
            v.light_pic:setVisible(true)
            v.level:changeTexture(stage_info.bottom, UI_TEX_TYPE_PLIST)
            v.level.num:changeTexture(stage_info.num, UI_TEX_TYPE_PLIST)
            v.count_down_text:setText(string.format("+%d", exp))
            self.platform_tab[k].exp = exp
            local arr = CCArray:create()
            arr:addObject(CCMoveBy:create(1, ccp(0, 10)))
            arr:addObject(CCMoveBy:create(1, ccp(0, -10)))
            local action = CCSequence:create(arr)
            v.level:runAction(CCRepeatForever:create(action))
        else
            v.level:setVisible(false)
            v.count_down_text:setVisible(false)
            v.light_pic:setVisible(false)
        end

        if (k == win_num + 1) then
            v.selected_circle:setVisible(true)
            local fade_in = CCFadeTo:create(0.25, 255 * 0.5)
            local fade_out = CCFadeTo:create(0.25, 255)
            local arr = CCArray:create()
            arr:addObject(fade_in)
            arr:addObject(fade_out)
            local action = CCSequence:create(arr)
            v.selected_circle:runAction(CCRepeatForever:create(action))
        else
            v.selected_circle:setVisible(false)
        end
    end
end

--根据当前的竞技场信息更新界面
function ClsArenaMainUI:updateView(info)
    local arena_data = getGameData():getArenaData()
    local win_num = arena_data:getWinPeopleNum()

    if arena_data:isOver() then
        self.btn_match:disable()
        self.black_head.tip:setVisible(true)
    else
        self.btn_match:active()
        self.black_head.tip:setVisible(false)
    end

    if not tolua.isnull(self.ship_effect) then 
        self.ship_effect:removeFromParentAndCleanup(true)
        self.ship_effect = nil
    end

    if tolua.isnull(self.ship_effect) then 
        self.ship_effect = CCArmature:create("tx_0053")
        self.ship_effect:setScaleX(-1) 
        local armatureAnimation = self.ship_effect:getAnimation()
        armatureAnimation:playByIndex(0)
        self.ship_effect:setZOrder(100)
        local index = win_num + 1
        local pos = self[string.format("ship_%d", index)]:getPosition()
        self.ship_effect:setPosition(ccp(pos.x, pos.y))
        self.area_bg:addCCNode(self.ship_effect)
    end

    local box_status = arena_data:getBoxStatus()
    local cur_stage_info = arena_data:getCurStageInfo()
    self.box_panel:setBoxStatus(box_status)

    local reward_stage_info = arena_data:getRewardStageInfo()        
    local name = reward_stage_info.name

    self.box_check_tip:setText(string.format(ui_word.ARENA_BOX_TIP, name))

    local next_stage_info = arena_stage[cur_stage_info.index + 1]
    
    local pre_stage_info = arena_stage[cur_stage_info.index - 1]
    local next_next_stage_info = arena_stage[cur_stage_info.index + 2]

    if cur_stage_info.minWin and cur_stage_info.minWin > 0 then
        self.bar_tips:setVisible(true)
        self.bar_tips:setText(string.format(ui_word.ARENA_BOTTOM_TIP, cur_stage_info.minWin, cur_stage_info.sub))
    else
        self.bar_tips:setVisible(false)
    end

    local exp_status = arena_data:getExpStatus()
    if exp_status == ARENA_EXP_NOT_CHANGE then
        self:updatePlatformView(cur_stage_info)
        self.rank_name:setText(cur_stage_info.name)

        self.bar_level_start:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
        self.bar_level_start.num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)
        self.bar_level_end:changeTexture(next_stage_info.bottom, UI_TEX_TYPE_PLIST)
        self.bar_level_end.num:changeTexture(next_stage_info.num, UI_TEX_TYPE_PLIST)

        local arena_info = arena_data:getArenaInfo()
        local offset = arena_info.stage_exp - cur_stage_info.exp
        local next_all = next_stage_info.exp - cur_stage_info.exp
        self.bar_num:setText(string.format("%d/%d", offset, next_all))
        self.bar:setPercent(100 * offset / next_all)
    elseif exp_status == ARENA_EXP_UP then--经验涨了
        local up_info = arena_data:getUpStageInfo()
        if up_info then--升阶了
            self:updatePlatformView(pre_stage_info)--平台信息
            self.rank_name:setText(pre_stage_info.name)--段位信息

            local latest_exp = arena_data:getLatestExp()
            local next_all = cur_stage_info.exp - pre_stage_info.exp
            local offset = latest_exp - pre_stage_info.exp
            self.bar_num:setText(string.format("%d/%d", offset, next_all))
            self.bar_num.value = offset
            self.bar:setPercent(100 * offset / next_all)

            self.bar_level_start:changeTexture(pre_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_start.num:changeTexture(pre_stage_info.num, UI_TEX_TYPE_PLIST)
            self.bar_level_end:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_end.num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)
            self:openUpProgressScheduler()
        else
            self:updatePlatformView(cur_stage_info)
            self.rank_name:setText(cur_stage_info.name)

            local latest_exp = arena_data:getLatestExp()
            local offset = latest_exp - cur_stage_info.exp
            local next_all = next_stage_info.exp - cur_stage_info.exp
            self.bar_num:setText(string.format("%d/%d", offset, next_all))
            self.bar_num.value = offset
            self.bar:setPercent(100 * offset / next_all)

            self.bar_level_start:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_start.num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)
            self.bar_level_end:changeTexture(next_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_end.num:changeTexture(next_stage_info.num, UI_TEX_TYPE_PLIST)
            self:openNotChangeScheduler()
        end
    elseif exp_status == ARENA_EXP_DOWN then --经验降了
        local down_info = arena_data:getDownStageInfo()
        if down_info then--降阶了
            self:updatePlatformView(next_stage_info)--平台信息
            self.rank_name:setText(next_stage_info.name)--段位信息

            local latest_exp = arena_data:getLatestExp()
            local next_all = next_next_stage_info.exp - next_stage_info.exp
            local offset = latest_exp - next_stage_info.exp
            self.bar_num:setText(string.format("%d/%d", offset, next_all))
            self.bar_num.value = offset
            self.bar:setPercent(100 * offset / next_all)

            self.bar_level_start:changeTexture(pre_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_start.num:changeTexture(pre_stage_info.num, UI_TEX_TYPE_PLIST)
            self.bar_level_end:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_end.num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)
            self:openDownProgressScheduler()
        else
            self:updatePlatformView(cur_stage_info)
            self.rank_name:setText(cur_stage_info.name)

            local latest_exp = arena_data:getLatestExp()
            local offset = latest_exp - cur_stage_info.exp
            local next_all = next_stage_info.exp - cur_stage_info.exp
            self.bar_num:setText(string.format("%d/%d", offset, next_all))
            self.bar_num.value = offset
            self.bar:setPercent(100 * offset / next_all)

            self.bar_level_start:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_start.num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)
            self.bar_level_end:changeTexture(next_stage_info.bottom, UI_TEX_TYPE_PLIST)
            self.bar_level_end.num:changeTexture(next_stage_info.num, UI_TEX_TYPE_PLIST)
            self:openNotChangeScheduler(ARENA_EXP_DOWN)
        end
    end
end

function ClsArenaMainUI:stopUpBarScheduler()
    if self.bar_up_scheduler then
        scheduler:unscheduleScriptEntry(self.bar_up_scheduler)
        self.bar_up_scheduler = nil
    end 
end

function ClsArenaMainUI:openUpProgressScheduler()
    local add_offset = 1
    local arena_data = getGameData():getArenaData()
    local cur_stage_info = arena_data:getCurStageInfo()
    local latest_exp = arena_data:getLatestExp()
    local pre_stage_pos = cur_stage_info.index - 1
    local pre_stage_info = arena_stage[pre_stage_pos]
    local next_all = cur_stage_info.exp - pre_stage_info.exp
    local total_offset = cur_stage_info.exp - latest_exp
    local effect = CompositeEffect.new("tx_arena_bar_grow", 500, 51, self.bar_effect_layer, -1)
    local up = false
    local function moveCallBack()
        if add_offset <= total_offset then
            local cur_value = self.bar_num.value
            local next_value = cur_value + 1
            self.bar_num:setText(string.format("%d/%d", next_value, next_all))
            self.bar_num.value = next_value
            self.bar:setPercent((100 * next_value / next_all))
            add_offset = add_offset + 1
            if add_offset > total_offset and not up then
                up = true
                add_offset = 1
                local next_stage_info = arena_stage[cur_stage_info.index + 1]
                next_all = next_stage_info.exp - cur_stage_info.exp
                local arena_info = arena_data:getArenaInfo()
                total_offset = arena_info.stage_exp - cur_stage_info.exp
                self.bar_num.value = 0
                self.bar:setPercent(0)
                self.bar_num:setText(string.format("%d/%d", 0, next_all))
                local effect = CompositeEffect.new("tx_arena_bar", 500, 51, self, -1)
                audioExt.playEffect(music_info.ARENA_RANK_UP.res)
                effect:setScale(0.75)
                local arr = CCArray:create()
                arr:addObject(CCDelayTime:create(1))
                arr:addObject(CCCallFunc:create(function() 
                    self.bar_level_start:changeTexture(cur_stage_info.bottom, UI_TEX_TYPE_PLIST)
                    self.bar_level_start.num:changeTexture(cur_stage_info.num, UI_TEX_TYPE_PLIST)
                    self.bar_level_end:changeTexture(next_stage_info.bottom, UI_TEX_TYPE_PLIST)
                    self.bar_level_end.num:changeTexture(next_stage_info.num, UI_TEX_TYPE_PLIST)
                    self:updatePlatformView(cur_stage_info)
                    self.rank_name:setText(cur_stage_info.name)
                end))
                arr:addObject(CCDelayTime:create(1))
                arr:addObject(CCCallFunc:create(function() 
                    local effect = CompositeEffect.new("tx_arena_bar_grow", 500, 51, self.bar_effect_layer, -1)
                end))
                self:runAction(CCSequence:create(arr))
            end
        else
            arena_data:setLatestGrade()
            self:stopUpBarScheduler()
        end
    end

    self:stopUpBarScheduler()
    self.bar_up_scheduler = scheduler:scheduleScriptFunc(moveCallBack, 0.01, false)
end

function ClsArenaMainUI:stopDownBarScheduler()
    if self.bar_down_scheduler then
        scheduler:unscheduleScriptEntry(self.bar_down_scheduler)
        self.bar_down_scheduler = nil
    end 
end

function ClsArenaMainUI:openDownProgressScheduler()
    local down_offset = -1
    local arena_data = getGameData():getArenaData()
    local cur_stage_info = arena_data:getCurStageInfo()
    local latest_exp = arena_data:getLatestExp()
    local next_stage_info = arena_stage[cur_stage_info.index + 1]
    local next_next_stage_info = arena_stage[cur_stage_info.index + 2]
    local next_all = next_next_stage_info.exp - next_stage_info.exp
    local total_offset = latest_exp - next_stage_info.exp
    local down = false
    local function moveCallBack()
        if math.abs(down_offset) <= math.abs(total_offset) then
            local cur_value = self.bar_num.value
            local next_value = cur_value - 1
            self.bar_num:setText(string.format("%d/%d", next_value, next_all))
            self.bar_num.value = next_value
            self.bar:setPercent((100 * next_value / next_all))
            down_offset = down_offset - 1
            if math.abs(down_offset) > math.abs(total_offset) and not down then
                down = true
                down_offset = -1
                next_all = next_stage_info.exp - cur_stage_info.exp
                local arena_info = arena_data:getArenaInfo()
                total_offset = next_all - (arena_info.stage_exp - cur_stage_info.exp)
                self.bar_num.value = next_stage_info.exp - cur_stage_info.exp
                self.bar:setPercent(100)
                self.bar_num:setText(string.format("%d/%d", next_stage_info.exp - cur_stage_info.exp, next_all))
                self:updatePlatformView(cur_stage_info)
                self.rank_name:setText(cur_stage_info.name)
            end
        else
            arena_data:setLatestGrade()
            self:stopDownBarScheduler()
        end
    end

    self:stopDownBarScheduler()
    self.bar_down_scheduler = scheduler:scheduleScriptFunc(moveCallBack, 0.01, false)
end

function ClsArenaMainUI:stopNotChangeScheduler()
    if self.not_change_scheduler then
        scheduler:unscheduleScriptEntry(self.not_change_scheduler)
        self.not_change_scheduler = nil
    end
end

function ClsArenaMainUI:openNotChangeScheduler(kind)
    local arena_data = getGameData():getArenaData()
    local cur_stage_info = arena_data:getCurStageInfo()
    local next_stage_info = arena_stage[cur_stage_info.index + 1]
    local next_all = next_stage_info.exp - cur_stage_info.exp

    local cur_offset = 1
    local step = 1
    local total_offset = arena_data:getUpExpOffset()
    if kind == ARENA_EXP_DOWN then
        cur_offset = -1
        step = -1
        total_offset = arena_data:getDownExpOffset()
    else
        local effect = CompositeEffect.new("tx_arena_bar_grow", 500, 51, self.bar_effect_layer, -1)
    end

    local function moveCallBack()
        if math.abs(cur_offset) <= math.abs(total_offset) then
            local cur_value = self.bar_num.value
            local next_value = cur_value + step
            self.bar_num:setText(string.format("%d/%d", next_value, next_all))
            self.bar_num.value = next_value
            self.bar:setPercent((100 * next_value / next_all))
            cur_offset = cur_offset + step
        else
            arena_data:setLatestGrade()
            self:stopNotChangeScheduler()
        end
    end

    self:stopNotChangeScheduler()
    self.not_change_scheduler = scheduler:scheduleScriptFunc(moveCallBack, 0.01, false)
end

function ClsArenaMainUI:configEvent()

    self.btn_match:addEventListener(function()
        cclog("开始匹配")
        self:startMatchTarget()
    end, TOUCH_EVENT_ENDED)

    self.head_panel.btn_search:setPressedActionEnabled(true)
    self.head_panel.btn_search:addEventListener(function() 
        cclog("船长信息查询")
        local arena_data = getGameData():getArenaData()
        local target = arena_data:getCurFighter()
        if target.is_robot ~= 0 then
            Alert:warning({msg = ui_word.ARENA_GET_ROLE_INFO_OVER_TIME})
            return
        end
        local playerData = getGameData():getPlayerData()
        if target.uid == playerData:getUid() then
            getUIManager():create("gameobj/playerRole/clsRoleInfoView")
        else
            arena_data:askTargetInfo()
        end
    end, TOUCH_EVENT_ENDED)

    self.btn_reset:addEventListener(function()
        Alert:showAttention(ui_word.ARENA_RESET_TIP, function()
            local arena_data = getGameData():getArenaData()
            arena_data:askResetTarget() 
        end)
    end, TOUCH_EVENT_ENDED)

    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            return true
        elseif event_type == "ended" then
            self:touchEndCall(x, y)
        end
    end)
end

function ClsArenaMainUI:touchEndCall(x, y)
    --平台
    local touch_pos = ccp(x, y)
    for k, v in ipairs(self.platform_tab) do
        if v.touch_rect:containsPoint(touch_pos) then
            if v.status == STATUS_PLATFORM_FIGHTED then
                Alert:warning({msg = ui_word.ARENA_IS_FIGHTED})
            elseif v.status == STATUS_PLATFORM_LOCK then
                Alert:warning({msg = ui_word.ARENA_IS_LOCK})
            elseif v.status == STATUS_PLATFORM_TIP then
                getUIManager():create("gameobj/arena/clsArenaTipMainUI", nil, {kind = ARENA_STAGE_TIP, index = 2, item = v})
            end
            return
        end
    end

    --段位
    for k, v in ipairs(self.grade_tab) do
        if v.touch_rect:containsPoint(touch_pos) then
            getUIManager():create("gameobj/arena/clsArenaTipMainUI", nil, {kind = ARENA_STAGE_TIP, index = 1})
            return
        end
    end

    --竞技场提示
    if self.title_frame_bg.touch_rect:containsPoint(touch_pos) then
        getUIManager():create("gameobj/arena/clsArenaTipMainUI", nil, {kind = ARENA_INTRODUCE_TIP})
        return
    end

    if self.head_bg_circle.touch_rect:containsPoint(touch_pos) then
        if self.head_panel:getOpacity() == OPACITY_MAX then
            local arena_data = getGameData():getArenaData()
            local target = arena_data:getCurFighter()
            if target.is_robot ~= 0 then
                Alert:warning({msg = ui_word.ARENA_GET_ROLE_INFO_OVER_TIME})
                return
            end
            arena_data:askTargetInfo()
        end
    end
end

function ClsArenaMainUI:showMatchInfo(info, enter)
    if info.uid == 0 then
        self.head_panel:setOpacity(0)
        self.black_head:setOpacity(255)
        return
    end
    local nobility_info = nobility_data[info.nobility]
    if nobility_info then
        self.head_panel.sailor_title:changeTexture(convertResources(nobility_info.peerage_before), UI_TEX_TYPE_PLIST)
    end
    self.head_panel.sailor_text:setText(info.name)
    self.head_panel.level_num:setText(info.level)
    self.head_panel.prestige_num:setText(info.power)
    local role_icon = JOB_RES[info.role]
    self.head_panel.sailor_type:changeTexture(role_icon, UI_TEX_TYPE_PLIST)
    local arena_data = getGameData():getArenaData()
    self.head_panel.time_text:setText(string.format("%d/%d", info.fails, PER_PEOPLE_TIME))
    self.head_panel.head:changeTexture(string.format("ui/seaman/seaman_%s.png", info.icon), UI_TEX_TYPE_LOCAL)
    self.head_panel:setOpacity(0)
    local arena_data = getGameData():getArenaData()
    self.rival_text:setText(string.format(ui_word.ARENAA_FITHED_TIP, arena_data:getCurFigherNum(), FIGHT_PEOPLE))
    if enter then
        local arr = CCArray:create()
        arr:addObject(CCFadeIn:create(0.5))
        arr:addObject(CCDelayTime:create(3))
        arr:addObject(CCCallFunc:create(function() 
            local arena_data = getGameData():getArenaData()
            arena_data:askFight()
        end))   
        self.head_panel:runAction(CCSequence:create(arr))
        self.black_head:runAction(CCFadeOut:create(0.5))
    else
        self.head_panel:setOpacity(OPACITY_MAX)
        self.black_head:setOpacity(0)
    end
end

local reamin_times = 1
local all_times = 1

function ClsArenaMainUI:setResetBtnVisible(enable)
    self.btn_reset:setVisible(enable)
    if enable then
        self.btn_reset.text:setText(string.format("%d/%d", reamin_times, all_times))
    end
end

function ClsArenaMainUI:startMatchTarget()
    if not tolua.isnull(self.rotate_effect) then
        return
    end

    audioExt.playEffect(music_info.ARENA_MATCH.res)
    getUIManager():create("ui/clsShieldLayer")
    self.rotate_effect = CCArmature:create("tx_0096")
    local armature = self.rotate_effect:getAnimation()
    armature:playByIndex(0, -1, -1, 1)
    self.rotate_effect:setPosition(ccp(0, 0))
    self.rotate_effect:setZOrder(2)
    self.btn_match:addCCNode(self.rotate_effect)

    self:setHelmStatus(STATUS_ADD_SPEED)
    local arena_data = getGameData():getArenaData()
    local is_have_fighter = arena_data:isCurHaveFighter()
    self.btn_match.sound_effect = audioExt.playEffect(music_info.ARENA_STAR.res)
    if is_have_fighter then
        local cur_fighter = arena_data:getCurFighter()
        if cur_fighter.fails == 2 then
            Alert:showAttention(ui_word.ARENA_FINAL_CHANCE, function()
                arena_data:askFight()
            end, function() 
                self:resetView()
            end)
        else
            arena_data:askFight()
        end
    else
        arena_data:askMatchInfo()
    end
end

function ClsArenaMainUI:setHelmStatus(status)
    self.btn_match.status = status
end

function ClsArenaMainUI:resetView()
    self.btn_match.status = STATUS_AVERAGE
    if not tolua.isnull(self.rotate_effect) then
        self.rotate_effect:removeFromParentAndCleanup(true)
        self.rotate_effect = nil
    end

    getUIManager():close("ClsShieldLayer")
end

function ClsArenaMainUI:showFailView()
    self.btn_match:disable()
end

function ClsArenaMainUI:getHelmStatus()
    return self.btn_match.status
end

function ClsArenaMainUI:setHelmRotate(value)
    local cur_rotate = self.btn_match:getRotation()
    self.btn_match:setRotation(cur_rotate + value)
end

function ClsArenaMainUI:stopHelmScheduler()
    if self.helm_scheduler then
        scheduler:unscheduleScriptEntry(self.helm_scheduler)
        self.helm_scheduler = nil
    end 
end

function ClsArenaMainUI:startHelm()
    local move_angle = 1
    local add_angle = 0.07
    local detect_time = 0.001
    local max_angle = 20
    local function rotateCallBack()
        if self:getHelmStatus() == STATUS_ADD_SPEED then
            move_angle = move_angle + add_angle
            move_angle = math.min(move_angle, max_angle)
        else
            move_angle = 1
        end
        self:setHelmRotate(move_angle)
    end

    self:stopHelmScheduler()
    self.helm_scheduler = scheduler:scheduleScriptFunc(rotateCallBack, detect_time, false)
end

--UnLoadArmature()和ReleaseTexture()要一起使用
function ClsArenaMainUI:onExit()
	UnLoadPlist(self.res_plist)
    UnLoadArmature(self.armature_tab)
    ReleaseTexture()
    
    self:stopHelmScheduler()
    self:stopNotChangeScheduler()
    self:stopDownBarScheduler()
    self:stopUpBarScheduler()

    if not tolua.isnull(self.btn_match) and
        self.btn_match.sound_effect then
        
        audioExt.stopEffect(self.btn_match.sound_effect)
    end
end

return ClsArenaMainUI
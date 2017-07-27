local sailor_info = require("game_config/sailor/sailor_info")
local music_info = require("game_config/music_info")
local nobility_data = require("game_config/nobility_data")
local ui_word = require("game_config/ui_word")
local area_info = require("game_config/port/area_info")
local uiTools = require("gameobj/uiTools")
local tool = require("module/dataHandle/dataTools")
local ClsAlert = require("ui/tools/alert")
local port_info = require("game_config/port/port_info")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")

local scheduler = CCDirector:sharedDirector():getScheduler()
local MAX_TIMES = 1

local cell_info = {
    [1] = {name = "head_icon"},
    [2] = {name = "state_text"},
    [3] = {name = "player_title"},
    [4] = {name = "player_name"},
    [5] = {name = "player_level"},
    [6] = {name = "area_name"},
    [7] = {name = "gold_icon"},
    [8] = {name = "gold_num"},
    [9] = {name = "player_power_num"},
    [10] = {name = "win_panel"},
    [11] = {name = "fail_panel"},
    [12] = {name = "select_pic"},
}

local ClsPlunderedCell = class("ClsPlunderedCell", ClsScrollViewItem)

function ClsPlunderedCell:updateUI(cell_date, panel)
    local data = cell_date
    self.btn_tab = {}

    for k, v in ipairs(cell_info) do
        local item = getConvertChildByName(panel, v.name)
        item.name = v.name
        self[v.name] = item
    end

    local loot_data = getGameData():getLootData()

    --商会求助面板
    self.help_panel = getConvertChildByName(panel, "help_panel")
    local btn_help = getConvertChildByName(self.help_panel, "btn_help")
    btn_help:setPressedActionEnabled(true)
    btn_help.last_time = 0
    btn_help:addEventListener(function()
        if CCTime:getmillistimeofCocos2d() - btn_help.last_time < 5000 then
            ClsAlert:warning({msg = ui_word.TEAM_BTN_CLICK_TIP})
            return
        end
        btn_help.last_time = CCTime:getmillistimeofCocos2d()

        local guild_info_data = getGameData():getGuildInfoData()
        local guild_id = guild_info_data:getGuildId()
        local is_add_guild = nil
        if guild_id and guild_id ~= 0 then
            is_add_guild = true
        else
            is_add_guild = false
        end

        if not is_add_guild then
            ClsAlert:warning({msg = ui_word.HELP_NOTICE_JOIN_GUILD})
        else
            loot_data:askGuildHelp(data.id, data.name)
        end
    end, TOUCH_EVENT_ENDED)
    local txt_guild_help = getConvertChildByName(self.help_panel, "txt_guild_help")
    self.help_panel.btn = btn_help
    self.help_panel.txt = txt_guild_help
    local help_panel_visible = self.help_panel.setVisible
    function self.help_panel:setVisible(enable)
        help_panel_visible(self, enable)
        self.btn:setTouchEnabled(enable)
    end

    --追踪进行中面板
    self.tracing_panel = getConvertChildByName(panel, "tracing_panel")
    self.tracing_panel.cell = self
    function self.tracing_panel:openScheduler()
        local function updateCount()
            if tolua.isnull(self) then return end
            local player_data = getGameData():getPlayerData()
            local cur_time = player_data:getCurServerTime()
            local tracing_info = loot_data:getTracingInfo()
            local remain_cd = tracing_info.duration - cur_time + tracing_info.trace_time
            if remain_cd > 0 then
                local show_txt = tostring(tool:getTimeStrNormal(remain_cd))
                self.time:setText(show_txt)
            else
                self:closeScheduler()
                loot_data:setTracingInfo(nil)
                self.cell.trace_panel:setVisible(true)
                self.cell.tracing_panel:setVisible(false)
            end
        end
        self:closeScheduler()
        self.update_scheduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
    end

    function self.tracing_panel:closeScheduler()
        if self.update_scheduler then
            scheduler:unscheduleScriptEntry(self.update_scheduler)
            self.update_scheduler = nil
        end
    end

    local btn_tracing = getConvertChildByName(self.tracing_panel, "btn_tracing")
    btn_tracing:setPressedActionEnabled(true)
    btn_tracing:addEventListener(function() 
        ClsAlert:warning({msg = ui_word.TRACING_PLAYER})
    end, TOUCH_EVENT_ENDED)
    local countdown_time = getConvertChildByName(self.tracing_panel, "countdown_time")
    local text_port_1 = getConvertChildByName(self.tracing_panel, "text_port_1")
    self.tracing_panel.btn = btn_tracing
    self.tracing_panel.time = countdown_time
    self.tracing_panel.port = text_port_1
    local btn_tracing_visible = self.tracing_panel.setVisible
    function self.tracing_panel:setVisible(enable)
        btn_tracing_visible(self, enable)
        self.btn:setTouchEnabled(enable)
        if enable then
            self:openScheduler()
            local show_txt = nil
            local info = nil
            local tracing_info = loot_data:getTracingInfo()
            if tracing_info.is_arrest then
                info = port_info[tracing_info.port_id]
                show_txt = string.format(ui_word.LOOT_ARREST_TIP, info.name)
            elseif tracing_info.port_id > 0 then
                info = port_info[tracing_info.port_id]
                show_txt = string.format(ui_word.PLAYER_AT_WHERE, info.name)
            elseif tracing_info.area_id > 0 then
                info = area_info[tracing_info.area_id]
                show_txt = string.format(ui_word.PLAYER_AT_WHERE, info.name)
            end
            if show_txt then
                self.port:setVisible(true)
                self.port:setText(show_txt)
            else
                self.port:setVisible(false)
            end
        else
            self:closeScheduler()
        end
    end

    --追踪面板
    self.trace_panel = getConvertChildByName(panel, "trace_panel")
    local btn_trace = getConvertChildByName(self.trace_panel, "btn_trace")
    btn_trace:setPressedActionEnabled(true)
    btn_trace:addEventListener(function()
        local is_can_trace = loot_data:isCanTrace(data.id)
        if is_can_trace then
            local show_txt = ui_word.TRACE_PLAYER_TIP
            local is_have_tracing = loot_data:isHaveTracing()
            if is_have_tracing then
                show_txt = ui_word.TRACE_PLAYER_TIP2
            end
            ClsAlert:showAttention(show_txt, function()
                loot_data:askStartTracePlayer(data.id)    
            end)
        else
            ClsAlert:warning({msg = ui_word.NOT_TRACE_AGAIN})
        end
    end, TOUCH_EVENT_ENDED)
    local trace_num = getConvertChildByName(self.trace_panel, "trace_num")
    self.trace_panel.btn = btn_trace
    self.trace_panel.num = trace_num
    local trace_panel_visible = self.trace_panel.setVisible
    function self.trace_panel:setVisible(enable)
        trace_panel_visible(self, enable)
        self.btn:setTouchEnabled(enable)
        if enable then
            local remain_trace_num = 1
            local color = COLOR_COFFEE
            if not loot_data:isCanTrace(data.id) then
                remain_trace_num = 0
                color = COLOR_RED
            end
            self.num:setText(string.format("%d/1", remain_trace_num))
            self.num:setUILabelColor(color)
        end
    end

    function self.trace_panel:updateNum()
        local player_data = getGameData():getPlayerData()
        local cur_time = player_data:getCurServerTime()
        if data.trace_num == 0 then
            self.num:setText(string.foramt("%d/%d", 1, MAX_TIMES)) 
        end
    end

    --头像
    local player_photo_id = nil
    if not data.icon or data.icon == "" or tonumber(data.icon) == 0 then
        player_photo_id = 101
    else
        player_photo_id = tonumber(data.icon)
    end

    --点击头像出现船长信息
    self.head_icon:setTouchEnabled(true)
    self.head_icon:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        getUIManager():create("gameobj/captionInfo/clsCaptainInfoMain", nil, cell_date.target_id)
    end, TOUCH_EVENT_ENDED)

    self.head_icon:changeTexture(sailor_info[player_photo_id].res, UI_TEX_TYPE_LOCAL)
    local head_size = self.head_icon:getContentSize()
    self.head_icon:setScale(90 / head_size.height)

    --登录状态
    self.state_text:setVisible(true)
    local last_login_time_text, latest_login_time = uiTools:getLoginStatus(data.lastLoginTime)
    self.state_text:setText(last_login_time_text)
    self.state_text:setOpacity(255)--先还原
    if data.lastLoginTime ~= ONLINE then
        self.state_text:setOpacity(255 / 2)
    end

    --爵位
    local nobility_info = nobility_data[data.nobility]
    if nobility_info then
        self.player_title:setVisible(true)
        self.player_title:changeTexture(convertResources(nobility_info.peerage_before), UI_TEX_TYPE_PLIST)
    else
        self.player_title:setVisible(false)
    end

    self.player_name:setText(data.name)
    if data.level then 
        self.player_level:setText(string.format("Lv.%s", data.level))
    end
    self.area_name:setText(area_info[data.area].name)
    local reward_icon = "common_icon_coin.png"
    if data.is_gold ~= 0 then
        reward_icon = "common_icon_diamond.png"
    end
    self.gold_icon:changeTexture(reward_icon, UI_TEX_TYPE_PLIST)
    self.gold_num:setText(math.abs(data.result))
    self.player_power_num:setText(data.zhandouli)

    self.win_panel:setVisible(data.is_win ~= 0)
    self.fail_panel:setVisible(data.is_win == 0)

    local is_visible = data.is_win == 0 and (data.type == TIME_LOOT_TYPE or data.state == NAME_STATE_WHITE)

    local is_tracing = loot_data:isTracingById(data.id)
    self.trace_panel:setVisible(not is_tracing and is_visible)
    
    self.help_panel:setVisible(is_visible)
    self.tracing_panel:setVisible(is_tracing)
end

function ClsPlunderedCell:preClose()
    if not tolua.isnull(self.tracing_panel) then
        self.tracing_panel:closeScheduler()
    end
end

function ClsPlunderedCell:onTap(x, y)

end

local ClsPlunderedReportUI = class("ClsPlunderedReportUI", function() return UIWidget:create() end)
function ClsPlunderedReportUI:ctor()
    self:configUI()
    self:updateListView()
end

function ClsPlunderedReportUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_prestige.json")
    self:addChild(self.panel)
end

function ClsPlunderedReportUI:updateListView(content)
    if not content then
        local loot_data = getGameData():getLootData()
        content = loot_data:getPlunderedReport()
    end

    --不论有无数据都先清空列表
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
        self.list_view = nil
    end

    if not content then cclog("没有被掠夺数据") return end
    self.list_view = ClsScrollView.new(785, 420, true, function()
        local cell = GUIReader:shareReader():widgetFromJsonFile("json/friend_report_cell.json")
        return cell
    end)

    self.cells = {}
    for k, v in ipairs(content) do
        local cell = ClsPlunderedCell.new(CCSize(768, 104), v)
        self.cells[#self.cells + 1] = cell
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(185, 13))
    self:addChild(self.list_view)
end

function ClsPlunderedReportUI:setUpdateObjs(info)
    if tolua.isnull(self.list_view) then return end
    local loot_data = getGameData():getLootData()
    local is_have_tracing = loot_data:isHaveTracing()
    local temp = {}
    if is_have_tracing then
        if loot_data:isTracingById(info.id) then
            for k, v in ipairs(self.list_view.m_cells) do
                table.insert(temp, v)
                break
            end
            loot_data:setTraceStatusObjs(temp)
            return
        else
            local pre_tracing_info = loot_data:getTracingInfo()
            local find_pre, find_cur = false, false
            for k, v in ipairs(self.list_view.m_cells) do
                if v.m_cell_date.id == pre_tracing_info.id then
                    table.insert(temp, v)
                    find_pre = true
                elseif v.m_cell_date.id == info.id then
                    table.insert(temp, v)
                    find_cur = true
                end
                if find_pre and find_cur then
                    break
                end
            end
            loot_data:setTraceStatusObjs(temp)
        end
    else
        for k, v in ipairs(self.list_view.m_cells) do
            if v.m_cell_date.id == info.id then
                table.insert(temp, v)
                loot_data:setTraceStatusObjs(temp)
                break
            end
        end
    end
end

--追踪状态变化更新
function ClsPlunderedReportUI:updateChangeObjs(objs)
    if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(objs) do
        if v:getIsCreate() then
            v:callUpdateUI()
        end
    end
end

function ClsPlunderedReportUI:updateListCell(info)
    if tolua.isnull(self.list_view) then return end

    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.id == info.id then
            v.m_cell_date = info
            if v:getIsCreate() then
                v:callUpdateUI()
            end
        end
    end
end

function ClsPlunderedReportUI:preClose()
    if tolua.isnull(self.list_view) then
        return
    else
        for k, v in ipairs(self.list_view.m_cells) do
            v:preClose()
        end
    end
end

return ClsPlunderedReportUI


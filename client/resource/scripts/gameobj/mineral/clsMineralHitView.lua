--2016/08/30
--create by wmh0497
--海上的矿npc

local ClsAlert = require("ui/tools/alert")
local news = require("game_config/news")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local port_info = require("game_config/port/port_info")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsMineralHitView = class("ClsMineralHitView", ClsBaseView)

function ClsMineralHitView:onEnter(id)
    self.m_plist_tab = {}
    LoadPlist(self.m_plist_tab)

    self.m_id = id
    
    self:initUI()

    getGameData():getAreaCompetitionData():askMineralPortHurt(self.m_id)
end

--基础ui初始化
function ClsMineralHitView:initUI()
    self.m_panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_ore_rank.json")
    convertUIType(self.m_panel)
    self:addWidget(self.m_panel)

    local bg_spr = getConvertChildByName(self.m_panel, "rank_bg") -- 关闭按钮
    self.m_bars_tab = {}
    for i = 1, 5 do
        local item = {}
        item.per_ui = getConvertChildByName(bg_spr, string.format("progress_%d", i))
        item.per_bar = getConvertChildByName(item.per_ui, string.format("progress_bar_%d", i))
        item.per_lab = getConvertChildByName(item.per_ui, string.format("percent_%d", i))
        item.name_lab = getConvertChildByName(item.per_ui, string.format("text_%d", i))
        item.per_ui:setVisible(false)
        self.m_bars_tab[i] = item
    end
    
    self.m_close_btn = getConvertChildByName(bg_spr, "btn_close")
    self.m_close_btn:setPressedActionEnabled(true)
    self.m_close_btn:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)
end

function ClsMineralHitView:updatePortHurtShow(hurt_data)
    local total_hurt = hurt_data.total_hurt
    local port_hurts = hurt_data.port_hurt
    if total_hurt <= 0 then total_hurt = 1 end
    for i, item in ipairs(self.m_bars_tab) do
        local info = port_hurts[i]
        if info then
            item.per_ui:setVisible(true)
            
            local port_name_str = port_info[info.portId].name
            item.name_lab:setText(port_name_str)
            local per_n = math.floor(info.hurt*100/total_hurt)
            item.per_bar:setPercent(per_n)
            item.per_lab:setText(string.format("%d%%", per_n))
        else
            item.per_ui:setVisible(false)
        end
    end
end

function ClsMineralHitView:onExit()
    UnLoadPlist(self.m_plist_tab)
end

return ClsMineralHitView
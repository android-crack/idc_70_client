--
-- Author: lzg0496
-- Date: 2016-08-04 15:56:18
-- Function: 星级评比

local ui_word = require("scripts/game_config/ui_word")
local ClsComponentBase = require("ui/view/clsComponentBase")
local ClsStarUiComponent = class("ClsStarUiComponent", ClsComponentBase)

function ClsStarUiComponent:onStart()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initJsonUi()
    self.m__stop_change_star = false
end

function ClsStarUiComponent:initJsonUi()
    local star_panel = getConvertChildByName(self.m_explore_sea_ui, "race_star")
    star_panel:setVisible(true)
    
    self.m_star_uis = {}
    for i = 1, 3 do
        local info = {}
        info.star_spr = getConvertChildByName(star_panel, "star_icon_"..i)
        info.desc_lab = getConvertChildByName(star_panel, "star_text_"..i)
        self.m_star_uis[i] = info
    end
end

function ClsStarUiComponent:updateStarUI(amout)
    if not self.m__stop_change_star then
        for k, v in ipairs(self.m_star_uis) do
            if k > amout then
                v.star_spr:setGray(true)
            end
        end
    end
end

function ClsStarUiComponent:stopUpdataStar()
    self.m__stop_change_star = true
end

return ClsStarUiComponent
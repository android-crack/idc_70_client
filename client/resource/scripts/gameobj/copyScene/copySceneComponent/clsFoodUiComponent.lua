--2016/07/23
--create by wmh0497
--组件基类
local ui_word = require("game_config/ui_word")
local ClsComponentBase = require("ui/view/clsComponentBase")
local ClsFoodUiComponent = class("ClsFoodUiComponent", ClsComponentBase)

function ClsFoodUiComponent:onStart()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initJsonUi()
end

function ClsFoodUiComponent:initJsonUi()
    local food_bar_bg_spr = getConvertChildByName(self.m_explore_sea_ui, "food_bar_bg")
    food_bar_bg_spr:setEnabled(true)
    local food_icon_spr = getConvertChildByName(self.m_explore_sea_ui, "food_icon")
    food_icon_spr:setEnabled(true)
    
    self.m_food_lab = getConvertChildByName(self.m_explore_sea_ui, "food_num")
    self.m_food_lab:setEnabled(true)
    self.m_food_bar = getConvertChildByName(food_bar_bg_spr, "food_bar")
    
    self:updateFoodUI(0, 1)
end

function ClsFoodUiComponent:showBtnBack(value)
    local btn_back = getConvertChildByName(self.m_explore_sea_ui, "btn_back")
    btn_back:setVisible(value)
end

function ClsFoodUiComponent:updateFoodUI(cur_food, max_food)
    if max_food <= 0 then
        max_food = 1
    end
    if not tolua.isnull(self.m_food_lab) then
        self.m_food_lab:setText(tostring(cur_food).."/"..tostring(max_food))
    end

    if not tolua.isnull(self.m_food_bar) then
        local percent = cur_food / max_food * 100
        self.m_food_bar:setPercent(percent)
    end
end

return ClsFoodUiComponent




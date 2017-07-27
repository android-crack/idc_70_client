--
-- Function: 
-- Author: lzg0496
-- Date: 2017-02-16 11:28:19
-- 

local clsBaseView = require("ui/view/clsBaseView")
local UI_WORD = require("game_config/ui_word")

local clsExploreLocalUI = class("clsExploreLocalUI", clsBaseView)

function clsExploreLocalUI:getViewConfig()
    return {is_swallow = false}
end

function clsExploreLocalUI:onEnter()
    self:askBaseData()
    self:mkUI()
    self:initUI()
    self:configEvent()
    self:updataUI()
end

function clsExploreLocalUI:askBaseData()
end

function clsExploreLocalUI:mkUI()
    self.panel = createPanelByJson("json/explore_sea_pos.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)
    local need_widget_name = {
        lbl_boat_pos = "boat_pos",
        spr_boat_pos_bg = "boat_pos_bg",
    }

    for k, v in pairs(need_widget_name) do
        self[k] = getConvertChildByName(self.panel, v)
    end
end

function clsExploreLocalUI:initUI()
    self.spr_boat_pos_bg:setPosition(ccp(893, 540))
    self.lbl_boat_pos:setText("")
end

function clsExploreLocalUI:configEvent()
end

function clsExploreLocalUI:updataUI(tx, ty)
    if self.tx == tx and self.ty == ty then
        return
    end
    self.tx = tx
    self.ty = ty

    --(x坐标+12)/1694*360-180 大于0为东经 字母E，小于0为西经 字母是W
    --(y坐标+21)/959*180-90   大于0为南纬 字母是S，小于0为北纬 字母N
    longitude_n = (tx + 12)/1694*360 - 180
    latitude_n = (ty + 21)/959*180 - 90
    local longitude_ew = UI_WORD.MAP_POS_EAST
    if longitude_n < 0 then
        longitude_ew = UI_WORD.MAP_POS_WEST
    end
    longitude_n = Math.abs(longitude_n)

    local latitude_sn = UI_WORD.MAP_POS_NORTH
    if latitude_n > 0 then
        latitude_sn = UI_WORD.MAP_POS_SOUTH
    end
    latitude_n = Math.abs(latitude_n)

    local long_num_1 = Math.floor(longitude_n)
    local long_num_2 = Math.floor((longitude_n - long_num_1)*60)

    local lat_num_1 = Math.floor(latitude_n)
    local lat_num_2 = Math.floor((latitude_n - lat_num_1)*60)

    local lab_str = string.format("%s%d°%d', %s%d°%d'", longitude_ew, long_num_1, long_num_2, latitude_sn, lat_num_1, lat_num_2)
    self.lbl_boat_pos:setText(lab_str)
end

return clsExploreLocalUI
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local base_attr_info = require("game_config/base_attr_info")
local baozang_info = require("game_config/collect/baozang_info")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsRewardTip = class("ClsRewardTip", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsRewardTip:getViewConfig()
    return {
        name = "ClsRewardTip",
        type = UI_TYPE.TIP,    --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = true,      --(选填) 默认true, 是否吞掉下层页面的触摸事件
        is_back_bg = true
    }
end

function ClsRewardTip:onEnter(parameter)
	self.rewards = parameter
    
    self.resPlist = {
        ["ui/item_box.plist"] = 1,
        ["ui/equip_icon.plist"] = 1,
    }
    LoadPlist(self.resPlist)

	self:configUI()
    self:configEvent()
end

function ClsRewardTip:configUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_tips.json")
    self:addWidget(self.panel)

    local widget_info = {
        [1] = {name = "equip_icon_bg"},
        [2] = {name = "equip_icon"},
        [3] = {name = "name"},
        [4] = {name = "info_text"},
        [5] = {name = "lv_num"},
        [6] = {name = "num_txt"},
        [7] = {name = "num_num"},
        [8] = {name = "btn_synthetic"},
        [9] = {name = "btn_use"},
    }

    for k, v in ipairs(widget_info) do
        self[v.name] = getConvertChildByName(self.panel, v.name)
    end
    self.num_txt:setText("")
    self.num_num:setText("")
    self.btn_synthetic:setVisible(false)
    self.btn_use:setVisible(false)

    self.attr_objs = {}
    local attr_key = {"", "_2"}
    for i,k in ipairs(attr_key) do
        local temp = {}
        local temp_name = string.format("property_info%s", k)
        local temp_add = string.format("property_add%s", k)
        temp.name = getConvertChildByName(self.panel, temp_name)
        temp.add = getConvertChildByName(self.panel, temp_add)

        function temp:setVisible(enable)
            self.name:setVisible(enable)
            self.add:setVisible(enable)
        end

        temp:setVisible(false)
        table.insert(self.attr_objs, temp) 
    end

    local baowu_data_handler = getGameData():getBaowuData()
    local baowu_info = baowu_data_handler:getInfoById(self.rewards.id)
    local baowu_data = baozang_info[baowu_info.baowuId]
    local icon_res = baowu_data.res
    self.equip_icon:changeTexture(convertResources(icon_res), UI_TEX_TYPE_PLIST)
    self.name:setText(baowu_data.name)
    self.info_text:setText(baowu_data.desc)

    local quality = baowu_info.step
    self.name:setUILabelColor(QUALITY_COLOR_NORMAL[quality])
    local bg_res = string.format("item_box_%s.png", quality)
    self.equip_icon_bg:changeTexture(bg_res, UI_TEX_TYPE_PLIST)

    self.lv_num:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, baowu_data.level))

    local dataTools = require("module/dataHandle/dataTools")
    for k, v in ipairs(baowu_info.attr) do
        local attr_obj = self.attr_objs[k]
        attr_obj:setVisible(true)

        attr_obj.name:setText(base_attr_info[v.name].name)
        attr_obj.add:setText(dataTools:getBoatBaowuAttr(v.name, v.value))
    end
end

function ClsRewardTip:configEvent()
    self:regTouchEvent(self, function(event_type, x, y)
        if event_type == "began" then
            local bg_world_pos = self.panel:getWorldPosition()
            local bg_size = self.panel:getSize()
            if x >= bg_world_pos.x and x <= bg_world_pos.x + bg_size.width and y >= bg_world_pos.y and y <= bg_world_pos.y + bg_size.height then
                return false
            end
            return true
        elseif event_type == "ended" then
            self:close()
        end
    end)
end

function ClsRewardTip:onExit()
    UnLoadPlist(self.resPlist)
end

return ClsRewardTip
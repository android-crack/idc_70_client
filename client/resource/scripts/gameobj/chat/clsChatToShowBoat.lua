-- 聊天打开船舶tips
-- Author: Ltian
-- Date: 2016-12-07 19:22:36
--
local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local boat_info = require("game_config/boat/boat_info")
local base_attr_info = require("game_config/base_attr_info")
local boat_attr = require("game_config/boat/boat_attr")
local ClsDataTools = require("module/dataHandle/dataTools")
local nobility_data = require("game_config/nobility_data")
local skill_info = require("game_config/skill/skill_info")

local ClsChatToShowBoat = class("ClsChatToShowBoat", ClsBaseView)

local touch_rect = CCRect(375, 20, 380, 450)

function ClsChatToShowBoat:getViewConfig(...)
    return {
    		type =  UI_TYPE.TOP,
			is_swallow = true,   
		}
end

function ClsChatToShowBoat:onEnter(parameter)
	self.parameter = parameter
    self.res_plist = {
   
    }

    LoadPlist(self.res_plist)

    self:configUI(parameter)
    self:configEvent()
end
local not_show_btn = {
	"btn_discharge",
	"btn_strengthen",
	"btn_equip",
	"ship_name_add" --暂时不要
}

local ship_main_prop = {
	"ship_name",
	"ship_bg",
	"ship_icon",
	"ship_type_icon",
	"job_info",
	"level_info",
	"power_num"
}

local property_label = {
	"equip_title",
	"wash_attribute_text_1",
	"wash_attribute_text_2",
	"wash_attribute_text_3",
	"wash_attribute_text_4",
	"wash_attribute_text_5",
}
function ClsChatToShowBoat:configUI(parameter)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for i,v in ipairs(not_show_btn) do
		getConvertChildByName(self.panel, v):setVisible(false)
	end

	for i,v in ipairs(ship_main_prop) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	self.attr_panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship_property.json")
	convertUIType(self.attr_panel)
	self.porperty_panel = {}
	for i,v in ipairs(property_label) do
		self.porperty_panel[v] = getConvertChildByName(self.attr_panel, v)
		self.porperty_panel[v]:setVisible(false)
	end
	
	self.attr_panel:setPosition(ccp(408, 95))
	self.panel:addChild(self.attr_panel)
	self:updateView()
end


function ClsChatToShowBoat:updateView()
	--基本属性
	local item_res = boat_info[self.parameter.id].res
	self.ship_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	self.ship_name:setText(self.parameter.name)
	local quality = self.parameter.quality
	setUILabelColor(self.ship_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	--类型
	local boat_config = boat_attr[self.parameter.id]
	local fi_type_icon = ClsDataTools:getBoatFiTypeRes(boat_config.fi_type)
	self.ship_type_icon:changeTexture(fi_type_icon, UI_TEX_TYPE_PLIST)
	--职业要求
	local occup_attr = ""
	for i,v in ipairs(boat_config.occup) do
		if string.len(occup_attr) > 0 then
			occup_attr = occup_attr .. ui_word.SIGN_DUANHAO
		end
		occup_attr = occup_attr .. ROLE_OCCUP_NAME[v]
	end
	self.job_info:setText(occup_attr)
	local nobility_config = nobility_data[boat_config.nobility_id]
	if nobility_config then
		self.level_info:setText(nobility_config.title)
		setUILabelColor(self.level_info, ccc3(dexToColor3B(nobility_config.level_color)))
	else
		self.level_info:setText(ui_word.BACKPACK_BOAT_NOBILITY_STR)
	end
	self.power_num:setText(self.parameter.power)
--------------------------------------------------------
	local base_attr_list = self.parameter.base_attrs
	for i,v in ipairs(base_attr_list) do
		local attr_info = {}
		attr_info.attr = getConvertChildByName(self.attr_panel, v.attr .. "_txt")
		attr_info.num = getConvertChildByName(self.attr_panel, v.attr .. "_num")
		attr_info.add = getConvertChildByName(self.attr_panel, v.attr .. "_add")
		attr_info.num:setText(v.value)
		attr_info.add:setVisible(false)
	end

	-- 改造属性
	local normal_attr = {}
    local skill_attr = {}

    for k, v in ipairs(self.parameter.rand_attrs) do
        if v.attr == "boatSkill" then
            table.insert(skill_attr, v)
        else
            table.insert(normal_attr, v)
        end
    end

    local cur_line = 0
    for k, v in ipairs(normal_attr) do
        cur_line = math.ceil(k / 2)
        local item_name = string.format("wash_attribute_text_%d", k)
        local item = self.porperty_panel[item_name]
        item:setVisible(true)
        local show_txt = string.format("%s  +%s", base_attr_info[v.attr].name, v.value)
        item:setText(show_txt)
        setUILabelColor(item, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
    end

    for k, v in ipairs(skill_attr) do
        cur_line = cur_line + 1
        local item_name = string.format("wash_attribute_text_%d", 2 * cur_line - 1)
        local item = self.porperty_panel[item_name]
        item:setVisible(true)
        local skill_attr = skill_info[v.value]
        local sailor_data = getGameData():getSailorData()
        local desc_tab = sailor_data:getSkillDescWithLv(v.value, 1)
        local name = skill_attr.name
        local value = desc_tab.base_desc
        local show_txt = string.format("%s: %s", name, value)
        item:setText(show_txt)
        setUILabelColor(item, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
    end
end
function ClsChatToShowBoat:configEvent()

	self:regTouchEvent(self, function(eventType, x, y)
		print("------------------")
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if not is_in then
			self:onTouchCB()
		end
	end)
end

function ClsChatToShowBoat:onTouchCB()
	self:closeView()
end

function ClsChatToShowBoat:closeView()
	self:close()
end

function ClsChatToShowBoat:onExit()
	UnLoadPlist(self.res_plist)
	
end

return ClsChatToShowBoat
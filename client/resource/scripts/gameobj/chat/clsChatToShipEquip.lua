-- 
-- Author: Ltian
-- Date: 2016-12-08 10:30:56
--
local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local baozang_info = require("game_config/collect/baozang_info")
local base_attr_info = require("game_config/base_attr_info")
local ClsBaseView = require("ui/view/clsBaseView")
local touch_rect = CCRect(360, 160, 240, 240)

local ClsChatToShipEquip = class("ClsChatToShipEquip", ClsBaseView)
function ClsChatToShipEquip:getViewConfig(...)
    return {
		type =  UI_TYPE.TOP,
		is_swallow = true,   
	}
end

function ClsChatToShipEquip:onEnter(parameter)
	self.parameter = parameter
	table.print(parameter)
    self.res_plist = {
   		["ui/item_box.plist"] = 1,
   		["ui/equip_icon.plist"] = 1,

    }

    LoadPlist(self.res_plist)
    self:configUI(parameter)
    self:configEvent()
end

local widget_name = {
	"equip_icon_bg",
	"equip_icon",
	"name",
	"lv_num",
	"num_txt",
	"num_num",
	"property_info",
	"property_add",
	"property_info_2",
	"property_add_2",
	"info_text",
	"btn_synthetic",
	"btn_use",
}

function ClsChatToShipEquip:configUI(parameter)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_tips.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.panel:setPosition(ccp(display.cx - 120, display.cy - 120))
	self:updateView()
end

function ClsChatToShipEquip:updateView()
	self.name:setText(self.parameter.name)
	local quality = self.parameter.step
	setUILabelColor(self.name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	local item_bg_res = string.format("item_box_%s.png", quality)
	self.equip_icon_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)
	local baowu_data = baozang_info[self.parameter.baowuId]
	local item_res = baowu_data.res
	self.equip_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	self.info_text:setText(baowu_data.desc)
	self.lv_num:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, baowu_data.level))
	self.num_txt:setText("")
    self.num_num:setText("")

    local dataTools = require("module/dataHandle/dataTools")
	
	local attr_info = self.parameter.attr[1]
	if attr_info then
		self.property_info:setText(base_attr_info[attr_info.name].name)
		self.property_add:setText(dataTools:getBoatBaowuAttr(attr_info.name, attr_info.value))
	else
		self.property_info:setText("")
		self.property_add:setText("")
	end
	attr_info = self.parameter.attr[2]
	if attr_info then
		self.property_info_2:setText(base_attr_info[attr_info.name].name)
		self.property_add_2:setText(dataTools:getBoatBaowuAttr(attr_info.name, attr_info.value))
	else
		self.property_info_2:setText("")
		self.property_add_2:setText("")
	end
	self.property_info_2:setVisible(true)
	self.property_add_2:setVisible(true)
	self.btn_synthetic:setVisible(false)
	self.btn_use:setVisible(false)
end

function ClsChatToShipEquip:configEvent()
	self:regTouchEvent(self, function(eventType, x, y)
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if not is_in then
			self:onTouchCB()
		end
	end)
end

function ClsChatToShipEquip:onTouchCB()
	self:closeView()
end

function ClsChatToShipEquip:closeView()
	self:close()
end

function ClsChatToShipEquip:onExit()
	UnLoadPlist(self.res_plist)
end

return ClsChatToShipEquip
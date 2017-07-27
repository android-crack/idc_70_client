--
-- Author: Ltian
-- Date: 2016-12-07 20:25:44
--
-- 聊天打开船舶tips
-- Author: Ltian
-- Date: 2016-12-07 19:22:36
--
local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local ClsBaseView = require("ui/view/clsBaseView")
local baozang_info = require("game_config/collect/baozang_info")
local base_attr_info = require("game_config/base_attr_info")

local ClsChatToBaowu = class("ClsChatToBaowu", ClsBaseView)


local touch_rect = CCRect(375, 20, 380, 460)

function ClsChatToBaowu:getViewConfig(...)
    return {
    		type =  UI_TYPE.TOP,
			is_swallow = true,   
		}
end

function ClsChatToBaowu:onEnter(parameter)
	self.parameter = parameter
	table.print(self.parameter)
    self.res_plist = {
   
    }

    LoadPlist(self.res_plist)

    self:configUI(parameter)
    self:configEvent()
end

local not_show_btn = {
	"btn_discharge",
	"btn_dismantling",
	"wash_attribute_txt1",
	"wash_attribute_txt2",
	"wash_attribute_txt3",
	"wash_attribute_txt4",
}

local base_panel = {
	"baowu_icon",
	"ship_name",
	"level_info",
	"attr_info",
	"power_num",
	"attr_text_1",
	"attr_num_1",
	"attr_text_2",
	"attr_num_2",

}

function ClsChatToBaowu:configUI(parameter)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_details.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	for i,v in ipairs(not_show_btn) do
		self[v] = getConvertChildByName(self.panel, v)
		self[v]:setVisible(false)
	end

	for k,v in pairs(base_panel) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:updateView()
end


function ClsChatToBaowu:updateView()
	local baowu_info = baozang_info[self.parameter.baowuId]
	self.baowu_icon:changeTexture(convertResources(baowu_info.res), UI_TEX_TYPE_PLIST)
	self.ship_name:setText(baowu_info.name)
    setUILabelColor(self.ship_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[self.parameter.color])))

    self.level_info:setText(baowu_info.limitLevel)
    self.attr_info:setText(baowu_info.kind)
    self.power_num:setText(self.parameter.power)

	for i=1,#self.parameter.attr do
		local attr = self.parameter.attr[i]
		local attr_text = self["attr_text_" .. i]
		local attr_num = self["attr_num_" .. i]
		if attr then
			attr_text:setText(base_attr_info[attr.name].name)
			attr_num:setText("  " .. attr.value)
		else
			attr_text:setText("")
			attr_num:setText("")
		end
	end
end
function ClsChatToBaowu:configEvent()

	self:regTouchEvent(self, function(eventType, x, y)
		print("------------------")
		local touch_point = ccp(x, y)
		is_in = touch_rect:containsPoint(touch_point)
		if not is_in then
			self:onTouchCB()
		end
	end)
end

function ClsChatToBaowu:onTouchCB()
	self:closeView()
end

function ClsChatToBaowu:closeView()
	self:close()
end

function ClsChatToBaowu:onExit()
	UnLoadPlist(self.res_plist)
	
end

return ClsChatToBaowu
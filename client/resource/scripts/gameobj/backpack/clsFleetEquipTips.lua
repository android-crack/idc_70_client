-- 船只装备界面tips
-- Author: chenlurong
-- Date: 2016-11-12 11:33:02
--

local baozang_info = require("game_config/collect/baozang_info")
local base_attr_info = require("game_config/base_attr_info")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")

local ClsFleetEquipTips = class("ClsFleetEquipTips", ClsBaseTipsView)

function ClsFleetEquipTips:getViewConfig(name_str, params, partner_index, item_key, x, y)
	return ClsFleetEquipTips.super.getViewConfig(self, name_str, params, partner_index, item_key, x, y)
end

function ClsFleetEquipTips:onEnter(name_str, params, partner_index, item_key, x, y)
	local ui_layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_equip_tips.json")
	convertUIType(panel)
	ui_layer:addChild(panel)

	ClsFleetEquipTips.super.onEnter(self, name_str, params, ui_layer, true)

	local bg_size = panel:getContentSize()
	-- ui_layer:setContentSize(CCSize(bg_size.width, bg_size.height))

	local pos_x = x - bg_size.width
	local pos_y = y - bg_size.height
	if pos_y < 0 then
		pos_y = y
	end
	if pos_x < 0 then
		pos_x = x
	end
	ui_layer:setPosition(ccp(pos_x, pos_y))

	local item_icon_bg = getConvertChildByName(panel, "equip_icon_bg")
	local item_icon = getConvertChildByName(panel, "equip_icon")
	local item_name = getConvertChildByName(panel, "name")
	local property_info = getConvertChildByName(panel, "property_info")
	local property_add = getConvertChildByName(panel, "property_add")
	local info_text = getConvertChildByName(panel, "info_text")
	local lv_num = getConvertChildByName(panel, "lv_num")

	local baowu_data_handler = getGameData():getBaowuData()
	local baowu_info = baowu_data_handler:getInfoById(item_key)
	local baowu_data = baozang_info[baowu_info.baowuId]
	local item_res = baowu_data.res
	item_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	item_name:setText(baowu_data.name)
	info_text:setText(baowu_data.desc)

	local quality = baowu_info.step
	setUILabelColor(item_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[quality])))
	local item_bg_res = string.format("item_box_%s.png", quality)
	item_icon_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)

	local partner_data = getGameData():getPartnerData()
	local select_bag_equip = partner_data:getBagEquipInfo(partner_index)
	local equip_sailor_id = select_bag_equip.id

	lv_num:setText(baowu_data.limitLevel)
	local player_data = getGameData():getPlayerData()
	local cur_level = player_data:getLevel()
	if cur_level < baowu_data.limitLevel then
		setUILabelColor(lv_num, ccc3(dexToColor3B(COLOR_RED)))
	end

	-- print("====================================baowu_info")
	-- table.print(baowu_info)
	local attr_info = baowu_info.attr[1]
	if attr_info then
		property_info:setText(base_attr_info[attr_info.name].name)
		property_add:setText("+" .. attr_info.value)
	else
		property_info:setText("")
		property_add:setText("")
	end
end

function ClsFleetEquipTips:bgOnTouch(event, x, y)
    if event == "began" then
    	self:close()
        return false
    end
end


return ClsFleetEquipTips

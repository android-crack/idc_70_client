local music_info=require("scripts/game_config/music_info")
local boat_attr = require("game_config/boat/boat_attr")
local boat_info = require("game_config/boat/boat_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local baozang_info = require("game_config/collect/baozang_info")
local boat_strengthening = require("game_config/boat/boat_strengthening")
local boat_fleet_config = require("game_config/boat/boat_fleet_config")
local nobility_data = require("game_config/nobility_data")
local sailor_info = require("game_config/sailor/sailor_info")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local base_attr_info = require("game_config/base_attr_info")
local skill_info = require("game_config/skill/skill_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")

local base_attr_num = 7
local random_attr_num = 5
local NEED_ALERT_QUALITY = 4

local need_attr = {
	[ATTR_KEY_REMOTE] = "far_strengthening_num",
	[ATTR_KEY_MELEE] = "near_strengthening_num",
	[ATTR_KEY_DEFENSE] = "defense_strengthening_num",
	[ATTR_KEY_DURABLE] = "hpmax_strengthening_num",
}

------------------------------------装备船的属性元件------------------------
local ClsBoatEquipAttrInfo = class("ClsBoatEquipAttrInfo", require("ui/view/clsScrollViewItem"))

function ClsBoatEquipAttrInfo:initUI(cell_data)
	self.data = cell_data
	self:mkUi()
end

function ClsBoatEquipAttrInfo:mkUi()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship_property.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	for i = 1, random_attr_num do
		local item_name = string.format("wash_attribute_text_%d", i)
		self[item_name] = getConvertChildByName(self.panel, item_name)
		self[item_name]:setVisible(false)
	end

	self.equip_title = getConvertChildByName(self.panel, "equip_title")

	local boat_level = self.data.boat_level
	local boat_strengthening_info = boat_strengthening[boat_level]

	self.attr_list = {}
	local boat_data = self.data.boat
	local base_attr_list = boat_data.boat_base_attr
	for i,v in ipairs(base_attr_list) do
		local attr_info = {}
		attr_info.attr = getConvertChildByName(self.panel, v.name .. "_txt")
		attr_info.num = getConvertChildByName(self.panel, v.name .. "_num")
		attr_info.add = getConvertChildByName(self.panel, v.name .. "_add")
		self.attr_list[v.name] = attr_info

		attr_info.attr:setText(base_attr_info[v.name].name)
		attr_info.num:setText(v.value)
		if boat_strengthening_info and need_attr[v.name] then
			attr_info.add:setText("+" .. boat_strengthening_info[need_attr[v.name]])
		else
			attr_info.add:setText("")
		end
	end

	local normal_attr = {}
    local skill_attr = {}
    for k, v in ipairs(boat_data.boat_wash_attr) do
        if v.name == "boatSkill" then
            table.insert(skill_attr, v)
        else
            table.insert(normal_attr, v)
        end
    end

    local cur_line = 0
    for k, v in ipairs(normal_attr) do
        cur_line = math.ceil(k / 2)
        local item_name = string.format("wash_attribute_text_%d", k)
        local item = self[item_name]
        item:setVisible(true)
        local show_txt = string.format("%s  +%s", base_attr_info[v.name].name, v.value)
        item:setText(show_txt)
        setUILabelColor(item, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
    end

    for k, v in ipairs(skill_attr) do
        cur_line = cur_line + 1
        local item_name = string.format("wash_attribute_text_%d", 2 * cur_line - 1)
        local item = self[item_name]
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

	self.equip_title = getConvertChildByName(self.panel, "equip_title")
	self.equip_title:setText(string.format(ui_word.BACKPACK_EQUIP_BOAT_BAOWU_STR, tonumber(self.baowu_num)))
end

function ClsBoatEquipAttrInfo:updateBaowuNum(baowu_num)
	self.baowu_num = baowu_num
	if self.equip_title then
		self.equip_title:setText(string.format(ui_word.BACKPACK_EQUIP_BOAT_BAOWU_STR, baowu_num))
	end
end

------------------------------------装备船上已装备的宝物的列表元件------------
local ClsBoatEquipBaowuInfo = class("ClsBoatEquipBaowuInfo", require("ui/view/clsScrollViewItem"))

function ClsBoatEquipBaowuInfo:initUI(cell_data)
	self.data = cell_data
	self:mkUi()
end

function ClsBoatEquipBaowuInfo:mkUi()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship_equip_list.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	self.panel:setPosition(ccp(30, 0))

	self.equip_bg = getConvertChildByName(self.panel, "equip_bg")
	self.equip_icon = getConvertChildByName(self.panel, "equip_icon")
	self.equip_name = getConvertChildByName(self.panel, "equip_name")
	self.equip_info = getConvertChildByName(self.panel, "equip_info")
	self.equip_info_add = getConvertChildByName(self.panel, "equip_info_add")

	self.equip_bg = getConvertChildByName(self.panel, "equip_bg")
	self.equip_icon = getConvertChildByName(self.panel, "equip_icon")
	self.equip_name = getConvertChildByName(self.panel, "equip_name")
	self.equip_level = getConvertChildByName(self.panel, "equip_level")

	self.equip_items = {}
	for k = 1, 2 do
		local equip_info_name = string.format("equip_info_%d", k)
		local equip_add_name = string.format("equip_info_add_%d", k)
		local temp = {}
		temp.text = getConvertChildByName(self.panel, equip_info_name)
		temp.add = getConvertChildByName(self.panel, equip_add_name)

		function temp:setVisible(enable)
			self.text:setVisible(enable)
			self.add:setVisible(enable)
		end

		function temp:setText(name, value)
			self.text:setText(base_attr_info[name].name)
			local str = ClsDataTools:getBoatBaowuAttr(name, value)
			self.add:setText(str)
		end

		temp:setVisible(false)

		table.insert(self.equip_items, temp)
	end

	local baowu_key = self.data.id
	local baozang_config = baozang_info[baowu_key]
	self.equip_icon:changeTexture(convertResources(baozang_config.res) , UI_TEX_TYPE_PLIST)
	self.equip_name:setText(baozang_config.name)
	setUILabelColor(self.equip_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[baozang_config.star])))
	self.equip_level:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, baozang_config.level))
	setUILabelColor(self.equip_level, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[baozang_config.star])))

	local equip_bg_res = string.format("item_box_%s.png", baozang_config.star)
	self.equip_bg:changeTexture(equip_bg_res, UI_TEX_TYPE_PLIST)

	for k, v in ipairs(self.data.boat_baowu_attr) do
		self.equip_items[k]:setVisible(true)
		self.equip_items[k]:setText(v.name, v.value)
	end
end
------------------------------------------------------------------------------

local CaptainInfoTips = class("CaptainInfoTips", ClsBaseTipsView)
function CaptainInfoTips:getViewConfig(name_str, params)
	return CaptainInfoTips.super.getViewConfig(self, name_str, params)
end

function CaptainInfoTips:onEnter(name_str, params, data,is_baowu)
	self.m_data = data
	if(not is_baowu)then
		self:showBoatTip()
	else
		self:showBaowuTip()
	end
end

function CaptainInfoTips:showBoatTip()
	local widget_name = {
		"btn_discharge",
		"btn_strengthen",
		"btn_equip",
		"ship_icon",
		"ship_type_icon",
		"ship_name",
		"ship_name_add",
		"level_info",
		"job_info",
		"power_num",
	}

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
    for k, v in ipairs(widget_name) do
        self[v] = getConvertChildByName(self.panel, v)
    end
	CaptainInfoTips.super.onEnter(self, "CaptainInfoTips", nil, self.panel, true)

	local rect = CCRect(415, 27, 350, 277)
	local list_cell_size = CCSizeMake(rect.size.width, rect.size.height)

	local cell_list = {}
	local width = 350
	local height = 280

	self.list_view = ClsScrollView.new(width, height, true, nil, {is_fit_bottom = true})
    self.list_view:setPosition(ccp(415, 27))
    self:addWidget(self.list_view)

	local baowu_list = self.m_data.boat_baowus
	local boat_config = boat_attr[self.m_data.boatId]
	local attr_info_item = ClsBoatEquipAttrInfo.new(CCSize(rect.size.width, 205), {boat = self.m_data, attr = boat_config, boat_level = self.m_data.intensifyLevel})
	cell_list[#cell_list + 1] = attr_info_item


	local baowu_num = 0
	for i,v in ipairs(baowu_list) do
		if v and #v.boat_baowu_attr > 0 then
			local baowu_info_item = ClsBoatEquipBaowuInfo.new(CCSize(rect.size.width, 85), v)
			baowu_num = baowu_num + 1
			cell_list[#cell_list + 1] = baowu_info_item
		end
	end
	self.list_view:addCells(cell_list)

	attr_info_item:updateBaowuNum(baowu_num)

    self.btn_discharge:setVisible(false)
    self.btn_strengthen:setVisible(false)
    self.btn_equip:setVisible(false)


	local item_res = boat_info[self.m_data.boatId].res
	self.ship_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)

	local fi_type_icon = ClsDataTools:getBoatFiTypeRes(boat_config.fi_type)
	self.ship_type_icon:changeTexture(fi_type_icon, UI_TEX_TYPE_PLIST)

	local nobility_config = nobility_data[boat_config.nobility_id]

	if nobility_config then
		self.level_info:setText(nobility_config.title)
		setUILabelColor(self.level_info,ccc3(dexToColor3B(nobility_config.level_color)))
	else
		self.level_info:setText(ui_word.BACKPACK_BOAT_NOBILITY_STR)
	end
		
	local occup_attr = ""
	for i,v in ipairs(boat_config.occup) do
		if string.len(occup_attr) > 0 then
			occup_attr = occup_attr .. ui_word.SIGN_DUANHAO
		end
		occup_attr = occup_attr .. ROLE_OCCUP_NAME[v]
	end
	self.job_info:setText(occup_attr)

	self.ship_name:setText(self.m_data.boatName)
	setUILabelColor(self.ship_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[self.m_data.boatColor > 0 and self.m_data.boatColor or 1])))
	self.ship_name_add:setText("+" .. self.m_data.intensifyLevel)
	setUILabelColor(self.ship_name_add,QUALITY_COLOR_STROKE[math.floor(self.m_data.intensifyLevel/10)+1])
	self.power_num:setText(self.m_data.boatPower)
end

--显示装备宝物的数据
function CaptainInfoTips:showBaowuTip()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_baowu_details.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	CaptainInfoTips.super.onEnter(self, "showBaowuTip", nil, self.panel, true)

	self.baowu_icon = getConvertChildByName(self.panel, "baowu_icon")
	self.baowu_name = getConvertChildByName(self.panel, "ship_name")
	self.level_info = getConvertChildByName(self.panel, "level_info")
	self.attr_info = getConvertChildByName(self.panel, "attr_info")

	self.btn_download = getConvertChildByName(self.panel, "btn_discharge")
	self.btn_wash = getConvertChildByName(self.panel, "btn_dismantling")

	self.attr_text_1 = getConvertChildByName(self.panel, "attr_text_1")
	self.attr_num_1 = getConvertChildByName(self.panel, "attr_num_1")
	self.attr_text_2 = getConvertChildByName(self.panel, "attr_text_2")
	self.attr_num_2 = getConvertChildByName(self.panel, "attr_num_2")

	self.power_num = getConvertChildByName(self.panel,"power_num") --宝物声望

	local baowu_info = baozang_info[self.m_data.baowuId]
	self.baowu_icon:changeTexture(convertResources(baowu_info.res), UI_TEX_TYPE_PLIST)
	self.baowu_name:setText(baowu_info.name)
    setUILabelColor(self.baowu_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[self.m_data.color])))

    self.level_info:setText(baowu_info.limitLevel)
    self.attr_info:setText(baowu_info.kind)

	for i=1,2 do
		local attr = self.m_data.base_attrs[i]
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

	self.power_num:setText(self.m_data.power)

	--排序
	table.sort(self.m_data.refine_attrs,function ( a,b )
		return a.pos < b.pos
	end)
	for i=1,4 do
		local attr_txt = getConvertChildByName(self.panel, "wash_attribute_txt" .. i)
		local attr_info = self.m_data.refine_attrs[i]
		if attr_info then

			attr_txt:setText(base_attr_info[attr_info.name].name .. ClsDataTools:getBaowuSpecialAttr(attr_info.name, attr_info.value))
		    setUILabelColor(attr_txt, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[attr_info.color])))
		else
			attr_txt:setText("")
		end
	end

	self.btn_download:setVisible(false)
	self.btn_wash:setVisible(false)
end

function CaptainInfoTips:onExit()
	
end

return CaptainInfoTips
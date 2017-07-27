-- 船只属性tips界面
-- Author: chenlurong
-- Date: 2016-06-27 20:26:05
--

local music_info=require("scripts/game_config/music_info")
local boat_attr = require("game_config/boat/boat_attr")
local boat_info = require("game_config/boat/boat_info")
local skill_info = require("game_config/skill/skill_info")
local base_attr_info = require("game_config/base_attr_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")
local baozang_info = require("game_config/collect/baozang_info")
local boat_strengthening = require("game_config/boat/boat_strengthening")
local boat_fleet_config = require("game_config/boat/boat_fleet_config")
local nobility_data = require("game_config/nobility_data")
local sailor_info = require("game_config/sailor/sailor_info")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local Game3d = require("game3d")
local Main3d = require("gameobj/mainInit3d")

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

	for i = 1,random_attr_num do
		local item_name = string.format("wash_attribute_text_%d", i)
		self[item_name] = getConvertChildByName(self.panel, item_name)
		self[item_name]:setVisible(false)
	end
	self.equip_title = getConvertChildByName(self.panel, "equip_title")

	local boat_level = self.data.boat_level
	local boat_strengthening_info = boat_strengthening[boat_level]

	self.attr_list = {}
	local boat_data = self.data.boat
	local base_attr_list = boat_data.base_attrs
	for i,v in ipairs(base_attr_list) do
		local attr_info = {}
		attr_info.attr = getConvertChildByName(self.panel, v.attr .. "_txt")
		attr_info.num = getConvertChildByName(self.panel, v.attr .. "_num")
		attr_info.add = getConvertChildByName(self.panel, v.attr .. "_add")
		self.attr_list[v.attr] = attr_info

		attr_info.attr:setText(base_attr_info[v.attr].name)
		attr_info.num:setText(v.value)
		if boat_strengthening_info and need_attr[v.attr] then
			attr_info.add:setText("+" .. boat_strengthening_info[need_attr[v.attr]])
		else
			attr_info.add:setText("")
		end
	end

	local normal_attr = {}
    local skill_attr = {}

    for k, v in ipairs(boat_data.rand_attrs) do
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
        local item = self[item_name]
        item:setVisible(true)
        local show_txt = string.format("%s  +%s", base_attr_info[v.attr].name, v.value)
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
	self.equip_info_1 = getConvertChildByName(self.panel, "equip_info_1")
	self.equip_info_2 = getConvertChildByName(self.panel, "equip_info_2")
	self.equip_info_add_1 = getConvertChildByName(self.panel, "equip_info_add_1")
	self.equip_info_add_2 = getConvertChildByName(self.panel, "equip_info_add_2")
	self.equip_level = getConvertChildByName(self.panel, "equip_level")

	local baowu_key = self.data
	local baowu_data = getGameData():getBaowuData()
	local baowu_info = baowu_data:getInfoById(baowu_key)
	local baozang_config = baozang_info[baowu_key]
	self.equip_icon:changeTexture(convertResources(baozang_config.res) , UI_TEX_TYPE_PLIST)
	self.equip_name:setText(baozang_config.name)
	setUILabelColor(self.equip_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[baowu_info.step])))
	self.equip_level:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, baozang_config.level))
	setUILabelColor(self.equip_level, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[baowu_info.step])))

	local equip_bg_res = string.format("item_box_%s.png", baowu_info.step)
	self.equip_bg:changeTexture(equip_bg_res, UI_TEX_TYPE_PLIST)

	local attr_info = baowu_info.attr[1]
	if attr_info then
		self.equip_info_1:setText(base_attr_info[attr_info.name].name)

		local str = ClsDataTools:getBoatBaowuAttr(attr_info.name, attr_info.value)
		self.equip_info_add_1:setText(str)
	else
		self.equip_info_1:setText("")
		self.equip_info_add_1:setText("")
	end

	local attr_info2 = baowu_info.attr[2]
	if attr_info2 then
		self.equip_info_2:setText(base_attr_info[attr_info2.name].name)

		local str = ClsDataTools:getBoatBaowuAttr(attr_info2.name, attr_info2.value)
		self.equip_info_add_2:setText(str)
	else
		self.equip_info_2:setText("")
		self.equip_info_add_2:setText("")
	end

end
------------------------------------------------------------------------------

local ClsBoatAttrTips = class("ClsBoatAttrTips", ClsBaseTipsView)

function ClsBoatAttrTips:getViewConfig(name_str, params, select_index, backpack_boat_key, from_backpack, from_fleet_ui)
	return ClsBoatAttrTips.super.getViewConfig(self, name_str, params, select_index, backpack_boat_key, from_backpack, from_fleet_ui)
end

function ClsBoatAttrTips:onEnter(name_str, params, select_index, backpack_boat_key, from_backpack, from_fleet_ui)
	self.select_index = select_index
	self.from_fleet_ui = from_fleet_ui
	self.ship3d_info = {
		is_init = false,
	}
	missionGuide:disableAllGuide()
	local partner_data = getGameData():getPartnerData()
	self.select_bag_equip = partner_data:getBagEquipInfo(select_index)
	self.equip_sailor_id = self.select_bag_equip.id
	self.equip_boat_key = self.select_bag_equip.boatKey
	if from_backpack then--背包点击的船
		local ship_data = getGameData():getShipData()
		self.boat_data = ship_data:getBoatDataByKey(backpack_boat_key)
		if not self.boat_data then
			self:close()
			return
		end
		self:showBackpackBoatTips(name_str, params)
	else
		self:showEquipBoatTips(name_str, params)
	end
end

function ClsBoatAttrTips:getSkinData()
	
	local partner_data = getGameData():getPartnerData()
	local skin_data = partner_data:getBagEquipSkinByBoatKey(self.equip_boat_key)
	if skin_data and skin_data.skin_enable == 1 then
		return skin_data
	end
end

function ClsBoatAttrTips:setViewEnabled()
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:setViewTouchEnabled(false)
	end

	local clsFleetPartner = getUIManager():get("ClsFleetPartner")
	if not tolua.isnull(clsFleetPartner) then 
		clsFleetPartner:setViewTouchEnabled(false)
	end
end

--显示装备船的数据
function ClsBoatAttrTips:showEquipBoatTips(name_str, params)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	ClsBoatAttrTips.super.onEnter(self, name_str, params, self.panel, true)

	self.ship_icon = getConvertChildByName(self.panel, "ship_icon")
	self.ship_type_icon = getConvertChildByName(self.panel, "ship_type_icon")
	self.ship_name = getConvertChildByName(self.panel, "ship_name")
	self.ship_name_add = getConvertChildByName(self.panel, "ship_name_add")
	self.level_info = getConvertChildByName(self.panel, "level_info")
	self.job_info = getConvertChildByName(self.panel, "job_info")
	self.power_num = getConvertChildByName(self.panel, "power_num")
	self.btn_discharge = getConvertChildByName(self.panel, "btn_discharge")
	self.btn_strengthen = getConvertChildByName(self.panel, "btn_strengthen")
	self.btn_equip = getConvertChildByName(self.panel, "btn_equip")

	local partner_data = getGameData():getPartnerData()
	local ship_data = getGameData():getShipData()
	local boat = ship_data:getBoatDataByKey(self.equip_boat_key)
	if not boat then
		self:close()
		return
	end
	local skin_data = self:getSkinData()
	local select_boat_type = boat.id
	local item_res = boat_info[select_boat_type].res
	local boat_name = boat.name
	local ship_3d_id = select_boat_type
	if skin_data then
		boat_name = skin_data.skin_name
		item_res = skin_data.skin_res
		ship_3d_id = skin_data.skin_id

	end
	self.ship_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)

	local boat_config = boat_attr[select_boat_type]
	local fi_type_icon = ClsDataTools:getBoatFiTypeRes(boat_config.fi_type)
	self.ship_type_icon:changeTexture(fi_type_icon, UI_TEX_TYPE_PLIST)

	local nobility_config = nobility_data[boat_config.nobility_id]

	if nobility_config then
		self.level_info:setText(nobility_config.title)
		setUILabelColor(self.level_info, ccc3(dexToColor3B(nobility_config.level_color)))
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
	
	self.ship_name:setText(boat_name)
	setUILabelColor(self.ship_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[boat.quality])))
	self.ship_name_add:setText("+" .. self.select_bag_equip.boatLevel)
	setUILabelColor(self.ship_name_add,QUALITY_COLOR_STROKE[math.floor(self.select_bag_equip.boatLevel/10)+1])
	self.power_num:setText(self.select_bag_equip.boatPower)

	self:showShip(ship_3d_id)

	local rect = CCRect(415, 27, 350, 277)
	local list_cell_size = CCSizeMake(rect.size.width, rect.size.height)

	local cell_list = {}
	local width = 350
	local height = 280
	-- local list_cell_size = CCSize(width, height / (row - 0.2))

	self.list_view = ClsScrollView.new(width, height, true, nil, {is_fit_bottom = true})
    self.list_view:setPosition(ccp(415, 27))
    self:addWidget(self.list_view)

	local baowu_list = self.select_bag_equip.boatBaowu
	local attr_info_item = ClsBoatEquipAttrInfo.new(CCSize(rect.size.width, 205), {boat = boat, attr = boat_config, boat_level = self.select_bag_equip.boatLevel})
	cell_list[#cell_list + 1] = attr_info_item
	-- print("==========================================boat")
	-- table.print(boat)

	local baowu_num = 0
	for i,v in ipairs(baowu_list) do
		if v and v > 0 then
			local baowu_info_item = ClsBoatEquipBaowuInfo.new(CCSize(rect.size.width, 85), v)
			baowu_num = baowu_num + 1
			cell_list[#cell_list + 1] = baowu_info_item
		end
	end
	self.list_view:addCells(cell_list)

	attr_info_item:updateBaowuNum(baowu_num)

	self.btn_discharge:setPressedActionEnabled(true)
	self.btn_discharge:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:isExploreAlert(function()
			self:setViewEnabled()
			partner_data:askDownloadBoat(self.select_index)
			self:close()
		end, true)
    end,TOUCH_EVENT_ENDED)

	self.btn_strengthen:setPressedActionEnabled(true)
	self.btn_strengthen:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:isExploreAlert(function()
			self:close()
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			if tolua.isnull(shipyard_ui) then 
				getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_STRENGTHEN, self.select_index)
			end
		end)
    end,TOUCH_EVENT_ENDED)

	self.btn_equip:setPressedActionEnabled(true)
	self.btn_equip:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:isExploreAlert(function()
			self:close()
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			if tolua.isnull(shipyard_ui) then 
				getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_EQUIP, self.select_index)
			end
		end)
    end,TOUCH_EVENT_ENDED)

    local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.SHIPYARD_QHPAGE.value, {openBtn = self.btn_strengthen, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBoatAttrTips"})	
	onOffData:pushOpenBtn(on_off_info.SHOPTREASURE_SET.value, {openBtn = self.btn_equip, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBoatAttrTips"})
end

--显示背包船的tips
function ClsBoatAttrTips:showBackpackBoatTips(name_str, params)
	if tolua.isnull(self.ui_layer) then
		self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_ship_info.json")
		convertUIType(self.panel)
		self:addWidget(self.panel)

		ClsBoatAttrTips.super.onEnter(self, name_str, params, self.panel, true)

		self.ship_icon_right = getConvertChildByName(self.panel, "ship_icon_r")
		self.ship_type_icon_right = getConvertChildByName(self.panel, "ship_type_icon_r")
		self.ship_name_right = getConvertChildByName(self.panel, "ship_name_r")
		self.level_info_right = getConvertChildByName(self.panel, "level_info_r")
		self.job_info_right = getConvertChildByName(self.panel, "job_info_r")
		self.power_num_right = getConvertChildByName(self.panel, "power_num_r")
		self.power_arrow_right = getConvertChildByName(self.panel, "power_arrow_r")

		--右边改造属性控件
		for i = 1, random_attr_num do
			local item_name = string.format("wash_attr_right_%d", i)
			self[item_name] = getConvertChildByName(self.panel, string.format("wash_attribute_text_%s_2", i))
		end

		self.btn_wash_attr = getConvertChildByName(self.panel, "btn_wash_attribute")
		self.btn_dismantling = getConvertChildByName(self.panel, "btn_dismantling")
		self.btn_fighting = getConvertChildByName(self.panel, "btn_fighting")

		ClsGuideMgr:tryGuide("ClsBoatAttrTips")		
	end

	for i = 1, random_attr_num do
		local item_name = string.format("wash_attr_right_%d", i)
		self[item_name]:setVisible(false)
	end

	-- print("==========================================self.boat_data")
	-- table.print(self.boat_data)

	local backpack_data = self.boat_data
	if not self.boat_data then
		self:close()
		return
	end
	local item_res = boat_info[backpack_data.id].res
	self.ship_icon_right:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)

	local boat_config = boat_attr[backpack_data.id]
	local fi_type_icon = ClsDataTools:getBoatFiTypeRes(boat_config.fi_type)
	self.ship_type_icon_right:changeTexture(fi_type_icon, UI_TEX_TYPE_PLIST)

	local player_data = getGameData():getPlayerData()
	local occup_attr = ""
	local occup_has_sample = false
	local cur_profession = player_data:getProfession()
	local nobility_config = nobility_data[boat_config.nobility_id]
	local cur_level = getGameData():getNobilityData():getCurrentNobilityData().level

	local is_nobility_better = false
	if nobility_config then
		self.level_info_right:setText(nobility_config.title)
		if cur_level < nobility_config.level then
			setUILabelColor(self.level_info_right, ccc3(dexToColor3B(COLOR_RED)))
		else
			setUILabelColor(self.level_info_right, ccc3(dexToColor3B(nobility_config.level_color)))
		end
		is_nobility_better = cur_level <= nobility_config.level
	else
		self.level_info_right:setText(ui_word.BACKPACK_BOAT_NOBILITY_STR)
	end

	if self.equip_sailor_id ~= -1 then
		cur_profession = sailor_info[self.equip_sailor_id].job[1]
	end

	for i,v in ipairs(boat_config.occup) do
		if string.len(occup_attr) > 0 then
			occup_attr = occup_attr .. ui_word.SIGN_DUANHAO
		end
		occup_attr = occup_attr .. ROLE_OCCUP_NAME[v]
		if not occup_has_sample and cur_profession == v then
			occup_has_sample = true
		end
	end	
	self.job_info_right:setText(occup_attr)
	if not occup_has_sample then
		setUILabelColor(self.job_info_right, ccc3(dexToColor3B(COLOR_RED)))
	else
		setUILabelColor(self.job_info_right, ccc3(dexToColor3B(COLOR_WHITE)))
	end

	self.ship_name_right:setText(backpack_data.name)
	setUILabelColor(self.ship_name_right, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[backpack_data.quality])))
	self.power_num_right:setText(backpack_data.power)

	self.right_base_attr = {}
	for i, v in ipairs(backpack_data.base_attrs) do
		local attr_info = {}
		attr_info.attr = getConvertChildByName(self.panel, v.attr .. "_txt_r")
		attr_info.num = getConvertChildByName(self.panel, v.attr .. "_num_r")
		attr_info.arrow = getConvertChildByName(self.panel, v.attr .. "_arrow")
		self.right_base_attr[v.attr] = attr_info

		attr_info.attr:setText(base_attr_info[v.attr].name)
		attr_info.num:setText(v.value)
		attr_info.arrow:setVisible(false)
		attr_info.value = v.value
	end

	local normal_attr = {}
    local skill_attr = {}

    for k, v in ipairs(backpack_data.rand_attrs) do
        if v.attr == "boatSkill" then
            table.insert(skill_attr, v)
        else
            table.insert(normal_attr, v)
        end
    end

    local cur_line = 0
    for k, v in ipairs(normal_attr) do
        cur_line = math.ceil(k / 2)
        local item_name = string.format("wash_attr_right_%d", k)
        local item = self[item_name]
        item:setVisible(true)
        local show_txt = string.format("%s  +%s", base_attr_info[v.attr].name, v.value)
        item:setText(show_txt)
        setUILabelColor(item, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
    end

    for k, v in ipairs(skill_attr) do
        cur_line = cur_line + 1
        local item_name = string.format("wash_attr_right_%d", 2 * cur_line - 1)
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

	local dismantling_info = self:getDismantlingReward(boat_config.level, backpack_data.quality)
	self.equip_icon_list = {}
	for i = 1, 3 do
		local bg = getConvertChildByName(self.panel, "equip_bg_" .. i)
		local icon = getConvertChildByName(self.panel, "equip_icon_" .. i)
		local num = getConvertChildByName(self.panel, "equip_num_" .. i)
		self.equip_icon_list[i] = {bg = bg, icon = icon, num = num}

		local reward_info = dismantling_info[i]
		local color = 0
		if reward_info then
			local item_res, amount, scale, _, _, _, color_num = getCommonRewardIcon(reward_info)
			icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
			num:setText(amount)
			color = color_num
		else
			icon:setVisible(false)
			num:setText("")
		end
		local equip_bg_res = string.format("item_box_%s.png", color)
		bg:changeTexture(equip_bg_res, UI_TEX_TYPE_PLIST)
	end

	-- 左侧信息显示问题
	if self.equip_boat_key and self.equip_boat_key > 0 then--显示对比状态
		if not self.ship_icon_left then 
			self.ship_icon_left = getConvertChildByName(self.panel, "ship_icon_l")
			self.ship_type_icon_left = getConvertChildByName(self.panel, "ship_type_icon_l")
			self.ship_name_left = getConvertChildByName(self.panel, "ship_name_l")
			self.level_info_left = getConvertChildByName(self.panel, "level_info_l")
			self.job_info_left = getConvertChildByName(self.panel, "job_info_l")
			self.power_num_left = getConvertChildByName(self.panel, "power_num_l")

			--左边改造属性控件
			for i = 1, random_attr_num do
				local item_name = string.format("wash_attr_left_%d", i)
				self[item_name] = getConvertChildByName(self.panel, string.format("wash_attribute_text_%s_1", i))
				self[item_name]:setVisible(false)
			end
		end

		for i = 1, random_attr_num do
			local item_name = string.format("wash_attr_left_%d",i)
			self[item_name]:setVisible(false)
		end

		local ship_data = getGameData():getShipData()
		local boat_equip = ship_data:getBoatDataByKey(self.equip_boat_key)
		local select_boat_type = boat_equip.id
		local item_res = boat_info[select_boat_type].res
		local boat_name = boat_equip.name
		local skin_data = self:getSkinData()
	    if skin_data then
	    	boat_name = skin_data.skin_name
	    	item_res = skin_data.skin_res
	    end
		self.ship_icon_left:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)

		-- print("==========================================boat_equip")
		-- table.print(boat_equip)

		local boat_config_left = boat_attr[select_boat_type]
		local fi_type_icon = ClsDataTools:getBoatFiTypeRes(boat_config_left.fi_type)
		self.ship_type_icon_left:changeTexture(fi_type_icon, UI_TEX_TYPE_PLIST)

		local nobility_config = nobility_data[boat_config_left.nobility_id]

		if nobility_config then
			self.level_info_left:setText(nobility_config.title)
			setUILabelColor(self.level_info_left, ccc3(dexToColor3B(nobility_config.level_color)))
		else
			self.level_info_left:setText("")
		end

		local occup_attr = ""
		for i,v in ipairs(boat_config_left.occup) do
			if string.len(occup_attr) > 0 then
				occup_attr = occup_attr .. ui_word.SIGN_DUANHAO
			end
			occup_attr = occup_attr .. ROLE_OCCUP_NAME[v]
		end
		self.job_info_left:setText(occup_attr)
		self.ship_name_left:setText(boat_name)
		setUILabelColor(self.ship_name_left, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[boat_equip.quality])))
		self.power_num_left:setText(boat_equip.power)

		local function changeCompareTag(target, cur_value, equip_value)
			local down_campare_res = "common_arrow_down.png"
			local up_campare_res = "common_arrow_up.png"
			if cur_value ~= equip_value then
				target:setVisible(true)
				if cur_value < equip_value then
					target:changeTexture(down_campare_res, UI_TEX_TYPE_PLIST)
				else
					target:changeTexture(up_campare_res, UI_TEX_TYPE_PLIST)
				end
			else
				target:setVisible(false)
			end
		end

		self.left_base_attr = {}
		for i,v in ipairs(boat_equip.base_attrs) do
			local attr_info_left = {}
			attr_info_left.attr = getConvertChildByName(self.panel, v.attr .. "_txt_l")
			attr_info_left.num = getConvertChildByName(self.panel, v.attr .. "_num_l")
			self.left_base_attr[v.attr] = attr_info_left

			attr_info_left.attr:setText(base_attr_info[v.attr].name)
			attr_info_left.num:setText(v.value)

			local right_base_attr_info = self.right_base_attr[v.attr]
			changeCompareTag(right_base_attr_info.arrow, right_base_attr_info.value, v.value)	
		end

		local normal_attr = {}
	    local skill_attr = {}

	    for k, v in ipairs(boat_equip.rand_attrs) do
	        if v.attr == "boatSkill" then
	            table.insert(skill_attr, v)
	        else
	            table.insert(normal_attr, v)
	        end
	    end
	
		local cur_line = 0
	    for k, v in ipairs(normal_attr) do
	        cur_line = math.ceil(k / 2)
	        local item_name = string.format("wash_attr_left_%d", k)
	        local item = self[item_name]
	        item:setVisible(true)
	        local show_txt = string.format("%s  +%s", base_attr_info[v.attr].name, v.value)
	        item:setText(show_txt)
	        setUILabelColor(item, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[v.quality])))
	    end

	    for k, v in ipairs(skill_attr) do
	        cur_line = cur_line + 1
	        local item_name = string.format("wash_attr_left_%d", 2 * cur_line - 1)
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

		changeCompareTag(self.power_arrow_right, backpack_data.power, boat_equip.power)	
	else
		self.bg_left = getConvertChildByName(self.panel, "bg_l")
		self.bg_left:setVisible(false)
		self.power_arrow_right:setVisible(false)
		self.btn_wash_attr:setVisible(false)
		self.btn_wash_attr:setTouchEnabled(false)
		
		self:showShip(backpack_data.id)
	end

	self.btn_wash_attr:setPressedActionEnabled(true)
	self.btn_wash_attr:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:isExploreAlert(function()
			self:close()
			getUIManager():create("gameobj/shipyard/clsShipyardMainUI", nil, TAB_REFINE, {backpack_key = backpack_data.guid, select_index = self.select_index})
		end)
    end,TOUCH_EVENT_ENDED)

	self.btn_dismantling:setPressedActionEnabled(true)
	self.btn_dismantling:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:close()
		if is_nobility_better and backpack_data.quality >= NEED_ALERT_QUALITY then
			getUIManager():create("gameobj/backpack/clsBackpackDismantlyUI", nil, backpack_data.guid, dismantling_info, BAG_PROP_TYPE_FLEET)
		else
			local ship_data = getGameData():getShipData()
			ship_data:askBoatSplit(backpack_data.guid)
		end
    end,TOUCH_EVENT_ENDED)

	self.btn_fighting:setPressedActionEnabled(true)
	self.btn_fighting:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:isExploreAlert(function()
			local partner_data = getGameData():getPartnerData()
			partner_data:askUploadBoat(self.select_index, backpack_data.guid)
			self:close()
		end, true)
    end,TOUCH_EVENT_ENDED)

    missionGuide:pushGuideBtn(on_off_info.DISMANTLE.value,
	 {rect = CCRect(835, 95, 100, 40), guideLayer = self})

	local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.DISMANTLE.value, {openBtn = self.btn_dismantling, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBoatAttrTips"})
	onOffData:pushOpenBtn(on_off_info.BACKPACK_BOATWASH.value, {openBtn = self.btn_wash_attr, openEnable = true, btn_scale = 0.7, 
		addLock = true, btnRes = "#common_btn_blue1.png", parent = "ClsBoatAttrTips"})	
end

function ClsBoatAttrTips:getDismantlingReward(boat_level, boat_quality)
	local reward_data = {}
	for k,v in pairs(boat_fleet_config) do
		if v.level == boat_level then
			local rewards = v["quality_" .. boat_quality]
			for k,v in pairs(rewards) do
				reward_data[#reward_data + 1] = {key = ITEM_INDEX_PROP, value = v, id = k}
			end
			return reward_data
		end
	end
	return reward_data
end

function ClsBoatAttrTips:showShip(boat_id)
	local boat_info_item = ClsDataTools:getBoat(boat_id)
	if not self.ship3d_info.is_init then
		self.ship3d_info.is_init = true
		self.ship3d_info.layer_id = 1
		self.ship3d_info.scene_id = SCENE_ID.BOAT_TIP

		self.ship3d_info.parent_2d_spr = CCNode:create()
		self:addChild(self.ship3d_info.parent_2d_spr, -1)

		Main3d:createScene(self.ship3d_info.scene_id)

		-- layer
		Game3d:createLayer(self.ship3d_info.scene_id, self.ship3d_info.layer_id, self.ship3d_info.parent_2d_spr)
		self.ship3d_info.layer3d = Game3d:getLayer3d(self.ship3d_info.scene_id, self.ship3d_info.layer_id)
		self.ship3d_info.layer3d:setTranslation(CameraFollow:cocosToGameplayWorld(ccp(-295, -64)))
	else
		self.ship3d_info.layer3d:removeAllChildren()
	end

	local path = SHIP_3D_PATH
	local node_name = string.format("boat%.2d", boat_info_item.res_3d_id)
	local Sprite3D = require("gameobj/sprite3d")
	local player_data = getGameData():getPlayerData()
	local star_level = nil
	if not self.from_fleet_ui then
		star_level = player_data:getShipEffects()
	end
	local item = {
		id = boat_id,
		key = boat_key,
		path = path,
		is_ship = true,
		node_name = node_name,
		ani_name = node_name,
		parent = self.ship3d_info.layer3d,
		pos = {x = 0, y = 0, angle = 90},
		star_level = star_level,
	}
	local ship_3d = Sprite3D.new(item)
	ship_3d.node:scale(2)
end

function ClsBoatAttrTips:isExploreAlert(fun, is_backpack_pass)
	if isExplore  then
		if self.from_fleet_ui and is_backpack_pass then
			fun()
			return
		end
		if ClsSceneManage:doLogic("checkAlert") then return end
		local port_info = require("game_config/port/port_info")
		local Alert = require("ui/tools/alert")
		local portData = getGameData():getPortData()
		local portName = port_info[portData:getPortId()].name
		local tips = require("game_config/tips")
		local str = string.format(tips[77].msg, portName)
		Alert:showAttention(str, function()
				self:close()
				if getGameData():getTeamData():isLock() then
					Alert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
					return
				end
				---回港
				portData:setEnterPortCallBack(function() 
					getUIManager():create("gameobj/backpack/clsBackpackMainUI")
				end)
				portData:askBackEnterPort()

		end, nil, nil, {hide_cancel_btn = true})	
	else
		fun()
	end
end

function ClsBoatAttrTips:onExit()
	missionGuide:enableAllGuide()
	if self.ship3d_info.is_init then
		Main3d:removeScene(self.ship3d_info.scene_id)
		self.ship3d_info = {}
	end
end

return ClsBoatAttrTips
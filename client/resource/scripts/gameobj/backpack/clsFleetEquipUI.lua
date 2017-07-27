-- 船只装备界面
-- Author: chenlurong
-- Date: 2016-06-27 20:33:02
--

local music_info = require("scripts/game_config/music_info")
local baozang_info = require("game_config/collect/baozang_info")
local boat_info = require("game_config/boat/boat_info")
local base_attr_info = require("game_config/base_attr_info")
local ui_word = require("scripts/game_config/ui_word")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local boat_attr = require("game_config/boat/boat_attr")
local composite_effect = require("gameobj/composite_effect")
local ClsShipyardShipItem = require("gameobj/shipyard/clsShipyardShipItem")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local Alert = require("ui/tools/alert")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local dataTools = require("module/dataHandle/dataTools")

local ClsShipyardShipItem = require("gameobj/shipyard/clsShipyardShipItem")
--------------------------------------------船元件--------------------------------
local ClsFleetShipItem = class("ClsFleetShipItem", ClsShipyardShipItem)

function ClsFleetShipItem:mkUi()
	ClsFleetShipItem.super.mkUi(self)
	local task_data = getGameData():getTaskData()
	local task_keys = {
		on_off_info.SHIPYARD_EQUIP_BOX1.value,
		on_off_info.SHIPYARD_EQUIP_BOX2.value,
		on_off_info.SHIPYARD_EQUIP_BOX3.value,
		on_off_info.SHIPYARD_EQUIP_BOX4.value,
		on_off_info.SHIPYARD_EQUIP_BOX5.value,
	}
	task_data:regTask(self, {task_keys[self.partner_index]}, KIND_CIRCLE, task_keys[self.partner_index], 132, 89, true)
end

---------------------------------------------------------------------------
local ClsFleetUnlockAttrItem = class("ClsFleetUnlockAttrItem", require("ui/view/clsScrollViewItem"))

function ClsFleetUnlockAttrItem:initUI(cell_data)
	self.index = cell_data.index
	self.data = cell_data.data

	self.ui_layer = UIWidget:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_equip_unlock.json")
	convertUIType(self.panel)
	self.ui_layer:addChild(self.panel)
	self:addChild(self.ui_layer)

	self.line = getConvertChildByName(self.panel, "line")
	self.level_txt = getConvertChildByName(self.panel, "level_txt")
	self.unlock_txt = getConvertChildByName(self.panel, "unlock_txt")
	self.line:setVisible(self.index ~= 1)
	self.level_txt:setText(string.format(ui_word.BACKPACK_EQUIP_UNLOCK_LEVEL_STR, self.data.lv))
	self.unlock_txt:setText(self.data.describe)

	local size = self.unlock_txt:getContentSize()

	if cell_data.label_add > 0 then 
		self.unlock_txt:setTextAreaSize(CCSize(size.width, size.height + cell_data.label_add))
		self.ui_layer:setPosition(ccp(0, cell_data.label_add))
	end

	self:updateLevelState(tonumber(self.total_lv))
end

function ClsFleetUnlockAttrItem:updateLevelState(total_lv, unlock_effect_index)
	if not self.unlock_txt then
		self.total_lv = total_lv
		self.unlock_effect_index = unlock_effect_index
		return
	end
	if self.data and self.data.lv <= total_lv then
		setUILabelColor(self.unlock_txt, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))
	else
		setUILabelColor(self.unlock_txt, ccc3(dexToColor3B(COLOR_CAMEL)))
	end
	if unlock_effect_index and unlock_effect_index == self.index then
		if not tolua.isnull(self.equip_unlock_effect) then
			self.equip_unlock_effect:removeFromParentAndCleanup(true)
			self.equip_unlock_effect = nil
		end
		self.equip_unlock_effect = composite_effect.new("tx_ship_equip_unlock", 130, 40, self.ui_layer, -1, nil, nil, nil, true)
	end
end

-----------------------------------装备界面----------------------------------------
local ClsFleetEquipUI = class("ClsFleetEquipUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsFleetEquipUI:getViewConfig()
	return {
		name = "ClsFleetEquipUI",       --(选填）默认 class的名字
		type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
		is_swallow = false,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
		-- effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
	}
end

--select_index字段，这里的索引从主句开始1-5
function ClsFleetEquipUI:onEnter(select_index)
	self.plist_tab = {
		["ui/baowu.plist"] = 1,
		["ui/ship_icon.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}
	LoadPlist(self.plist_tab)
	self.touch_enabled = true

	self.select_index = select_index
	self.last_equip_unlock_lv = 0

	self:initUI()
	self:initEvent()
	self:updateEquipUnlockAttrList()
	self:updateShipList()
end

function ClsFleetEquipUI:initUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_equip.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self.equip_list = {}
	for i = 1, 3 do
		self.equip_list[i] = {}
		self.equip_list[i].icon = getConvertChildByName(self.panel, "equip_icon_" .. i)
		self.equip_list[i].bg = getConvertChildByName(self.panel, "equip_bg_" .. i)
		self.equip_list[i].icon_bg = getConvertChildByName(self.panel, "equip_icon_bg_" .. i)
		self.equip_list[i].name = getConvertChildByName(self.panel, "equip_name_" .. i)
		self.equip_list[i].attr = getConvertChildByName(self.panel, "equip_info_text_" .. i)
		self.equip_list[i].attr2 = getConvertChildByName(self.panel, "equip_info_text_" .. i.."_0")
		self.equip_list[i].effect_node = getConvertChildByName(self.panel, "arrow_effect_" .. i)
		self.equip_list[i].equip_add = getConvertChildByName(self.panel, "equip_add_" .. i)
		self.equip_list[i].equip_level = getConvertChildByName(self.panel, "equip_level_" .. i)
	end

	self.ship_name = getConvertChildByName(self.panel, "ship_name")
	self.ship_name:setText("")
	
	self.tips_txt = getConvertChildByName(self.panel, "tips_txt")
	self.tips_amount = getConvertChildByName(self.panel, "tips_amount")
	self.tips_amount:setText("")
	self.tips_txt:setVisible(false)

	self.btn_close = getConvertChildByName(self.panel, "btn_close")

	self.btn_fast = getConvertChildByName(self.panel, "btn_fast")

	ClsGuideMgr:tryGuide("ClsFleetEquipUI")
end

function ClsFleetEquipUI:showEquipBackpackList(site)
	local info = {
		site = site,
		id = self.select_boat_item.data.id,
		partner_index = self.select_boat_item.partner_index
	}
	local bag_data = getGameData():getBagDataHandler()
	local equip_list = bag_data:getCanEquipData(info.id, info.site, info.partner_index)
	local partner_data = getGameData():getPartnerData()
	local bag_equip_data = partner_data:getBagEquipInfoById(info.id)
	local boat_equip_data = bag_equip_data.boatBaowu

	if boat_equip_data[site] and boat_equip_data[site] > 0 then
		info.equip_list = equip_list
		getUIManager():create("gameobj/backpack/clsShipEquipTips", nil, info)
	elseif not equip_list or # equip_list < 1 then
		Alert:showJumpWindow(SHIP_EQUIP_NOT_ENOUGH)
	else
		info.equip_list = equip_list
		getUIManager():create("gameobj/backpack/clsShipEquipTips", nil, info)
	end
end

function ClsFleetEquipUI:initEvent()
	for i, v in ipairs(self.equip_list) do
		v.icon:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:showEquipBackpackList(i)
		end,TOUCH_EVENT_ENDED)
		v.equip_add:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:showEquipBackpackList(i)
		end,TOUCH_EVENT_ENDED)

		v.effect_node:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local tips_data = v.tips_data
			local alert_text = string.format(ui_word.BAOWU_BOAT_COMPOSE_EQUIP_TIPS, tips_data.amount, tips_data.name)
			local get_str = string.format("%s %s", tips_data.compose_name, tips_data.compose_num)
			Alert:showCostDetailTips(alert_text, nil, tips_data.compose_type, tips_data.compose_id, get_str, nil, function()
				self:setTouch(false)
				local baowu_data = getGameData():getBaowuData()
				baowu_data:askBoatEquipCompose(self.select_boat_item.partner_index, v.baowu_equip_key, i)
			end)
		end,TOUCH_EVENT_ENDED)
	end
	
	self.btn_fast:setPressedActionEnabled(true)
	self.btn_fast.last_time = 0
	self.btn_fast:addEventListener(function()
		if CCTime:getmillistimeofCocos2d() - self.btn_fast.last_time < 500 then return end
		self.btn_fast.last_time = CCTime:getmillistimeofCocos2d()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local partner_data = getGameData():getPartnerData()
		partner_data:oneKeySetBaowu(self.select_boat_item.partner_index)
	end, TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self.btn_close:setTouchEnabled(false)
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		local shipyard_main_ui = getUIManager():get("ClsShipyardMainUI")
		if not tolua.isnull(shipyard_main_ui) then
			shipyard_main_ui:closeView()
		end

		local backpack_ui = getUIManager():get("ClsBackpackMainUI")
		if not tolua.isnull(backpack_ui) then
			backpack_ui:refreshBackpackInfo()
		end

	end,TOUCH_EVENT_ENDED)
end

function ClsFleetEquipUI:updateShipList()
	local partner_data = getGameData():getPartnerData()
	local partner_ids = partner_data:getBagEquipIds()

	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	local function onListCellTap(x, y, cell)
		if not cell.data then
			return
		end
		if self.select_boat_item then
			if self.select_boat_item.partner_index == cell.partner_index then
				return
			end
			self.select_boat_item:setSelectStatus(false)
		end
		if x then
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
		end

		cell:setSelectStatus(true)
		self.select_boat_item = cell
		self.select_boat_key = self.select_boat_item.data.boatKey
		self.ship_name:setText(cell.ship_name:getStringValue())

		self:setBoatEquipList()
		self:showBoatEquipInfo()
	end

	local width = 745
	local height = 98
	local list_cell_size = CCSize(152, 98)

	self.list_view = ClsScrollView.new(width, height, false, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(172, 372))
	self:addWidget(self.list_view)

	self.boat_item_list = {}
	self.select_boat_item =nil

	local select_cell = nil
	local select_index = 1
	for i,sailor_id in ipairs(partner_ids) do
		local boat_item = ClsFleetShipItem.new(list_cell_size, {index = i, sailor_id = sailor_id, call_back = function(x, y, cell)
				onListCellTap(x, y, cell)
			end})
		self.boat_item_list[#self.boat_item_list + 1] = boat_item
	end
	self.list_view:addCells(self.boat_item_list)

	self.select_index = self.select_index or 1
	select_cell = self.boat_item_list[self.select_index]
	onListCellTap(nil, nil, select_cell)
end

function ClsFleetEquipUI:updateEquipUnlockAttrList()
	if not tolua.isnull(self.unlock_list_view) then
		self.unlock_list_view:removeFromParentAndCleanup(true)
		self.unlock_list_view = nil
	end

	local width = 260
	local height = 244
	local list_cell_size = CCSize(width, 65)

	self.unlock_list_view = ClsScrollView.new(width, height, true, nil, {is_fit_bottom = true})
	self.unlock_list_view:setPosition(ccp(176, 69))
	self:addWidget(self.unlock_list_view)

	self.equip_unlock_list = {}

	local default_height = 67
	local equip_unlock_attr = require("game_config/collect/equip_unlock_attr")
	local player_data = getGameData():getPlayerData()
	local cur_profession = player_data:getProfession()
	local index = 0
	for i,v in ipairs(equip_unlock_attr) do
		for j,occup_num in ipairs(v.occup) do
			if occup_num == cur_profession then
				index = index + 1
				local label = createBMFont({text = v.describe, anchor=ccp(0,0), fontFile = FONT_COMMON, size = 16, align=ui.TEXT_ALIGN_LEFT, width = 220, color = ccc3(dexToColor3B(COLOR_BROWN)), x=5, y=0})
				local rect = label:getContentSize()
				local dis_height = (math.max(rect.height, 30) - 30)
				local list_h = default_height + dis_height
				local equip_unlock_item = ClsFleetUnlockAttrItem.new( CCSize(width, list_h), {index = index, data = v, label_add = dis_height})
				self.equip_unlock_list[#self.equip_unlock_list + 1] = equip_unlock_item
			end
		end
	end
	self.unlock_list_view:addCells(self.equip_unlock_list)
end

function ClsFleetEquipUI:updateEquipUnlockAttrLv(total_lv, is_op)
	local tips_amount_str = string.format(ui_word.STR_LV, total_lv)
	if total_lv == 0 then
		tips_amount_str = ""
	end
	local effect_index = nil
	local unlock_effect_index = nil
	local equip_unlock_attr = require("game_config/collect/equip_unlock_attr")
	local player_data = getGameData():getPlayerData()
	local cur_profession = player_data:getProfession()
	local index = 0
	for i,v in ipairs(equip_unlock_attr) do
		for j,occup_num in ipairs(v.occup) do
			if occup_num == cur_profession then
				index = index + 1
				if v.lv <= total_lv then
					effect_index = index
				end
			end
		end
	end
	if is_op and total_lv > self.last_equip_unlock_lv then
		unlock_effect_index = effect_index
	end
	effect_index = effect_index or 1
	self.unlock_list_view:scrollToCellIndex(effect_index)
	self.tips_amount:setText(tips_amount_str)
	self.tips_txt:setVisible(total_lv > 0)
	if self.equip_unlock_list then
		for i,v in ipairs(self.equip_unlock_list) do
			v:updateLevelState(total_lv, unlock_effect_index)
		end
	end
	self.last_equip_unlock_lv = total_lv
end

function ClsFleetEquipUI:showBoatEquipInfo(is_op)
	local partner_data = getGameData():getPartnerData()
	local bag_equip_data = partner_data:getBagEquipInfoById(self.select_boat_item.data.id)
	local boat_equip_data = bag_equip_data.boatBaowu

	local ship_data = getGameData():getShipData()
	local boat = ship_data:getBoatDataByKey(self.select_boat_key)
	local baowu_lot = boat_attr[boat.id].baowuslot
	if baowu_lot == 0 then
		self.btn_fast:disable()
	else
		self.btn_fast:active()
	end

	-- print("============================showBoatEquipInfo==boat_equip_data")
	-- table.print(boat_equip_data)
	local total_equip_unlock_lv = 0
	local player_data = getGameData():getPlayerData()
	local cur_level = player_data:getLevel()

	local baowu_data_handler = getGameData():getBaowuData()
	for i,v in ipairs(self.equip_list) do
		local quality = 0
		v.bg:setVisible(i <= baowu_lot)
		local compose_baowu = 0
		local compose_amount = 0
		local baozang_config

		v.attr:setText("")
		v.attr2:setText("")
		if boat_equip_data[i] and boat_equip_data[i] > 0 then
			local baowu_equip_key = boat_equip_data[i]
			local baowu_info = baowu_data_handler:getInfoById(baowu_equip_key)
			if not baowu_info then
				v.equip_add:setVisible(true)
				v.equip_add:setTouchEnabled(i <= baowu_lot)
				v.baowu_equip_key = nil
				v.name:setText("")
				v.equip_level:setText("")
				v.icon:setVisible(false)
				v.icon:setTouchEnabled(false)
			end
			baozang_config = baozang_info[baowu_info.baowuId]
			v.icon:changeTexture(convertResources(baozang_config.res) , UI_TEX_TYPE_PLIST)
			v.name:setText(baozang_config.name)
			quality = baowu_info.step
			setUILabelColor(v.name, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
			v.equip_level:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, baozang_config.level))
			setUILabelColor(v.equip_level, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
			total_equip_unlock_lv = total_equip_unlock_lv + baozang_config.level

			local attr_info = baowu_info.attr[1]
			if attr_info then
				local str = dataTools:getBoatBaowuAttr(attr_info.name, attr_info.value)
				v.attr:setText(base_attr_info[attr_info.name].name .. str)
			end
			local attr_info2 = baowu_info.attr[2]
			if attr_info2 then
				local str = dataTools:getBoatBaowuAttr(attr_info2.name, attr_info2.value)
				v.attr2:setText(base_attr_info[attr_info2.name].name .. str)
			end
			local own_amount = baowu_info.amount - baowu_info.upload_amount + 1
			compose_amount= baozang_config.compose_amount
			if baozang_config.compose_level <= cur_level and own_amount >= compose_amount then
				compose_baowu = baozang_config.compose_baowu
			end

			v.icon:setVisible(true)
			v.icon:setTouchEnabled(true)
			v.baowu_equip_key = baowu_equip_key
			v.equip_add:setVisible(false)
			v.equip_add:setTouchEnabled(false)
		else
			v.equip_add:setVisible(true)
			v.equip_add:setTouchEnabled(i <= baowu_lot)
			v.baowu_equip_key = nil
			v.name:setText("")
			v.equip_level:setText("")
			v.icon:setVisible(false)
			v.icon:setTouchEnabled(false)
		end
		local item_bg_res = string.format("item_box_%s.png", quality )
		v.icon_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)

		local is_show_tips = false
		if compose_baowu > 0 then
			local compose_baowu_config = baozang_info[compose_baowu]
			if compose_baowu_config.limitLevel <= cur_level then
				if tolua.isnull(v.effect) then
					v.effect = composite_effect.new("tx_0157", 16, 12, v.effect_node, -1, nil, nil, nil, true)
					v.effect_node:setTouchEnabled(true)
					v.effect_node:setVisible(true)
				end
				v.tips_data = {
					amount = compose_amount,
					name = baozang_config.name,
					compose_num = 1,
					compose_name = compose_baowu_config.name,
					compose_id = compose_baowu,
					compose_type = ITEM_INDEX_BAOWU,
				}
				is_show_tips = true
			end
		end
		if not is_show_tips then
			self:clearEffectGaf(v)
		end
	end
	if not is_op then
		self.last_equip_unlock_lv = total_equip_unlock_lv
	end
	self:updateEquipUnlockAttrLv(total_equip_unlock_lv, is_op)
end

function ClsFleetEquipUI:clearEffectGaf(node)
	if not tolua.isnull(node.effect) then
		node.effect:removeFromParentAndCleanup(true)
		node.effect = nil
	end
	node.tips_data = nil
	node.effect_node:setTouchEnabled(false)
	node.effect_node:setVisible(false)
end

--装备宝物后刷新
function ClsFleetEquipUI:updateView(errno)
	if errno and errno == 0 then
		self:setBoatEquipList()
		self:showBoatEquipInfo(true)
	end
	self:setTouch(true)
end

function ClsFleetEquipUI:setBoatEquipList()
	local partner_data = getGameData():getPartnerData()
	self.boat_equip_data = partner_data:getBagEquipInfoById(self.select_boat_item.data.id).boatBaowu
end

function ClsFleetEquipUI:showEquipTips(item_key, x, y)
	getUIManager():create("gameobj/backpack/clsFleetEquipTips", nil, "ClsFleetEquipTips", {is_back_bg = false, is_swallow = false}, self.select_boat_item.partner_index, item_key, x, y)
end

function ClsFleetEquipUI:setTouch(enabled)
	self.touch_enabled = enabled
	if not tolua.isnull(self.list_view) then
		self.list_view:setTouch(enabled)
	end
	if not tolua.isnull(self.backpack_list_view) then
		self.backpack_list_view:setTouch(enabled)
	end
end

function ClsFleetEquipUI:getBtnClose()
	return self.btn_close
end

function ClsFleetEquipUI:onExit()
	missionGuide:enableAllGuide()
	UnLoadPlist(self.plist_tab)
	ReleaseTexture(self)
end

return ClsFleetEquipUI

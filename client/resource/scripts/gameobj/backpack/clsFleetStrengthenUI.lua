-- 船只强化界面
-- Author: xuya
-- Date: 2016-06-27 20:32:40

local music_info = require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local boat_strengthening = require("game_config/boat/boat_strengthening")
local item_info = require("game_config/propItem/item_info")
local Alert = require("ui/tools/alert")
local ClsScrollView = require("ui/view/clsScrollView")
local UiCommon = require("ui/tools/UiCommon")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local boat_attr = require("game_config/boat/boat_attr")
local ClsShipyardShipItem = require("gameobj/shipyard/clsShipyardShipItem")
local boat_breakthrough_xianshi = require("game_config/boat/boat_breakthrough_xianshi")

local CompositeEffect = require("gameobj/composite_effect")
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local Game3d = require("game3d")
local Main3d = require("gameobj/mainInit3d")

local BREAK_ATTR_NUM = 7
local ATTR_NUM = 4

local need_attr = {
	[ATTR_KEY_REMOTE] = "far_strengthening_num",
	[ATTR_KEY_MELEE] = "near_strengthening_num",
	[ATTR_KEY_DEFENSE] = "defense_strengthening_num",
	[ATTR_KEY_DURABLE] = "hpmax_strengthening_num",
}

local ClsFleetShipItem = class("ClsFleetShipItem", ClsShipyardShipItem)

function ClsFleetShipItem:mkUi()
	ClsFleetShipItem.super.mkUi(self)
	
	
	local task_data = getGameData():getTaskData()
    local task_keys = {
        on_off_info.ASSEMBLE_BOX1.value,
        on_off_info.ASSEMBLE_BOX2.value,
        on_off_info.ASSEMBLE_BOX3.value,
        on_off_info.ASSEMBLE_BOX4.value,
        on_off_info.ASSEMBLE_BOX5.value,

    }
    print("self.partner_index", self.partner_index)
    task_data:regTask(self, {task_keys[self.partner_index]}, KIND_CIRCLE, task_keys[self.partner_index], 132, 89, true)

end

-----------------------------------强化界面----------------------------------------
local ClsFleetStrengthenUI = class("ClsFleetStrengthenUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsFleetStrengthenUI:getViewConfig()
    return {
        name = "ClsFleetStrengthenUI",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        -- effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
    }
end
--select_index字段，这里的索引从主句开始1-5
function ClsFleetStrengthenUI:onEnter(select_index)
	self.plist_tab = {
		["ui/ship_icon.plist"] = 1,
		["ui/ship_skill.plist"] = 1,
	}

	LoadPlist(self.plist_tab)

	self.select_index = select_index

	self:initUI()
	self:initEvent()
	self:init3D()
	self:updateShipList()
end
local function showLabelAct(label,beginNum,endNum,str)
	if(not label or tolua.isnull(label))then return end
	label:setAnchorPoint(ccp(0.5,0.5))
    UiCommon:numberEffect(label,beginNum,endNum,nil,nil,str)
    local arr = CCArray:create()
    arr:addObject(CCScaleTo:create(.5,1.4))
    arr:addObject(CCScaleTo:create(.1,1.0))
    label:runAction(CCSequence:create(arr))
end
function ClsFleetStrengthenUI:initUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_strengthen.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

	local attr_info = {
		[1] = {_base = "far", kind = ATTR_KEY_REMOTE},
		[2] = {_base = "near", kind = ATTR_KEY_MELEE},
		[3] = {_base = "long", kind = ATTR_KEY_DURABLE},
		[4] = {_base = "defense", kind = ATTR_KEY_DEFENSE},
	}

	self.attr_info = getConvertChildByName(self.panel, "attr_info")

	self.left_panel = {}
	self.right_panel = {}

	function self.right_panel:setVisible(enabled)
		self.title:setVisible(enabled)
		for k, v in ipairs(self.attrs) do
			v:setVisible(enabled)
		end
	end

	self.left_attrs = {}
	self.right_attrs = {}

	self.left_panel.attrs = self.left_attrs
	self.right_panel.attrs = self.right_attrs

	for k, v in ipairs(attr_info) do
		--左边属性
		local attr_temp = {}
		local text, value, up = nil, nil, nil
		local text_name = string.format("%s_text", v._base)
		local value_name = string.format("%s_num", v._base)
		local up_name = string.format("%s_add", v._base)

		text = getConvertChildByName(self.attr_info, text_name)
		value = getConvertChildByName(self.attr_info, value_name)
		up = getConvertChildByName(self.attr_info, up_name)

		attr_temp.kind = v.kind
		attr_temp.text = text
		attr_temp.value = value
		attr_temp.up = up

		function attr_temp:setVisible(enabled)
			self.text:setVisible(enabled)
			self.value:setVisible(enabled)
			self.up:setVisible(enabled)
		end

		function attr_temp:setText(base_num, up_num,isMove)
			local tmp_num = tonumber(self.up:getStringValue())
			self.value:setText(base_num)
			self.up:setText(up_num)
			if(isMove)then
				showLabelAct(self.up,tmp_num,tonumber(up_num),"+")
			end
		end

		self.left_attrs[#self.left_attrs + 1] = attr_temp

		--右边属性
		attr_temp = {}
		text_name = string.format("%s_r", text_name)
		value_name = string.format("%s_r", value_name)
		up_name = string.format("%s_r", up_name)
		local up_icon_name = string.format("%s_arrow", v._base)

		text = getConvertChildByName(self.attr_info, text_name)
		value = getConvertChildByName(self.attr_info, value_name)
		up = getConvertChildByName(self.attr_info, up_name)

		attr_temp.kind = v.kind
		attr_temp.text = text
		attr_temp.value = value
		attr_temp.up = up
		attr_temp.up_icon = getConvertChildByName(self.attr_info, up_icon_name)

		function attr_temp:setVisible(enabled)
			self.text:setVisible(enabled)
			self.value:setVisible(enabled)
			self.up:setVisible(enabled)
			self.up_icon:setVisible(enabled)
		end

		function attr_temp:setText(base_num, up_num,isMove)
			local tmp_num = tonumber(self.up:getStringValue())
			self.value:setText(base_num)
			self.up:setText(up_num)
			if(isMove)then
				showLabelAct(self.up,tmp_num,tonumber(up_num),"+")
			end
		end

		self.right_attrs[#self.right_attrs + 1] = attr_temp
	end

	self.ship_name = getConvertChildByName(self.panel, "ship_name")
	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.ship_layer = getConvertChildByName(self.panel, "ship_layer")
	self.current_level_label = getConvertChildByName(self.panel, "boat_name")
	self.next_level_label = getConvertChildByName(self.panel, "boat_name_r")

	self.left_panel.title = self.current_level_label
	self.right_panel.title = self.next_level_label

	--下级解锁技能
	self.next_unlock_name = getConvertChildByName(self.panel, "next_unlock_name")
	self.next_unlock_text = getConvertChildByName(self.panel, "next_unlock_text")
	self.next_icon = getConvertChildByName(self.panel, "next_icon")
	self.break_attr = getConvertChildByName(self.panel, "break_attr")
	self.no_unlock_text = getConvertChildByName(self.panel, "no_unlock_text")
	self.next_msg_panel = getConvertChildByName(self.panel, "next_msg_panel")

	self.strengthen_panel = getConvertChildByName(self.panel, "strengthen_panel")
	self.strengthen_panel.widgets = {}
	local func = self.strengthen_panel.setVisible

	local function btnFunc(self, enabled)
		for k, v in pairs(self.widgets) do
			if v:getDescription() == "Button" then
				if enabled then
					v:active()
				else
					v:disable()
				end
			end
		end
	end

	function self.strengthen_panel:setVisible(enabled)
		func(self, enabled)
		btnFunc(self, enabled)
	end

	local strengthen_info = {
		[1] = {name = "btn_strengthen"},
		[2] = {name = "bar_num"},
		[3] = {name = "bar_add_num"},
		[4] = {name = "consume_icon"},
		[5] = {name = "consume_num"},
		[6] = {name = "cash_num"},
		[7] = {name = "bar"},
		[8] = {name = "hammer_bg"},
		
	}

	for k, v in ipairs(strengthen_info) do
		local item = getConvertChildByName(self.strengthen_panel, v.name)
		self.strengthen_panel.widgets[v.name] = item
	end

	self.strengthen_panel.widgets.bar_add_num:setVisible(false)

	self.break_panel = getConvertChildByName(self.panel, "break_panel")
	self.break_panel.widgets = {}

	func = self.break_panel.setVisible
	function self.break_panel:setVisible(enabled)  --为了功能改框架接口很不好，没改好反而弄出问题了，完全可以抽出一个方法来做
		func(self, enabled)
		btnFunc(self, enabled)  --这个只屏蔽cocos按钮控件，imageView控件没有屏蔽，但是代码里面有用imageView控件注册事件的方法
		                        --所以就出bug了，我这里暂时把错误改了，作者看到了可以把方法抽出来。
		self.widgets.crystal_bg:setTouchEnabled(enabled)
	end

	local break_info = {
		[1] = {name = "btn_break"},
		[2] = {name = "crystal_icon"},
		[3] = {name = "crystal_amount"},
		[4] = {name = "break_attr_name"},
		[5] = {name = "cash_num"},
		[6] = {name = "title_name"},
		[7] = {name = "title_remand"},
		[8] = {name = "crystal_bg"},
	}

	for k, v in ipairs(break_info) do
		local item = getConvertChildByName(self.break_panel, v.name)
		self.break_panel.widgets[v.name] = item
	end
	
	self.flow_tips = getConvertChildByName(self.panel, "flow_tips")
	ClsGuideMgr:tryGuide("ClsFleetStrengthenUI")
end

function ClsFleetStrengthenUI:init3D()
    local layer_id = 1
    local scene_id = SCENE_ID.PREVIEW
    Main3d:createScene(scene_id) 
    local parent = CCNode:create()
    self.ship_layer:addCCNode(parent)
    
    Game3d:createLayer(scene_id,layer_id, parent)
    self.layer3d = Game3d:getLayer3d(scene_id,layer_id)
end

function ClsFleetStrengthenUI:showStrengthenTip( ... )

	local tip_panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_strengthen_tips.json")
	tip_panel:setPosition(ccp(50,85))

	--突破属性赋值
	local partner_data = getGameData():getPartnerData()
	local partner_equip_data = partner_data:getBagEquipInfoById(self.select_boat_item.data.id)
	local boat_strengthen_level = partner_equip_data.boatLevel
	for k = 1, BREAK_ATTR_NUM do
		local info = boat_breakthrough_xianshi[k]
		local item = getConvertChildByName(tip_panel, "break_icon_bg_"..k)
		local icon = getConvertChildByName(item, "break_icon_"..k)
		local attr = getConvertChildByName(item, "break_text_"..k)
		local lock = getConvertChildByName(item, "break_lock_"..k)
		local lock_txt = getConvertChildByName(item, "break_unlock_"..k)
		local break_name = getConvertChildByName(item, "break_name_"..k)
		local open_txt = getConvertChildByName(item, "break_open_"..k)

		local show_txt = string.format("%s+%s", info.boat_breakthrough_txt, info.boat_breakthrough_value)
		icon:changeTexture(convertResources(info.boat_breakthrough_icon), UI_TEX_TYPE_PLIST)
		attr:setText(show_txt)
		local lock_level = k * 10
		local is_lock = lock_level > boat_strengthen_level
		lock:setVisible(is_lock)
		lock_txt:setVisible(is_lock)
		open_txt:setVisible(not is_lock)
		break_name:setText(info.boat_breakthrough_name)
	end
 
	return tip_panel
end

function ClsFleetStrengthenUI:initEvent()
	--强化按钮
	self.strengthen_panel.last_time = 0
	self.strengthen_panel.widgets.btn_strengthen:setPressedActionEnabled(true)
	self.strengthen_panel.widgets.btn_strengthen:addEventListener(function()
		if CCTime:getmillistimeofCocos2d() - self.strengthen_panel.last_time < 1000 then return end
        self.strengthen_panel.last_time = CCTime:getmillistimeofCocos2d()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		if self.own_hammers < self.consume_cost then
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			Alert:showJumpWindow(HAMMER_NOT_ENOUGH, shipyard_ui)
		elseif self.own_cash < self.cash_cost then
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			Alert:showJumpWindow(CASH_NOT_ENOUGH, shipyard_ui, {need_cash = self.cash_cost, come_type = Alert:getOpenShopType().VIEW_3D_TYPE, come_name = "backpack_boat_Strengthen"})
		else
			self:setTouch(false)
			local partner_data = getGameData():getPartnerData()
			partner_data:askPartnerEnhance(self.select_boat_item.partner_index)
		end
    end, TOUCH_EVENT_ENDED)

	self.break_panel.widgets.btn_break:setPressedActionEnabled(true)
	self.break_panel.widgets.btn_break:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local nobility_data = getGameData():getNobilityData()
		local my_nobility = nobility_data:getNobilityID()

		if(my_nobility < self.need_nobility)then--爵位不足
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			Alert:showJumpWindow(NOBILITY_NOT_ENOUGH, shipyard_ui, {ignore_sea = false})
			return
		elseif self.own_crystals < self.consume_cost then
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			Alert:showJumpWindow(BREAKTHROUGH_NOT_ENOUGH, shipyard_ui)
			return
		end

		local partner_data = getGameData():getPartnerData()
		partner_data:askPartnerEnhance(self.select_boat_item.partner_index)
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
    end, TOUCH_EVENT_ENDED)

	self.break_attr:addEventListener(function()
		getUIManager():create("ui/view/clsBaseTipsView", nil, "AttsTip", {effect = UI_EFFECT.SCALE,is_back_bg = false}, self:showStrengthenTip(), true)
    end, TOUCH_EVENT_ENDED)

	self.strengthen_panel.widgets.hammer_bg:addEventListener(function()
    	local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
		Alert:showJumpWindow(HAMMER_TIPS, shipyard_ui)
	end, TOUCH_EVENT_ENDED)

	self.break_panel.widgets.crystal_bg:addEventListener(function()
    	local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
		Alert:showJumpWindow(BREAKTHROUGH_TIPS, shipyard_ui)
	end, TOUCH_EVENT_ENDED)

	RegTrigger(ITEM_UPDATE_EVENT, function()
        if tolua.isnull(self) then return end
        self:updateHammer()
        self:updateCrystal()
    end)
end

function ClsFleetStrengthenUI:updateShipList()
	local partner_data = getGameData():getPartnerData()
	local partner_ids = partner_data:getBagEquipIds()

	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	local function onListCellTap(x, y, cell)
		if not cell.data then return end
		if self.select_boat_item then
			if self.select_boat_item.partner_index == cell.partner_index then return end
			self.select_boat_item:setSelectStatus(false)
		end

		if x then
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
		end

		self.select_index = cell.partner_index
		cell:setSelectStatus(true)
		self.select_boat_item = cell
		self.select_boat_key = self.select_boat_item.data.boatKey
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
	for i, sailor_id in ipairs(partner_ids) do
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

function ClsFleetStrengthenUI:getSkinData(boat_key)
    local partner_data = getGameData():getPartnerData()
    local skin_data = partner_data:getBagEquipSkinByBoatKey(boat_key)
    if skin_data and skin_data.skin_enable == 1 then
        return skin_data
    end
end
function ClsFleetStrengthenUI:showBoatEquipInfo(need_number_effect, is_success)
	local partner_data = getGameData():getPartnerData()
	local partner_equip_data = partner_data:getBagEquipInfoById(self.select_boat_item.data.id)
	local boat_key = partner_equip_data.boatKey
	
	local ship_data = getGameData():getShipData()
	local boat_equip = ship_data:getBoatDataByKey(boat_key)
	local boat_strengthen_level = partner_equip_data.boatLevel
	local skin_data = self:getSkinData(boat_key)
	local boat_name = boat_equip.name
	local boat_3d_id = boat_equip.id

	if skin_data then
		boat_name = skin_data.skin_name
		boat_3d_id = skin_data.skin_id
	end
	boat_equip.boat_level = boat_strengthen_level
	self.boat_equip = boat_equip

	local boat_strengthen_next_level = boat_strengthen_level + 1
	self.next_level = boat_strengthen_next_level
	local boat_rate = partner_equip_data.boatRate

	self.ship_name:setText(boat_name)
	self.ship_name:setUILabelColor(QUALITY_COLOR_STROKE[boat_equip.quality])

	local strengthen_level = string.format("%s +%s", ui_word.SHIPYARD_STRENGTH, boat_strengthen_level)
	self.current_level_label:setUILabelColor(QUALITY_COLOR_STROKE[math.floor(boat_strengthen_level /10) +1])

	local next_break = ((boat_strengthen_level + 1) % 10 == 0) or false
	self.strengthen_panel:setVisible(not next_break)
	self.break_panel:setVisible(next_break)
	self.next_break = next_break

	local strengthen_level_r = string.format("%s +%s", ui_word.SHIPYARD_STRENGTH, boat_strengthen_next_level)
	self.next_level_label:setUILabelColor(QUALITY_COLOR_STROKE[math.floor((boat_strengthen_level+1)/10) +1])

	if(is_success)then
		showLabelAct(self.current_level_label,boat_strengthen_level-1,boat_strengthen_level,ui_word.SHIPYARD_STRENGTH.." +")
		showLabelAct(self.next_level_label,boat_strengthen_next_level-1,boat_strengthen_next_level,ui_word.SHIPYARD_STRENGTH.." +")
	else
		self.current_level_label:setText(strengthen_level)
		self.next_level_label:setText(strengthen_level_r)
	end

	--创建船armature
	if not tolua.isnull(self.ship_model) then 
        self.ship_model:removeFromParentAndCleanup(true)
        self.ship_model = nil
    end

    local boat = boat_info[boat_equip.id]
    local show_txt = string.format(ui_word.FLOW_TIP, boat.bt_flow_res)
	self.flow_tips:setText(show_txt)

	self:showShip3D(boat_3d_id)

	local strengthening_info = boat_strengthening[boat_strengthen_level]
	local strengthening_info_new = boat_strengthening[boat_strengthen_next_level]

	local attr_values = {}
    for k, v in ipairs(boat_equip.base_attrs) do
        if need_attr[v.attr] then
            attr_values[v.attr] = v
        end
    end

	for k = 1, ATTR_NUM do
		local left_item = self.left_attrs[k]
		local kind = left_item.kind
		local base_num = attr_values[kind].value
		if strengthening_info then
			local up_num = string.format("+%s", strengthening_info[need_attr[kind]])
			left_item:setText(base_num, up_num,is_success)
		else
			left_item:setText(base_num, 0)
		end
		if strengthening_info_new then
			local right_temp = self.right_attrs[k]
			up_num = string.format("+%s", strengthening_info_new[need_attr[kind]])
			right_temp:setText(base_num, up_num,is_success)
		end
	end

	self.right_panel:setVisible((strengthening_info_new ~= nil))

	local break_index = math.floor(boat_strengthen_level/10) +1
	local info = boat_breakthrough_xianshi[break_index]
	if(info)then
		self.next_unlock_name:setText(info.boat_breakthrough_name)
		self.next_icon:changeTexture(convertResources(info.boat_breakthrough_icon), UI_TEX_TYPE_PLIST)
		self.next_unlock_text:setText(string.format(ui_word.STRENG_UNLOCK_TIPS,break_index*10))
	end
	self.next_msg_panel:setVisible(info ~= nil)
	self.no_unlock_text:setVisible(info == nil)

	self.consume_cost = 0
	self.cash_cost = 0
	self.need_nobility = 0

	if not next_break then--接下来是强化
		local strengthen_widgets = self.strengthen_panel.widgets
		strengthen_widgets.bar:setPercent(boat_rate)

		if need_number_effect then
			local str = strengthen_widgets.bar_num:getStringValue()
			local old_rate = string.gsub(str, '%%', '')
	        UiCommon:numberEffect(strengthen_widgets.bar_num, tonumber(old_rate), boat_rate, 20, nil, nil, "%")
		else
			strengthen_widgets.bar_num:setText(boat_rate .. "%")
		end

		if strengthening_info_new then
			for k, v in pairs(strengthening_info_new.strengthening_material) do
				local item_res = item_info[k].res
				strengthen_widgets.consume_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
				strengthen_widgets.consume_num:setText(v)
				self.consume_id = k
				self.consume_cost = v
			end
			self.cash_cost = strengthening_info_new.strengthening_cash
			strengthen_widgets.cash_num:setText(self.cash_cost)
			self:updateHammer(need_number_effect)
			self:updateCash()
		else
			strengthen_widgets.consume_num:setText("0")
			strengthen_widgets.cash_num:setText("0")
			strengthen_widgets.btn_strengthen:disable()
		end
	else--接下来是突破
		local break_widgets = self.break_panel.widgets
		local index = boat_strengthen_next_level / 10
		local info = boat_breakthrough_xianshi[index]
		break_widgets.break_attr_name:setText(string.format("%s%s+%s", info.boat_breakthrough_txt, ui_word.STR_PROPERTY, info.boat_breakthrough_value))
		if strengthening_info_new then
			for k, v in pairs(strengthening_info_new.strengthening_material) do
				local item_res = item_info[k].res
				break_widgets.crystal_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
				break_widgets.crystal_amount:setText(v)
				self.consume_id = k
				self.consume_cost = v
			end
			self.cash_cost = strengthening_info_new.strengthening_cash
			self.need_nobility = strengthening_info_new.nobility_id
			break_widgets.cash_num:setText(self.cash_cost)
			self:updateCrystal()
			self:updateCash()
			self:updateNobility()
		end
	end
end

function ClsFleetStrengthenUI:updateBarPercent()
	local partner_data = getGameData():getPartnerData()
	local partner_equip_data = partner_data:getBagEquipInfoById(self.select_boat_item.data.id)
	local strengthen_widgets = self.strengthen_panel.widgets
	strengthen_widgets.bar_num:setText(partner_equip_data.boatRate .. "%")
	strengthen_widgets.bar:setPercent(partner_equip_data.boatRate)
end

function ClsFleetStrengthenUI:updateCrystal()
	local prop_data_handler = getGameData():getPropDataHandler()
	self.own_crystals = prop_data_handler:getCrystalNum(self.consume_id)
	local break_widgets = self.break_panel.widgets
	break_widgets.crystal_amount:setText(string.format("%s/%s", self.own_crystals, self.consume_cost))

	local color = COLOR_ORANGE_STROKE
	if self.own_crystals < self.consume_cost then
		color = COLOR_RED_STROKE
	end
	break_widgets.crystal_amount:setUILabelColor(color)
end

function ClsFleetStrengthenUI:updateHammer(need_number_effect)
	local prop_data_handler = getGameData():getPropDataHandler()
	local hammer_key = {
		PROP_ITEM_JUNIOR_HAMMER,
		PROP_ITEM_HIGH_HAMMER,
		PROP_ITEM_MYSTERY_HAMMER,
	}
	self.own_hammers = 0
	for i, v in ipairs(hammer_key) do
		if v == self.consume_id then
			self.own_hammers = prop_data_handler:getHammerNum(v)
		end
	end

	local strengthen_widgets = self.strengthen_panel.widgets
	strengthen_widgets.consume_num:setText(string.format("%s/%s", self.own_hammers, self.consume_cost))

	local color = COLOR_ORANGE_STROKE
	if self.own_hammers < self.consume_cost then
		color = COLOR_RED_STROKE
	end
	strengthen_widgets.consume_num:setUILabelColor(color)
end

function ClsFleetStrengthenUI:updateCash()
	local playerData = getGameData():getPlayerData()
	self.own_cash = playerData:getCash()
	local gola_widgets = self.strengthen_panel.widgets
	if self.next_break then
		gola_widgets = self.break_panel.widgets
	end

	local color = COLOR_ORANGE_STROKE
	if self.own_cash < self.cash_cost then
		color = COLOR_RED_STROKE
	end
	gola_widgets.cash_num:setUILabelColor(color)
end

function ClsFleetStrengthenUI:updateNobility()
	if(self.need_nobility == 0)then return end

	local nobility_config = require("game_config/nobility_data")
	local need_data = nobility_config[self.need_nobility]
	if(not need_data)then return end

	local nobility_data = getGameData():getNobilityData()
	local my_nobility_id = nobility_data:getNobilityID()

	local break_widgets = self.break_panel.widgets
	break_widgets.title_name:setText(need_data.title)
	local color = COLOR_ORANGE_STROKE
	if my_nobility_id < self.need_nobility then
		color = COLOR_RED_STROKE
	end
	break_widgets.title_name:setUILabelColor(color)
end

function ClsFleetStrengthenUI:updateStrengthenEffect(index, errno, is_success, rate_change)
	self:setTouch(true)
	if errno ~= 0 then return end
	self:showBoatEquipInfo(true,is_success ~=0)
	local strengthen_widgets = self.strengthen_panel.widgets
	if is_success ~= 0 then--强化成功，强化等级增加了
		local partner_data = getGameData():getPartnerData()
		local partner_equip_data = partner_data:getBagEquipInfoById(self.select_boat_item.data.id)
		local boat_key = partner_equip_data.boatKey
		local ship_data = getGameData():getShipData()
		local boat_equip = ship_data:getBoatDataByKey(boat_key)
		local boat_strengthen_level = partner_equip_data.boatLevel
		local is_break = (boat_strengthen_level % 10 == 0) or false
		if is_break then
			-- self:showBreakSuccessUI()
			self:showEnhanceSuccessUI(index, rate_change, true)
			return
		end
		self:showEnhanceSuccessUI(index, rate_change)
	else
		local msg = string.format(ui_word.FLEET_STRENGTHEN_FAILURE, rate_change)
		Alert:warning({msg = msg})
		strengthen_widgets.bar_add_num:setVisible(true)
		strengthen_widgets.bar_add_num:setText(string.format("%+d%%", rate_change))
		strengthen_widgets.bar_add_num:runAction(CCFadeOut:create(2))
		local str = strengthen_widgets.bar_num:getStringValue()
		local old_rate = string.gsub(str, '%%', '')
        UiCommon:numberEffect(strengthen_widgets.bar_num, tonumber(old_rate), (old_rate + rate_change), 20, nil, nil, "%")
	end

	local function clearEffect()
		if not tolua.isnull(self.ship_enhance_effect) then
			self.ship_enhance_effect:removeFromParentAndCleanup(true)
			self.ship_enhance_effect = nil
		end
	end
	self.ship_enhance_effect = CompositeEffect.new("tx_ship_enhance", 327, 200, self, -1, nil, nil, nil)
	audioExt.playEffect(music_info.SHIPYARD_BUILD.res)
	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(1.25))
    arr:addObject(CCCallFunc:create(function()
        clearEffect()
    end))
    self:runAction(CCSequence:create(arr))
end

function ClsFleetStrengthenUI:updateLabelCallBack()
	self:updateCash()
	self:updateHammer()
end

function ClsFleetStrengthenUI:showBreakSuccessUI()
	getUIManager():create("gameobj/backpack/clsShipBreakEffectLayer", nil, {boat_info = self.boat_equip})
end

function ClsFleetStrengthenUI:showEnhanceSuccessUI(index, rate_change,is_break)
	local plistTab = {
        ["ui/ship_icon.plist"] = 1,
        ["ui/backpack.plist"] = 1,
    }
    LoadPlist(plistTab)

	local ui_layer = UIWidget:create()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_enhance_success.json")
    convertUIType(panel)
    ui_layer:addChild(panel)

    local need_attr = {
		[ATTR_KEY_REMOTE] = "far_strengthening_num",
		[ATTR_KEY_MELEE] = "near_strengthening_num",
		[ATTR_KEY_DEFENSE] = "defense_strengthening_num",
		[ATTR_KEY_DURABLE] = "hpmax_strengthening_num",   
	}

    local widget_info = {
    	[1] = {name = "boat_pic"},
    	[2] = {name = "boat_name"},
    	[3] = {name = "next_text"},
    	[4] = {name = "effect_layer"},
    	[5] = {name = "boat_strengthen_num"},
    	[6] = {name = "ship_skill_icon"},
    	[7] = {name = "attr_name"},
    	[8] = {name = "attr_info"},
    	[9] = {name = "att_panel"}
	}

	for k, v in ipairs(widget_info) do
		local item = getConvertChildByName(panel, v.name)
		ui_layer[v.name] = item
	end
	ui_layer.next_text:setText(string.format(ui_word.UP_RATE_NEXT, rate_change, '%'))
	ui_layer.next_text:setVisible(not is_break and rate_change ~= 0)

	ui_layer.boat_pic:setVisible(false)
	local qianghua_effect = CompositeEffect.new("tx_qianghua", 99, 645, ui_layer.effect_layer, nil, function() 
	end, nil, nil, true)
	local qianghua_txt = CompositeEffect.new(is_break and "tx_txt_break_success" or "tx_txt_enhance_success", 99, 645+90, ui_layer.effect_layer, nil, function() 
	end, nil, nil, true)

	require("framework.scheduler").performWithDelayGlobal(function()
		if tolua.isnull(ui_layer.boat_pic) then return end
		ui_layer.boat_pic:setVisible(true)
	end, 0.25)

    local partner_data = getGameData():getPartnerData()
	local partner_equip_data = partner_data:getBagEquipInfo(index + 1)
	local boat_key = partner_equip_data.boatKey
	
	local ship_data = getGameData():getShipData()
	local boat_equip = ship_data:getBoatDataByKey(boat_key)
	local skin_data = self:getSkinData(boat_key)
	
	local item_res = boat_info[boat_equip.id].res
	local boat_name = boat_equip.name
	if skin_data then
		boat_name = skin_data.skin_name
		item_res = boat_info[skin_data.skin_id].res
	end
	local boat_strengthen_level = partner_equip_data.boatLevel

	
	ui_layer.boat_pic:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)

	if (boat_strengthen_level + 1) % 10 == 0 then
		ui_layer.next_text:setVisible(false)
	end

	ui_layer.boat_name:setText(boat_name)
	ui_layer.boat_name:setUILabelColor(QUALITY_COLOR_STROKE[boat_equip.quality])
	ui_layer.boat_strengthen_num:setText(" +"..boat_strengthen_level)
	ui_layer.boat_strengthen_num:setUILabelColor(QUALITY_COLOR_STROKE[math.floor(boat_strengthen_level /10) +1])

	local info = boat_breakthrough_xianshi[math.floor(boat_strengthen_level/10)]
	ui_layer.att_panel:setVisible(is_break and info ~= nil)
	if(is_break and info)then
		ui_layer.attr_name:setText(info.boat_breakthrough_name)
		ui_layer.ship_skill_icon:changeTexture(convertResources(info.boat_breakthrough_icon), UI_TEX_TYPE_PLIST)
		local show_txt = string.format("%s+%s", info.boat_breakthrough_txt, info.boat_breakthrough_value)
		ui_layer.attr_info:setText(show_txt)
	end

	local scheduler = CCDirector:sharedDirector():getScheduler()

	ui_layer.onExit = function(self)
		if ui_layer.scheduleHandler then
    		scheduler:unscheduleScriptEntry(ui_layer.scheduleHandler)
    		ui_layer.scheduleHandler = nil
    	end
    	UnLoadPlist(plistTab)

		getUIManager():close("AlertShowZhanDouLiEffect")
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local task = DialogQuene.doing_task
		if(task)then 
			if(task:getQueneType() == DialogQuene:getDialogType().battle_power)then DialogQuene.doing_task:TaskEnd()end
		end
	end

	local function callBack()
		if ui_layer.scheduleHandler then
    		scheduler:unscheduleScriptEntry(ui_layer.scheduleHandler)
    		ui_layer.scheduleHandler = nil
    	end
    	getUIManager():close("ClsFleetStrengthenSuccessTips")
    end

	panel:setPosition(ccp(display.cx, display.top))
    panel:setAnchorPoint(ccp(0.5, 1))
	ui_layer.scheduleHandler = scheduler:scheduleScriptFunc(callBack, 3, false)

	getUIManager():create("ui/view/clsBaseTipsView", nil, "ClsFleetStrengthenSuccessTips", {effect = false, is_back_bg = false}, ui_layer, true)
end

function ClsFleetStrengthenUI:setTouch(enabled)
	if not tolua.isnull(self.list_view) then
		self.list_view:setTouch(enabled)
	end
end

function ClsFleetStrengthenUI:onExit()
	UnRegTrigger(ITEM_UPDATE_EVENT)
	UnLoadPlist(self.plist_tab)
	ReleaseTexture(self)
end

function ClsFleetStrengthenUI:showUpEff(parent, type ,is_widget)
	if(not type)then return end
	local img_name = {"txt_enhance_success.png","txt_break_success.png"}
    local img_file = "ui/txt/"..img_name[type]
    if(#img_file < 8)then return end

    local img = UIImageView:create() 
	img:changeTexture(img_file, UI_TEX_TYPE_LOCAL)
    img:setPosition(ccp(display.width*0.5- 22 ,display.height*0.88 + 122 ))
    if(is_widget)then
    	parent:addChild(img)
    else
    	parent:addWidget(img)
    end
    local arr = CCArray:create()
    local a1 = CCMoveTo:create(0.6, ccp(img:getPosition().x,img:getPosition().y - 90))
    local a2 = CCMoveTo:create(0.3,ccp(img:getPosition().x, img:getPosition().y -90 - 9 ))
    local a3 = CCCallFunc:create(function (  )
    	img:removeFromParentAndCleanup(true)
    end)

    arr:addObject(a1)
    arr:addObject(a2)
    arr:addObject(a3)
    img:stopAllActions()
    img:runAction(CCSequence:create(arr))
end

function ClsFleetStrengthenUI:showShip3D(boat_id)  
    if boat_info[boat_id] == nil then return end 
    
    self.layer3d:removeAllChildren()
    
    local path = SHIP_3D_PATH
    local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
    local Sprite3D = require("gameobj/sprite3d")

    local pos_x = -140
    local ship_attr = boat_attr[boat_id]
    if #ship_attr.occup == 1 then
        if ship_attr.occup[1] == 3 then
            pos_x = -160
        end
    end

    local pos_ids = {
        [1] = 40,
        [2] = -30,
        [3] = -30,
        [12] = 40,
        [112] = 40 
    }
    if pos_ids[boat_id] then
        pos_x = pos_x + pos_ids[boat_id]
    end

    local item = {
        id = boat_id,
        key = boat_key,
        path = path,
        is_ship = true,
        node_name = node_name,
        ani_name = node_name,
        parent = self.layer3d,
        pos = {x = pos_x, y = -120, angle = 90},
    }
    local ship_3d = Sprite3D.new(item)
    ship_3d.node:scale(1.35)
end

function ClsFleetStrengthenUI:getBtnClose()
    return self.btn_close
end

function ClsFleetStrengthenUI:preClose(...)
    self.layer3d = nil
    Main3d:removeScene(SCENE_ID.PREVIEW)
end

return ClsFleetStrengthenUI
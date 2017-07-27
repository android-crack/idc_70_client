-- 船只改造界面
local music_info=require("scripts/game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local boat_xilian_cost = require("game_config/boat/boat_xilian_cost")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local base_attr_info = require("game_config/base_attr_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local on_off_info = require("game_config/on_off_info")
local ClsShipyardShipItem = require("gameobj/shipyard/clsShipyardShipItem")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsBaseView = require("ui/view/clsBaseView")
local skill_info = require("game_config/skill/skill_info")
local ATTR_NUM = 5

----------------------------------------------------------------------
local ClsFleetRefineUI = class("ClsFleetRefineUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsFleetRefineUI:getViewConfig()
    return {
        name = "ClsFleetRefineUI",   --(选填）默认 class的名字
        type = UI_TYPE.VIEW,         --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        is_swallow = false,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
    }
end

--paraml里面有select_index 和backpack_key 字段，这里的索引从主句开始1-5
function ClsFleetRefineUI:onEnter(param)
	self.plist_tab = {
		["ui/ship_icon.plist"] = 1,
	}
	LoadPlist(self.plist_tab)

	if param then
		self.select_index = param.select_index
		self.default_backpack_key = param.backpack_key
	end

	self:initUI()
	self:initEvent()
	self:updateShipList()
end

function ClsFleetRefineUI:initUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shipyard_xilian.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)

    local widget_info = {
    	[1] = {name = "ship_icon_left", json_name = "ship_pic"},
    	[2] = {name = "ship_icon_bg_left", json_name = "ship_bg"},
    	[3] = {name = "ship_bg_right", json_name = "ship_bg_r"},
    	[4] = {name = "ship_icon_right", json_name = "ship_pic_r"},
    	[5] = {name = "select_ship_text", json_name = "select_ship_text"},
    	[6] = {name = "ship_icon_bg_right", json_name = "ship_bg_r"},
    	[7] = {name = "ship_add_text", json_name = "ship_add_text"},
    	[8] = {name = "consume_num", json_name = "consume_num"},
    	[9] = {name = "btn_refine", json_name = "btn_xilian"},
    	[10] = {name = "btn_close", json_name = "btn_close"},
	}

	for k, v in ipairs(widget_info) do
		self[v.name] = getConvertChildByName(self.panel, v.json_name)
	end

    self.ship_add_text:setText("")

    self.left_attr_list = {}
    self.right_attr_list = {}

    local function setAttrEnable(self, enable)
    	self.btn:setTouchEnabled(enable)
		self.btn:setVisible(enable)
		self.attr:setVisible(enable)
    end

    for i = 1, ATTR_NUM do
    	--左边
    	local btn_name = string.format("btn_select_%s", i)
    	local btn_text = string.format("check_text_%s_l", i)
    	local left_attr_obj = {}--左边的每一个随机属性对象
    	left_attr_obj.btn = getConvertChildByName(self.panel, btn_name)
    	left_attr_obj.attr = getConvertChildByName(self.panel, btn_text)
    	left_attr_obj.setVisible = setAttrEnable

    	--左边每一个随机框注册事件
    	left_attr_obj.btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateLeftCheckList(i, true)
		end, CHECKBOX_STATE_EVENT_SELECTED)

		left_attr_obj.btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateLeftCheckList(i, false)
		end, CHECKBOX_STATE_EVENT_UNSELECTED)

		--右边
		btn_name = string.format("btn_select_%s_r", i)
		btn_text = string.format("check_text_%s_r", i)

		local right_attr_obj = {}--左边的每一个随机属性对象
    	right_attr_obj.btn = getConvertChildByName(self.panel, btn_name)
    	right_attr_obj.attr = getConvertChildByName(self.panel, btn_text)
    	right_attr_obj.setVisible = setAttrEnable

    	--右边复选框注册事件
    	right_attr_obj.btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateRightCheckList(i, true)
		end,CHECKBOX_STATE_EVENT_SELECTED)

		right_attr_obj.btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateRightCheckList(i, false)
		end,CHECKBOX_STATE_EVENT_UNSELECTED)

		right_attr_obj:setVisible(false)

		self.left_attr_list[i] = left_attr_obj
    	self.right_attr_list[i] = right_attr_obj
    end
    self:setRefineCostNum()

	self.getGuideObj = function(condition)
		return self:getGuideInfo(condition)
	end
	
    require("framework.scheduler").performWithDelayGlobal(function()
        ClsGuideMgr:tryGuide("ClsFleetRefineUI")
    end,.3)
end

function ClsFleetRefineUI:getGuideInfo(condition)
	if(condition.aid == 1)then
		return self.right_attr_list[1].btn
	elseif(condition.aid == 2)then
		return self.left_attr_list[1].btn
	end
end

function ClsFleetRefineUI:initEvent()
	self.ship_bg_right:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:createChooseBoatPanel()
    end,TOUCH_EVENT_ENDED)

	self.btn_refine:setPressedActionEnabled(true)
	self.btn_refine:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	    if ClsSceneManage:doLogic("checkAlert") then return end
		local player_info = getGameData():getPlayerData()
		if not self.right_check_index then
			Alert:warning({msg = ui_word.BACKPACK_BOAT_WANT_CHOOSE, size = 26})
		elseif not self.left_check_index then
			Alert:warning({msg = ui_word.BACKPACK_BOAT_WANT_REFINE_CHOOSE, size = 26})
		elseif player_info:getCash() < self.need_gold then
			local shipyard_ui = getUIManager():get("ClsShipyardMainUI")
			Alert:showJumpWindow(CASH_NOT_ENOUGH, shipyard_ui, {need_cash = self.need_gold, come_type = Alert:getOpenShopType().VIEW_3D_TYPE, come_name = "backpack_boat_refine"})
		else
			local ship_data = getGameData():getShipData()
			local src_attr = self.right_attr_list[self.right_check_index].attr_id
			local dst_attr = self.left_attr_list[self.left_check_index].attr_id
			ship_data:askBoatWash(self.backpack_key, self.equip_boat_key, src_attr, dst_attr)
		end
    end,TOUCH_EVENT_ENDED)

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

function ClsFleetRefineUI:updateShipList()
	local partner_data = getGameData():getPartnerData()
	local partner_ids = partner_data:getBagEquipIds()

	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	local function onListCellTap( x, y, cell )
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
		self.equip_boat_key = self.select_boat_item.data.boatKey
		if self.default_backpack_key then
			self.backpack_key = self.default_backpack_key 
			self:updateBackpackRefineInfo()
			self:setRefineCostNum()
			self.default_backpack_key = nil
			local ship_data = getGameData():getShipData()
			ship_data:askRefineColor(self.backpack_key, self.equip_boat_key)
		else
			self:clearBackpackBoatInfo()
		end
		self:updateEquipRefineInfo()
		self:updateCheckStatus()
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
		local boat_item = ClsShipyardShipItem.new(list_cell_size, {index = i, sailor_id = sailor_id, call_back = function(x, y, cell)
				onListCellTap(x, y, cell)
			end})
		self.boat_item_list[#self.boat_item_list + 1] = boat_item
	end
	self.list_view:addCells(self.boat_item_list)

	self.select_index = self.select_index or 1
	select_cell = self.boat_item_list[self.select_index]
	onListCellTap(nil, nil, select_cell)
end

function ClsFleetRefineUI:refreshRefineInfo()
	self.left_check_index = nil
	self.right_check_index = nil
	self:updateLabelCallBack()
	self:updateEquipRefineInfo()
	local is_empty_attr = self:updateBackpackRefineInfo()
	if is_empty_attr then
		local a,alert_layer = Alert:showAttention(ui_word.REFINE_RANDOM_ATTR_EMPTY_TIP, function()
			local ship_data = getGameData():getShipData()
			ship_data:askBoatSplit(self.backpack_key)
		end)
		self.alert_layer = alert_layer
		ClsGuideMgr:tryGuide("ClsFleetRefineUI")
	end
	self:updateCheckStatus()
	local ship_data = getGameData():getShipData()
	ship_data:askRefineColor(self.backpack_key, self.equip_boat_key)
end

function ClsFleetRefineUI:getSkinData(boat_key)
    local partner_data = getGameData():getPartnerData()
    local skin_data = partner_data:getBagEquipSkinByBoatKey(boat_key)
    if skin_data and skin_data.skin_enable == 1 then
        return skin_data
    end
end

function ClsFleetRefineUI:updateEquipRefineInfo()
	local ship_data = getGameData():getShipData()

	local left_boat = ship_data:getBoatDataByKey(self.equip_boat_key)
	local skin_data = self:getSkinData(self.equip_boat_key)
	local boat_show_id = left_boat.id
	if skin_data then
		boat_show_id = skin_data.skin_id
	end
	
	local left_item_res = boat_info[boat_show_id].res
	self.ship_icon_left:changeTexture(convertResources(left_item_res), UI_TEX_TYPE_PLIST)

	local quality = left_boat.quality
	local icon_bg_res = string.format("item_box_%s.png", quality)
	self.ship_icon_bg_left:changeTexture(icon_bg_res, UI_TEX_TYPE_PLIST)

	local rand_attrs = left_boat.rand_attrs
	self.rand_amount = left_boat.rand_amount

	for i = 1, ATTR_NUM do
		local left_attr_obj = self.left_attr_list[i]
		left_attr_obj.btn:setSelectedState(false)
		local left_attr_info = rand_attrs[i]
		if left_attr_info then
			left_attr_obj:setVisible(true)
			left_attr_obj.attr_id = left_attr_info.attr
			left_attr_obj.attr_value = left_attr_info.value

			local show_txt = nil
			if left_attr_info.attr == "boatSkill" then
				local skill_attr = skill_info[left_attr_info.value]
				local sailor_data = getGameData():getSailorData()
				local desc_tab = sailor_data:getSkillDescWithLv(left_attr_info.value, 1)
				show_txt = desc_tab.base_desc
			else
				show_txt = string.format("%s +%s", base_attr_info[left_attr_info.attr].name, left_attr_info.value)
			end
			left_attr_obj.attr:setText(show_txt)
			left_attr_obj.attr:setUILabelColor(QUALITY_COLOR_STROKE[left_attr_info.quality])
		else
			left_attr_obj.attr_id = ""
			left_attr_obj:setVisible(i <= self.rand_amount)
			left_attr_obj.attr:setText(ui_word.BACKPACK_BOAT_SPACE_STR)
			left_attr_obj.attr:setUILabelColor(COLOR_COFFEE)
		end
	end
end

function ClsFleetRefineUI:clearBackpackBoatInfo()
	self.backpack_key = nil
	self.ship_add_text:setText("")
	self.ship_icon_right:setVisible(false)
	self.select_ship_text:setVisible(true)

	for i = 1, ATTR_NUM do
		local right_attr_obj = self.right_attr_list[i]
		right_attr_obj.btn:setSelectedState(false)
		right_attr_obj.attr_id = nil
		right_attr_obj:setVisible(false)
	end
	self:setRefineCostNum()
	local icon_bg_res = string.format("item_box_%s.png", 0)
	self.ship_icon_bg_right:changeTexture(icon_bg_res, UI_TEX_TYPE_PLIST)
end

--选择右边的船洗练
function ClsFleetRefineUI:updateBackpackRefineInfo()
	self.ship_add_text:setText("")
	if not self.backpack_key then
		return
	end
	local ship_data = getGameData():getShipData()
	local right_boat = ship_data:getBoatDataByKey(self.backpack_key)
	if not right_boat then 
		return 
	end
	local right_item_res = boat_info[right_boat.id].res
	self.ship_icon_right:changeTexture(convertResources(right_item_res), UI_TEX_TYPE_PLIST)
	self.ship_icon_right:setVisible(true)
	self.select_ship_text:setVisible(false)

	local quality = right_boat.quality
	local icon_bg_res = string.format("item_box_%s.png", quality)
	self.ship_icon_bg_right:changeTexture(icon_bg_res, UI_TEX_TYPE_PLIST)

	local empty_attr = true--默认属性为空
	for i = 1, ATTR_NUM do
		local right_attr_obj = self.right_attr_list[i]
		right_attr_obj.btn:setSelectedState(false)
		local right_attr_info = right_boat.rand_attrs[i]
		if right_attr_info then
			empty_attr = false
			right_attr_obj.attr_id = right_attr_info.attr
			right_attr_obj.attr_value = right_attr_info.value
			local show_txt = nil
			local value = right_attr_info.value
			if right_attr_info.attr == "boatSkill" then
				local skill_attr = skill_info[right_attr_info.value]
				local sailor_data = getGameData():getSailorData()
				local desc_tab = sailor_data:getSkillDescWithLv(right_attr_info.value, 1)
				show_txt = desc_tab.base_desc
			else
				show_txt = string.format("%s +%s", base_attr_info[right_attr_info.attr].name, right_attr_info.value)
			end
			right_attr_obj.attr:setText(show_txt)
		else
			right_attr_obj.attr_id = nil
			right_attr_obj:setVisible(false)
		end
	end
	return empty_attr
end

function ClsFleetRefineUI:updateRightAttrColor(right_boat_key, left_boat_key, attr_info)
	if self.backpack_key ~= right_boat_key or self.equip_boat_key ~= left_boat_key then
		return
	elseif attr_info then
		for k, v in ipairs(self.right_attr_list) do
			for i, j in ipairs(attr_info) do
				if v.attr_id == j.attr then
					v.attr_color = j.quality
					v.attr:setUILabelColor(QUALITY_COLOR_STROKE[j.quality])
					v:setVisible(v.can_check)
					if not v.can_check then
						v.attr:setVisible(true)
					end
				end
			end
		end
	end
end

function ClsFleetRefineUI:updateCheckStatus()
	local can_refine_num = 0
	for i, right_attr_obj in ipairs(self.right_attr_list) do
		if right_attr_obj.attr_id then
			local sample_index = nil
			local can_check = true
			for j, left_attr_obj in ipairs(self.left_attr_list) do
				if not sample_index then
					if right_attr_obj.attr_id == left_attr_obj.attr_id then
						sample_index = j
						if right_attr_obj.attr_id ~= "boatSkill" then
							if right_attr_obj.attr_value <= left_attr_obj.attr_value then
								can_check = false
							end
						end
					end
				end
			end
			right_attr_obj.sample_index = sample_index
			right_attr_obj.can_check = can_check
			if can_check then
				can_refine_num = can_refine_num + 1
			end
		end
	end
	if can_refine_num > 0 then
		self.btn_refine:active()
	else
		if self.backpack_key then
			Alert:warning({msg = ui_word.REFINE_NON_SELECT_ATTR_TIP, size = 26})
		end
		self.btn_refine:disable()
	end
end

function ClsFleetRefineUI:updateLeftCheckList(index, selected)
	if selected then
		self.left_check_index = index
		for i,v in ipairs(self.left_attr_list) do
			if i ~= index then
				v.btn:setSelectedState(false)
			end
		end
	else
		self.left_check_index = nil
	end
end

--选择右边复选框的时候
function ClsFleetRefineUI:updateRightCheckList(index, selected)
	local sample_index = nil
	self.ship_add_text:setText("")
	if selected then
		self.right_check_index = index
		for i, v in ipairs(self.right_attr_list) do
			if i ~= index then
				v.btn:setSelectedState(false)
			else
				sample_index = v.sample_index
				if v.attr_id ~= "boatSkill" then
					local show_txt = string.format("%s  +%d", base_attr_info[v.attr_id].name, v.attr_value)
					self.ship_add_text:setText(show_txt)
					if v.attr_color then
						self.ship_add_text:setUILabelColor(QUALITY_COLOR_STROKE[v.attr_color])
					end
				end
			end
		end
	else
		self.right_check_index = nil
	end

	self.left_check_index = sample_index
	for i, v in ipairs(self.left_attr_list) do
		if sample_index then
			v.btn:setSelectedState(sample_index == i)
			v:setVisible(sample_index == i)
		else
			if i <= self.rand_amount then
				v.btn:setSelectedState(false)
				v:setVisible(true)
			end
		end
	end
end

function ClsFleetRefineUI:updateLabelCallBack()
	local player_info = getGameData():getPlayerData()
	local color = COLOR_RED_STROKE
	if player_info:getCash() >= self.need_gold then
		color = COLOR_YELLOW_STROKE
	end
	self.consume_num:setUILabelColor(color)
end

function ClsFleetRefineUI:setRefineCostNum()
	self.need_gold = 0
	if self.backpack_key then
		local ship_data = getGameData():getShipData()
		local boat = ship_data:getBoatDataByKey(self.backpack_key)
		local boat_level = boat_attr[boat.id].level
		for i,v in ipairs(boat_xilian_cost) do
			if v.level == boat_level then
				self.need_gold = v.boat_xilian_cash
			end
		end
	end
    self.consume_num:setText(self.need_gold)
    self:updateLabelCallBack()
end

--右边选择船只洗练界面
function ClsFleetRefineUI:createChooseBoatPanel()
	getUIManager():create('gameobj/backpack/clsFleetRefineChooseUI', nil, self.select_boat_item.partner_index, self.backpack_key, function(item, x, y)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:selectItem(item, x, y)
	end)
end

function ClsFleetRefineUI:closeChooseBoatPanel(is_exit)
	getUIManager():close('ClsFleetRefineChooseUI')
end

function ClsFleetRefineUI:selectItem(item, x, y)
	self.backpack_key = item.data.data.guid
	self:setRefineCostNum()
	self:updateBackpackRefineInfo()
	self:updateCheckStatus()
	self:closeChooseBoatPanel()
	local ship_data = getGameData():getShipData()
	ship_data:askRefineColor(self.backpack_key, self.equip_boat_key)
end

function ClsFleetRefineUI:getBoatRefineTag(data, is_equip)
	if is_equip then return nil end

	local cur_boat_key = self.equip_boat_key
	if cur_boat_key == 0 then return nil end

	local ship_data = getGameData():getShipData()
	local bp_ship_info = ship_data:getBoatDataByKey(data.guid)
	local bp_rand_attr = bp_ship_info.rand_attrs
	if #bp_rand_attr == 0 then
		return nil
	end
	
	local cur_ship_info = ship_data:getBoatDataByKey(cur_boat_key)
	local cur_rand_amount = cur_ship_info.rand_amount
	local cur_rand_attr = cur_ship_info.rand_attrs
	local cur_attr_worst_color = 100
	if #cur_rand_attr < cur_rand_amount then
		cur_attr_worst_color = -1
	end

	for i, bp_attr in ipairs(bp_rand_attr) do
		local has_same = false
		for j, cur_attr in ipairs(cur_rand_attr) do
			if cur_attr.attr == bp_attr.attr then
				has_same = true
				if cur_attr.value < bp_attr.value then
					return TAG_TYPE.CAN_REFINE
				end
			end
			if cur_attr_worst_color ~= -1 and cur_attr.quality < cur_attr_worst_color then
				cur_attr_worst_color = cur_attr.quality
			end
		end
		if  not has_same and bp_attr.quality > cur_attr_worst_color then
			return TAG_TYPE.CAN_REFINE
		end 
	end
	return
end

function ClsFleetRefineUI:getBtnClose()
    return self.btn_close
end

function ClsFleetRefineUI:preClose()
	self:closeChooseBoatPanel(true)
end

function ClsFleetRefineUI:onExit()
	UnLoadPlist(self.plist_tab)
	ReleaseTexture(self)
end

return ClsFleetRefineUI
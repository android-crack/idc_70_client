-- 背包系统
-- Author: chenlurong
-- Date: 2016-06-27 20:09:27
--

local music_info=require("scripts/game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsScrollView = require("ui/view/clsScrollView")
local ui_word = require("scripts/game_config/ui_word")
local boat_info = require("game_config/boat/boat_info")
local baozang_info = require("game_config/collect/baozang_info")
local role_info = require("game_config/role/role_info")
local boat_attr = require("game_config/boat/boat_attr")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")
local ClsAlert = require("ui/tools/alert")
local baowu_dismantling = require("game_config/collect/baowu_dismantling")
local boat_fleet_config = require("game_config/boat/boat_fleet_config")
local on_off_info = require("game_config/on_off_info")
-------------------------------------------------------------------------
local col = 4
local row = 5
local star_total = 4

local ClsBackpackMainItem = class("ClsBackpackMainItem", function ()
		return UIWidget:create()
	end)

ClsBackpackMainItem.mkUi = function(self, index, data)
	self.data = data
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_item.json")
	convertUIType(self.panel)
	self:addChild(self.panel)

	self.item_bg = getConvertChildByName(self.panel, "item_bg")
	self.item_icon = getConvertChildByName(self.panel, "item_icon")
	self.item_icon:setVisible(false)
	self.item_num = getConvertChildByName(self.panel, "item_amount")
	self.item_num:setText("")
	self.item_selected = getConvertChildByName(self.panel, "item_selected")
	self.item_text = getConvertChildByName(self.panel, "item_text")
	self.item_text:setText("")
	self.item_lock = getConvertChildByName(self.panel, "item_lock")
	self.item_level = getConvertChildByName(self.panel, "item_level")
	self.item_level:setText("")

	if self.data then
		local data = self.data

		local item_type = data.type
		local base_data = data.data
		local show_tag = data.tag
		local quality = 1
		local count = 0
		if show_tag then
			self.item_text:setText(show_tag.text)
			setUILabelColor(self.item_text, ccc3(dexToColor3B(show_tag.color)))
		end

		local item_res = nil
		local isLock = false
		local player_data = getGameData():getPlayerData()
		local my_level = player_data:getLevel()

		local my_nobility = getGameData():getNobilityData():getNobilityID()
		if item_type == BAG_PROP_TYPE_SAILOR_BAOWU then
			item_res = baozang_info[base_data.baowuId].res
			quality = base_data.color
			isLock = my_level < baozang_info[base_data.baowuId].limitLevel
		elseif item_type == BAG_PROP_TYPE_BOAT_BAOWU  then
			self.item_level:setVisible(true)
			item_res = baozang_info[base_data.baowuId].res
			quality = base_data.step
			count = base_data.amount - base_data.upload_amount
			local boat_baowu_config = baozang_info[base_data.baowuId]
			isLock = my_level < boat_baowu_config.limitLevel
			self.item_level:setText(string.format(ui_word.BACKPCAK_ITEM_LEVEL_STR, boat_baowu_config.level))
			setUILabelColor(self.item_level, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))
		elseif item_type == BAG_PROP_TYPE_FLEET then
			item_res = boat_info[base_data.id].res
			quality = base_data.quality
			local boat_msg = boat_attr[base_data.id] or {}
			isLock = my_nobility < (boat_msg.nobility_id or 0)
		elseif item_type == BAG_PROP_TYPE_ASSEMB then
			item_res = base_data.baseData.res
			count = base_data.count
			quality = base_data.baseData.quality or base_data.baseData.level
		elseif item_type == BAG_PROP_TYPE_COMSUME then
			item_res = base_data.baseData.res
			count = base_data.count
			quality = base_data.baseData.quality or base_data.baseData.level
			isLock = my_level < base_data.baseData.UseGradeLimit
		end

		if count > 1 then
			self.item_num:setText(tostring(count))
		end
		self.item_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
		self.item_icon:setVisible(true)

		local btn_res = string.format("item_box_%s.png", quality)
		self.item_bg:changeTexture(btn_res, UI_TEX_TYPE_PLIST)
		self.item_lock:setVisible(isLock)
	else
		self.item_selected:setVisible(false)
		self.item_lock:setVisible(false)
	end
end

ClsBackpackMainItem.changeSelectState = function(self, state)
	if self.is_selected ~= state then
		if not tolua.isnull(self.item_selected) then
			self.item_selected:setVisible(state)
		end
	end
	self.is_selected = state
end

ClsBackpackMainItem.canClick = function(self)
	return self.data ~= nil
end

---------------------------------------------------------------------------
local ClsBackpackMainCell = class("ClsBackpackMainCell", require("ui/view/clsScrollViewItem"))

ClsBackpackMainCell.initUI = function(self, cell_data)
	self.call_back = cell_data.call_back
	self.data = cell_data.data
	self.item_list = {}
	self.bounding_list = {}
	local item_width = self.m_width / col
	for i = 1, col do
		local item = ClsBackpackMainItem.new()
		item:mkUi(i, self.data[i])
		item:setPosition(ccp(item_width * (i - 1), 0))
		self:addChild(item)
		self.item_list[i] = item

		local item_size = CCSize(74, 73)
		local bounding_layer = display.newLayer()
		local width_dis = item_width - item_size.width
		local height_dis = self.m_height - item_size.height
		bounding_layer:setContentSize(CCSize(item_size.width, item_size.height))
		bounding_layer:setPosition(ccp(item_width * (i - 1)  + width_dis / 2, height_dis / 2))
		self:addCCNode(bounding_layer)
		self.bounding_list[i] = bounding_layer
	end

	ClsGuideMgr:tryGuide("ClsBackpackMainUI")
end

ClsBackpackMainCell.onTap = function(self, x, y)
	local pos = self:getWorldPosition()
	local node_pos = ccp(x - pos.x, y - pos.y)
	for k, button in pairs (self.bounding_list) do
		if button:boundingBox():containsPoint(node_pos) then
			local select_item = self.item_list[k]
			if select_item:canClick() then
				self.call_back(select_item)
			end
		end
	end
end

-----------------------------------背包界面----------------------------------------
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local ClsBackpackMainUI = class("ClsBackpackMainUI", ClsBaseView)


--页面参数配置方法，注意，是静态方法
ClsBackpackMainUI.getViewConfig = function(self)
	return {
		name = "ClsBackpackMainUI",       --(选填）默认 class的名字
		type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
		-- is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
		effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
		hide_before_view = true,
	}
end

ClsBackpackMainUI.onEnter = function(self, index, close_CB)
	--ClsDialogSequence:pauseQuene("ClsBackpackMainUI")
	self.goal_index = index
	self.close_CB = close_CB
	self.plist_tab = {
		["ui/backpack.plist"] = 1,
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/ship_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}
	LoadPlist(self.plist_tab)
	self.touch_enable = true

	self:initUI()
	self:initEvent()
	if not isExplore then
		self:init3D()
	end

	local partner_data = getGameData():getPartnerData()
	partner_data:askBagEquipInfo()

	self.cur_select_tab = nil
	self.cur_select_index = 1
end

ClsBackpackMainUI.initUI = function(self)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self.backpack_btn = {
		{name="tab_always", label = "text_always", type = BACKPACK_TAB_ALWAYS},
		{name="tab_ship", label = "text_ship", type = BACKPACK_TAB_BOAT},
		{name="tab_equip", label = "text_equip", type = BACKPACK_TAB_EQUIP},
		{name="tab_other", label = "text_other", type = BACKPACK_TAB_OTHER},
	}

	self.backpack_menu = {}
	for i, v in ipairs( self.backpack_btn ) do
		self.backpack_menu[i] = {}
		self.backpack_menu[i].btn = getConvertChildByName(self.panel, v.name)
		self.backpack_menu[i].label = getConvertChildByName(self.panel, v.label)
		self.backpack_menu[i].type = v.type
	end

	self.baowu_panel = getConvertChildByName(self.panel, "baowu_panel")
	self.baowu_icon_list = {}

	for i = 1, 3 do
		local temp = {}
		local obj_name = string.format("baowu_%d", i)
		local icon_name = string.format("baowu_icon_%d", i)
		local txt_name = string.format("baowu_type_txt%d", i)
		local baowu_name = string.format("baowu_name_%d", i)
		temp.star_list = {}
		for star_index=1, star_total do
			temp.star_list[star_index] = getConvertChildByName(self.panel, string.format("star_%d_%d", i, star_index))
		end

		temp.spr = getConvertChildByName(self.panel, obj_name)
		temp.icon = getConvertChildByName(self.panel, icon_name)
		temp.default = getConvertChildByName(self.panel, txt_name)
		temp.name = getConvertChildByName(self.panel, baowu_name)
		local icon_visible = temp.icon.setVisible
		temp.icon.setVisible = function(self, enable)
			icon_visible(self, enable)
			self:setTouchEnabled(enable)
		end
		temp.icon:setVisible(false)

		local default_visible = temp.default.setVisible
		temp.default.setVisible = function(self, enable)
			default_visible(self, enable)
			self:setTouchEnabled(enable)
		end
		temp.default:setVisible(true)

		temp.name:setText("")
		self.baowu_icon_list[i] = temp
	end

	self.ship_name_panel_1 = getConvertChildByName(self.panel, "ship_name_panel_1")
	self.ship_plus_1 = getConvertChildByName(self.panel, "ship_plus_1")
	self.ship_name_1 = getConvertChildByName(self.panel, "ship_name_1")

	self.ship_plus_1:setText("")
	self.ship_name_1:setText("")

	self.ship_name_panel_2 = getConvertChildByName(self.panel, "ship_name_panel_2")
	self.ship_name_2 = getConvertChildByName(self.panel, "ship_name_2")
	self.ship_plus_2 = getConvertChildByName(self.panel, "ship_plus_2")

	self.ship_name_2:setText("")
	self.ship_plus_2:setText("")

	self.power_num = getConvertChildByName(self.panel, "force_num")
	self.power_num:setText("0")

	self.role_pic = getConvertChildByName(self.panel, "role_pic")
	self.role_name = getConvertChildByName(self.panel, "role_name")
	self.role_bg = getConvertChildByName(self.panel, "role_bg")

	--船舶皮肤
	self.skin_box = getConvertChildByName(self.panel, "skin_box")
	self.skin_icon = getConvertChildByName(self.panel, "skin_icon")
	self.skin_time_num_1 = getConvertChildByName(self.panel, "skin_time_num_1")
	self.skin_time_num_2 = getConvertChildByName(self.panel, "skin_time_num_2")
	self.skin_txt = getConvertChildByName(self.panel, "skin_txt")


	self.role_pic:setVisible(false)
	self.role_name:setText("")

	self.ship_model = getConvertChildByName(self.panel, "ship_model")
	self.ship_water = getConvertChildByName(self.panel, "ship_water")
	self.ship_armature = getConvertChildByName(self.panel, "ship_armature")
	local pos = self.ship_armature:getPosition()
	self.ship_armature_pos = ccp(pos.x, pos.y)

	self.head_pic = getConvertChildByName(self.panel, "head_pic")
	self.head_bg = getConvertChildByName(self.panel, "head_bg")
	self.head_bg:setVisible(false)

	self.backpack_panel = getConvertChildByName(self.panel, "backpack_panel")
	self.backpcak_panel_pos = self.backpack_panel:getPosition()
	self.backpcak_panel_width = 350--右侧背包面板的宽度，锚点是右侧
	self.btn_join = getConvertChildByName(self.panel, "btn_join")
	self.btn_compose = getConvertChildByName(self.panel, "btn_compose")
	self.btn_dismantle = getConvertChildByName(self.panel, "btn_dismantle")
	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	if isExplore then
		self.btn_join:setVisible(false)
	end
	self.btn_join:setTouchEnabled(not isExplore)

	local voice_info = getLangVoiceInfo()
	audioExt.playEffect(voice_info.VOICE_SWITCH_1007.res)

	self.getTabObj = function ( condition )
		return self:getTab(condition)
	end
	self.getSailorBaowuObj = function(condition)
		return self:getsailorBaowu(condition)
	end
	self.getGuideObj = function(condition)
		return self:getGuideInfo(condition)
	end

	local onOffData = getGameData():getOnOffData()
	onOffData:pushOpenBtn(on_off_info.DISMANTLE.value, {openBtn = self.btn_dismantle, openEnable = true, 
		addLock = true, btnRes = "#common_btn_green1.png", parent = "ClsBackpackMainUI"})	
end

ClsBackpackMainUI.getTab = function(self, condition)
	local menu = self.backpack_menu[condition.aid]
	if(not menu)then return end
	return menu.btn
end

ClsBackpackMainUI.getsailorBaowu = function(self, condition)
	if not condition.aid and not self.baowu_icon_list[condition.aid] then return end
	return self.baowu_icon_list[condition.aid].spr
end

ClsBackpackMainUI.getGuideInfo = function(self, condition)
	if tolua.isnull(self.list_view) then return end

	local guide_layer = self.list_view:getInnerLayer()
	local addItemGuide = function(aim_obj)
		local aim_world_pos = aim_obj:convertToWorldSpace(ccp(0,0))
		local parent_pos = guide_layer:convertToWorldSpace(ccp(0,0))
		local guide_pos = {['x'] = aim_world_pos.x - parent_pos.x, ['y'] = aim_world_pos.y - parent_pos.y}
		return guide_layer, guide_pos, {['w'] = 72, ['h'] = 72}
	end

	local id_path = condition.type
	for k, cell in ipairs(self.cell_list) do
		local item_list = cell.item_list
		if(item_list)then
			for i=1,#item_list do
				local tmp = item_list[i]
				if(tmp and tmp.data)then
					if(condition.aid == 0)then--返回空格子
						return addItemGuide(tmp.item_bg)
					elseif tmp.data.data[id_path] == condition.aid then
						return addItemGuide(tmp.item_icon)
					end
				end
			end
		end
	end
end

ClsBackpackMainUI.setBoatDismantReward = function(self, boat_level, boat_quality, reward_tbl)
	for k,v in pairs(boat_fleet_config) do
		if v.level == boat_level then
			local rewards = v["quality_" .. boat_quality]
			for k,v in pairs(rewards) do
				if not reward_tbl[k] then
					reward_tbl[k] = v
				else
					reward_tbl[k] = reward_tbl[k] + v
				end
			end
			break
		end
	end
end

ClsBackpackMainUI.getAllDismantData = function(self)
	local temp = {}
	local reward_data = {}
	local dismantic_list = getGameData():getBagDataHandler():getDismantleList()
	for _, boat_key in ipairs(dismantic_list.boat) do
		local boat_base_data = getGameData():getShipData():getBoatDataByKey(boat_key)
		local boat_config = boat_attr[boat_base_data.id]
		self:setBoatDismantReward(boat_config.level, boat_base_data.quality, temp)
	end
	for _, baowu_key in ipairs(dismantic_list.baowu) do
		local baowu_data = getGameData():getBaowuData():getInfoById(baowu_key)
		if baowu_data then
			local baowu_info = baozang_info[baowu_data.baowuId]
			local baowu_dismantling_data = baowu_dismantling[baowu_info.star]
			local rewards = baowu_dismantling_data["baowu_quality_" .. baowu_data.color]
			for k,v in pairs(rewards) do
				if not temp[k] then
					temp[k] = v
				else
					temp[k] = temp[k] + v
				end
			end
		end
	end
	for item_id, amount in pairs(temp) do
		reward_data[#reward_data + 1] = {key = ITEM_INDEX_PROP, value = amount, id = item_id}
	end
	return reward_data
end

ClsBackpackMainUI.initEvent = function(self)
	for i = 1, #self.backpack_menu do
		self.backpack_menu[i].btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateTabSelected( i )
			if(i == 3)then
				require("framework.scheduler").performWithDelayGlobal(function()
					ClsGuideMgr:tryGuide("ClsBackpackMainUI")
				end,.3)
			end
		end,TOUCH_EVENT_ENDED)

		self.backpack_menu[i].btn:addEventListener(function()
			setUILabelColor(self.backpack_menu[i].label, ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		end,TOUCH_EVENT_BEGAN)

		self.backpack_menu[i].btn:addEventListener(function()
			setUILabelColor(self.backpack_menu[i].label, ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end,TOUCH_EVENT_CANCELED)
	end

	for i, v in ipairs(self.baowu_icon_list) do
		v.icon:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			getUIManager():create("gameobj/backpack/clsBaowuAttrTips", nil, "ClsBaowuAttrTips", {effect = false}, self.cur_select_index, v.data)
		end, TOUCH_EVENT_ENDED)

		v.default:addEventListener(function() 
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			ClsAlert:showJumpWindow(SAILOR_BAOWU_NOT_ENOUGH)
		end, TOUCH_EVENT_ENDED)
	end

	self.ship_model:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/backpack/clsBoatAttrTips", nil, "ClsBoatAttrTips", {effect = false}, self.cur_select_index)
	end,TOUCH_EVENT_ENDED)

	self.btn_join:setPressedActionEnabled(true)
	self.btn_join:addEventListener(function()
		self.btn_join:setTouchEnabled(false)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local partner_data = getGameData():getPartnerData()
		partner_data:askPartnerPrefetUpload(self.cur_select_index)
	end,TOUCH_EVENT_ENDED)

	self.btn_dismantle:setPressedActionEnabled(true)
	self.btn_dismantle:addEventListener(function()
		self:updatePerfetDismanticBack(false)
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local dismantic_list = getGameData():getBagDataHandler():getDismantleList()
		if (#dismantic_list.boat + #dismantic_list.baowu) == 0 then
			ClsAlert:warning({msg = ui_word.BACKPACK_NONE_DISMANTIC_TIPS, size = 26})
			self:updatePerfetDismanticBack(true)
			return
		end
		local all_dismantic_data = self:getAllDismantData()
		getUIManager():create("gameobj/backpack/clsBackpackDismantlyUI", nil, nil, all_dismantic_data, nil, true)
	end,TOUCH_EVENT_ENDED)

	self.btn_compose.last_time = 0
	self.btn_compose:setPressedActionEnabled(true)
	self.btn_compose:addEventListener(function()
		if CCTime:getmillistimeofCocos2d() - self.btn_compose.last_time < 1000 then
			return
		end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local bag_data_handler = getGameData():getBagDataHandler()
		local compose_list, total_cost = bag_data_handler:getComposeList()
		if #compose_list == 0 then
			ClsAlert:warning({msg = ui_word.BACKPACK_NONE_COMPOSE_TIPS, size = 26})
			return
		end
		local cost_not_enough = getGameData():getPlayerData():getCash() < total_cost
		ClsAlert:showCostDetailTips(ui_word.BACKPACK_COMPOSE_TIPS, nil, ITEM_INDEX_CASH, nil, total_cost, ui_word.BACKPACK_COMPOSE_DESC_TIPS, function()
			if cost_not_enough then
				ClsAlert:warning({msg = ui_word.BAOWU_BOAT_COMPOSE_GOLD_TIPS, size = 26})
				return
			end
			self.btn_compose.last_time = CCTime:getmillistimeofCocos2d()
			bag_data_handler:askOnekeyCompose(compose_list)
		end, {cost_not_enough = cost_not_enough})
	end,TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self.btn_close:setTouchEnabled(false)
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		if type(self.close_CB) == "function" then
			self.close_CB()
		end
		self:effectClose()
	end,TOUCH_EVENT_ENDED)

	self:regTouchEvent(self, function(eventType, x, y)
		if eventType == "began" then
			if not self.play_boat_effect then
				if not self.show_boat_state then
					if not tolua.isnull(self.ship_sprite) then
						if self.ship_touch_rect:containsPoint(ccp(x, y)) then
							self:showArmatureBoatEffect()
							return true
						end
					end
				else
					self:hideArmatureBoatEffect()
					return true
				end
			end
			return false
		end
	end)
	self:setViewTouchEnabled(true)
end

ClsBackpackMainUI.updateTabSelected = function(self, index)
	if not self.cur_bag_equip_info then
		return
	end
	self.cur_select_tab = index

	for i = 1, #self.backpack_menu do
		local select_state = index == i
		local backpack_tab = self.backpack_menu[i]
		local backpack_btn = backpack_tab.btn
		backpack_btn:setFocused( select_state )
		backpack_btn:setTouchEnabled( not select_state )
		local color = COLOR_TAB_UNSELECTED
		if select_state then
			color = COLOR_TAB_SELECTED
		end
		setUILabelColor(backpack_tab.label, ccc3(dexToColor3B(color)))
	end
	self.btn_compose:setVisible(index > 1)
	self.btn_dismantle:setVisible(index == 1)

	self:updateBackpackInfo(self.backpack_menu[index].type)
end

--3d init
ClsBackpackMainUI.init3D = function(self)
	self.layer_id = 1
	self.scene_id = SCENE_ID.BACKPACK

	local parent = CCNode:create()
	self.ship_water:addCCNode(parent)

	Main3d:createScene(self.scene_id)

	-- layer
	Game3d:createLayer(self.scene_id, self.layer_id, parent)
	self.layer3d = Game3d:getLayer3d(self.scene_id, self.layer_id)
	self.layer3d:setTranslation(CameraFollow:cocosToGameplayWorld(ccp(-340, -205)))
end

-- 显示3D船
ClsBackpackMainUI.showShip3D = function(self, boat_id)
	if boat_info[boat_id] == nil then return end

	self.boat_3d_model = nil
	self.layer3d:removeAllChildren()

	local path = SHIP_3D_PATH
	local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
	local Sprite3D = require("gameobj/sprite3d")
	local player_data = getGameData():getPlayerData()
	local item = {
		id = boat_id,
		key = boat_key,
		path = path,
		is_ship = true,
		node_name = node_name,
		ani_name = node_name,
		parent = self.layer3d,
		pos = {x = 0, y = 0, angle = -120},
		star_level = player_data:getShipEffects()
	}
	self.boat_3d_model = Sprite3D.new(item)
end

--动态变化3d船流光效果
ClsBackpackMainUI.updateShip3DEffect = function(self)
	if self.boat_3d_model then
		local player_data = getGameData():getPlayerData()
		self.boat_3d_model:updateStatus(player_data:getShipEffects())
	end
end

--海上探索专用，替换3D船
ClsBackpackMainUI.showArmatureBoat = function(self, boat_id)
	if not tolua.isnull(self.ship_show_sprite) then
		self.ship_show_sprite:removeFromParentAndCleanup(true)
	end
	local boat_config = ClsDataTools:getBoat(boat_id)
	self.ship_show_sprite = CCArmature:create(boat_config.effect)
	self.ship_show_sprite:getAnimation():playByIndex(0)
	self.ship_water:addCCNode(self.ship_show_sprite)
	local scale_num = 0.3
	self.ship_show_sprite:setScale(scale_num)
	self.ship_show_sprite:setScaleX(-1 * scale_num)
	-- self.ship_show_sprite:setRotation(345)
	self.ship_show_sprite:setPosition(boat_config.boatPos[1] - 15, boat_config.boatPos[2] + 55)
end

ClsBackpackMainUI.updateView = function(self)
	self:updateInfo()
	if self.cur_select_tab then
		self:refreshBackpackInfo()
	else
		self:updateTabSelected(self.goal_index or 1)
		self.role_pic:setVisible(true)
	end
end

--皮肤盒子
ClsBackpackMainUI.updateSkinBoxUI = function(self)
	local boat_key = self.cur_bag_equip_info.boatKey
	local ship_data = getGameData():getShipData()
	local partner_data = getGameData():getPartnerData()
	local skin_data = partner_data:getMainBoatSkin() --皮肤
	local boat = ship_data:getBoatDataByKey(boat_key)
	self.skin_box:setVisible(true)
	if skin_data then
		local item_info = require("game_config/propItem/item_info")
		local btn_res = string.format("item_box_%s.png", item_info[skin_data.item_id].quality)
		self.skin_box:changeTexture(btn_res, UI_TEX_TYPE_PLIST)
		self.skin_icon:setVisible(true)
		self.skin_txt:setVisible(false)
		
		local item_res = item_info[skin_data.item_id].res
		self.skin_icon:changeTexture(convertResources(item_res) , UI_TEX_TYPE_PLIST)
	else
		self.skin_icon:setVisible(false)
		self.skin_txt:setVisible(true)
	end
	self.skin_box:addEventListener(function()
		if skin_data then
			getUIManager():create("gameobj/backpack/clsBoatSkinTips", nil, "ClsBoatSkinTips", nil, 0, skin_data.item_id, boat_key, true)
		end
	end, TOUCH_EVENT_ENDED)
end

ClsBackpackMainUI.updateInfo = function(self)
	--数据有变动看看是否当前的索引

	local partner_data = getGameData():getPartnerData()
	self.cur_bag_equip_info = partner_data:getBagEquipInfo(self.cur_select_index)

	if self.res_armature then
		armature_manager:removeArmatureFileInfo(self.res_armature)
	end
	if not tolua.isnull(self.ship_sprite) then
		self.ship_sprite:removeFromParentAndCleanup(true)
	end

	-- self:hideArmatureBoatEffect()

	if self.cur_bag_equip_info then
		local player_data = getGameData():getPlayerData()
		local big_icon = role_info[player_data:getRoleId()].bigicon
		local icon = role_info[player_data:getRoleId()].res

		self.role_pic:changeTexture(big_icon, UI_TEX_TYPE_LOCAL)
		self.head_pic:changeTexture(icon, UI_TEX_TYPE_LOCAL)
		self.role_name:setText(player_data:getName())

		self.ship_plus_1:setText(string.format("+%s", self.cur_bag_equip_info.boatLevel))
		self.ship_plus_2:setText(string.format("+%s", self.cur_bag_equip_info.boatLevel))
		local color_type = math.floor(self.cur_bag_equip_info.boatLevel/10)+1
		setUILabelColor(self.ship_plus_1,QUALITY_COLOR_STROKE[color_type])
		setUILabelColor(self.ship_plus_2,QUALITY_COLOR_STROKE[color_type])
		self.power_num:setText(self.cur_bag_equip_info.power)

		local baowu_list = self.cur_bag_equip_info.partnerBaowu
		local baowu_data = getGameData():getBaowuData()
		for i = 1, #self.baowu_icon_list do
			local baowu_icon = self.baowu_icon_list[i]
			local baowu_equip_key = baowu_list[i]
			local baowu_len = string.len(baowu_equip_key)
			baowu_icon.icon:setVisible(baowu_len > 0)
			baowu_icon.default:setVisible(baowu_len == 0)
			baowu_icon.name:setText("")
			local quality = 1
			local baozang_config
			local refine_attr
			if baowu_equip_key and baowu_len > 0 then
				local baowu_item_data = baowu_data:getInfoById(baowu_equip_key)
				baozang_config = baozang_info[baowu_item_data.baowuId]
				baowu_icon.icon:changeTexture(convertResources(baozang_config.res) , UI_TEX_TYPE_PLIST)
				baowu_icon.data = baowu_item_data
				quality = baowu_item_data.color
				baowu_icon.name:setText(baozang_config.name)
				setUILabelColor(baowu_icon.name, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[quality])))

				for j,refine in ipairs(self.cur_bag_equip_info.refineAttr) do
					if refine and refine.index == i then
						refine_attr = refine.refine
					end
				end
			end
			local star_level = 0
			if refine_attr then
				star_level = ClsDataTools:calBaowuStarLevel(refine_attr, baozang_config)
			end
			for star_index = 1, star_total do
				local star_icon = baowu_icon.star_list[star_index]
				if star_level > (star_index - 1) * 2 then
					star_icon:setVisible(true)
					local star_res = "common_star3.png"
					if (star_level - (star_index * 2)) >= 0 then
						star_res = "common_star1.png"
					end
					star_icon:changeTexture(star_res, UI_TEX_TYPE_PLIST)
				else
					star_icon:setVisible(false)
				end
			end

			local item_bg_res = string.format("item_treasure_%s.png", quality)
			baowu_icon.spr:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)
		end

		local boat_key = self.cur_bag_equip_info.boatKey
		
		if boat_key ~= 0 then
			-- self.cur_bag_equip_info.skin
			local ship_data = getGameData():getShipData()
			local partner_data = getGameData():getPartnerData()
			local skin_data = partner_data:getMainBoatSkin() --皮肤
			local boat = ship_data:getBoatDataByKey(boat_key)
			local show_boat_id = boat.id
			local show_boat_name = boat.name
			local remain_time = 0

			if skin_data and skin_data.skin_enable == 1 then
				show_boat_id = skin_data.skin_id
				show_boat_name = skin_data.skin_name
				remain_time = skin_data.skin_end_time
			end
			self:updateSkinBoxUI()
			local boat_config = ClsDataTools:getBoat(show_boat_id)
			self.res_armature = string.format("armature/ship/%s/%s.ExportJson", boat_config.effect, boat_config.effect)
			armature_manager:addArmatureFileInfo(self.res_armature)
			self.ship_sprite = CCArmature:create(boat_config.effect)
			self.ship_sprite:getAnimation():playByIndex(0)
			self.ship_armature:addCCNode(self.ship_sprite)

			if isExplore then
				self:showArmatureBoat(show_boat_id)
			else
				self:showShip3D(show_boat_id)
			end

			local armature_bg_size = self.ship_armature:getContentSize()
			local height = self.ship_sprite:getContentSize().height
			local scale_num = 0.85
			self.ship_sprite:setScale(scale_num)
			self.ship_sprite:setScaleX(-1 * scale_num)
			-- self.ship_sprite:setOpacity(255 * 0.8)

			self.ship_sprite:setPosition(armature_bg_size.width * 0.5, armature_bg_size.height * 0.5 + boat_config.boatPos[2])

			self.ship_name_1:setText(show_boat_name)
			setUILabelColor(self.ship_name_1, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[boat.quality])))

			self.ship_name_2:setText(show_boat_name)
			setUILabelColor(self.ship_name_2, ccc3(dexToColor3B(QUALITY_COLOR_STROKE[boat.quality])))
			local width = self.ship_name_1:getContentSize().width + self.ship_name_2:getContentSize().width
			
			self:autoAdaptUIRight(remain_time)
			self:autoAdaptUIMid(remain_time)
			local ship_pos_x = self.ship_sprite:getPositionX()
			local ship_pos_y = self.ship_sprite:getPositionY()
			local pos_arm = self.ship_armature:convertToWorldSpace(ccp(ship_pos_x, ship_pos_y))
			local pos_w = self:convertToNodeSpace(pos_arm)
			local rect_size = self.ship_sprite:boundingBox()
			local ship_half_width = rect_size.size.width * scale_num * 0.42
			local ship_half_height = rect_size.size.height * scale_num * 0.42
			local width = self.backpcak_panel_pos.x - self.backpcak_panel_width - pos_w.x + ship_half_width
			self.ship_touch_rect = CCRect(pos_w.x - ship_half_width, pos_w.y - ship_half_height, width, rect_size.size.height * scale_num)
		end
		ClsGuideMgr:tryGuide("ClsBackpackMainUI")
	end
end
ClsBackpackMainUI.timeFarmat = function(self, remain_time)
	local show_time_str, time_tab = ClsDataTools:getCnTimeStr(remain_time)
	return show_time_str
end

-- 右下角名字UI对齐
ClsBackpackMainUI.autoAdaptUIRight = function(self, remain_time)
	if not remain_time or remain_time == 0 then
		self.skin_time_num_1:setVisible(false)
	else
		self.skin_time_num_1:setVisible(true)
		local show_time_str = self:timeFarmat(remain_time)
		local pos_x = self.ship_plus_1:getPosition().x + self.ship_plus_1:getContentSize().width
		self.skin_time_num_1:getPosition()
		self.skin_time_num_1:setAnchorPoint(ccp(1, 0.5))
		self.skin_time_num_1:setPosition(ccp(pos_x, self.skin_time_num_1:getPosition().y))
		self.skin_time_num_1:setText(ui_word.SKIN_END_TIME..show_time_str)
	end
	
end

--中间名字对齐
ClsBackpackMainUI.autoAdaptUIMid = function(self, remain_time)
	if not remain_time or remain_time == 0 then
		self.skin_time_num_2:setVisible(false)
	else
		self.skin_time_num_2:setVisible(true)
		local show_time_str = self:timeFarmat(remain_time)
		local pos_x = self.ship_plus_2:getPosition().x
		local name_width = self.ship_name_2:getContentSize().width
		local plus_width = self.ship_plus_2:getContentSize().width
		local mid_pos = (plus_width - name_width)/2 + pos_x
		self.skin_time_num_2:getPosition()
		self.skin_time_num_2:setAnchorPoint(ccp(0.5, 0.5))
		self.skin_time_num_2:setPosition(ccp(mid_pos -3, self.skin_time_num_1:getPosition().y))
		self.skin_time_num_2:setText(ui_word.SKIN_END_TIME..show_time_str)
	end
end

ClsBackpackMainUI.showArmatureBoatEffect = function(self)
	self:setTouch(false)
	self.show_boat_state = true
	self.play_boat_effect = true
	local effect_list = {}
	effect_list[#effect_list + 1] = {node = self.role_pic, effect = {type = PORT_EFFECT_FADEOUT,
			change = {0, 1}, delay = 0.4, action = {{0.3}}}
		}--玩家全身像
	effect_list[#effect_list + 1] = {node = self.role_bg, effect = {type = PORT_EFFECT_FADEOUT_ROTATE,
			change = {0, 1}, delay = 0.4, action = {{0.3, 250, true}}}
		}--玩家全身像底框

	effect_list[#effect_list + 1] = {node = self.baowu_icon_list[1].spr, effect = {type = PORT_EFFECT_FADEOUT_ZOOM,
			change = {1, 1}, delay = 0, action = {{0.17, 1.3, 1.3}, {0.13, 0, 0, true}}}
		}--第一个宝物格子
	effect_list[#effect_list + 1] = {node = self.baowu_icon_list[2].spr, effect = {type = PORT_EFFECT_FADEOUT_ZOOM,
			change = {1, 1}, delay = 0.17, action = {{0.17, 1.3, 1.3}, {0.13, 0, 0, true}}}
		}--第二个宝物格子
	effect_list[#effect_list + 1] = {node = self.baowu_icon_list[3].spr, effect = {type = PORT_EFFECT_FADEOUT_ZOOM,
			change = {1, 1}, delay = 0.34, action = {{0.17, 1.3, 1.3}, {0.13, 0, 0, true}}}
		}--第三个宝物格子

	effect_list[#effect_list + 1] = {node = self.ship_armature, effect = {type = PORT_EFFECT_EASEINOUT,
			change = {0, 0}, delay = 0.4, action = {{1.3, -226, -10}}}
		}--船容器
	effect_list[#effect_list + 1] = {node = self.ship_sprite, effect = {type = PORT_EFFECT_FADETO_ZOOM,
			change = 255 * 1, delay = 0.4, action = {{1.3, 255, {-0.9, 0.9}}}}
		}--船只透明度

	playNodeListEffect(effect_list, function()
		self.play_boat_effect = false
		self:setTouch(true)
		self.ship_name_panel_2:setVisible(true)
		self.head_bg:setVisible(true)
	end)
	self.skin_box:setVisible(false)
	self.ship_model:setVisible(false)
	self.ship_name_panel_1:setVisible(false)
	self.role_name:setVisible(false)
end

ClsBackpackMainUI.hideArmatureBoatEffect = function(self)
	self.play_boat_effect = true
	self.show_boat_state = false
	self:setTouch(false)

	local effect_list = {}
	effect_list[#effect_list + 1] = {node = self.role_pic, effect = {type = PORT_EFFECT_FADEIN,
			change = {0, 1}, delay = 0.7, action = {{0.3}}}
		}--玩家全身像
	effect_list[#effect_list + 1] = {node = self.role_bg, effect = {type = PORT_EFFECT_FADEIN_ROTATE,
			change = {0, 1}, delay = 0.6, action = {{0.4, 360, true}}}
		}--玩家全身像底框

	effect_list[#effect_list + 1] = {node = self.baowu_icon_list[1].spr, effect = {type = PORT_EFFECT_FADEIN_ZOOM,
			change = {0, 0}, delay = 0.4, action = {{0.17, 1.3, 1.3, true}, {0.13, 1, 1}}}
		}--第一个宝物格子
	effect_list[#effect_list + 1] = {node = self.baowu_icon_list[2].spr, effect = {type = PORT_EFFECT_FADEIN_ZOOM,
			change = {0, 0}, delay = 0.5, action = {{0.17, 1.3, 1.3, true}, {0.13, 1, 1}}}
		}--第二个宝物格子
	effect_list[#effect_list + 1] = {node = self.baowu_icon_list[3].spr, effect = {type = PORT_EFFECT_FADEIN_ZOOM,
			change = {0, 0}, delay = 0.6, action = {{0.17, 1.3, 1.3, true}, {0.13, 1, 1}}}
		}--第三个宝物格子

	effect_list[#effect_list + 1] = {node = self.ship_armature, effect = {type = PORT_EFFECT_EASEINOUT,
			change = {0, 0}, delay = 0, action = {{0.9, 226, 10}}}
		}--船容器
	effect_list[#effect_list + 1] = {node = self.ship_sprite, effect = {type = PORT_EFFECT_FADETO_ZOOM,
			change = 255, delay = 0, action = {{0.9, 255 * 1, {-0.85, 0.85}}}}
		}--船只透明度

	playNodeListEffect(effect_list, function()
		self.play_boat_effect = false
		self:setTouch(true)

		self.ship_model:setVisible(true)
		self.ship_name_panel_1:setVisible(true)
		self.role_name:setVisible(true)
		self.skin_box:setVisible(true)
	end)

	self.ship_name_panel_2:setVisible(false)
	self.head_bg:setVisible(false)
end

ClsBackpackMainUI.refreshBackpackInfo = function(self, prop_type)
	if prop_type and prop_type ~= BAG_PROP_TYPE_COMSUME then
		local PROP_TYPE_LIST = {
			[BAG_PROP_TYPE_FLEET] = {BACKPACK_TAB_ALWAYS, BACKPACK_TAB_BOAT},
			[BAG_PROP_TYPE_SAILOR_BAOWU] = {BACKPACK_TAB_ALWAYS, BACKPACK_TAB_EQUIP},
			[BAG_PROP_TYPE_BOAT_BAOWU] = {BACKPACK_TAB_BOAT},
			[BAG_PROP_TYPE_ASSEMB] = {BACKPACK_TAB_BOAT},
		}
		if PROP_TYPE_LIST[prop_type] then
			local need_refresh = nil
			for i,v in ipairs(PROP_TYPE_LIST[prop_type]) do
				if v == self.cur_select_tab then
					need_refresh = true
				end
			end
			if not need_refresh then
				return
			end
		end
	end
	if not self.cur_select_tab or not self.backpack_menu then
		return
	end
	self:updateBackpackInfo(self.backpack_menu[self.cur_select_tab].type)
end

ClsBackpackMainUI.updateBackpackInfo = function(self, type)
	if self.list_view ~= nil then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end

	local width = 308
	local height = 372
	local list_cell_size = CCSize(width, height / (row - 0.2))

	self.list_view = ClsScrollView.new(width, height, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(635, 69))
	self:addWidget(self.list_view)

	self.cell_list = {}
	self.select_backpack_item = nil

	local bag_data_hanlder = getGameData():getBagDataHandler()
	local data_list = bag_data_hanlder:getBackpackTabData(type, self.cur_select_index)

	-- print("====================updateBackpack=============list")
	-- table.print(data_list)

	local item_data_list = {}
	local item_count = 0
	for i, data in ipairs(data_list) do
		local list = data.list
		for k,v in pairs(list) do
			item_count = item_count + 1
			item_data_list[#item_data_list + 1] = v
		end
	end

	local item_max = math.max(item_count, col * row)
	local row_item_list = nil
	local cell_data = {}
	for i=1,item_max do
		local index = (i - 1) % col + 1
		if index == 1 then
			cell_data = {}
		end

		local item_data = item_data_list[i]
		cell_data[#cell_data + 1] = item_data

		if (i == item_max) or (i % col == 0) then
			local cell_spr = ClsBackpackMainCell.new(list_cell_size, {data = cell_data, index = math.ceil(i / col), call_back = function(item)
				self:selectItem(item)
			end})
			self.cell_list[#self.cell_list + 1] = cell_spr
		end
	end

	self.list_view:addCells(self.cell_list)
	--self.list_view:setZOrder(10086)

	self.list_len = #self.cell_list
	--self.list_view:setCurrentIndex(1)
	self.list_view:setTouch(self.touch_enable)

	self:setViewTouchEnabled(self.touch_enable)
end

ClsBackpackMainUI.selectItem = function(self, item)
	if self.touch_flag then return end
	self.touch_flag = true
	require("framework.scheduler").performWithDelayGlobal(function()
		self.touch_flag = false
	end, 0.55)

	if self.select_backpack_item then
		self.select_backpack_item:changeSelectState(false)
	end
	item:changeSelectState(true)
	self.select_backpack_item = item

	local select_type = item.data.type
	if select_type == BAG_PROP_TYPE_FLEET then
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		
		getUIManager():create("gameobj/backpack/clsBoatAttrTips", nil, "ClsBoatAttrTips", {effect = false}, self.cur_select_index, item.data.data.guid, true)
	elseif select_type == BAG_PROP_TYPE_SAILOR_BAOWU then
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/backpack/clsBaowuAttrTips", nil, "ClsBaowuAttrTips", {effect = false}, self.cur_select_index, item.data.data, true)
	elseif select_type == BAG_PROP_TYPE_BOAT_BAOWU then
		getUIManager():create("gameobj/backpack/clsBackpackBoatBaowuTips", nil, "ClsBackpackBoatBaowuTips", nil, item.data.data, self.cur_select_index)
	else--使用道具
		
		local boat_key = self.cur_bag_equip_info.boatKey
		if item.data.data.baseData.backpack_type == PROP_ITEM_BACKPACK_SKIN then
			getUIManager():create("gameobj/backpack/clsBoatSkinTips", nil, "ClsBoatSkinTips", nil, -1, item.data.data.id, boat_key)
			return
		end
		getUIManager():create("gameobj/backpack/clsBackpackItemTips", nil, "ClsBackpackItemTips", nil, select_type, item.data.data, nil, boat_key)
	end
end

ClsBackpackMainUI.updatePerfetUploadBack = function(self)
	self.btn_join:setTouchEnabled(true)
end

ClsBackpackMainUI.updatePerfetDismanticBack = function(self, bool)
	self.btn_dismantle:setTouchEnabled(bool)
	for k, v in pairs(self.backpack_menu) do
		if not tolua.isnull(v.btn) then
			v.btn:setTouchEnabled(bool)
		end
	end
end

ClsBackpackMainUI.closeView = function(self)
	self.btn_close:executeEvent(TOUCH_EVENT_ENDED)
end

ClsBackpackMainUI.setTouch = function(self, enable)
	self.touch_enable = enable
	if not tolua.isnull(self.list_view) then
		self.list_view:setTouch(enable)
	end
	self:setViewTouchEnabled(enable)
end

ClsBackpackMainUI.onExit = function(self)
	self.boat_3d_model = nil
	UnLoadPlist(self.plist_tab)
	ReleaseTexture(self)
	self.layer3d = nil
	Main3d:removeScene(self.scene_id)
	ClsDialogSequence:resumeQuene("ClsBackpackMainUI")
end

ClsBackpackMainUI.preClose = function(self)
	local item_tips = getUIManager():get("ClsBackpackItemTips")
	if not tolua.isnull(item_tips) then
		item_tips:close()
	end
end

return ClsBackpackMainUI

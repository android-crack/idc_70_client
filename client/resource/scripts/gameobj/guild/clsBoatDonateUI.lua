local ClsBaseView = require("ui/view/clsBaseView")
local cfg_music_info = require("game_config/music_info")
local cfg_boat_info = require("game_config/boat/boat_info")
local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")
local clsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")
local cfg_ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local cfg_port_info = require("game_config/port/port_info")
local port_battle_model = require("game_config/copyScene/port_battle_model")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")

local BOAT_ID = 18

local ClsNameListItem = class("ClsNameListItem", clsScrollViewItem)

ClsNameListItem.updateUI = function(self, data, cell)
	local need_widget_name = {
		lbl_player_name = "player_name",
		lbl_contribution_num = "contribution_num",
		spr_select = "list_selected",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(cell, v)
	end

	self.lbl_player_name:setText(data.name)
	self.lbl_contribution_num:setText(data.build)

	local player_uid = getGameData():getPlayerData():getUid()
	self.spr_select:setVisible(data.uid == player_uid)
end

local ClsBoatDonateUI = class("ClsBoatDonateUI", ClsBaseView)

ClsBoatDonateUI.getViewConfig = function(self)
	return {
		effect = UI_EFFECT.DOWN,
	}
end

local function setBtnStatus(btn, status)
	btn:setVisible(status)
	btn:setTouchEnabled(status)
end

ClsBoatDonateUI.onEnter = function(self)
	self.plistTab = {
		["ui/cityhall_ui.plist"] = 1,
	}
	LoadPlist(self.plistTab)
	self.donate_list_view = nil
	self.is_attack = nil
	self.is_show_3D = false
	self.port_battle_data = getGameData():getPortBattleData()
	self.port_list = self.port_battle_data:getPortList()
	self.port_index = 1
	self.port_id = self.port_list[self.port_index]
	self:askBaseData()
	self:mkUI()
	self:initUI()
	self:configEvent()
end

ClsBoatDonateUI.askBaseData = function(self)
	self.port_battle_data:askDonateInfo(self.port_id)
end

ClsBoatDonateUI.mkUI = function(self)
	local panel = createPanelByJson("json/portfight_build.json")
	self:addWidget(panel)

	local need_widget_name = {
		lbl_cost_num = "cost_num",
		btn_build = "btn_bulid",
		lbl_build_times = "build_num",
		lbl_donate_progress = "bar_num",
		pro_donate_progress = "bar",
		pal_ship = "ship_panel",
		lbl_ship_name = "ship_name",
		btn_build_hint = "build_hint",
		lbl_port = "build_port_name",
		btn_close = "btn_close",
		btn_left = "build_left_arrow",
		btn_right = "build_right_arrow",
	}

	for k,v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(panel, v)
	end

	local task_data = getGameData():getTaskData()
	local task_keys = {on_off_info.GRADUATE_BUILD_BUILDBUTTON.value}
	task_data:regTask(self.btn_build, task_keys, KIND_RECTANGLE, on_off_info.GRADUATE_BUILD_BUILDBUTTON.value, 50, 18, true)
end

ClsBoatDonateUI.initUI = function(self)
	self.lbl_cost_num:setVisible(false)
	self.lbl_build_times:setVisible(false)
	self.lbl_donate_progress:setVisible(false)
	self.pro_donate_progress:setPercent(0)
	self:init3D()

	setBtnStatus(self.btn_left, false)
	--只有一个候选港口
	if #self.port_list == 1 then
		setBtnStatus(self.btn_left, false)
		setBtnStatus(self.btn_right, false)
	end

	-- 进度条分割图标
	self.pro_donate_progress:removeAllChildren()
	self.split_sprites_table = {}
	local length = 548
	local start_length = math.floor(length*40/138) - 3
	local ruling_length = length - start_length
	local total_num = #port_battle_model
	local spacing = ruling_length/total_num
	local start_pos = - 0.5 * length + start_length

	for i = 0,total_num-1 do
		self.split_sprites_table[i] = display.newSprite("#cityhall_invest_mark.png")
		self.split_sprites_table[i]:setVisible(false)
		self.split_sprites_table[i]:setPositionX(i*spacing + start_pos)
		self.pro_donate_progress:addCCNode(self.split_sprites_table[i])
	end
end

ClsBoatDonateUI.configEvent = function(self)
	self.btn_build:setPressedActionEnabled(true)
	self.btn_build:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		local donate_cash = self.port_battle_data:getDonateCash()
		local player_data = getGameData():getPlayerData()
		if player_data:getCash() < donate_cash then
			ClsAlert:showJumpWindow(CASH_NOT_ENOUGH, self, {need_cash = donate_cash, come_type = ClsAlert:getOpenShopType().VIEW_3D_TYPE})
			return
		end
		self.port_battle_data:askDonate(self.port_id)
		getGameData():getTaskData():setTask(on_off_info.GRADUATE_BUILD_BUILDBUTTON.value, false)
	end, TOUCH_EVENT_ENDED)

	self.btn_build_hint:setPressedActionEnabled(true)
	self.btn_build_hint:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/guild/clsDonateExplainUI")
	end, TOUCH_EVENT_ENDED)

	self.btn_left:setPressedActionEnabled(true)
	self.btn_left:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		self.port_index = self.port_index - 1
		self:showtoggleBtn()
		if self.port_index == 1 then
			setBtnStatus(self.btn_left, false)
		end
		if self.port_index <= 0 then
			self.port_index = 1
			return
		end
		self.port_id = self.port_list[self.port_index]
		self:askBaseData()
	end, TOUCH_EVENT_ENDED)

	self.btn_right:setPressedActionEnabled(true)
	self.btn_right:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		self:showtoggleBtn()
		self.port_index = self.port_index + 1
		if self.port_index == #self.port_list then
			setBtnStatus(self.btn_right, false)
		end
		if self.port_index > #self.port_list then
			self.port_index = #self.port_list
			return
		end
		self.port_id = self.port_list[self.port_index]
		self:askBaseData()
	end, TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(cfg_music_info.COMMON_BUTTON.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	RegTrigger(CASH_UPDATE_EVENT, function()
		local target_ui = nil
		local is_exist = false
		target_ui = getUIManager():get("ClsBoatDonateUI")
		is_exist = not tolua.isnull(target_ui)
		if is_exist then
			target_ui:updateCash()
		end
	end)
end

ClsBoatDonateUI.showtoggleBtn = function(self)
	setBtnStatus(self.btn_left, true)
	setBtnStatus(self.btn_right, true)
end

ClsBoatDonateUI.updataUI = function(self, is_attack)
	if is_attack then
		self.is_attack = is_attack
	end

	local cur_donate_times, max_donate_times = self.port_battle_data:getCurAndMaxDonateTimes()
	self.lbl_build_times:setText(cur_donate_times .. "/" .. max_donate_times)
	self.lbl_build_times:setVisible(true)

	self.btn_build:active()
	if cur_donate_times >= max_donate_times then
		self.btn_build:disable()
	end

	local cur_donates, max_donates = self.port_battle_data:getCurAndMaxDonates()
	self.lbl_donate_progress:setText(cur_donates .. "/" .. max_donates)
	self.lbl_donate_progress:setVisible(true)
	local rate = cur_donates / max_donates
	self.pro_donate_progress:setPercent(rate * 100)
	if rate > 1 then
		self.pro_donate_progress:setPercent(100)
	end

	local donate_cash = self.port_battle_data:getDonateCash()
	self.lbl_cost_num:setText(donate_cash)
	self.lbl_cost_num:setVisible(true)

	local cash = getGameData():getPlayerData():getCash()
	local color = COLOR_YELLOW_STROKE
	if cash < donate_cash then
		color = COLOR_RED
	end
	setUILabelColor(self.lbl_cost_num, ccc3(dexToColor3B(color)))

	local donate_list = self.port_battle_data:getDonateList()
	if not tolua.isnull(self.donate_list_view) then
		self.donate_list_view:removeFromParent()
	end

	local cells = {}
	for k, v in ipairs(donate_list) do
		local cell = ClsNameListItem.new(CCSizeMake(215, 44), v)
		cells[#cells + 1] = cell
	end
	self.donate_list_view = ClsScrollView.new(230, 335, true, function()
		local cell_ui = createPanelByJson("json/portfight_build_rank.json")
		return cell_ui
	end, {is_fit_bottom = true})

	self.donate_list_view:setPosition(ccp(105, 57))
	self.donate_list_view:addCells(cells)
	self.donate_list_view:setTouch(true)
	self:addWidget(self.donate_list_view)

	-- if not self.is_show_3D then
		self:showModel3D(self.is_attack == 1, self:getCurRangeBoat(cur_donates))
	-- end

	for _, scale_node in pairs(self.split_sprites_table or {}) do
		if not tolua.isnull(scale_node) then
			scale_node:setVisible(false)
			if not (self.is_attack == 1) then
				scale_node:setVisible(true)
			end
		end
	end

	self.lbl_port:setText(cfg_port_info[self.port_id].name)
end

ClsBoatDonateUI.getCurRangeBoat = function(self, cur_built_val)
	local obj_index = nil
	for _, info in ipairs(port_battle_model) do
		if info.build >= cur_built_val then
			obj_index = tonumber(info.model)
			break
		end
	end
	if obj_index and ClsSceneConfig[obj_index] then
		local boat_id = ClsSceneConfig[obj_index].special_attr["boatId"]
		if boat_id then
			return boat_id
		end
	end
end

ClsBoatDonateUI.updateCash = function(self)
	local cash = getGameData():getPlayerData():getCash()
	local donate_cash = getGameData():getPortBattleData():getDonateCash()
	local color = COLOR_YELLOW_STROKE
	if cash < donate_cash then
		color = COLOR_RED_STROKE
	end
	setUILabelColor(self.lbl_cost_num, ccc3(dexToColor3B(color)))
end

--3d init
ClsBoatDonateUI.init3D = function(self)
	self.layer_id = 1
	self.scene_id = SCENE_ID.BOAT_DONATE

	local parent = CCNode:create()
	self.pal_ship:addCCNode(parent)

	Main3d:createScene(self.scene_id)

	-- layer
	Game3d:createLayer(self.scene_id, self.layer_id, parent)
	self.layer3d = Game3d:getLayer3d(self.scene_id, self.layer_id)
	self.layer3d:setTranslation(CameraFollow:cocosToGameplayWorld(ccp(180, -90)))
end

-- 显示3D模型
ClsBoatDonateUI.showModel3D = function(self, is_attack, boat_id)
	self.is_show_3D = true
	local Sprite3D = require("gameobj/sprite3d")
	self.layer3d:removeAllChildren()
	self.layer3d:setScale(1)
	
	if is_attack then --没有船id，默认显示雕像模型
		self.lbl_ship_name:setText(cfg_ui_word.STR_SCULPTURE_NAME)
		local path = MODEL_3D_PATH
		local item = {
			id = boat_id,
			star_level = 0,
			is_ship = false,
			path = path,
			node_name = "ex_piller",
			ani_name = "ex_piller",
			parent = self.layer3d,
			pos = {x = -62, y = 28, angle = 325}
		}
		Sprite3D.new(item)
		return
	end
	if cfg_boat_info[boat_id] == nil then return end
	self.lbl_ship_name:setText(cfg_ui_word.STR_WARSHIP_NAME)
	local path = SHIP_3D_PATH
	local node_name = string.format("boat%.2d", cfg_boat_info[boat_id].res_3d_id)
	local item = {
		id = boat_id,
		key = boat_key,
		path = path,
		is_ship = true,
		node_name = node_name,
		ani_name = node_name,
		parent = self.layer3d,
		pos = {x = -25, y = 0, angle = 105}
	}
	self.layer3d:setScale(1.7)
	Sprite3D.new(item)
end

ClsBoatDonateUI.onExit = function(self)
	self.layer3d = nil
	UnLoadPlist(self.plistTab)
	Main3d:removeScene(self.scene_id)
	UnRegTrigger(CASH_UPDATE_EVENT)
end

return ClsBoatDonateUI

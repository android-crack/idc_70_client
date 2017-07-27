-- 副本层UI
local math_abs = math.abs
local UI_WORD = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
local ClsCompositeEffect = require("gameobj/composite_effect")
local on_off_info = require("game_config/on_off_info")

local ClsCopySceneUI = class("ClsCopySceneUI", ClsBaseView)

ClsCopySceneUI.getViewConfig = function(self)
	return {is_swallow = false}
end

ClsCopySceneUI.onEnter = function(self)
	ClsDialogSequence:resumeQuene("LoginLayer")
	ClsDialogSequence:resumeQuene("battle_scene")
	self.is_enabled = true
	self.small_map_objs = {}
	self.small_map_self_point_spr = nil
	self.scale_rate = nil
	self.tips_tab = {}
	self.tips_layer = nil
	self.m_is_show_eye = true
	self.m_is_show_btns = true

	self.armature = {
		"effects/tx_0126.ExportJson", --仓库
		"effects/tx_0187.ExportJson", --组队
		"effects/tx_0196.ExportJson", --技能
		"effects/tx_0131.ExportJson", --伙伴
		"effects/tx_explore_qte.ExportJson" --qte特效
	}
	LoadArmature(self.armature)

	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	self.map_id = ClsSceneManage:getMapId()
	self.scene_type = ClsSceneManage:getSceneTypeMap()
	self:createUiItem()
	self.is_error = false --是否网络错误
	self.is_drop = false  --是否在抛锚状态
	self:showTipsUI() --尝试去显示场景公告
end

ClsCopySceneUI.touchEndLogic = function(self)
end

ClsCopySceneUI.getJsonUi = function(self)
	return self.m_explore_sea_ui
end

ClsCopySceneUI.setSceneLayer = function(self, layer)
	--子类重写
	self.scene_layer = layer
end

ClsCopySceneUI.onExit = function(self)
	--子类重写
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("onExit")
	UnLoadArmature(self.armature)

	local copy_scene_data = getGameData():getCopySceneData()
	copy_scene_data:clearData()
	local guild_fight_data = getGameData():getGuildFightData()
	guild_fight_data:clearData()
end

ClsCopySceneUI.createJsonUi = function(self)
	local explore_sea_ui = GUIReader:shareReader():widgetFromJsonFile("json/explore_copy.json")
	self.m_explore_sea_ui = explore_sea_ui
	self:addWidget(explore_sea_ui)
	local ignore_config = {
		"food_bar_bg",
		"food_icon",
		"food_num",
	}
	for _, v in pairs(ignore_config) do
		local item_ui = getConvertChildByName(explore_sea_ui, v)
		item_ui:setEnabled(false)
	end

	self.m_food_lab = getConvertChildByName(explore_sea_ui, "food_num")
	self.m_food_bar = getConvertChildByName(explore_sea_ui, "food_bar")
	self.m_back_btn = getConvertChildByName(explore_sea_ui, "btn_back")
	self.m_map_bg_spr = getConvertChildByName(explore_sea_ui, "map_bg")
	self.time_label = getConvertChildByName(self.m_map_bg_spr, "time_num")
	self.time_bg = getConvertChildByName(self.m_map_bg_spr, "time_bg")
	self.time_bg:setVisible(false)
	self.hide_eye_btn = getConvertChildByName(explore_sea_ui, "btn_hidden_ui")
	self.port_icon_panel = getConvertChildByName(explore_sea_ui, "port_icon")

	self.portfight_head = getConvertChildByName(explore_sea_ui, "portfight_head")
	self.stronghold_head = getConvertChildByName(explore_sea_ui, "stronghold_head")

	self.time_label:setText(" ")

	self.m_food_lab:setText("0/0")

	self.m_back_btn:setPressedActionEnabled(true)
	self.m_back_btn:addEventListener(function()
		if self.show_big_chat then
			return
		end

		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
		local str_tips = ClsSceneManage:doLogic("getExitTips")
		Alert:showAttention(str_tips, function()
			ClsSceneManage:sendExitSceneMessage()
		end, nil, nil, {hide_cancel_btn = true})
	end, TOUCH_EVENT_ENDED)

	local back_text_lab = getConvertChildByName(self.m_back_btn, "btn_back_text")
	back_text_lab:setText(UI_WORD.EXPLORE_EVENT_OUT_TIPS)

	self.hide_eye_btn:setPressedActionEnabled(true)
	self.hide_eye_btn:addEventListener(function()
		self:hideOrShowEyeBtn()
	end, TOUCH_EVENT_ENDED)

	self.btn_config = {
		[1] = {name = "btn_rank"},
		[2] = {name = "btn_staff", on_off_key = on_off_info.FOMATION_USE.value},
		[3] = {name = "btn_skill", on_off_key = on_off_info.SKILL_SYSTEM.value},
		[4] = {name = "btn_backpack", on_off_key = on_off_info.TREASURE_WAREHOUSE.value},
		[5] = {name = "btn_back"},
	}
	self:bindBtnsConfig()
end

ClsCopySceneUI.bindBtnsConfig = function(self)
	local onOffData = getGameData():getOnOffData()

	self.port_icon_btns = {}
	for k, v in ipairs(self.btn_config) do
		local btn = getConvertChildByName(self.m_explore_sea_ui, v.name)
		btn:setPressedActionEnabled(true)
		local pos = ccp(btn:getPosition().x, btn:getPosition().y)
		local end_pos = ccp(pos.x + 80, pos.y)

		local not_open = false
		if v.on_off_key then
			not_open = not onOffData:isOpen(v.on_off_key)
		end

		local tb = {name = v.name, start_pos = pos, end_pos = end_pos, not_open = not_open, btn = btn}

		self.port_icon_btns[#self.port_icon_btns + 1] = tb
	end

end

ClsCopySceneUI.createUiItem = function(self)
	self:createJsonUi()
	--子类重写,不同场景ui不同
end

ClsCopySceneUI.showStartOrEndIconTips = function(self, is_start)
	if tolua.isnull(self.m_explore_sea_ui) then
		return
	end
	local offset_y = 0
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local map_id = ClsSceneManage:getMapId()
	local copy_scene_type = ClsSceneManage:getSceneTypeMap()
	if map_id == copy_scene_type.TREASURE then
		offset_y = -40
	end
	--添加探索开始图标
	local pos_y = display.top - 80 + offset_y
	local start_pic = getConvertChildByName(self.m_explore_sea_ui, "start_pic")

	if is_start then
		local start_text_lab = getConvertChildByName(start_pic, "start_text")
		start_text_lab:setVisible(true)
	else
		local end_text_lab = getConvertChildByName(start_pic, "end_text")
		end_text_lab:setVisible(true)
	end
	start_pic:setPosition(ccp(display.cx, pos_y))
	start_pic:setVisible(true)
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(3))
	array:addObject(CCFadeOut:create(0.3))
	array:addObject(CCCallFunc:create(function()
		start_pic:setVisible(false)
	end))
	start_pic:runAction(CCSequence:create(array))
end

ClsCopySceneUI.updateSmallMapUi = function(self, player_pos, others_pos)
	if not self.scene_layer then
		return
	end

	if not self.scale_rate then
		self.scale_rate = {}
		local map_size = self.m_map_bg_spr:getSize()
		local top_offset = 32
		local bottom_offset = 10
		local hor_offset = 10
		local true_width = map_size.width - hor_offset*2
		local true_height = map_size.height - top_offset - bottom_offset
		local land_width = self.scene_layer.land:getLandWidth()
		local land_height = self.scene_layer.land:getLandHeight()
		local block_width = self.scene_layer.land:getBlockWidth()
		local block_height = self.scene_layer.land:getBlockHeight()
		self.scale_rate.scale_x = true_width/(land_width - block_width*2)
		self.scale_rate.scale_y = true_height/(land_height - block_height*2)
		self.scale_rate.orgin_x = hor_offset - map_size.width/2
		self.scale_rate.orgin_y = bottom_offset - map_size.height/2
		self.scale_rate.cut_x = block_width
		self.scale_rate.cut_y = block_height
		self.small_map_self_point_spr = display.newSprite("#battle_radar_mine.png")
		self.small_map_self_point_spr:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
		self.m_map_bg_spr:addCCNode(self.small_map_self_point_spr)
		self.m_map_bg_spr:setVisible(true)
	end
	--初始化要删除的标记
	for k, v in pairs(self.small_map_objs) do
		v.is_show = nil
	end
	--更新位置
	self.small_map_self_point_spr:setPosition(ccp(self.scale_rate.orgin_x + (player_pos.x - self.scale_rate.cut_x)*self.scale_rate.scale_x, self.scale_rate.orgin_y + (player_pos.y - self.scale_rate.cut_y)*self.scale_rate.scale_y))
	for k, v in pairs(others_pos) do
		local map_point = self:getMapPoint(v)
		map_point:setPosition(ccp(self.scale_rate.orgin_x + (v.x - self.scale_rate.cut_x)*self.scale_rate.scale_x, self.scale_rate.orgin_y + (v.y - self.scale_rate.cut_y)*self.scale_rate.scale_y))
		map_point.is_show = true
	end
	--删除多余的东东
	for k, v in pairs(self.small_map_objs) do
		if not v.is_show then
			v:removeFromParentAndCleanup(true)
			self.small_map_objs[k] = nil
		end
	end
end

ClsCopySceneUI.getMapPoint = function(self, point_info)
	local id = point_info.id
	local map_point = self.small_map_objs[id]
	if map_point then
		return map_point
	end
	local pic_str = "#battle_radar_enemy.png"
	if point_info.is_player then
		pic_str = "#battle_radar_friend.png"
	elseif point_info.is_wreck or point_info.is_melee_red then
		pic_str = "#common_point.png"
	end
	map_point = display.newSprite(pic_str)
	map_point:setAnchorPoint(display.ANCHOR_POINTS[display.CENTER])
	self.m_map_bg_spr:addCCNode(map_point)
	self.small_map_objs[id] = map_point
	return map_point
end

ClsCopySceneUI.showTipsUI = function(self)
	local copy_scene_data = getGameData():getCopySceneData()
	local params = copy_scene_data:getTips()[1]
	if not params then
		return
	end
	if self.is_error or tolua.isnull(self.m_explore_sea_ui) then
		return
	end

	copy_scene_data:clearTips()
	local explore_info = params.explore_info --可选
	local show_time = params.show_time or 4 --可选
	local offset_x = 0
	local offset_y = 0

	if self.map_id == self.scene_type.TREASURE then
		offset_y = -40
	end

	if self.map_id == self.scene_type.GUILD_BATTLE or self.map_id == self.scene_type.PORT_BATTLE then
		offset_y = -20
	end

	self.tips_layer = getConvertChildByName(self.m_explore_sea_ui,"salvage_tips")
	self.tips_layer:stopAllActions()
	self.tips_layer:setPosition(ccp(display.cx, display.top - 80 + offset_y))
	self.tips_layer:setVisible(true)

	local salvage_tips_text = getConvertChildByName(self.tips_layer,"salvage_tips_text")
	salvage_tips_text:setVisible(true)
	if not tolua.isnull(salvage_tips_text.rich_label) then
		salvage_tips_text.rich_label:removeFromParentAndCleanup(true)
	end
	local rich_label_tag = string.find(explore_info, "$%(c:", 0)
	if rich_label_tag then
		salvage_tips_text.rich_label = createRichLabel(explore_info, 320, 30, 16, 4)
		salvage_tips_text:setText("")
		salvage_tips_text:addCCNode(salvage_tips_text.rich_label)
		salvage_tips_text.rich_label:setPosition(ccp(-salvage_tips_text.rich_label:getContentSize().width/2, -salvage_tips_text.rich_label:getContentSize().height/2))
	else
		salvage_tips_text:setText(explore_info)
	end

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(show_time))
	array:addObject(CCCallFunc:create(function()
		self:removeTipLayer()
	end))
	self.tips_layer:runAction(CCSequence:create(array))
end

ClsCopySceneUI.showFightEffect = function(self)
	ClsCompositeEffect.new("tx_0058", display.cx, display.cy, self)
end

-- 设置UI是否可点击
ClsCopySceneUI.setEnabledUI = function(self, is_enabled)
	self.is_enabled = is_enabled
	self:callComponent("chat_ui", "setTouch", is_enabled)
	self:callComponent("team_mission_ui", "setTouch", is_enabled)
end

ClsCopySceneUI.getBtnExit = function(self)
	return self.m_back_btn
end

ClsCopySceneUI.isEnabledUI = function(self)
	return self.is_enabled
end

ClsCopySceneUI.isCanTeamInvite = function(self)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	return ClsSceneManage:doLogic("isCanTeamInvite")
end

ClsCopySceneUI.removeTipLayer = function(self)
	if self.tips_layer then
		self.tips_layer:setVisible(false)
		self.tips_layer:stopAllActions()
	end
end

ClsCopySceneUI.setIsError = function(self, is_error)
	self.is_error = is_error
end

ClsCopySceneUI.setEnableEyeBtn = function(self, enable)
	self.hide_eye_btn:setTouchEnabled(enable)
	self.hide_eye_btn:setVisible(enable)
end

ClsCopySceneUI.hideOrShowEyeBtn = function(self)
	local is_show = not self.m_is_show_eye
	if is_show then
		self.hide_eye_btn:changeTexture("explore_hidden_1.png", "explore_hidden_2.png", "explore_hidden_2.png", UI_TEX_TYPE_PLIST)
	else
		self.hide_eye_btn:changeTexture("explore_hidden_2.png", "explore_hidden_1.png", "explore_hidden_1.png", UI_TEX_TYPE_PLIST)
	end
	self:setIsShowDetailUI(is_show)
end

ClsCopySceneUI.setIsShowDetailUI = function(self, is_show)
	if self.m_is_show_eye == is_show then return end
	self.m_is_show_eye = is_show
	local mission_ui = getUIManager():get("ClsTeamMissionPortUI")
	if not tolua.isnull(mission_ui) then
		mission_ui:setIsShowPanel(self.m_is_show_eye)
	end
	local chat_component = getUIManager():get("ClsChatComponent")
	if not tolua.isnull(chat_component) then
		chat_component:setIsShow(self.m_is_show_eye)
	end
	self:setIsShowBottons(is_show)

	local offset_y = is_show and - 80 or 80
	self.portfight_head:runAction(CCMoveBy:create(0.1, ccp(0, offset_y)))
	self.stronghold_head:runAction(CCMoveBy:create(0.1, ccp(0, offset_y)))
end

ClsCopySceneUI.setIsShowBottons = function(self, is_show)
	if self.m_is_show_btns == is_show then return end
	self.m_is_show_btns = is_show

	if not is_show then
		self.port_icon_panel:setEnabled(false)
		self.port_icon_panel:stopAllActions()
		for k, v in ipairs(self.port_icon_btns) do
			if not v.not_open then
				v.btn:setVisible(false)
				v.btn:setPosition(v.end_pos)
			end
		end
		return
	end

	local move_time = 0.1
	local array = CCArray:create()
	for k, v in ipairs(self.port_icon_btns) do
		v.btn:stopAllActions()
		v.btn:setVisible(false)
		v.btn:setTouchEnabled(false)
		array:addObject(CCCallFunc:create(function()
				v.btn:setVisible(not v.not_open)
				v.btn:setTouchEnabled(not v.not_open)
				v.btn:runAction(CCMoveTo:create(move_time, v.start_pos))
			end))
		array:addObject(CCDelayTime:create(move_time))
	end
	array:addObject(CCCallFunc:create(function() 
		for k, v in ipairs(self.port_icon_btns) do
			v.btn:setTouchEnabled(true)
		end
	end))
	self.port_icon_panel:setEnabled(true)
	self.port_icon_panel:stopAllActions()
	self.port_icon_panel:runAction(CCSequence:create(array))
end

ClsCopySceneUI.setIsShowHintBtn = function(self, is_show)
	table.insert(self.btn_config, {name = "btn_hint"})
	self:bindBtnsConfig()

	if not self.m_explore_sea_ui then return end
	local btn = getConvertChildByName(self.m_explore_sea_ui, "btn_hint")
	btn:setVisible(is_show)
	btn:setTouchEnabled(is_show)
	btn:setPressedActionEnabled(true)
	btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
		ClsSceneManage:doLogic("createRuleUI")
	end, TOUCH_EVENT_ENDED)
end

ClsCopySceneUI.setIsShowSoloBtn = function(self, is_show)
	table.insert(self.btn_config, {name = "btn_solo"})
	self:bindBtnsConfig()

	if not self.m_explore_sea_ui then return end
	local btn = getConvertChildByName(self.m_explore_sea_ui, "btn_solo")
	btn:setVisible(is_show)
	btn:setTouchEnabled(is_show)
	btn:setPressedActionEnabled(true)
	btn:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
		ClsSceneManage:doLogic("createSoloUI")
	end, TOUCH_EVENT_ENDED)
end


ClsCopySceneUI.setIsShowStopBtn = function(self, is_show)
	table.insert(self.btn_config, {name = "btn_stop"})
	self:bindBtnsConfig()
	if not self.m_explore_sea_ui then return end
	self.btn_stop = getConvertChildByName(self.m_explore_sea_ui, "btn_stop")
	self.btn_stop.stop_tip_spr = getConvertChildByName(self.btn_stop, "btn_stop_ban")
	self.btn_stop:setVisible(is_show)
	self.btn_stop:setTouchEnabled(is_show)
	self.btn_stop:setPressedActionEnabled(true)
	self.btn_stop:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:setIsDropAnchor(not self.is_drop)
	end, TOUCH_EVENT_ENDED)
end

ClsCopySceneUI.playAudio = function(self, audioParam)
	local voice_res_key = audioParam.f--
	if self.m_is_man then
		voice_res_key = audioParam.m--
	end
	local voice_info = getLangVoiceInfo()
	local voiceRes = voice_info[voice_res_key].res

	if self.m_cur_voice_hander then
		if audioExt.isPlayEffect(self.m_cur_voice_hander) then
			self.m_cur_voice_hander = nil
			return
		end
	end
	self.m_cur_voice_hander = audioExt.playEffectOneTime(voice_res_key, voiceRes)
end

ClsCopySceneUI.setIsDropAnchor = function(self, is_drop)
	if self.is_drop == is_drop then return end
	self.is_drop = is_drop
	
	self.btn_stop.stop_tip_spr:setVisible(is_drop)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local copy_scene_layer = ClsSceneManage:getSceneLayer()
	if not tolua.isnull(copy_scene_layer) then 
		local copy_scene_land = copy_scene_layer:getLand()
		if not tolua.isnull(copy_scene_land) then
			if is_drop then
				self:playAudio({f = "VOICE_EXPLORE_1020", m = "VOICE_EXPLORE_1000"})
				copy_scene_land:showDropAnchorTips(nil)
			else
				copy_scene_land:showDropAnchorTips(true)
			end
			copy_scene_layer:getShipsLayer():setIsDroping(is_drop)
		end
	end
end

return ClsCopySceneUI

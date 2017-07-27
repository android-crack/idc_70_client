--
-- Author: lzg0496
-- Date: 2016-07-05 17:00:22
-- Function: 爵位系统UI

local cls_music_info = require("game_config/music_info")
local cls_ui_common = require("ui/tools/UiCommon")
local cls_ui_word = require("game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local cls_alert = require("ui/tools/alert")
local uiTools = require("gameobj/uiTools")
local on_off_info=require("game_config/on_off_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local boat_attr = require("game_config/boat/boat_attr")
local voice_info = getLangVoiceInfo()
local ClsBaseView = require("ui/view/clsBaseView")
local ClsDialogSequene = require("gameobj/quene/clsDialogQuene")
local ClsNobilityUpEffect = require("gameobj/quene/clsNobilityUpEffect")
local ClsDataTools = require("module/dataHandle/dataTools")
local battle_jy_info = require("game_config/battle/battle_jy_info")

local clsNobilityUI = class("clsNobilityUI", ClsBaseView)

local REDUCE_RATE = 0.1

function clsNobilityUI:onEnter()

	self.plist = {
	}
	LoadPlist(self.plist)

	getGameData():getNobilityData():sendSyncNobilityInfo()

	----声望
	self.start_power = getGameData():getPlayerData():getBattlePower()

	--print("============================升级qian的声望",self.start_power)

    self:mkUI()
    self:initUI()
	self:configEvent()
end

function clsNobilityUI:getViewConfig()
	return {
		effect = UI_EFFECT.DOWN,
		is_back_bg = true
	}
	
end

function clsNobilityUI:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_title.json")
	self:addWidget(self.panel)

	local need_widget_name = {
		spr_cur_nobility = "icon_left",
		lbl_cur_nobility = "icon_level_left",
		spr_next_nobility = "icon_left_0",
		lbl_next_nobility = "icon_level_left_0",
		lbl_cur_melee = "near_num",
		lbl_cur_remote = "gun_num",
		lbl_cur_durable = "long_num",
		lbl_cur_defense = "defense_num",
		lbl_cur_reduce = "reduce_num",
		-- lbl_cur_set = "set_num",
		lbl_next_melee = "near_num_r",
		lbl_next_melee_txt = "near_text_r", 
		lbl_next_remote = "gun_num_r",
		lbl_next_remote_txt = "gun_text_r", 
		lbl_next_durable = "long_num_r",
		lbl_next_durable_txt = "long_text_r", 
		lbl_next_defense = "defense_num_r",
		lbl_next_defense_txt = "defense_text_r", 
		lbl_next_reduce = "reduce_num_r",
		lbl_next_reduce_txt = "reduce_text_r",
		-- lbl_next_set = "set_num_r",
		-- lbl_next_set_txt = "set_text_r",
		lbl_exp = "bar_text",
		pro_exp = "bar",
		btn_upstep = "btn_up",
		lbl_btn_up_text = "btn_up_text",
		btn_close = "btn_close",
		lbl_arrow_melee = "arrow_1",
		lbl_arrow_remote = "arrow_2",
		lbl_arrow_durable = "arrow_3",
		lbl_arrow_defense = "arrow_4",
		lbl_arrow_reduce = "arrow_5",
		-- lbl_arrow_set = "arrow_6",
		lbl_cur_boat = "boat_build_info",
		lbl_next_boat = "boat_build_info_r",
		lbl_next_boat_set = "boat_build_text_r",
		lbl_elite_txt = "txt_elite",
	}

	for k, v in pairs(need_widget_name) do
		self[k] = getConvertChildByName(self.panel, v)
	end

	local taskData = getGameData():getTaskData()
    local task_keys = {
        on_off_info.PEERAGES.value,
    }
    self.btn_upstep.task_keys = task_keys
    taskData:regTask(self.btn_upstep, task_keys, KIND_RECTANGLE, on_off_info.PEERAGES_UP.value, 62, 17, true)
    ClsGuideMgr:tryGuide("clsNobilityUI")
	local voice_info = getLangVoiceInfo()
    audioExt.playEffect(voice_info.VOICE_SWITCH_1003.res)
end

function clsNobilityUI:initUI()
	self.nobility_data = getGameData():getNobilityData()
	self.nobility_exp = getGameData():getPlayerData():getBattlePower()
	self.nobility_id = self.nobility_data:getNobilityID()

	self.elite_id = self.nobility_data:getEliteID()

	self.chapter_id = self.elite_id

	local cur_nobility_data = self.nobility_data:getNobilityDataByID(self.nobility_id)
	self.elite_limit_level = cur_nobility_data.elite_limit_level

	if self.elite_limit_level < 1 then
		self.lbl_elite_txt:setVisible(false)
	end
	self.lbl_elite_txt:setText( string.format(cls_ui_word.PORT_NOBILITY_ELITE_TAB,self.elite_limit_level))


	if self.chapter_id <= self.elite_limit_level then
		setUILabelColor(self.lbl_elite_txt, ccc3(dexToColor3B(COLOR_RED)))
	end

	self.spr_cur_nobility:changeTexture(cur_nobility_data.icon, UI_TEX_TYPE_PLIST)
	self.lbl_cur_nobility:setText(cur_nobility_data.title)
	self.lbl_cur_nobility:setUILabelColor(cur_nobility_data.level_color)
	self.lbl_cur_melee:setText(cur_nobility_data.melee)
	self.lbl_cur_remote:setText(cur_nobility_data.remote)
	self.lbl_cur_durable:setText(cur_nobility_data.durable)
	self.lbl_cur_defense:setText(cur_nobility_data.defense)
	self.lbl_cur_reduce:setText(cur_nobility_data.reduce * REDUCE_RATE .. "%")
	-- self.lbl_cur_set:setText(cur_nobility_data.invest_sailor_amount)

	local player_data = getGameData():getPlayerData()
	local boat_id = cur_nobility_data.boat_ids[player_data:getProfession()]
	local boat_config = ClsDataTools:getBoat(boat_id)
	self.lbl_cur_boat:setText(boat_config.name)
	if self.nobility_data:isFullLevel() then
		self.lbl_exp:setText(cls_ui_word.PORT_FULL_NOBILITY)
		self.btn_upstep:disable()
		self.pro_exp:setPercent(100)

		self.spr_next_nobility:setVisible(false)
		self.lbl_next_nobility:setVisible(false)
		self.lbl_next_melee:setVisible(false)
		self.lbl_next_remote:setVisible(false)
		self.lbl_next_durable:setVisible(false)
		self.lbl_next_defense:setVisible(false)
		self.lbl_next_reduce:setVisible(false)
		-- self.lbl_next_set:setVisible(false)
		self.lbl_next_melee_txt:setVisible(false)
		self.lbl_next_remote_txt:setVisible(false)
		self.lbl_next_defense_txt:setVisible(false)
		self.lbl_next_durable_txt:setVisible(false)
		self.lbl_next_reduce_txt:setVisible(false)
		-- self.lbl_next_set_txt:setVisible(false)

		self.lbl_next_boat_set:setVisible(false)
		self.lbl_next_boat:setVisible(false)

		self.lbl_arrow_melee:setVisible(false)
		self.lbl_arrow_remote:setVisible(false)
		self.lbl_arrow_durable:setVisible(false)
		self.lbl_arrow_defense:setVisible(false)
		self.lbl_arrow_reduce:setVisible(false)
		-- self.lbl_arrow_set:setVisible(false)

		return
	end

	local next_nobility_data = nil
	if cur_nobility_data.next ~= 0 then
		next_nobility_data = self.nobility_data:getNobilityDataByID(cur_nobility_data.next)
	else
		next_nobility_data = cur_nobility_data
	end
	self.spr_next_nobility:changeTexture(next_nobility_data.icon, UI_TEX_TYPE_PLIST)
	self.lbl_next_nobility:setText(next_nobility_data.title)
	self.lbl_next_nobility:setUILabelColor(next_nobility_data.level_color)
	self.lbl_next_melee:setText(next_nobility_data.melee)
	self.lbl_next_remote:setText(next_nobility_data.remote)
	self.lbl_next_durable:setText(next_nobility_data.durable)
	self.lbl_next_defense:setText(next_nobility_data.defense)
	self.lbl_next_reduce:setText(next_nobility_data.reduce * REDUCE_RATE .. "%")
	-- self.lbl_next_set:setText(next_nobility_data.invest_sailor_amount)

	-- 当前等级和下个等级数值相同则不显示箭头
	self.lbl_arrow_melee:setVisible(cur_nobility_data.melee ~= next_nobility_data.melee)
	self.lbl_arrow_remote:setVisible(cur_nobility_data.remote ~= next_nobility_data.remote)
	self.lbl_arrow_durable:setVisible(cur_nobility_data.durable ~= next_nobility_data.durable)
	self.lbl_arrow_defense:setVisible(cur_nobility_data.defense ~= next_nobility_data.defense)
	self.lbl_arrow_reduce:setVisible(cur_nobility_data.reduce ~= next_nobility_data.reduce)
	-- self.lbl_arrow_set:setVisible(cur_nobility_data.invest_sailor_amount ~= next_nobility_data.invest_sailor_amount)

	local exp_num = self.nobility_exp / cur_nobility_data.exp
	if exp_num > 1 then
		exp_num = 1
	end
	self.pro_exp:setPercent(exp_num * 100)
	local nobility_exp = string.format(cls_ui_word.PORT_NOBILITY_EXP, self.nobility_exp, cur_nobility_data.exp)
	self.lbl_exp:setText(nobility_exp)	

	local player_data = getGameData():getPlayerData()
	local boat_id = next_nobility_data.boat_ids[player_data:getProfession()]
	local boat_config = ClsDataTools:getBoat(boat_id)
	self.lbl_next_boat:setText(boat_config.name)

	if self.pro_exp:getPercent() < 100 then
		self.lbl_btn_up_text:setText(cls_ui_word.PRESTIGE_UP_BTN_TAB_1)

	else

		self.lbl_btn_up_text:setText(cls_ui_word.PRESTIGE_UP_BTN_TAB_2)		
		if self.chapter_id <= self.elite_limit_level then
			self.lbl_btn_up_text:setText(cls_ui_word.PRESTIGE_UP_BTN_TAB_3)
		end	
	end
end

function clsNobilityUI:configEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self:onCloseClicked()
	end, TOUCH_EVENT_ENDED)

	self.btn_upstep:setPressedActionEnabled(true)
	self.btn_upstep:addEventListener(function()
		self:onUpStepClicked()
	end, TOUCH_EVENT_ENDED)
end

function clsNobilityUI:onCloseClicked()
	audioExt.playEffect(cls_music_info.COMMON_CLOSE.res)

    self:close()
end

function clsNobilityUI:onUpStepClicked()
	audioExt.playEffect(cls_music_info.COMMON_BUTTON.res)
	local teamData = getGameData():getTeamData()
	
	if teamData:isLock(true) then
		-- local is_in_target_port = (getGameData():getPortData():getPortId() == 2)
		-- if is_in_target_port then
		-- 	if getGameData():getSceneDataHandler():isInExplore() then
		-- 		is_in_target_port = false
		-- 	end
		-- end
		-- local tip_str = cls_ui_word.PORT_NOBILITY_LEAVE_TEAM_AND_GO
		-- if is_in_target_port then
		-- 	tip_str = cls_ui_word.LEAVE_TEAM_TIP
		-- end
		-- require("ui/tools/alert"):showAttention(
		-- 	tip_str,
		-- 	function()
		-- 		teamData:askLeaveTeam()
		-- 		if not is_in_target_port then
		-- 			getGameData():getWorldMapAttrsData():tryToEnterPort(2)
		-- 		end
		-- 	end
		-- 	)
		return
	end
	self.btn_upstep:disable()

	if self.chapter_id <= self.elite_limit_level and self.pro_exp:getPercent() >= 100 then
		local function close_function(  )
			self.btn_upstep:active()
		end
		getUIManager():create("gameobj/battle/clsEliteBattle",nil,close_function)
		return 
	end	

	--能晋升但不在里斯本就弹提示
	if(self.pro_exp:getPercent() >= 100 and (getGameData():getPortData():getPortId() ~= 2 or isExplore))then

		require("ui/tools/alert"):showAttention(
			cls_ui_word.PORT_UP_NOBILITY_TIP, function()
					self.nobility_data:askTryJumpPort()
				end, function() self:setTouch(true) end, nil, {ok_text = cls_ui_word.PORT_UP_NOBILITY_BTN, hide_cancel_btn = true})	
	else

		self.nobility_data:sendNobilityUpstep()
			
		--设置恢复弹出对话框（只对地图）
		local explore_map_obj = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
		if not tolua.isnull(explore_map_obj) and self.pro_exp:getPercent() >= 100 then

		end
	end
end

function clsNobilityUI:updataUI()
	
	self.nobility_data = getGameData():getNobilityData()
	local cur_nobility_data = self.nobility_data:getNobilityDataByID(self.nobility_id)
	cur_nobility_data = self.nobility_data:getNobilityDataByID(cur_nobility_data.next)

	audioExt.playEffect(voice_info.VOICE_PRESTIGE_1000.res)

	if cur_nobility_data then 
		self.spr_cur_nobility:changeTexture(cur_nobility_data.icon, UI_TEX_TYPE_PLIST)
		self.lbl_cur_nobility:setText(cur_nobility_data.title)
		self:numberEffect(self.lbl_cur_melee, cur_nobility_data.melee)
		self:numberEffect(self.lbl_cur_remote, cur_nobility_data.remote)
		self:numberEffect(self.lbl_cur_durable, cur_nobility_data.durable)
		self:numberEffect(self.lbl_cur_defense, cur_nobility_data.defense)
		self:numberEffectReduce(self.lbl_cur_reduce, cur_nobility_data.reduce)
		local next_nobility_data = nil
		if cur_nobility_data.next ~= 0 then
			next_nobility_data = self.nobility_data:getNobilityDataByID(cur_nobility_data.next)
		else
			next_nobility_data = cur_nobility_data
		end
		self.spr_next_nobility:changeTexture(next_nobility_data.icon, UI_TEX_TYPE_PLIST)
		self.lbl_next_nobility:setText(next_nobility_data.title)
		self:numberEffect(self.lbl_next_melee, next_nobility_data.melee)
		self:numberEffect(self.lbl_next_remote, next_nobility_data.remote)
		self:numberEffect(self.lbl_next_durable, next_nobility_data.durable)
		self:numberEffect(self.lbl_next_defense, next_nobility_data.defense, function()
			self.nobility_data:sendSyncNobilityInfo()
		end)

		self:numberEffectReduce(self.lbl_next_reduce, next_nobility_data.reduce)
	end 

	if self.pro_exp:getPercent() < 100 then
		self.lbl_btn_up_text:setText(cls_ui_word.PRESTIGE_UP_BTN_TAB_1)
	
	else
		self.lbl_btn_up_text:setText(cls_ui_word.PRESTIGE_UP_BTN_TAB_2)			
		if self.chapter_id <= self.elite_limit_level then
			self.lbl_btn_up_text:setText(cls_ui_word.PRESTIGE_UP_BTN_TAB_3)
		end			
	end

    if not tolua.isnull(self.clip_node) then
        self.clip_node:removeFromParentAndCleanup(true)
        self.clip_node = nil 
    end

	local frame = display.newSpriteFrame("common_9_cream.png")
	local sprite_bg = CCScale9Sprite:createWithSpriteFrame(frame)
	sprite_bg:setContentSize(CCSize(460, 140))
	sprite_bg:setAnchorPoint(ccp(0, 0))
	sprite_bg:setCapInsets(CCRect(0,0,0,0))
	sprite_bg:setPosition(ccp(250,207))--250,207

    self.clip_node = CCClippingNode:create()
    local draw_node = CCDrawNode:create()
    local color = ccc4f(0, 1, 0, 1)
    local points = CCPointArray:create(4)   
    points:add(ccp(252,209))
    points:add(ccp(252, 344))
    points:add(ccp(713, 344))    
    points:add(ccp(713, 209))

    draw_node:drawPolygon(points, color, 0, color)
    draw_node:setPosition(ccp(0, 0)) 
    self.clip_node:setStencil(draw_node)
    self.clip_node:setInverted(false)        
	self.clip_node:setPosition(ccp(0,0))
	local bg_layer = display.newLayer()
	bg_layer:addChild(sprite_bg)
	self.clip_node:addChild(bg_layer)

    self:addChild(self.clip_node)

    local actions = CCArray:create()
    local use_time = 10
    actions:addObject(CCMoveTo:create(1.0, ccp(713, 209))) --是为了和前面两次速度相同
    actions:addObject(CCDelayTime:create(1))
    actions:addObject(CCCallFunc:create(function (  )
		self:setTouch(true)  
    end))
    sprite_bg:runAction(CCSequence:create(actions))


	ClsDialogSequene:insertTaskToQuene(ClsNobilityUpEffect.new())
	
end 

function clsNobilityUI:numberEffect(lbl_num, value, callback)
	cls_ui_common:numberEffect(lbl_num, tonumber(lbl_num:getStringValue()), value, nil, callback)
end

function clsNobilityUI:numberEffectReduce(lbl_num, value, callback)
	local num = tonumber(string.sub(lbl_num:getStringValue(), 1, -2)) / REDUCE_RATE
	cls_ui_common:numberEffect(lbl_num, num, value, nil, nil, nil, nil, function(tempNum)
		lbl_num:setText(tempNum * REDUCE_RATE .. "%")
	end)
end

function clsNobilityUI:setTouch(enable)
	if tolua.isnull(self) then
		return 
	end

	if enable then
		self.btn_close:active()
		self.btn_upstep:active()
		if self.nobility_data:isFullLevel() then
			self.btn_upstep:disable()
		end
		local task_data = getGameData():getTaskData()
		for i,v in ipairs(self.btn_upstep.task_keys) do
			task_data:onOffEffect(v)
		end
	else
		self.btn_upstep:disable()
		self.btn_close:disable()
	end
end

function clsNobilityUI:onExit()
	--当任务完成拦截时，重新拿一次同步信息协议，刷新相关的界面信息
	self.nobility_data:sendSyncNobilityInfo()
	UnLoadPlist(self.plist)
	-- 
	--  
	-- dialogSequence:setForcePause(false)
end

return clsNobilityUI



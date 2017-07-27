--2016/06/12
--create by wmh0497
--用于在探索事件的基类

--[[
{ ['1']={ ['y']=248,['x']=843,['evType']=1,['jsonArgs']={"
testFlg":1,"y":248,"x":843},['evId']=10,} }
]]

local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")
local tips = require("game_config/tips")
local music_info = require("game_config/music_info")

local ClsExploreEventBase = class("ClsExploreEventBase")

function ClsExploreEventBase:ctor(event_layer, eid, ...)
	self.m_eid = eid

	self.m_event_layer = event_layer
	self.m_explore_layer = getExploreLayer()
	self.m_effect_layer = getUIManager():get("ClsExploreEffectLayer")
	self.m_player_ship = self.m_explore_layer:getPlayerShip()
	self.m_ships_layer = self.m_explore_layer:getShipsLayer()

	self.m_is_decorate = false
	self.m_skill_id = 0
	self.m_max_distance = 2 * display.width    -- 物品离船的最远有效距离
	self.m_max_distance2 = self.m_max_distance * self.m_max_distance
	self.m_create_distance = 0.65 * display.width -- 物品初始距离
	self.m_is_end = false
	self.m_is_hit = false
	

	-- flags
	self.m_success_flag = 3 -- 有瞭望/降帆/打死海怪 表示结果成功
	self.m_fail_flag = -3 -- 无 瞭望和降帆 结果失败
	self.m_hit_remove_flag = 0 -- 撞到鲨鱼后 并移除鲨鱼
	self.m_hit_not_remove_flag = -4 -- 撞到海怪 不移除
	self.m_far_remove_flag = -2 -- 距离过远 移除
	self.m_bad_pos_remove_flag = -2 -- 位置错误 移除

	self.m_is_delay_delete = false

	self:initEvent(...)
end

function ClsExploreEventBase:getEventId()
	return self.m_eid
end

function ClsExploreEventBase:getEventType()
	return self.m_event_type or ""
end

function ClsExploreEventBase:getSkillId()
	return self.m_skill_id
end

function ClsExploreEventBase:getIsEnd()
	return self.m_is_end
end

function ClsExploreEventBase:getIsDelayDelete()
	return self.m_is_delay_delete
end

function ClsExploreEventBase:setIsDecorate(is_decorate)
	self.m_is_decorate = is_decorate
end

function ClsExploreEventBase:getIsDecorate(is_decorate)
	return self.m_is_decorate
end

-- 初始化event
function ClsExploreEventBase:initEvent(...)

end

function ClsExploreEventBase:update(dt)
	--子类继承
end

function ClsExploreEventBase:getCreateItemPos(is_get_sea_point)
	local px, py = self.m_player_ship:getPos()
	local ship_pos = nil
	local angle = self.m_player_ship:getAngle() - 80 + Math.random(80)
	local create_distance = self.m_create_distance - 60 + Math.random(120)
	for i = 0, 7 do   -- 尝试每个位置
		local x_angle = angle + i * 45
		if x_angle > 360 then
			x_angle = x_angle - 360
		end
		local x = create_distance * Math.sin(Math.rad(x_angle)) + px
		local y = create_distance * Math.cos(Math.rad(x_angle)) + py
		local land_type = self.m_explore_layer:getMapState(x, y, true)
		if is_get_sea_point then
			if land_type == MAP_SEA or (land_type == MAP_EDGE) then
				if not self.m_event_layer:isOverlap(self.m_eid,x,y) then
					ship_pos = ccp(x, y)
					break
				end
			end
		else
			if land_type == MAP_SEA  then
				if not self.m_event_layer:isOverlap(self.m_eid,x,y) then
					ship_pos = ccp(x, y)
					break
				end
			end
		end
	end
	if ship_pos then
		return ship_pos.x, ship_pos.y
	end
end

function ClsExploreEventBase:getSkillSailorId()
	local appointSkills = getGameData():getSailorData():getRoomSailorsSkill()
	if appointSkills then
		if appointSkills[self.m_skill_id] then
			return appointSkills[self.m_skill_id].sailorId
		end
	end
end

function ClsExploreEventBase:hit() --船撞到了
	--撞到了执行的逻辑
end

function ClsExploreEventBase:release()
end

function ClsExploreEventBase:touch()
end

function ClsExploreEventBase:sendRemoveEvent(remove_flag)
	if self.m_eid < 0 then
		self.m_event_layer:removeCustomEventById(self.m_eid)
		return
	end
	getGameData():getExploreData():exploreEventEnd(self.m_eid, remove_flag)
end

function ClsExploreEventBase:createSkillIcon()
	local btn = getSkillBtn()
	self.m_item_model.ui:addChild(btn)
end

function ClsExploreEventBase:getSkillBtn(touch_view)
	--技能图标--------------------
	local skill_cfg = require("game_config/skill/skill_info")
	local skill_config = skill_cfg[self.m_skill_id]
	local skill_res = nil
	if skill_config then
		if string.len(skill_config.res) > 0 then
			skill_res = skill_config.res
		end
	end

	local touch_view = touch_view or self.m_explore_layer
	local btn = touch_view:createButton({image = "#explore_skill.png", isAudio = false, unSelectScale = 0.7, selectScale = 0.6})
	local skill_spr = display.newSprite(skill_res)
	local posY = 60
	local size = btn:getNormalImageSpr():getContentSize()

	skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
	btn:getNormalImageSpr():addChild(skill_spr)
	btn:setPositionY(posY)

	btn:regCallBack(function()
			self:touch()
		end)
	return btn
end

function ClsExploreEventBase:getQteBtn(wait_reason_str, wait_time_n, end_callback)
	wait_time_n = wait_time_n or 0
	local btn = self:getSkillBtn(self.m_effect_layer)
	btn:setScale(1)
	if wait_reason_str then
		self.m_ships_layer:setStopShipReason(wait_reason_str)
	end
	local release_callback = function()
			if not tolua.isnull(self.m_ships_layer) and wait_reason_str then
				self.m_ships_layer:releaseStopShipReason(wait_reason_str)
			end
		end
	btn:setRemoveCallback(function() release_callback() end)
	btn:getNormalImageSpr():setCascadeOpacityEnabled(true)
	btn:regCallBack(function()
		 	audioExt.playEffect(music_info.COMMON_BUTTON.res)
			btn:setTouchEnabled(false)
			local actions = CCArray:create()
			actions:addObject(CCFadeTo:create(0.5, 0))
			actions:addObject(CCCallFunc:create(function()
					btn:setVisible(false)
					if type(end_callback) == "function" then
						end_callback()
					end
				end))
			btn:getNormalImageSpr():runAction(CCSequence:create(actions))
			release_callback()
			self:touch("qte")
		end)
	
	local size = btn:getNormalImageSpr():getContentSize()
	local eff_spr = display.newSprite()
	eff_spr:setCascadeOpacityEnabled(true)
	eff_spr:setPosition(size.width/2 + 2, size.height/2)
	btn:getNormalImageSpr():addChild(eff_spr, 10)
	
	local effect_arm = CCArmature:create("tx_explore_qte")
	effect_arm:setCascadeOpacityEnabled(true)
	effect_arm:getAnimation():playByIndex(0)
	eff_spr:addChild(effect_arm)
	
	if wait_reason_str then
		local delay_act = require("ui/tools/UiCommon"):getDelayAction(wait_time_n, function() release_callback() end)
		btn:runAction(delay_act)
	end
	return btn
end

function ClsExploreEventBase:isSameTouchInfo(touch_info, type_str, eid)
	if type(touch_info) == "table" then
		if touch_info.type == type_str and touch_info.id == eid then
			return true
		end
	end
	return false
end

function ClsExploreEventBase:playEventVoice(voice_info)
	if tolua.isnull(getExploreUI()) then return end
	if voice_info then
		getExploreUI():playAudio({m = voice_info[1], f = voice_info[2]})
	end
end

function ClsExploreEventBase:setSkillIconVisible(isShow)
	if self.m_btn_menu then
		self.m_btn_menu:setVisible(isShow)
	end
end

function ClsExploreEventBase:createHpProgress()
	local pos_y = -30
	local value_percent = 100
	local hp_bg_spr = display.newSprite("#common_bar_bg1.png")
	local hp_bar =  CCProgressTimer:create(display.newSprite("#common_bar1.png"))
	hp_bar:setType(kCCProgressTimerTypeBar)
	hp_bar:setMidpoint(ccp(0,1))
	hp_bar:setBarChangeRate(ccp(1, 0))
	hp_bar:setPercentage(100)
	hp_bg_spr:addChild(hp_bar)
	hp_bg_spr:setPositionY(pos_y)

	self.m_hp_ui = hp_bg_spr
	self.m_hp_ui.main_bar = hp_bar

	--透明的血条
	local trans_bar = CCProgressTimer:create(display.newSprite("#common_bar1.png"))
	trans_bar:setType(kCCProgressTimerTypeBar)
	trans_bar:setMidpoint(ccp(0,1))
	trans_bar:setBarChangeRate(ccp(1, 0))
	trans_bar:setPercentage(100)
	trans_bar:setVisible(false)
	self.m_hp_ui.trans_bar = trans_bar
	hp_bg_spr:addChild(trans_bar)
	trans_bar:setZOrder(1)
	hp_bar:setZOrder(2)
	local size = hp_bg_spr:getContentSize()
	trans_bar:setPosition(ccp(size.width / 2, size.height / 2))
	hp_bar:setPosition(ccp(size.width / 2, size.height / 2))
	hp_bg_spr:setScaleX(0.47)
	hp_bg_spr:setScaleY(0.56)

	return self.m_hp_ui
end

function ClsExploreEventBase:getDistance2(x1, y1, x2, y2)
	return (x1 - x2)*(x1 - x2) + (y1 - y2)*(y1 - y2)
end

function ClsExploreEventBase:isInDistance(dis, x1, y1, x2, y2)
	local dis2 = dis*dis
	local now2 = self:getDistance2(x1, y1, x2, y2)
	if dis2 >= now2 then
		return true
	end
	return false
end

function ClsExploreEventBase:showDialogTips(tips_id, sailor_id, time_n)
	EventTrigger(EVENT_EXPLORE_PLOT_DIALOG, {txt = tips[tips_id].msg, is_player = true, duration = time_n or 3})
end

function ClsExploreEventBase:subSailor(rate_n, tip_id_n, is_monster_tip)
	local supplyData = getGameData():getSupplyData()
	local total_num = supplyData:getTotalSailor()
	local cut_num = math.ceil(total_num * rate_n / 100)
	supplyData:subSailor(cut_num)
	if tip_id_n then
		EventTrigger(EVENT_EXPLORE_PLOT_DIALOG, {txt = string.format(tips[tip_id_n].msg, cut_num), is_player = true, duration = 8})
	end
	if is_monster_tip then
		EventTrigger(EVENT_EXPLORE_SHOW_DIALOG, {tip_id = is_monster_tip}, tonumber(cut_num))
	end
end

function ClsExploreEventBase:autoForwardUpdate(dt, is_out)
	self.m_item_model:setSpeedRate(1)
	local player_tran = self.m_player_ship.node:getTranslationWorld()
	local event_model_tran = self.m_item_model.node:getTranslationWorld()
	local dir = Vector3.new()
	if is_out then
		Vector3.subtract(event_model_tran, player_tran, dir)
	else
		Vector3.subtract(player_tran, event_model_tran, dir)
	end
	LookForward(self.m_item_model.node, dir)

	self.m_item_model:update(dt)
end

return ClsExploreEventBase

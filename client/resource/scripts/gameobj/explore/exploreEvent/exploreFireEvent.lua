--2016/05/23
--create by wmh0497
--浮冰和礁石事件

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local ClsSceneUtil = require("gameobj/explore/sceneUtil")
local ClsSkillCalc = require("module/battleAttrs/skill_calc")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")

local EVENT_TIP_CONFIG = {
	["rock"] = 41,
	["ice"] = 42,
}

local ClsExploreFireEvent = class("ClsExploreFireEvent", ClsExploreEventBase)

function ClsExploreFireEvent:initEvent(event_date)
	self.m_event_data = event_date
	local event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_config_item = event_config_item
	self.m_active_skill_item = explore_skill[event_config_item.effective_skill_id]
	self.m_passive_skill_item = explore_skill[event_config_item.skill_id]
	self.m_event_type = event_config_item.event_type

	local param = {}
	param.res = event_config_item.res
	param.animation_res = event_config_item.animation_res
	param.water_res = event_config_item.water_res
	param.sea_level = event_config_item.sea_level
	param.type = self.m_event_type
	param.item_id = self.m_eid
	param.hit_radius = event_config_item.hit_radius

	self.m_item_model = propEntity.new(param)

	self.m_hp = event_config_item.value
	self.m_max_hp = self.m_hp

	self.m_hit_radius = event_config_item.hit_radius
	self.m_skill_radius = event_config_item.skill_radius
	self.m_skill_radius2 = self.m_skill_radius * self.m_skill_radius 
	self.m_skill_id = self.m_active_skill_item.skill_info_id
	self.m_shake_stop_reason = string.format("%s_ExploreFireEvent_id%s_sceneShake", self.m_event_type, tostring(self.m_eid))
	self.m_stop_reason = string.format("%s_ExploreFireEvent_id%s_firing", self.m_event_type, tostring(self.m_eid))
	self.m_wait_reason = string.format("%s_ExploreFireEvent_id%s_wait_1s", self.m_event_type, tostring(self.m_eid))
	self.m_active_key = string.format("%s_ExploreFireEvent_id%s_qte_key", self.m_event_type, tostring(self.m_eid))
	self.m_is_show_event_tips = false

	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()

	local show_radius_n = event_config_item.show_radius
	if show_radius_n > 0 then
		self.m_create_distance = event_config_item.show_radius
	end

	local item_x, item_y = self:getCreateItemPos()
	if item_x then
		self.m_item_model:setPos(item_x, item_y)
	else --没有的话，直接清除
		self:sendRemoveEvent(self.m_far_remove_flag)
		self.m_is_end = true
		return
	end
	self.m_item_model:playAnimation(event_config_item.animation_res[1], false, true)

	self.m_delay_timer = nil
end

function ClsExploreFireEvent:touch(touch_reason_str)
	self.m_delay_timer = nil
	if self.m_is_firing or self.m_is_lock_touch or self.m_is_end then
		self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
		return
	end
	local x, y = self.m_item_model:getPos()
	local px, py = self.m_player_ship:getPos()
	if self:isInDistance(self.m_skill_radius, x, y, px, py) then
		self.m_ships_layer:setStopShipReason(self.m_stop_reason)
		self:showEventEffect()
	else
		self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
	end
	
end

function ClsExploreFireEvent:updateDelayCallback(dt)
	if self.m_delay_timer then
		if self.m_delay_timer.time <= 0 then
			local callback = self.m_delay_timer.callback
			self.m_delay_timer = nil
			if callback then
				callback()
			end
		else
			self.m_delay_timer.time = self.m_delay_timer.time - dt
		end
	end
end

--Math.distance(x, y, px, py)
function ClsExploreFireEvent:update(dt)
	if self.m_is_end then
		return
	end

	self:updateDelayCallback(dt)

	local x, y = self.m_item_model:getPos()
	local px, py = self.m_player_ship:getPos()
	local dis2 = self:getDistance2(x, y, px, py)
	local has_key = false
	if dis2 <= (self.m_hit_radius*self.m_hit_radius) then
		if not self.m_is_hit then
			self:playEventVoice(self.m_event_config_item.voice_fail)
			self:hit()
			self.m_is_end = true
		end
		has_key = true
	elseif dis2 <= (self.m_skill_radius*self.m_skill_radius) then
		if not self.m_is_show_event_tips then
			self.m_is_show_event_tips = true
			self:showDialogTips(self.m_event_config_item.tip_id[2], self:getSkillSailorId())
			self:playEventVoice(self.m_event_config_item.voice_appear)
		end
		has_key = true
	elseif dis2 > (self.m_max_distance*self.m_max_distance) then
		self:sendRemoveEvent(self.m_far_remove_flag)
		self.m_is_end = true
	end
	
	if has_key then
		if not self.m_event_layer:hasActiveKey(self.m_active_key) then
			self.m_event_layer:addActiveKey(self.m_active_key, function() return self:getQteBtn(self.m_wait_reason, 1) end)
		end
	else
		self.m_event_layer:removeActiveKey(self.m_active_key)
	end
end

function ClsExploreFireEvent:hit() --船撞到了
	self.m_is_hit = true
	local function began_callback()
		audioExt.playEffect(music_info[self.m_event_config_item.hit_sound].res)
		self.m_ships_layer:setStopShipReason(self.m_shake_stop_reason)
		self:sendRemoveEvent(self.m_hit_remove_flag)

		local rate_n = self.m_passive_skill_item.params -- [1]  --百分比
		if rate_n and rate_n > 0 then
			self:subSailor(rate_n, self.m_passive_skill_item.tip_id[1])
		end
	end
	local function end_callback()
		self.m_ships_layer:releaseStopShipReason(self.m_shake_stop_reason)
	end
	local function checkFunc()
	end
	ClsSceneUtil:sceneShake(10, began_callback, end_callback, self.m_player_ship.node, checkFunc)
end

function ClsExploreFireEvent:showEventEffect()
	self.m_is_firing = true
	self.m_is_lock_touch = true

	local function eff_action()
		self.m_is_firing = nil
		self.m_is_lock_touch = false
		self.m_bullet = nil

		if not self.m_hp_ui then
			self.m_hp_ui = self:createHpProgress()
			self.m_item_model.ui:addChild(self.m_hp_ui)
		end

		local hit_value = 1
		local add_value = ClsSkillCalc.NonBattleCalc[ClsSkillCalc.EXPLORE_REMOVE_ROCK_ICE](self.m_hp) --是否这次直接成功
		if add_value > 0 then
			hit_value = add_value
		end
		self.m_hp = self.m_hp - hit_value
		if self.m_hp < 0 then self.m_hp = 0 end
		print(self.m_event_type, "-------left hp, hit hp---", self.m_hp, hit_value)
		local per_n = math.floor(self.m_hp / self.m_max_hp * 100)
		self.m_hp_ui.main_bar:setPercentage(per_n)

		audioExt.playEffect(music_info[self.m_active_skill_item.hit_sound].res)
		local ClsSceneUtil = require("gameobj/explore/sceneUtil")
		ClsSceneUtil:sceneFire(self.m_hp, self.m_max_hp, self.m_item_model, self.m_item_model.ui, self.m_event_type)
		if self.m_hp <= 0 then
			self:sendRemoveEvent(self.m_success_flag)
			self:playEventVoice(self.m_event_config_item.voice_qte)
			self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
			self.m_is_end = true
		else
			self.m_delay_timer = {time = 0.2, callback = function() self:touch() end}
		end
	end

	local down = 30
	local ClsExploreBullet = require("gameobj/explore/exploreBullet")
	local bullet_param = {
		skill_id = self.m_skill_id,
		targetNode = self.m_item_model.node,
		ship = self.m_player_ship,
		isFirst = false,
		num = 1,
		targetCallBack = eff_action,
		down = down --炮弹打中的位置下移down单位
	}
	self.m_bullet = ClsExploreBullet.new(bullet_param)
	audioExt.playEffect(music_info[self.m_active_skill_item.fire_sound].res)
end

function ClsExploreFireEvent:release()
	self.m_ships_layer:releaseStopShipReason(self.m_shake_stop_reason)
	self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
	self.m_event_layer:removeActiveKey(self.m_active_key)
	
	if self.m_item_model then
		self.m_item_model:release()
		self.m_item_model = nil
	end
	if self.m_bullet then
		self.m_bullet:Release()
	end
end

return ClsExploreFireEvent

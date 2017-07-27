--2016/05/23
--create by wmh0497
--酒桶和宝箱

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

local ClsExploreBoxEvent = class("ClsExploreBoxEvent", ClsExploreEventBase)

function ClsExploreBoxEvent:initEvent(event_date)
	self.m_event_data = event_date
	local event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_config_item = event_config_item
	self.m_active_skill_item = explore_skill[event_config_item.effective_skill_id]
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

	self.m_skill_radius = event_config_item.skill_radius
	self.m_skill_radius2 = self.m_skill_radius * self.m_skill_radius
	self.m_jump_radius =  event_config_item.jump_radius
	self.m_jump_radius2 = self.m_jump_radius * self.m_jump_radius
	self.m_skill_id = self.m_active_skill_item.skill_info_id
	self.m_stop_reason = string.format("%s_ExploreBoxEvent_id%s_getReward", self.m_event_type, tostring(self.m_eid))
	self.m_wait_reason = string.format("%s_ExploreBoxEvent_id%s_wait_1s", self.m_event_type, tostring(self.m_eid))
	self.m_active_key = string.format("%s_ExploreBoxEvent_id%s_qte_key", self.m_event_type, tostring(self.m_eid))
	self.m_is_show_event_tips = false
	self.m_is_remove_auto = false

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
end

function ClsExploreBoxEvent:touch(touch_reason_str)
	if self.m_is_firing or self.m_is_lock_touch then
		return
	end
	
	local x, y = self.m_item_model:getPos()
	local px, py = self.m_player_ship:getPos()
	
	self.m_ships_layer:setPlayerAttr("touch_something", nil)
	local dis2 = self:getDistance2(x, y, px, py)
	if self:isInDistance(self.m_skill_radius, x, y, px, py) then
		if dis2 <= self.m_jump_radius2 then
			self:showEventEffect()
		else
			if IS_AUTO then  -- 自动导航中断
				self.m_explore_layer:getLand():breakAuto(true)
				self.m_is_remove_auto = true
			end
			getExploreUI():releaseDropAchnor()
			local screen_x, screen_y = self.m_explore_layer:getLand():getLandPosInScreen(x, y)
			self.m_ships_layer:setMyShipMoveDir(screen_x, screen_y)
			self.m_ships_layer:setPlayerAttr("touch_something", {type = self.m_event_type, id = self.m_eid})
		end
	end
end

--Math.distance(x, y, px, py)
function ClsExploreBoxEvent:update(dt)
	if self.m_is_end then
		return
	end
	local x, y = self.m_item_model:getPos()
	local px, py = self.m_player_ship:getPos()
	local dis2 = self:getDistance2(x, y, px, py)
	if dis2 <= (self.m_skill_radius2) then
		if not self.m_is_show_event_tips then
			self.m_is_show_event_tips = true
			self:showDialogTips(self.m_event_config_item.tip_id[2], self:getSkillSailorId())
			self:playEventVoice(self.m_event_config_item.voice_appear)
		end
		if not self.m_event_layer:hasActiveKey(self.m_active_key) then
			self.m_event_layer:addActiveKey(self.m_active_key, function() return self:getQteBtn(self.m_wait_reason, 1) end)
		end
		
		if dis2 <= (self.m_jump_radius2) then
			if self:isSameTouchInfo(self.m_ships_layer:getPlayerAttr("touch_something"), self.m_event_type, self.m_eid) then
				self.m_ships_layer:setPlayerAttr("touch_something", nil)
				self:showEventEffect()
			end
		end
	else
		self.m_event_layer:removeActiveKey(self.m_active_key)
		
		if dis2 > (self.m_max_distance*self.m_max_distance) then
			self:sendRemoveEvent(self.m_far_remove_flag)
			self.m_is_end = true
		end
	end
end

function ClsExploreBoxEvent:showEventEffect()
	local team_data = getGameData():getTeamData()
	if team_data:isLock() then
		return
	end

	self.m_is_firing = true
	self.m_is_lock_touch = true

	local function tip_callBack()
		if self.m_item_model then
			self.m_item_model:setVisible(false)
		end
	end

	local function end_callBack()
		self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
		self:sendRemoveEvent(self.m_success_flag)
		self:playEventVoice(self.m_event_config_item.voice_qte)
		self.m_is_end = true
		self.m_is_firing = false
		self.m_is_lock_touch = false
		if self.m_is_remove_auto and (not IS_AUTO) then
			self.m_is_remove_auto = false
			self.m_explore_layer:continueAutoNavigation(true)
		end
	end

	local ClsExploreSalvageSkill = require("gameobj/explore/exploreSalvageSkill")
	local target = {spItem = self.m_item_model}
	local params = {
		ship_id = self.m_player_ship.id,
		anim_call = "scripts/gameobj/gameplayFunc.lua#animationClipPlayEnd",
		targetNode = target.spItem.node,
		targetData = target,
		ship = self.m_player_ship,
		num = 1,
		modelFile = "ex_salvage",
		animationFile = "ex_salvage",
		targetCallBack = end_callBack,
		tipCallBack = tip_callBack,
	}

	ClsExploreSalvageSkill.new(params)
	self.m_ships_layer:setStopShipReason(self.m_stop_reason)
	audioExt.playEffect(music_info[self.m_active_skill_item.fire_sound].res)
end

function ClsExploreBoxEvent:release()
	self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
	
	self.m_event_layer:removeActiveKey(self.m_active_key)
	if self.m_item_model then
		self.m_item_model:release()
		self.m_item_model = nil
	end
end

return ClsExploreBoxEvent

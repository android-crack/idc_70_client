--2016/06/16
--create by wmh0497
--美人鱼

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local propEntity = require("gameobj/explore/exploreProp")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")

local ClsExploreMermaidEvent = class("ClsExploreMermaidEvent", ClsExploreEventBase)

function ClsExploreMermaidEvent:initEvent(event_date)
	self.m_event_data = event_date
	local event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_config_item = event_config_item
	self.m_event_type = event_config_item.event_type

	local param = {}
	param.res = event_config_item.res
	param.animation_res = event_config_item.animation_res
	param.water_res = event_config_item.water_res
	param.sea_level = event_config_item.sea_level
	param.type = self.m_event_type
	param.item_id = self.m_eid
	param.hit_radius = event_config_item.hit_radius
	param.auto_speed = Math.abs(event_config_item.auto_speed)

	self.m_item_model = propEntity.new(param)
	-- self.m_item_model.node:setTag("explore_event_id", tostring(self.m_eid))

	self.m_hit_radius2 = event_config_item.hit_radius * event_config_item.hit_radius
	self.m_sound_radius2 = event_config_item.jump_radius * event_config_item.jump_radius
	self.m_skill_radius2 = event_config_item.skill_radius * event_config_item.skill_radius
	self.m_play_sound_res = nil
	self.m_is_play_sound = false
	self.m_is_play_skill_radius_sound = false
	self.m_is_go_out = false
	self.m_auto_speed = Math.abs(event_config_item.auto_speed)

	local show_radius_n = event_config_item.show_radius
	if show_radius_n > 0 then
		self.m_create_distance = event_config_item.show_radius
	end

	local item_x, item_y = self:getCreateItemPos()
	if item_x then
		self.m_item_model:setPos(item_x, item_y)
	else --没有的话，直接清除
		self:sendRemoveEvent(self.m_bad_pos_remove_flag)
		self.m_is_end = true
		return
	end
	self.m_item_model:playAnimation(event_config_item.animation_res[1], true, true)
	
	self.m_is_send_qte = false
	self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
	self.m_stop_reason_wait = string.format("%s_ExploreMermaidEvent_id%s_wait_1s", self.m_event_type, tostring(self.m_eid))
	self.m_active_key = string.format("%s_ExploreMermaidEvent_id%s_qte_key", self.m_event_type, tostring(self.m_eid))
end

--Math.distance(x, y, px, py)
function ClsExploreMermaidEvent:update(dt)
	if self.m_is_end then
		return
	end
	local x, y = self.m_item_model:getPos()
	if self.m_explore_layer:getMapState(x, y, true) ~= MAP_SEA  then
		self:sendRemoveEvent(self.m_bad_pos_remove_flag)
		self.m_is_end = true
	end
	local px, py = self.m_player_ship:getPos()
	local dis2 = self:getDistance2(x, y, px, py)
	local has_key = false
	if dis2 <= self.m_hit_radius2 then
		if not self.m_is_hit then
			local explore_data = getGameData():getExploreData()
			self:sendRemoveEvent(self.m_success_flag)
			self.m_ships_layer:setIsMermaidUp(true)
			self:playEventVoice(self.m_event_config_item.voice_fail)
			self.m_is_end = true
			self:hit()
		end
		has_key = true
	elseif dis2 <= self.m_sound_radius2 then
		self.m_item_model:stopAnimation(self.m_event_config_item.animation_res[1]) --停止游动动画
		if not self.m_item_model:animationIsPlaying(self.m_event_config_item.animation_res[2]) then
			self:autoForwardUpdate(dt, true)
			if not self.m_is_play_skill_radius_sound then
				self:stopSoundRadiusSound()
				self.m_is_play_skill_radius_sound = true
				local sound_res = self.m_event_config_item.sound_id[4]
				audioExt.playEffect(music_info[sound_res].res)
				self.m_item_model:playAnimation(self.m_event_config_item.animation_res[2], false, true)
			else
				if not self.m_is_go_out then
					self.m_is_go_out = true
					self:goOut()
				end
				self.m_item_model:playAnimation(self.m_event_config_item.animation_res[3], true, true)
			end
		end
		has_key = true
	elseif dis2 <= self.m_skill_radius2 then
		if not self.m_is_play_sound then
			self.m_is_play_sound = true
			local index = Math.random(1, 3)
			local sound_res = self.m_event_config_item.sound_id[index]
			self.m_play_sound_res = audioExt.playEffect(music_info[sound_res].res)
			self:playEventVoice(self.m_event_config_item.voice_appear)
		end
		if not self.m_item_model:animationIsPlaying(self.m_event_config_item.animation_res[2]) then
			self:autoForwardUpdate(dt, true)
			if (not self.m_is_go_out) and self.m_is_play_skill_radius_sound then
				self.m_is_go_out = true
				self:goOut()
				self.m_item_model:playAnimation(self.m_event_config_item.animation_res[3], true, true)
			end
		end
		has_key = true
	elseif dis2 > self.m_max_distance2 then
		self:sendRemoveEvent(self.m_far_remove_flag)
		self.m_is_end = true
	else
		self.m_is_send_qte = false
	end
	
	if has_key then
		if not self.m_event_layer:hasActiveKey(self.m_active_key) and (not self.m_is_send_qte) then
			self.m_is_send_qte = true
			self.m_event_layer:addActiveKey(self.m_active_key, function() return self:getMermaidQteBtn() end)
		end
	else
		self.m_event_layer:removeActiveKey(self.m_active_key)
	end
end

function ClsExploreMermaidEvent:hit()
	local info = getGameData():getExplorePlayerShipsData():getAttr(self.m_my_uid, "touch_something")
	if info and info.type == self.m_event_type and info.id == self.m_eid then
		self.m_explore_layer:continueAutoNavigation(true)
		getGameData():getExplorePlayerShipsData():setAttr(self.m_my_uid, "touch_something", nil)
	end
end

function ClsExploreMermaidEvent:touch(touch_reason_str)
	local is_set_auto = IS_AUTO
	if IS_AUTO then  -- 自动导航中断
		self.m_explore_layer:getLand():breakAuto(true)
	end
	getExploreUI():releaseDropAchnor()
	local x, y = self.m_item_model:getPos()
	local px, py = self.m_player_ship:getPos()
	local screen_x, screen_y = self.m_explore_layer:getLand():getLandPosInScreen(x, y)
	self.m_ships_layer:setMyShipMoveDir(screen_x, screen_y)
	
	if is_set_auto then
		getGameData():getExplorePlayerShipsData():setAttr(self.m_my_uid, "touch_something", {type = self.m_event_type, id = self.m_eid})
	end
end

function ClsExploreMermaidEvent:getMermaidQteBtn()
	local btn = self:getQteBtn(nil, 1)
	
	local skill_spr = display.newSprite("#skill_9001.png")
	local size = btn:getNormalImageSpr():getContentSize()
	skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
	btn:getNormalImageSpr():addChild(skill_spr)
	
	return btn
end

function ClsExploreMermaidEvent:goOut()
	local forward = self.m_item_model.node:getForwardVector()
	local tmp_forward = Vector3.new()
	tmp_forward:set(forward:x(), forward:y(), forward:z())
	tmp_forward:scale(130)
	self.m_item_model.node:translate(tmp_forward)
	self:sendRemoveEvent(self.m_success_flag)
	self.m_ships_layer:setIsMermaidUp(true)
	self.m_is_end = true
end

function ClsExploreMermaidEvent:stopSoundRadiusSound()
	if self.m_is_play_sound and self.m_play_sound_res then
		audioExt.stopEffect(self.m_play_sound_res)
		self.m_play_sound_res = nil
	end
end

function ClsExploreMermaidEvent:release()
	if self.m_item_model then
		self.m_item_model:release()
		self.m_item_model = nil
	end
	self.m_event_layer:removeActiveKey(self.m_active_key)
	local info = getGameData():getExplorePlayerShipsData():getAttr(self.m_my_uid, "touch_something")
	if info and info.type == self.m_event_type and info.id == self.m_eid then
		if not self.m_event_layer:getIsRelease() then
			self.m_explore_layer:continueAutoNavigation(true)
			getGameData():getExplorePlayerShipsData():setAttr(self.m_my_uid, "touch_something", nil)
		end
	end
end

return ClsExploreMermaidEvent

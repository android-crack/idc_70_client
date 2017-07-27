--2016/06/20
--create by wmh0497
--暴风雨

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local ClsCommonBase = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")

local ClsExploreStormEvent = class("ClsExploreStormEvent", ClsExploreEventBase)

function ClsExploreStormEvent:initEvent(event_date)
	self.m_event_data = event_date
	local event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_config_item = event_config_item
	self.m_active_skill_item = explore_skill[event_config_item.effective_skill_id]
	self.m_passive_skill_item = explore_skill[event_config_item.skill_id]
	self.m_event_type = event_config_item.event_type
	self.m_count_time = 0
	self.m_during_time = event_config_item.time
	self.m_sound_hander = nil
	self.m_storm_layer = nil
	self.m_is_release = false
	
	self.m_stop_reason_wait = string.format("%s_ExploreStormEvent_id%s_wait_1s", self.m_event_type, tostring(self.m_eid))
	self.m_active_key = string.format("%s_ExploreStormEvent_id%s_qte_key", self.m_event_type, tostring(self.m_eid))
	
	self:playEventVoice(self.m_event_config_item.voice_appear)
	
	self.m_is_touch_qte_btn = false
	self:createStorm()
	self.m_ships_layer:setIsPlayStorm(true)
	if not self.m_event_layer:hasActiveKey(self.m_active_key) then
		self.m_event_layer:addActiveKey(self.m_active_key, function() return self:getStormQteBtn() end)
	end
end

function ClsExploreStormEvent:getStormQteBtn()
	local btn = self:getQteBtn(nil, 1, function() self.m_event_layer:removeActiveKey(self.m_active_key) end)
	
	local skill_spr = display.newSprite("#explore_sail_up.png")
	local size = btn:getNormalImageSpr():getContentSize()
	skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
	btn:getNormalImageSpr():addChild(skill_spr)
	
	return btn
end

function ClsExploreStormEvent:touch()
	if self.m_is_touch_qte_btn then return end
	self.m_is_touch_qte_btn = true
	
	local explore_ui = getExploreUI()
	if not tolua.isnull(explore_ui) then
		explore_ui:setSailState(SAIL_DOWN)
	end
end

function ClsExploreStormEvent:update(dt)
	if self.m_is_end then
		return
	end
	self.m_count_time = self.m_count_time + dt
	if self.m_count_time > self.m_during_time then
		if getExploreLayer():getShipsLayer():getSailState() == SAIL_DOWN then
			self:sendRemoveEvent(self.m_success_flag)
			self.m_is_end = true
		else
			self:sendRemoveEvent(self.m_fail_flag)
			self.m_is_end = true
		end
		return
	end
end

function ClsExploreStormEvent:createStorm()
	--wmh todo 隐藏云
	--self:setAllCloudVisible(false)
	self.m_sound_hander = audioExt.playEffect(music_info.EX_STORM.res)
	self.m_storm_layer = CCLayer:create()
	self.m_event_layer:getUiView():addChild(self.m_storm_layer, 10)
	local color_layer = CCLayerColor:create(ccc4(0,0,0,120))
	self.m_storm_layer:addChild(color_layer)
	local rain_emitter = CCParticleSystemQuad:create("explorer/rain.plist")
	self.m_storm_layer:addChild(rain_emitter)
	rain_emitter:setBlendAdditive(true)
	rain_emitter:setPosition(ccp(display.cx, display.height))

	-- 闪电效果
	local blink_sound = music_info.EX_THUNDER.res
	local actions = {}
	actions[1] = CCDelayTime:create(2)
	actions[2] = CCCallFunc:create(function()
		audioExt.playEffect(blink_sound, false)
	end)
	actions[3] = CCBlink:create(0.2, 1)
	actions[4] = CCDelayTime:create(1)
	actions[5] = CCCallFunc:create(function()
		audioExt.playEffect(blink_sound, false)
	end)
	actions[6] = CCBlink:create(0.6, 3)
	actions[7] = CCDelayTime:create(2)
	actions[8] = CCCallFunc:create(function()
		audioExt.playEffect(blink_sound, false)
	end)
	actions[9] = CCBlink:create(0.4, 2)
	local seq_act = transition.sequence(actions)
	color_layer:runAction(seq_act)

	if self.m_ships_layer:getSailState() == SAIL_UP then
		self:showDialogTips(self.m_event_config_item.tip_id[1])
	end
end

function ClsExploreStormEvent:release()
	if self.m_is_release then
		return
	end
	self.m_is_release = true
	self.m_ships_layer:setIsPlayStorm(false)
	if not self.m_event_layer:getIsRelease() then
		if not tolua.isnull(self.m_storm_layer) then
			self.m_storm_layer:removeFromParentAndCleanup(true)
		end
		self.m_event_layer:removeActiveKey(self.m_active_key)
		if self.m_is_end then
			self.m_event_layer:createCustomEventByName("sun_shine")
			local sail_state = self.m_ships_layer:getSailState()
			if sail_state == SAIL_UP then
				local supply_data = getGameData():getSupplyData()
				local sailor_count = Math.floor(supply_data:getCurSailor() * 0.4)
				supply_data:subSailor(sailor_count)
				EventTrigger(EVENT_EXPLORE_SHOW_DIALOG, {tip_id = self.m_passive_skill_item.tip_id[1]}, tonumber(sailor_count))
				self:playEventVoice(self.m_event_config_item.voice_fail)
			else
				self:playEventVoice(self.m_event_config_item.voice_qte)
			end
		end
	end
	if self.m_sound_hander then
		audioExt.stopEffect(self.m_sound_hander)
	end
	self.m_sound_hander = nil
end

return ClsExploreStormEvent

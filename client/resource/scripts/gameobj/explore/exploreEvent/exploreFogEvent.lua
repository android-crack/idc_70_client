--2016/06/20
--create by wmh0497
--迷雾

local ClsExploreEventBase = require("gameobj/explore/exploreEvent/exploreEventBase")
local ClsCommonBase = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")
local explore_event = require("game_config/explore/explore_event")
local explore_skill = require("game_config/explore/explore_skill")

local FOG_POS_CONFIG = {   -- 迷雾配置
		[1] = {pos = ccp(168,549), off_x = -15, off_y = 9},
		[2] = {pos = ccp(795,577), off_x = 10, off_y = 6},
		[3] = {pos = ccp(794,98), off_x = 12, off_y = -23},
		[4] = {pos = ccp(145,143), off_x = -21, off_y = -12},
		[5] = {pos = ccp(335,-29), off_x = -13, off_y = -23},
		[6] = {pos = ccp(868,410), off_x = 14, off_y = 6},
		[7] = {pos = ccp(37,326), off_x = -15, off_y = -16},
		[8] = {pos = ccp(351,669), off_x = 0, off_y = 12},
		[9] = {pos = ccp(575,701), off_x = 12, off_y = 8},
		[10] = {pos = ccp(665,-1), off_x = 12, off_y = -24},
		[11] = {pos = ccp(50,364), off_x = -12, off_y = 8},
		[12] = {pos = ccp(383,675), off_x = 16, off_y = 15},
		[13] = {pos = ccp(873,364), off_x = 17, off_y = -22},
		[14] = {pos = ccp(611,-13), off_x = -15, off_y = -30},
	}

local ClsExploreFogEvent = class("ClsExploreFogEvent", ClsExploreEventBase)

function ClsExploreFogEvent:initEvent(event_date)
	self.m_event_data = event_date
	local event_config_item = explore_event[self.m_event_data.evType]
	self.m_event_config_item = event_config_item
	self.m_active_skill_item = explore_skill[event_config_item.effective_skill_id]
	self.m_event_type = event_config_item.event_type
	self.m_count_time = 0
	self.m_during_time = event_config_item.time
	self.m_sound_hander = nil
	self.m_storm_layer = nil
	self.m_is_release = false
	self.m_fog_tab = {}
	self.m_fog_layer = nil
	
	self.m_is_click_fog_btn = false
	
	self.m_stop_reason_wait = string.format("%s_ExploreFogEvent_id%s_wait_1s", self.m_event_type, tostring(self.m_eid))
	self.m_active_key = string.format("%s_ExploreFogEvent_id%s_qte_key", self.m_event_type, tostring(self.m_eid))
	
	self.m_is_touch_qte_btn = false
	
	if not self.m_event_layer:hasActiveKey(self.m_active_key) then
		self.m_event_layer:addActiveKey(self.m_active_key, function() return self:getFogQteBtn() end)
	end
	
	self:playEventVoice(self.m_event_config_item.voice_appear)
	
	self:createFog()
end

function ClsExploreFogEvent:getFogQteBtn()
	local btn = self:getQteBtn(nil, 1)
	
	local skill_spr = display.newSprite("#skill_1066.png")
	local size = btn:getNormalImageSpr():getContentSize()
	skill_spr:setPosition(ccp(size.width / 2, size.height / 2))
	btn:getNormalImageSpr():addChild(skill_spr)
	
	return btn
end

function ClsExploreFogEvent:update(dt)
	if self.m_is_end then
		return
	end
	self.m_count_time = self.m_count_time + dt
	if self.m_count_time > self.m_during_time then
		if self.m_is_click_fog_btn == true then
			self:sendRemoveEvent(self.m_success_flag)
		else
			self:sendRemoveEvent(self.m_fail_flag)
		end
		self.m_is_end = true
		return
	end
end

function ClsExploreFogEvent:createFog()
	self.m_fog_layer = CCLayerColor:create(ccc4(255,255,255,50))
	self.m_event_layer:getUiView():addChild(self.m_fog_layer)
	self.m_fog_tab = {}
	for k, v in ipairs(FOG_POS_CONFIG) do
		self.m_fog_tab[k] = getChangeFormatSprite("ui/bg/bg_fog.png")
		self.m_fog_tab[k]:setScale(2)
		self.m_fog_tab[k]:setPosition(v.pos)
		self.m_fog_layer:addChild(self.m_fog_tab[k])
	end
	local function beganCall( )

	end
	local function endCall( )

	end

	-- 雾的出现 用剧情对话框 船不停止移动
	EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG,{beganCallBack = beganCall, call_back = endCall,tip_id = self.m_event_config_item.tip_id[2]})
end

function ClsExploreFogEvent:touch()
	if self.m_is_click_fog_btn  then
		return
	end
	self.m_is_click_fog_btn = true
	audioExt.playEffect(music_info.EX_FOG.res)
	local level = 6
	for i, v in pairs(FOG_POS_CONFIG) do
		local fog_spr = self.m_fog_tab[i]
		if not tolua.isnull(fog_spr) then
			local move_act = CCMoveBy:create(0.5, ccp(v.off_x * level, v.off_y * level))
			fog_spr:runAction(move_act)
		end
	end
end


function ClsExploreFogEvent:release()
	if self.m_is_release then
		return
	end
	self.m_is_release = true
	self.m_event_layer:removeActiveKey(self.m_active_key)
	if tolua.isnull(self.m_fog_layer) then
		return
	end
	for i, v in pairs(FOG_POS_CONFIG) do
		local move_act = CCMoveBy:create(1, ccp(v.off_x * 25, v.off_y * 25))
		local action = nil
		if i == #FOG_POS_CONFIG then
			local array = CCArray:create()
			array:addObject(move_act)
			array:addObject(CCCallFunc:create(function()
					if not tolua.isnull(self.m_fog_layer) then
						self.m_fog_layer:removeFromParentAndCleanup(true)
						self.m_fog_layer = nil
						self.m_fog_tab = nil
					end
				end))
			action = CCSequence:create(array)
		else
			action = move_act
		end
		if self.m_fog_tab then
			if not tolua.isnull(self.m_fog_tab[i]) then
				self.m_fog_tab[i]:runAction(action)
			end
		end
	end
end

return ClsExploreFogEvent

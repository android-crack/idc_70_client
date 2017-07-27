--2017/01/06
--create by wmh0497
--用于显示3d的任务页面

local game3d = require("game3d")
local ui_word = require("game_config/ui_word")
local ClsU3dSceneParse = require("gameobj/u3d/u3dSceneParse")
local music_info = require("game_config/music_info")

local ClsMission3dUi = class("ClsMission3dUi", function() return display.newLayer() end)

function ClsMission3dUi:ctor(parent, mission3d_cfg, close_callback)
	self:registerScriptHandler(function(event)
			if event == "exit" then self:onExit() end
		end)
	audioExt.stopMusic()
	audioExt.stopAllEffects()
	
	self.m_close_callback = close_callback
	self.m_mission_cfg = mission3d_cfg --require(string.format("gameobj/mission3d/mission3d_cfg_%s", mission3d_cfg_str))
	
	self.m_u3d_scene = ClsU3dSceneParse.new(self, require("game_config/mission3d/"..self.m_mission_cfg.scene_cfg), SCENE_ID.MISSION)
	self.m_scene_ui = self.m_u3d_scene:getSceneUi()
	
	if self.m_mission_cfg.bg_music then
		audioExt.playMusic(music_info[self.m_mission_cfg.bg_music].res, false)
	end
	
	local active_camera_name_str = self.m_mission_cfg.active_camera
	if active_camera_name_str then
		local camera = self.m_u3d_scene:getNodeByName(active_camera_name_str)
		camera:setActiveCamera()
	end
	
	for _, u3d_amin_item in ipairs(self.m_mission_cfg.u3d_anim) do
		local model = self.m_u3d_scene:getNodeByName(u3d_amin_item[1])
		model:playU3dCfgAnimation()
	end
	
	for _, model_amin_item in ipairs(self.m_mission_cfg.model_anim) do
		local model = self.m_u3d_scene:getNodeByName(model_amin_item[1])
		model:playAnimation(model_amin_item[2], model_amin_item[3], model_amin_item[4])
	end
	
	parent:addChild(self)
	self:addDelayCloseCallback()
	self:delayStart()
end

function ClsMission3dUi:addDelayCloseCallback()
	if self.m_mission_cfg.waiting_close then
		local waiting_info = self.m_mission_cfg.waiting_close
		local model = self.m_u3d_scene:getNodeByName(waiting_info[1])
		self:scheduleUpdate(function()
			if not model:isPlayAnimation(waiting_info[2]) then
				self:closeSelf()
			end
		end, 0)
		return
	end
	
	local delay_close_time = self.m_mission_cfg.delay_close_time or 20
	self:performWithDelay(function() 
			self:closeSelf()
		end, delay_close_time)
end

function ClsMission3dUi:delayStart()
	local delay_play_partcile = self.m_mission_cfg.delay_play_partcile
	if delay_play_partcile then
		local delay_close_time = self.m_mission_cfg.delay_close_time or 20
		for _, name_str in ipairs(delay_play_partcile) do
			local partcile = self.m_u3d_scene:getNodeByName(name_str)
			partcile:stop()
		end
		
		self:performWithDelay(function() 
				for _, name_str in ipairs(delay_play_partcile) do
					local partcile = self.m_u3d_scene:getNodeByName(name_str)
					partcile:start()
				end
			end, 0.001)
	end
end

function ClsMission3dUi:closeSelf()
	self:removeFromParentAndCleanup(true)
	self:doExitCallback()
end

function ClsMission3dUi:onExit() 
	if self.m_u3d_scene then
		self.m_scene_ui = nil
		self.m_scene_ui = nil
		self.m_u3d_scene:release()
		self.m_u3d_scene = nil
	end
end

function ClsMission3dUi:doExitCallback()
	if type(self.m_close_callback) == "function" then
		self.m_close_callback()
		self.m_close_callback = nil
	end
end

return ClsMission3dUi
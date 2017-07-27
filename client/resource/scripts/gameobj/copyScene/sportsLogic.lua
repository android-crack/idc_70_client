--
-- Author: 0496
-- Date: 2016-05-30 17:53:23
-- Function: 竞技副本的部分逻辑

local copySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local ClsFoodUiComponent = require("gameobj/copyScene/copySceneComponent/clsFoodUiComponent")
local ClsStarUiComponent = require("gameobj/copyScene/copySceneComponent/clsStarUiComponent")
local ClsVoiceUIComponent = require("gameobj/copyScene/copySceneComponent/clsVoiceUiComponent")
local tips = require("game_config/tips")
local TOTAL_TIME = 80 --倒计时总时间 客户端暂时写死.

local sportsLogic = class("sportsLogic", copySceneLogicBase)

function sportsLogic:ctor()
	self.m_star_times = {
		[1] = {time = 50, star_num = 2},
		[2] = {time = 60, star_num = 1},
	}
	self.map_land_params = {
		bit_res = "explorer/copy_scene_map.bit",
		map_res = "explorer/map/land/copy_scene_land.tmx", --地图资源
		tile_height = 47, --地图高度，格子数目
		tile_width = 60, -- 地图宽度，格子数目
		block_width_count = 7, --地图宽度遮挡
		block_height_count = 7, --地图高度挡住
		block_up_count = 5,
		block_down_count = 7,
		block_left_count = 7,
		block_right_count = 7,
	}

	--策划每次修改事件表时，都需要告诉相应的程序修改数量值
	self.model_count = {
		[SCENE_OBJECT_TYPE_ROCK] = 3, --礁石
		[SCENE_OBJECT_TYPE_ICE] = 7, --浮冰
		[SCENE_OBJECT_TYPE_BITE_BOAT] = 3, --鲨鱼
		[SCENE_OBJECT_TYPE_FLAT] = 9, --酒桶
		[SCENE_OBJECT_TYPE_SEA_WRECK] = 1, --沉船
		[SCENE_OBJECT_TYPE_MONSTER] = 3, --海怪
	}
end

function sportsLogic:init()
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local scene_ui = ClsSceneManage:getSceneUILayer()
	scene_ui:addComponent("copy_food_ui", ClsFoodUiComponent)
	scene_ui:addComponent("copy_star_ui", ClsStarUiComponent)
	scene_ui:callComponent("copy_food_ui", "showBtnBack", true)
	ClsSceneManage:setSceneAttr("show_point_map", true)

	if device.platform == "android" then
		scene_ui:addComponent("copy_voice_ui", ClsVoiceUIComponent)
	end

	if self.end_time ~= nil then
		self:updateTimeUI(self.end_time)
	end
end

function sportsLogic:updateTimeUI(time)
	self.end_time = time
	local playerData = getGameData():getPlayerData()
	self.create_time = os.time() + playerData:getTimeDelta()
	self.active_time = self.end_time - self.create_time
	local function updateTime()
		-- 剩余时间
		self.active_time = self.active_time - 1
		if self.active_time <= 0  then
			local scheduler = CCDirector:sharedDirector():getScheduler()
			if self.updateTimeHandle then
				scheduler:unscheduleScriptEntry(self.updateTimeHandle)
				self.updateTimeHandle = nil
			end
			return
		end
		local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
		local scene_ui = ClsSceneManage:getSceneUILayer()
		scene_ui.time_bg:setVisible(true)

		local used_time = TOTAL_TIME - self.active_time
		local time_str = tostring(self.active_time) .. "s"
		scene_ui.time_label:setText(time_str)
		if #self.m_star_times > 0 then
			if used_time > self.m_star_times[1].time then
				scene_ui:callComponent("copy_star_ui", "updateStarUI", self.m_star_times[1].star_num)
				table.remove(self.m_star_times, 1)
			end
		end
	end
	updateTime()
	
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.updateTimeHandle then
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end
	self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime, 1, false)
end

--添加导航提示
function sportsLogic:addNavigate()
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local map_layer = ClsSceneManage:getSceneMapLayer()
	local scene_layer = ClsSceneManage:getSceneLayer()

	local road_target_config = {{9,28}, {14,33}, {19,38}}
	local touch_pos_vec3s = {}
	for k, v in ipairs(road_target_config) do
		local co_pos = map_layer:tileSizeToCocos2(ccp(v[1],v[2]))
		pos_vec3 = cocosToGameplayWorld(co_pos)
		touch_pos_vec3s[k] = pos_vec3
	end
	self:addMultiPathEffect(touch_pos_vec3s)
end

function sportsLogic:addMultiPathEffect(touchPoss)
	self.pathEffInfos = {}
	for k, touchPos in ipairs(touchPoss) do
		local pathEffInfo = {}
		pathEffInfo.pathTouchPos = touchPos
		local commonBase = require("gameobj/commonFuns")
		local parent = Explore3D:getLayerShip3d()
		local _, particle = commonBase:addNodeEffect(parent, "tx_dianji_yellow", touchPos)
		particle:Start()
		pathEffInfo.pathClickParticles = particle
		self.pathEffInfos[k] = pathEffInfo
	end
end

function sportsLogic:clearMultiPathEffect()
	if self.pathEffInfos then
		for k, v in ipairs(self.pathEffInfos) do
			v.pathClickParticles:Release()
		end
		self.pathEffInfos = nil
	end
end

function sportsLogic:getResuleLayer(result_info, callBack)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local scene_ui = ClsSceneManage:getSceneUILayer()
	scene_ui:callComponent("copy_star_ui", "stopUpdataStar")
	local result_ui = getUIManager():create("gameobj/copyScene/sportsResultUI", nil, result_info, callBack)
	return result_ui
end


function sportsLogic:showCompleteTips(sid)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:showCompleteTips(sid)
end

function sportsLogic:createPlayerShip(parent)
	local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")
	return ClsCopyPlayerShipsLayer.new(parent)
end

function sportsLogic:cancelRecord()
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local scene_ui = ClsSceneManage:getSceneUILayer()
	if device.platform == "android" then
		scene_ui:callComponent("copy_voice_ui", "cancelRecord")
	end
end

function sportsLogic:onExit()
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if self.updateTimeHandle then
		scheduler:unscheduleScriptEntry(self.updateTimeHandle)
		self.updateTimeHandle = nil
	end
end

return sportsLogic

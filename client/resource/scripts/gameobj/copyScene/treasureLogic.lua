--
-- Author: 0496
-- Date: 2016-05-30 17:33:18
-- Function: 寻宝副本逻辑

local copySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local copy_scene_mission = require("game_config/copyScene/copy_scene_mission")
local ui_word = require("game_config/ui_word")
local tips = require("game_config/tips")
local ClsFoodUiComponent = require("gameobj/copyScene/copySceneComponent/clsFoodUiComponent")
local ClsVoiceUIComponent = require("gameobj/copyScene/copySceneComponent/clsVoiceUiComponent")

local treasureLogic = class("treasureLogic", copySceneLogicBase)

function treasureLogic:ctor()
	self.map_land_params = {
		bit_res = "explorer/copy_scene_treasure_map.bit",
        map_res = "explorer/map/land/copy_scene_treasure_land.tmx", --地图资源
        tile_height = 44, --地图高度，格子数目
        tile_width = 92, -- 地图宽度，格子数目
        block_width_count = 8, --地图宽度遮挡
        block_height_count = 5, --地图高度挡住
        block_up_count = 5,
        block_down_count = 5,
        block_left_count = 8,
        block_right_count = 8,
	}

	--策划每次修改事件表时，都需要告诉相应的程序修改数量值
	self.model_count = {
		[SCENE_OBJECT_TYPE_ROCK] = 9, --礁石
		[SCENE_OBJECT_TYPE_ICE] = 9, --浮冰
		[SCENE_OBJECT_TYPE_BITE_BOAT] = 6, --鲨鱼
		[SCENE_OBJECT_TYPE_FLAT] = 5, --酒桶
		[SCENE_OBJECT_TYPE_BOX] = 4, --宝箱
		[SCENE_OBJECT_TYPE_SEA_WRECK] = 1, --沉船
		[SCENE_OBJECT_TYPE_MONSTER] = 6, --海怪
		[SCENE_OBJECT_TYPE_XUANWO] = 3, --漩涡
	}

	self.first_complete = false
    self.can_find_wreck = false
    
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
end

function treasureLogic:init()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    scene_ui:addComponent("copy_food_ui", ClsFoodUiComponent)
    scene_ui:callComponent("copy_food_ui", "showBtnBack", true)
    ClsSceneManage:setSceneAttr("show_point_map", true)

    if device.platform == "android" then
        scene_ui:addComponent("copy_voice_ui", ClsVoiceUIComponent)
    end

    if self.end_time ~= nil then
        self:updateTimeUI(self.end_time)
    end
end

function treasureLogic:updateTimeUI(time)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local playerData = getGameData():getPlayerData()
	self.end_time = time
	local function updateTime()
		local curTime = os.time() + playerData:getTimeDelta()
        
        local scene_ui = ClsSceneManage:getSceneUILayer()
        if tolua.isnull(scene_ui) then
            if self.updateTimeHandle then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
                self.updateTimeHandle = nil
            end
            return
        end
  
        scene_ui.time_bg:setVisible(true)
        local remain_time = math.ceil(self.end_time - curTime)
        if remain_time < 0 then 
            remain_time = 0
        end
        local time_str = tostring(remain_time) .. "s"
        scene_ui.time_label:setText(time_str)
    end
    
    updateTime()

    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.updateTimeHandle then
        scheduler:unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
    self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime, 1, false)
end

function treasureLogic:hideEvent(event_type, pos_info)
    if (event_type == SCENE_OBJECT_TYPE_SEA_WRECK) then
        --是否可以显示沉船的事件点
        if self.can_find_wreck then
            pos_info.is_wreck = true
            return false
        end
    --在寻宝副本中，判断是否是自己任务的事件类型
    elseif self.m_copy_mission then
        if (event_type == self.m_copy_mission.type) or (event_type == SCENE_OBJECT_TYPE_FLAT) then
            return false
        end
    end
    return true
end

function treasureLogic:updataEventObjectAttr(obj, key, value)
    if obj then
        if obj.event_type == SCENE_OBJECT_TYPE_SEA_WRECK and "owner" == key then
            value = string.gsub(value, "[\[]", "")
            value = string.gsub(value, "]", "")
            value = string.split(value, ",")
            for _, uid in ipairs(value) do
                if tonumber(uid) == self.m_my_uid then
                    obj:setVisible(true)
                    return
                end
            end
            obj:setVisible(false)
            return
        end
        obj:updataAttr(key, value)
    end
end
     
function treasureLogic:updateMissions()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    local missions = getGameData():getCopySceneData():getTreasureMissions()
    for _, mission in pairs(missions) do 
        if mission.uid == self.m_my_uid then
            self.m_copy_mission = mission
            if mission.progress >= mission.times then
                self.can_find_wreck = true
            end
            break
        end
    end
    scene_ui:callComponent("copy_mission_ui", "updateMissions")
end

function treasureLogic:getResuleLayer(result_info, callBack)
	self.resultUI = getUIManager():create("gameobj/copyScene/treasureResultUI", nil, result_info, callBack)
	return self.resultUI
end

function treasureLogic:createPlayerShip(parent)
    local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")
    return ClsCopyPlayerShipsLayer.new(parent)
end

function treasureLogic:cancelRecord()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    if device.platform == "android" then
        scene_ui:callComponent("copy_voice_ui", "cancelRecord")
    end
end

function treasureLogic:onExit()
    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.updateTimeHandle then
        scheduler:unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
end

return treasureLogic
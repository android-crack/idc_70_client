--
-- Author: lzg0496
-- Date: 2016-08-19 14:29:06
-- Function: 新手副本逻辑

local copySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local copy_wall_config = require("game_config/copyScene/copy_treasure_wall_config")
local ClsFoodUiComponent = require("gameobj/copyScene/copySceneComponent/clsFoodUiComponent")
local ClsManualDescComponent = require("gameobj/copyScene/copySceneComponent/clsManualDescComponent")

local manualLogic = class("manualLogic", copySceneLogicBase)

function manualLogic:ctor()
    self.map_land_params = {
        bit_res = "explorer/copy_scene_manual_map.bit",
        map_res = "explorer/map/land/copy_scene_manual_land.tmx", --地图资源
        tile_height = 47, --地图高度，格子数目
        tile_width = 60, -- 地图宽度，格子数目
        block_width_count = 0, --地图宽度遮挡
        block_height_count = 0, --地图高度挡住
        block_up_count = 0,
        block_down_count = 0,
        block_left_count = 0,
        block_right_count = 0,
    }

    --策划每次修改事件表时，都需要告诉相应的程序修改数量值
    self.model_count = {
        [SCENE_OBJECT_TYPE_ROCK] = 2, --礁石
        [SCENE_OBJECT_TYPE_ICE] = 2, --浮冰
        [SCENE_OBJECT_TYPE_BITE_BOAT] = 1, --鲨鱼
        [SCENE_OBJECT_TYPE_FLAT] = 2, --酒桶
        [SCENE_OBJECT_TYPE_SEA_WRECK] = 1, --沉船
        [SCENE_OBJECT_TYPE_MONSTER] = 1, --海怪
        [SCENE_OBJECT_TYPE_BOX] = 0, --宝箱
        [SCENE_OBJECT_TYPE_XUANWO] = 0, --漩涡
    }

    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
end

function manualLogic:init()
    local scene_ui = ClsSceneManage:getSceneUILayer()
    scene_ui:addComponent("copy_food_ui", ClsFoodUiComponent)
    scene_ui:addComponent("copy_guide_ui", ClsManualDescComponent)
    ClsSceneManage:setSceneAttr("show_point_map", true)
    ClsSceneManage:getSceneLayer():getPlayerShip():setIsCheckCameraFollow(true)
    scene_ui:getBtnExit():setEnabled(false)
end

function manualLogic:updateTimeUI(time)
    self.end_time = time
    local playerData = getGameData():getPlayerData()
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
        local remain_time = self.end_time - curTime
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

function manualLogic:tryToShowGuildArrow(event_obj, str_tip)
    event_obj:createLeadActionAndTip(str_tip)
end

--添加导航提示
function manualLogic:addNavigate()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local map_layer = ClsSceneManage:getSceneMapLayer()
    local scene_layer = ClsSceneManage:getSceneLayer()

    local road_target_config = {{10,32}}
    local touch_pos_vec3s = {}
    for k, v in ipairs(road_target_config) do
        local co_pos = map_layer:tileSizeToCocos2(ccp(v[1],v[2]))
        pos_vec3 = cocosToGameplayWorld(co_pos)
        touch_pos_vec3s[k] = pos_vec3
    end
    self:addMultiPathEffect(touch_pos_vec3s)
end

function manualLogic:addMultiPathEffect(touchPoss)
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

function manualLogic:clearMultiPathEffect()
    if self.pathEffInfos then
        for k, v in ipairs(self.pathEffInfos) do
            v.pathClickParticles:Release()
        end
        self.pathEffInfos = nil
    end
end

function manualLogic:createPlayerShip(parent)
    local ClsCopyPlayerShipsLayer = require("gameobj/copyScene/clsCopyPlayerShipsLayer")
    return ClsCopyPlayerShipsLayer.new(parent)
end

function manualLogic:onExit()
    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.updateTimeHandle then
        scheduler:unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
end

return manualLogic
--
-- Author: lzg0946
-- Date: 2016-08-31 16:44:28
-- Function: 大乱斗系统逻辑

local copySceneLogicBase = require("gameobj/copyScene/copySceneLogicBase")
local ClsChatUiComponent = require("gameobj/copyScene/copySceneComponent/clsChatUiComponent")
local ClsIntegralUiComponent = require("gameobj/copyScene/copySceneComponent/clsIntegralUiComponent")
local ClsEndTimeUiComponent = require("gameobj/copyScene/copySceneComponent/clsEndTimeUiComponent")
local ClsHeartUiComponent = require("gameobj/copyScene/copySceneComponent/clsHeartUiComponent")
local clsWaitComponent = require("gameobj/copyScene/copySceneComponent/clsWaitComponent")
local dataTools = require("module/dataHandle/dataTools")
local ClsUiWord = require("game_config/ui_word")
local melee_score = require("game_config/copyScene/melee_score")
local ClsVSUIComponent = require("gameobj/copyScene/copySceneComponent/clsVSUIComponent")

local MAX_JOIN_AMOUNT = 30

local clsMeleeLogic = class("clsMeleeLogic", copySceneLogicBase)

function clsMeleeLogic:ctor()
    self.map_land_params = {
        bit_res = "explorer/copy_scene_melee_map.bit",
        map_res = "explorer/map/land/copy_scene_melee_land.tmx", --地图资源
        tile_height = 28, --地图高度，格子数目
        tile_width = 56, -- 地图宽度，格子数目
        block_width_count = 8, --地图宽度遮挡
        block_height_count = 5, --地图高度挡住
        block_up_count = 5,
        block_down_count = 5,
        block_left_count = 8,
        block_right_count = 8,
    }

    --策划每次修改事件表时，都需要告诉相应的程序修改数量值
    self.model_count = {
    }

    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
end

function clsMeleeLogic:init()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    scene_ui:addComponent("vs_ui", ClsVSUIComponent)

    scene_ui:setEnabledUI(true)
    ClsSceneManage:setSceneAttr("show_point_map", true)
    getUIManager():create("gameobj/chat/clsChatComponent")
    self:setTopFightStatus()
    if self.end_time ~= nil then
        self:updateTimeUI(self.end_time)
    end
end

function clsMeleeLogic:updateTimeUI(time)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    self.end_time = time

    local function updateTime()
        local scene_ui = ClsSceneManage:getSceneUILayer()
        if tolua.isnull(scene_ui) then
            if self.updateTimeHandle then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
                self.updateTimeHandle = nil
            end
            return
        end

        local cur_time = os.time() + getGameData():getPlayerData():getTimeDelta()
        self.remain_time = math.ceil(self.end_time - cur_time)
        if self.remain_time < 0 then
            self.remain_time = 0
        end
        local time_str = dataTools:getTimeStrNormal(self.remain_time)
        scene_ui:callComponent("end_time_ui", "updateTimeUI", time_str)
    end

    updateTime()

    local scheduler = CCDirector:sharedDirector():getScheduler()
    if self.updateTimeHandle then
        scheduler:unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
    self.updateTimeHandle = scheduler:scheduleScriptFunc(updateTime, 1, false)

end

function clsMeleeLogic:updateRankUI(list, my_rank)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    if not tolua.isnull(scene_ui) then
        scene_ui:callComponent("integral_ui", "updateRankUI", list, my_rank, melee_score)
    end

    if tolua.isnull(self.ship_layer) then return end
    self.ship_layer:updateAllShipStatus()
end

function clsMeleeLogic:updateHeart(amount)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    if not tolua.isnull(scene_ui) then
        scene_ui:callComponent("heart_ui", "updateHeart", amount)
    end
end

function clsMeleeLogic:updateAttrText(val)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    if not tolua.isnull(scene_ui) then
        scene_ui:callComponent("heart_ui", "updateAttrText", val)
    end
end

function clsMeleeLogic:createPlayerShip(parent)
    self:setAttackStatus(true)
    local clsCopyMeleePlayerShipsLayer = require("gameobj/copyScene/clsCopyMeleePlayerShipsLayer")
    self.ship_layer = clsCopyMeleePlayerShipsLayer.new(parent)
    return self.ship_layer
end

function clsMeleeLogic:setAttackStatus(status)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:setSceneAttr("isAttack", status)
end

function clsMeleeLogic:updateWaitTime(times)
    local scene_manage = require("gameobj/copyScene/copySceneManage")
    local copy_scene_ui = scene_manage:getSceneUILayer()
    if not tolua.isnull(copy_scene_ui) then
        copy_scene_ui:callComponent("wait_time_ui", "updateWaitTime", times, true)
    end
end

function clsMeleeLogic:setTopFightStatus()
    local copy_scene_data = getGameData():getCopySceneData()
    local status = copy_scene_data:getMeleeStatus()
    local scene_manage = require("gameobj/copyScene/copySceneManage")
    local copy_scene_ui = scene_manage:getSceneUILayer()
    self:setAttackStatus(status == PVP_STATUS)

    if tolua.isnull(copy_scene_ui) or status == nil then
        return
    end

    if status == WAIT_STATUS then
        copy_scene_ui:addComponent("wait_time_ui", clsWaitComponent)
        return
    end

    copy_scene_ui:callComponent("wait_time_ui", "hideWaitTime")
    if status == PVE_STATUS then
        copy_scene_ui:callComponent("wait_time_ui", "playfightEffect")
    end
    copy_scene_ui:addComponent("integral_ui", ClsIntegralUiComponent)
    copy_scene_ui:addComponent("end_time_ui", ClsEndTimeUiComponent)
    copy_scene_ui:addComponent("heart_ui", ClsHeartUiComponent)
    local copySceneData = getGameData():getCopySceneData()
    local my_life = copySceneData:getMyLife()
    self:updateHeart(my_life)
    local rank_list = copySceneData:getRankList()
    local my_rank = copySceneData:getMyRank()
    self:updateRankUI(rank_list, my_rank)
    if self.end_time ~= nil then
        self:updateTimeUI(self.end_time)
    end
end

function clsMeleeLogic:isLockShowPlayerDetail()
	local scene_manage = require("gameobj/copyScene/copySceneManage")
	if MELEE_WRECK_STATUS == scene_manage:getSceneAttr("top_fight_status") or PVE_STATUS == scene_manage:getSceneAttr("top_fight_status") then
		return true
	end
	return false
end

function clsMeleeLogic:updateJoinAmount(amount)
    local scene_manage = require("gameobj/copyScene/copySceneManage")
    local copy_scene_ui = scene_manage:getSceneUILayer()
    if not tolua.isnull(copy_scene_ui) then
        copy_scene_ui:callComponent("wait_time_ui", "updateJoinAmount", amount, MAX_JOIN_AMOUNT)
    end
end

function clsMeleeLogic:updateEventBuffCD(end_time)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local event_objs = ClsSceneManage:getAllEventObj()
    for _, obj in pairs(event_objs) do
        if obj.event_type == SCENE_OBJECT_TYPE_MELEE_GOD then
            if type(obj.updateBuffCD) == "function" then
                obj:updateBuffCD(end_time)
            end
        end
    end
end

function clsMeleeLogic:hideEvent(event_type, pos_info)
    if (event_type == SCENE_OBJECT_TYPE_MELEE_GOD) then
        pos_info.is_melee_red = true
        local melee_status = getGameData():getCopySceneData():getMeleeStatus()
        if melee_status == PVP_STATUS then
            return false
        else
            return true
        end
    end
    if (event_type == SCENE_OBJECT_TYPE_MELEE_BOSS or event_type == SCENE_OBJECT_TYPE_MELEE_WRECK) then
        pos_info.is_melee_red = true
        return false
    end
end

function clsMeleeLogic:isPlayer(uid)
    local player_data = getGameData():getPlayerData()
    return player_data:getUid() ~= uid
end

function clsMeleeLogic:getExitTips()
    return ClsUiWord.STR_MELEE_EXIT_TIPS
end

function clsMeleeLogic:onExit()
    if self.updateTimeHandle then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateTimeHandle)
        self.updateTimeHandle = nil
    end
end

function clsMeleeLogic:checkAlert()
    if not getGameData():getSceneDataHandler():isInCopyScene() then return end
    local Alert = require("ui/tools/alert")
    Alert:warning({msg = ClsUiWord.MELEE_STATION_USE_TIPS})
    return true
end

return clsMeleeLogic

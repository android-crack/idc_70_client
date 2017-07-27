--create by ckx0042

local ModuleCopySceneServerOpt = {}
ModuleCopySceneServerOpt.copySceneCameraEffect = function(tx, ty, moveTime, pauseTime )
   	local scene_3d = Explore3D:getScene()
    if not scene_3d then return end
    local cam_node = scene_3d:findNode("Camera")
    if not cam_node then
        cam_node = scene_3d:addNode("Camera")
    end

    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    local scene_layer = ClsSceneManage:getSceneLayer()
    local map_layer = ClsSceneManage:getSceneMapLayer()

    local player_ship = scene_layer:getPlayerShip()
    local player_ship_vec3 = player_ship.node:getTranslationWorld()
    cam_node:setTranslation(player_ship_vec3)
    CameraFollow:LockTarget(cam_node)
    local co_pos = map_layer:tileSizeToCocos2(ccp(tx, ty))
    local tpos_vec3 = cocosToGameplayWorld(co_pos)
    local key_count = 2
    local move_time_n = moveTime/1000
    local key_times = {0, moveTime}
    local forward_key_values = {player_ship_vec3:x(), 0, player_ship_vec3:z(), tpos_vec3:x(), 0, tpos_vec3:z()}
    local back_key_values = {tpos_vec3:x(), 0, tpos_vec3:z(), player_ship_vec3:x(), 0, player_ship_vec3:z()}

    ClsSceneManage:doLogic("setPlayerShipMove", false)

    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function()
        local forward_anim = cam_node:createAnimation("camMove", Transform.ANIMATE_TRANSLATE(), key_count, key_times, forward_key_values, "LINEAR")
        forward_anim:play()
    end))
    array:addObject(CCDelayTime:create(move_time_n))
    array:addObject(CCDelayTime:create(pauseTime/1000))

    if ClsSceneManage:doLogic("isInSeaGodScene") then 
        array:addObject(CCCallFunc:create(function()
            ClsSceneManage:doLogic("sumonBoss")
        end))
    else
        array:addObject(CCCallFunc:create(function()
            local back_anim = cam_node:createAnimation("camMove", Transform.ANIMATE_TRANSLATE(), key_count, key_times, back_key_values, "LINEAR")
            back_anim:play()
        end))
        array:addObject(CCDelayTime:create(move_time_n + 0.1))
        array:addObject(CCCallFunc:create(function()
            CameraFollow:LockTarget(player_ship.node)
            ClsSceneManage:tryToPrepareRunning()
            ClsSceneManage:doLogic("addNavigate")
        end))
    end

    if not tolua.isnull(scene_ui) then
        scene_ui:runAction(CCSequence:create(array))
    end
end

ModuleCopySceneServerOpt.air_wall = function(value)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_layer = ClsSceneManage:getSceneLayer()
    if not tolua.isnull(scene_layer) then
        if string.len(tostring(value)) > 1 then
            scene_layer:getLand():setLockWallConfig(value)
            scene_layer:getLand():setIsShowLockWall(true)
        else
            scene_layer:getLand():setIsShowLockWall(false)

        end
    end
end

ModuleCopySceneServerOpt.start_icon = function()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    if not tolua.isnull(scene_ui) then
        scene_ui:showStartOrEndIconTips(true)
    end
end

ModuleCopySceneServerOpt.mission_bar = function()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local scene_ui = ClsSceneManage:getSceneUILayer()
    local clsMissionUiComponent = require("gameobj/copyScene/copySceneComponent/clsMissionUiComponent")
    scene_ui:addComponent("copy_mission_ui", clsMissionUiComponent)
    scene_ui:callComponent("copy_mission_ui", "updateMissions")
end

ModuleCopySceneServerOpt.remain_time = function(times)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("updateTimeUI", times)
    ClsSceneManage:doLogic("clearMultiPathEffect")
end

ModuleCopySceneServerOpt.wait_time = function(times)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateWaitTime", times)
end

ModuleCopySceneServerOpt.top_fight_status = function(status)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local copy_scene_data = getGameData():getCopySceneData()
    copy_scene_data:setMeleeStatus(status)
    ClsSceneManage:doLogic("setTopFightStatus")

end

ModuleCopySceneServerOpt.join_amount = function(amount)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateJoinAmount", amount)
end

ModuleCopySceneServerOpt.your_users = function(users)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateEnemyPeople", users)
end

ModuleCopySceneServerOpt.our_users = function(users)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateMePeople", users)
end

ModuleCopySceneServerOpt.your_score = function(points)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateEnemyPoint", points)
end

ModuleCopySceneServerOpt.our_score = function(points)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateMePoint", points)
end

ModuleCopySceneServerOpt.our_name = function(name)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateMyName", name)
end

ModuleCopySceneServerOpt.your_name = function(name)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateEnemyName", name)
end

ModuleCopySceneServerOpt.group_battle_status = function(status)
    local guild_fight_data = getGameData():getGuildFightData()
    guild_fight_data:setGroupFightStatus(status)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("updateGuildFightStatus")
end

ModuleCopySceneServerOpt.battle_effect = function()
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    local copy_scene_ui = ClsSceneManage:getSceneUILayer()
    if tolua.isnull(copy_scene_ui) then
        return
    end
    ClsSceneManage:doLogic("playFightMusic")
    copy_scene_ui:showFightEffect()
end

ModuleCopySceneServerOpt.ending_effect = function(win_camp)
    local copy_scene_data = getGameData():getCopySceneData()
    copy_scene_data:setCopyWinCamp(win_camp)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("showResultUI", win_camp)
    ClsSceneManage:doLogic("showResultTips", win_camp, true)
end

ModuleCopySceneServerOpt.port_battle_status = function(status)
	local port_battle_data = getGameData():getPortBattleData()
	port_battle_data:setPortBattleStatus(status)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	ClsSceneManage:doLogic("updatePortBattleStatus", status)
end

ModuleCopySceneServerOpt.battle_failed = function(camp)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("showBattleFail", camp)
end

ModuleCopySceneServerOpt.camp_name_1 = function(defend_name)
    local port_battle_data = getGameData():getPortBattleData()
    port_battle_data:setDefenderName(defend_name)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setDefenderName")
end

ModuleCopySceneServerOpt.camp_name_2 = function(attack_left_name)
    local port_battle_data = getGameData():getPortBattleData()
    port_battle_data:setAttackerLeftName(attack_left_name)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setAttackerLeftName")
    ClsSceneManage:setSceneAttr("camp_name_2", attack_left_name)
end

ModuleCopySceneServerOpt.camp_name_3 = function(attack_right_name)
    local port_battle_data = getGameData():getPortBattleData()
    port_battle_data:setAttackerRightName(attack_right_name)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setAttackerRightName")
    ClsSceneManage:setSceneAttr("camp_name_3", attack_right_name)
end

ModuleCopySceneServerOpt.camp_amount_2 = function(attack_left_pepole)
    local port_battle_data = getGameData():getPortBattleData()
    port_battle_data:setAttackerLeftPeople(attack_left_pepole)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setAttackerLeftPeople")
end

ModuleCopySceneServerOpt.camp_amount_3 = function(attack_right_people)
    local port_battle_data = getGameData():getPortBattleData()
    port_battle_data:setAttackerRightPeople(attack_right_people)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setAttackerRightPeople")
end

ModuleCopySceneServerOpt.camp_morale_1 = function(buff)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setCampBuff", buff, 1)
end

ModuleCopySceneServerOpt.camp_morale_2 = function(buff)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setCampBuff", buff, 2)
end

ModuleCopySceneServerOpt.camp_morale_3 = function(buff)
    local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
    ClsSceneManage:doLogic("setCampBuff", buff, 3)
end

return ModuleCopySceneServerOpt

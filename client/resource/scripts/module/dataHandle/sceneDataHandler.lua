--2016/07/19
--create by wmh0497
--场景信息存储

local SCENE_TPYE = {
    PORT = "port",
    EXPLORE = "explore", --普通探索
    COPY = "copy",
    MISSION3D = "mission3d",
}
local ClsSceneDataHandler = class("ClsSceneDataHandler")

function ClsSceneDataHandler:ctor()
    self.m_scene_id = nil
    self.m_scene_type = nil
    self.m_map_id = nil
    self.m_init_pos = nil
    self.m_is_same_scene = false
    self.m_my_info = {}
end

function ClsSceneDataHandler:setSceneInfo(scene_id, type_n, map_id)
    local before_scene_id = self.m_scene_id
    self.m_scene_id = scene_id
    self.m_is_same_scene = false
    if type_n == SCENE_TPYE_ID.PORT then--港口
        self.m_scene_type = SCENE_TPYE.PORT
        if self.m_scene_id == before_scene_id then
            self.m_is_same_scene = true
        end
    elseif type_n == SCENE_TPYE_ID.EXPORT then--海域
        if self.m_scene_type == SCENE_TPYE.EXPLORE then
            self.m_is_same_scene = true
        end
        self.m_scene_type = SCENE_TPYE.EXPLORE
    elseif type_n == SCENE_TPYE_ID.COPY then--副本
        if self.m_scene_id == before_scene_id then
            self.m_is_same_scene = true
        end
        self.m_scene_type = SCENE_TPYE.COPY
    end
    self.m_map_id = map_id
    return self.m_is_same_scene
end

function ClsSceneDataHandler:setMissionScene(mission3d_id)
	self.m_is_same_scene = false
	if self:isInMission3dScene() and self.m_scene_id == mission3d_id then
		self.m_is_same_scene = true
	end
    self.m_scene_id = mission3d_id
    self.m_scene_type = SCENE_TPYE.MISSION3D
    self.m_map_id = mission3d_id
end

function ClsSceneDataHandler:setSceneInitPos(x, y)
    self.m_init_pos = { ["x"] = x, ["y"] = y}
end

function ClsSceneDataHandler:setSceneMyPlayerInfo(my_uid, ship_id, name, add_speed, camp_n, icon)
    self.m_my_info = {}
    self.m_my_info.uid = my_uid
    self.m_my_info.ship_id = ship_id
    self.m_my_info.name = name
    self.m_my_info.add_speed = add_speed
    self.m_my_info.camp = camp_n
    self.m_my_info.icon = icon
end

function ClsSceneDataHandler:getMyUid()
    return self.m_my_info.uid or 0
end

function ClsSceneDataHandler:getMyIcon()
    return self.m_my_info.icon or 0
end

function ClsSceneDataHandler:getMyShipId()
    return self.m_my_info.ship_id or 1
end

function ClsSceneDataHandler:getMyName()
    return self.m_my_info.name or ""
end

function ClsSceneDataHandler:getMyAddSpeed()
    return self.m_my_info.add_speed or 0
end

function ClsSceneDataHandler:getMyCamp()
    return self.m_my_info.camp or 0
end

function ClsSceneDataHandler:getSceneInitPos()
    return self.m_init_pos
end

function ClsSceneDataHandler:getSceneId()
    return self.m_scene_id
end

function ClsSceneDataHandler:getSceneType()
    return self.m_scene_type
end

function ClsSceneDataHandler:getSceneTypeConfig()
    return SCENE_TPYE
end

function ClsSceneDataHandler:getMapId()
    return self.m_map_id
end

function ClsSceneDataHandler:isSameScene(is_clean)
    local result_b = self.m_is_same_scene
    if is_clean then
        self.m_is_same_scene = false
    end
    return result_b
end

function ClsSceneDataHandler:isInExplore()
    if SCENE_TPYE.EXPLORE == self.m_scene_type then
        return true
    end
    return false
end

function ClsSceneDataHandler:isInCopyScene()
    if SCENE_TPYE.COPY == self.m_scene_type then
        return true
    end
    return false
end

function ClsSceneDataHandler:isInMission3dScene()
    if SCENE_TPYE.MISSION3D == self.m_scene_type then
        return true
    end
    return false
end

function ClsSceneDataHandler:isInPortScene()
    if SCENE_TPYE.PORT == self.m_scene_type then
        return true
    end
    return false
end

function ClsSceneDataHandler:cleanInfo()
    self.m_scene_id = nil
    self.m_scene_type = nil
    self.m_map_id = nil
    self.m_init_pos = nil
end
return ClsSceneDataHandler
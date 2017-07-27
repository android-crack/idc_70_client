local map_partition = require("game_config/explore/explore_map_partition")
local ClsCompositeEffect = require("gameobj/composite_effect")

local ExploreUtil = {}

local TILE_SIZE = 64   
local TILE_HEIGHT = 960	
local TILE_WIDTH  = 1695
local LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT
local LAND_WIDTH  = TILE_SIZE * TILE_WIDTH 

function ExploreUtil:showClickEffect(x, y, parent)
	parent = parent or GameUtil.getRunningScene()
	ClsCompositeEffect.bollow(CLICK_EFFECT, x, y, parent, 0.5)
end

ExploreUtil.cocosToTile2 = function(self, position)  
	return ccp(position.x * TILE_SIZE + TILE_SIZE / 2, LAND_HEIGHT - position.y * TILE_SIZE - TILE_SIZE / 2)
end

ExploreUtil.cocosToTile = function(self, position)
    local x = math.floor(position.x / TILE_SIZE)
    local y = math.floor((LAND_HEIGHT - position.y) / TILE_SIZE)
    return ccp(x, y)
end

function ExploreUtil:navgationToPostion(cfg)
    local tPos = cfg.pos 

    local colorLayer = CCLayerColor:create(ccc4(0, 0, 0, 255))
    colorLayer:setOpacity(0)
    local function onTouch(eventType, x, y)
        
    end
    colorLayer:registerScriptTouchHandler(onTouch, false, -200, true)

    local scene = display.getRunningScene()
    if tolua.isnull(scene) then return end
    scene:addChild(colorLayer, 1001)

    local array = CCArray:create()
    local time = 0.5
    local dx_time = 0.5
    array:addObject(CCFadeIn:create(time))
    array:addObject(CCFadeOut:create(dx_time))
    array:addObject(CCCallFunc:create(function()
        colorLayer:removeFromParentAndCleanup(true)
    end))

    local arrayTemp = CCArray:create()
    arrayTemp:addObject(CCDelayTime:create(time - 0.05))
    arrayTemp:addObject(CCCallFunc:create(function()
        local exploreLayer = getExploreLayer()
        exploreLayer.player_ship:setPos(tPos.x, tPos.y)
        exploreLayer.seaNode:setTranslation(exploreLayer.player_ship.node:getTranslationWorld())
        exploreLayer.land:initLandField()
        CameraFollow:update(exploreLayer.player_ship)
        exploreLayer.land:update(1 / 60)
        local ui = getExploreUI()
        local angle = 0
        exploreLayer:shipRotate(angle)
        ui.world_map:setShipPosInfo({angle = angle, x = tPos.x, y = tPos.y})
        ui.world_map:showMin()
        EventTrigger(EVENT_EXPLORE_MYSHIP_PAUSE)
        
    end))
    local actionFade = CCSequence:create(array)
    local createAction = CCSequence:create(arrayTemp)
    local spawn = CCSpawn:createWithTwoActions(actionFade, createAction)
    colorLayer:runAction(spawn)
end

function ExploreUtil:getPartitionId(pos)  
    for k, v in ipairs(map_partition) do
        local rect = CCRect(v.start_pos[1], v.start_pos[2], v.width, v.height)
        if rect:containsPoint(pos) then 
            return k
        end 
    end 
end

function ExploreUtil:createEachPoint(pos_st, end_pos, AStar)
    local pos_end = end_pos  -- 目标点
    local path = AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1)
    if not path then
        return
    end
    return path
end

function ExploreUtil:createPathPoints(AStar, pos_st, pos_end)
   
    local path = {}
    local par_st = self:getPartitionId(pos_st)
    local par_end = self:getPartitionId(pos_end)
    return self:createEachPoint(pos_st, pos_end, AStar)
    -- if par_st and par_end then 
    --     --local pass_tab = map_partition[par_st].pass_partition[par_end]
    --     -- if pass_tab and #pass_tab > 0 then 
    --     --     local tab_count = #pass_tab
    --     --     local paths = {}
    --     --     for i = 1, tab_count do
    --     --         local partition_id = pass_tab[i]
    --     --         local pos = map_partition[partition_id].key_pos
    --     --         local t_path = nil
    --     --         if i == 1 then
    --     --             t_path = self:createEachPoint(pos_st, ccp(pos[1], pos[2]), AStar)
    --     --         else
    --     --             local front_partition_id = pass_tab[i - 1]
    --     --             local front_pos = map_partition[front_partition_id].key_pos
    --     --             t_path = self:createEachPoint(ccp(front_pos[1], front_pos[2]), ccp(pos[1], pos[2]), AStar)
    --     --         end
    --     --         paths[#paths + 1] = t_path
    --     --     end
    --     --     local end_partition_id = pass_tab[tab_count]
    --     --     if end_partition_id then
    --     --         local end_pos = map_partition[end_partition_id].key_pos
    --     --         local end_path = self:createEachPoint(ccp(end_pos[1], end_pos[2]), pos_end, AStar)
    --     --         paths[#paths + 1] = end_path
    --     --     end
    --     --     for i = 1, #paths do
    --     --         local path_item = paths[i]
    --     --         for j = 1, #path_item do
    --     --             path[#path + 1] = path_item[j]
    --     --         end
    --     --     end
    --     --     return path
    --     -- else
    --     return self:createEachPoint(pos_st, pos_end, AStar)
    --     --end
    -- else
    --     return self:createEachPoint(pos_st, pos_end, AStar)
    -- end
end

function ExploreUtil:getPosNum(path_len)
    local dx = 8
    if path_len >= 180 and path_len < 800 then
        dx = 16
    elseif path_len >= 800 and path_len < 1200 then
        dx = 32
    end
    return dx
end

return ExploreUtil
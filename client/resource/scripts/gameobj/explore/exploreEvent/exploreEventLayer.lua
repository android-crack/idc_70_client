--2016/06/12
--create by wmh0497
--用于管理探索事件

local explore_event = require("game_config/explore/explore_event")
local ClsExploreTreasureMapEvent = require("gameobj/explore/exploreEvent/exploreTreasureMapEvent")
local ClsExploreSeaBoatEvent = require("gameobj/explore/exploreEvent/exploreSeaBoatEvent")
local ClsExploreCloudEvent = require("gameobj/explore/exploreEvent/exploreCloudEvent")
local ClsExploreShipWrecksPoint = require("gameobj/explore/clsExploreShipWrecksPoint") --沉船图标刷新
local ClsEventLayerBase = require("gameobj/explore/clsEventLayerBase")

local EVENT_NAME_CONFIG = {
    ["sun_shine"] = {id = -1002, file = "exploreEffectEvent", params = {res = "tx_sunshine", during = 5, down = 80, add_pos = {x= 720, y = -820}}},
    ["treasure_map"] = {id = -1003, file = "exploreTreasureMapEvent"},
    ["explore_wreck"] = {id = -1004, file = "exploreSeaBoatEvent"},

    ["explore_sea_rock"] = {file = "exploreSeaRockEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_SEA_ROCK}},
    ["explore_down_fish"] = {file = "exploreSeaFishEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_SEA_DOWN_FISH, poss = {{x=-20,y=0}, {x=0,y=-20}, {x=0,y=20}, {x=20,y=0}, {x=20,y=-40}, {x=40,y=-20}} }},
    ["explore_sea_shark"] = {file = "exploreSeaFishEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_SEA_SHARK, poss = {{x=0,y=30}, {x=-25,y=-15}, {x=25,y=-20}} }},
    ["explore_sea_werck"] = {file = "exploreDecorateEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_WERCK}},
    ["explore_cloud"] = {file = "exploreCloudEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_CLOUD}},
    ["explore_whale"] = {file = "exploreWhaleEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_WHALE}},
    ["explore_seagull"] = {file = "exploreSeagulEvent", is_decorate = true, params = {evType = SCENE_OBJECT_TYPE_SEAGULL}},

}

local ClsExploreEventLayer = class("ClsExploreEventLayer", ClsEventLayerBase)

function ClsExploreEventLayer:ctor(explore_layer, ui_tag)
    ClsExploreEventLayer.super.ctor(self)
	self.m_explore_layer = explore_layer
	self.m_ui_tag = ui_tag
	self.m_event_pos_cache = {}
	self.m_decorate_hander = require("gameobj/explore/exploreEvent/clsDecorateEventCreateHander").new(self, self.m_explore_layer)

	--ui层东东的创建
	self.m_effect_layer = getUIManager():get("ClsExploreEffectLayer")
	self.m_ui_view = self.m_effect_layer:getEventLayerUIEffectLayer()
end

function ClsExploreEventLayer:isCanCreateEvent()
	return self:checkEventNumInScreen(4)
end

function ClsExploreEventLayer:checkEventNumInScreen(max_num)
	local sum_num = 0
	for _, event in pairs(self.m_custom_event_list) do
		if event:getIsDecorate() then
			sum_num = sum_num + 1
			if sum_num > max_num then
				return false
			end
		end
	end 
	return true
end

local math_abs = math.abs
function ClsExploreEventLayer:isOverlap(eid,x,y)
	local isOverlap = false
	for k,v in pairs(self.m_event_pos_cache) do
		if math_abs(v.x - x) < 64*2 and math_abs(v.y - y) < 64*2 then
			isOverlap = true
			break
		end
	end
	if isOverlap == false then
		self.m_event_pos_cache[eid] = {["x"]= x,["y"]= y}
	end
	return isOverlap
end

function ClsExploreEventLayer:getIsCustomEventLive(id)
	if self.m_custom_event_list[id] then
		return true
	end
	return false
end

function ClsExploreEventLayer:onEnter()
    ClsExploreCloudEvent:clearCloudRecord()
    if ClsExploreTreasureMapEvent:isCreateTreasureMap() then
        self:createCustomEventByName("treasure_map")
    end

    if ClsExploreSeaBoatEvent:isCreateSeaBoat() then
        self:createCustomEventByName("explore_wreck")
        ClsExploreShipWrecksPoint:updateShipWrecksPoint()
    end
end

function ClsExploreEventLayer:onExit()
    ClsExploreCloudEvent:clearCloudRecord()
end

function ClsExploreEventLayer:updateBolck(x, y)
	self.m_decorate_hander:updateBolck(x, y)
end

function ClsExploreEventLayer:update(dt)
	ClsExploreEventLayer.super.update(self, dt)
	self.m_decorate_hander:randomCreateUpdate(dt)
end

function ClsExploreEventLayer:getEventIdByType(type)
    return EVENT_NAME_CONFIG[type].id
end

function ClsExploreEventLayer:createCustomEventByName(event_name, e_id, other_params)
	if self.m_is_release then
		return
	end
	local event_config = EVENT_NAME_CONFIG[event_name]
	if event_config then
		local event_id = e_id or event_config.id
		local file_str = event_config.file
		local params_tab = table.clone(event_config.params)
		if other_params then
			for k, v in pairs(other_params) do
				params_tab[k] = v
			end
		end
		if event_id and file_str then
			if not self.m_custom_event_list[event_id] then
				local event_class = require(string.format("gameobj/explore/exploreEvent/%s", file_str))
				self.m_custom_event_list[event_id] = event_class.new(self, event_id, params_tab)
				self.m_custom_event_list[event_id]:setIsDecorate(event_config.is_decorate or false)
			end
		end
	end
end

--[[
{
["evId"] = 5.000000,
["evType"] = 16.000000,
["jsonArgs"] = "{"y":249,"x":869}",
["x"] = 869.000000,
["y"] = 249.000000,
}
--]]
function ClsExploreEventLayer:createEvent(event_date)
    if self.m_is_release then
        return
    end
    local event_config = explore_event[event_date.evType]
    local event_class = nil
    if event_config then
        if (event_config.event_type == "rock") or (event_config.event_type == "ice") then
            event_class = require("gameobj/explore/exploreEvent/exploreFireEvent")
        elseif (event_config.event_type == "biteBoat") or (event_config.event_type == "monster") then
            event_class = require("gameobj/explore/exploreEvent/exploreFishEvent")
        elseif (event_config.event_type == "mermaid") then
            event_class = require("gameobj/explore/exploreEvent/exploreMermaidEvent")
        elseif (event_config.event_type == "box") or (event_config.event_type == "fat") then
            event_class = require("gameobj/explore/exploreEvent/exploreBoxEvent")
        elseif (event_config.event_type == "storm") then
            event_class = require("gameobj/explore/exploreEvent/exploreStormEvent")
        elseif (event_config.event_type == "forge") then
            event_class = require("gameobj/explore/exploreEvent/exploreFogEvent")
        elseif (event_config.event_type == "cloud") then
            event_class = ClsExploreCloudEvent
        elseif (event_config.event_type == "whale") then
            event_class = require("gameobj/explore/exploreEvent/exploreWhaleEvent")
        elseif (event_config.event_type == "seagull") then
            event_class = require("gameobj/explore/exploreEvent/exploreSeagulEvent")
        elseif (event_config.event_type == "sea_down_fish") then
            event_class = require("gameobj/explore/exploreEvent/exploreSeaFishEvent")
        elseif (event_config.event_type == "coral") or (event_config.event_type == "sea_shark") or
               (event_config.event_type == "sea_werck") or (event_config.event_type == "werck") then
            event_class = require("gameobj/explore/exploreEvent/exploreDecorateEvent")
        elseif (event_config.event_type == "tornado") then
            event_class = require("gameobj/explore/exploreEvent/exploreTornadoEvent")
        elseif (event_config.event_type == "no_wind") or (event_config.event_type == "down_wind") or (event_config.event_type == "head_wind") then
            event_class = require("gameobj/explore/exploreEvent/exploreWindEvent")
        end
    end
    if event_class then
        local eid = event_date.evId
        if self.m_event_list[eid] then
            if self.m_event_list[eid]:getEventType() ~= event_config.event_type then
                print("error!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  has same eid = ", eid)
                table.print(event_date)
            end
        else
            local event_obj = event_class.new(self, eid, event_date)
            if event_obj:getIsEnd() then --创建失败的话，直接移除
                event_obj:release()
            else
                self.m_event_list[eid] = event_obj
            end
        end
        return true
    end
end

function ClsExploreEventLayer:touchEvent(node)
    if not node then return end
    local index = node:getTag("explore_event_id")
    if not index then return end
    local id = tonumber(index)
    local event_obj = self.m_event_list[id]
    if event_obj then
        return event_obj:touch()
    end
end

return ClsExploreEventLayer

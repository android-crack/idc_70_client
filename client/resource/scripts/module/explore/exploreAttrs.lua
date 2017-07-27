-- Explore attrs management and process
local port_info = require("game_config/port/port_info")

local ExploreAttrs = {}

function ExploreAttrs:initExploreAttrs()
	self:regFuns()
end

function ExploreAttrs:regFuns()
	local function evSeaAreaEvent(area_id)  -- 海域改变
		local now_area_id = getGameData():getSceneDataHandler():getMapId()
		if area_id ~= now_area_id then
			local explore_layer = getUIManager():get("ExploreLayer")
			local player_ship = explore_layer:getPlayerShip()
			local x, y = player_ship:getPos()
			local pos = explore_layer:getLand():tileToCocos(ccp(x, y))
			getGameData():getExplorePlayerShipsData():askEnterArea(area_id, pos.x, pos.y, true)
		end
	end

	RegTrigger(EVENT_EXPLORE_SEAAREA_CHANGE, evSeaAreaEvent)
end 

return ExploreAttrs
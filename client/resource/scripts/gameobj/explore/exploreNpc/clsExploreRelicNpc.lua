--遗迹探索事件NPC
local ClsExploreNpcBase  = require("gameobj/explore/exploreNpc/exploreNpcBase")
local ClsExploreShip3d = require("gameobj/explore/exploreShip3d")
local ui_word = require("scripts/game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local music_info = require("game_config/music_info")

local ClsExploreRelicNpc = class("ClsExploreRelicNpc", ClsExploreNpcBase)

local REMOVE_DIS = 1000 * 1000
local TOUCH_ENABLE_DIS = 120 * 120

function ClsExploreRelicNpc:initNpc(data)
	self.data = data
	self.base_data = data.attr
	self.is_can_touch = false
	local util_module = self.m_explore_layer:getLand()
	self.npc_pos = util_module:cocosToTile2({x = self.base_data.ship_pos[1], y = self.base_data.ship_pos[2]})
end

function ClsExploreRelicNpc:update(dt)
	local ship_x, ship_y = self:getPlayerShipPos()
	local dis = self:getDistance2(self.npc_pos.x, self.npc_pos.y, ship_x, ship_y)
	if dis >= REMOVE_DIS then
		--移除
		self:removePirateNpc()
	else
		self:createPirateNpc()
	end
end

function ClsExploreRelicNpc:createPirateNpc()
	if self.pirate_npc then
		return
	else
		local create_ship_para = {
 			id = 113,
            pos = self.npc_pos,
            speed = 0,
            name = ui_word.VIRTUAL_NAME_3,
            name_color = COLOR_RED_STROKE,
            ship_ui = getShipUI(),
		}
	    self.pirate_npc = ClsExploreShip3d.new(create_ship_para)
	    local name_obj = self.pirate_npc:getSailorName()
	    name_obj:setAnchorPoint(ccp(0.5, 0.5))
	    self.pirate_npc:setPlayerNamePos(ccp(0, 115))
	    local id_str = tostring(self.m_id)--self.m_id是NPC的ID
	    self.pirate_npc.node:setTag("exploreNpcLayer", id_str)
	end
end

-- 移除npc
function ClsExploreRelicNpc:removePirateNpc()
	if self.pirate_npc then
		self.pirate_npc:release()
		self.pirate_npc = nil
	end
end

function ClsExploreRelicNpc:touch()
	getUIManager():create("gameobj/relic/clsRelicEventUI", nil, {relic_id = self.base_data.id})
	return true
end

function ClsExploreRelicNpc:release()
	self:removePirateNpc()
end

return ClsExploreRelicNpc
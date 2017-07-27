--
-- Author: lzg0496
-- Date: 2016-10-08 11:50:08
-- 海域争霸管理NPC

local clsExploreMineralPointNpc = require("gameobj/explore/exploreNpc/clsExploreMineralPointNpc")
local clsExploreMineralTruceNpc = require("gameobj/explore/exploreNpc/clsExploreMineralTruceNpc")

local clsExploreMineralManageNpc = class("clsExploreMineralManageNpc")

function clsExploreMineralManageNpc:ctor(npc_layer, id, type_str, data)
    self.npc = nil
    local areaCompetitionHander = getGameData():getAreaCompetitionData()
    if areaCompetitionHander:isOpen() then
        self.npc = clsExploreMineralPointNpc.new(npc_layer, id, type_str, data)
    else
        self.npc = clsExploreMineralTruceNpc.new(npc_layer, id, type_str, data)
    end
end

function clsExploreMineralManageNpc:updateAttr(...)
    if self.npc then
        self.npc:updateAttr(...)    
    end 
end

function clsExploreMineralManageNpc:update(...)
    if self.npc then
        self.npc:update(...)    
    end    
end

function clsExploreMineralManageNpc:touch()
    if self.npc then
        self.npc:touch()    
    end
end

function clsExploreMineralManageNpc:touchMineral()
    if self.npc then
        self.npc:touchMineral()    
    end
end

function clsExploreMineralManageNpc:fireMineral(player_ship)
    if self.npc then
        self.npc:fireMineral(player_ship)    
    end
end

function clsExploreMineralManageNpc:updataUI()
    if self.npc and self.npc.updataUI then
        self.npc:updataUI()    
    end
end


function clsExploreMineralManageNpc:release()
    if self.npc then
        self.npc:release()
        self.npc = nil
    end
end

return clsExploreMineralManageNpc

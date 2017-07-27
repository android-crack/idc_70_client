local exploreNpcType = require("gameobj/explore/exploreNpc/exploreNpcType")

local ClsExploreNpcData = class("ClsExploreNpcData")

function ClsExploreNpcData:ctor()
    self.m_npcs_tab = {}
    self.m_update_other_data_hander = {}
    self:initUpdateDataHanderCfg()
end

function ClsExploreNpcData:initUpdateDataHanderCfg()
    --注意不要把getGameData之类的放到外面，防止数据出错
    self.m_update_other_data_hander[exploreNpcType.PIRATE] = {
        add_func = function(data) getGameData():getExplorePirateEventData():addPirate(data) end,
        update_attr_func = function(attr_key, data, old_value) getGameData():getExplorePirateEventData():updateAttr(attr_key, data, old_value) end,
        remove_func = function(data) getGameData():getExplorePirateEventData():removePirate(data) end
    }
    self.m_update_other_data_hander[exploreNpcType.PIRATE_BOSS] = self.m_update_other_data_hander[exploreNpcType.PIRATE]

    self.m_update_other_data_hander[exploreNpcType.REWARD_PIRATE] = {
        add_func = function(data) getGameData():getExploreRewardPirateEventData():addPirate(data) end,
        update_attr_func = function(attr_key, data, old_value) getGameData():getExploreRewardPirateEventData():updateAttr(attr_key, data, old_value) end,
        remove_func = function(data) getGameData():getExploreRewardPirateEventData():removePirate(data) end
    }
    -- self.m_update_other_data_hander[exploreNpcType.MINERAL_POINT] = {
    --     add_func = function(data) getGameData():getAreaCompetitionData():addMineralPoint(data) end,
    --     update_attr_func = function(attr_key, data, old_value) getGameData():getAreaCompetitionData():updateAttr(attr_key, data, old_value) end,
    --     remove_func = function(data) getGameData():getAreaCompetitionData():removeMineralPoint(data) end
    -- }

    self.m_update_other_data_hander[exploreNpcType.MISSION_PIRATE] = {
        add_func = function(data) getGameData():getMissionPirateData():addPirate(data) end,
        update_attr_func = function(attr_key, data, old_value) getGameData():getMissionPirateData():updateAttr(attr_key, data, old_value) end,
        remove_func = function(data) getGameData():getMissionPirateData():removePirate(data) end
    }
end

function ClsExploreNpcData:removeUselessNpcData()
    -- print(debug.traceback())
    local ids = {}
    for id, data in pairs(self.m_npcs_tab) do
        if data.type == exploreNpcType.MINERAL_POINT then
            ids[#ids + 1] = id
        end
    end
    for _, id in ipairs(ids) do
        self:removeNpc(id)
    end
end

function ClsExploreNpcData:getAllNpcData()
    return self.m_npcs_tab
end

function ClsExploreNpcData:addStandardNpc(npc_id, server_id, type_n, attr_info, cfgid, cfg_item)
    local data = {id = npc_id, server_id = server_id, type = type_n, attr = attr_info, cfg_id = cfgid, cfg_item = cfg_item}
    self:addNpc(data)
end

function ClsExploreNpcData:hasNpcId(id)
	if self.m_npcs_tab[id] then
		return true
	end
	return false
end

function ClsExploreNpcData:addNpc(data)
    if self.m_npcs_tab[data.id] then
        if data.attr then
            for key, value in pairs(data.attr) do
                self:updateNpcAttr(data.id, key, value)
            end
        else
            print("error!!!!!!!!!!!!!!!!  has same npc id")
            table.print(data)
            return
        end
    end
    self.m_npcs_tab[data.id] = data
    local hander_funcs = self.m_update_other_data_hander[data.type]
    if hander_funcs then
        hander_funcs.add_func(data)
    end
end

function ClsExploreNpcData:removeNpc(id)
    local npc_data = self.m_npcs_tab[id]
    if npc_data then
        self.m_npcs_tab[id] = nil
        local hander_funcs = self.m_update_other_data_hander[npc_data.type]
        if hander_funcs then
            hander_funcs.remove_func(npc_data)
        end
        local explore_layer = getExploreLayer()
        if not tolua.isnull(explore_layer) then
            local explore_npc_layer = explore_layer:getNpcLayer()
            if not tolua.isnull(explore_npc_layer) then
                explore_npc_layer:removeNpc(id)
            end
        end
    end
end

function ClsExploreNpcData:updateNpcAttr(id, key, value)
    local npc_data = self.m_npcs_tab[id]
    if npc_data then
        local old_value = npc_data.attr[key]
        npc_data.attr[key] = value
        local hander_funcs = self.m_update_other_data_hander[npc_data.type]
        if hander_funcs then
            hander_funcs.update_attr_func(key, npc_data, old_value)
        end
        local explore_layer = getExploreLayer()
        if not tolua.isnull(explore_layer) then
            local explore_npc_layer = explore_layer:getNpcLayer()
            if not tolua.isnull(explore_npc_layer) then --把这个信息转发到npc层
                explore_npc_layer:callNpc(id, "updateAttr", key, value, old_value)
            end
        end
    end
end

local keyToParams = {
    [1] = "hp",
}
function ClsExploreNpcData:updateChangeNpcAttr(id, key, value)
    local attr_key = keyToParams[key]
    if attr_key then
        self:updateNpcAttr(id, attr_key, value)
    end
end

return ClsExploreNpcData

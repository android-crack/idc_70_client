-- 船只的数据类
-- Author: chelurong
-- Date: 2016-07-05 14:55:16
--
-- // 船只属性
--   7 #define BOAT_ATTR_REMOTE     "remote"     // 远攻
--   8 #define BOAT_ATTR_MELEE      "melee"      // 近攻
--   9 #define BOAT_ATTR_DEFENSE    "defense"    // 防御
--  10 #define BOAT_ATTR_DURABLE    "durable"    // 耐久
--  11 #define BOAT_ATTR_LOAD       "load"       // 货仓
--  12 #define BOAT_ATTR_speed      "speed"      // 速度
--  13 #define BOAT_ATTR_range      "range"      // 射程
--  14 #define BOAT_ATTR_HIT        "hit"        // 命中
--  15 #define BOAT_ATTR_CRITS      "crits"      // 暴击
--  16 #define BOAT_ATTR_ANTI_CRITS "antiCrits" // 抗暴
--  17 #define BOAT_ATTR_DODGE      "dodge"      // 闪避
-- // 船只品质
--  25 #define BOAT_QUALITY_GREEN  1 // 绿
--  26 #define BOAT_QUALITY_BLUE   2 // 蓝
--  27 #define BOAT_QUALITY_VIOLET 3 // 紫

local boat_attr = require("game_config/boat/boat_attr")

local ClsShipData = class("ClsShipData")

function ClsShipData:ctor()
	self.own_boats = {}
	self.boat_list = {}
    self.build_boat_discount = nil
end

function ClsShipData:setBuildDiscount(discount)
    self.build_boat_discount = discount

    local dock_ui = getUIManager():get("ClsDockUI")
    if not tolua.isnull(dock_ui) then
        dock_ui:updateComsumeGold(discount)
    end
end

function ClsShipData:isHaveDiscount()
    if self.build_boat_discount and self.build_boat_discount > 0 then
        return true
    else
        return false
    end
end

function ClsShipData:getBuildDiscount()
    return self.build_boat_discount
end

--船的guid 即key现在是
function ClsShipData:receiveOwnBoats(boats)
    for k, v in ipairs(boats) do
		self:addToOwnBoats(v)
    end
    table.sort(self.own_boats, function(a, b)
        if a and b then
            return a.id < b.id
        end
    end)
end

function ClsShipData:addToOwnBoats(boat)
    if self.boat_list[boat.guid] then
        self:changeBoat(boat)
        return
    end
    self.boat_list[boat.guid] = boat.id
    if boat.is_changed == 0 then--未改过名字，所以用翻译名
        boat.name = boat_attr[boat.id].name
    end
    table.insert(self.own_boats, boat)--删除后的key刚好和新key有可能重复，当排序后可能会出现异常覆盖
    -- self.own_boats[boat.guid] = boat--序列表
end

function ClsShipData:changeBoat(boat)
    if boat.is_changed == 0 then--未改过名字，所以用翻译名
        boat.name = boat_attr[boat.id].name
    end
    for k,v in pairs(self.own_boats) do
        if v.guid == boat.guid then
            self.own_boats[k] = boat
            return
        end
    end
end

function ClsShipData:delBoat(boat_key)
    self.boat_list[boat_key] = nil
    for k,v in pairs(self.own_boats) do
        if v.guid == boat_key then
            self.own_boats[k] = nil
            return
        end
    end
end

function ClsShipData:getOwnBoats()
	return self.own_boats
end

function ClsShipData:getBoatDataByKey(key)
    if not self.own_boats then return end
    for k,v in pairs(self.own_boats) do
        if v.guid == key then
            return v
        end
    end
    return nil
end

function ClsShipData:getNobilityBoatName(nobility_id)
    if nobility_id == 0 then return "" end
    
    local playerData = getGameData():getPlayerData()
    local profession = playerData:getProfession()
    for _, boat in pairs(boat_attr) do
        if tonumber(nobility_id) == boat.nobility_id then
            for i, occup in pairs(boat.occup) do
                if occup == profession then
                    return boat.name
                end
            end
        end
    end
    return ""
end

--请求船舶洗练
function ClsShipData:askBoatWash(src_guid, dst_guid, src_attr, dst_attr)
    GameUtil.callRpc("rpc_server_boat_wash", {src_guid, dst_guid, src_attr, dst_attr}, "rpc_client_boat_wash")
end

--请求船舶拆解
function ClsShipData:askBoatSplit(guid)
    GameUtil.callRpc("rpc_server_boat_split", {guid}, "rpc_client_boat_split")
end

function ClsShipData:askCreateBoat(id, material_id, material_num)
    -- GameUtil.callRpc("rpc_server_boat_create", {id, material_id, material_num})
    GameUtil.callRpc("rpc_server_boat_create", {id,material_id})
end

function ClsShipData:askBuyMaterial(list)
    GameUtil.callRpc("rpc_server_boat_buy_material", {list})
end

--请求洗练船的属性根据左边船等级的颜色
function ClsShipData:askRefineColor(right_boat_key, left_boat_key)
    GameUtil.callRpc("rpc_server_boat_wash_attr_preview", {right_boat_key, left_boat_key})
end

function ClsShipData:askBuildBoatDiscount()
    GameUtil.callRpc("rpc_server_boat_create_discount", {})
end

return ClsShipData
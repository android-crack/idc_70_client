local port_info = require("game_config/port/port_info")
local area_info = require("game_config/port/area_info")
local relic_info = require("game_config/collect/relic_info")
local ui_word = require("game_config/ui_word")

local mapH = 64
local scheduler = CCDirector:sharedDirector():getScheduler()

local Relics = class("RelicData")

function Relics:ctor()
	self.relicHash = {} 
    self.edit_relic_hash = {}
end

function Relics:getOpenRelics()
	local collect = getGameData():getCollectData()
	local open = collect:getRelicsInfo()
	return open
end

local function judgePort(port_id, level)
	if getGameData():getMarketData():getInvestStepByPortId(port_id) < level then
		return false
	end
	return true
end

local function judgeSailor(sailor_id, level)
	local sailor_info = getGameData():getSailorData():getOwnSailorsById(sailor_id)
	if not sailor_info then
		return false
	elseif sailor_info.starLevel < level then
		return false
	end
	return true
end

local function judgeRelic(relic_id, level)
	local relic_infos = getGameData():getCollectData():getRelicsInfosOrderById()
	local check_relic_item = relic_infos[relic_id]
	if not check_relic_item then
		return false
	else
		local star_n  = check_relic_item.star or 0
		if star_n < level then
			return false
		end
	end
	return true
end

local conditions_func = {
	["port"] = judgePort,
	["sailor"] = judgeSailor,
	["relic"] = judgeRelic,
}

--是否满足条件
function Relics:isUnlockOk(relic_id, cond)
	local kind = nil
	if cond.port then
		kind = "port"
	elseif cond.sailor then
		kind = "sailor"
	elseif cond.relic then
		kind = "relic"
	end
	return conditions_func[kind](cond[kind], cond.level)
end

function Relics:isUnlockTotalOk(relic_id)
	local relic_cfg_item = relic_info[relic_id]
	for k, v in ipairs(relic_cfg_item.active_conds) do
		if not self:isUnlockOk(relic_id, v) then
			return false
		end
	end
	return true
end

--该遗迹是否有解锁条件
function Relics:isHaveUnlockConds(relic_id)
	local relic_cfg_item = relic_info[relic_id]
	if #relic_cfg_item.active_conds > 0 then
		return true
	else
		return false
	end
end

function Relics:getCurrentVisitFriendInfo()
	local collect = getGameData():getCollectData()
	local open = collect:getCurrentVisitFriendRelicsInfo()
	return open
end

function Relics:initRelicHash()
	self.relicHash = {}
	local opens = self:getOpenRelics() 
	for i, relic in ipairs(opens) do
		local relicInfo = relic.relicInfo
		local key = relicInfo.coord[1] * mapH + relicInfo.coord[2]
		self.relicHash[key] = relic.id
	end
end

function Relics:initEditRelicHash(list_tab)
	self.edit_relic_hash = {}
	local opens = list_tab
	for i, relic in ipairs(opens) do
		local relicInfo = relic.relicInfo
		local key = relicInfo.coord[1] * mapH + relicInfo.coord[2]
		self.edit_relic_hash[key] = relic.id
	end
end

function Relics:getRelicById(relicId)
	local opens = self:getOpenRelics() 
	local relicData = nil
	for i, relic in ipairs(opens) do
	    if relic.id == relicId then
	    	relicData = relic
	    	return relicData
	    end
	end
end 

function Relics:getRelicIdByPos(pos)  --从位置获取遗迹id
	local key = pos.x * mapH + pos.y
	return self.relicHash[key]
end 

function Relics:setRelicEventStatus(id)
	local collect = getGameData():getCollectData()
	local events = collect:getSuddenlyEvents()
	if events and #events > 0 then
    	for k, v in ipairs(events) do
			if id == v.id then
				v.status = 2
				break;
			end
		end
    end
    table.print(events)
end

function Relics:removeEventId(id)
	local collect = getGameData():getCollectData()
	local events = collect:getSuddenlyEvents()
	table.print(events)
	if events and #events > 0 then
    	for k, v in ipairs(events) do
			if id == v.id and v.status == 2 then
				table.remove(events, k)
				break
			end
		end
    end
    table.print(events)
end

function Relics:isSuddenlyEventByID(id) --是否在突发事件的table中
	local collect = getGameData():getCollectData()
	local events = collect:getSuddenlyEvents()
    local isEvents = false

    if events and #events > 0 then
    	for k, v in ipairs(events) do
			if id == v.id and v.status == 1 then
				isEvents = true
				break
			end
		end
    end
   
	return isEvents
end

function Relics:isSuddenlyEvent(id) --是否在突发事件的table中
	local collect = getGameData():getCollectData()
	local events = collect:getSuddenlyEvents()
    local isEvents = false
    if events and #events > 0 then
    	for k, v in ipairs(events) do
			if id == v.id then
				isEvents = true
				break
			end
		end
    end
   
	return isEvents
end

function Relics:isSuddenlyEventGetRward(id) --是否在突发事件的table中
	local collect = getGameData():getCollectData()
	local events = collect:getSuddenlyEvents()
    local isEvents = false
    if events and #events > 0 then
    	for k, v in ipairs(events) do
			if id == v.id and v.status == 2 then
				isEvents = true
				break
			end
		end
    end
    return isEvents
end

function Relics:isRelicPos(pos) 
	local key = pos.x * mapH + pos.y
	return self.relicHash[key]
end

function Relics:isEditRelicPos(pos) 
	local key = pos.x * mapH + pos.y
	return self.edit_relic_hash[key]
end

function Relics:findMinDistance(pos, func) 
	local opens = getGameData():getCollectData():getRelicsInfosOrderById()
	local minDistance = 0
	local minRelicData = {}
	local target_pos = {}
	local index = 1
	for i, relic in ipairs(relic_info) do
		if nil == opens[i] then
			local relicPos = func(ccp(relic.world_coord[1], relic.world_coord[2]))
			local dis = Math.distance(pos.x, pos.y, relicPos.x, relicPos.y)
			if index == 1 then
				minDistance = Math.distance(pos.x, pos.y, relicPos.x, relicPos.y)
			end
			dis = math.abs(dis)
			if dis <= minDistance then
				minDistance = dis
				target_pos[1] = relicPos.x
				target_pos[2] = relicPos.y
				minRelicData[#minRelicData + 1] = {id = i, relicInfo = relic}
			end
			index = index + 1
		end
	end
	return minDistance, minRelicData[#minRelicData], target_pos
end

--测试用代码，用于测试填的遗迹是否全部在titlemap上有
function Relics:checkAllRelicIsHasRightMapPoint(map_layer)
	for k, v in ipairs(relic_info) do
		local pos = ccp(v.coord[1], v.coord[2])
		if map_layer:tileGIDAt(pos) == 0 then
			print(" id = "..k .. " name = "..v.name.." point error")
		end
	end
end

function Relics:getRelicBuffID() 
	local buffsId = {}
	if self.buffData and self.buffData.buff and self.buffData.buff.fight_buff then
		buffsId[#buffsId + 1] = self.buffData.buff.fight_buff
	else
	end
	return buffsId
end

function Relics:getRelicBattleID()
	local relicBattleConfig = require("game_config/collect/relic_battle")
	local playerData = getGameData():getPlayerData()
	local playerLevel = playerData:getLevel()
	for key, value in pairs(relicBattleConfig) do
		if value.level == playerLevel then
			return value
		end
	end
end

function Relics:setUpdateTimeCallBack(value)
	self.updateTimeCallBack = value
end

function Relics:getExploreShipExtra()
	local speedAdd = 0
	speedAdd = self:getBuffAddValue("relic_buff_ExploreDriveSpeedRaise")
	return speedAdd
end

function Relics:getBattleHonur()
	local honourAdd = self:getBuffAddValue("relic_buff_BattleHonourRaise")
	return honourAdd
end

function Relics:getShopSellGoldAdd()
	local add = self:getBuffAddValue("relic_buff_SellGoodsProfitRaise")
	return add
end

function Relics:getExploreSailorExp()
	local add = self:getBuffAddValue("relic_buff_ExploreSailorExpRaise")
	return add
end

function Relics:getBuffAddValue(keyStatus)
	local addValue = 0
	if self.buffData then
		if self.buffData.statusKey and self.buffData.statusKey == keyStatus then
			for key, value in pairs(self.buffData.buff) do
			 	addValue = value
			end
		end
	end
	return addValue
end

function Relics:askCollectRelicArrive(relic_id)
	GameUtil.callRpc("rpc_server_collect_relic_arrive", {relic_id}) 
end

function Relics:getBuffName(key, value)
	--[[：战斗获得荣誉提升
：商品交易获得金额提升
：探索行驶速度提升
：主角获得经验提升
：航海士出海经验提升
]]
	local configTips = {[10] = ui_word.RELIC_LEVEL1, [20] = ui_word.RELIC_LEVEL2, [30] = ui_word.RELIC_LEVEL3}

	local t = {relic_buff_BattleHonourRaise = ui_word.RELIC_BUFF_SHIQI, relic_buff_SellGoodsProfitRaise = ui_word.RELIC_BUFF_YIJIA,
	 relic_buff_ExploreDriveSpeedRaise = ui_word.RELIC_BUFF_FENGXING, relic_buff_RoleExpRaise = ui_word.RELIC_BUFF_ZHIHUI, 
	 relic_buff_ExploreSailorExpRaise = ui_word.RELIC_BUFF_SHIYING }
	return configTips[toint(value)] .. t[key]
end

function Relics:getBuffImage(key)
	local t = {
	relic_buff_BattleHonourRaise = "#relic_honour_raise.png", 
	relic_buff_SellGoodsProfitRaise = "#relic_goods_profit_raise.png",
	relic_buff_ExploreDriveSpeedRaise = "#relic_drive_speed_raise.png",
	relic_buff_RoleExpRaise = "#relic_roleExp_raise.png", 
	relic_buff_ExploreSailorExpRaise = "#relic_explore_sailor.png" }
	return t[key]
end

function Relics:getFightBuffImage(id)
	local t = 
	{
		[12] = "#relic_speed_icon.png", 
		[13] = "#relic_speed_icon.png",
		[14] = "#relic_speed_icon.png",
		[15] = "#relic_sword_cion.png", 
		[16] = "#relic_sword_cion.png",
		[17] = "#relic_sword_cion.png", 
		[18] = "#relic_storm_icon.png",
		[19] = "#relic_storm_icon.png",
		[20] = "#relic_storm_icon.png", 
		[21] = "#relic_armor_icon.png", 
		[22] = "#relic_armor_icon.png",
		[23] = "#relic_armor_icon.png",
		[24] = "#relic_strong_icon.png", 
		[25] = "#relic_strong_icon.png",
		[26] = "#relic_strong_icon.png",
	}
	return t[id]
end

function Relics:getRelicBuffCD()
	return self.RelicEventCD
end

return Relics
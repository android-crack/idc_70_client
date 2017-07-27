local TYPE_LETTER = 63
local TYPE_SHIP_DRAWING = 175

local testTools = {}

local ALREADY_MKDIR = false

function testTools:userInfo()
	local data = {}

	local player_data = getGameData():getPlayerData()
	local prop_data = getGameData():getPropDataHandler()

	data.level = player_data:getLevel()
	data.coin = player_data:getCash()
	data.diamond = player_data:getGold()
	data.power = player_data:getPower()
	data.town_lv = getGameData():getInvestData():getStep()
	data.rum = player_data:getHonour()
	data.letter = prop_data:getTreasureItemCount(TYPE_LETTER)
	data.junior_hammer = prop_data:getTreasureItemCount(PROP_ITEM_JUNIOR_HAMMER)
	data.high_hammer = prop_data:getTreasureItemCount(PROP_ITEM_HIGH_HAMMER)
	data.mystery_hammer = prop_data:getTreasureItemCount(PROP_ITEM_MYSTERY_HAMMER)
	data.ship_drawing = prop_data:getTreasureItemCount(TYPE_SHIP_DRAWING)

	return data, "UserInfo"
end

function testTools:missionId()
	local data = {}
	data.mission_id = {}

	local mission_data = getGameData():getMissionData()
	local all_mission = mission_data:getMissionAndDailyMissionInfo()

	for k, v in pairs(all_mission) do
		data.mission_id[#data.mission_id + 1] = tonumber(v.id ~= 0 and v.id or v.missionId)
	end

	return data, "MissionId"
end

function testTools:allSailors()
	local data = {}

	local sailor_data = getGameData():getSailorData()
	local all_sailors = sailor_data:getOwnSailors()
	for k, v in pairs(all_sailors) do
		data[v.id] = v.level
	end

	return data, "Sailor"
end

function testTools:allShips()
	local data = {}

	local partner_data = getGameData():getPartnerData()
	local bag_equip_list = partner_data:getBagEquipList()

	local ship_data = getGameData():getShipData()
	local all_ships = ship_data:getOwnBoats()
	for k, ship in pairs(all_ships) do
		local tmp = {}
		tmp.name = ship.name
		tmp.type = ship.id
		tmp.is_equipped = false
		tmp.reinforce = 0

		for i, v in pairs(bag_equip_list) do
			if tonumber(v.boatKey) == tonumber(ship.guid) then
				tmp.is_equipped = true
				tmp.reinforce = v.boatLevel
			end
		end

		data[#data + 1] = tmp
	end

	return data, "Ship"
end

local dataFunc = 
{
	["basic_info"] = testTools.userInfo,
	["all_task"] = testTools.missionId,
	["person_info"] = testTools.allSailors,
	["all_sailer_info"] = testTools.allShips,
}

function testTools:setLoginAccount(id)
	self.login_account = id
end

function testTools:getLoginAccount()
	return self.login_account or 0
end

function testTools:parseMessage(txt)
	if device.platform ~= "windows" then return end

	local start_index, end_index = string.find(txt, "@Order")

	if not start_index then return false end

	local data_type = string.gsub(string.sub(txt, end_index + 1), "^%s*(.-)%s*$", "%1")
	if not dataFunc[data_type] then return end
	
	local data, path_name = dataFunc[data_type](self)

	local player_data = getGameData():getPlayerData()
	data.uid = player_data:getUid()

	local user_default = CCUserDefault:sharedUserDefault()
	local server_info = GTab.SERVER_LIST[user_default:getIntegerForKey("server")]

	data.ip = server_info.ip
	data.server = server_info.name

	path_name = string.format("qc_test\\%s_%s_%d.json", path_name, self:getLoginAccount(), CCTime:getmillistimeofCocos2d())

	if not ALREADY_MKDIR then
		ALREADY_MKDIR = true
		
		os.execute('mkdir qc_test')
	end

	table.save_as_json(data, path_name)

	return true
end

return testTools
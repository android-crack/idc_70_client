-- 组装战斗数据，保存在battle_data中
local dataTools = require("module/dataHandle/dataTools")
local skill_info = require("game_config/skill/skill_info")

local PAOTAI_ID = 21

local ClsBattleDataBase = class("ClsBattleDataBase")

local CURRENT_UID = 
{
	"default_team_id", 
	"target_team_id",
	"neutral_team_id",
	"enemy_team_id",
}

local DATA_NAME = 
{
	"id",				-- 战役base id
	"gen_id",

	FV_BOAT_KEY,
	FV_POWER,

	FV_FLEET_POS,
	FV_ATT_NEAR,
	FV_ATT_FAR,
	FV_FAR_RANGE,
	FV_DEFENSE,
	FV_SPEED,
	FV_HP,
	FV_HP_MAX,
	FV_CRIT_RATE,
	FV_DODGE,

	FV_HIT_RATE,
	FV_RESIST_CRIT,
	FV_DAMAGE_INC,
	FV_DAMAGE_DEC,

	FV_FIRE_RATE,
	FV_MINUS_CD,
}

-- 构建一个战斗数据
ClsBattleDataBase.ctor = function(self)
	self.ships = {}
	self.base_info = {}
end

-- 设置战斗需求数据
local setBaseData
setBaseData = function(data, info)
	for k, v in pairs(DATA_NAME) do
		data[v] = info[v] or 0
	end
end

local sortSkillMark
sortSkillMark = function(boat_key, skills, is_leader)
	if not skills then return end

	local tmp = {}
	for _, v in pairs(skills) do
		if v.ord then
			local temp = {}
			temp.id = v.id
			temp.ord = v.ord

			tmp[#tmp + 1] = temp
		end
	end

	table.sort(tmp, function(t1, t2)
		return t1.ord < t2.ord
	end)

	local skill_sort = {}
	for k, v in ipairs(tmp) do
		if skill_info[v.id] and skill_info[v.id].initiative == SKILL_INITIATIVE then
			skill_sort[#skill_sort + 1] = v.id
		end
	end

	local battle_data = getGameData():getBattleDataMt()
	battle_data:SetData(boat_key, skill_sort)
end

ClsBattleDataBase.translatePVEBoatFightValue = function(self, boats_data)
	local translateBoatAttr = 
	{ 
		["new_ai_id"]	=	"ai_list",			-- 新AI
		["team_id"]		=	"team",				-- 阵营
		["id"]			=	"base_id",			-- id
		["radar_show"]  =	"is_radar_hide"		-- 是否雷达显示
	}

	for _, boat_data in pairs(boats_data) do
		for to_key, from_key in pairs(translateBoatAttr) do
			boat_data[to_key] = boat_data[from_key]
			boat_data[from_key] = nil
		end

		boat_data["uid"] = CURRENT_UID[boat_data.team_id]

		boat_data[FV_BOAT_KEY] = "boat_key" .. boat_data.gen_id

		if tonumber(boat_data.is_leader) == 1 then
			boat_data.is_leader = true
		else
			boat_data.is_leader = false
		end

		if tonumber(boat_data.is_prop) == 1 then 
			boat_data.prop_id = boat_data.boat_id
			boat_data.boat_id = 0

			if boat_data.prop_id == PAOTAI_ID then
				boat_data.new_ai_id[#boat_data.new_ai_id + 1] = "sys_paotai_lock"
			end
		end

		boat_data.is_pve_boat = true

		boat_data.is_prop = nil
		boat_data.is_radar_hide = nil
	end
end

ClsBattleDataBase.translateBoatFightValue = function(self, fromData, base_data, is_default, is_target_team)
	local boatData = {}

	setBaseData(boatData, fromData)

	-- 最大血量赋值
	if boatData[FV_HP_MAX] < boatData[FV_HP] then
		boatData[FV_HP_MAX] = boatData[FV_HP]
	end

	-- tag
	boatData.tag = fromData.tag
	-- uid
	boatData.uid = fromData.uid or base_data.uid
	-- 等级
	boatData.level = fromData.boat_lv
	-- 道具
	boatData.prop_id = fromData.prop_id
	-- 船舶名字
	boatData.name = T(fromData.boat_name)
	-- 船只类型
	boatData.ship_id = fromData.boat_id

	if boatData.ship_id <= 0 then
		boatData.ship_id = 1
	end

	-- 玩家名字
	boatData.fighter_name = base_data.name
	-- 爵位
	boatData.nobility = base_data.nobility
	-- 新AI
	boatData.new_ai_id = fromData.new_ai_id or {}
	-- 头像规格
	boatData.head_id = fromData.head_id or 2
	-- 船上水手
	boatData.sailor_id = fromData.sailor_id or 0
	-- 水手等级
	boatData.sailor_lv = fromData.sailor_lv or 1
	-- 改造特效
	boatData.boatTransStar = tonumber(fromData[FV_BOAT_COLOR])
	-- 是否进场
	boatData.is_enter = tonumber(fromData.is_enter) ~= 1
	-- 是否在小地图上显示
	boatData.radar_show = tonumber(fromData.radar_show) ~= 1
	-- 是否旗舰
	boatData.is_leader = fromData.is_leader
	if fromData.sailor_id == -1 then
		boatData.is_leader = true
		boatData.head_id = 1
		-- 头像
		boatData.sailor_id = tonumber(base_data.icon) > 0 and tonumber(base_data.icon) or 1

		boatData.role = base_data.role
		
		--是否玩家操控的船
		boatData.is_player = is_default
		--测试代码
		if fromData.skills then
			-- fromData.skills[1].id = 3201
		end

		-- boatData.ship_id = 1
	--else
		-- boatData[FV_FAR_RANGE] = 100
		-- boatData.speed = 0
	end

	boatData.is_pve_boat = fromData.is_pve_boat

	if type(boatData.boat_key) == "number" then
		boatData.boat_key = boatData.uid .. boatData.boat_key
	end

	-- 阵营
	boatData.team_id = is_target_team and battle_config.target_team_id or battle_config.default_team_id
	boatData.team_id = fromData.team_id or boatData.team_id

	if boatData.is_leader and not fromData.is_pve_boat then
		if not self.base_info[boatData.team_id] then
			self.base_info[boatData.team_id] = {}
		end
		self.base_info[boatData.team_id].name = base_data.name
		self.base_info[boatData.team_id].level = boatData.level
		self.base_info[boatData.team_id].uid = base_data.uid
		self.base_info[boatData.team_id].power = base_data.power
	end

	if is_default then
		sortSkillMark(boatData.boat_key, fromData.skills, fromData.sailor_id == -1)
	end
	
	local boat_info = dataTools:getNewBoat(boatData.ship_id)
	-- 行走AI
	boatData.walk_Id = fromData.walk_id or (boat_info and boat_info.walk_Id or 0)

	boatData.pos = {["x"] = fromData.x, ["y"] = fromData.y, ["rota"] = fromData.rota}

	boatData.skills = fromData.skills or {}

	return boatData
end

-- 组装战斗数据
ClsBattleDataBase.assembleBattleData = function(self, base_data, is_default, is_target_team)
	for _, boat_data in pairs(base_data.partners or base_data) do
		local boat = self:translateBoatFightValue(boat_data, base_data, is_default, is_target_team)
		if boat then
			if not self.ships[boat.uid] then
				self.ships[boat.uid] = {}
			end
			self.ships[boat.uid][boat_data.boat_key] = boat

			if is_default and boat.is_leader then
				self.cur_client_uid = boat.uid
				self.summon_btn = base_data.summon_btn
			end
		end
	end
end

ClsBattleDataBase.assembleBattleFieldData = function(self, reward, plot_file_name, layer_id, battle_id)
	local battle_data = getGameData():getBattleDataMt()

	local battle_field_data = {}

	battle_field_data.cur_client_uid = self.cur_client_uid

	battle_field_data.summon_btn = self.summon_btn

	-- 我方其它信息
	battle_field_data.mine_info = self.base_info[battle_config.default_team_id]
	-- 对方其它信息
	battle_field_data.enemy_info = self.base_info[battle_config.target_team_id]

	-- 组建船只
	battle_field_data.ships = {}

	for uid, boats in pairs(self.ships) do
		for boat_key, boat_base_data in pairs(boats) do
			table.insert(battle_field_data.ships, boat_base_data)
		end
	end

	-- 数据保存到battle_data中
	battle_data:SetData("battle_field_data", battle_field_data)

	return battle_field_data
end

-- 开始这场战斗
ClsBattleDataBase.startBattle = function(self, battle_field_data, battle_end_cb)
	local battleScene = require("gameobj/battle/battleScene")
	battleScene.startBattle(battle_field_data, battle_end_cb)
end

return ClsBattleDataBase


local ClsBattleDataBase = require("gameobj/battle/battleDataBase")
local music_info = require("game_config/music_info")
local ClsEnterBattle = class("ClsEnterBattle")

-- 进入战斗前镜头的变化
function ClsEnterBattle:loadCameraAi(fighter_mine, plunder_flag)
	local ai_file_name, plot_file_name = "", "plot_special_lueduo_info"
	for k, v in pairs(fighter_mine.partners) do
		if v.boat_key == fighter_mine.flagship then
			if plunder_flag then
				v.new_ai_id = {"special_lueduo_begin_2"}
			else
				v.new_ai_id = {"special_lueduo_begin"}
			end
			break
		end
	end
	return ai_file_name, plot_file_name
end

-- 进入战斗
function ClsEnterBattle:startBattle(params)
	if type(params) ~= "table" then return end

	-- 战斗模块开关,同一时间只允许进入一场战斗
	local battle_data = getGameData():getBattleDataMt()
	if battle_data:GetBattleSwitch() then
		print("Error, In Battle!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
		return
	end

	local port_data = getGameData():getPortData()
    port_data:popBattleReward()

	battle_data:ClearBattleData()

	battle_data:SetBattleSwitch(true)

	getGameData():getAutoTradeAIHandler():setPause(true)

	battle_data:setSession(params.session)

	local attr = params.attr or {}

	if not attr.fight_no_sound or attr.fight_no_sound ~= 1 then
		audioExt.playEffect(music_info.BATTLE_BEGIN.res)
	end

    -- 初始化场景AI
    local scene_ai = params.scene_ai or {}
    for _, ai_id in ipairs(scene_ai) do
        battle_data:addAI(ai_id, {})
    end

    battle_data:SetData("ai_status", params.ai_status or {})
	battle_data:SetData("ui_attr", attr)

	local time = attr.time_out and math.floor(attr.time_out/1000 + 0.5) or battle_config.battle_time
	battle_data:SetData("battle_time_from_server", time)
	time = attr.total_time and attr.total_time/1000 or battle_config.battle_time
	battle_data:SetData("battle_total_time", time)

	battle_data:SetData("is_pvp", params.is_pvp)

	battle_data:SetRecording(false)
	battle_data:SetPlaying(true)

	local battleRecording = require("gameobj/battle/battleRecording")
    -- 初始化战斗录像相关
    battleRecording:startBattle()

	local bdObj = ClsBattleDataBase.new(battleId)

	local uid = params.uid or getGameData():getPlayerData():getUid()
	for team, infos in pairs(params.fighter_info) do
		for k, info in ipairs(infos) do
			bdObj:assembleBattleData(info, info.uid == uid, team == FV_ENEMY)
		end
	end

	local battle_field_data = bdObj:assembleBattleFieldData()

	battle_field_data.plot_file_name = params.plot_file_name or ""
	battle_field_data.layerId = params.layer_id or 1
	battle_field_data.fight_type = params.battle_type
	battle_field_data.preload_list = params.preload_list

	bdObj:startBattle(battle_field_data)
end

function ClsEnterBattle:battleInServerPVP(uid, session, layer_id, fighter_mine, fighter_enemy, ui_attr, preload_list, scene_ai, ai_status)
	local fighter_info = {}

	for k, v in ipairs(fighter_mine) do
		if uid == v.uid then
			fighter_info[FV_MINE] = fighter_mine
			break
		end
	end

	fighter_info[FV_ENEMY] = fighter_info[FV_MINE] ~= nil and fighter_enemy or fighter_mine
	fighter_info[FV_MINE] = fighter_info[FV_MINE] or fighter_enemy

	local attr = {}
	for k, v in pairs(ui_attr) do
		attr[v["key"]] = v["value"]
	end

	local params = {
		uid = uid,
		attr = attr,
		session = session,
		layer_id = layer_id,
		fighter_info = fighter_info,
		preload_list = preload_list,
        scene_ai = scene_ai,
        ai_status = ai_status,

		is_pvp = true,
		battle_type = 300,
	}
	local battle_data = getGameData():getBattleDataMt()
	battle_data:setBattleLayerScale(0.75)
    self:startBattle(params)
end

function ClsEnterBattle:battleInServerPVE(uid, session, layer_id, fighter_mine, player_ai_list, fighter_enemy, ui_attr, preload_list, scene_ai, ai_status)
	ClsBattleDataBase:translatePVEBoatFightValue(fighter_enemy)

	local fighter_info = {
		[FV_MINE] = fighter_mine,
		[FV_ENEMY] = {fighter_enemy},
	}

	for k, v in pairs(fighter_mine[1].partners) do
		if v.sailor_id == -1 then
			v.new_ai_id = player_ai_list
			break
		end
	end

	local attr = {}
	for k, v in pairs(ui_attr) do
		attr[v["key"]] = v["value"]
	end

	local battle_type = 300
	if attr.guild_boss and attr.guild_boss == 1 then
		battle_type = battle_config.fight_type_guild_boss
	end

	if attr.guild_boss then
		local guild_boss_data = getGameData():getGuildBossData()
		guild_boss_data:initPirateKillNum(attr.kill_general_pirate or 0, attr.kill_advanced_pirate or 0,
			attr.remain_pirate_amount, attr.boss_amount, attr.boss_difficulty)
	end

	local plot_file_name = ""
	if attr.plot_id and attr.plot_id > 1000000 then
		plot_file_name = string.format("plot_%d_info", attr.plot_id)
	end

	local params = {
		uid = uid,
		attr = attr,
		session = session,
		layer_id = layer_id,
		fighter_info = fighter_info,
		plot_file_name = plot_file_name,
		preload_list = preload_list,
        scene_ai = scene_ai,
        ai_status = ai_status,

		battle_type = battle_type,
	}
    self:startBattle(params)
end

return ClsEnterBattle

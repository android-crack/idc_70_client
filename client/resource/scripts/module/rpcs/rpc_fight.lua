local error_info = require("game_config/error_info")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local baowu_info = require("game_config/collect/baozang_info")
local battleResult = require("module/battleAttrs/battleResult")
local ClsEnterBattle = require("gameobj/battle/ClsEnterBattle")
local ClsBattleClient = require("gameobj/battle/clsBattleClient")
local skill_warning = require("game_config/skill/skill_warning")

function rpc_client_fight_result(result, err, show_view_str, rewards)
	local port_data = getGameData():getPortData()
	port_data:pushBattleReward(rewards)
end

function rpc_client_battle_info(info) --普通战役
	local battleData = getGameData():getBattleData()
	battleData:receiveBattleInfo(info)
end


---精英战役协议 1.战斗id。2.战役完成list 3.是否是最后一场完成
function rpc_client_elite_info(fighting_id, completed_list,is_all_completed)
	local battleData = getGameData():getBattleData()
	local battle_info_config_data = getGameData():getBattleInfoConfigData()

	battleData:setFightId(fighting_id) 
	battleData:setAllComplated(is_all_completed) 
	if not completed_list then return end   

	for k,fight_id in pairs(completed_list) do
		battleData:receiveEliteBattleInfo(fight_id, battle_info_config_data.ELITE_CONFIG) 
	end

	local ClsEliteBattleUI = getUIManager():get("ClsEliteBattleUI")
	if not tolua.isnull(ClsEliteBattleUI) then
		ClsEliteBattleUI:mkUI()
	end
 
end

--上线登录时，如果玩家有开精英战役，会开最大的章节下来，如果没开则不下发
function rpc_client_elite_battle_max_capter(area)
	 GameUtil.callRpc("rpc_server_elite_battle_list", {area}, "rpc_client_elite_battle_list")
end

function rpc_client_elite_assist_count(count)
	local battle_data = getGameData():getBattleData()
	battle_data:setAssistCount(count)
end

--------------------------------------------------------战斗结束--------------------------------------------------------

--点击船上的攻击按钮---------商会据点战玩家单独攻击
function rpc_client_group_checkpoint_single_fight_result(rewards)
	print("战斗完后----商会据点战玩家单独攻击---返回--", rewards)
	table.print(rewards)
	battleResult.showBattleResult(rewards)
end

--商会据点玩家攻击
function rpc_client_group_checkpoint_fight_result(result, error, list)
	print("战斗完后----商会据点战攻击---返回--", list)
	table.print(list)
	if result == 1 then
		battleResult.showBattleResult(list)
	else
		local msg = error_info[error].message
		Alert:warning({msg = msg})
	end
end

function rpc_client_group_checkpoint_user_buff(buff_list)
	getGameData():getGuildBuffData():setGuildBuffData(buff_list)
end

function rpc_client_group_checkpoint_use_item(result, error, itemId, amount)
	if result == 0 then
		local msg = error_info[error].message
		Alert:warning({msg = msg})
	end
end

-- 竞技场奖励
function rpc_client_arena_result(result, error, rewards)
	battleResult.showBattleResult(rewards)
end

--------------------------------------------------------战斗结束--------------------------------------------------------
--掠夺玩家保护CD
function rpc_client_get_plunder_cd(targetId, cd)
	local current_time = os.time()
	local playerData = getGameData():getPlayerData()
	local current_time = current_time + playerData:getTimeDelta()
	local player_uid = playerData:getUid()
	if player_uid ~= targetId then--不是自己
		local explore_layer = getExploreLayer()
		if tolua.isnull(explore_layer) then return end
		local ships_layer = explore_layer:getShipsLayer()
		if tolua.isnull(ships_layer) then return end
		local ship = ships_layer:getShipByUid(targetId)
		if not tolua.isnull(ship) then
			if tolua.isnull(ship.ui) then
				if tolua.isnull(ship.ui.cd_icon) then
					ship:openLootCdShceduler(cd)
				end
			end
		end
	end
end

-------------------------------------------------------NEW BATTLE-------------------------------------------------------

function rpc_client_fight_final(uid, session, layer_id, attack, defense, ui_attr, preload_list, scene_ai, ai_status)
	setNetPause(true)
	ClsEnterBattle:battleInServerPVP(uid, session, layer_id, attack, defense, ui_attr, preload_list, scene_ai, ai_status)
end

function rpc_client_fight_pve_final(uid, session, layer_id, attack, player_ai_list, defense, ui_attr, preload_list, scene_ai, ai_status)
	setNetPause(true)
	ClsEnterBattle:battleInServerPVE(uid, session, layer_id, attack, player_ai_list, defense, ui_attr, preload_list, scene_ai, ai_status)
end

local function checkCondition(fightId)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return false end

	if battle_data:getSession() ~= fightId then return false end

	return true
end

function rpc_client_set_server(fightId, uid, ai_status)
	local battle_data = getGameData():getBattleDataMt()

	if battle_data:getSession() ~= fightId then return false end

	local is_record = uid == battle_data:getCurClientUid()

	if battle_data:IsRecording() and is_record then return end

	battle_data:SetRecording(is_record)
	battle_data:SetPlaying(not is_record)

	if not battle_data:BattleIsRunning() then return end

	battle_data:runStartAi()
end

function rpc_client_fight_final_result(session, win, rewards, iat, cat)
	local is_far_arena = nil
	local is_melee = nil
	local is_hide_btn = nil
	local battle_data = getGameData():getBattleDataMt()
	local result_cdata = {}
	local result_idata = {}
	for i,v in ipairs(cat) do
		result_cdata[v.key] = v.value
	end
	for i,v in ipairs(iat) do
		result_idata[v.key] = v.value
	end

	local to_panel = result_cdata["return_to_panel"]
	if to_panel then
		if to_panel == "relic" then --遗迹
			local relic_id = result_idata.relic_id
			local team_data = getGameData():getTeamData()
			if not team_data:isInTeam() or team_data:isTeamLeader() then
				local exploreData = getGameData():getExploreData()
				local collect_data = getGameData():getCollectData()
				collect_data:askRelicInfo(relic_id)
				exploreData:setBattleBackRelicID(relic_id)
			end

		--公会boss或者精英战役
		elseif to_panel == "guild_boss" then
			local portData = getGameData():getPortData()
			portData:saveBattleEndLayer("guild_boss_rank")
		elseif to_panel == "fight" then
			local team_data = getGameData():getTeamData()
			if not team_data:isInTeam() or team_data:isTeamLeader() then
				local port_data = getGameData():getPortData()
				port_data:saveBattleEndLayer(to_panel)
			end
		elseif to_panel == "daily_mission_pve" then
			local fight_win = 1
			if win == fight_win then --胜利
				getGameData():getExploreNpcData():removeNpc(-1)
			end
		end
		--elseif to_panel == "main_mission_battle" then --主线战斗
		battle_data:SetData("to_panel", to_panel)
		
	end
   
	for i,v in ipairs(iat) do
		if v.key == "ft" and v.value == battle_config.fight_type_area_boss then --时段海盗
			for k, reward in ipairs(rewards) do
				if reward.type == ITEM_INDEX_SAILOR then
					Alert:battleWarning({msg = ui_word.PLUNDERPOINT_REWARD_SAILOR})
					break
				elseif rewards.type == ITEM_INDEX_BOAT then
					 Alert:showCommonReward(reward)
				end
			end
		end
		if v.key == "team_arena" then
			is_far_arena = true
		end
		if v.key == "return_port" then
			local port_id = v.value
			getGameData():getExploreData():setGoalInfo({id = port_id, navType = EXPLORE_NAV_TYPE_PORT})
		end
		if v.key == "is_seagod" and v.value == 1 then--海神挑战失败了，要弹出提示框
			local is_leader = iat[i + 1].value == 1
			battle_data:SetData("is_seagod", {is_leader = is_leader})
		end

		if v.key == "failure_no_skip" then
			battle_data:SetData("is_hide_prestige_btn", true)
		end
	end

	if battle_data:isAlreadyLoad() then
		require("gameobj/ClsbattleLoadingUI"):remove()
	end

	if not battle_data:GetTable("battle_layer") then return end

	setNetPause(true)

	local hide_camera = false

	local attr = battle_data:GetData("ui_attr")
	if attr and attr.no_rotate_camera == 1 then
		hide_camera = true
	end
	battle_data:GetTable("battle_layer").QuickEndBattle(win == battle_config.our_win, hide_camera)

	local port_data = getGameData():getPortData()
	port_data:pushBattleReward(rewards)
end

function rpc_client_fight_control_list(fightId, shipIds)
	local battle_data = getGameData():getBattleDataMt()

	if battle_data:getSession() ~= fightId then return end

	if not shipIds then return end

	local battle_data = getGameData():getBattleDataMt()

	battle_data:resetUpdateShip()

	for k, v in pairs(shipIds) do
		battle_data:setUpdateShip(v)
	end
end

function rpc_client_fight_move_to_points(fightId, shipId, points)
	if not checkCondition(fightId) then return end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(shipId)

	if not ship or ship:is_deaded() or not ship:getBody() then return end

	local count = #points

	local index = 3
	local tmp_table = {}
	while true do
		if index > count then break end

		tmp_table[#tmp_table + 1] = Vector3.new(points[index]/FIGHT_SCALE, 0, points[index + 1]/FIGHT_SCALE)

		index = index + 2
	end

	ClsBattleClient.moveToByPath(ship:getBody(), tmp_table, FV_MOVE_SERVER)
end

function rpc_client_fight_view_move_to(fightId, shipId, x, y, tx, ty)
	if not checkCondition(fightId) then return end

	local battle_data = getGameData():getBattleDataMt()
	local ship = battle_data:getShipByGenID(shipId)
	if not ship or ship:is_deaded() then return end

	local OFFSET_DISTANCE = 50

	local pos = ship:getPosition3D()

	if not pos then return end

	local scale = 10000
	x = x/scale
	y = y/scale
	tx = tx/scale
	ty = ty/scale

	if not ship:hasBuff("tuji_self") and not ship:hasBuff("chaofeng") and
		math.abs(pos:x() - x) > OFFSET_DISTANCE or math.abs(pos:z() - y) > OFFSET_DISTANCE then
		--ship:getBody().node:setTranslation(Vector3.new(x, 0, y))
		ship:getBody().node:setTranslation(x, 0, y)
		ship:getBody():updateUI()
	end

	ship:moveTo(Vector3.new(tx, 0, ty), "from_server")
end

function rpc_client_fight_view_set_pos(session, id, x, y, angle, stop_speed)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:GetBattleSwitch() then return end

	if battle_data:getSession() ~= session then return end

	local ship = battle_data:getShipByGenID(id)
	if not ship or ship:is_deaded() then return end

	x = x/scale
	y = y/scale
	angle = angle/scale
	stop_speed = stop_speed/scale

	-- ship:setServerPos(x, y)

	local up_vector = nil
	local pao_tai_id = 21
	local pao_guan_id = 25
	if ship.body.id == pao_guan_id or ship.body.id == pao_tai_id then
		up_vector = Vector3.new(0,1,0)
	end

	local sx, sy = ship.body:getPos()

	if math.abs(sx - x) > 5 and
		math.abs(sy - y) > 5 then
		ship.body:setPos(x, y)
	end
	ship.body:setAngle(angle, up_vector)

	-- ship.stopShipSpeed = stop_speed
end

function rpc_client_user_add_ship(fightId, owner, replace_id, ship)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsBattleStart() or not ship then return end

	local battle_data = getGameData():getBattleDataMt()

	local owner_ship = battle_data:getControlShip(owner)

	if not owner_ship then return end

	local base_data = {uid = owner, name = owner_ship:getFighterName()}

	local cur_uid = battle_data:getCurClientUid()

	local ClsBattleDataBase = require("gameobj/battle/battleDataBase")
	local battle_ship_data = ClsBattleDataBase:translateBoatFightValue(ship, base_data,
		owner == cur_uid, owner_ship:getTeamId() == battle_config.target_team_id)

	if not battle_ship_data then return end

	local battle_field_data = battle_data:GetData("battle_field_data")
	table.insert(battle_field_data.ships, battle_ship_data)

	battle_data:subEnter(owner, battle_ship_data, replace_id)
end

function rpc_client_user_add_pve_ship(fightId, ship)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	if not ship then return end

	local ClsBattleDataBase = require("gameobj/battle/battleDataBase")

	ClsBattleDataBase:translatePVEBoatFightValue({ship})

	local battle_ship_data = ClsBattleDataBase:translateBoatFightValue(ship, {name = ""}, false,
		ship.team_id == battle_config.target_team_id)

	if not battle_ship_data then return end

	local ship_obj = require("gameobj/battle/newShipEntity").createShipEntity(battle_ship_data)

	ship_obj:tryOpportunity(AI_OPPORTUNITY.FIGHT_START)
end

function rpc_client_fight_view_add_status(fightId, shipId, statusId, ms, iat, cat)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsBattleStart() then return end

	if battle_data:getSession() ~= fightId then return end

	local ship = battle_data:getShipByGenID(shipId)
	if not ship or ship:is_deaded() then return end

	battle_data:downloadAddStatus(ship, statusId, ms, iat, cat)
end

function rpc_client_fight_view_del_status(fightId, shipId, statusId)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsBattleStart() then return end

	if battle_data:getSession() ~= fightId then return end

	local ship = battle_data:getShipByGenID(shipId)
	if not ship or ship:is_deaded() then return end

	local status = ship:hasBuff(statusId)
	if status then
		status:del(true)
	end
end

function rpc_client_fight_view_add_ai(fightId, shipId, ai_ids)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsBattleStart() then return end

	if battle_data:getSession() ~= fightId then return end

	local target

	if shipId == battle_data:getId() then
		target = battle_data
	elseif shipId > 0 then
		target = battle_data:getShipByGenID(shipId)
	end

	if not target then return end

	for _, ai_id in pairs(ai_ids) do
		target:addAI(ai_id, {})
	end
end

function rpc_client_fight_view_del_ai(fightId, shipId, ai_ids)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsBattleStart() then return end

	if battle_data:getSession() ~= fightId then return end

	local target

	if shipId == battle_data:getId() then
		target = battle_data
	elseif shipId > 0 then
		target = battle_data:getShipByGenID(shipId)
	end

	if not target then return end

	for _, ai_id in pairs(ai_ids) do
		target:deleteAI(ai_id, {})
	end
end

function rpc_client_to_perform_skill(fightId, shipId, skillList)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:IsBattleStart() then return end

	if battle_data:getSession() ~= fightId or not battle_data:isUpdateShip(shipId) then return end

	if not battle_data:canUseSkill() then return end

	local ship = battle_data:getShipByGenID(shipId)

	if not ship or ship:is_deaded() or ship:is_hide() then return end

	for k, ex_skill_id in ipairs(skillList) do
		local skill_id = ship:getIdByExId(ex_skill_id)
		local ret = ship:UseSkill(skill_id, ship:getTarget(), true)
		if ret == skill_warning.OK.msg then
			break
		end
	end
end
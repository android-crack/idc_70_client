local reLinkUICls = require("ui/loginRelinkUI")
local commonBase = require("gameobj/commonFuns")
local skill_info = require("game_config/skill/skill_info")
local status_map = require("game_config/buff/status_map")
local battleRecording = require("gameobj/battle/battleRecording")
local shipEffectLayer = require("gameobj/battle/shipEffectLayer")
local skill_effect_util = require("module/battleAttrs/skill_effect_util")

local NOT_RECORD_AI = 
{
	["sys_youyi"] = true,
	["sys_dodge"] = true,
	["sys_lock_far"] = true,
	["sys_lock_near"] = true,
	["sys_paotai_lock"] = true,
	["sys_lock_far_pve"] = true,
}

local battle_data_mt = class("battle_data_mt")

battle_data_mt.ctor = function(self)
	self:InitBattleData()
end

battle_data_mt.InitBattleData = function(self)
	self._table_ = {}
	self._battle_run_status = false
	self._battle_status = false
	self._ext_data = {}
	self._layer = {}
	self._data = {}
	self._scheduler = {}

	self.ship_pool = {}

	self.effect_id = 1000
	self.drowning_ship = {}

	-- 玩家控制船只
	self.control_ships = {}

	self.leader_ships = {}

	-- 战斗模块开关
	self._battle_switch = false
	self.direct_end = nil

	self.owner_ships_dead = false

	self.show_relink = false

    -- 初始化同步战斗有关数据
    self:initRecordData()

    self.last_rpc_time = 0

    self.joystickPos = nil
    self.joystick_time = 0

    -- 存在战场副舰数量记录
    self.alive_partner = 0

    self.cur_update_ships = {}
    self.auto_ships = {}

    -- ai动作同步表
    self.ai_step_list = {}

    self.is_show_ship_ui = true
    self.is_show_damage_range = true

    self:initAI()
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.setShowShipUI = function(self, value)
	self.is_show_ship_ui = value
end

battle_data_mt.getShowShipUI = function(self)
	return self.is_show_ship_ui
end

battle_data_mt.resetHeartBeatTime = function(self)
	self.heart_time = getCurrentLogicTime()
end

battle_data_mt.setJoyStickPos = function(self, value)
	self.joystickPos = value
end

battle_data_mt.getJoyStickPos = function(self)
	return self.joystickPos
end

battle_data_mt.setJoyStickTime = function(self, value)
	self.joystick_time = value or 0
end

battle_data_mt.getJoyStickTime = function(self)
	return self.joystick_time or 0
end

battle_data_mt.update = function(self)
	local ship = self:getCurClientControlShip()
	if not ship or ship:is_deaded() then return end

	if self:getJoyStickPos() then
		self:setJoyStickTime(self:getJoyStickTime() + 1)

		if self:getJoyStickTime() >= FRAME_CNT_PER_SEC/5 then
			self:setJoyStickPos(nil)
			self:setJoyStickTime(0)
		end
	end
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.SetBattleSwitch = function(self, value)
	self._battle_switch = value
end

battle_data_mt.GetBattleSwitch = function(self)
	return self._battle_switch
end

battle_data_mt.SetShipsDead = function(self, value)
	self.owner_ships_dead = value

	local battle_ui = self:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) and value then
		battle_ui:allShipsDead()
	end
end

battle_data_mt.GetShipsDead = function(self)
	return self.owner_ships_dead
end

battle_data_mt.setSession = function(self, session)
	self.session = session
end

battle_data_mt.getSession = function(self)
	return self.session
end

battle_data_mt.isSkipPlot = function(self)
	return self._data["ui_attr"].click_skip_plot and self._data["ui_attr"].click_skip_plot == 1
end

battle_data_mt.isSummon = function(self)
	local summon_btn = self._data["battle_field_data"].summon_btn
	return summon_btn ~= 0
end

battle_data_mt.isArena = function(self)
	return self._data["ui_attr"].is_arena and self._data["ui_attr"].is_arena ~= 0
end

battle_data_mt.isSimilarityBoss = function(self)
	return self._data["ui_attr"].boss_ui and self._data["ui_attr"].boss_ui == 1
end

battle_data_mt.isDemo = function(self)
	return self._data["ui_attr"].no_control and self._data["ui_attr"].no_control == 1
end

battle_data_mt.setUpdateShip = function(self, id)
	self.cur_update_ships[id] = true
end

battle_data_mt.resetUpdateShip = function(self)
	self.cur_update_ships = {}
end

battle_data_mt.isUpdateShip = function(self, id)
	return self.cur_update_ships[id]
end

battle_data_mt.refreshAlivePartner = function(self, value)
	self.alive_partner = self.alive_partner + value

	local battle_ui = self:GetLayer("battle_ui")
	if tolua.isnull(battle_ui) or tolua.isnull(battle_ui.btn_gather) then return end

	if self.alive_partner <= 0 then
		battle_ui.btn_gather:setVisible(false)
	else
		battle_ui.btn_gather:setVisible(true)
	end
end

battle_data_mt.getAlivePartner = function(self)
	return self.alive_partner or 0
end

battle_data_mt.setAiStepList = function(self, id, ai_id, step)
	if not id or not ai_id or not step then return end

	if NOT_RECORD_AI[ai_id] then return end

	self.ai_step_list[id] = self.ai_step_list[id] or {}

	if step < 1 and not self.ai_step_list[id][ai_id] then return end

	if self.ai_step_list[id][ai_id] and self.ai_step_list[id][ai_id] == step then return end

	self.ai_step_list[id][ai_id] = step

	GameUtil.callRpcVarArgs("rpc_server_ai_status", self:getSession(), id, ai_id, step)
end

battle_data_mt.setAutoShip = function(self, id, value)
	self.auto_ships[id] = value
end

battle_data_mt.isAutoShip = function(self, id)
	return self.auto_ships[id]
end

battle_data_mt.setShowDamageRange = function(self, value)
	self.is_show_damage_range = value
end

battle_data_mt.isShowDamageRange = function(self)
	return self.is_show_damage_range
end

battle_data_mt.canUseSkill = function(self)
	local auto_use_skill_time = 3000

	return self:getBattleTime() > auto_use_skill_time
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.addDrownShip = function(self, id, ship)
	if not self:IsInBattle() then return end
	if not self.drowning_ship then
		self.drowning_ship = {}
	end
	self.drowning_ship[id] = ship
end

battle_data_mt.removeDrownShip = function(self, id)
	if not self.drowning_ship or not self.drowning_ship[id] then return end
	local ship = self.drowning_ship[id]
	local scheduler = CCDirector:sharedDirector():getScheduler()
	if ship.drownTimer then
		scheduler:unscheduleScriptEntry(ship.drownTimer)
		ship.drownTimer = nil
	end
	ship:release()
	self.drowning_ship[id] = nil
end

battle_data_mt.removeAllDrownShips = function(self)
	if not self.drowning_ship then return end
	for id, _ in pairs(self.drowning_ship) do
		self:removeDrownShip(id)
	end
	self.drowning_ship = nil
end

battle_data_mt.IsInBattle = function(self)
	return self._data ~= nil and self.ship_pool ~= nil
end

battle_data_mt.SetLayer = function(self, name, layer)
	self._layer[name] = layer
end

battle_data_mt.GetLayer = function(self, name)
	return self._layer[name]
end

battle_data_mt.SetTable = function(self, name, table)
	self._table_[name] = table
end

battle_data_mt.GetTable = function(self, name)
	if not self._table_ then return end
	return self._table_[name]
end

battle_data_mt.SetData = function(self, name, data)
	self._data[name] = data

	EventTrigger(EVENT_BATTLE_SET_DATA, name, data)
end

battle_data_mt.GetData = function(self, name)
	return self._data[name]
end

-- 策划用保存数据接口
battle_data_mt.planningSetData = function(self, name, data)
	self:SetData(name, data)

	if type(data) ~= "number" then
		print("ERROR!!! Data is not number!", type(data))
		return
	end

	battleRecording:recordVarArgs("battle_set_data", name, data)
end

battle_data_mt.SetScheduler = function(self, name, func, interval, isPaused)
	isPaused = isPaused or false
	local hander = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt) func(dt) end, interval, isPaused)
	if hander then
		self._scheduler[name] = hander
	end

	return hander
end

battle_data_mt.StopScheduler = function(self, name)
	if not self._scheduler then return end
	if self._scheduler[name] then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._scheduler[name])
		self._scheduler[name] = nil
	end 
end

battle_data_mt.StopAllScheduler = function(self)
	if not self._scheduler then return end
	
	local scheduler = CCDirector:sharedDirector():getScheduler()
	for name, hander in pairs(self._scheduler) do
		scheduler:unscheduleScriptEntry(hander)
		self._scheduler[name] = nil
	end
end 

battle_data_mt.ClearBattleData = function(self)
	local scheduler = CCDirector:sharedDirector():getScheduler()
	for name, hander in pairs(self._scheduler) do
		scheduler:unscheduleScriptEntry(hander)
	end

	self:InitBattleData()
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.GetShips = function(self)
	return self.ship_pool
end

battle_data_mt.getShipByGenID = function(self, id)
	if not id then return end
	return self.ship_pool[id]
end

battle_data_mt.getShipByBoatKey = function(self, boat_key)
	for k, v in pairs(self.ship_pool) do
		if v.baseData.boat_key == boat_key then
			return v
		end
	end
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.InsertShip = function(self, ship)
	self.ship_pool[ship:getId()] = ship
end

battle_data_mt.GetTeamShips = function(self, teamId, no_death, uid)
	local ships = {}
	for k, ship in pairs(self.ship_pool) do
		if ship.teamId == teamId and (not uid or ship:getUid() == uid) then
			if ship.isDeaded then
				if not no_death then
					table.insert(ships, ship)
				end
			else
				table.insert(ships, ship)
			end
		end
	end

	return ships
end

battle_data_mt.GetTeamMemberShip = function(self, uid, no_death)
	local ships = {}
	for k, ship in pairs(self.ship_pool) do
		if ship.teamId == battle_config.default_team_id and not ship.isLeader and (not uid or ship:getUid() == uid) then
			if ship:is_deaded() then
				if not no_death then
					table.insert(ships, ship)
				end
			else
				table.insert(ships, ship)
			end
		end
	end
	return ships
end

battle_data_mt.GetTeamShipsId = function(self, teamId, no_death, uid)
	local ships = {}
	for k, v in pairs(self.ship_pool) do
		if v:getTeamId() == teamId and (not uid or v:getUid() == uid) then
			if v.isDeaded then
				if not no_death then
					table.insert(ships, k)
				end
			else
				table.insert(ships, k)
			end
		end
	end

	return ships
end

battle_data_mt.getEnemyShips = function(self, team_id)
	local ships = {}
	
	if team_id == battle_config.neutral_team_id then return ships end
	
	for k, v in pairs(self.ship_pool) do
		if not v:is_deaded() and v:getTeamId() ~= battle_config.neutral_team_id and v:getTeamId() ~= team_id then
			ships[#ships + 1] = v
		end
	end

	return ships
end

battle_data_mt.getEnemyShipsId = function(self, team_id)
	local ships = {}
	
	if team_id == battle_config.neutral_team_id then return ships end
	
	for k, v in pairs(self.ship_pool) do
		if not v:is_deaded() and v:getTeamId() ~= battle_config.neutral_team_id and v:getTeamId() ~= team_id then
			ships[#ships + 1] = v:getId()
		end
	end

	return ships
end

battle_data_mt.getFriendShipsId = function(self, selfShipObj)
	if (not selfShipObj) then return {} end

	local selfTeamId = selfShipObj:getTeamId()

	-- 友方Team
	return self:GetTeamShipsId(selfTeamId, true)
end

-- 副舰
battle_data_mt.getPartnerShipsId = function(self, ship)
	if not ship then return {} end

	local team_id = ship:getTeamId()

	return self:GetTeamShipsId(team_id, true, ship:getUid())
end

battle_data_mt.getAllShipsId = function(self, selfShipObj)
	local ships = {}

	for k, ship in pairs(self.ship_pool) do
		if not ship:is_deaded() then
			table.insert(ships, ship:getId())
		end
	end

	return ships
end

battle_data_mt.GetShipByBaseId = function(self, id)
	if id < 1 then return nil end

	for k, ship in pairs(self.ship_pool) do
		if ship.baseData.id == id then
			return ship
		end
	end

	return nil
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.runExistAi = function(self, ai_status)
	if not ai_status then return end

	for k, v in pairs(ai_status) do
		local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, v.ai)
	    local ClsAI = require(clazz_name)

		if v.shipId == self:getId() and self:IsRecording() then
			local aiObj = ClsAI.new({}, self)
			self:setRunningAI(aiObj)
			aiObj:toRunAction(v.idx)
		elseif v.shipId > 0 and self:isUpdateShip(v.shipId) then
			local ship = self:getShipByGenID(v.shipId)
			if ship and not ship:is_deaded() then
				local aiObj = ClsAI.new({}, ship)
				ship:setRunningAI(aiObj)
				aiObj:toRunAction(v.idx)
			end
		end
	end
end

battle_data_mt.runStartAi = function(self)
    if self.ship_pool == nil then return end

	for k, v in pairs(self.ship_pool) do
		v:searchTarget()

		if self:isUpdateShip(v:getId()) then
			v:tryOpportunity(AI_OPPORTUNITY.FIGHT_START)
		end
	end

	if self:IsRecording() then
		self:tryOpportunity(AI_OPPORTUNITY.FIGHT_START)

		local ai_status = self:GetData("ai_status")
		self:runExistAi(ai_status)
	end

	self:setLastRpcTime()
end

battle_data_mt.GetBaseDate = function(self, base_id)
	for k, v in pairs(self._data["battle_field_data"].ships) do
		if v.id and v.id == base_id then
			return v
		end
	end
end

battle_data_mt.GetBaseDataByKey = function(self, boat_key)
	for k, v in pairs(self._data["battle_field_data"].ships) do
		if v.boat_key and v.boat_key == boat_key then
			return v
		end
	end
end

battle_data_mt.SearchTag = function(self, tag)
	local result = {}
	for k, v in pairs(self.ship_pool) do
		if not v.isDeaded and v.baseData.tag == tag then
			table.insert(result, v)
		end
	end
	return result
end

battle_data_mt.SetBattleRunning = function(self, is_run)
	local old_status = self._battle_run_status
	if old_status == is_run then return end

	self._battle_run_status = is_run

	local battleUi = self:GetLayer("battle_ui")
	if not tolua.isnull(battleUi) then
		if self:BattleIsRunning() then
			battleUi:resumeBattle()
		else
			battleUi:pauseBattle()
		end
	end
end

battle_data_mt.BattleIsRunning = function(self)
	return self._battle_run_status
end

battle_data_mt.SetBattleStart = function(self, start)
	self._battle_status = start
end

battle_data_mt.IsBattleStart = function(self)
	return self._battle_status
end

battle_data_mt.GetExtData = function(self)
	return self._ext_data
end

local getShipId
getShipId = function( owner, ship_obj )
	return ship_obj:getId()
end

local getShipHp
getShipHp = function( owner,ship_obj )
	return ship_obj:getHp()
end

local getShipHpMax
getShipHpMax = function( owner, ship_obj )
	return ship_obj:getHpMax()
end

local getShipHpRate
getShipHpRate = function( owner, ship_obj )
	return ship_obj:getHpRate()
end

local getShipSpeed
getShipSpeed = function( owner, ship_obj )
	return ship_obj:getSpeed()
end

local getShipAttFar
getShipAttFar = function( owner, ship_obj )
	return ship_obj:getAttFar()
end

local getShipAttNear
getShipAttNear = function( owner, ship_obj )
	return ship_obj:getAttNear()
end

local getShipDefense
getShipDefense = function( owner, ship_obj )
	return ship_obj:getDefense()
end

local getShipDistance
getShipDistance = function( owner, ship_obj )
	return GetDistanceFor3D(owner.body.node, ship_obj.body.node)
end


local getValueFunc = {
	["ID"] = getShipId,
	["HP"] = getShipHp,
	["HP_RATE"] = getShipHpRate,
	["HP_MAX"] = getShipHpMax,
	["SPEED"] = getShipSpeed,
	["FAR_ATTACK"] = getShipAttFar,
	["NEAR_ATTACK"] = getShipAttNear,
	["DEFENSE"] = getShipDefense,
	["DISTANCE"] = getShipDistance,
}

-- ship_ids 船只Id列表
-- sort_key 排序用key
-- asc  1 升序
--     -1 降序
battle_data_mt.sortShipsByKey = function(self, owner, shipIds, sort_key, asc)
	sort_key = string.upper(sort_key)
	local func = getValueFunc[sort_key]

	if (not func) then
		if( type(sort_key) ~= "string" or (type(sort_key) == "string" and string.len(sort_key) > 0 )) then
			print(string.format(T("ERROR:不明的排序方式[%s]"), sort_key))
			if ( sort_key == nil) then
				print( debug.traceback() )
			end
		end
		return shipIds
	end


	-- TODO:等待校验排序方式
	table.sort(shipIds, function(ship_id_a, ship_id_b)
		local ship_a_obj, ship_b_obj
		if ( type(ship_id_a) == "number" ) then
			ship_a_obj = self:getShipByGenID(ship_id_a)
		else
			ship_a_obj = ship_id_a
		end
		if ( type(ship_id_b) == "number" ) then
			ship_b_obj = self:getShipByGenID(ship_id_b)
		else
			ship_b_obj = ship_id_b
		end

		if ((not ship_a_obj) and (not ship_b_obj)) then return false end

		if (not ship_a_obj) then return asc < 0 end
		if (not ship_b_obj) then return -1*asc < 0 end

		return (func(owner, ship_a_obj) - func(owner, ship_b_obj))*asc < 0
	end)

	return shipIds
end

battle_data_mt.getEffectId = function(self)
	local id = self.effect_id
	self.effect_id = self.effect_id + 1
	return id
end

local SceneEffect = require("gameobj/battle/sceneEffect")
battle_data_mt.addEffect = function(self, id, filename, dx, dy, time, angle, follow)
	self.effect = self.effect or {}
	if follow and self.effect[id] then return end
	local pos = cocosToGameplayWorld(ccp(dx, dy))
	local file = EFFECT_3D_PATH .. filename .. PARTICLE_3D_EXT
	local follow_target = nil
	if follow then
		follow_target = follow:getBody().node
	end
	local particle = SceneEffect.createEffect({file = file, pos = pos, dt = time , followNode = follow_target})

	id = id or self:getEffectId()

	self.effect[id] = particle

	if particle then
		particle:GetNode():setTranslation(pos)
		particle:Start()

		if time and time > 0 then
			particle:SetDuration(time)
		end

		if angle and angle > 0 then
			particle:GetNode():rotateY(math.rad(angle))
		end
	end

	return id
end

battle_data_mt.delEffect = function(self, id)
	if not self.effect then return end
	if not self.effect[id]  then return end

	SceneEffect.ReleaseParticle(self.effect[id])
end

battle_data_mt.showDeadEffect = function(self, ship)
	if not self:IsBattleStart() then return end
	
	if ship:isPVEShip() or ship:getTeamId() ~= battle_config.default_team_id then return end

	local battle_ui = self:GetLayer("battle_ui")
	
	if tolua.isnull(battle_ui) then return end

	local id = ship:getId()

	if battle_ui:getHeadAction(id) then return end

	local uid = ship:getUid()

	battle_ui:setShipDead(uid, id)
end

-- 替补进场
battle_data_mt.subEnter = function(self, uid, ship_data, replace_id)
	local ship = self:getControlShip(uid)

	if not ship then return end

	local leader_ship = self:getLeaderShip(uid)
	if not leader_ship or leader_ship:is_deaded() then return end

	ship_data.new_ai_id = {"tibu_follow"}

	local ship_obj = require("gameobj/battle/newShipEntity").createShipEntity(ship_data)

	if ship_obj:isPVEShip() or ship_obj:getTeamId() ~= battle_config.default_team_id then return end

	local battle_ui = self:GetLayer("battle_ui")

	if tolua.isnull(battle_ui) then return end

	local ship = self:getShipByGenID(replace_id)

	local id = ship_obj:getId()

	if battle_ui:getHeadAction(replace_id) or (ship and not ship:is_deaded()) then
		local sub_queue = self:GetData("sub_queue") or {}
		sub_queue[replace_id] = id

		self:SetData("sub_queue", sub_queue)
		return
	end

	battle_ui:setSubShipInfo(uid, ship_obj:getId(), replace_id)
end

-- 改变战队
battle_data_mt.changeTeam = function(self, ship, newTeamId, from_server)
	if newTeamId < battle_config.team_id_min or newTeamId > battle_config.team_id_max then return end

	ship:setTeamId(newTeamId, from_server)
	shipEffectLayer.changeTeam(ship)
end

------------------------------------------------------------------------------------------------------------------------
-- 同步战斗有关数据以及函数区域
------------------------------------------------------------------------------------------------------------------------
battle_data_mt.initRecordData = function(self)
    -- 录像标记
    self._recording = false
    -- 播放标记
    self._playing = false

    self._serverFrame = 0
    self._no_set_serverFrame = 0

    self.loaded = false

    -- 本机状态
    self._state = battle_config.state_unknow
end

battle_data_mt.setAlreadyLoad = function(self, value)
	self.loaded = value
end

battle_data_mt.isAlreadyLoad = function(self)
	return self.loaded
end

battle_data_mt.setState = function(self, state)
	self._state = state
end

battle_data_mt.broadcastMsg = function(self, event, args)

    local wait_rpc = nil
    -- if event == "battle_escape" then
        -- wait_rpc = "rpc_client_fight_final_result"
    -- end

    if wait_rpc then
        local arg_table = {self.session, battleRecording.VIEW_TO_ID[event], args}
        GameUtil.callRpc("rpc_server_fight_view", arg_table, wait_rpc)
    else
        GameUtil.callRpcVarArgs("rpc_server_fight_view", self.session, battleRecording.VIEW_TO_ID[event], args)
    end
end

-- 战斗是否录像
battle_data_mt.IsRecording = function(self)
    return self._recording
end

-- 设置战斗是否录像
battle_data_mt.SetRecording = function(self, recordFlg)
    self._recording = recordFlg

    if self._recording then
	    -- 设置为本机状态为录像初始
	    self:setState(battle_config.state_record_init)
	end
end

-- 战斗是否录像播放
battle_data_mt.IsPlaying = function(self)
    return self._playing
end

-- 设置战斗是否录像播放
battle_data_mt.SetPlaying = function(self, playing)
    self._playing = playing

    if self._playing then
    	-- 设置为本机状态为播放初始
    	self:setState(battle_config.state_playing_init)
    end
end

-- 战斗当前播放帧
battle_data_mt.setCurrentFrame = function(self, value)
    self._currentFrame = value
end

battle_data_mt.getCurrentFrame = function(self)
    return self._currentFrame or 0
end

-- 服务端当前帧
battle_data_mt.setServerFrame = function(self, value)
    self._serverFrame = value
    self:resetNoSetServerFrame()
end

battle_data_mt.getServerFrame = function(self)
    return self._serverFrame
end

-- 服务端同步帧后，多少帧未同步
battle_data_mt.incNoSetServerFrame = function(self)
    self._no_set_serverFrame = self._no_set_serverFrame + 1
end

battle_data_mt.resetNoSetServerFrame = function(self)
    self._no_set_serverFrame = 0
end

battle_data_mt.getNoSetServerFrame = function(self)
    return self._no_set_serverFrame
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.setLeaderID = function(self, ship)
	if not ship then return end
	self.leader_ships[ship:getUid()] = ship:getId()
end

battle_data_mt.getLeaderID = function(self, uid)
	if not uid then return end
	return self.leader_ships[uid]
end

battle_data_mt.getLeaderShip = function(self, uid)
	if not uid then return end
	local leader_id = self.leader_ships[uid]

	return self.ship_pool[leader_id]
end

battle_data_mt.getCurClientUid = function(self)
	if not self._data or not self._data["battle_field_data"] then return end
	return self._data["battle_field_data"].cur_client_uid
end

-- 玩家控制船只接口
battle_data_mt.setControlShipID = function(self, id, uid)
	self.control_ships[uid] = id
end

battle_data_mt.getControlShip = function(self, uid)
	if not self.control_ships[uid] then return end
	return self.ship_pool[self.control_ships[uid]]
end

battle_data_mt.getCurClientControlShip = function(self)
	local cur_client_uid = self:getCurClientUid()
	if not cur_client_uid then return end
	return self:getControlShip(cur_client_uid)
end

battle_data_mt.getControlShipTargetID = function(self, uid)
	local ship = self:getControlShip(uid)

	if ship and ship:getTarget() and not ship:getTarget():is_deaded() then
		return ship:getTarget():getId()
	end

	return 0
end

battle_data_mt.isControlShip = function(self, id, uid)
	return self.control_ships[uid] and self.control_ships[uid] == id
end

battle_data_mt.isCurClientControlShip = function(self, id)
	local cur_client_uid = self:getCurClientUid()
	if not cur_client_uid then return end
	return self.control_ships[cur_client_uid] and self.control_ships[cur_client_uid] == id
end

battle_data_mt.changeControlShip = function(self, id, server)
	if not id then return end

	local new_ship = self:getShipByGenID(id)

	local old_ship = self:getControlShip(new_ship:getUid())

	self:setControlShipID(id, new_ship:getUid())

	new_ship:setAutoFight(false)

	if new_ship:getTarget() and not new_ship:getTarget():is_deaded() then
    	new_ship:getTarget():getBody():showGuanquan()
    end

	if old_ship and not old_ship:is_deaded() then
		old_ship:setAutoFight(true)
		old_ship:addPartnerAitoShip()

    	local target = old_ship:getTarget()
    	if target and not target:is_deaded() then
			target:getBody():hideGuanquan()
		end
    	old_ship:getBody():setPathNode(false)
		old_ship:getBody():delAttackRange()
	end

	local battle_ui = self:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		if old_ship and old_ship:getId() and battle_ui.fleet_head[old_ship:getId()] then
			battle_ui.fleet_head[old_ship:getId()].select:setVisible(false)
		end
		if new_ship and new_ship:getId() and battle_ui.fleet_head[new_ship:getId()] then
			battle_ui.fleet_head[new_ship:getId()].select:setVisible(true)
		end
		battle_ui:dismissSkillTip()
		battle_ui:initSkillUi()
		battle_ui:setHand()
		battle_ui:lockPlayerShip()
		battle_ui:showCombo(false)
		battle_ui:hideGatherButton()
	end
end

battle_data_mt.isNotOnline = function(self)
	return self.show_relink
end

battle_data_mt.setLastRpcTime = function(self)
	self.last_rpc_time = self:GetData("battle_time")

	self:hideReLinkView()
end

battle_data_mt.checkIsLostNet = function(self)
	if tonumber(self.last_rpc_time) < self:getBattleTotalTime() and
		tonumber(self.last_rpc_time) - tonumber(self:GetData("battle_time")) > 5 then
		self:showReLinkView()
	else
		self:hideReLinkView()
	end
end

battle_data_mt.showReLinkView = function(self)
	if self.show_relink then return end

	self.show_relink = true

	local reLinkUI = reLinkUICls:maintainObj()
	reLinkUI:mkReLoginDialog()
end

battle_data_mt.hideReLinkView = function(self)
	if not self.show_relink then return end

	self.show_relink = false

	local reLinkUI = reLinkUICls:maintainObj()
	reLinkUI:hide()
end

battle_data_mt.getLastSelectFightType = function(self)
	return self._last_fight_type
end

battle_data_mt.setLastSelectFightType = function(self, fight_type)
	self._last_fight_type = fight_type
end

battle_data_mt.setBattleLayerScale = function(self, scale)
	self._battle_layer_scale = scale
end

battle_data_mt.getBattleLayerScale = function(self)
	local scale = self._battle_layer_scale or 0.95
	scale = tonumber(scale)
	if scale > 0.7 then
		return scale
	else
		local ship = self:getCurClientControlShip()
		if not ship then
			return 0.85
		end
		local role = ship:getRole()

		if role == KIND_EXPORE then
			return 0.85
		elseif role == KIND_SAILOR then
			return 0.75
		else
			return 0.95
		end
	end
end

battle_data_mt.uploadAI = function(self, is_add, ship_id, ai_ids)
	if is_add then
		GameUtil.callRpcVarArgs("rpc_server_fight_view_add_ai", self.session, ship_id, ai_ids)
	else
		GameUtil.callRpcVarArgs("rpc_server_fight_view_del_ai", self.session, ship_id, ai_ids)
	end
end

battle_data_mt.downloadAddStatus = function(self, ship, status_id, ms, iat, cat)
	local attacker_id, skill_id

	local x, y, combo, heart_break = 0, 0, 0, 0

	local tbResult = {}
	for k, v in pairs(iat) do
		if v.key == "heart_break" then
			heart_break = v.value/1000
		elseif v.key == "attacker" then
			attacker_id = v.value
		elseif v.key == "tj_target" then
			tbResult.tj_target = self:getShipByGenID(v.value)
		elseif v.key == "x" then
			x = v.value/FIGHT_SCALE
		elseif v.key == "y" then
			y = v.value/FIGHT_SCALE
		elseif v.key == "combo" then
			combo = v.value
		else
			local i, j = string.find(v.key, "_boolean")
			if not i then
				tbResult[v.key] = v.value
			else
				tbResult[string.sub(v.key, 1, i - 1)] = v.value == 1
			end
		end
	end

	for k, v in pairs(cat) do
		if v.key == "skill_id" then
			skill_id = v.value
		else
			tbResult[v.key] = v.value
		end
	end

	local attacker = self:getShipByGenID(attacker_id)

	-- if not attacker then return end

	local forward = nil
	if x and y then
		forward = Vector3.new(x, 0, y)
	end

	local objStatus = status_map[status_id].new(attacker, ship, ms/1000, heart_break, skill_id, nil, nil, forward)

	objStatus.tbResult = tbResult

	objStatus:calc()

	if combo == FV_BOOL_TRUE and attacker and self:isCurClientControlShip(attacker:getId()) then
		local battle_ui = getUIManager():get("FightUI")
		if not tolua.isnull(battle_ui) then
			battle_ui:showCombo(true)
		end
	end
end

battle_data_mt.uploadAddStatus = function(self, buff)
	local session = self:getSession()
	local ship_id = buff.target:getId()
	local status_id = buff:get_status_id()
	local ms = buff.duration_time and buff.duration_time or 0
	if ms > battle_config.battle_time then
		ms = battle_config.battle_time*2
	end
	ms = math.floor(ms*1000 + 0.5)
	local iat, cat = {}, {}

	if buff.tbResult then
		for k, v in pairs(buff.tbResult) do
			local tmp = {}
			tmp.key = k

			if type(v) == "number" then
				tmp.value = math.floor(v + 0.5)
				iat[#iat + 1] = tmp
			elseif type(v) == "string" then
				tmp.value = v
				cat[#cat + 1] = tmp
			elseif type(v) == "table" then
				if k == "tj_target" then
					tmp.value = v:getId()
					iat[#iat + 1] = tmp
				else
					table.print(v)
					print("======================不明类型数据！！！, k , v ", k, v)
				end
			elseif type(v) == "boolean" then
				tmp.key = k .. "_boolean"
				tmp.value = v and 1 or 0
				iat[#iat + 1] = tmp
			else
				print("======================不明类型数据！！！, k , v ", k, v)
			end
		end
	end

	if buff.forward then
		local x, y = math.floor(buff.forward:x()*FIGHT_SCALE + 0.5), math.floor(buff.forward:z()*FIGHT_SCALE + 0.5)

		local tmp_1 = {["key"] = "forward_x", ["value"] = x}
		local tmp_2 = {["key"] = "forward_y", ["value"] = y}

		iat[#iat + 1] = tmp_1
		iat[#iat + 1] = tmp_2
	end

	local skill_id = -1
	if buff.skill then
		skill_id = buff.attacker:getIdByExId(buff.skill)
	end

	iat[#iat + 1] = {["key"] = "skill_id", ["value"] = skill_id}
	iat[#iat + 1] = {["key"] = "heart_break", ["value"] = buff.heart_break*1000}
	iat[#iat + 1] = {["key"] = "attacker", ["value"] = buff.attacker:getId()}

	GameUtil.callRpcVarArgs("rpc_server_fight_view_add_status", session, ship_id, status_id, ms, iat, cat)
end

battle_data_mt.uploadDelStatus = function(self, buff)
	local session = self:getSession()
	local ship_id = buff.target:getId()
	local status_id = buff:get_status_id()

	GameUtil.callRpcVarArgs("rpc_server_fight_view_del_status", session, ship_id, status_id)
end

battle_data_mt.enemyInRectangle = function(self, length, width, angle, start_pos, ship)
	start_pos = start_pos or ship:getPosition3D()
	local buff_pos = ccp(start_pos:x(), - start_pos:z())

	local pos = {
		ccp(0, - width),
		ccp(0, width),
		ccp(length, width),
		ccp(length, - width),
	}

	local cos_value, sin_value = math.cos(angle), math.sin(angle)

	local rotateAngle
	rotateAngle = function(x1, y1, c_value, s_value)
		local x = x1*c_value - y1*s_value
		local y = y1*c_value + x1*s_value
		return x, y
	end

	for k, v in ipairs(pos) do
		local x, y = rotateAngle(v.x, v.y, cos_value, sin_value)
		pos[k] = ccp(x + buff_pos.x, y + buff_pos.y)
	end

	local targets = {}

	for k, v in pairs(self:GetShips()) do
		if not v:is_deaded() and v:getTeamId() ~= ship:getTeamId() and v:getTeamId() ~= battle_config.neutral_team_id then
			local boat_pos = v:getPosition3D()
			local x, y = boat_pos:x(), - boat_pos:z()

			local inside = true
			for pos_k, _ in ipairs(pos) do
				local pos_1, pos_2 = pos[pos_k], pos[pos_k + 1 > 4 and 1 or pos_k + 1]
				local result = commonBase:IsLineLeft(pos_1.x, pos_1.y, pos_2.x, pos_2.y, x, y)

				if result > 0 then
					inside = false
					break
				end
			end

			if inside then
				targets[#targets + 1] = v
			end
		end
	end

	return targets
end

battle_data_mt.fenshenPosition = function(self, attacker)
	local forward_self = attacker:getPosition3D()

	if not forward_self then return end

	local target = attacker:getTarget()
	local forward_enemy = Vector3.new()
	if target and target.body and target.body.node then
		forward_enemy = target:getPosition3D()
	else
		return forward_self
	end

	local distance = 200

	local forward_des = Vector3.new()
	Vector3.subtract(forward_enemy, forward_self, forward_des)
	forward_des:normalize()
	forward_des:scale(distance)

	local x, z = skill_effect_util.checkLandPos(forward_self, forward_des, distance)

	return Vector3.new(x, 0, z)
end

battle_data_mt.getBattleTotalTime = function(self)
	return self:GetData("battle_total_time") or battle_config.battle_time
end

battle_data_mt.getBattleTime = function(self)
	local battle_time = self:GetData("battle_time") or 0
	return (self:getBattleTotalTime() - battle_time)*1000
end

------------------------------------------------------------------------------------------------------------------------

battle_data_mt.setSpeedForTest = function(self, value)
	for k, v in pairs(self.ship_pool) do
		if not v:is_deaded() and v.is_ship then
			v:addSpeed(value)
		end
	end
end
----------------------------------- 新版本AI系统有关函数 Begin -------------------------------------

require("gameobj/battle/ai/ai_base")

battle_data_mt.initAI = function(self)
    -- 新AI数据
    self.new_ai = {}
    -- 运行中的AI
    self.running_ai = {}
    -- 时机注册机制数据
    self.__has_opportunity = {}
end


-- 添加AI
battle_data_mt.addAI = function(self, ai_id, params)
    local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
    local ClsAI = require(clazz_name)
    local aiObj = ClsAI.new(params, self)

    self.new_ai[ai_id] = aiObj
    self.__has_opportunity[aiObj:getOpportunity()] = true
end

-- 删除AI
battle_data_mt.deleteAI = function(self, ai_id)
    self.new_ai[ai_id] = nil
    self.__has_opportunity = {}
    for ai, aiObj in pairs(self.new_ai) do
        self.__has_opportunity[aiObj:getOpportunity()] = true
    end
end

battle_data_mt.setRunningAI = function(self, aiObj)
	local ai_id = aiObj:getId()

	self.running_ai[ai_id] = aiObj
end

battle_data_mt.isRunningAI = function(self)
	return table.nums(self.running_ai) > 0
end

-- 尝试执行某个时机的AI
battle_data_mt.tryOpportunity = function(self, opportunity)
    if not self.new_ai then return end
    if not self.__has_opportunity[opportunity] then return end

    local tmp_new_ai = table.keys(self.new_ai)

    for _, ai_id in ipairs(tmp_new_ai) do
        if not self.running_ai[ai_id] and self.new_ai[ai_id] then
            local res = self.new_ai[ai_id]:tryRun(opportunity)
        end
    end
end

battle_data_mt.completeAI = function(self, aiObj)
    local ai_id = aiObj:getId()

    if aiObj:getOpportunity() == AI_OPPORTUNITY.FIGHT_START or aiObj:getOpportunity() == AI_OPPORTUNITY.BEFORE_FIGHT_START then
    	self:uploadAI(false, self:getId(), {ai_id})
    end

    -- 删除正在执行AI
    self.running_ai[ai_id] = nil

    self:setAiStepList(self:getId(), ai_id, -1)
end

battle_data_mt.getAI = function(self, ai_id)
	return self.new_ai[ai_id]
end

battle_data_mt.getRuningAI = function(self, ai_id)
	return self.running_ai[ai_id]
end

battle_data_mt.getId = function(self)
    return -2
end

----------------------------------- 新版本AI系统有关函数 End   -------------------------------------

-- 心跳
battle_data_mt.HeartBeat = function(self)
	local now = getCurrentLogicTime()
    local delta_time = math.floor((now - (self.heart_time or now)) * 1000)
    self.heart_time = now

    for id, ship in pairs(self:GetShips()) do
    	if ship and not ship:is_deaded() then
	    	ship:HeartBeat(delta_time)
	    end
    end

	if self:IsRecording() then
	    for ai_id, ai_obj in pairs(self.running_ai) do
	        ai_obj:heartBeat(delta_time)
	    end

	    self:tryOpportunity(AI_OPPORTUNITY.TACTIC)
	end
end

------------------------------------------------------------------------------------------------------------------------

return battle_data_mt

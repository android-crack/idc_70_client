local alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local skill_warning = require("game_config/skill/skill_warning")
local shipEffectLayer = require("gameobj/battle/shipEffectLayer")
local battleRecording = require("gameobj/battle/battleRecording")
local skill_effect_util = require("module/battleAttrs/skill_effect_util")

local skill_base = require("module/battleAttrs/skill_base")
local clsSkillInitiative = class("clsSkillInitiative", skill_base)

local FIRST_STATUS = 1

local milisec_base = 1000

local function play_effect_music(sound, id, uid, send)
	if not sound or sound == "" then return end

	local sound_cfg =  music_info[sound]

	if not sound_cfg then return end

    local sound_res = sound_cfg.res

    local battle_data = getGameData():getBattleDataMt()

    local ship = battle_data:getShipByGenID(id)
    if ship and not ship:is_deaded() and ship:getBody() and 
    	ship:getBody():getNode() and ship:getBody():getNode():isInFrustum() then

	    local is_player = battle_data:isCurClientControlShip(id)
		audioExt.playEffect(sound_res, false, is_player)
	end

	if send then
		battleRecording:recordVarArgs("play_effect_music", sound_res, id, uid)
	end
end

local function sort_targets(attacker, targets, sort_method)
	local sort_key, sort_asc = sort_method, 1

	if not sort_method or sort_method == "" then return targets end

	local idx = string.find(sort_method, "_", -5)
	if idx then
		sort_key = string.sub(sort_method, 1, idx - 1)
		if string.sub(sort_method, idx + 1) == "DESC" then
			sort_asc = -1
		end
	end

	local battle_data = getGameData():getBattleDataMt()
	targets = battle_data:sortShipsByKey(attacker, targets, sort_key, sort_asc)

	return targets
end

local function isTargetEnemy(attacker, target)
	return attacker:getTeamId() ~= target:getTeamId() and target:getTeamId() ~= battle_config.neutral_team_id
end

-- SCOPE SELF
function clsSkillInitiative:selectTargetSelf(attacker, target, lv, cnt, sort_method)
	return {attacker}
end

-- SCOPE ENEMY
function clsSkillInitiative:selectTargetEnemy(attacker, target, lv, cnt, sort_method, job, ignore_sort)
	local targets = {}
	local dist_min = self:get_limit_distance_min(attacker, lv)
	local dist_max = self:_get_limit_distance_max(attacker, lv)

	local battle_data = getGameData():getBattleDataMt()
	local all_enemy = battle_data:getEnemyShips(attacker:getTeamId())
	all_enemy = sort_targets(attacker, all_enemy, sort_method)

	local a_target = attacker.target

	local not_sort = not sort_method or sort_method == ""

	if ignore_sort or not_sort then
		-- 保证target在第一位
		if target and target ~= a_target then
			if isTargetEnemy(attacker, target) and self:check_target(attacker, target, dist_min, dist_max, job) then
				targets[#targets + 1] = target

				if #targets >= cnt then return targets end
			end
		end

		if a_target and isTargetEnemy(attacker, a_target)then
			if self:check_target(attacker, a_target, dist_min, dist_max, job) then
				targets[#targets + 1] = a_target

				if #targets >= cnt then return targets end
			end
		end
	end

	for _, enemy in ipairs(all_enemy) do
		if (not not_sort or (tenemy ~= target and enemy ~= a_target)) then
			if self:check_target(attacker, enemy, dist_min, dist_max, job) then
				targets[#targets + 1] = enemy

				if #targets >= cnt then return targets end
			end
		end
	end
	return targets
end

-- SCOPE ENEMY EXPLORE
function clsSkillInitiative:selectEnemyExplore(attacker, target, lv, cnt, sort_method)
	return self:selectTargetEnemy(attacker, target, lv, cnt, sort_method, KIND_EXPORE)
end

-- SCOPE ENEMY NAVY
function clsSkillInitiative:selectEnemyNavy(attacker, target, lv, cnt, sort_method)
	return self:selectTargetEnemy(attacker, target, lv, cnt, sort_method, KIND_SAILOR)
end

-- SCOPE ENEMY PIRATE
function clsSkillInitiative:selectEnemyPirate(attacker, target, lv, cnt, sort_method)
	return self:selectTargetEnemy(attacker, target, lv, cnt, sort_method, KIND_GUN)
end

-- SCOPE ALL_FRIEND
function clsSkillInitiative:selectTargetAllFriend(attacker, target, lv, cnt, sort_method)
	local dist_min = self:get_limit_distance_min(attacker, lv)
	local dist_max = self:_get_limit_distance_max(attacker, lv)

	local battle_data = getGameData():getBattleDataMt()
	local all_friend = battle_data:GetTeamShips(attacker:getTeamId(), true)

	all_friend = sort_targets(attacker, all_friend, sort_method)

	local targets = {}

	for _, friend in pairs(all_friend) do
		if self:check_target(attacker, friend, dist_min, dist_max) then
			targets[#targets + 1] = friend

			if #targets >= cnt then return targets end
		end
	end

	return targets
end

-- SCOPE FRIEND_OTHER
function clsSkillInitiative:selectTargetFriendOther(attacker, target, lv, cnt, sort_method)
	local dist_min = self:get_limit_distance_min(attacker, lv)
	local dist_max = self:_get_limit_distance_max(attacker, lv)

	local battle_data = getGameData():getBattleDataMt()
	local all_friend = battle_data:GetTeamShips(attacker:getTeamId(), true)

	all_friend = sort_targets(attacker, all_friend, sort_method)

	local targets = {}

	if target and not target:is_deaded() and target:getTeamId() == attacker:getTeamId() then
		if self:check_target(attacker, target, dist_min, dist_max) then
			targets[#targets + 1] = target

			if #targets >= cnt then return targets end
		end
	end

	for _, friend in pairs(all_friend) do
		if friend ~= attacker and friend ~= target and self:check_target(attacker, friend, dist_min, dist_max) then
			targets[#targets + 1] = friend

			if #targets >= cnt then return targets end
		end
	end

	return targets
end

-- SCOPE FRIEND
function clsSkillInitiative:selectTargetFriend(attacker, target, lv, cnt, sort_method, job)
	local dist_min = self:get_limit_distance_min(attacker, lv)
	local dist_max = self:_get_limit_distance_max(attacker, lv)

	local battle_data = getGameData():getBattleDataMt()
	local all_friend = battle_data:GetTeamShips(attacker:getTeamId(), true)

	all_friend = sort_targets(attacker, all_friend, sort_method)

	local targets = {}

	targets[#targets + 1] = attacker

	if #targets >= cnt then return targets end

	for _, friend in pairs(all_friend) do
		if friend ~= attacker and self:check_target(attacker, friend, dist_min, dist_max, job) then
			targets[#targets + 1] = friend

			if #targets >= cnt then return targets end
		end
	end

	return targets
end

-- SCOPE FRIEND EXPLORE
function clsSkillInitiative:selectFriendExplore(attacker, target, lv, cnt, sort_method)
	return self:selectTargetFriend(attacker, target, lv, cnt, sort_method, KIND_EXPORE)
end

-- SCOPE FRIEND NAVY
function clsSkillInitiative:selectFriendNavy(attacker, target, lv, cnt, sort_method)
	return self:selectTargetFriend(attacker, target, lv, cnt, sort_method, KIND_SAILOR)
end

-- SCOPE FRIEND PIRATE
function clsSkillInitiative:selectFriendPirate(attacker, target, lv, cnt, sort_method)
	return self:selectTargetFriend(attacker, target, lv, cnt, sort_method, KIND_GUN)
end

local function selectScene(skill_obj, attacker, target, lv, cnt, sort_method)
	local scene_status = getGameData():getBattleDataMt():GetTable("Scene_Status")

	if not scene_status then
		scene_status = require("gameobj/battle/ClsSceneStatus")
		getGameData():getBattleDataMt():SetTable("Scene_Status", scene_status)
	end

	return {scene_status}
end

local selectTargetMethod = {
	["SELF"] = clsSkillInitiative.selectTargetSelf,
	["ENEMY"] = clsSkillInitiative.selectTargetEnemy,
	["ENEMY_EXPLORE"] = clsSkillInitiative.selectEnemyExplore,
	["ENEMY_NAVY"] = clsSkillInitiative.selectEnemyNavy,
	["ENEMY_PIRATE"] = clsSkillInitiative.selectEnemyPirate,
	["FRIEND"] = clsSkillInitiative.selectTargetFriend,
	["FRIEND_EXPLORE"] = clsSkillInitiative.selectFriendExplore,
	["FRIEND_NAVY"] = clsSkillInitiative.selectFriendNavy,
	["FRIEND_PIRATE"] = clsSkillInitiative.selectFriendPirate,
	["ALL_FRIEND"] = clsSkillInitiative.selectTargetAllFriend,
	["FRIEND_OTHER"] = clsSkillInitiative.selectTargetFriendOther,
	["SCENE"] = selectScene,
}

-------------------------------------------------------------------------------------------------------------------------

-- 技能限制检查
function clsSkillInitiative:can_use(attacker, target)
	local ret = self:SKILL_LIMIT_RESULT()

	local skillId = self:get_skill_id()
	local lv = self:get_skill_lv(attacker)
	
	-- 检验attacker是否有此技能	
	if lv == 0 then	return ret.NONE.msg end

	-- 检查使用技能那一刻玩家是否已经死亡
	if attacker:is_deaded() then return ret.DEADED.msg end
	
	local cur_cd = attacker:get_skill_cd(skillId)
	-- 检查共用CD
	if self:get_skill_type() ~= "auto" then
		local common_cd = attacker:get_common_skill_cd()
		if common_cd and common_cd > 0 then 
			return ret.COMMON_CD.msg
		end
	end
	-- 检查技能CD
	if cur_cd > 0 then return ret.CD.msg end
	
	-- 检验attacker是否有付能施放此技能的状态
	for _, status in pairs(self:get_status_limit()) do
		if attacker:hasBuff(status) then
			return ret.STATUS_LIMIT.msg
		end
	end

	-- 检验目标距离
	local scope = self:get_select_scope()
	if scope == "ENEMY" then
		local targets = self:selectTargetEnemy(attacker, attacker.target, lv, 1) 

		if #targets < 1 then
			return ret.NO_TARGET.msg
		end
	end

	-- 检验施法消耗
	local tbCost = self:calc_cost(attacker)
	if tbCost.hp then
		-- 判断attacker是否有足够的气血
		if attacker:getHp() <= tbCost.hp then
			return ret.HP.msg
		end
	end
	
	return ret.OK.msg, tbCost
end

-- 技能使用
function clsSkillInitiative:do_use(attackerId, target, not_show_warning)
	local battle_data = getGameData():getBattleDataMt()
	local attacker = battle_data:getShipByGenID(attackerId)

	local ret, tbCost = self:can_use(attacker, target)

	local skill_id = self:get_skill_id()
	local ret_t = self:SKILL_LIMIT_RESULT()

	if ret ~= ret_t.OK.msg then
		if not not_show_warning and not attacker:isAutoFighting() and self:is_initiative() then 
			self:skill_limit_display(ret)
		end
		return ret
	end
	
	if tbCost and tbCost.hp then
		attacker:modifyHp(attacker, tbCost.hp)
	end

	-- 施法清除状态
	local clear_status = self:get_skill_clear_status()
	for _, v in pairs(clear_status) do
		local buff = attacker:hasBuff(v)
		if buff then 
			buff:del(true)
		end
	end

    -- 施法激活状态
    local active_status = self:get_skill_active_status()
    for _, v in pairs(active_status) do
		local buff = attacker:hasBuff(v)
        if buff then
            buff:active(skill_id)
        end
    end

	self.is_hit_music_played = false

	local cd = self:get_skill_cd(attacker)
	attacker:set_skill_cd(skill_id, cd)

	if self:get_skill_type() ~= "auto" then 
		local common_cd = self:get_common_cd()
		attacker:set_common_skill_cd(common_cd, skill_id)

		if common_cd <= 0 then
			local battle_ui = battle_data:GetLayer("battle_ui")
			if not tolua.isnull(battle_ui) then
				battle_ui:showSkillCD(skill_id)
			end
		end
	end

	self:calcStatusTarget(attacker, target)
	
    return ret_t.OK.msg
end

function clsSkillInitiative:getDefultDir(attacker)
	local lv = self:get_skill_lv(attacker)
	local targets = self:selectTargetEnemy(attacker, attacker:getTarget(), lv, 1, "DISTANCE", nil, true)

	if #targets == 0 then return 0, 0 end

	local v1 = attacker:getBody().node:getTranslationWorld()
	local v2 = targets[1]:getBody().node:getTranslationWorld()

	local forward = Vector3.new()
	Vector3.subtract(v2, v1, forward)
	forward:normalize()

	local x = math.floor(forward:x()*FIGHT_SCALE + 0.5)/FIGHT_SCALE
	local z = math.floor(forward:z()*FIGHT_SCALE + 0.5)/FIGHT_SCALE

	attacker:setData(self:get_skill_id(), {x = x, z = z})

	return x*FIGHT_SCALE, z*FIGHT_SCALE
end

function clsSkillInitiative:calcStatusTarget(attacker, target)
	target = target or attacker:getTarget()

	local status = self:get_add_status()

	local upload_targets = {}

	for idx = 1, #status do
		local buff = status[idx]

		if buff.scope ~= "LAST_TARGET" then
			local targets = self:select_target(attacker, target, buff)

			if targets and #targets > 0 then 
				local targets_id = {}
				for _, v in ipairs(targets) do
					targets_id[#targets_id + 1] = v:getId()
				end
				upload_targets[#upload_targets + 1] = targets_id
			else
				upload_targets[#upload_targets + 1] = {}
			end
		end
	end

	local x, z = 0, 0
	if self:get_skill_series() > 0 then
		x, z = self:getDefultDir(attacker)
	end

	-- 第二阶段技能不上行校验
	if self:get_skill_type() == "auto" and self:_get_skill_cd() <= 0 then 
		self:perfromSkillDisplay(attacker, upload_targets)
		-- print("第二阶段技能不上行校验!", self:get_skill_id(), self:get_skill_name())
		return
	end

	-- self:perfromSkillDisplay(attacker, upload_targets)

	-- local battle_data = getGameData():getBattleDataMt()
	-- if not battle_data:isUpdateShip(attacker:getId()) then return end

	battleRecording:recordVarArgs("battle_use_skill", attacker:getId(), upload_targets, self:get_skill_id(), x, z)
end

function clsSkillInitiative:perfromSkillDisplay(attacker, upload_targets)
	local battle_data = getGameData():getBattleDataMt()

	local status = self:get_add_status()

	local target_count = 0
    for idx = 1, #status do
        local buff = status[idx]
        if buff.scope ~= "LAST_TARGET" then
            target_count = target_count + 1

            local targets = {}
            for _, id in ipairs(upload_targets[target_count]) do
                targets[#targets + 1] = battle_data:getShipByGenID(id)
            end
            
            local function callback(t_targets)
                for _, target in ipairs(t_targets) do
                    self:skill_effect(attacker, target, idx)
                end
                local eff_music = self:get_fire_music()
                if eff_music and eff_music ~= "" then
                    play_effect_music(eff_music, attacker:getId(), attacker:getUid())
                end
            end

            if targets and #targets > 0 then 
                -- 有技能摇杆的直接释放
                local skill_series = self:get_skill_series()
                if tonumber(skill_series) > 0 and tonumber(skill_series) < 100 then 
                    callback(targets)
                else
                    self:use_effect_display(attacker, targets, callback)
                end
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------

-- 施放限制status列表
function clsSkillInitiative:get_status_limit()
	return {}
end

function clsSkillInitiative:get_skill_clear_status()
	return {}
end

function clsSkillInitiative:get_skill_active_status()
    return {}
end

function clsSkillInitiative:get_skill_end_sctive_status()
    return {}
end

-- 施放目标必须在特定距离内
function clsSkillInitiative:get_limit_distance_max(attacker, lv)
	return 999999	
end

-- 施放目标拓展距离
function clsSkillInitiative:_get_limit_distance_max(attacker, lv)
	return self:get_limit_distance_max(attacker, lv)
end

-- 施放目标必须在特定距离内
function clsSkillInitiative:get_limit_distance_min(attacker)
	return 0
end

-------------------------------------------------------------------------------------------------------------------------

-- 目标选择函数
function clsSkillInitiative:select_target(attacker, target, status)
	local targets = self:select_scope(attacker, target, status)

	return targets
end

function clsSkillInitiative:select_cnt(attacker, status)
	local cnt = 1
	if status then
		cnt = status.select_cnt(attacker, self:get_skill_lv(attacker))

		if not cnt then return 1 end
	end
	
	return cnt
end

function clsSkillInitiative:check_target_distance(attacker, target, dist_min, dist_max)
	if not dist_min or not dist_max then return false end

	local dist = GetDistanceFor3D(attacker.body.node, target.body.node)

	if dist >= dist_min and dist < dist_max then 
		return true
	end

	return false
end

function clsSkillInitiative:check_target_limit(target)
	return true
end

function clsSkillInitiative:check_target(attacker, target, dist_min, dist_max, job)
	if not target or target:is_deaded() or target:is_hide() then return false end

	local check_distance = self:check_target_distance(attacker, target, dist_min, dist_max)
	local check_limit = self:check_target_limit(target)

	local check_job = true
	if job then
		check_job = target:getSailorJob() == job
	end

	return check_distance and check_limit and check_job
end

function clsSkillInitiative:select_scope(attacker, target, status)
	local lv = self:get_skill_lv(attacker)
	local scope = status.scope

	local cnt = self:select_cnt(attacker, status)

	local selectFunc = selectTargetMethod[scope]

	if selectFunc then
		return selectFunc(self, attacker, target, lv, cnt, status.sort_method)
	else
		print("Error!!! Unknow scope!!!")

		return {}
	end
end

-------------------------------------------------------------------------------------------------------------------------

-- 技能限制原因
function clsSkillInitiative:SKILL_LIMIT_RESULT()
	return skill_warning
end

-- 技能类型
function clsSkillInitiative:get_skill_type()
	return "initiative"
end

-- 技能名字
function clsSkillInitiative:get_skill_name()
	return T("主动技能基类")
end

-- 技能id
function clsSkillInitiative:get_skill_id()
	return "skill_initiative"
end

-- 技能cd
function clsSkillInitiative:_get_skill_cd(attacker)
	return 0
end

-- 技能cd
function clsSkillInitiative:get_skill_cd(attacker)
	local cd = self:_get_skill_cd(attacker)
	if self:is_initiative(attacker) then
		cd = cd*(1 - attacker:getMinusCD()/1000.0)
	end

	if cd < 0 then
		return 0
	end
	
	return cd
end

function clsSkillInitiative:get_skill_series()
	return 0
end

-- 气血消耗公式
function clsSkillInitiative:calc_hp_cost( attacker, lv )
	return 0
end

-- 怒气消耗公式
function clsSkillInitiative:calc_sp_cost( attacker, lv )
	return 0
end

-- 技能消耗
function clsSkillInitiative:calc_cost(attacker)
	local tbCost = {}
	
	local lv = self:get_skill_lv(attacker)
	
	local hp = self:calc_hp_cost(attacker, lv)
	local sp = self:calc_sp_cost(attacker, lv)

	tbCost.hp = hp
	tbCost.sp = sp

	return tbCost 
end

function clsSkillInitiative:status_limit_display()
end

-- 技能限制显示
function clsSkillInitiative:skill_limit_display(limit_code)
	alert:battleWarning({msg = limit_code})
end

function clsSkillInitiative:get_skill_lv(attacker)
	local skillId = self:get_skill_id()

	local lv = attacker:has_skill_ex(skillId)

	return lv
end

function clsSkillInitiative:get_add_status()
	return {}
end

function clsSkillInitiative:get_select_scope()
	return "FRIEND"
end

-----------------------显示模块-------------------------
-- 技能施放音效
function clsSkillInitiative:get_effect_music()
	return ""
end

-- 技能受击音效
function clsSkillInitiative:get_hit_music()
	return ""
end

-- 获取施法前特效名称
function clsSkillInitiative:get_skill_use_effect()
	return "tx_skillready"
end

-- 获取受击特效名称
function clsSkillInitiative:get_skill_hit_effect()
	return "tx_shouji"
end

function clsSkillInitiative:play_use_effect_music(id, uid)
	local sound = self:get_effect_music()
	play_effect_music(sound, id, uid)
end

-- 施法前显示
function clsSkillInitiative:use_effect_display(attacker, targets, callback)
	local eff_names = self:get_before_effect_name()
	local eff_dt = self:get_before_effect_time()/milisec_base
	local eff_types = self:get_before_effect_type()

 	local skill_series = self:get_skill_series()
	if skill_series > 100 then
		local lv = self:get_skill_lv(attacker)
		local range = self:get_limit_distance_max(attacker, lv)
		local pos_info = attacker:getData(self:get_skill_id())
		attacker.body:showBossSkillRange(range, skill_series, Vector3.new(pos_info.x, 0, pos_info.z))
	end

	local call_back = function()
		if skill_series > 100 then
			attacker.body:dismissBossSkillRange()
		end
		
		if type(callback) == "function" then
			callback(targets)
		end
	end

	if type(eff_names) == "table" and #eff_names > 0 then
		for i, eff_name in ipairs(eff_names) do
			eff_type = eff_types[i]
			
			local func = skill_effect_util.effect_funcs[eff_type]
			if func and eff_name and eff_name ~= "" then
				func({id = eff_name, owner = attacker, duration = eff_dt, callback = call_back})

				call_back = nil
			end
		end
	else
		call_back()
	end

	self:play_use_effect_music(attacker:getId(), attacker:getUid())
end

function clsSkillInitiative:get_before_effect_name()
	return {}
end

function clsSkillInitiative:get_before_effect_type()
	return {}
end

function clsSkillInitiative:get_before_effect_time()
	return 0
end

function clsSkillInitiative:get_effect_name()
	return ""
end

-- 获取显示特效类型
function clsSkillInitiative:get_effect_type()
	-- 类型：
	-- @proj 挂上飞行器
	-- @composite 挂上模型粒子特效(可能模型与粒子的混合体)
	-- @tech 目标模型tech 
	return ""
end

-- 特效播放时间
function clsSkillInitiative:get_effect_time()
	return 0
end

function clsSkillInitiative:get_fire_music()
	return ""
end

-- 技能施放特效显示
function clsSkillInitiative:skill_effect(attacker, target, status_idx)
	local all_status = self:get_add_status()
	local status = all_status[status_idx]
	local eff_name = status.effect_name
	local eff_type = status.effect_type
	local eff_time = status.effect_time
	
	local skill_id = self:get_skill_id()
	-- 获取对应的特效显示函数
	local func = skill_effect_util.effect_funcs[eff_type]

	local callback = self.end_display_call_back

	if func and eff_name and eff_name ~= "" then
		local x, z = 0, 0
		local position_info = attacker:getData(self:get_skill_id())
		if type(position_info) == "table" then
			x = position_info.x
			z = position_info.z
		end
		local skill_series =  self:get_skill_series()
		local lv = self:get_skill_lv(attacker)
		local range = self:get_limit_distance_max(attacker, lv)
		func({id = eff_name, owner = attacker, target = target, attacker = attacker, callback = callback, 
            skill_id = skill_id, duration = eff_time, ext_args = status_idx, x = x, z = z, skill_series = skill_series,
            rang = range})
	else
		self:end_display_call_back(attacker, target, status_idx)
	end
end

-- 是否主动技能
function clsSkillInitiative:is_initiative(attacker)
	return self:get_skill_type() == "initiative"
end

-- 判断是否为手动施放的技能
function clsSkillInitiative:is_player_initiative(attacker)
	local battle_data = getGameData():getBattleDataMt()
	return battle_data:isCurClientControlShip(attacker:getId()) and self:is_initiative()
end

function clsSkillInitiative:ShowUnSelectSkillPerfrom(attacker)
	local target = attacker:getTarget()
	local eff_names = self:get_before_effect_name()
	local eff_dt = 1000
	local eff_types = self:get_before_effect_type()

	
	
	if type(eff_names) == "table" and #eff_names > 0 then
		for i, eff_name in ipairs(eff_names) do
			-- 施法前特效不能是proj类型的
			eff_type = eff_types[i]
			assert(eff_type ~= "proj")
			
			local func = skill_effect_util.effect_funcs[eff_type]
			if func and eff_name and eff_name ~= "" then
				-- 录像
				battleRecording:recordVarArgs("util_effect", attacker.id, eff_name, eff_type, eff_dt)
				func({id = eff_name, owner = attacker, duration = eff_dt})
			end
		end
	end
	--self:removeUnSelectSkillPerfrom(attacker)
	self:play_use_effect_music(attacker:getId(), attacker:getUid())
end

function clsSkillInitiative:removeUnSelectSkillPerfrom(attacker)
	
	local eff_names = self:get_before_effect_name()
	local eff_types = self:get_before_effect_type()

	if type(eff_names) == "table" and #eff_names > 0 then
		battleRecording:recordVarArgs("del_effect", attacker.id, eff_types, eff_names)
		for i, eff_name in ipairs(eff_names) do
			-- 施法前特效不能是proj类型的
			eff_type = eff_types[i]
			assert(eff_type ~= "proj")
			
			local func = skill_effect_util.del_effect_funcs[eff_type]
			if func and eff_name and eff_name ~= "" then
				self.target_id = target_id
    			self.eff_type = eff_type
    			self.eff_name = eff_name
    			self.buff_icon = buff_icon
				-- 录像
				
				func({id = eff_name, target = attacker, owner = attacker})
			end
		end
	else
		
	end
end

function clsSkillInitiative:end_display(attacker, target, idx)
	local lv = self:get_skill_lv(attacker)

	local all_status = self:get_add_status()
	for k = idx, #all_status do
		local info = all_status[k]

		if k ~= idx and info.scope ~= "LAST_TARGET" then
			break
		end

		local result = info["pre_action"](attacker, target, lv)

		local translate = result.translate
		if translate and not target:hasBuff("unmovable") then
			attacker:translateAnimation(target, translate)
		end
	end

	local sound = self:get_hit_music()
	if self.is_hit_music_played or sound == "" then return end
	play_effect_music(sound, target:getId(), attacker:getUid(), true)
	self.is_hit_music_played = true
end

function clsSkillInitiative:end_display_call_back(attacker, target, idx, dir, is_bullet)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	self:end_display(attacker, target, idx)

	if not battle_data:isUpdateShip(attacker:getId()) then return end

	local a_id = attacker:getId()
	local t_id = target:getId()
	local skill_id = self:get_skill_id()

	local x, y = 0, 0
	if dir then
		x = math.floor(dir:x()*FIGHT_SCALE + 0.5)
		y = math.floor(dir:z()*FIGHT_SCALE + 0.5)
	end

	local combo = FV_BOOL_FALSE
	if is_bullet and idx == FIRST_STATUS and battle_data:isCurClientControlShip(attacker:getId()) then
		combo = FV_BOOL_TRUE
	end

	battleRecording:recordVarArgs("battle_add_status", a_id, t_id, skill_id, idx, x, y, combo)
end

return clsSkillInitiative

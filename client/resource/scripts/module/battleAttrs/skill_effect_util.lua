local proj_eff = require("game_config/battle/proj_eff")
local bulletManager = require("gameobj/battle/bulletManager")
local shipEffect = require("gameobj/battle/shipEffectLayer")
local cls_gousuo_manager = require("gameobj/battle/GousuoManager")
local music_info = require("game_config/music_info")
local WalkManager = require("gameobj/battle/walkManager")
local battleRecording = require("gameobj/battle/battleRecording")
local composite_effect = require("gameobj/composite_effect")
local sceneEffect = require("gameobj/battle/sceneEffect")


local util = {}

function util.proj_effect(params)
	local proj_id = params.id
	local attacker = params.attacker
	local target = params.target
	local owner = params.owner
	local callback = params.callback
	local skill_id = params.skill_id
	local ext_args = params.ext_args
	local rotate = params.rotate
	assert(attacker ~= target)

	if not attacker or not target then return end
	
	local proj_cfg = proj_eff[proj_id]
	local bullet_id = proj_cfg.bullet_id
	if proj_cfg.bullet_depend_on_ship == 1 then
		local boatData = getGameData():getBoatData()
		bullet_id = boatData:getBulletRes(attacker.baseData.ship_id)
	end

	local battle_data = getGameData():getBattleDataMt()

	local speed_scale = 100
	local bullet_param = {
		bullet_id = bullet_id,
		skill_id = skill_id,
		target_id = target:getId(),
		attacker_id = attacker:getId(),
		rotate = rotate,
		remain = proj_cfg.remain,
		speed = proj_cfg.speed/speed_scale,
		isActSkill = battle_data:isCurClientControlShip(attacker:getId()),
		callback = callback,
		ext_args = ext_args,
		rotate = proj_cfg.rotate,
	}
	
	local params = util.initBulletParams(bullet_param, proj_cfg.shoot_setting)
	bulletManager.createBullets(params, proj_cfg.shoot_dt)	
end

function util.composite_effect(params)
	local owner = params.owner
    local id = params.id
    if not owner then return end
	owner:getBody():showEffect(id)
end

function util.scene_particle_effect(params)
	local id = params.id
	local attacker = params.attacker
	local target = params.target
	local owner = params.owner
	local callback = params.callback
	local skill_id = params.skill_id
	local duration = params.duration
	local ext_args = params.ext_args

	if not owner then return end
	
	local name = EFFECT_3D_PATH..id..".particlesystem"
	local particle = sceneEffect.createEffect({file = name, isStart = true, followNode = owner:getBody().node, 
								dt = duration, callback = callback, skill_id = skill_id, pos = owner:getPosition3D(),
								attacker = attacker, target = target, ext_args = ext_args,})
	
	owner:getBody().scene_effect[id] = particle
end

function util.local_particle_effect(params)
	local id = params.id
	local attacker = params.attacker
	local target = params.target
	local owner = params.owner
	local callback = params.callback
	local skill_id = params.skill_id
	local duration = params.duration
	local ext_args = params.ext_args

	if not owner then return end
	
	local name = EFFECT_3D_PATH..id..".particlesystem"
	local particle = sceneEffect.createEffect({file = name, isStart = true, parent = owner:getBody().node, 
								dt = duration, callback = callback, skill_id = skill_id, 
								attacker = attacker, target = target, ext_args = ext_args,})
	
	owner:getBody().scene_effect[id] = particle
end

-- 攻击者和被攻击者 共有的特效。
function util.share_particle_effect(params)
	local id = params.id
	local attacker = params.attacker
	local target = params.target
	local owner = params.owner
	local callback = params.callback
	local skill_id = params.skill_id
	local duration = params.duration
	local ext_args = params.ext_args

	if not attacker or not target then return end
	
	-- 2者的ID作为key，并且按大小顺序
	local id_1 = target:getId()
	local id_2 = attacker:getId()
	if id_1 > id_2 then id_1, id_2 = id_2, id_1 end 
	local key = id .. id_1 .. id_2
	if sceneEffect.IsExist(key) then return end 
	
	local name = EFFECT_3D_PATH..id..".particlesystem"
	local particle = sceneEffect.createEffect({file = name, isStart = true, followNode = "share", key = key,
								dt = duration, callback = callback, skill_id = skill_id, pos = attacker:getPosition3D(), 
								attacker = attacker, target = target, ext_args = ext_args,})
end


function util.gousuo_effect(params)
	cls_gousuo_manager:createGousou(params)					
end

function util.real_fenshen_effect(id, duration, skills, ship_id, gen_id, x, z)
	local battle_data = getGameData():getBattleDataMt()

	local ship_data = battle_data:getShipByGenID(id)
	if not ship_data then return end

	local data = table.clone(ship_data.baseData)

	data[FV_ATT_FAR] = data[FV_ATT_FAR]
	data[FV_ATT_NEAR] = data[FV_ATT_NEAR]
	data[FV_DEFENSE] = data[FV_DEFENSE]/2
	data[FV_HP_MAX] = data[FV_HP_MAX]/2
	data[FV_HP] = data[FV_HP]/2
	
	data.role = nil
	data.walk_Id = 1
	data.gen_id = gen_id
	data.ship_id = ship_id
	data.is_leader = false
	data.is_player = false
	data.sailor_id = nil
	data.team_id = ship_data:getTeamId()
	data.tag = battle_config.FEN_SHEN_TAG
	data.tickToDie = duration
	data.new_ai_id = {}
	data.ai_id = {}

	data.skills = {}
	for k, v in pairs(skills) do
		data.skills[#data.skills + 1] = {level = 1, id = tonumber(v)}
	end
	
	local shipEntity = require("gameobj/battle/newShipEntity")
	local entity = shipEntity.createShipEntity(data)
	entity.body:setTechnique("ghost")
	entity.body:setBanRotate(true)
	
	local alpha = 0.7
	local endTime = 1000
	
	local function changeTechnique()					
		entity.body:setTechnique("common_texture_flow")
		local id = "tx_1036"
		entity.body:setFlowState(id)
		SetTranslucent(entity.body.node, nil, alpha)
		entity.body:setBanRotate(false)
		entity.body:resetPath()
	end
	local array = CCArray:create()
	local delay = CCDelayTime:create(endTime/1000)
	array:addObject(delay)
	local callfunc = CCCallFunc:create(changeTechnique)
	array:addObject(callfunc)
	entity.body.acSp:runAction(CCSequence:create(array))

	entity:changeTarget(ship_data:getTargetId())

	if ship_id then
		local to_run_ai = string.format("sk_fenshen_%d", data.ship_id)

		entity:addAI(to_run_ai, {})
		local ai_obj = entity:getAI(to_run_ai)
		if ai_obj then
			ai_obj:tryRun(AI_OPPORTUNITY.RUN)
		end
	end

	local pos = ship_data:getPosition3D()
	if not pos then 
		entity:setPosition(x, z)
		return
	end

	local forward = Vector3.new()
	Vector3.subtract(Vector3.new(x, 0, z), pos, forward)

	LookForward(entity.body.node, forward)

	local keyCount = 2
	local keyTimes = {0, endTime}
	local keyValues = {pos:x(), pos:y(), pos:z(), x, 0, z}

	local ani = entity.body.node:createAnimation("Move", Transform.ANIMATE_TRANSLATE(),
												keyCount, keyTimes, keyValues, "LINEAR")
	ani:play()
end

local xilahuo_pos =
{
	["smallShip"] =  {0.815014, 20.2733,-30},
	["middleShip"] =  {0.815014, 20.2733, -40},
	["bigShip"] = {0.815014, 20.2733, -50}
}
function util.xilahuo_effect(params)
	local ship_data = params.owner
	local duration = params.duration
	local idx = params.ext_args
	local skill_id = params.skill_id
	local callback = params.callback
	local ext_args = params.ext_args
	--util.endActiveSkillEff()
	if ship_data.isDeaded then return end
	local tool = require("module/dataHandle/dataTools")
	local boatCfg = tool:getBoat(ship_data.baseData.ship_id)
	local pos = xilahuo_pos[boatCfg.kind]
	
	ship_data.body:showEffect("jn_xilahuo", nil, Vector3.new(unpack(pos)))
	
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local tickCount = 0

	local function checkXilahuo(dt)
		tickCount = tickCount + dt
		if tickCount > duration or ship_data.isDeaded then 
			if ship_data.xilahuoTimer then
				local scheduler = CCDirector:sharedDirector():getScheduler()
				scheduler:unscheduleScriptEntry(ship_data.xilahuoTimer)
				ship_data.xilahuoTimer = nil
			end
			if ship_data.body then 
				ship_data.body:hideEffect("jn_xilahuo")
			end
			return 
		end
		local origin = ship_data.body.node:getTranslation()
		local dir = ship_data.body.node:getForwardVectorWorld()
		local near_targets = ship_data:getNearAttackAbleShips()
		if #near_targets == 0 then return end
		local pick_objs = util.pickRayObect(origin, dir, near_targets)
		for _, v in pairs(pick_objs) do
			local skill_map = require("game_config/battleSkill/skill_map")
			local cls_skill = skill_map[skill_id]
			if cls_skill then 
				callback(cls_skill, ship_data, v, ext_args)
			end
		end
	end
	local checkTime = 1
	ship_data.xilahuoTimer = scheduler:scheduleScriptFunc(checkXilahuo, checkTime, false)		
end

-- 流光
function util.liuguang_effect(params)
	local owner = params.owner
    local id = params.id
	owner:getBody():setFlowState(id)
end


function util.cocos_effect(params)
	local owner = params.owner
    local id = params.id
	local duration = params.duration
	local callback = params.callback
	if not owner or not id then return end 
	
	composite_effect.new(id, 0, 0, owner:getBody().ui)
	if duration and duration > 0 then 
		local array = CCArray:create()
		local delay = CCDelayTime:create(duration)
		local callfunc = CCCallFunc:create(function()
			if callback then callback() end 
		end)
		array:addObject(delay)
		array:addObject(callfunc)
		owner:getBody().acSp:runAction(CCSequence:create(array))		
	else 	
		if callback then callback() end 
	end 
end 

function util.particle_launch_effect(params)
	local id = params.id
	local attacker = params.attacker
	local target = params.target
	local owner = params.owner
	local callback = params.callback
	local skill_id = params.skill_id
	local duration = params.duration or 1
	local ext_args = params.ext_args
	local rang = params.rang or 400
	local x = params.x
	local z = params.z

	local skill_series = params.skill_series
	if not owner or not owner.body or not owner.body.node  then return end

	
	local name = EFFECT_3D_PATH..id..".particlesystem"
	local function show_launch_effect(x_1, y_1)
		if not owner or not owner.body or not owner.body.node then return end

		local pos = owner.body.node:getTranslationWorld()
		local particle = sceneEffect.createEffect({file = name, isStart = true, pos = pos, dt = duration, 
			skill_id = skill_id, attacker = attacker, target = target})

		if not particle or not particle:GetNode() then return end
		
		owner:getBody().scene_effect[id] = particle

		local keyCount = 2
		local keyTimes = {0, duration * 1000}
		local node = particle:GetNode()
		local pos = node:getTranslationWorld()
		
		local endPosX = pos:x() + rang*x_1
		local endPosY = pos:y()
		local endPosZ = pos:z() + rang*y_1
		
		local keyValues = {pos:x(), pos:y(), pos:z(), 
							endPosX, endPosY, endPosZ}	
		local ani = node:createAnimation("Move", Transform.ANIMATE_TRANSLATE(),
													keyCount, keyTimes, keyValues, "LINEAR")
		ani:play()
	end

	local dealy_time = CCDelayTime:create(duration/2)

	local skill_map = require("game_config/battleSkill/skill_map")

	if skill_series > 100 then
		show_launch_effect(x, z)

		display.getRunningScene():runAction(CCSequence:createWithTwoActions(dealy_time, CCCallFunc:create(function() 
			if type(callback) == "function" then
				callback(skill_map[skill_id], attacker, target, ext_args, Vector3.new(x, 0, z))
			end
		end)))
	else
		local angles = {
			0,
			15,
			-15,
		}

		for i = 1, 3 do
			local angle = angles[i]
			local dir = RotateVector3(Vector3.new(0, 1, 0),angle, Vector3.new(x, 0, z)):normalize()

			local x_1 = dir:x()
			local y_1 = dir:z()
			
			local sequence = CCSequence:createWithTwoActions(dealy_time, CCCallFunc:create(function() 
				if type(callback) == "function" then
					local skill_map = require("game_config/battleSkill/skill_map")
					callback(skill_map[skill_id], attacker, target, ext_args, Vector3.new(x_1, 0, y_1))
				end
			end))

			local callfunc = CCCallFunc:create(function()
				show_launch_effect(x_1, y_1)
			end)

			local array_1 = CCArray:create()
			array_1:addObject(sequence)
			array_1:addObject(callfunc)
			local spawn = CCSpawn:create(array_1)

			local array = CCArray:create()
			array:addObject(CCDelayTime:create((i - 1)*0.3))
			array:addObject(spawn)

			display.getRunningScene():runAction(CCSequence:create(array))
		end
	end
end

function util.del_particle_launch_effect(params)
	local owner = params.owner
    local id = params.id
	local particle = owner:getBody().scene_effect[id]
	if particle then
		sceneEffect.Stop(particle)
		owner:getBody().scene_effect[id] = nil 
	end 
end

function util.del_proj_effect()
	-- 交由bullet类管理
end

function util.del_composite_effect(params)
	local owner = params.owner
    local id = params.id
	owner:getBody():hideEffect(id)
end

function util.del_scene_particle_effect(params)
	local owner = params.owner
    local id = params.id
	local particle = owner:getBody().scene_effect[id]
	if particle then
		sceneEffect.Stop(particle)
		owner:getBody().scene_effect[id] = nil 
	end
end

function util.del_local_particle_effect(params)
	local owner = params.owner
    local id = params.id
	local particle = owner:getBody().scene_effect[id]
	if particle then
		sceneEffect.Stop(particle)
		owner:getBody().scene_effect[id] = nil 
	end 
end

function util.del_share_particle_effect(params)
end 


function util.del_liuguang_effect(params)
	local owner = params.owner
	owner:getBody():resetStatus()
end 


function util.armature_scene_effect(params)
	local ship_id = params.owner.id
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isCurClientControlShip(ship_id) then
		return
	end
	local key = params.id
	local duration = params.duration
    local armatureTab = {}
    armatureTab[1] = "effects/"..key..".ExportJson"
    
	local effect_layer = battle_data:GetLayer("effect_layer")
	if not tolua.isnull(effect_layer) then
		effect_layer:showArmatureSceneEffect(key, duration)
	end
	
end

function util.del_armature_scene_effect(params)
	local key = params.id
    local battle_data = getGameData():getBattleDataMt()
	local effect_layer = battle_data:GetLayer("effect_layer")
	if not tolua.isnull(effect_layer) then
		effect_layer:removeArmatureSceneEffect(key)
	end
end

function util.cocos_scene_effect(params)

	local ship_id = params.owner.id
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isCurClientControlShip(ship_id) then
		return
	end
	local owner = params.owner
    local id = params.id
	local duration = params.duration
	local callback = params.callback
	
	local effect_layer = battle_data:GetLayer("effect_layer")
	if not tolua.isnull(effect_layer) then
		effect_layer:showCocosSceneEffect(id, duration, callback)
	end
end

function util.del_cocos_scene_effect(params)
	local key = params.id
    local battle_data = getGameData():getBattleDataMt()
	local effect_layer = battle_data:GetLayer("effect_layer")
	if not tolua.isnull(effect_layer) then
		effect_layer:removeArmatureSceneEffect(key)
	end
end

util.effect_funcs = 
{
	["proj"] = util.proj_effect,
	["composite"] = util.composite_effect,
	["particle_scene"] = util.scene_particle_effect,
	["particle_local"] = util.local_particle_effect,
	["particle_share"] = util.share_particle_effect,
	["gousuo"] = util.gousuo_effect,
	["fenshen"] = util.fenshen_effect, 
	["xilahuo"] = util.xilahuo_effect,
	["liuguang"] = util.liuguang_effect,
	["cocos_effect"] = util.cocos_effect,
	["particle_launch"] = util.particle_launch_effect,
	["armature_scene"] = util.armature_scene_effect,
	["cocos_scene"] = util.cocos_scene_effect,

}
util.del_effect_funcs = 
{
	["proj"] = util.del_proj_effect,
	["composite"] = util.del_composite_effect,
	["particle_scene"] = util.del_scene_particle_effect,
	["particle_local"] = util.del_local_particle_effect,
	["particle_share"] = util.del_share_particle_effect,
	["tech"] = util.del_tech_effect,
	["gousuo"] = util.del_gousuo_effect,
	["fenshen"] = util.del_fenshen_effect,
	["liuguang"] = util.del_liuguang_effect,
	["particle_launch"] = util.del_particle_launch_effect,
	["armature_scene"] = util.del_armature_scene_effect,
	["cocos_scene"] = util.del_cocos_scene_effect,
}



function util.checkBoundPos(x, z)
	local width, height = CameraFollow:GetSceneBound()

	if x < 0 then
		x = 0
	elseif z < - height then
		z = - height
	elseif x > width then
		x = width
	elseif z > 0 then 
		z = 0
	end
	return x, z
end

function util.checkLandPos(pos, vec, distance)
	-- 碰撞陆地
	local mis_distance = 32

	local vec_des = Vector3.new()
	Vector3.add(pos, vec, vec_des)
	local in_land = WalkManager.inLand(Vector3ToScreen(vec_des, BattleInit3D:getScene():getActiveCamera()))
	if not in_land then return vec_des:x(), vec_des:z() end

	distance = distance - mis_distance
	if distance <= 0 then return pos:x(), pos:z() end

	vec:normalize()
	vec:scale(distance)

	return util.checkLandPos(pos, vec, distance)
end

function util.initBulletParams(baseParams, bullet_pos_t)
	local params = {}
	for i = 1, #bullet_pos_t do
		local isActSkillBegin, isActSkillEnd
		if i == 1 then 
			isActSkillBegin = true
			isActSkillEnd = false
		elseif i == #bullet_pos_t then
			isActSkillBegin = false
			isActSkillEnd = true
		else
			isActSkillBegin = false
			isActSkillEnd = false
		end
		local bullet_param = table.clone(baseParams)
		bullet_param.isMulti = true
		bullet_param.number = i
		bullet_param.isActSkillBegin = isActSkillBegin
		bullet_param.isActSkillEnd = isActSkillEnd
		bullet_param.bullet_pos_t = bullet_pos_t 
		params[i] = bullet_param
	end
	return params
end

function util.blinkAction(params)
	local ship_data = params.ship_data
	local start_call = params.start_call
	local end_call = params.end_call
	local dt = params.dt
	local durationTime = params.durationTime
	local mod_base = params.mod_base
	
	local scheduler = CCDirector:sharedDirector():getScheduler()
	local tick_count = 0
	local small_tick = 0
	local timer = scheduler:scheduleScriptFunc(function(dt)		
		if tick_count >= durationTime or ship_data.isDeaded then 
			if not ship_data.isDeaded then
				end_call()
			end
			local scheduler = CCDirector:sharedDirector():getScheduler()
			scheduler:unscheduleScriptEntry(ship_data.xilahuo_timer)
			--ship_data.xilahuo_timer = nil
			return
		end
		
		-- local initAlpha = 0.9
		-- local endAlpha = 0.3
		-- if small_tick < 1/2 then 
			-- local alpha = (initAlpha - (initAlpha - endAlpha)/(1/2)*small_tick) 
		-- else
			-- local alpha = endAlpha + (small_tick - 1/2)*(initAlpha - endAlpha)/(1/2)*small_tick
		-- end
		tick_count = tick_count + dt
		start_call(tick_count, mod_base)
	end, dt, false) 	
	return timer
end

function util.pickRayObect(origin, dir, targets)
	local ray = Ray.new(origin, dir)
	local ret = {}
	for _, v in pairs(targets) do
		local boundingBox = v.body.node:getBoundingSphere()
		local mat = v.body.node:getWorldMatrix()
		--boundingBox:transform(mat)
		--local vec = boundingBox:getExtent()
		local distance = ray:intersects(boundingBox)

		if distance ~=  Ray.INTERSECTS_NONE() then
			ret[#ret + 1] = v
		end
	end
	return ret
end

function util.translateAnimation(target, key_values)
	if not target or not target.body or not target.body.node then return end

	local keyCount = 2
	local keyTimes = {0, 400}

	local anim = target.body.node:createAnimation("Move", Transform.ANIMATE_TRANSLATE(),
										keyCount, keyTimes, key_values, "LINEAR")
	anim:play()

	local running_scene = GameUtil.getRunningScene()
	if running_scene then
		local ac_1 = CCDelayTime:create(0.4)
		local ac_2 = CCCallFunc:create(function()
			if not target.is_ship then return end
			local body = target:getBody()
			if body then
				body:setRotateAngle(GetAngleBetweenNodeAndPoint(body.node, body.target_pos))
				body:updateUI()
			end
		end)
        
        running_scene:runAction(CCSequence:createWithTwoActions(ac_1, ac_2))
	end
end

function util.beforeSkillTuji(attacker, targets, callback, clsSkill)
	local t_targets = clsSkill:selectTargetEnemy(attacker, attacker.target, 1, 1, "DISTANCE_ASEC", nil, true)

	if #t_targets < 1 then return end

	local target = t_targets[1]

	if attacker:is_deaded() or not target or target:is_deaded() then return end

	local eff_names = clsSkill:get_before_effect_name()
	local eff_dt = clsSkill:get_before_effect_time(attacker, clsSkill:get_skill_lv(attacker), target)/1000
	local eff_types = clsSkill:get_before_effect_type()

	attacker.tuji_target = target
	attacker.body:setPathNode(false)
	attacker.touch_pos = nil
	
	attacker.body:setBanTurn(true)
	attacker.body:setBanRotate(true)

	LookAtPointAnimation(attacker.body.node, target.body.node:getTranslation(), eff_dt, 0.02)

	local call_back = function()
		if type(callback) == "function" then
			callback(targets)
		end
	end

	if type(eff_names) == "table" and #eff_names > 0 then
		for i, eff_name in ipairs(eff_names) do
			eff_type = eff_types[i]
			
			local func = util.effect_funcs[eff_type]
			if func and eff_name and eff_name ~= "" then
				func({id = eff_name, owner = attacker, duration = eff_dt, callback = call_back})
			end
		end
	else
		call_back()
	end

	if not attacker:getBody():getNode():isInFrustum() then return end

	local sound = clsSkill:get_effect_music()
	if sound ~= nil and sound ~= "" then	
		local sound_res = music_info[sound].res

		local battle_data = getGameData():getBattleDataMt()
		local is_player = battle_data:isCurClientControlShip(attacker:getId())
		audioExt.playEffect(sound_res, false, is_player)
	end
end

return util

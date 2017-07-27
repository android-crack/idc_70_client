local SceneEffect = {}

local effect_list = {}
local effect_key_list = {}

function SceneEffect.createEffect(params)
	local file = params.file
	local pos = params.pos or Vector3.new(0, 0, 0)
	local isStart = params.isStart
	local followNode = params.followNode
	
	local parent = params.parent or BattleInit3D:getLayerShip3d()
	if not parent then return end

	local offset = params.offset or Vector3.new(0,0,0)
	local dt = params.dt
	local callback = params.callback
	local skill_id = params.skill_id
	local attacker = params.attacker
	local target = params.target
	local is_retain = params.is_retain or false  --场景结束前不释放
	local key = params.key or ""
	local ext_args = params.ext_args

	local owner = nil
	local is_ship = nil
	local battle_data = getGameData():getBattleDataMt()
	if battle_data:GetBattleSwitch() and (params.parent or (params.followNode and params.followNode ~= "share")) then
		is_ship = true

		local node = params.parent
		if not node then
			node = params.followNode
		end

		owner = battle_data:getShipByGenID(tonumber(node:getId()))

		if not owner then return end

		local effect_table = owner:getData("effect_table") or {}

		effect_table[file] = effect_table[file] or 0

		owner:setData("effect_table", effect_table)

		if effect_table[file] > 2 then 
			if callback then
				if skill_id then
					local skill_map = require("game_config/battleSkill/skill_map")
					callback(skill_map[skill_id], attacker, target, ext_args)
				else
					callback()
				end
			end

			-- print("=======================SceneEffect!!!! 特效数量超过3", file)
			return 
		end
		effect_table[file] = effect_table[file] + 1
		owner:setData("effect_table", effect_table)
	end
	
	local ParticleSystem = require("particle_system")
	local particle = ParticleSystem.new(file, dt)
	if not particle  then return end
	
	

	local tmp = 
	{
		name = file, particle = particle, attacker = attacker, dt = dt, cur_dt = 0, target = target, 
		followNode = followNode, offset = offset, is_retain = is_retain,key = key, callback = callback, 
		skill_id = skill_id, ext_args = ext_args, owner = owner, is_ship = is_ship
	}
	effect_list[particle] = tmp
	effect_key_list[key] = true
	
	local particleNode = particle:GetNode()
	parent:addChild(particleNode)
	particleNode:setTranslation(pos)
	
	if isStart then
		particle:Start()
	end
	
	return particle
end
	
function SceneEffect.update(dt)
	local release_list = {}
	
	local function end_callback(v)
		if v.callback then
			if v.skill_id then
				local skill_map = require("game_config/battleSkill/skill_map")
				v.callback(skill_map[v.skill_id], v.attacker, v.target, v.ext_args)
			else
				v.callback()
			end
		end
		v.is_end = true 
	end 
	
	for i, v in pairs(effect_list) do
		local particle = v.particle
		if v.followNode then 
			if v.followNode == "share" then -- 在2者中间
				if not v.attacker:is_deaded() and not v.target:is_deaded() then 
					local pos1 = v.attacker:getBody().node:getTranslation()
					local pos2 = v.target:getBody().node:getTranslation()
					local x = (pos1:x() + pos2:x())/2
					local y = (pos1:y() + pos2:y())/2
					local z = (pos1:z() + pos2:z())/2
					--local pos = Vector3.new(x, y, z)
					--particle:GetNode():setTranslation(pos)
					particle:GetNode():setTranslation(x, y, z)
				end 
			else 
				local pos = v.followNode:getTranslation()
				local ret = Vector3.new()
				Vector3.add(pos, v.offset, ret)
				particle:GetNode():setTranslation(ret)
			end 
		end 
		
		if not v.is_retain then 
			-- 策划配置的播放时间
			if v.dt then 
				if effect_list[i].cur_dt < v.dt then
					effect_list[i].cur_dt = effect_list[i].cur_dt + dt/1000	
				elseif not v.is_end then 
					end_callback(v)
				end
			else 
				if not particle:IsPlaying() then 
					end_callback(v)
				end 
			end 
			
			-- 特效播放完毕，加入删除队列
			if v.is_end and not particle:IsParticleAlive() then 
				release_list[#release_list + 1] = particle
			end 
		end 
	end
	
	-- 删除特效
	for k, v in ipairs(release_list) do
		SceneEffect.ReleaseParticle(v)
	end 
end

function SceneEffect.Show()

end 

function SceneEffect.Hide()

end 

function SceneEffect.IsExist(key)
	return effect_key_list[key]
end 

function SceneEffect.Stop(particle)
	local v = effect_list[particle]
	if v then
		v.is_end = true 
		v.particle:Stop()
	end
end 

function SceneEffect.ReleaseParticle(particle)
	local v = effect_list[particle]
	if v then
		v.particle:Release()
		effect_list[particle] = nil
		effect_key_list[v.key] = nil

		if v.is_ship then
			local effect_table = v.owner:getData("effect_table")

			local cnt = effect_table[v.name] or 0
			effect_table[v.name] = cnt - 1 < 0 and 0 or cnt - 1
			v.owner:setData("effect_table", effect_table)

			-- print("===========================SceneEffect 特效释放", v.name)
		end
	end
end

function SceneEffect.Release()
	for k, v in ipairs(effect_list) do
		SceneEffect.ReleaseParticle(k)
	end
	effect_list = {}
	effect_key_list = {}
end

return SceneEffect

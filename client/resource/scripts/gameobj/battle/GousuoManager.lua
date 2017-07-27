local cls_gousuo_manager = class("cls_gousuo_manager")
cls_gousuo_manager.gousuo_effect = {}

local function adjustGouSuoPos(params)
	local own = params.own
	local target = params.target
	local tiegou1 = params.tiegou1
	local tiegou2 = params.tiegou2
	local startPos_offset = params.startPos_offset
	local endPos_offset = params.endPos_offset
	local tick = params.tick
	local cb_first = params.cb_first
	local durationTime = params.durationTime
	local isShake = params.isShake
	local cb_first_cb = params.cb_first_cb or false
	local skill_id = params.skill_id
	local ext_args = params.ext_args
	local start_offset_tmp = Vector3.new(startPos_offset[1], startPos_offset[2], startPos_offset[3])
	local end_offset_tmp = Vector3.new(endPos_offset[1], endPos_offset[2], endPos_offset[3])
	local ownPos = LocalVector2World(own.body.node, start_offset_tmp)
	tiegou1:setTranslation(ownPos:x(), ownPos:y(), ownPos:z())
	
	local targetPos = LocalVector2World(target.body.node, end_offset_tmp)
	local dir = Vector3.new()
	Vector3.subtract(targetPos, ownPos, dir)
	LookForward(tiegou1, dir)

	local boundingBox = tiegou1:getModel():getMesh():getBoundingBox()
	local center = boundingBox:getCenter()
	local unit = center:length()*2
	local tiegouLength = 30
	local length = GetVectorDistance(ownPos, targetPos) - tiegouLength
	

	-- 绳索完全拉直需要的时间
	local full_rope_tm = 250
	local timeRate = tick/full_rope_tm
	if timeRate > 1 then
		if type(cb_first) == "function" and not params.cb_first_cb then
			local skill_map = require("game_config/battleSkill/skill_map")
			local skill = skill_map[skill_id]
			cb_first(skill, own, target, ext_args)
			params.cb_first_cb = true
		end
		timeRate = 1			
	end
	local scaleZ = length/unit*timeRate
	tiegou1:setScaleZ(scaleZ)

	local forward_vec = tiegou1:getForwardVectorWorld():normalize()
	forward_vec:scale(unit*scaleZ)

	local tiegou2_pos = Vector3.new()
	Vector3.add(ownPos, forward_vec, tiegou2_pos)
	tiegou2:setTranslation(tiegou2_pos)
	Vector3.subtract(ownPos, tiegou2_pos, dir)
	LookForward(tiegou2, dir)
	
	if timeRate == 1 and not isShake then			
		CameraFollow:SceneShake(8, 5)
		params.isShake = true
	end
end

local function clearGouSuo(effect_t)
	local tiegou1 = effect_t.tiegou1
	local tiegou2 = effect_t.tiegou2
	local layer3dShip = BattleInit3D:getLayerShip3d()
	if tiegou1 then
		local parent = tiegou1:getParent()
		parent:removeChild(tiegou1)
	end
	if tiegou2 then
		local parent = tiegou2:getParent()
		parent:removeChild(tiegou2)
	end
	effect_t.tiegou1 = nil
	effect_t.tiegou2 = nil
	effect_t.tick = 0
	effect_t.own = nil
	effect_t.target = nil
end

function cls_gousuo_manager:updateGouSuos(dt)	
	for i, _ in pairs(cls_gousuo_manager.gousuo_effect) do
		local effect_t = cls_gousuo_manager.gousuo_effect[i]
		local own = effect_t.own
		local target = effect_t.target
		local tiegou2 = effect_t.tiegou2
		local tiegou1 = effect_t.tiegou1
		local tick = effect_t.tick
		local durationTime = effect_t.durationTime
		if not own or not target or own.isDeaded or target.isDeaded	then 
			clearGouSuo(effect_t)
			cls_gousuo_manager.gousuo_effect[i] = nil
			return
		end
		if not (tiegou1 and tiegou2 and tick) then return end
		tick = tick + dt
		effect_t.tick = tick
		
		adjustGouSuoPos(effect_t)
		if tick > durationTime then 
			clearGouSuo(effect_t)
			cls_gousuo_manager.gousuo_effect[i] = nil
		end
	end
end

-- 添加buff显示效果
function cls_gousuo_manager:createGousou(params)
	local ship_data = params.attacker
	local target = params.target
	if not target or not target.body or not target.body.node then return end
	if not ship_data or not ship_data.body or not ship_data.body.node then return end
		
	local duration = params.duration
	local cb = params.callback
	local ext_args = params.ext_args
	local skill_id = params.skill_id

	local function createGousou(params)
		if not target.body or not target.body.node then return nil end
		if not ship_data.body or not ship_data.body.node then return nil end

		local startPos_offset = params.startPos_offset
		local endPos_offset = params.endPos_offset
		local ship_data = params.ship_data
		local is_first = params.is_first
		local cb_first = params.cb_first
		local skill = params.skill_id
		local ext_args = params.ext_args
		
		local effect_t = {}
		local name1 = battle_config.gousuo_1 -- 索
		local name2 = battle_config.gousuo_2 -- 钩
		local file1 = string.format("%s%s/%s%s", MODEL_3D_PATH, name1, name1, GPB_EXT)
		local file2 = string.format("%s%s/%s%s", MODEL_3D_PATH, name2, name2, GPB_EXT)
		local tiegou1 = ResourceManager:LoadModel(file1, name1)
		local tiegou2 = ResourceManager:LoadModel(file2, name2)

		local name = "zhaozi02"
		local file = string.format("%s%s/%s%s", MODEL_3D_PATH, name, name, ".gpb")
		local zhaozi02_model = ResourceManager:LoadModel(file, name)
		zhaozi02_model:setTranslation(0, 0, 15)
		zhaozi02_model:setScale(0.1)
		zhaozi02_model:setScaleZ(1.845*0.1)
		tiegou2:addChild(zhaozi02_model)
		tiegou2:setRotation(Vector3.new(0,1,0), math.rad(-90))

		--local durationTime = getSkillBuffDurationTime(skill_data)
		-- TODO:
		local durationTime = duration
		local layer3dShip = BattleInit3D:getLayerShip3d()
		if not layer3dShip then return end
		layer3dShip:addChild(tiegou1)
		layer3dShip:addChild(tiegou2)
		-- if isActSkill then 
			-- FullScreenEffect.AddObj(tiegou1)
			-- FullScreenEffect.AddObj(tiegou2)
		-- end
		effect_t["tiegou1"] = tiegou1
		effect_t["tiegou2"] = tiegou2
		effect_t["own"] = ship_data
		effect_t["target"] = target
		effect_t["duration"] = 0
		effect_t["startPos_offset"] = startPos_offset
		effect_t["endPos_offset"] = endPos_offset
		effect_t["durationTime"] = durationTime*1000
		effect_t["tick"] = 0
		effect_t["is_first"] = is_first
		effect_t["cb_first"] = cb_first
		effect_t["skill_id"] = skill_id
		effect_t["ext_args"] = ext_args
		
		adjustGouSuoPos(effect_t)
		return effect_t
	end

	local gousuo_cnt = 3
	local heigtToStay = 10
	local gousuo_offset  = 
	{
		{
			src = {0, heigtToStay, -30},
			dst = {0, heigtToStay, 30},
		},
		{
			src = {0, heigtToStay, 0},
			dst = {0, heigtToStay, 0},
		},
		{
			src = {0, heigtToStay, 30},
			dst = {0, heigtToStay, -30},
		},
	}
	local array = CCArray:create()
	for i = 1, gousuo_cnt do	
		local callback =  function()
			local offset = gousuo_offset[i]
			local is_first = false
			local cb_first = nil
			if i == 1 then 
				is_first = true
				cb_first = cb
			end
			local effect_t = createGousou({startPos_offset = offset.src, 
											endPos_offset = offset.dst,
											ship_data = ship_data,
											is_first = is_first,
											cb_first = cb_first,
											skill_id = skill_id,
											ext_args = ext_args
											})
			cls_gousuo_manager.gousuo_effect[#cls_gousuo_manager.gousuo_effect + 1] = effect_t
		end
		local callFunc = CCCallFunc:create(callback)
		array:addObject(callFunc) 
		local delay = CCDelayTime:create(0.4)
		array:addObject(delay)
	end
	display.getRunningScene():runAction(CCSequence:create(array))
end

function cls_gousuo_manager:releaseGouSuo()
	local keys = table.keys(cls_gousuo_manager.gousuo_effect)
	for _, key in pairs(keys) do
		local effect_t = cls_gousuo_manager.gousuo_effect[key]
		clearGouSuo(effect_t)
		cls_gousuo_manager.gousuo_effect[key] = nil
	end
end

return cls_gousuo_manager
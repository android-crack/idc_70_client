--region bullet.lua
--Date
--此文件由[BabeLua]插件自动生成
require("resource_manager")

--跟踪弹
local bullet_info = require("game_config/battle/bullet_info")
local music_info = require("game_config/music_info")
				
local bullet_tab = {}
local bullet_num = 0

local function getBulletCfg(id)
	local cfg = bullet_info[tonumber(id)]
	return cfg
end

local function hideEffects(effects)
	if effects then 
		for i, k in ipairs(effects) do
			k:Stop()
		end
	end
end

-- 获取船舶受击位置：从中心点，头部点，尾部点随机选择
local function getHitedNode(ship, idx)
	local targetNode = ship.body.node
	local leftNode = ship:getHeadNode()
	local rightNode = ship:getTailNode()

	local parentMatrix = targetNode:getWorldMatrix()
	if idx == 1 and leftNode then
		local v = leftNode:getTranslationWorld()
		parentMatrix:transformPoint(v)
		return v
	elseif idx == 2 and rightNode then 
		local v = rightNode:getTranslationWorld()
		parentMatrix:transformPoint(v)
		return v
	else
		local targetTran = targetNode:getTranslationWorld()
		local targetPos = Vector3.new()
		Vector3.add(targetTran, Vector3.new(0, 30, 0), targetPos)
		return targetPos
	end
end

local function getShootPos(ship_data, number, isMulti, bullet_pos_t)
	if isMulti then
		local nodename = bullet_pos_t[number]
		if nodename == "head" and ship_data:getHeadNode() then
			return ship_data:getHeadNode():getTranslation()
		elseif nodename == "tail" and ship_data:getTailNode() then
			return ship_data:getTailNode():getTranslation()
		end
	end
	return ship_data.body:getShootPos()
end

local bullet = class("bullet")

function bullet:ctor(param)
	local battleData = getGameData():getBattleDataMt()
	local attacker = battleData:getShipByGenID(param.attacker_id) 
	local target = battleData:getShipByGenID(param.target_id)
	if not attacker or not target then return end
	if attacker:is_deaded() then return end
	if target:is_deaded() then return end	
	
	self.bullet_id = param.bullet_id
	local cfg = getBulletCfg(self.bullet_id)
	local modelFile = cfg.name
	local fire_effect = cfg.fire_effect
	self.attacker = attacker
	self.targetData= target  
	self.skill_id = param.skill_id
	self.skill_lv = param.skill_lv or 1
	self.info = param.info
	self.isFirst = param.isFirst
	self.speed = param.speed or 0.8
	self.rotate = param.rotate or 0
	self.remain = param.remain or 0
	
	self.isActSkill = param.isActSkill
	self.isActSkillBegin = param.isActSkillBegin
	self.isActSkillEnd = param.isActSkillEnd
	self.isHitedShakeOnce = param.isHitedShakeOnce
	self.number = param.number
	self.isMulti = param.isMulti --是否是多个子弹中的其中一个，用来获取子弹的发射位置
	self.bullet_pos_t = param.bullet_pos_t
	self.callback = param.callback
	self.ext_args = param.ext_args
	self.start_effect = param.start_effect
	self.hit_music = cfg.hited_sound_id
	
	if modelFile and modelFile ~= "" then 
		self.bullet_node = ResourceManager:LoadModel(MODEL_3D_PATH..modelFile.."/"..modelFile..".gpb", modelFile)
	else 
		self.bullet_node = Node.create()
	end 

	local layer3dShip = BattleInit3D:getLayerShip3d()
	layer3dShip:addChild(self.bullet_node)

	local ownNode = attacker.body.node
    local ownPos = ownNode:getTranslation()

	local increment = getShootPos(attacker, self.number, self.isMulti, self.bullet_pos_t)
	local mat = ownNode:getWorldMatrix()
    local blPos = Vector3.new(increment)
	mat:transformPoint(blPos)
	self.bullet_node:setTranslation(blPos)
	
	if fire_effect then
		local file = EFFECT_3D_PATH..fire_effect..MODELPARTICLE_EXT
		if self.effect_control == nil then
			self.effect_control = require( "gameobj/effect/effect" ).new( self.bullet_node );
		end

		if self.effect_control ~= nil then
			self.effect_control:preload( file );
		else
			assert( false, "error: effect controller was empty!!!!" );
		end
		 self.effect_control:showAll()
	end

	self.idx = math.random(1,3)
	self.endPos = getHitedNode(self.targetData, self.idx)
	LookAtPoint(self.bullet_node, self.endPos)
    
	bullet_num = bullet_num + 1
	self.key = bullet_num
    bullet_tab[self.key] = self  
	
	-- [todo]:只对主动技能处理
	if self.isActSkill then 
		local point = self.targetData.body.node:getTranslation()
		local distance = Vector3.new()
		Vector3.subtract(point, ownPos, distance)
		local dst = Vector3.new()
		local dst2 = Vector3.new()
		Vector3.cross(distance , Vector3.new(0,1,0), dst)
		Vector3.add(blPos, dst, dst2)
		attacker.body:_showFireRes(blPos, dst2, self.use_effect) -- 显示施法特效	
	else
		attacker.body:showFireRes()
	end
	
	--TODO:
	if self.skill_id == "sk2" and attacker.body.node:isInFrustum() then -- 普通炮击音效
		local sound_id = cfg.fire_sound_id
		local sound = music_info[sound_id].res
		audioExt.playEffect(sound, false)
	end
end

local function hitTargetCB(bullet)
	local targetData = bullet.targetData
	if not targetData.isDeaded then
		targetData:onBulletHited(bullet.attacker, bullet)
		targetData.body:showEffect("tx_shouji")
		local skill_map = require("game_config/battleSkill/skill_map")
		local battleData = getGameData():getBattleDataMt()
		if bullet.skill_id == "sk2" and battleData:BattleIsRunning() and targetData.body.node:isInFrustum() then -- 普通炮击音效
			local sound_id = bullet.hit_music
			local sound = music_info[sound_id].res
			audioExt.playEffect(sound, false)
		end
		if type(bullet.callback) == "function" then
			bullet.callback(skill_map[bullet.skill_id], bullet.attacker, bullet.targetData, bullet.ext_args, nil, true)
		end
	end
	hideEffects(bullet.effects)
	
	-- 挂在目标点上，延迟释放。
	if bullet.remain > 0 and not targetData.isDeaded then
		local duration = bullet.remain
		local node = bullet.bullet_node
		bullet:release()
		 
		local pos = node:getTranslationWorld()
		local forward = node:getForwardVectorWorld()
		targetData.body.node:addChild(node)
		local tran = WorldPoint2Local(targetData.body.node, pos)
		node:setTranslation(tran)
		LookForward(node, forward)
		
		Model3DFadeOut(node, duration)
		local function callback()
			if not targetData.isDeaded then 
				local parent = node:getParent()
				parent:removeChild(node)
			end 
		end 
		require("framework.scheduler").performWithDelayGlobal(callback, duration)
	else 
		bullet:release()
	end 
end 


function bullet:update(elapsedTime)
    for k, bt in pairs(bullet_tab) do			
        local bullet_node = bt.bullet_node
        if bullet_node then   
			local targetData = bt.targetData
		
			if targetData.isDeaded and targetData.body.shootNode == nil then
				hitTargetCB(bt)
			else	
				local bulletTrans = bullet_node:getTranslation()
				bt.endPos = getHitedNode(bt.targetData, bt.idx)
				local tmpForward = Vector3.new()
				
				if bt.rotate > 0 then 
					local angle = bt.rotate * elapsedTime / 1000
					Vector3.subtract(bt.endPos, bulletTrans, tmpForward)
					bullet_node:rotateY(math.rad(angle))	
				else 
					LookAtPoint(bullet_node, bt.endPos)
					tmpForward = bullet_node:getForwardVectorWorld()	
				end 
				
				local speed = bt.speed
				tmpForward:normalize()
				tmpForward:scale(speed*elapsedTime)
			
				if GetVectorDistance(bulletTrans, bt.endPos) <= tmpForward:length() then
					bullet_node:setTranslation(bt.endPos)
					hitTargetCB(bt)
				else
					bullet_node:translate(tmpForward)
				end
			end
        end
    end	
end

function bullet:release()
	local parent = self.bullet_node:getParent()
	if self.effect_control then
		self.effect_control:release();
		self.effect_control = nil
	end
	parent:removeChild(self.bullet_node)
	bullet_tab[self.key] = nil
	self.attacker = nil
	self.targetData= nil
	self.effects = nil
	self.bullet_node = nil
end

function bullet:releaseAll()
    for k, bt in pairs(bullet_tab) do
		bt:release()
		bullet_tab[k] = nil
	end
	bullet_tab = {}
	bullet_num = 0
end

return bullet

--endregion

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_jet_flame = class("cls_jet_flame", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_jet_flame.get_status_id = function(self)
	return "jet_flame";
end


-- 状态名 
cls_jet_flame.get_status_name = function(self)
	return T("火焰喷射");
end

-- 特效 
cls_jet_flame.get_status_effect = function(self)
	return {"tx_ranshaodan", };
end

-- 特效类型 
cls_jet_flame.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

-- cls_jet_flame.deal_result = function(self, tbResult)
-- 	local ship = self.target

-- 	if not ship or ship:is_deaded() then return end

-- 	local origin = ship.body.node:getTranslation()
-- 	local dir = ship.body.node:getForwardVectorWorld()
-- 	local near_targets = ship:getNearAttackAbleShips(tbResult.Jet_Flame)

-- 	local ray = Ray.new(origin, dir)
-- 	local ret = {}
-- 	for _, v in pairs(near_targets) do
-- 		local boundingBox = v.body.node:getBoundingSphere()
		
-- 		-- local mat = v.body.node:getWorldMatrix()
-- 		-- boundingBox:transform(mat)

-- 		local distance = ray:intersects(boundingBox)

-- 		if distance ~= Ray.INTERSECTS_NONE() then
-- 			ret[#ret + 1] = v
-- 		end
-- 	end

-- 	if #ret == 0 then return end

-- 	local skill_map = require("game_config/battleSkill/skill_map")
-- 	local cls_skill = skill_map[tbResult.Jet_Flame_2]

-- 	local idx = 1
-- 	local lst_buff = cls_skill:get_add_status()

-- 	for idx = 1, #lst_buff do
		
-- 		local buff = lst_buff[idx]

-- 		if buff.scope ~= "LAST_TARGET" then
-- 			for _, target in ipairs(ret) do
-- 				local tbIdx = cls_skill:deal_status(ship, target, idx)
-- 				cls_skill:end_display_call_back(ship, target, tbIdx)
-- 			end
-- 		end
-- 	end
-- end

local jet_flame_ai = "sk_huoyanpenshe"

cls_jet_flame.deal_result = function(self, tbResult)
	local ship_obj = self.target
	-- 修改突击中转向速度
	if not  tbResult.old_turn_speed then
		tbResult.old_turn_speed = ship_obj.body:getShipTurnSpeed()
		ship_obj.body:setShipTurnSpeed(50)
	end
	
	local battle_data = getGameData():getBattleDataMt()

	local ship = self.target

	if not battle_data:isUpdateShip(ship:getId()) then return end

	if not ship or ship:is_deaded() then return end

	if ship:isAutoFighting() then
		ship:tryRunAI(jet_flame_ai, AI_OPPORTUNITY.RUN)
	end

	local origin = ship.body.node:getTranslation()

	local buff_angle = 90 - ship:getAngle()

	local targets = battle_data:enemyInRectangle(tbResult.BossSkill_Length, tbResult.BossSkill_Width, 
		math.rad(buff_angle), origin, ship)

	if #targets == 0 then return end

	local skill_map = require("game_config/battleSkill/skill_map")
	local cls_skill = skill_map[tbResult.BossSkill]

	local idx = 1
	local lst_buff = cls_skill:get_add_status()

	for idx = 1, #lst_buff do
		
		local buff = lst_buff[idx]

		if buff.scope ~= "LAST_TARGET" then
			for _, target in ipairs(targets) do
				cls_skill:end_display_call_back(ship, target, idx)
			end
		end
	end
end

cls_jet_flame.un_deal_result = function(self, tbResult)
	self.target.body:setShipTurnSpeed(tbResult.old_turn_speed)

	local ai_obj = self.target:getAI(jet_flame_ai)
	if ai_obj then
		self.target:completeAI(ai_obj)
		self.target:deleteAI(jet_flame_ai)
	end
end

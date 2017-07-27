----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_tuji_self = class("cls_tuji_self", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_tuji_self.get_status_id = function(self)
	return "tuji_self";
end


-- 状态名 
cls_tuji_self.get_status_name = function(self)
	return T("突击_2");
end

-- 特效 
cls_tuji_self.get_status_effect = function(self)
	return {"zhaozi02", "tx_tuji_line", };
end

-- 特效类型 
cls_tuji_self.get_status_effect_type = function(self)
	return {"composite", "particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

local SK_FOLLOW = "sk_follow_2"

cls_tuji_self.deal_result = function(self, tbResult)
	cls_tuji_self.super.deal_result(self, tbResult)

	local ship_obj = self.target
	if not tbResult.tj_target then
		tbResult.tj_target = ship_obj.tuji_target
		ship_obj.tuji_target = nil
	end

	-- 修改船只速度
	local target_speed = ship_obj:getSpeed()
	local tj_speed = tbResult.tj_speed or (target_speed*10)
	local delta_speed = tj_speed - target_speed

	-- 修改突击中转向速度
	tbResult.old_turn_speed = ship_obj.body:getShipTurnSpeed()
	ship_obj.body:setShipTurnSpeed(270)

	ship_obj.body:setBanTurn(false)
	-- 允许船只转向
	ship_obj.body:setBanRotate(false)

	-- 修改旋转角度
	ship_obj.body:setRotateAngle(0, "tuji_self")

	ship_obj:addSpeed(delta_speed)
	tbResult.mod_speed = delta_speed

	self.target:addAI(SK_FOLLOW, {})
	local ai_obj = self.target:getAI(SK_FOLLOW)

	if tbResult.tj_target then
		ai_obj:setData("__follow_target_id", tbResult.tj_target:getId())
	end

	if self.target.is_ship then
		self.target:getBody():resetPath()
	end

	ai_obj:tryRun(AI_OPPORTUNITY.RUN)
end

cls_tuji_self.un_deal_result = function(self, tbResult)
	self.target.body:setShipTurnSpeed(tbResult.old_turn_speed)

	local delta_speed = tbResult.mod_speed

	self.target:subSpeed(delta_speed)

	local ai_obj = self.target:getAI(SK_FOLLOW)
	if ai_obj then
		self.target:completeAI(ai_obj)
		self.target:deleteAI(SK_FOLLOW)
	end

	if not getGameData():getBattleDataMt():isUpdateShip(self.target:getId()) then return end

	local tj_target = tbResult.tj_target

	if self.attacker.isDeaded or not tj_target or tj_target.isDeaded then return end
	if not self.attacker:canAttack( tj_target ) then return end

	local skill_map = require("game_config/battleSkill/skill_map")
	local skillId = self.tbResult.tj_skill_id
	local cls_skill = skill_map[skillId]
	cls_skill:do_use(self.target.id, tj_target)

	cls_tuji_self.super.un_deal_result(self, self.tbResult)
end

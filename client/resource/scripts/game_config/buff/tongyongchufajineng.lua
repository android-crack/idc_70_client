----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_tongyongchufajineng = class("cls_tongyongchufajineng", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_tongyongchufajineng.get_status_id = function(self)
	return "tongyongchufajineng";
end


-- 状态名 
cls_tongyongchufajineng.get_status_name = function(self)
	return T("通用触发技能");
end

-- 增减益 
cls_tongyongchufajineng.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_tongyongchufajineng.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)

	local skill_map = require("game_config/battleSkill/skill_map")
	local skillId = tbResult.ty_skill_id
	local cls_skill = skill_map[skillId]

	local target = self.attacker:getTarget()
	if tbResult.target_confirm then
		target = getGameData():getBattleDataMt():getShipByGenID(tbResult.target_confirm)
	end

	local ret = cls_skill:do_use(self.attacker:getId(), target)
end
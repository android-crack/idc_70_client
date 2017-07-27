----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_chain_shot_vertigo = class("cls_chain_shot_vertigo", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_chain_shot_vertigo.get_status_id = function(self)
	return "chain_shot_vertigo";
end


-- 状态名 
cls_chain_shot_vertigo.get_status_name = function(self)
	return T("链弹眩晕触发");
end

-- 增减益 
cls_chain_shot_vertigo.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_chain_shot_vertigo.deal_result = function(self)
	local target = self.target

	self.super.deal_result(self, self.tbResult)

	local skill_map = require("game_config/battleSkill/skill_map")
	local skillId = self.tbResult.ld_skill_id
	local cls_skill = skill_map[skillId]
	cls_skill:do_use(self.attacker.id, self.target)
end
----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_huoyandan = class("cls_huoyandan", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_huoyandan.get_status_id = function(self)
	return "huoyandan";
end


-- 状态名 
cls_huoyandan.get_status_name = function(self)
	return T("火焰弹");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_huoyandan.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)

	local skill_map = require("game_config/battleSkill/skill_map")
	local skillId = tbResult.ty_skill_id
	local cls_skill = skill_map[skillId]
	local ret = cls_skill:do_use(self.attacker:getId(), self.target:getId())
end
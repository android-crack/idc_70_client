----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_bubuweiying = class("cls_bubuweiying", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_bubuweiying.get_status_id = function(self)
	return "bubuweiying";
end


-- 状态名 
cls_bubuweiying.get_status_name = function(self)
	return T("步步为营");
end

-- 增减益 
cls_bubuweiying.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
-- tbResult.bbwy_skill_id
cls_bubuweiying.heart_beat = function(self)
	local target = self.target

	self:deal_result(self.tbResult)

	local skill_map = require("game_config/battleSkill/skill_map")
	local skillId = self.tbResult.bbwy_skill_id;
	local cls_skill = skill_map[skillId]
	cls_skill:do_use(target.id, target:getTarget())
end

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_zhangduoshifang = class("cls_zhangduoshifang", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_zhangduoshifang.get_status_id = function(self)
	return "zhangduoshifang";
end


-- 状态名 
cls_zhangduoshifang.get_status_name = function(self)
	return T("掌舵释放");
end

-- 增减益 
cls_zhangduoshifang.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_zhangduoshifang.heart_beat = function(self)
	local target = self.target

	self:deal_result(self.tbResult)

	-- 施放技能sk90004
	local skill_map = require("game_config/battleSkill/skill_map")
	-- sk90004
	local cls_skill = skill_map["sk90004"]
	cls_skill:do_use(target.id, target:getTarget())
end

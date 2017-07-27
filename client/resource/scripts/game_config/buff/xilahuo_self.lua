----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_xilahuo_self = class("cls_xilahuo_self", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_xilahuo_self.get_status_id = function(self)
	return "xilahuo_self";
end


-- 状态名 
cls_xilahuo_self.get_status_name = function(self)
	return T("希腊火_2");
end

-- 增减益 
cls_xilahuo_self.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_xilahuo_self.get_status_effect = function(self)
	return {"tx_0152", };
end

-- 特效类型 
cls_xilahuo_self.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
cls_xilahuo_self.heart_beat = function(self)
	local target = self.target

	local skill_map = require("game_config/battleSkill/skill_map")
	local cls_skill = skill_map[self.tbResult.tj_skill_id]
	cls_skill:do_use(target.id, target:getTarget())
end

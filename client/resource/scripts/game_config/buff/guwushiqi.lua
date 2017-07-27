----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_guwushiqi = class("cls_guwushiqi", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_guwushiqi.get_status_id = function(self)
	return "guwushiqi";
end


-- 状态名 
cls_guwushiqi.get_status_name = function(self)
	return T("鼓舞士气");
end

-- 增减益 
cls_guwushiqi.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
--
cls_guwushiqi.heart_beat = function(self)
	local target = self.target

	self:deal_result(self.tbResult)

	local skill_map = require("game_config/battleSkill/skill_map")
	local skillId = self.tbResult.gwsq_skill_id;
	local cls_skill = skill_map[skillId]
	cls_skill:do_use(target.id, target:getTarget())
end

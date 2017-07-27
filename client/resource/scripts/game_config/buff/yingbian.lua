----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_yingbian = class("cls_yingbian", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_yingbian.get_status_id = function(self)
	return "yingbian";
end


-- 状态名 
cls_yingbian.get_status_name = function(self)
	return T("应变");
end

-- 增减益 
cls_yingbian.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_yingbian.affect_buff = function(self, targetBuff, tbResult)
	local target = self.target
	local selfTbResult = self.tbResult

	-- 普通攻击时，5%机率触发加防御30%
	if ( math.random(1000) > selfTbResult.yb_rate ) then return tbResult end

	-- 加防
	-- sk90001
	local skill_map = require("game_config/battleSkill/skill_map")
	local cls_skill = skill_map["sk90001"]
	cls_skill:do_use(target.id, target:getTarget())
	return tbResult
end

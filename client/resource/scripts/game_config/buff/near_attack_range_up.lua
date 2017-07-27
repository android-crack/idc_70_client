----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_near_attack_range_up = class("cls_near_attack_range_up", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_near_attack_range_up.get_status_id = function(self)
	return "near_attack_range_up";
end


-- 状态名 
cls_near_attack_range_up.get_status_name = function(self)
	return T("近战攻击距离提升");
end

-- 增减益 
cls_near_attack_range_up.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_sub_hp_3 = class("cls_sub_hp_3", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_sub_hp_3.get_status_id = function(self)
	return "sub_hp_3";
end


-- 状态名 
cls_sub_hp_3.get_status_name = function(self)
	return T("扣血_3");
end

-- 增减益 
cls_sub_hp_3.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_unspeedable = class("cls_unspeedable", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_unspeedable.get_status_id = function(self)
	return "unspeedable";
end


-- 状态名 
cls_unspeedable.get_status_name = function(self)
	return T("免疫速度改变");
end

-- 增减益 
cls_unspeedable.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

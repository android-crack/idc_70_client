----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff/buff_base")

cls_empty = class("cls_empty", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_empty.get_status_id = function(self)
	return "empty";
end


-- 状态名 
cls_empty.get_status_name = function(self)
	return T("空状态");
end


-- 增减益 
cls_empty.get_status_type = function(self)
	return T("增益");
end


---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

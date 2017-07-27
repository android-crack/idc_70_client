----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_fenshen_2 = class("cls_fenshen_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_fenshen_2.get_status_id = function(self)
	return "fenshen_2";
end


-- 状态名 
cls_fenshen_2.get_status_name = function(self)
	return T("分身_2");
end

-- 增减益 
cls_fenshen_2.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
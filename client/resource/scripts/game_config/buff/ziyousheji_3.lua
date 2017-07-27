----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_ziyousheji_3 = class("cls_ziyousheji_3", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_ziyousheji_3.get_status_id = function(self)
	return "ziyousheji_3";
end


-- 状态名 
cls_ziyousheji_3.get_status_name = function(self)
	return T("自由射击_3");
end

-- 增减益 
cls_ziyousheji_3.get_status_type = function(self)
	return T("增益");
end

-- 描述 
cls_ziyousheji_3.get_status_desc = function(self)
	return T("关系表尚未配置");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
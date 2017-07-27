----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_ziyoushejijiansu = class("cls_ziyoushejijiansu", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_ziyoushejijiansu.get_status_id = function(self)
	return "ziyoushejijiansu";
end


-- 状态名 
cls_ziyoushejijiansu.get_status_name = function(self)
	return T("自由射击减速");
end

-- 描述 
cls_ziyoushejijiansu.get_status_desc = function(self)
	return T("关系表尚未配置");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
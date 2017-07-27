----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_fengxingjian = class("cls_fengxingjian", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_fengxingjian.get_status_id = function(self)
	return "fengxingjian";
end


-- 状态名 
cls_fengxingjian.get_status_name = function(self)
	return T("风行舰");
end

-- 增减益 
cls_fengxingjian.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_jianrupanshi = class("cls_jianrupanshi", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_jianrupanshi.get_status_id = function(self)
	return "jianrupanshi";
end


-- 状态名 
cls_jianrupanshi.get_status_name = function(self)
	return T("坚如磐石");
end

-- 增减益 
cls_jianrupanshi.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_unmovable = class("cls_unmovable", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_unmovable.get_status_id = function(self)
	return "unmovable";
end


-- 状态名 
cls_unmovable.get_status_name = function(self)
	return T("免疫移动");
end

-- 增减益 
cls_unmovable.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

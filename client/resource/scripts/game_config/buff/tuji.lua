----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_tuji = class("cls_tuji", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_tuji.get_status_id = function(self)
	return "tuji";
end


-- 状态名 
cls_tuji.get_status_name = function(self)
	return T("突击");
end

-- 增减益 
cls_tuji.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"yinshen", "wudi", }

cls_tuji.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

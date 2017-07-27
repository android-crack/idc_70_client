----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_gousuo = class("cls_gousuo", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_gousuo.get_status_id = function(self)
	return "gousuo";
end


-- 状态名 
cls_gousuo.get_status_name = function(self)
	return T("钩锁");
end

-- 增减益 
cls_gousuo.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"yinshen", "wudi", }

cls_gousuo.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_jian_nu = class("cls_jian_nu", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_jian_nu.get_status_id = function(self)
	return "jian_nu";
end


-- 状态名 
cls_jian_nu.get_status_name = function(self)
	return T("减怒");
end

-- 增减益 
cls_jian_nu.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"kuangnu", "clear_debuff", "wudi", }

cls_jian_nu.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

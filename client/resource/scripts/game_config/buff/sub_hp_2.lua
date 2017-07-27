----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_sub_hp_2 = class("cls_sub_hp_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_sub_hp_2.get_status_id = function(self)
	return "sub_hp_2";
end


-- 状态名 
cls_sub_hp_2.get_status_name = function(self)
	return T("扣血_2");
end

-- 增减益 
cls_sub_hp_2.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"wudi", }

cls_sub_hp_2.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"sub_hp", }

cls_sub_hp_2.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
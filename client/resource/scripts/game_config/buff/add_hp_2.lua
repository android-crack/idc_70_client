----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_add_hp_2 = class("cls_add_hp_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_add_hp_2.get_status_id = function(self)
	return "add_hp_2";
end


-- 状态名 
cls_add_hp_2.get_status_name = function(self)
	return T("加血_2");
end

-- 增减益 
cls_add_hp_2.get_status_type = function(self)
	return T("增益");
end

-- 数值影响(被攻击方) 
local affect_effect_statusT = {"add_heal", }

cls_add_hp_2.get_affect_effect_statusT = function(self)
	return affect_effect_statusT
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"add_hp_3", "never_heal", }

cls_add_hp_2.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------
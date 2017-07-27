----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_attack = class("cls_attack", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_attack.get_status_id = function(self)
	return "attack";
end


-- 状态名 
cls_attack.get_status_name = function(self)
	return T("攻击");
end

-- 增减益 
cls_attack.get_status_type = function(self)
	return T("减益");
end

-- 数值影响(被攻击方) 
local affect_effect_statusT = {"miss", "fantan", "nufachongguan", "yingbian", "yangfanqihang", "jiebei", }

cls_attack.get_affect_effect_statusT = function(self)
	return affect_effect_statusT
end

-- 数值影响(攻击方) 
local affect_effect_statusA = {"xushidaifa", "dongxiruodian", }

cls_attack.get_affect_effect_statusA = function(self)
	return affect_effect_statusA
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"yinshen", "wudi", }

cls_attack.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

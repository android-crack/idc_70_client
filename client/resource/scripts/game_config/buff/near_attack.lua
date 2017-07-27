----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_near_attack = class("cls_near_attack", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_near_attack.get_status_id = function(self)
	return "near_attack";
end


-- 状态名 
cls_near_attack.get_status_name = function(self)
	return T("近战攻击");
end

-- 增减益 
cls_near_attack.get_status_type = function(self)
	return T("减益");
end

-- 数值影响(被攻击方) 
local affect_effect_statusT = {"miss", "fantan", "nufachongguan", "yingbian", "yangfanqihang", "jiebei", "beattack_heal", "shoupugongshanbi", }

cls_near_attack.get_affect_effect_statusT = function(self)
	return affect_effect_statusT
end

-- 数值影响(攻击方) 
local affect_effect_statusA = {"xushidaifa", "dongxiruodian", "fennu", "kuaisuzhuangtian", "fennu", "jinpugongxixue", "ziyousheji_2", "ziyousheji_3", "ziyousheji_4", "putonggongjitishen", "putonggongjitishen_ywwq", }

cls_near_attack.get_affect_effect_statusA = function(self)
	return affect_effect_statusA
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"yinshen", "wudi", }

cls_near_attack.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

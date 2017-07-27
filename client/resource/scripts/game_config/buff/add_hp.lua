----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_add_hp = class("cls_add_hp", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_add_hp.get_status_id = function(self)
	return "add_hp";
end


-- 状态名 
cls_add_hp.get_status_name = function(self)
	return T("加血");
end

-- 增减益 
cls_add_hp.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_add_hp.get_status_effect = function(self)
	return {"jn_jiagu_health", };
end

-- 特效类型 
cls_add_hp.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 数值影响(被攻击方) 
local affect_effect_statusT = {"add_heal", }

cls_add_hp.get_affect_effect_statusT = function(self)
	return affect_effect_statusT
end

-- 状态图标 
cls_add_hp.get_status_icon = function(self)
	return "zhiliao.png";
end


---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"never_heal", }

cls_add_hp.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

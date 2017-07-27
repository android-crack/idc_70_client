----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_never_heal = class("cls_never_heal", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_never_heal.get_status_id = function(self)
	return "never_heal";
end


-- 状态名 
cls_never_heal.get_status_name = function(self)
	return T("无法治疗");
end

-- 增减益 
cls_never_heal.get_status_type = function(self)
	return T("减益");
end

-- 特效 
cls_never_heal.get_status_effect = function(self)
	return {"tx_zhaohuo_3", };
end

-- 特效类型 
cls_never_heal.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态图标 
cls_never_heal.get_status_icon = function(self)
	return "jinliao.png";
end


-- 状态提示 
cls_never_heal.get_status_prompt = function(self)
	return T("禁疗");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"add_hp_3", "wudi", }

cls_never_heal.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"add_hp", "add_hp_2", "add_hp_4", }

cls_never_heal.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------

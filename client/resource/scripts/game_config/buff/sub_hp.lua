----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_sub_hp = class("cls_sub_hp", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_sub_hp.get_status_id = function(self)
	return "sub_hp";
end


-- 状态名 
cls_sub_hp.get_status_name = function(self)
	return T("扣血");
end

-- 增减益 
cls_sub_hp.get_status_type = function(self)
	return T("减益");
end

-- 特效 
cls_sub_hp.get_status_effect = function(self)
	return {"tx_qihuo", };
end

-- 特效类型 
cls_sub_hp.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"wudi", }

cls_sub_hp.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"sub_hp_2", }

cls_sub_hp.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
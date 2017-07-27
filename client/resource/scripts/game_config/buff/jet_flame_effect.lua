----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_jet_flame_effect = class("cls_jet_flame_effect", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_jet_flame_effect.get_status_id = function(self)
	return "jet_flame_effect";
end


-- 状态名 
cls_jet_flame_effect.get_status_name = function(self)
	return T("火焰喷射特效");
end

-- 特效 
cls_jet_flame_effect.get_status_effect = function(self)
	return {"tx_zhaohuo_3", };
end

-- 特效类型 
cls_jet_flame_effect.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
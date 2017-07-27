----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_wudi_2 = class("cls_wudi_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_wudi_2.get_status_id = function(self)
	return "wudi_2";
end


-- 状态名 
cls_wudi_2.get_status_name = function(self)
	return T("无敌_2");
end

-- 增减益 
cls_wudi_2.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_wudi_2.get_status_effect = function(self)
	return {"tx_0117", };
end

-- 特效类型 
cls_wudi_2.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
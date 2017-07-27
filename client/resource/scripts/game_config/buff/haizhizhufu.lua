----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_haizhizhufu = class("cls_haizhizhufu", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_haizhizhufu.get_status_id = function(self)
	return "haizhizhufu";
end


-- 状态名 
cls_haizhizhufu.get_status_name = function(self)
	return T("海之祝福");
end

-- 增减益 
cls_haizhizhufu.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_haizhizhufu.get_status_effect = function(self)
	return {"tx_haizizhufu", };
end

-- 特效类型 
cls_haizhizhufu.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
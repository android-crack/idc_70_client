----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_paodan2 = class("cls_paodan2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_paodan2.get_status_id = function(self)
	return "paodan2";
end


-- 状态名 
cls_paodan2.get_status_name = function(self)
	return T("炮弹2");
end

-- 增减益 
cls_paodan2.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_paodan2.get_status_effect = function(self)
	return {"tx_paodan_middle", };
end

-- 特效类型 
cls_paodan2.get_status_effect_type = function(self)
	return {"particle_scene", };
end

-- 状态图标 
cls_paodan2.get_status_icon = function(self)
	return "jiasu.png";
end


---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

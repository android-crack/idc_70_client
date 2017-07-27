----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_pojia = class("cls_pojia", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_pojia.get_status_id = function(self)
	return "pojia";
end


-- 状态名 
cls_pojia.get_status_name = function(self)
	return T("破甲");
end

-- 增减益 
cls_pojia.get_status_type = function(self)
	return T("减益");
end

-- 特效 
cls_pojia.get_status_effect = function(self)
	return {"tx_skill_shielddown", };
end

-- 特效类型 
cls_pojia.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态图标 
cls_pojia.get_status_icon = function(self)
	return "jiasu.png";
end


---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"clear_debuff", "wudi", }

cls_pojia.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

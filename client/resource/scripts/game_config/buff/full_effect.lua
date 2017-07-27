----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_full_effect = class("cls_full_effect", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_full_effect.get_status_id = function(self)
	return "full_effect";
end


-- 状态名 
cls_full_effect.get_status_name = function(self)
	return T("全屏特效");
end


-- 特效 
cls_full_effect.get_status_effect = function(self)
	return "tx_sunshine";
end


-- 特效类型 
cls_full_effect.get_status_effect_type = function(self)
	return "particle";
end


---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

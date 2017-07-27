----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_fanji_tips = class("cls_fanji_tips", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_fanji_tips.get_status_id = function(self)
	return "fanji_tips";
end


-- 特效 
cls_fanji_tips.get_status_effect = function(self)
	return {"jn_xuli", };
end

-- 特效类型 
cls_fanji_tips.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态提示 
cls_fanji_tips.get_status_prompt = function(self)
	return T("反击");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
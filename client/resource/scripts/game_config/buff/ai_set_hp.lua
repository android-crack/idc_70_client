----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_ai_set_hp = class("cls_ai_set_hp", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_ai_set_hp.get_status_id = function(self)
	return "ai_set_hp";
end


-- 状态名 
cls_ai_set_hp.get_status_name = function(self)
	return T("设置气血");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
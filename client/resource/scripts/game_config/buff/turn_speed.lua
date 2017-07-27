----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_turn_speed = class("cls_turn_speed", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_turn_speed.get_status_id = function(self)
	return "turn_speed";
end


-- 状态名 
cls_turn_speed.get_status_name = function(self)
	return T("转弯角度");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
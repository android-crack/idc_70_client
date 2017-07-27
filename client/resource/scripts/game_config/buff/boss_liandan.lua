----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_boss_liandan = class("cls_boss_liandan", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_boss_liandan.get_status_id = function(self)
	return "boss_liandan";
end


-- 状态名 
cls_boss_liandan.get_status_name = function(self)
	return T("BOSS链弹");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
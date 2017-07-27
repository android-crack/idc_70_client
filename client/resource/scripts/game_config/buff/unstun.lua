----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_unstun = class("cls_unstun", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_unstun.get_status_id = function(self)
	return "unstun";
end


-- 状态名 
cls_unstun.get_status_name = function(self)
	return T("免疫眩晕");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"stun", }

cls_unstun.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
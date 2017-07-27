----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_xuelianggongxiang = class("cls_xuelianggongxiang", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_xuelianggongxiang.get_status_id = function(self)
	return "xuelianggongxiang";
end


-- 状态名 
cls_xuelianggongxiang.get_status_name = function(self)
	return T("血量共享");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
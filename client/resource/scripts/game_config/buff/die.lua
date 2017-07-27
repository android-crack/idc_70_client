----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_die = class("cls_die", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_die.get_status_id = function(self)
	return "die";
end


-- 状态名 
cls_die.get_status_name = function(self)
	return T("死亡");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"wudi", }

cls_die.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_jinpugongxixue = class("cls_jinpugongxixue", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_jinpugongxixue.get_status_id = function(self)
	return "jinpugongxixue";
end


-- 状态名 
cls_jinpugongxixue.get_status_name = function(self)
	return T("近普攻吸血");
end

-- 增减益 
cls_jinpugongxixue.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
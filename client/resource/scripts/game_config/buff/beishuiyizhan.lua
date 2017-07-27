----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_beishuiyizhan = class("cls_beishuiyizhan", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_beishuiyizhan.get_status_id = function(self)
	return "beishuiyizhan";
end


-- 状态名 
cls_beishuiyizhan.get_status_name = function(self)
	return T("背水一战");
end

-- 增减益 
cls_beishuiyizhan.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

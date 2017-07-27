----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_putonggongjitishen = class("cls_putonggongjitishen", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_putonggongjitishen.get_status_id = function(self)
	return "putonggongjitishen";
end


-- 状态名 
cls_putonggongjitishen.get_status_name = function(self)
	return T("普通攻击提升");
end

-- 增减益 
cls_putonggongjitishen.get_status_type = function(self)
	return T("增益");
end

-- 描述 
cls_putonggongjitishen.get_status_desc = function(self)
	return T("关系表尚未配置");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
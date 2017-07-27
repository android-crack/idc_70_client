----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_putonggongjitishen_ywwq = class("cls_putonggongjitishen_ywwq", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_putonggongjitishen_ywwq.get_status_id = function(self)
	return "putonggongjitishen_ywwq";
end


-- 状态名 
cls_putonggongjitishen_ywwq.get_status_name = function(self)
	return T("普通攻击提升_一往无前");
end

-- 增减益 
cls_putonggongjitishen_ywwq.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"add_att_far_2", "add_att_near_2", "fennu", }

cls_putonggongjitishen_ywwq.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
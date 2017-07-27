----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_mianyikongzhi = class("cls_mianyikongzhi", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_mianyikongzhi.get_status_id = function(self)
	return "mianyikongzhi";
end


-- 状态名 
cls_mianyikongzhi.get_status_name = function(self)
	return T("免疫控制");
end

-- 增减益 
cls_mianyikongzhi.get_status_type = function(self)
	return T("增益");
end

-- 状态提示 
cls_mianyikongzhi.get_status_prompt = function(self)
	return T("免疫控制");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"faint", "slow", "slow_2", "chaofeng", "slow_3", "stun", }

cls_mianyikongzhi.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
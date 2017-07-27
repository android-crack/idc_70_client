----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_clear_buff = class("cls_clear_buff", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_clear_buff.get_status_id = function(self)
	return "clear_buff";
end


-- 状态名 
cls_clear_buff.get_status_name = function(self)
	return T("清除增益状态");
end

-- 增减益 
cls_clear_buff.get_status_type = function(self)
	return T("减益");
end

-- 状态提示 
cls_clear_buff.get_status_prompt = function(self)
	return T("清除增益");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"add_def", "add_hp", "add_hp_3", "miss", "fast", "fantan", "add_att_far", "add_att_near", "jia_nu", "dodge", }

cls_clear_buff.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
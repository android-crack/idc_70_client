----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_far_attack_select_cnt_add_2 = class("cls_far_attack_select_cnt_add_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_far_attack_select_cnt_add_2.get_status_id = function(self)
	return "far_attack_select_cnt_add_2";
end


-- 状态名 
cls_far_attack_select_cnt_add_2.get_status_name = function(self)
	return T("远程攻击多目标_2");
end

-- 增减益 
cls_far_attack_select_cnt_add_2.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
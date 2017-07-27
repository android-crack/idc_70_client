----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_clear_debuff = class("cls_clear_debuff", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_clear_debuff.get_status_id = function(self)
	return "clear_debuff";
end


-- 状态名 
cls_clear_debuff.get_status_name = function(self)
	return T("清除减益状态");
end

-- 增减益 
cls_clear_debuff.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_clear_debuff.get_status_effect = function(self)
	return {"tx_0165", };
end

-- 特效类型 
cls_clear_debuff.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态提示 
cls_clear_debuff.get_status_prompt = function(self)
	return T("净化");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"sub_def", "faint", "seal", "sub_hp", "slow", "slow_2", "sub_att_far", "sub_att_near", "jian_nu", "pojia", "kongzhi", "chaofeng", "never_heal", "sub_hp_2", "silence", "dis_turn", "stun", "jet_flame_effect", }

cls_clear_debuff.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------

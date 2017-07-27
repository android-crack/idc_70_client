----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_wudi = class("cls_wudi", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_wudi.get_status_id = function(self)
	return "wudi";
end


-- 状态名 
cls_wudi.get_status_name = function(self)
	return T("无敌");
end

-- 增减益 
cls_wudi.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_wudi.get_status_effect = function(self)
	return {"tx_0117", };
end

-- 特效类型 
cls_wudi.get_status_effect_type = function(self)
	return {"liuguang", };
end

-- 状态提示 
cls_wudi.get_status_prompt = function(self)
	return T("无敌");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"sub_def", "faint", "seal", "sub_hp", "slow", "slow_2", "sub_att_far", "sub_att_near", "jian_nu", "pojia", "kongzhi", "chaofeng", "never_heal", "sub_hp_2", "silence", "dis_turn", "stun", "jet_flame_effect", }

cls_wudi.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
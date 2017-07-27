----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_zhihuiqi_effect = class("cls_zhihuiqi_effect", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_zhihuiqi_effect.get_status_id = function(self)
	return "zhihuiqi_effect";
end


-- 状态名 
cls_zhihuiqi_effect.get_status_name = function(self)
	return T("指挥旗特效");
end

-- 特效 
cls_zhihuiqi_effect.get_status_effect = function(self)
	return {"tx_attack_up", "tx_attack_up", };
end

-- 特效类型 
cls_zhihuiqi_effect.get_status_effect_type = function(self)
	return {"particle_local", "liuguang", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
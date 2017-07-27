----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_cut_effect = class("cls_cut_effect", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_cut_effect.get_status_id = function(self)
	return "cut_effect";
end


-- 状态名 
cls_cut_effect.get_status_name = function(self)
	return T("刀砍特效");
end

-- 特效 
cls_cut_effect.get_status_effect = function(self)
	return {"tx_jinzhandao", };
end

-- 特效类型 
cls_cut_effect.get_status_effect_type = function(self)
	return {"particle_share", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_cut_effect.deal_result = function(self, tbResult)
	self.target.body:playAnimation("shake", true)
	
end

cls_cut_effect.un_deal_result = function(self, tbResult)
	self.target.body:playAnimation("move", true)
end
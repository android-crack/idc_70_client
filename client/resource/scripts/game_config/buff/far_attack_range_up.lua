----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_far_attack_range_up = class("cls_far_attack_range_up", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_far_attack_range_up.get_status_id = function(self)
	return "far_attack_range_up";
end


-- 状态名 
cls_far_attack_range_up.get_status_name = function(self)
	return T("远程攻击距离提升");
end

-- 增减益 
cls_far_attack_range_up.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_far_attack_range_up.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.add_far_att_range then 
		self.target:setFarAttFange(self.target:getFarRange() + tbResult.add_far_att_range)
	end
end

cls_far_attack_range_up.un_deal_result = function(self, tbResult)
	if tbResult.add_far_att_range then 
		self.target:setFarAttFange(self.target:getFarRange() - tbResult.add_far_att_range)
	end
	self.super.un_deal_result(self, tbResult)
end
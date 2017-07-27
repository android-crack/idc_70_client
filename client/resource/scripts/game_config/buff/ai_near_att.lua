----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_ai_near_att = class("cls_ai_near_att", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_ai_near_att.get_status_id = function(self)
	return "ai_near_att";
end


-- 状态名 
cls_ai_near_att.get_status_name = function(self)
	return T("近攻修正");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"ai_near_att", }

cls_ai_near_att.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
--
cls_ai_near_att.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.mod_value then 
		self.target:addAttNear(tbResult.mod_value)
	end
end


cls_ai_near_att.un_deal_result = function(self, tbResult)
	if tbResult.mod_value then 
		self.target:subAttNear(tbResult.mod_value)
	end
	self.super.un_deal_result(self, tbResult)
end



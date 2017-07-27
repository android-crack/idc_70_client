----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_ai_speed = class("cls_ai_speed", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_ai_speed.get_status_id = function(self)
	return "ai_speed";
end


-- 状态名 
cls_ai_speed.get_status_name = function(self)
	return T("速度修正");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"ai_speed", }

cls_ai_speed.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
cls_ai_speed.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.mod_value then 
		self.target:addSpeed(tbResult.mod_value)
	end
end


cls_ai_speed.un_deal_result = function(self, tbResult)
	if tbResult.mod_value then 
		self.target:subSpeed(tbResult.mod_value)
	end
	self.super.un_deal_result(self, tbResult)
end



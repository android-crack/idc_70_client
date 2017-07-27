----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_ai_defense = class("cls_ai_defense", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_ai_defense.get_status_id = function(self)
	return "ai_defense";
end


-- 状态名 
cls_ai_defense.get_status_name = function(self)
	return T("防御修正");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"ai_defense", }

cls_ai_defense.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
cls_ai_defense.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.mod_value then 
		self.target:addDefense(tbResult.mod_value)
	end
end


cls_ai_defense.un_deal_result = function(self, tbResult)
	if tbResult.mod_value then 
		self.target:subDefense(tbResult.mod_value)
	end
	self.super.un_deal_result(self, tbResult)
end



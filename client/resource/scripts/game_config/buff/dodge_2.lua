----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_dodge_2 = class("cls_dodge_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_dodge_2.get_status_id = function(self)
	return "dodge_2";
end


-- 状态名 
cls_dodge_2.get_status_name = function(self)
	return T("闪避_2");
end

-- 增减益 
cls_dodge_2.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_dodge_2.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.dodge then 
		self.target:addDodge(tbResult.dodge)
	end
end

cls_dodge_2.un_deal_result = function(self, tbResult)
	if tbResult.dodge then 
		self.target:addDodge(-tbResult.dodge)
	end
	self.super.un_deal_result(self, tbResult)
end
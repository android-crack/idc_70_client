----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_baoji_3 = class("cls_baoji_3", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_baoji_3.get_status_id = function(self)
	return "baoji_3";
end


-- 状态名 
cls_baoji_3.get_status_name = function(self)
	return T("暴击_3");
end

-- 增减益 
cls_baoji_3.get_status_type = function(self)
	return T("增益");
end

-- 状态图标 
cls_baoji_3.get_status_icon = function(self)
	return "jiagong.png";
end


-- 状态提示 
cls_baoji_3.get_status_prompt = function(self)
	return T("暴击提升");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"baoji_2", }

cls_baoji_3.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------

cls_baoji_3.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.custom_baoji_rate then 
		self.target:setCritRate(self.target:getCritRate() + tbResult.custom_baoji_rate)
	end
end

cls_baoji_3.un_deal_result = function(self, tbResult)
	if tbResult.custom_baoji_rate then 
		self.target:setCritRate(self.target:getCritRate() - tbResult.custom_baoji_rate)
	end
	self.super.un_deal_result(self, tbResult)
end
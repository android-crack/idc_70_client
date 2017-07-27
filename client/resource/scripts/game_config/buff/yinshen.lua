----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_yinshen = class("cls_yinshen", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_yinshen.get_status_id = function(self)
	return "yinshen";
end


-- 状态名 
cls_yinshen.get_status_name = function(self)
	return T("隐身");
end

-- 增减益 
cls_yinshen.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_yinshen.get_status_effect = function(self)
	return {"texture_flow2", };
end

-- 特效类型 
cls_yinshen.get_status_effect_type = function(self)
	return {"liuguang", };
end

-- 状态提示 
cls_yinshen.get_status_prompt = function(self)
	return T("隐身");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"sub_def", "faint", "seal", "sub_hp", "slow", "slow_2", "gousuo", "sub_hp_2", "slow_3", }

cls_yinshen.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
cls_yinshen.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	self.target:setHide(true)
end

cls_yinshen.un_deal_result = function(self, tbResult)
	self.target:setHide(false)
	self.super.un_deal_result(self, tbResult)
end
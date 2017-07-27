----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_seal = class("cls_seal", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_seal.get_status_id = function(self)
	return "seal";
end


-- 状态名 
cls_seal.get_status_name = function(self)
	return T("冰冻");
end

-- 增减益 
cls_seal.get_status_type = function(self)
	return T("减益");
end

-- 特效 
cls_seal.get_status_effect = function(self)
	return {"texture_flow3", };
end

-- 特效类型 
cls_seal.get_status_effect_type = function(self)
	return {"liuguang", };
end

-- 状态图标 
cls_seal.get_status_icon = function(self)
	return "xuruo.png";
end


---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"wudi", }

cls_seal.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------
cls_seal.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.sub_speed then 
		self.target:sub_speed(tbResult.sub_speed)
	end
end

cls_seal.un_deal_result = function(self, tbResult)
	self.super.un_deal_result(self, tbResult)
	if tbResult.sub_speed then 
		self.target:add_speed(tbResult.sub_speed)
	end
end
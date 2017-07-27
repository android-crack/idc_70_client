----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_dodge = class("cls_dodge", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_dodge.get_status_id = function(self)
	return "dodge";
end


-- 状态名 
cls_dodge.get_status_name = function(self)
	return T("闪避");
end

-- 增减益 
cls_dodge.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_dodge.get_status_effect = function(self)
	return {"tx_0167", };
end

-- 特效类型 
cls_dodge.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态图标 
cls_dodge.get_status_icon = function(self)
	return "jiafang.png";
end


-- 状态提示 
cls_dodge.get_status_prompt = function(self)
	return T("闪避提升");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"dodge_3", }

cls_dodge.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------

cls_dodge.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.dodge then 
		self.target:addDodge(tbResult.dodge)
	end
end

cls_dodge.un_deal_result = function(self, tbResult)
	if tbResult.dodge then 
		self.target:addDodge(-tbResult.dodge)
	end
	self.super.un_deal_result(self, tbResult)
end

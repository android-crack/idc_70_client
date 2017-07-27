----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_add_def = class("cls_add_def", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_add_def.get_status_id = function(self)
	return "add_def";
end


-- 状态名 
cls_add_def.get_status_name = function(self)
	return T("加防");
end

-- 增减益 
cls_add_def.get_status_type = function(self)
	return T("增益");
end

-- 描述 
cls_add_def.get_status_desc = function(self)
	return T("略");
end

-- 特效 
cls_add_def.get_status_effect = function(self)
	return {"zhaozi", };
end

-- 特效类型 
cls_add_def.get_status_effect_type = function(self)
	return {"composite", };
end

-- 状态图标 
cls_add_def.get_status_icon = function(self)
	return "jiafang.png";
end


-- 状态提示 
cls_add_def.get_status_prompt = function(self)
	return T("加防");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"sub_def", }

cls_add_def.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------

cls_add_def.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.add_defend then 
		self.target:addDefense(tbResult.add_defend)
	end
end

cls_add_def.un_deal_result = function(self, tbResult)
	self.super.un_deal_result(self, tbResult)
	
	if tbResult.add_defend then 
		self.target:addDefense(-tbResult.add_defend)	
	end
end

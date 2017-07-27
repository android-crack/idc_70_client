----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_fast_3 = class("cls_fast_3", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_fast_3.get_status_id = function(self)
	return "fast_3";
end


-- 状态名 
cls_fast_3.get_status_name = function(self)
	return T("加速_3");
end

-- 增减益 
cls_fast_3.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_fast_3.get_status_effect = function(self)
	return {"tx_speedup", };
end

-- 特效类型 
cls_fast_3.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态图标 
cls_fast_3.get_status_icon = function(self)
	return "jiasu.png";
end


-- 状态提示 
cls_fast_3.get_status_prompt = function(self)
	return T("加速");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"unmovable", "unspeedable", "slow_3", }

cls_fast_3.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"slow", "fast", "tuji", }

cls_fast_3.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------

cls_fast_3.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.add_speed then 
		self.target:add_speed(tbResult.add_speed)
	end
end

cls_fast_3.un_deal_result = function(self, tbResult)
	self.super.un_deal_result(self, tbResult)
	
	if tbResult.add_speed then 
		self.target:add_speed(-tbResult.add_speed)	
	end
end
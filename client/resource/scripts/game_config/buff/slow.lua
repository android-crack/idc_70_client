----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_slow = class("cls_slow", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_slow.get_status_id = function(self)
	return "slow";
end


-- 状态名 
cls_slow.get_status_name = function(self)
	return T("减速");
end

-- 增减益 
cls_slow.get_status_type = function(self)
	return T("减益");
end

-- 状态图标 
cls_slow.get_status_icon = function(self)
	return "jiansu.png";
end


-- 状态提示 
cls_slow.get_status_prompt = function(self)
	return T("减速");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"fengxingjian", "clear_debuff", "wudi", "mianyikongzhi", }

cls_slow.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"fast", "fast_3", "tuji", }

cls_slow.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
cls_slow.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.sub_speed then 
		self.target:sub_speed(tbResult.sub_speed)
	end
end

cls_slow.un_deal_result = function(self, tbResult)
	self.super.un_deal_result(self, tbResult)
	
	if tbResult.sub_speed then 
		self.target:add_speed(tbResult.sub_speed)	
	end
end
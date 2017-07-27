----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_sub_att_near = class("cls_sub_att_near", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_sub_att_near.get_status_id = function(self)
	return "sub_att_near";
end


-- 状态名 
cls_sub_att_near.get_status_name = function(self)
	return T("减近攻");
end

-- 增减益 
cls_sub_att_near.get_status_type = function(self)
	return T("减益");
end

-- 状态图标 
cls_sub_att_near.get_status_icon = function(self)
	return "jiangong.png";
end


-- 状态提示 
cls_sub_att_near.get_status_prompt = function(self)
	return T("降攻");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"ziyousheji", "clear_debuff", "wudi", }

cls_sub_att_near.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"add_att_near", }

cls_sub_att_near.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
cls_sub_att_near.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.sub_att_near then 
		self.target:subAttNear(tbResult.sub_att_near)
	end
end

cls_sub_att_near.un_deal_result = function(self, tbResult)
	if tbResult.sub_att_near then 
		self.target:subAttNear(-tbResult.sub_att_near)
	end
	self.super.un_deal_result(self, tbResult)
end

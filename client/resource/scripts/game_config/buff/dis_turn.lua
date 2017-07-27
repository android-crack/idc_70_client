----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_dis_turn = class("cls_dis_turn", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_dis_turn.get_status_id = function(self)
	return "dis_turn";
end


-- 状态名 
cls_dis_turn.get_status_name = function(self)
	return T("禁止转动");
end

-- 增减益 
cls_dis_turn.get_status_type = function(self)
	return T("减益");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"clear_debuff", "wudi", }

cls_dis_turn.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

cls_dis_turn.deal_result = function(self, tbResult)
	cls_dis_turn.super.deal_result(self, tbResult)

	-- 禁止船只转向
	self.target.body:setBanRotate(true)
end

cls_dis_turn.un_deal_result = function(self, tbResult)
	-- 允许船只转向
	self.target.body:setBanRotate(false)

	cls_dis_turn.super.un_deal_result(self, self.tbResult)
end
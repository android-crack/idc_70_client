----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_mingzhong_2 = class("cls_mingzhong_2", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_mingzhong_2.get_status_id = function(self)
	return "mingzhong_2";
end


-- 状态名 
cls_mingzhong_2.get_status_name = function(self)
	return T("命中_2");
end

-- 增减益 
cls_mingzhong_2.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_mingzhong_2.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.custom_mingzhong_rate then 
		self.target:setHitRate(self.target:getHitRate() + tbResult.custom_mingzhong_rate)
	end
end

cls_mingzhong_2.un_deal_result = function(self, tbResult)
	if tbResult.custom_mingzhong_rate then 
		self.target:setHitRate(self.target:getHitRate() - tbResult.custom_mingzhong_rate)
	end
	self.super.un_deal_result(self, tbResult)
end
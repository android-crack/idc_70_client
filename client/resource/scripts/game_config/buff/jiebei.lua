----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_jiebei = class("cls_jiebei", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_jiebei.get_status_id = function(self)
	return "jiebei";
end


-- 状态名 
cls_jiebei.get_status_name = function(self)
	return T("戒备");
end

-- 增减益 
cls_jiebei.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_jiebei.affect_buff = function(self, targetBuff, tbResult)
	local target = self.target

	-- 不扣血直接返回
	if not tbResult.sub_hp then return tbResult end

	-- 未满血
	if target:getMaxHp() > target:getHp() then return tbResult end

	tbResult.sub_hp = tbResult.sub_hp * ( 1000.0 - self.tbResult.jb_defense_rate ) / 1000.0 

	return tbResult
end

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_fennu = class("cls_fennu", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_fennu.get_status_id = function(self)
	return "fennu";
end


-- 状态名 
cls_fennu.get_status_name = function(self)
	return T("愤怒");
end

-- 增减益 
cls_fennu.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"putonggongjitishen_ywwq", }

cls_fennu.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------
--
cls_fennu.affect_buff = function(self, targetBuff, tbResult)
	local target = self.target

	-- 不扣血直接返回
	if not tbResult.sub_hp then return tbResult end

	if target:getMaxHp() > 2 * target:getHp() then return tbResult end

	tbResult.sub_hp = tbResult.sub_hp * ( self.tbResult.fn_damage_rate + 1000.0 ) / 1000.0 

	return tbResult
end

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_dongxiruodian = class("cls_dongxiruodian", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_dongxiruodian.get_status_id = function(self)
	return "dongxiruodian";
end


-- 状态名 
cls_dongxiruodian.get_status_name = function(self)
	return T("洞悉弱点");
end

-- 增减益 
cls_dongxiruodian.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_dongxiruodian.affect_buff = function(self, targetBuff, tbResult)
	if not tbResult.sub_hp then return tbResult end

	tbResult.sub_hp = tbResult.sub_hp * 2

	return tbResult
end

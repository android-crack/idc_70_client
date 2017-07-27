----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_add_heal = class("cls_add_heal", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_add_heal.get_status_id = function(self)
	return "add_heal";
end


-- 状态名 
cls_add_heal.get_status_name = function(self)
	return T("强化治疗");
end

-- 增减益 
cls_add_heal.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_add_heal.affect_buff = function(self, targetBuff, tbResult)
	if not tbResult.add_hp then return tbResult end
	if self.tbResult.add_heal then
		local add_heal = self.tbResult.add_heal
		if targetBuff.duration_time and targetBuff.duration_time > 0 and 
			targetBuff.heart_break and targetBuff.heart_break > 0 then
			add_heal = add_heal/(targetBuff.duration_time/targetBuff.heart_break)
		end
		tbResult.add_hp = tbResult.add_hp + add_heal 
	end
	return tbResult
end
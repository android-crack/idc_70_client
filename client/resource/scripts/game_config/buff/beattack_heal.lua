----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_beattack_heal = class("cls_beattack_heal", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_beattack_heal.get_status_id = function(self)
	return "beattack_heal";
end


-- 状态名 
cls_beattack_heal.get_status_name = function(self)
	return T("受击回血");
end

-- 增减益 
cls_beattack_heal.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_beattack_heal.affect_buff = function(self, targetBuff, tbResult)
	if self.tbResult.add_heal then
		self.target:addHp(self.tbResult.add_heal, targetBuff.attacker)
	end
	return tbResult
end
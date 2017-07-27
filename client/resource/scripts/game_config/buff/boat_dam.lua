----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_boat_dam = class("cls_boat_dam", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_boat_dam.get_status_id = function(self)
	return "boat_dam";
end


-- 状态名 
cls_boat_dam.get_status_name = function(self)
	return T("船只伤害");
end

-- 增减益 
cls_boat_dam.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_boat_dam.affect_buff = function(self, targetBuff, tbResult)
	local target = self.target

	-- 不扣血直接返回
	if not tbResult.sub_hp then return tbResult end

	-- 非普通攻击不关
	if targetBuff.skill ~= "sk2" then return tbResult end

	tbResult.sub_hp = tbResult.sub_hp * ( self.tbResult.cz_damage_rate + 1000.0 ) / 1000.0 
	tbResult.baoji_flg = true

	return tbResult
end

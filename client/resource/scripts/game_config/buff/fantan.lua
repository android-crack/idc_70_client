----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_fantan = class("cls_fantan", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_fantan.get_status_id = function(self)
	return "fantan";
end


-- 状态名 
cls_fantan.get_status_name = function(self)
	return T("反弹");
end

-- 增减益 
cls_fantan.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_fantan.get_status_effect = function(self)
	return {"zhaozi", };
end

-- 特效类型 
cls_fantan.get_status_effect_type = function(self)
	return {"composite", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
cls_fantan.affect_attack = function(self, targetBuff, tbResult)
	if tbResult.sub_hp then 
		local sub_hp = tbResult.sub_hp*self.tbResult.fantan

		local status_map = require("game_config/buff/status_map")
		local clz = status_map["fantan_attack"]
		local status = clz.new(targetBuff.target, targetBuff.attacker, 0, 0, 0, 1, function(attacker, target, skillLv)
				 local tb = {}
				 tb.sub_hp = sub_hp
				 return tb
			end)
		status:add()
	end
	return tbResult
end

local tbDispath = {
	attack = cls_fantan.affect_attack,
	far_attack = cls_fantan.affect_attack,
	near_attack = cls_fantan.affect_attack,
}
cls_fantan.affect_buff = function(self, targetBuff, tbResult)
	tBuffId = targetBuff:get_status_id()
	if tbDispath[tBuffId] then
		return tbDispath[tBuffId](self, targetBuff, tbResult)
	end
	return tbResult
end

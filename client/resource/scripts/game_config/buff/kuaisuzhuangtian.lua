----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_kuaisuzhuangtian = class("cls_kuaisuzhuangtian", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_kuaisuzhuangtian.get_status_id = function(self)
	return "kuaisuzhuangtian";
end


-- 状态名 
cls_kuaisuzhuangtian.get_status_name = function(self)
	return T("快速装填");
end

-- 增减益 
cls_kuaisuzhuangtian.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
cls_kuaisuzhuangtian.affect_buff = function(self, targetBuff, tbResult)
	if not self.tbResult.ty_rate or not self.tbResult.ty_status_id or self.tbResult.ty_status_id == "" then 
		return tbResult
	end

	if self.tbResult.ty_rate < math.random(1000) then return tbResult end

	local status_map = require("game_config/buff/status_map")
	local clz = status_map[self.tbResult.ty_status_id]
	local status = clz.new(targetBuff.attacker, targetBuff.target, 
		self.tbResult.ty_status_time or 1, 0, self.skill, 1, function() return {} end)
	status:add()

	return tbResult
end

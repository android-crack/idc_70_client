----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_yangfanqihang = class("cls_yangfanqihang", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_yangfanqihang.get_status_id = function(self)
	return "yangfanqihang";
end


-- 状态名 
cls_yangfanqihang.get_status_name = function(self)
	return T("扬帆起航");
end

-- 增减益 
cls_yangfanqihang.get_status_type = function(self)
	return T("增益");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_yangfanqihang.affect_buff = function(self, targetBuff, tbResult)
	local target = self.target
	local selfTbResult = self.tbResult

	-- 普通攻击时，5%机率触发加速度
	if ( math.random(1000) > selfTbResult.yf_rate ) then return tbResult end

	local skill_map = require("game_config/battleSkill/skill_map")
	-- 加速度 
	-- sk90002
	local cls_skill = skill_map["sk90002"]
	cls_skill:do_use(target.id, target:getTarget())
	return tbResult
end

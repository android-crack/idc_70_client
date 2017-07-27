----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_miss = class("cls_miss", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_miss.get_status_id = function(self)
	return "miss";
end


-- 状态名 
cls_miss.get_status_name = function(self)
	return T("回避");
end

-- 增减益 
cls_miss.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_miss.get_status_effect = function(self)
	return {"texture_flow2", };
end

-- 特效类型 
cls_miss.get_status_effect_type = function(self)
	return {"liuguang", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------
local skill_effect_util = require("module/battleAttrs/skill_effect_util")
cls_miss.affect_buff = function(self, targetBuff, tbResult)
	if tbResult.sub_hp then 
		tbResult.sub_hp = tbResult.sub_hp - (self.tbResult.defend or 0)
		if tbResult.sub_hp <= 0 then tbResult.sub_hp = 1 end
	end
	return tbResult
end

cls_miss.affect_buff_display = function(self)

end
----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_dodge_3 = class("cls_dodge_3", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_dodge_3.get_status_id = function(self)
	return "dodge_3";
end


-- 状态名 
cls_dodge_3.get_status_name = function(self)
	return T("闪避_3");
end

-- 增减益 
cls_dodge_3.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_dodge_3.get_status_effect = function(self)
	return {"tx_0167", };
end

-- 特效类型 
cls_dodge_3.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态图标 
cls_dodge_3.get_status_icon = function(self)
	return "jiafang.png";
end


-- 状态提示 
cls_dodge_3.get_status_prompt = function(self)
	return T("闪避提升");
end

---------------------------------------------------------------

-- 关系属性

--本状态添加时会覆盖的状态
local overwrite_status = {"dodge", }

cls_dodge_3.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
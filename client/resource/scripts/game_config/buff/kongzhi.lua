----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_kongzhi = class("cls_kongzhi", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_kongzhi.get_status_id = function(self)
	return "kongzhi";
end


-- 状态名 
cls_kongzhi.get_status_name = function(self)
	return T("控制");
end

-- 增减益 
cls_kongzhi.get_status_type = function(self)
	return T("减益");
end

-- 特效 
cls_kongzhi.get_status_effect = function(self)
	return {"tx_skill_attackdown", };
end

-- 特效类型 
cls_kongzhi.get_status_effect_type = function(self)
	return {"particle_scene", };
end

-- 状态图标 
cls_kongzhi.get_status_icon = function(self)
	return "xuruo.png";
end


---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"clear_debuff", "wudi", }

cls_kongzhi.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------

----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_sub_def = class("cls_sub_def", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_sub_def.get_status_id = function(self)
	return "sub_def";
end


-- 状态名 
cls_sub_def.get_status_name = function(self)
	return T("降防");
end

-- 增减益 
cls_sub_def.get_status_type = function(self)
	return T("减益");
end

-- 状态图标 
cls_sub_def.get_status_icon = function(self)
	return "jianfang.png";
end


-- 状态提示 
cls_sub_def.get_status_prompt = function(self)
	return T("减防");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"add_def_3", "jianrupanshi", "clear_debuff", "wudi", }

cls_sub_def.get_exclude_status = function(self)
	return exclude_status
end

--本状态添加时会覆盖的状态
local overwrite_status = {"add_def", }

cls_sub_def.get_overwrite_status = function(self)
	return overwrite_status
end


----------------------- Auto Genrate End   --------------------
-- affect_attack = function(targetBuff, tbResult)
	-- return tbResult
-- end

-- local tbDispath = {
	-- attack = affect_attack,
-- }
-- cls_sub_def.affect_buff = function(self, targetBuff, tbResult)
	-- tBuffId = targetBuff:get_status_id()
	-- if ( tbDispath[tBuffId] ) then
		-- return tbDispath[tBuffId](targetBuff, tbResult)
	-- end
	-- if tbResult.sub_hp then 
		-- tbResult.sub_hp = tbResult.sub_hp + self.tbResult.defend
	-- end
	-- return tbResult
-- end
cls_sub_def.deal_result = function(self, tbResult)
	self.super.deal_result(self, tbResult)
	if tbResult.sub_defend then 
		self.target:subDefense(tbResult.sub_defend)
	end
end

cls_sub_def.un_deal_result = function(self, tbResult)
	self.super.un_deal_result(self, tbResult)
	
	if tbResult.sub_defend then 
		self.target:subDefense(-tbResult.sub_defend)	
	end
end

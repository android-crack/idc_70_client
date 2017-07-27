----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_chaofeng = class("cls_chaofeng", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_chaofeng.get_status_id = function(self)
	return "chaofeng";
end


-- 状态名 
cls_chaofeng.get_status_name = function(self)
	return T("嘲讽");
end

-- 增减益 
cls_chaofeng.get_status_type = function(self)
	return T("增益");
end

-- 特效 
cls_chaofeng.get_status_effect = function(self)
	return {"tx_chaofeng", };
end

-- 特效类型 
cls_chaofeng.get_status_effect_type = function(self)
	return {"particle_local", };
end

-- 状态提示 
cls_chaofeng.get_status_prompt = function(self)
	return T("嘲讽");
end

---------------------------------------------------------------

-- 关系属性

--目标有下列状态，本状态不能添加上去
local exclude_status = {"clear_debuff", "wudi", "mianyikongzhi", }

cls_chaofeng.get_exclude_status = function(self)
	return exclude_status
end


----------------------- Auto Genrate End   --------------------
local battleRecording = require("gameobj/battle/battleRecording")

local SK_FOLLOW = "sk_follow"
cls_chaofeng.deal_result = function(self, tbResult)
	if not self.attacker or not self.target then return end

	cls_chaofeng.super.deal_result(self, tbResult)

	self.target:changeTarget(self.attacker:getId())

	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isUpdateShip(self.target:getId()) then return end

	self.target:addAI(SK_FOLLOW, {})

	local ai_obj = self.target:getAI(SK_FOLLOW)

	ai_obj:setData("__follow_target_id", self.attacker:getId())

	ai_obj:tryRun(AI_OPPORTUNITY.RUN)
end

cls_chaofeng.un_deal_result = function(self, tbResult)
	if not self.target then return end

	local ai_obj = self.target:getAI(SK_FOLLOW)

	if ai_obj then
		self.target:completeAI(ai_obj)
		self.target:deleteAI(SK_FOLLOW)
	end

	cls_chaofeng.super.un_deal_result(self, tbResult)
end



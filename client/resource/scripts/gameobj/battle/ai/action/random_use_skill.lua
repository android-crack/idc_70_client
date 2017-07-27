--************************************--
-- author: hal
-- data: 2015-08-11
-- descript: 施放某个技能（需AI调出才施放，不自动施放）
--
-- modify:
-- who         data            reason
--
--
--************************************--

-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionRandomUseSkill = class("ClsAIActionRandomUseSkill", ClsAIActionBase) 

function ClsAIActionRandomUseSkill:getId()
	return "random_use_skill"
end

-- 
function ClsAIActionRandomUseSkill:initAction( skill_id )
end

function ClsAIActionRandomUseSkill:__dealAction( target_id, delta_time )
	-- body
	local ai_obj = self:getOwnerAI();
	if not ai_obj then return false end

	local battleData = getGameData():getBattleDataMt()
	local target_obj = battleData:getShipByGenID(target_id)

	if ( not target_obj ) then return false end

	-- TODO:选取skill_id

	-- 施放技能
	local owner_obj = ai_obj:getOwner();
	if owner_obj then
		-- 施放技能
		owner_obj:RandomUseSkill( owner_obj.target );
	end
end

return ClsAIActionRandomUseSkill

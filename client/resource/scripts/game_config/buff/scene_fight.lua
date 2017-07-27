----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_scene_fight = class("cls_scene_fight", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_scene_fight.get_status_id = function(self)
	return "scene_fight";
end


-- 状态名 
cls_scene_fight.get_status_name = function(self)
	return T("场景战斗");
end

-- 特效 
cls_scene_fight.get_status_effect = function(self)
	return {"tx_qihuo", };
end

-- 特效类型 
cls_scene_fight.get_status_effect_type = function(self)
	return {"particle_local", };
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

local rotateAngle
rotateAngle = function(x1, y1, c_value, s_value)
	local x = x1*c_value - y1*s_value
	local y = y1*c_value + x1*s_value
	return x, y
end

local commonBase = require("gameobj/commonFuns")
cls_scene_fight.deal_result = function(self, tbResult)
	if tbResult.BossSkill_Shape then
		if tbResult.BossSkill_Shape == SKILL_SHAPE_RECTANGLE then
			local buff_angle = 60
			local buff_pos = ccp(0, 0)

			local pos = {
				ccp(0, - tbResult.BossSkill_Width),
				ccp(0, tbResult.BossSkill_Width),
				ccp(tbResult.BossSkill_Length, tbResult.BossSkill_Width),
				ccp(tbResult.BossSkill_Length, - tbResult.BossSkill_Width),
			}

			local angle = math.rad(buff_angle)

			local cos_value, sin_value = math.cos(angle), math.sin(angle)

			for k, v in ipairs(pos) do
				local x, y = rotateAngle(v.x, v.y, cos_value, sin_value)
				pos[k] = ccp(x + buff_pos.x, y + buff_pos.y)
			end

			local targets = {}

			local battle_data = getGameData():getBattleDataMt()
			for k, v in pairs(battle_data:GetShips()) do
				if not v:is_deaded() then
					local boat_pos = v:getTranslationWorld()
					local x, y = boat_pos:x(), - boat_pos:z()

					local inside = true
					for pos_k, _ in ipairs(pos) do
						local pos_1, pos_2 = pos[pos_k], pos[pos_k + 1 > 4 and 1 or pos_k]
						local result = commonBase:IsLineLeft(pos_1.x, pos_1.y, pos_2.x, pos_2.y, x, y)

						if result > 0 then 
							inside = false
							break 
						end
					end

					if inside then
						targets[#targets + 1] = v
					end
				end
			end

			if #targets == 0 then return end

			local attacker = self.attacker

			local cls_skill = skill_map[tbResult.BossSkill]

			local idx = 1
			local lst_buff = cls_skill:get_add_status()

			for idx = 1, #lst_buff do
				
				local buff = lst_buff[idx]

				if buff.scope ~= "LAST_TARGET" then
					for _, target in ipairs(targets) do
						local tbIdx = cls_skill:deal_status(attacker, target, idx)
						cls_skill:end_display_call_back(attacker, target, tbIdx)
					end
				end
			end
		end
	end
end

cls_scene_fight.un_deal_result = function(self, tbResult)
end
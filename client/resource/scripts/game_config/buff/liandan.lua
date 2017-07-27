----------------------- Auto Genrate Begin --------------------

-- 定义状态继承类型
local clsBuffBase = require("module/battleAttrs/buff_base")

cls_liandan = class("cls_liandan", clsBuffBase);

-- 属性段
---------------------------------------------------------------

-- 状态ID 
cls_liandan.get_status_id = function(self)
	return "liandan";
end


-- 状态名 
cls_liandan.get_status_name = function(self)
	return T("链弹");
end

---------------------------------------------------------------

-- 关系属性


----------------------- Auto Genrate End   --------------------

cls_liandan.deal_result = function(self, tbResult)
	local battle_data = getGameData():getBattleDataMt()

	local ship = self.target

	if not battle_data:isUpdateShip(ship:getId()) then return end

	if not ship or ship:is_deaded() then return end

	local origin = ship.body.node:getTranslation()

	local forward = self.forward or Vector3.new()

	local angle = Vector3.angle(Vector3.new(1, 0, 0), forward)

	local angle_y = Vector3.angle(Vector3.new(0, 0, -1), forward)

	if math.deg(angle_y) > 90 then
		angle = math.rad(360 - math.deg(angle))
	end
	
	local targets = battle_data:enemyInRectangle(tbResult.BossSkill_Length, tbResult.BossSkill_Width, angle, origin, 
		ship)

	if #targets == 0 then return end

	local skill_map = require("game_config/battleSkill/skill_map")
	local cls_skill = skill_map[tbResult.BossSkill]

	local idx = 1
	local lst_buff = cls_skill:get_add_status()

	for idx = 1, #lst_buff do
		
		local buff = lst_buff[idx]

		if buff.scope ~= "LAST_TARGET" then
			for _, target in ipairs(targets) do
				cls_skill:end_display_call_back(ship, target, idx)
			end
		end
	end
end
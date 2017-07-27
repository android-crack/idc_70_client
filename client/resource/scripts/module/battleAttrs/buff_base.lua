local skill_effect_util= require("module/battleAttrs/skill_effect_util")

local clsBuffBase = class("clsBuffBase")

clsBuffBase.ctor = function(self, attackerBoat, targetBoat, durationTime, heart_break, skillId, skillLv, calc_status, dir)
	-- 记录施放船只
	self.attacker = attackerBoat
	-- 记录目标
	self.target = targetBoat
	-- 记录持续时间
	self.duration_time = durationTime
	self.lastUpdateTime = getCurrentLogicTime()
	-- 记录心跳间隔
	self.heart_break = heart_break
	-- 记录施放本状态的技能id
	self.skill = skillId
	self.skillLv = skillLv 

	self.calc_status = calc_status

	if dir then
		self.forward = Vector3.new(dir)
	end

	self.calDurationTime = 0
end

clsBuffBase.get_status_id = function(self)
	return ""
end

clsBuffBase.get_status_name = function(self)
	return ""
end

clsBuffBase.get_status_prompt = function(self)
	return ""
end

clsBuffBase.get_exclude_status = function(self)
	return {}
end

clsBuffBase.get_overwrite_status = function(self)
	return {}
end

clsBuffBase.get_affect_effect_statusA = function(self)
	return {}
end

clsBuffBase.get_affect_effect_statusT = function(self)
	return {}
end

-- 状态互相影响时的显示 
clsBuffBase.affect_buff_display = function(self)
end

clsBuffBase.affect = function(self, tbResult)
    local affect_a = self:get_affect_effect_statusA()
	for _, buffid in ipairs(affect_a) do
		local buff = self.attacker:hasBuff(buffid)
		if buff then
			tbResult = buff:affect_buff(self, tbResult)
			buff:affect_buff_display()
		end
	end

	local affect_t = self:get_affect_effect_statusT()
	for _, buffid in ipairs(affect_t) do
		local buff = self.target:hasBuff(buffid)
		if  buff then
			tbResult = buff:affect_buff(self, tbResult)
			buff:affect_buff_display()
		end
	end

    -- 暴击
    self:critical(tbResult)

	return tbResult
end

-- 暴击
clsBuffBase.critical = function(self, tbResult)
    if tbResult.sub_hp and self:get_status_id() ~= "sub_hp_2" then
    	local critical = self.attacker:getCritRate() - self.target:getAntiCrits() + 50 + (tbResult.baoji_skill or 0)
    	if critical > math.random(1000) then
            tbResult.sub_hp = tbResult.sub_hp * (tbResult.baoji_times or 2)
            tbResult.baoji_flag = true
        end
    end
end

clsBuffBase.affect_buff = function(self, targetBuff, tbResult)
	return tbResult
end

-- 将要改变血量
clsBuffBase.ToModifyHp = function(self, attacker, md_value, damage_type)
	return md_value 
end

clsBuffBase.calc = function(self)
	-- 结算处理:
	if self.isCalc then return end

	-- 是否目标身上有排斥状态
	local excludeBuffs = self:get_exclude_status()
	for _, buff in pairs(excludeBuffs) do
		local buffObj = self.target:hasBuff(buff)
		if buffObj then
			-- 有排斥状态直接返回
			buffObj:exclude(self)
			return
		end
	end

	-- 覆盖目标状态
	local overwriteBuffs = self:get_overwrite_status()
	for _, buff in pairs(overwriteBuffs) do
		local buffObj = self.target:hasBuff(buff)
		if buffObj then
			-- 覆盖状态直接返回
			buffObj:to_be_overwrite(self)
			buffObj:del(true)
		end
	end
	
	self:deal_result(self.tbResult)

	self:add_buff_display()

	self.target:addBuff(self)

	self.isCalc = true
end

-- 使用该技能前触发当前的状态结算 
clsBuffBase.active = function(self, targetSkillId)
end

-- 回复已使用该技能触发其他技能计算的数据
clsBuffBase.reset_active = function(self, targetSkillId)
end

-- 状态移除结算
clsBuffBase.un_calc = function(self)
	if not self.isCalc then return end

	self:un_deal_result(self.tbResult)

	self.isCalc = false
end

clsBuffBase.deal_result = function(self, tbResult)
	if not self.target or self.target:is_deaded() then return end

	local sub_hp = tbResult.sub_hp and math.floor(tbResult.sub_hp + 0.5)
	if sub_hp then
		-- 强制伤害最低值 
		if sub_hp <= 0 then
			sub_hp = 1
		end
		self.target:subHp(sub_hp, self.attacker, tbResult)
	end

	local add_hp = tbResult.add_hp and math.floor(tbResult.add_hp + 0.5)
	if add_hp then 
		self.target:addHp(add_hp, self.attacker)
	end

	if tbResult.hit_effect then 
		self.target:showHitEffect(tbResult.hit_effect, tbResult.hit_effect_time)
	end

	if not self.attacker then return end

	if tbResult.shake_time or tbResult.shake_range then
		tbResult.shake_time = tbResult.shake_time or 1
		tbResult.shake_range = tbResult.shake_range or 1

		local battle_data = getGameData():getBattleDataMt()
		if self.attacker:getUid() == battle_data:getCurClientUid() then
			CameraFollow:SceneShake(tbResult.shake_time, tbResult.shake_range, true)
		end
	end

	if tbResult.translate and not self.target:hasBuff("unmovable") then
		self.attacker:translateAnimation(self.target, tbResult.translate)
	end
end

clsBuffBase.un_deal_result = function(self, tbResult)
	
end

clsBuffBase.get_effect_type = function(self)
	return ""
end

clsBuffBase.get_status_effect_type = function(self)
	return ""
end

clsBuffBase.get_status_effect = function(self)
	return ""
end

clsBuffBase.get_status_icon = function(self)
	return ""
end

-- 添加buff显示效果
clsBuffBase.add_buff_display = function(self)
	local effect_types = self:get_status_effect_type()
	local eff_names = self:get_status_effect()

	if type(effect_types) == "table" and #effect_types > 0 then
		for k, effect_type in ipairs(effect_types) do
			local eff_name = eff_names[k]

			if self.target:getId() > 0 then
				local func = skill_effect_util.effect_funcs[effect_type]
				if func and eff_name and eff_name ~= "" then
					func({id = eff_name, attacker = self.attacker, target = self.target, owner = self.target, 
						duration = self.duration_time})
				end
			else
				if not self.effects then
					self.effects = {}
				end

				local battle_data = getGameData():getBattleDataMt()
				local x, y = self.attacker:getPosition()
				local id = battle_data:addeffect(nil, eff_name, x, y, self.duration_time)

				self.effects[#self.effects + 1] = id
			end
		end
	end

	if self:get_status_icon() ~= "" then
		if self.target and self.target:getBody() and self.target:getBody().ui 
			and self.target:getBody().ui.buffIconsBar then 
			self.target:getBody().ui.buffIconsBar:InsertBuffIcon(self:get_status_icon())
		end
	end
end

-- 移除buff显示效果
clsBuffBase.del_buff_display = function(self)
	local effect_types = self:get_status_effect_type()
	local eff_names = self:get_status_effect()

	if self.target:getId() > 0 and type(effect_types) == "table" and #effect_types > 0 then
		for k, effect_type in ipairs(effect_types) do
			local eff_name = eff_names[k]

			local func = skill_effect_util.del_effect_funcs[effect_type]
			if func and eff_name and eff_name ~= "" then
				func({id = eff_name, owner = self.target})
			end
		end
	end

	if self.target:getId() == 0 and type(self.effects) == "table" then
		for k, v in ipairs(self.effects) do
			getGameData():getBattleDataMt():delEffect(id)
		end
	end
	
	if self:get_status_icon() ~= "" then
		if self.target and self.target:getBody() and self.target:getBody().ui 
			and self.target:getBody().ui.buffIconsBar then 
			self.target:getBody().ui.buffIconsBar:RemoveBuffIcon(self:get_status_icon())
		end
	end
end

-- 从目标身上移除
clsBuffBase.del = function(self, not_upload)
	if not not_upload then
		getGameData():getBattleDataMt():uploadDelStatus(self)
	end

	self.target:delBuff(self:get_status_id())

	self:un_calc()
	self:del_buff_display()
end

-- 本状态排斥了目标状态,目标状态
-- 目标状态只是创建成功,尚未calc,携带了attacker,target
clsBuffBase.exclude = function(self, targetBuff)
end

-- 本状态被目标状态覆盖
-- 目标状态只是创建成功,尚未calc,携带了attacker,target
clsBuffBase.to_be_overwrite = function(self, targetBuff)
end

-- 添加到目标身上
clsBuffBase.add = function(self)
	local target = self.target

	if not target then return end

	if target:getId() > 0 and target:is_deaded() then return end
	
	-- 是否目标身上有排斥状态
	local excludeBuffs = self:get_exclude_status()
	for _, buff in pairs(excludeBuffs) do
		local buffObj = target:hasBuff(buff)
		if buffObj then
			-- 有排斥状态直接返回
			buffObj:exclude(self)
			return
		end
	end

	-- 覆盖目标状态
	local overwriteBuffs = self:get_overwrite_status()
	for _, buff in pairs(overwriteBuffs) do
		local buffObj = target:hasBuff(buff)
		if buffObj and buff ~= self:get_status_id() then
			-- 覆盖状态直接返回
			buffObj:to_be_overwrite(self)
			buffObj:del()
		end
	end

	if type(self.calc_status) == "function" then
		self.tbResult = self.calc_status(self.attacker, target, self.skillLv)
	end

	-- 处理影响
	if target:getId() > 0 then
		self.tbResult = self:affect(self.tbResult)
	end

	local battle_data = getGameData():getBattleDataMt()
	battle_data:uploadAddStatus(self)
end

clsBuffBase.heart_beat = function(self)
	self:deal_result(self.tbResult)	
end

clsBuffBase.heart_beat_display = function(self)
end

-- 在状态判定，默认返回True
clsBuffBase.InBuff = function(self)
	-- 超时判断状态
	local now = getCurrentLogicTime()
	
	if (self.calDurationTime + (now - self.lastUpdateTime)) >= self.duration_time*1000 then 
		self:del(true)
		return nil 
	end
	
	return self 
end

clsBuffBase.update = function(self, elapsedTime)
	self.elapsedTime = (self.elapsedTime or 0) + elapsedTime
	self.calDurationTime = self.calDurationTime + elapsedTime
	self.lastUpdateTime = getCurrentLogicTime()

	if not self:InBuff() then return end

	if self.heart_break and self.heart_break > 0 then 
		local heart_break = self.heart_break * 1000
		while self.elapsedTime >= heart_break do
			self.elapsedTime = self.elapsedTime - heart_break
			-- 心跳
			self:heart_beat()
			self:heart_beat_display()
		end
	end
end

return clsBuffBase

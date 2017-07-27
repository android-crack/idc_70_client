
----商会研究所数据

local ClsGuildResearchData = class("ClsGuildResearchData")

ClsGuildResearchData.ctor = function(self)
	self.research_data = nil 	--研究所数据
	self.study_skill_data = {}  ---学习技能信息
	self.fly_status = false   ---跳转状态
end

ClsGuildResearchData.setFlyStatus = function(self, enable)
	self.fly_status = enable
end

ClsGuildResearchData.getFlyStatus = function(self)
	return self.fly_status
end

---学习技能数据
ClsGuildResearchData.setStudySkillData = function(self, data)
	self.study_skill_data = data
end

ClsGuildResearchData.getStudySkillData = function(self)
	return self.study_skill_data
end

---研究所数据
ClsGuildResearchData.setResearchData = function(self, data)
	self.research_data = data
end

ClsGuildResearchData.getResearchData = function(self)
	return self.research_data
end

ClsGuildResearchData.clearResearchData = function(self)
	self.research_data = nil 
end

ClsGuildResearchData.updateResearchData = function(self, info)
	if not self.research_data then return end 
	local data = table.clone(self.research_data)
	for k,v in ipairs(data) do
		if v.key == info.key then
			self.research_data[k] = info
		end
	end
end

---判断商品是不是商会研究所需要的商品
ClsGuildResearchData.isGoodsGuildNeed = function(self, good_id)
	---判断商会是否存在
	local guild_info_data = getGameData():getGuildInfoData()
	local is_have_guild = guild_info_data:hasGuild()
	if not is_have_guild then
		return false
	end

	---判断商会等级
	local guild_level = guild_info_data:getGuildGrade()
	if guild_level < OPEN_GUILD_RESEARCH_LEVEL then
		return false
	end

	if not self.research_data then print("-------无商会研究所数据--------")return false end

	for k,v in pairs(self.research_data) do
		if self:isNeedGoods(v.list, good_id) then
			return true
		end
	end

	return false	
end

ClsGuildResearchData.isNeedGoods = function(self, good_list ,good_id)
	for k,v in pairs(good_list) do
		if v.mate_id == good_id then
			return true
		end
	end
	return false
end


---获取商品的信息
ClsGuildResearchData.getGoodsInfoById = function(self, good_id)
	if not self.research_data then return end
	local good_list = self:getGuildNeedGoodsList() 
	return good_list[good_id]
end

ClsGuildResearchData.getGuildNeedGoodsList = function(self)
	local good_list = {}
	for k,v in pairs(self.research_data) do
		for kay,value in pairs(v.list) do
			good_list[value.mate_id] = {mate_curr = value.mate_curr, mate_need = value.mate_need}
		end
	end
	return good_list		
end


---研究所的进度获取,等级
ClsGuildResearchData.getSkillComplateNumAndLimit = function(self)
	if not self.research_data then return end
	local num = 0 
	local limit_level = 0
	for k,v in pairs(self.research_data) do
		if v.key ~= "" then
			if v.level == v.limit then
				num = num + 1
			end
			limit_level = v.limit/5
		end
	end

	return num, limit_level
end

---保存商会研究所选中的技能数据

ClsGuildResearchData.setResearchSelectSkillInfo = function(self, data)
	if self.data then
		self.data = {}
	end
	self.data = data
end

ClsGuildResearchData.getResearchSelectSkillInfo = function(self)
	return self.data
end

ClsGuildResearchData.updateResearchSelectSkillInfo = function(self, info)
	if not info then return  end 
	if not self.data then return end 
	for i,v in ipairs(info.list) do
		if self.data.id == v.mate_id then
			self.data.have_amount  = v.mate_curr
		end
	end	
end

---钻石捐献弹框状态
ClsGuildResearchData.setResearchTipsStatus = function(self, status)
	self.tips_status = status
end

ClsGuildResearchData.getResearchTipsStatus = function(self)
	return self.tips_status
end


---请求研究所数据
ClsGuildResearchData.askResearchData = function(self)
	GameUtil.callRpc("rpc_server_group_skill", {},"rpc_client_group_skill") 

end


---请求材料研究
ClsGuildResearchData.askResearchByMate = function(self, skill_id, mate_id)
	GameUtil.callRpc("rpc_server_take_material", {skill_id, mate_id}) 
end

---请求钻石研究
ClsGuildResearchData.askResearchByDiamound = function(self, skill_id, mate_id)
	GameUtil.callRpc("rpc_server_take_material_by_gold", {skill_id, mate_id}) 
end

--学习技能
ClsGuildResearchData.askStudySkill = function(self, skill_id)
	GameUtil.callRpc("rpc_server_group_skill_learn", {skill_id}) 
end

---请求学习技能数据
ClsGuildResearchData.askStudyData = function(self)
	GameUtil.callRpc("rpc_server_group_skill_learn_info", {},"rpc_client_group_skill_learn_info")
end

return ClsGuildResearchData
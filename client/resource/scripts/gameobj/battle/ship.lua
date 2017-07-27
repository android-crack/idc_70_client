local alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local skills = require("module/battleAttrs/skills")
local battleProp = require("gameobj/battle/battleProp")
local boat_info = require("game_config/boat/boat_info")
local dataTools = require("module/dataHandle/dataTools")
local SceneEffect = require("gameobj/battle/sceneEffect")
local prop_info = require("game_config/battle/prop_info")
local battleShip3d = require("gameobj/battle/battleShip3d")
local music_info = require("scripts/game_config/music_info")
local sailor_info = require("game_config/sailor/sailor_info")
local skill_map = require("game_config/battleSkill/skill_map")
local skill_warning = require("game_config/skill/skill_warning")
local status_map = require("game_config/buff/status_map")
local shipEffectLayer = require("gameobj/battle/shipEffectLayer")
local battleRecording = require("gameobj/battle/battleRecording")
local skill_effect_util = require("module/battleAttrs/skill_effect_util")
local battle_slogan = require("game_config/battle/battle_slogan")

local ADD_HP_TIME = 200

local HEART_BEAT_CNT = 10
local HEART_BEAT_TIME = math.floor(1000/3)
local HEART_BEAT_CHECK_MOVE = SHIP_HEART_BEAT_CNT_PER_SEC

local PROP_IGNORE_HIT_EFFECT = 
{
	["tx_shoujisuipian01"] = true,
	["tx_shoujisuipian02"] = true,
	["tx_shoujisuipian03"] = true,
}

require("game_config/battle_config")

local ClsShip = class("ClsShip")

ClsShip.ctor = function(self, data)
	-- 通过战斗数据生成船只ID
	local battle_data = getGameData():getBattleDataMt()

	self.id = data.gen_id
	-- 名字
	self.name = data.name
	-- 玩家名字
	self.fighter_name = data.fighter_name or ""
	-- 爵位
	self.nobility = data.nobility
	-- 等级
	self.level = data.level or 1
	-- 船类型
	self.ship_id = data.ship_id
	-- 水手
	self.sailor_id = data.sailor_id
	-- 水手等级
	self.sailor_lv = data.sailor_lv
	-- 船头像类型
	self.head_id = data.head_id
	-- pve敌方船只
	self.is_pve_boat = data.is_pve_boat
	-- 玩家UID
	self.uid = data.uid or 0
	-- 是否旗舰
	self.isLeader = data.is_leader
	if self:is_leader() then
		if not self:isPVEShip() then
			battle_data:setControlShipID(self.id, self.uid)
		end

		battle_data:setLeaderID(self)
	elseif not self:isPVEShip() and self:getUid() == battle_data:getCurClientUid() and data.tag ~= battle_config.FEN_SHEN_TAG then
		battle_data:refreshAlivePartner(1)
	end

	-- 此船的目标
	self:setTarget(nil)

	self.land_collision = 0

	-- TODO:这里记录了数据，以后看看是不是要删除
	self.baseData = data

	-- 技能CD
	self.skill_cd = {}
	-- buff
	self.buffs = {}
	-- 技能
	self.skills = {}
	self.ex_skills = {}
	self.skill_initiativeList = {}

	-- collision_obj
	self.collision_obj = {}
	self.collision_point = {}

	-- 初始化战斗用数值
	self:initBattleValues(data)
	-- 初始化技能
	self:initSkills(data)

	battle_data:InsertShip(self)

	-- 行走ai
	self.walk = data.walk_Id or 0

	self.check_move_status = {}

	-- 构建船的body
	local prop_id = data.prop_id
	if prop_info[prop_id] then  -- 非船
		self.is_ship = false
		self.body = battleProp.new(data, self.id)
	else
		self.is_ship = true
		self.body = battleShip3d.new(self)

		if not self:is_leader() then
			self.body.node:scale(0.7)
		end

		if battle_data:isCurClientControlShip(self.id) then
			CameraFollow:update(self.body)
		end

		-- 行走ai
		if self.walk <= 0 then
			local boat_attr = dataTools:getNewBoat(data.ship_id)
			self.walk = boat_attr.walk_Id or 0
		end
	end

	self.head_node = self.body.node:findNode("head", true)
	self.tail_node = self.body.node:findNode("tail", true)

	-- 调整初始化AI到这里
	self:initAI()

	-- 设置teamId这个必须在setControlShipID及创建body之后
	self:setTeamId(data.team_id)

	if self:is_leader() and not self:isPVEShip() and not battle_data:isDemo() and not battle_data:isAutoShip(self.id) then
		self.autoFighting = false
	else
		self:setAutoFight(true, true)
	end

	-- 船只头像初始化
	shipEffectLayer.onBorn(self)

	self.heart_time = getCurrentLogicTime()
	self.heart_time_count = - (self.id%HEART_BEAT_CNT + 1)*HEART_BEAT_TIME/HEART_BEAT_CNT

	-- 各种系统的辅助数据
	self.data = {}

	self.status_show_count = 0
	self.status_prompt = {}
	self.status_prompt_stack = {}

	self.show_add_hp = false
	self.add_hp_list = {}
	self.add_hp_time = getCurrentLogicTime()

	self.lock_move = false
end

-- 初始化战斗数值
ClsShip.initBattleValues = function(self, data)
	self.values = {}
	self.values.near 				= data[FV_ATT_NEAR]					-- 近战攻击
	self.values.speed 				= data[FV_SPEED]					-- 航行速度
	self.values.max_hp 				= math.floor(data[FV_HP_MAX])		-- 最大血量
	self.values.hp 					= data[FV_HP] or self.values.max_hp -- 现有血量
	self.values.defense 			= data[FV_DEFENSE]					-- 船体防御
	self.values.att_far 			= data[FV_ATT_FAR]					-- 远程攻击
	self.values.far_range 			= data[FV_FAR_RANGE]				-- 远程攻击距离
	self.values.fire_rate 			= data[FV_FIRE_RATE]				-- 远程攻速
	self.values.minus_cd 			= data[FV_MINUS_CD]					-- 主动技能减cd
	self.values.damage_increase 	= data[FV_DAMAGE_INC]				-- 伤害增加
	self.values.damage_reduction 	= data[FV_DAMAGE_DEC]   			-- 伤害减免
	self.values.anti_cirts			= data[FV_RESIST_CRIT] 				-- 抗暴
	self.values.baoji_rate 			= data[FV_CRIT_RATE]				-- 暴击率
	self.values.dodge 				= data[FV_DODGE]					-- 闪避
	self.values.hit_rate 			= data[FV_HIT_RATE]					-- 命中
end

-- 初始化技能
ClsShip.initSkills = function(self, data)
	-- 加入普通技能：普通近战，普通远程
	data.skills[#data.skills + 1] = {level = 1, id = battle_config.near_skill_id}
	data.skills[#data.skills + 1] = {level = 1, id = battle_config.far_skill_id}

	for _, v in pairs(data.skills) do
		self:addSkill(v.id, v.level, nil, v.sailor)
	end
end

------------------------------------------------------------------------------------------------------------------------

ClsShip.getId = function(self)
	return self.id
end

ClsShip.getName = function(self)
	return self.name
end

ClsShip.getFighterName = function(self)
	return self.fighter_name
end

ClsShip.getNobility = function(self)
	return self.nobility
end

ClsShip.getUid = function(self)
	return self.uid
end

ClsShip.getBody = function(self)
	return self.body
end

ClsShip.getLevel = function(self)
	return self.level
end

ClsShip.getSailorID = function(self)
	return self.sailor_id
end

ClsShip.getSailorJob = function(self)
	local id = self:getSailorID()
	if not id or not sailor_info[id] then return 0 end

	return sailor_info[id]["job"][1]
end

ClsShip.getSailorLV = function(self)
	return self.sailor_lv
end

ClsShip.getHeadID = function(self)
	return self.head_id
end

ClsShip.isPVEShip = function(self)
	return self.is_pve_boat
end

ClsShip.getRole = function(self)
	return self.baseData.role
end

ClsShip.getHeadNode = function(self)
	return self.head_node
end

ClsShip.getTailNode = function(self)
	return self.tail_node
end

ClsShip.isAutoFighting = function(self)
	return self.autoFighting
end

ClsShip.getDamageInc = function(self)
	return self.values.damage_increase or 0
end

ClsShip.getDamageDec = function(self)
	return self.values.damage_reduction or 0
end

ClsShip.setHitRate = function(self, value)
	self.values.hit_rate = value or self.values.hit_rate
end

ClsShip.getHitRate = function(self)
	return self.values.hit_rate or 1000
end

ClsShip.getAntiCrits = function(self)
	return self.values.anti_cirts or 0
end

-- 暴击率
ClsShip.setCritRate = function(self, value)
	self.values.baoji_rate = value or self.values.baoji_rate
end

ClsShip.getCritRate = function(self)
	return self.values.baoji_rate or 0
end

-- 闪避率
ClsShip.setDodge = function(self, value)
	self.values.dodge = value or self.values.dodge
end

ClsShip.getDodge = function(self)
	return self.values.dodge or 0
end

--增加闪避率
ClsShip.addDodge = function(self, value)
	self.values.dodge =  self.values.dodge or  0
	self.values.dodge = self.values.dodge + value
end

-- 远程攻速
ClsShip.setFireRate = function(self, value)
	self.values.fire_rate = value or self.values.fire_rate
end

ClsShip.getFireRate = function(self)
	return self.values.fire_rate or 0
end

-- 主动技能减cd
ClsShip.setMinusCD = function(self, value)
	self.values.minus_cd = value or self.values.minus_cd
end

ClsShip.getMinusCD = function(self)
	return self.values.minus_cd or 0
end

-- 设置船只teamId
ClsShip.setTeamId = function(self, teamId, from_server)
	if self.teamId == teamId then return end

	-- 通知服务器
	if self.teamId and not from_server then
		battleRecording:recordVarArgs("change_team", self.id, teamId)
	end

	if self.body and self.teamId ~= battle_config.default_team_id and self.teamId ~= battle_config.neutral_team_id then
		local battle_data = getGameData():getBattleDataMt()
		local ship = battle_data:getCurClientControlShip()
		if ship and ship.target == self then
			ship.target = nil
		end
		self.body:hideGuanquan()
	end
	self.teamId = teamId

	if self.teamId == battle_config.target_team_id or self.teamId == battle_config.enemy_team_id then
		self:getBody():setOutlineStyle(true)
	end
end

-- 获取船只的teamId
ClsShip.getTeamId = function(self)
	return self.teamId
end

ClsShip.setCollisionObj = function(self, id, target, point)
	if not id then return end

	self.collision_obj[id] = target
	self.collision_point[id] = point
end

ClsShip.getCollisionObj = function(self, id)
	if not id then 
		return self.collision_obj
	end
	return self.collision_obj[id]
end

ClsShip.getCollisionPoint = function(self, id)
	if not id then 
		return self.collision_point
	end
	return self.collision_point[id]
end

----------------------------------- 新版本AI系统有关函数 Begin -------------------------------------

require("gameobj/battle/ai/ai_base")

ClsShip.initAI = function(self)
	-- 新AI数据
	self.new_ai = {}
	-- 运行中的AI
	self.running_ai = {}
	-- 时机注册机制数据
	self.__has_opportunity = {}

	local data = self.baseData

	if data.new_ai_id then
		for k, aiId in ipairs(data.new_ai_id) do
			self:addAI(aiId, {})
		end
	end
	self:addPartnerAitoShip()
end

-- 给自己的小伙伴船增加一个攻击旗舰的AI
ClsShip.addPartnerAitoShip = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local uid = self:getUid()
	local is_cur_client = uid == battle_data:getCurClientUid()
	if is_cur_client and tonumber(self.sailor_id) > 0 and not self:is_leader() then
		local sailor_battle_ai = sailor_info[self.sailor_id].battle_ai
		for i, v in ipairs(sailor_battle_ai) do
			self:addAI(v, {})
		end
	end
end

-- 添加AI
ClsShip.addAI = function(self, ai_id, params)
	local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
	local ClsAI = require(clazz_name)
	local aiObj = ClsAI.new(params, self)

	self.new_ai[ai_id] = aiObj
	self.__has_opportunity[aiObj:getOpportunity()] = true
end

-- 删除AI
ClsShip.deleteAI = function(self, ai_id)
	self.new_ai[ai_id] = nil
	self.__has_opportunity = {}
	for ai, aiObj in pairs(self.new_ai) do
		self.__has_opportunity[aiObj:getOpportunity()] = true
	end
end

ClsShip.setRunningAI = function(self, aiObj)
	local ai_id = aiObj:getId()

	self.running_ai[ai_id] = aiObj
end

ClsShip.isRunningAI = function(self)
	return table.nums(self.running_ai) > 0
end

-- 尝试执行某个时机的AI
ClsShip.tryOpportunity = function(self, opportunity)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isUpdateShip(self:getId()) then return end
	
	if not self.new_ai then return end
	if not self.__has_opportunity[opportunity] then return end

	local tmp_new_ai = table.keys(self.new_ai)

	for _, ai_id in ipairs(tmp_new_ai) do
		if not self.running_ai[ai_id] and self.new_ai[ai_id] then
			local res = self.new_ai[ai_id]:tryRun(opportunity)
		end
	end
end

ClsShip.completeAI = function(self, aiObj)
	local ai_id = aiObj:getId()

	local battle_data = getGameData():getBattleDataMt()

	if aiObj:getOpportunity() == AI_OPPORTUNITY.FIGHT_START or aiObj:getOpportunity() == AI_OPPORTUNITY.BEFORE_FIGHT_START then
		battle_data:uploadAI(false, self:getId(), {ai_id})
	end

	-- 删除正在执行AI
	self.running_ai[ai_id] = nil

	battle_data:setAiStepList(self:getId(), ai_id, -1)
end

ClsShip.getAI = function(self, ai_id)
	return self.new_ai[ai_id]
end

ClsShip.getRuningAI = function(self, ai_id)
	return self.running_ai[ai_id]
end

----------------------------------- 新版本AI系统有关函数 End   -------------------------------------

-- 船只说话
ClsShip.say = function(self, name, word, from_server)
	if self:is_deaded() then return end

	if not from_server then
		battleRecording:recordVarArgs("say", self.id, name, word)
	end

	local body = self.body
	if body.dialogBox and not tolua.isnull(body.dialogBox) then
		body.dialogBox:removeFromParentAndCleanup(true)
		body.dialogBox = nil
	end

	local msg = {}
	msg.x = 90
	msg.y = -80
	msg.txt = word
	msg.seaman_id = self:getSailorID()
	-- 能通过点击取消播放
	msg.isTouchRemove = true

	msg.name = name
	if not name or string.len(name) <= 0 then
		if self:is_leader() and not self:isPVEShip() then
			msg.name = self:getFighterName()
		elseif self:isPVEShip() then
			msg.name = self:getName()
		elseif tonumber(msg.seaman_id) > 0 then
			msg.name = sailor_info[msg.seaman_id].name
		end
	end

	msg.parent = body.dialog

	local dialog = require("gameobj/battle/battleDialog")
	body.dialogBox = dialog:showBox(msg)
end

ClsShip.release = function(self, is_death, is_send)
	if self:is_deaded() then return end

	self:similarityBoss()

	self.isDeaded = true

	local battle_data = getGameData():getBattleDataMt()

	battle_data:showDeadEffect(self)

	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:removeNPC(self:getId())
	end	

	for _, v in pairs(self.buffs) do
		v:del(true)
	end

	local uid = self:getUid()

	if uid == battle_data:getCurClientUid() then
		if self:is_leader() then
			battle_data:SetShipsDead(true)
		elseif self.baseData.tag ~= battle_config.FEN_SHEN_TAG then
			battle_data:refreshAlivePartner(-1)
		end
	end

	if is_death and self.baseData.tag ~= battle_config.FEN_SHEN_TAG then
		self:tryOpportunity(AI_OPPORTUNITY.DEATH)

		if self.teamId == battle_config.default_team_id and not self:is_leader() then
			-- 保存攻击方死亡船只数
			local dead_ship_count = battle_data:GetData("attacker_dead_ship_count") or 0
			battle_data:SetData("attacker_dead_ship_count", dead_ship_count + 1)
		end
	end

	if not tolua.isnull(self.body.dialogBox) then
		self.body.dialogBox:removeFromParentAndCleanup(true)
		self.body.dialogBox = nil
	end

	if is_death and self.is_ship then
		self.body:drown()
	else
		if is_send then
			battleRecording:recordVarArgs("release", self.id)
		end

		local running_scene = GameUtil.getRunningScene()

		local juhuaguai = 32
		if running_scene and self.baseData.prop_id == juhuaguai then
			audioExt.playEffect(music_info.MONSTER_DIE.res)
			self:getBody():playAnimation("die", false)

			local ac_1 = CCDelayTime:create(2)
			local ac_2 = CCCallFunc:create(function()
				self:getBody():release()
			end)
			
			running_scene:runAction(CCSequence:createWithTwoActions(ac_1, ac_2))
		else
			self:getBody():release()
		end
	end

	local leader = battle_data:getLeaderShip(uid)
	if battle_data:isCurClientControlShip(self.id) and not self:is_leader() and leader and not leader:is_deaded() then
		battle_data:changeControlShip(leader:getId())
	end
end

ClsShip.getHpRate = function(self)
	local max_hp = self:getMaxHp()
	if not max_hp or max_hp < 1 then return 0 end

	return self:getHp()/max_hp
end

ClsShip.setHp = function(self, value)
	self.values.hp = value or 0
end

ClsShip.getHp = function(self)
	return self.values.hp
end

ClsShip.getMaxHp = function(self)
	return math.max(0, self.values.max_hp)
end

ClsShip.subHp = function(self, sub_hp, attacker, tbResult)
	if attacker and self ~= attacker and self:getTeamId() == attacker:getTeamId() then return end
	if sub_hp < 0 then sub_hp = 1 end
	
	self:modifyHp(attacker, -sub_hp, nil, tbResult)
end

ClsShip.addHp = function(self, add_hp, attacker)
	if add_hp < 0 then add_hp = 1 end
	self:modifyHp(attacker, add_hp)
end

ClsShip.AIsetHp = function(self, value)
	if self:is_deaded() then return end

	local old_value = self:getHp()
	local modify_hp = value - old_value

	if modify_hp == 0 then return end

	local clz = status_map["ai_set_hp"]
	local status = clz.new(self, self, 0, 0)
	status.tbResult = {}

	if modify_hp > 0 then
		status.tbResult.add_hp = modify_hp
	else
		status.tbResult.sub_hp = - modify_hp
	end

	getGameData():getBattleDataMt():uploadAddStatus(status)
end

ClsShip.modifyHp = function(self, attacker_data, md_value, damage_type, tbResult)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:IsBattleStart() then return end

	damage_type = damage_type or battle_config.damage_type_far
	if type(md_value) ~= "number" then return end
	md_value = math.floor(md_value)

	if md_value == 0 or self.isDeaded then return end

	if md_value < 0 then
		tbResult.sub_hp = - md_value
	end

	self:setHp(Math.clamp(0, self:getMaxHp(), self:getHp() + md_value))

	shipEffectLayer.updateShipHp(self, md_value)

	local isCure = false
	if md_value > 0 then
		isCure = true
	end

	local show_left = false
	if attacker_data then
		local x_1, x_2 = attacker_data:getPositionX(), self:getPositionX() 
		if x_1 and x_2 and x_1 > x_2 then
			show_left = true
		end
	end

	if not isCure or not self.show_add_hp then
		if isCure then
			self.add_hp_time = getCurrentLogicTime()
			self.show_add_hp = true
		end
		shipEffectLayer.showDamageWord(self, md_value, isCure, tbResult, show_left)
	else
		self.add_hp_list[#self.add_hp_list + 1] = md_value
	end

	self:tryOpportunity(AI_OPPORTUNITY.HP_CHANGE)

	if self:getHp() <= 0 and not self:is_deaded() then
		self:similarityBoss(attacker_data)
		self:killTips(attacker_data)

		local not_fenshen = self.baseData.tag ~= battle_config.FEN_SHEN_TAG
		
		self:release(not_fenshen, true)

		if self.is_ship and not_fenshen then
			battleRecording:recordVarArgs("drown", self.id)
		end
	end
end

ClsShip.similarityBoss = function(self, ship)
	if not (self:isPVEShip() and self:getTeamId() ~= battle_config.default_team_id) then
		return
	end
	if self.is_check_kill then return end
	self.is_check_kill = true

	local GuildBossData = getGameData():getGuildBossData()
	GuildBossData:killBoss()

	if not ship then return end

	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isSimilarityBoss() then return end

	local killer_uid = ship:getUid()

	if type(killer_uid) ~= "number" then return end
	
	local killer_tbl = battle_data:GetData("killer_tab") or {}
	killer_tbl[killer_uid] = tonumber(killer_tbl[killer_uid]) + 1
	battle_data:SetData("killer_tab", killer_tbl)

	local elite_ship_id = 17
	if self.ship_id == elite_ship_id then --精英船
		local sup_killer_tbl = battle_data:GetData("sup_killer_tbl") or {}
		sup_killer_tbl[killer_uid] = tonumber(sup_killer_tbl[killer_uid]) + 1
		battle_data:SetData("sup_killer_tbl", sup_killer_tbl)
	end
	GuildBossData:tempSortRank()
end

ClsShip.killTips = function(self, ship)
	if not ship or ship == self then return end

	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:isUpdateShip(self:getId()) then return end

	local fight_ui = getUIManager():get("FightUI")
	if tolua.isnull(fight_ui) then return end

	local is_pvp = battle_data:GetData("is_pvp")

	if is_pvp then
		local attacker_name, attacker_name_is_null, attacker_is_enemy, attacker_sailor_id = self:getPvpKillInfo(ship)
		local be_attacker_name, be_attacker_name_is_null, be_attacker_is_enemy, be_attacker_sailor_id = self:getPvpKillInfo(self)
		if not attacker_name_is_null  and not be_attacker_name_is_null and 
			attacker_sailor_id > 0 and 
			be_attacker_sailor_id > 0 
		then
			local attacker = {
				name = attacker_name,
				is_enemy = attacker_is_enemy,
				sailor_id = attacker_sailor_id
			}
			local be_attacker = {
				name = be_attacker_name,
				is_enemy = be_attacker_is_enemy,
				sailor_id = be_attacker_sailor_id
			}
			fight_ui:showPvPKillTip(attacker, be_attacker)

			battleRecording:recordVarArgs("battle_pvp_kill_tips", ship:getId(), self:getId())
		end
	else
		local attacker_name, attacker_name_is_null = self:getTipsInfo(ship)
		local be_attacker_name, be_attacker_name_is_null = self:getTipsInfo(self)
		if not attacker_name_is_null  and not be_attacker_name_is_null then
			fight_ui:showSkillDamage(string.format(ui_word.BETTLE_KILL_TIPS,
			attacker_name, be_attacker_name))
		end
	end
end

ClsShip.getPvpKillInfo = function(self, ship_info)
	local sailor_id = ship_info:getSailorID()
	---水手名字
	local sailor_name = ""
	if ship_info:isPVEShip() then
		sailor_name = ship_info:getName()
	else
		if ship_info:is_leader() then
			sailor_name = ship_info:getFighterName()
		else
			
			if type(sailor_id) == "number" then
				sailor_name = sailor_info[sailor_id].name
			else
				sailor_name = ""
			end

		end
	end

	local is_null = false
	if sailor_name == "" or sailor_name == nil then
		is_null = true
	end
	local is_enemy = false
	if ship_info.teamId == battle_config.enemy_team_id or ship_info.teamId == battle_config.target_team_id then
		is_enemy = true

	end
	return sailor_name, is_null, is_enemy, sailor_id
end

ClsShip.getTipsInfo = function(self, ship_info)
	---水手名字
	local sailor_name = ""
	if ship_info:isPVEShip() then
		sailor_name = ship_info:getName()
	else
		if ship_info:is_leader() then
			sailor_name = ship_info:getFighterName()
		else
			local sailor_id = ship_info:getSailorID()
			if type(sailor_id) == "number" then
				sailor_name = sailor_info[sailor_id].name
			else
				sailor_name = ""
			end

		end
	end
	local color = "$(c:COLOR_BLUE_STROKE)"
	local is_null = false
	if sailor_name == "" or sailor_name == nil then
		is_null = true
	end
	if ship_info.teamId == battle_config.enemy_team_id or ship_info.teamId == battle_config.target_team_id then
		color = "$(c:COLOR_RED_STROKE)"
	end
	return color..sailor_name, is_null
end

-- 更改目标
ClsShip.changeTarget = function(self, target_id, player_select_target)
	if not target_id then return false end

	local battle_data = getGameData():getBattleDataMt()
	local target_ship = battle_data:getShipByGenID(target_id)

	if not target_ship or target_ship:is_deaded() then return false end

	if self:getTargetId() == target_id then 
		if player_select_target then
			target_ship:getBody():showGuanquan()
		end
		return false 
	end

	-- 嘲讽状态清除
	local chaofeng_obj = self:hasBuff("chaofeng")
	if chaofeng_obj then
		if not self.target or self.target:is_deaded() then
			chaofeng_obj:del()
			chaofeng_obj = nil
		elseif battle_data:isCurClientControlShip(self:getId()) then
			local msg = skill_warning.CHAOFENG.msg
			alert:battleWarning({msg = msg})

			return false
		end
	end

	self:setTarget(target_ship)

	return true
end

ClsShip.addSkill = function(self, skill_id, level, passive, sailor_id, is_add_by_ai, ord, show_effect)
	level = level or 1
	local skill_data = skills.createSkill(skill_id, level, passive)
	skill_data.sailor_id = sailor_id

	self.skills[skill_id] = skill_data
	self.ex_skills[skill_data.baseData.skill_ex_id] = {level = level, skill_id = skill_id}
	if skill_data.baseData.initiative == SKILL_INITIATIVE then
		self.skill_initiativeList[#self.skill_initiativeList + 1] = skill_id
	end

	if is_add_by_ai and self:is_leader() and ord then  --通过ai加的技能
		local battle_data = getGameData():getBattleDataMt()
		local ship = battle_data:getCurClientControlShip()		
		local battle_sort_skill = battle_data:GetData(ship.baseData.boat_key)
		battle_sort_skill[tonumber(ord)] = skill_id
		battle_data:SetData(ship.baseData.boat_key, battle_sort_skill)
		if self ~= ship then return end
		local battle_data = getGameData():getBattleDataMt()
		local battle_ui = battle_data:GetLayer("battle_ui")
		local skill = nil
		if show_effect == 1 then
			skill = skill_id
		end
		if not tolua.isnull(battle_ui) then
			battle_ui:initSkillUi(skill)
		end
	end
end


ClsShip.getSkill = function(self, skill_id)
	return self.skills[skill_id]
end

ClsShip.ai_check_skill_hit = function(self)
	local tuji_self_obj = self:hasBuff("tuji_self")
	if tuji_self_obj and tuji_self_obj.tbResult.tj_target then
		self:check_skill_hit(nil)
	end
end

ClsShip.check_skill_hit = function(self, target)
	local tuji_self_obj = self:hasBuff("tuji_self")
	if tuji_self_obj and getGameData():getBattleDataMt():isUpdateShip(self:getId()) then
		if target and self.teamId == target.teamId then return true end
		-- 设置撞击目标
		tuji_self_obj.tbResult.tj_target = target
		tuji_self_obj:del()
		return true
	end
	return false
end

-- TODO:多处AI有调用
ClsShip.addAnger = function(self, anger)
end

ClsShip.subSpeed = function(self, speed)
	self.values.speed = self.values.speed - speed
	self:setBodySpeed()
end

ClsShip.addSpeed = function(self, speed)
	self.values.speed = self.values.speed + speed
	self:setBodySpeed()
end

ClsShip.getSpeed = function(self)
	return self.values.speed
end

------------------------------------------------------------------------------------------------------------------------

--body attr
ClsShip.setBodySpeed = function(self)
	self:getBody():setSpeed(self.values.speed < 0 and 0 or self.values.speed)
end

------------------------------------------------------------------------------------------------------------------------

ClsShip.getTargetSpeed = function(self)
	if not self.target then return 0 end
	if self.target.isDeaded then return 0 end

	return self.target:getSpeed()
end

-- FIXME:改完导表，删除此函数
ClsShip.sub_speed = function(self, speed)
	self:subSpeed(speed)
end

ClsShip.add_speed = function(self, speed)
	self:addSpeed(speed)
end

-- 获取远程攻击力
ClsShip.getAttFar = function(self, dist)
	return self.values.att_far
end

ClsShip.subAttFar = function(self, val)
	self.values.att_far = self.values.att_far - val
end

ClsShip.addAttFar = function(self, val)
	self.values.att_far = self.values.att_far + val
end

-- 获取近战攻击
ClsShip.getAttNear = function(self)
	return self.values.near or 0
end

ClsShip.addAttNear = function(self, val)
	self.values.near = self.values.near + val
	return val
end

ClsShip.subAttNear = function(self, val)
	self.values.near = self.values.near - val
	return val
end

ClsShip.getDefense = function(self)
	return self.values.defense or 1
end

ClsShip.setDefense = function(self, val)
	self.values.defense = val
end

ClsShip.subDefense = function(self, val)
	self.values.defense = self.values.defense - val
end

ClsShip.addDefense = function(self, val)
	self.values.defense = self.values.defense + val
end

ClsShip.hasBuff = function(self, id)
	local buffObj = self.buffs[id]
	if buffObj and buffObj:InBuff() then return buffObj end

	return nil
end

ClsShip.addBuff = function(self, buff, from_server)
	if not buff then return end

	local id = buff:get_status_id()

	self.buffs[id] = buff

	local battle_data = getGameData():getBattleDataMt()

	local ship = battle_data:getCurClientControlShip()
	if self == ship or (buff.attacker and buff.attacker == ship) then
		shipEffectLayer.showStatusPrompt(self, buff:get_status_prompt())
	end
end

ClsShip.delBuff = function(self, id)
	self.buffs[id] = nil
end

ClsShip.setPosition = function(self, x, y)
	self.body:setPos(x, y)
end

ClsShip.getPosition3D = function(self)
	if not self.body or not self.body.node then return end
	return self.body.node:getTranslationWorld()
end

ClsShip.getPosition = function(self)
	local translation = self:getPosition3D()

	if not translation then return end

	local pos = gameplayToCocosWorld(translation)
	return pos.x, pos.y
end

ClsShip.getPositionX = function(self)
	local x = self:getPosition()
	return x
end

ClsShip.getPositionY = function(self)
	local _, y = self:getPosition()
	return y
end

ClsShip.setPositionX = function(self, x)
	local _x, y = self:getPosition()

	if not x or not y then return end

	battleRecording:recordVarArgs("set_pos", self:getId(), x, y)

	self.body:setPos(x, y)
end

ClsShip.setPositionY = function(self, y)
	local x, _y = self:getPosition()

	if not x or not y then return end

	battleRecording:recordVarArgs("set_pos", self:getId(), x, y)

	self.body:setPos(x, y)
end

ClsShip.getAngle = function(self)
	return self.body:getAngle()
end

ClsShip.setRota = function(self, dir)
	self.body:setAngle(ShipDirToRota[dir])
end

-- 播放录像时，服务器位置
ClsShip.setServerPos = function(self, x, y)
	self._serverX = x
	self._serverY = y
end

local ALLOW_POS_DIFF = 5

-- 校验位置
ClsShip.checkServerPos = function(self)
	local sx, sy = self._serverX, self._serverY

	if sx == nil or sy == nil then return end

	-- 同步过了就清除座标
	-- 等待下一次同步
	self._serverX = nil
	self._serverY = nil

	local x, y = self.body:getPos()

	if math.abs(sx - x) < ALLOW_POS_DIFF and
		math.abs(sy - y) < ALLOW_POS_DIFF then
		return
	end

	self.body:setPos( sx, sy )
end

local insertToShipList
insertToShipList = function(tableList,shipValue)
	for k,v in ipairs(tableList) do
		if v == shipValue then
			return false
		end
	end

	tableList[#tableList + 1] = shipValue
	return true
end

local removeFromShipList
removeFromShipList = function(tableList,shipValue)
	for k,v in ipairs(tableList) do
		if v == shipValue then
			for index = k,#tableList do
				tableList[index] = tableList[index+1]
			end
		end
	end
end

ClsShip.canAttack = function(self, target)
	local curTeam = self.teamId
	local targetTeam = target.teamId
	assert(curTeam)
	assert(targetTeam)

	if targetTeam == battle_config.neutral_team_id then
		return false
	end

	if curTeam == targetTeam then return false end

	if curTeam == battle_config.default_team_id or curTeam == battle_config.target_team_id then
		if targetTeam == battle_config.enemy_team_id then return true end

		if targetTeam == battle_config.default_team_id or targetTeam == battle_config.target_team_id then
			return true
		end
	end

	return false
end

-- FIXME:获得某船近战能够攻击的逻辑，不该放在船内
-- 凡是本类中引用到battleData的部分都应该在类外去实现，以免增加本类的耦合性
--jingz 获得近战攻击范围内可攻击的单位
--中立方不能参与攻击
ClsShip.getNearAttackAbleShips = function(self, near_dist)
	local near_ships = {}
	local sx, sy = self:getPosition()
	local near_distance = near_dist or self.body.near_dist or battle_config.near_dist_min
	local battle_data = getGameData():getBattleDataMt()
	for _, v in pairs(battle_data:GetShips()) do

		if not v.isDeaded and v ~= self then

			if self:canAttack(v) and  near_distance >= GetDistanceFor3D(self.body.node, v.body.node) then
				insertToShipList(near_ships, v)
			end
		end

	end
	return near_ships
end

ClsShip.getNearRange = function(self)
	local id = self.ship_id
	if id == 0 then return 0 end

	local kind = boat_info[id].kind
	local range = 0
	if kind == "smallShip" then
		range = battle_config.near_dist_min
	elseif kind == "middleShip" then
		range = battle_config.near_dist_mid
	else
		range = battle_config.near_dist_max
	end
	return range
end

ClsShip.setFarAttFange = function(self, value)
	self.values.far_range = value or self.values.far_range
end

ClsShip.getFarRange = function(self)
	return self.values.far_range or 0
end

ClsShip.get_skill_cd = function(self, skill_id)
	-- AI主动释放的技能去除技能cd
	local id = self:getIdByExId(skill_id)
	if self.skills[id] and self.skills[id].passiveFlag then
		return 0
	end

	local cd = self.skill_cd[skill_id]
	if not cd then return 0 end
	local now = getCurrentLogicTime()
	if ( cd < now ) then return 0 end
	return cd
end

ClsShip.get_remain_cd = function(self, skill_id)
	local cd = self:get_skill_cd(skill_id)

	if cd > 0 then
		cd = cd - getCurrentLogicTime()
	end

	return cd
end

ClsShip.set_skill_cd = function(self, skill_id, cd)
	local now = getCurrentLogicTime()
	self.skill_cd[skill_id] = now + cd
end

ClsShip.set_common_skill_cd = function(self, cd, skill_id)
	local id = self:getIdByExId(skill_id)
	if self.skills[id] and self.skills[id].passiveFlag then
		return 0
	end

	if cd <= 0 then return end
	local now = getCurrentLogicTime()
	if not self.common_skill_cd or self.common_skill_cd < now + cd then
		self.common_skill_cd = now + cd
	end
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:isCurClientControlShip(self:getId()) then return end
	
	local battle_ui = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battle_ui) then
		battle_ui:setCommonSkillCD()
	end
end

ClsShip.get_common_skill_cd = function(self)
	if not self.common_skill_cd then return 0 end
	local now = getCurrentLogicTime()
	if ( self.common_skill_cd <= now ) then return 0 end
	return self.common_skill_cd
end

ClsShip.get_skill_lv = function(self, skill_Id)
	local skd = self.skills[skill_Id]
	local skillLv = 1
	if skd then
		skillLv = skd.level
	end
	return skillLv
end

ClsShip.getSkillLv = function(self, ex_id)
	local index = string.find(ex_id, "_MAX")

	local skill_lv = 0
	local ex_skill_id = ex_id
	if index then
		ex_skill_id = string.sub(ex_id, 0, index - 1)
		local skill_id = self:getIdByExId(ex_skill_id)
		local skill_data = self:getSkill(skill_id)

		if not skill_data then return 999 end

		skill_lv = skill_data.baseData.max_lv
	else
		local skill_id = self:getIdByExId(ex_skill_id)

		if skill_id == 0 then return 0 end

		skill_lv = self:get_skill_lv(skill_id)
	end

	return skill_lv
end

ClsShip.resetMoveStatus = function(self, reason, num)
	self.check_move_status[reason] = num or 0
end

ClsShip.resetAllMoveStatus = function(self)
	for k, v in pairs(self.check_move_status) do
		self:resetMoveStatus(k)
	end
end

ClsShip.checkMoveAction = function(self, reason)
	if not reason or reason == "" then return false end

	if not self.check_move_status[reason] or self.check_move_status[reason] == 0 then
		self.check_move_status[reason] = 1
		return true
	end

	return false
end

ClsShip.setLockMove = function(self, value)
	self.lock_move = value
end

ClsShip.moveTo = function(self, position, reason, move_type)
	if not position then return false end

	self.body:moveTo(position, reason, move_type)
end

--------------------------------------------------------

ClsShip.UseSkill = function(self, skill_id, target_obj, not_show_warning)
	local ret = 0

	local skillData = self.skills[skill_id]

	if skillData == nil then return end

	local cls_skill = skill_map[skillData.baseData.skill_ex_id]

	if not cls_skill then return end

	target_obj = target_obj or self:getTarget()

	local isInitiative = skillData.baseData.initiative == SKILL_INITIATIVE
	local isAuto = skillData.baseData.initiative == SKILL_AUTO
	local isAura = skillData.baseData.initiative == SKILL_AURA

	if isInitiative then  -- 主动技
		ret = cls_skill:do_use(self.id, target_obj, not_show_warning)
	elseif isAuto then -- 自动技能
		ret = cls_skill:do_use(self.id, target_obj)
	elseif isAura then -- 光环
		ret = cls_skill:do_use_per_second(self.id, target_obj)
	end

	----------------------使用技能口号---------------------------

	local slogan = battle_slogan[skill_id]
	if ret == skill_warning.OK.msg and not self:is_leader() and slogan and math.random(100) <= slogan.random then
		local fight_ui = getUIManager():get("FightUI")
		if not tolua.isnull(fight_ui) then
			local is_slogan = fight_ui:isSlogan()
			if not is_slogan then
				battleRecording:recordVarArgs("battle_sailor_slogan" ,self:getId(), skill_id)
				fight_ui:setSlogan(self:getId(), skill_id)
			end		
		end
	end

	return ret
end

-- 随机对目标施放技能
ClsShip.RandomUseSkill = function(self, target_obj)
	if self:is_deaded() or self:is_hide() then return end

	if self:isPVEShip() or not self:is_leader() then return end

	-- 中立不攻击
	if self.teamId == battle_config.neutral_team_id then return end

	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:canUseSkill() then return end

	local common_cd = self:get_common_skill_cd()

	-- 技能公共CD啥也不做
	if common_cd and common_cd > 0 then return end

	local to_use_skill_list = {}
	for _, initiative_id in pairs(self.skill_initiativeList) do
		local skill = self.skills[initiative_id]

		if skill and not skill.passiveFlag then
			local cd = self:get_skill_cd(skill.baseData.skill_ex_id)
			if not cd or cd <= 0 then
				table.insert(to_use_skill_list, initiative_id)
			end
		end
	end

	local count = #to_use_skill_list
	if #to_use_skill_list == 0 then return end

	local index = math.random(1, count)
	local to_use_skill_id = to_use_skill_list[index]

	self:UseSkill(to_use_skill_id, target_obj)
end

------------------------------------------------------------------------------------------------------------------------

--寻找最近的目标船
ClsShip.getNearestShip = function(self)
	local nearest_ship = nil
	local nearest_dis = 0

	if self.teamId == battle_config.neutral_team_id then return nearest_ship, nearest_dis end

	local self_pos = self.body.node:getTranslationWorld()

	local battle_data = getGameData():getBattleDataMt()

	local tb_dis = battle_data:GetData("dis_of_ships") or {}

	local ships = battle_data:GetShips()
	for k, v in pairs(ships) do
		if not v:is_deaded() then
			if v.teamId ~= self.teamId and v.teamId ~= battle_config.neutral_team_id then
				if v.body and v.body.node then
					local target_pos = v.body.node:getTranslationWorld()

					-- local dv = Vector3.new()
					-- Vector3.subtract(self_pos, target_pos, dv)
					-- local dis = dv:length()

					local first, second = self:getId(), v:getId()
					if first > second then
						first, second = second, first
					end
					local key = string.format("%d_%d", first, second)

					local dis = tb_dis[key]

					if not dis then
						local offset_x = target_pos:x() - self_pos:x()
						local offset_y = target_pos:z() - self_pos:z()
						dis = offset_x*offset_x + offset_y*offset_y

						tb_dis[key] = dis
					end
					
					if nearest_dis == 0 or dis < nearest_dis then
						nearest_dis = dis
						nearest_ship = v
					end
				end
			end
		end
	end

	battle_data:SetData("dis_of_ships", tb_dis)

	return nearest_ship, nearest_dis
end

------------------------------------------------------------------------------------------------------------------------
ClsShip.updateBuffs = function(self, dt)
	if self:is_deaded() then return end

	local tmp_buff_id = table.keys(self.buffs)

	for _, id in ipairs(tmp_buff_id) do
		local buff = self.buffs[id]
		if buff then
			buff:update(dt)
		end
	end
end

ClsShip.updateAura = function(self, delta_time)
	if self:is_deaded() then return end

	for skill_id, skill in pairs(self.skills) do
		if skill.baseData then
			local isAura = (skill.baseData.initiative == SKILL_AURA)

			if isAura then
				self:UseSkill(skill_id, self:getTarget())
			end
		end
	end
end

-- 更新技能
ClsShip.updateAttack = function(self, delta_time)
	if self:is_deaded() or self:is_hide() then return end

	-- 中立不攻击
	if self.teamId == battle_config.neutral_team_id then return end

	local is_player_ship = not(self:isPVEShip() or not self:is_leader())

	local batch_play_skill = {}
	local batch_skill = {}
	for skill_id, skill in pairs(self.skills) do
		if skill.baseData then
			local cd = self:get_skill_cd(skill.baseData.skill_ex_id)

			if not cd or cd <= 0 then
				local isInitiative = skill.baseData.initiative == SKILL_INITIATIVE
				local isAuto = skill.baseData.initiative == SKILL_AUTO

				if is_player_ship and isInitiative and self:isAutoFighting() and not skill.passiveFlag then
					table.insert(batch_skill, skill_id)
				elseif isAuto then
					table.insert(batch_play_skill, skill_id)
				end
			end
		end
	end

	local battle_data = getGameData():getBattleDataMt()

	if not self:getRuningAI("sys_autoskill") and self:isAutoFighting() and battle_data:canUseSkill() then
		local count = #batch_skill
		if count >= 1 then
			local index = math.random(1, count)
			self:UseSkill(batch_skill[index], self:getTarget())

			return
		end
	end

	-- 没有的话，尝试使用普通技能
	for _, skill_id in ipairs(batch_play_skill) do
		self:UseSkill(skill_id, self:getTarget())
	end
end

ClsShip.updateAi = function(self, deltaTime)
	if self:is_deaded() then return end

	-- 新AI系统的心跳
	for ai_id, ai_obj in pairs(self.running_ai) do
		ai_obj:heartBeat(deltaTime)
	end

	if self.isDeaded then return end
	--
	-- 触发策略AI
	self:tryOpportunity(AI_OPPORTUNITY.TACTIC)

	if self.isDeaded then return end

	local catch = self:getNearInterestingShips(false, true)
	if #catch > 0 then
		self:tryOpportunity(AI_OPPORTUNITY.CATCH)

		for k, ship in pairs(catch) do
			if not ship.isDeaded then
				ship:tryOpportunity(AI_OPPORTUNITY.BECATCH)
			end
		end
	end
end

ClsShip.updateMoveStatus = function(self)
	for k, v in pairs(self.check_move_status) do
		if v > 0 then
			v = v + 1
			if v > HEART_BEAT_CHECK_MOVE then
				v = 0
			end
			self.check_move_status[k] = v
		end
	end
end

ClsShip.updateAddHp = function(self)
	local now = getCurrentLogicTime()
	if math.floor((now - self.add_hp_time)*1000) >= ADD_HP_TIME then
		self.add_hp_time = now
		if #self.add_hp_list == 0 then
			self.show_add_hp = false
			return
		end

		shipEffectLayer.showDamageWord(self, table.remove(self.add_hp_list, 1), true)
	end
end

-- 默认一秒一次的心跳
ClsShip.HeartBeat = function(self, delta_time)
	shipEffectLayer.updateShipHpGrey(self)

	self.heart_time_count = self.heart_time_count + delta_time
	if self.heart_time_count < 0 then return end
	self.heart_time_count = self.heart_time_count - HEART_BEAT_TIME

	self:updateMoveStatus()
	self:updateAddHp()

	local now = getCurrentLogicTime()
	local deltaTime = math.floor((now - self.heart_time) * 1000)
	self.heart_time = now

	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:BattleIsRunning() then return end

	self:updateBuffs(deltaTime)

	if not battle_data:isUpdateShip(self:getId()) then return end

	self:searchTarget(true)

	self:updateAura(deltaTime)
	self:updateAttack(deltaTime)
	self:updateAi(deltaTime)
end
------------------------------------------------------------------------------------------------------------------------

-- FIXME:此函数不该在此类中
--jingz 通过距离过滤近战攻击范围内的感兴趣对象
ClsShip.getNearInterestingShips = function(self, with_team, with_neutra)
	local near_distance =  self.body.near_dist or battle_config.near_dist_min
	return self:getRangedInterestingShips(0,near_distance,with_team, with_neutra)
end

-- FIXME:此函数不该在此类中
--jingz 通过距离过滤范围内的感兴趣对象
ClsShip.getRangedInterestingShips = function(self, min_distance, max_distance, with_team, with_neutra)

	local interesting_ships =
	{
		--玩家方
		[battle_config.default_team_id] = true,

		--防守方
		[battle_config.target_team_id] = true,

		--中立方(1,2不能攻击)
		[battle_config.neutral_team_id] = with_neutra,

		--敌对方(1,2都能攻击)
		[battle_config.enemy_team_id] = true,
	}

	if self.teamId == battle_config.neutral_team_id then
		interesting_ships[battle_config.neutral_team_id] = true
	end

	if self.teamId == battle_config.enemy_team_id or self.teamId == battle_config.target_team_id then
		interesting_ships[self.teamId] = with_team
	end


	local ships_list = {}
	local sx, sy = self:getPosition()
	local battle_data = getGameData():getBattleDataMt()
	for k, v in pairs(battle_data:GetShips()) do
		if not v.isDeaded and v ~= self and interesting_ships[v.teamId] then
			local dist = GetDistanceFor3D(self.body.node, v.body.node)
			if dist >= min_distance and dist <= max_distance then
				insertToShipList(ships_list, v)
			end
		end
	end

	return ships_list
end

ClsShip.has_skill_ex = function(self, ex_id)
	local ex_skill = self.ex_skills[ex_id]

	if not ex_skill or not ex_skill.level then return 0 end

	return ex_skill.level
end

ClsShip.getIdByExId = function(self, ex_id)
	if ex_id == "sk1" then return 1 end

	if ex_id == "sk2" then return 2 end

	local ex_skill = self.ex_skills[ex_id]

	if not ex_skill or not ex_skill.skill_id then return 0 end

	return ex_skill.skill_id
end

------------------------------------------------------------------------------------------------------------------------
ClsShip.is_leader = function(self)
	return self.isLeader
end

ClsShip.is_player = function(self)
	return self:is_leader() and not self:isPVEShip()
end

ClsShip.is_player_team = function(self)
	local battle_data = getGameData():getBattleDataMt()
	return self.teamId == battle_data:getCurClientControlShip().teamId
end

ClsShip.is_deaded = function(self)
	return self.isDeaded
end

------------------------------------------------------------------------------------------------------------------------

-- 船只隐身
ClsShip.setHide = function(self, val)
	self.isHide = val
end

ClsShip.is_hide = function(self)
	return self.isHide
end

ClsShip.onBulletHited = function(self, atker_data, bullet_data)
	if self.is_ship and atker_data.target then
		atker_data.target.body:beHit()
	end

	self:tryOpportunity(AI_OPPORTUNITY.BE_HIT)
end

ClsShip.setSpeedRate = function(self, rate)
	self.body:setSpeedRate(rate)
end

ClsShip.getSpeedRate = function(self)
	return self.body:getSpeedRate()
end

ClsShip.setData = function(self, key, value)
	self.data[key] = value

	if key == "__my_uid" then
		self.uid = value
		self.baseData.uid = value
	end
end

ClsShip.getData = function(self, key)
	return self.data[key]
end

ClsShip.setTarget = function(self, target)
	local battle_data = getGameData():getBattleDataMt()
	if battle_data:isCurClientControlShip(self:getId()) and target then
		if self.target and not self.target:is_deaded() then
			self.target:getBody():hideGuanquan()
		end
		target.body:showGuanquan()
	end
	self.target = target
end

ClsShip.getTarget = function(self)
	return self.target
end

ClsShip.getTargetId = function(self)
	if not self.target then return 0 end
	return self.target:getId()
end

ClsShip.getTargetDistance = function(self)
	if not self.target then return 99999 end
	if self.target.isDeaded then return 99999 end

	return GetDistanceFor3D(self.body.node, self.target.body.node)
end

ClsShip.getBaseId = function(self)
	return self.baseData.id
end

ClsShip.getBaseSpeed = function(self)
	return self.baseData[FV_SPEED]
end

ClsShip.getLeaderId = function(self)
	local battle_data = getGameData():getBattleDataMt()
	return battle_data:getLeaderID(self:getUid()) or 0
end

ClsShip.getLeaderTaregtId = function(self)
	local battle_data = getGameData():getBattleDataMt()
	local leader = battle_data:getLeaderShip(self:getUid())

	if not leader or not leader:getTarget() or leader:getTarget():is_deaded() then return 0 end

	return leader:getTarget():getId()
end

------------------------------------------------------------------------------------------------------------------------

ClsShip.setAutoFight = function(self, autoFightFlg, from_server)
	if self.autoFighting == autoFightFlg then return end

	local toRunAI = SYS_USER_AUTOFIGHT
	if not autoFightFlg then
		toRunAI = SYS_CLEAR
	end

	local ret = self:tryRunAI(toRunAI)

	if ret then
		self.autoFighting = autoFightFlg

		local battle_data = getGameData():getBattleDataMt()
		if self == battle_data:getCurClientControlShip() and not from_server then
			battle_data:setLastSelectFightType(autoFightFlg)
		end
	end
end

ClsShip.tryRunAI = function(self, ai, opportunity, call_back)
	local ai_obj = self.new_ai[ai]
	if not ai_obj then
		self:addAI(ai, {})
		ai_obj = self.new_ai[ai]
	end

	if self.running_ai[ai] then
		self:completeAI(ai_obj)
		ai_obj = self.new_ai[ai]
	end

	if type(call_back) == "function" then
		call_back(ai_obj)
	end

	opportunity = opportunity or AI_OPPORTUNITY.RUN

	return ai_obj:tryRun(opportunity, {})
end

ClsShip.addAIList = function(self, aiList)
	for _, ai_id in ipairs(aiList ) do
		self:addAI(ai_id, {} )
	end
end

local setAIValue
setAIValue = function(self, buffer_id, value)
	local clz = status_map[buffer_id]
	local aiValueObj = clz.new(self, self, 999999, 0, 0, 1)
	aiValueObj.tbResult = {}
	aiValueObj.tbResult.mod_value = value

	local battle_data = getGameData():getBattleDataMt()
	battle_data:uploadAddStatus(aiValueObj)
end

local getAIValue
getAIValue = function(self, buffer_id)
	local aiValueObj = self:hasBuff(buffer_id)
	if not aiValueObj then return 0 end

	local tbResult = aiValueObj.tbResult
	return tbResult.mod_value
end

ClsShip.setAISpeed = function(self, speed)
	setAIValue(self, "ai_speed", speed)
end

ClsShip.getAISpeed = function(self)
	return getAIValue(self, "ai_speed")
end

ClsShip.setAIDefense = function(self, defense)
	setAIValue(self, "ai_defense", defense)
end

ClsShip.getAIDefense = function(self)
	return getAIValue(self, "ai_defense")
end

ClsShip.setAINearAtt = function(self, att)
	setAIValue(self, "ai_near_att", att)
end

ClsShip.getAINearAtt = function(self)
	return getAIValue(self, "ai_near_att")
end

ClsShip.setAIFarAtt = function(self, att)
	setAIValue(self, "ai_far_att", att)
end

ClsShip.getAIFarAtt = function(self)
	return getAIValue(self, "ai_far_att")
end

ClsShip.touchScene = function(self, pos)
	local battle_data = getGameData():getBattleDataMt()

	if not battle_data:isCurClientControlShip(self:getId()) then return end

	if self:hasBuff("tuji_self") then
		alert:battleWarning({msg = skill_warning.STATUS_LIMIT.msg})
		return
	end

	local chaofeng_obj = self:hasBuff("chaofeng")
	if not self.target or self.target.isDeaded then
		if chaofeng_obj then
			chaofeng_obj:del()
			chaofeng_obj = nil
		end
	end

	if chaofeng_obj then
		alert:battleWarning({msg = skill_warning.CHAOFENG.msg})
		return
	end

	self:setAutoFight(false)

	if self.lock_move then return end

	self:moveTo(pos, FV_MOVE_USER_ORDER)
end

ClsShip.getWalkId = function(self)
	return self.walk
end

local targetOKCondition
targetOKCondition = function(self, target)
	-- 目标不存在，目标不OK
	if not target then return false end
	-- 目标死亡不OK
	if target.isDeaded then return false end

	local selfTeamId = self:getTeamId()
	local targetTeamId = target:getTeamId()

	-- 目标跟自己一个阵营，目标不OK
	if ( selfTeamId == targetTeamId ) then return false end
	-- 目标中立，不OK
	if ( targetTeamId == battle_config.neutral_team_id) then return false end
	if ( selfTeamId == battle_config.neutral_team_id) then return false end

	-- 目标距离太远换
	if self:isAutoFighting() then
		if (self:getTargetDistance() > self:getFarRange() ) then
			return false;
		end
	end

	return true
end

ClsShip.searchTarget = function(self, force)
	if self:is_deaded() then return false end

	local battle_data = getGameData():getBattleDataMt()
	local target_ship = battle_data:getShipByGenID(self:getTargetId())
	if self:is_player_team() and target_ship and not target_ship:is_deaded() then
		if not (force and battle_data:isCurClientControlShip(self:getId())) then return false end
	end

	if not force and not self:isAutoFighting() then return false end

	if targetOKCondition(self, self.target) then return false end

	local target = self:getNearestShip()

	if not target then
		self:setTarget(nil)
		return false
	end

	self:changeTarget(target:getId())
	return true
end

-- 往船只上添加特效
ClsShip.addEffect = function(self, id, filename, dx, dy, time, follow_ship)
	-- 保证特效有
	self.effect = self.effect or {}

	local pos = Vector3.new(0, 0, 0)
	local parent = nil
	if follow_ship then
		--pos = Vector3.new(dx, 0, dy)
		pos:set(dx, 0, dy)
		parent = self.body.node
	else
		local trans = self.body.node:getTranslationWorld()
		local pt = gameplayToCocosWorld(trans)
		local retx, rety = pt.x + dx, pt.y + dy
		pos = cocosToGameplayWorld(ccp(retx, rety))
	end
	local particle = SceneEffect.createEffect({file = EFFECT_3D_PATH .. filename .. PARTICLE_3D_EXT, pos = pos, parent = parent})

	self.effect[id] = particle

	if particle then
		particle:GetNode():setTranslation(pos)
		particle:Start()

		if time and (time > 0) then
			particle:SetDuration(time)
		end
	end
end

ClsShip.delEffect = function(self, id)
	if not self.effect then return end
	if not self.effect[id]  then return end

	SceneEffect.ReleaseParticle(self.effect[id])
end

ClsShip.showHitEffect = function(self, id, duration)
	if self:is_deaded() then return end
	
	if not id then return end
	if not self.is_ship and PROP_IGNORE_HIT_EFFECT[id] then return end

	skill_effect_util.scene_particle_effect({id = id, owner = self, duration = duration})
end

ClsShip.isIgnorCollision = function(self)
	return self.ignorCollision or false
end

ClsShip.setIgnorCollision = function(self, bFlg)
	self.ignorCollision = bFlg
end

ClsShip.getBattleTime = function(self)
	return getGameData():getBattleDataMt():getBattleTime()
end

ClsShip.getControlShipTargetID = function(self)
	local battle_data = getGameData():getBattleDataMt()
	return battle_data:getControlShipTargetID(self:getUid())
end

------------------------------------------------------------------------------------------------------------------------

local ANGLE = -10
local UP_VECTOR = Vector3.new(0, 1, 0)

ClsShip.cruise = function(self)
	-- 设置追随目标
	local translation = self.body.node:getTranslationWorld()

	local angle = ANGLE
	local target_vector = GetTwoNodeVector(self.body.node, self.target.body.node)

	local ret = IsPointAtRight(self.body.node, self.target:getPosition3D())
	if not ret then
		angle = - angle
		target_vector = GetTwoNodeVector(self.target.body.node, self.body.node)
	end

	local dir = Vector3.new()
	Vector3.cross(UP_VECTOR, target_vector, dir)
	dir:normalize()

	dir = RotateVector3(UP_VECTOR, angle, dir)

	local r = 300
	
	local move_x = translation:x() + dir:x()*r
	local move_y = translation:y() + dir:y()*r
	local move_z = translation:z() + dir:z()*r
	local move_pos = Vector3.new(move_x, move_y, move_z)

	self:moveTo(move_pos, FV_MOVE_CRUISE)
end

ClsShip.awayFromLand = function(self, forward)
	if not forward then return end

	local battle_data = getGameData():getBattleDataMt()
	local map_layer = battle_data:GetLayer("map_layer")

	local boat_pos = self:getPosition3D()

	local add_angle = 30
	local test_size = 64

	local checkMove
	checkMove = function(angle)
		local forward_vector = RotateVector3(UP_VECTOR, angle, forward)
		forward_vector:scale(test_size)

		local target_vector = Vector3.new()
		Vector3.add(forward_vector, boat_pos, target_vector)

		local cocos_pos = gameplayToCocosWorld(target_vector)

		local ret = map_layer:checkLand(ccp(cocos_pos.x*BATTLE_SCALE_RATE, cocos_pos.y*BATTLE_SCALE_RATE))

		return ret, forward_vector
	end

	local chenck_angle = add_angle
	while chenck_angle < 180 do
		local ret, vec = checkMove(chenck_angle)
		if not ret then
			vec:scale(2)
			vec:add(boat_pos)
			self:moveTo(vec, FV_MOVE_FROM_LAND)
			return
		end

		ret, vec = checkMove(- chenck_angle)
		if not ret then
			vec:scale(2)
			vec:add(boat_pos)
			self:moveTo(vec, FV_MOVE_FROM_LAND)
			return
		end

		chenck_angle = chenck_angle + add_angle
	end
	
	local test_vector = Vector3.new(-forward:x(), 0, -forward:z())
	test_vector:scale(test_size*2)
	test_vector:add(boat_pos)
	self:moveTo(test_vector, FV_MOVE_FROM_LAND)
end

------------------------------------------------------------------------------------------------------------------------

ClsShip.translateAnimation = function(self, target, distance)
	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:isUpdateShip(self:getId()) then return end

	if tolua.isnull(target.body.node) or tolua.isnull(self.body.node) then return end

	local vec = GetVectorBetween(target.body.node, self.body.node, true)
	vec:scale(distance)
	
	local pos = target:getPosition3D()

	if not pos then return end

	local endposx = pos:x() + vec:x()
	local endposz = pos:z() + vec:z()
	endposx, endposz = skill_effect_util.checkBoundPos(endposx, endposz)

	endposx, endposz = skill_effect_util.checkLandPos(pos, vec, distance, endposx, endposz)

	local x = math.floor(endposx*FIGHT_SCALE + 0.5)
	local z = math.floor(endposz*FIGHT_SCALE + 0.5)

	battleRecording:recordVarArgs("translate_animation", target:getId(), x, z)

	local keyValues = {pos:x(), pos:y(), pos:z(), x/FIGHT_SCALE, pos:y() + vec:y(), z/FIGHT_SCALE}

	skill_effect_util.translateAnimation(target, keyValues)
end

ClsShip.fenshen = function(self, params)
	if not self or self:is_deaded() then return end

	if not getGameData():getBattleDataMt():isUpdateShip(self:getId()) then return end

	local id = self:getId()
	local duration = params.duration or 1
	local strength = params.fenshen_strength or 0.75
	local skills = {params.fenshen_skill_1, params.fenshen_skill_2}
	local cnt = params.fenshen_cnt
	local ship_id = params.fenshen_ship_id

	local genShipId
	genShipId = function(ship_id)
		if ship_id == -1 then
			local all_id = {3, 5, 6, 12}
			local idx = math.random(4)
			return all_id[idx] 
		end
		-- 默认返回3
		return ship_id
	end

	local forward_self = self:getPosition3D()

	local target = self:getTarget()
	local forward_enemy = Vector3.new()
	if target and target.body and target.body.node then
		forward_enemy = target:getPosition3D()
	end

	local distance = 200

	local forward_des = Vector3.new()
	Vector3.subtract(forward_enemy, forward_self, forward_des)
	forward_des:normalize()
	forward_des:scale(distance)

	local x, z = skill_effect_util.checkLandPos(forward_self, forward_des, distance)

	local x = math.floor(x*FIGHT_SCALE + 0.5)
	local z = math.floor(z*FIGHT_SCALE + 0.5)

	battleRecording:recordVarArgs("battle_fenshen", id, duration, strength, skills, cnt, genShipId(ship_id), nil, x, z)
end

------------------------------------------------------------------------------------------------------------------------

return ClsShip

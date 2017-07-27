
--local sail_info=require("game_config/skill/sail_info")
local news=require("game_config/news")
local tool=require("module/dataHandle/dataTools")
local skill_info=require("game_config/skill/skill_info")
local sailorCfgInfo = require("game_config/sailor/sailor_info")
local voice_info=getLangVoiceInfo()
local baoWuCfg = require("game_config/collect/baozang_info")
local Alert = require("ui/tools/alert")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")

local dialog = require("ui/dialogLayer")


local SailorData = class("SailorData")


local TYPE_NEW_SAILOR = 1  ---新的水手
local TYPE_OWNED_SAILOR = 3 --重复的水手

local SHOW_OWNED_ONE = 1  -- 显示一个重复的水手
local SHOW_FIVE = 2  --显示5个可能重复水手

local HONOUR_RECRUIT = 1 --荣誉招募
local KEEPSAKE_RECRUIT = 2 --信物招募

function SailorData:ctor()
	self.lockSailorId = nil

	self.oldOwnSailors = {} --某个操作前的数据（目前只有招募用）
	self.ownSailors = {}     --玩家水手列表 int table
	self.sailorCount = 0    --玩家的水手数量

	self.recruitId = nil
	self.skillImprove = {} -- 水手技能提升,格式： {[sailorId] = {[skillId] = skillValue}}

	self.honourRecruitSailor = {}

	self.dataBeforeReward = {} --公会任务领奖保存水手数据（目前只有公会任务用）

	self.sailor_job_data = {} -- 水手任命岗位数据，服务端通知维护
	self.room_sailor_skills = {} --激活的水手技能
	self.sailor_upLeve_seque = {} --升级下发执行特效队列
	self.recruitSailorInfo = {}   ----招募到的航海士信息
	self.fullStarReward = {}    ----招募满星航海士的奖励
	self.recruit_sailor_reward = {} ---招募航海士奖励星章
	self.awaken_times = 0 ---觉醒次数

	self.explore_sailor_up_level = true
	self.first_a_sailor = 0 

	self.limit_activity_info = {}  ---招募限时活动信息
end

function SailorData:setLimitActivityInfo(info)
	self.limit_activity_info = info 
end

function SailorData:getLimitActivityInfo( )
	return self.limit_activity_info
end

function SailorData:isLimitActivityStatus()
	if not self.limit_activity_info then return false end
	if not self.limit_activity_info.times then return false end 

	if self.limit_activity_info.remainTime <= 0 then
		return false
	end

	if self.limit_activity_info.times <= 0 then
		return false
	end

	return true
end

---距离后动结束15分钟
function SailorData:isLimitActivityWillStop()
	if not self.limit_activity_info then return false,0 end
	if not self.limit_activity_info.remainTime then return false,0 end
	if self.limit_activity_info.remainTime < 15*60 then
		return true, self.limit_activity_info.remainTime
	end
end


function SailorData:setFirstASailor(id)
	self.first_a_sailor = id 
end

function SailorData:getFirstASailor()
	return self.first_a_sailor 
end

function SailorData:clearFirstASailor()
	self.first_a_sailor = 0
end

function SailorData:isFristASailor()
--device.platform == "ios" and
	if device.platform == "ios" and self.first_a_sailor ~= 0 then
		return true
	end
	return false	
end

function SailorData:getExploreSailorUpLevel()
	return self.explore_sailor_up_level
end

function SailorData:setExploreSailorUpLevel(enable)
	self.explore_sailor_up_level = enable
end

----水手觉醒次数
function SailorData:setAwakenTimes(times)
	self.awaken_times = times
end

function SailorData:getAwakenTimes()
	return self.awaken_times
end

function SailorData:saveDataBeforReward(sailorIds)
	for k, v in pairs(sailorIds) do
		local sailor = table.clone(self.ownSailors[v])
		self.dataBeforeReward[v] = sailor
	end
end

function SailorData:getDataBeforeReward(sailorId)
	return self.dataBeforeReward[sailorId]
end

--使用后清除数据
function SailorData:clearDataAfterReward(sailorId)
	if self.dataBeforeReward[sailorId] then
		self.dataBeforeReward[sailorId] = {}
	end
end

function SailorData:askLimitRecruitActivity()
	GameUtil.callRpc("rpc_server_enlist_time_limit_huodong",{})
end


--单独的航海士升阶升星
function SailorData:askForUpStep(sailorId)
	GameUtil.callRpc("rpc_server_sailor_upstar",{sailorId})
end

function SailorData:upStepNewSailor(sailorId)
	GameUtil.callRpc("rpc_server_sailor_upstep",{sailorId}, "rpc_client_sailor_upstep")
end

----获取已经有过的航海士
function SailorData:askHasOwnSailorList()
	-- GameUtil.callRpc("rpc_server_user_get_usable_sailor_icon_list",{}, "rpc_client_user_get_usable_sailor_icon_list")
end

----航海士设置宝物装备
function SailorData:setSailorBaoWu(sailorId,posId,equipId)
	GameUtil.callRpc("rpc_server_sailor_set_baowu",{sailorId,posId,equipId}, "rpc_client_sailor_set_baowu")
end

-----航海士替换装备
function SailorData:changeSailorBaoWu(sailorId,posId,equikId)
	GameUtil.callRpc("rpc_server_sailor_change_baowu",{sailorId,posId,equikId},"rpc_client_sailor_change_baowu")
end


---招募航海士免费协议
function SailorData:getSailorFreeRecruitInfo()
	 GameUtil.callRpc("rpc_server_sailor_enlist_free_info", {}, "rpc_client_sailor_enlist_free_info")
end

---朗姆酒招募
function SailorData:sailorHonourRecruit()
	GameUtil.callRpc("rpc_server_sailor_honour_enlist", {}, "rpc_client_sailor_honour_enlist")
end

---钻石招募
function SailorData:sailorDiamondRecruit()
	GameUtil.callRpc("rpc_server_sailor_gold_enlist", {}, "rpc_client_sailor_gold_enlist")	
end

---水手觉醒
function SailorData:askSailorAwaken(sailor_id,is_diamoud)
	GameUtil.callRpc("rpc_server_sailor_awake", {sailor_id, is_diamoud})	
end

---领取招募限时活动奖励
function SailorData:askLimitRecruitRewards(id)
	GameUtil.callRpc("rpc_server_gold_enlist_limit_huodong_reward", {id})	
end

--限时招募信息
function SailorData:setLimitRewardInfo(info)
	self.limit_reward_info = info 
end

function SailorData:getLimitRewardInfo(  )
	return self.limit_reward_info
end

function SailorData:getLimitRewardTimes()
	local times = 0 
	if not self.limit_reward_info then return times end 
	--table.print(self.limit_reward_info)
	table.sort(self.limit_reward_info, function (a,b)
		return a.id < b.id
	end)

	for k,v in ipairs(self.limit_reward_info) do
		if v.status == 0 then
			times = v.id
			return times
		end
	end
	return times
end



--之前招募用过，待检查后删除
function SailorData:saveOldSailors()
	self.oldOwnSailors = table.clone(self.ownSailors)
end


--获取状态为NULL的水手
function SailorData:getFreeSailors()
	local sailors = {}
    for sailorId, sailor in pairs(self.ownSailors) do
        if sailor.status == STATUS_NULL then
            table.insert(sailors, sailor)
        end
    end
    return sailors
end

function SailorData:getSailorNotJob(jobs)
	local sailors = {}
	for sailorId, sailor in pairs(self.ownSailors) do
		local find = false
    	for k, v in pairs(jobs) do
    		if sailor.job[1] == v then
    			find = true
    			break
    		end
    	end

		if sailor.status == STATUS_NULL and not find then
            table.insert(sailors, sailor)
        end
	end

	return sailors
end


function SailorData:getCanAwakeSailor()
	local sailors = {}
	for sailorId, sailor in pairs(self.ownSailors) do
		if sailor.star == 6 then
            table.insert(sailors, sailor)
        end
	end
	return sailors
end

--根据职业获取状态为NULL,并且符合在情报屋任务中的水手
function SailorData:getSailorsByJob(job, appointSailorIds)
	local sailors = {}
    for sailorId, sailor in pairs(self.ownSailors) do
    	local find = false
    	for k, v in pairs(appointSailorIds) do
    		if sailor.id == v then
    			find = true
    			break
    		end
    	end

        if sailor.job[1] == job and (sailor.status == STATUS_NULL or find)then
            table.insert(sailors, sailor)
        end    
    end
    return sailors
end

function SailorData:hasOwned(sailorId)
	local ownSailors = self:getOwnSailors()
	if ownSailors[sailorId] then
		return true
	end
	return false
end

--[[
--Receive the sailor id and look up the details in sailor_info
--rType: 1 - one sailor, 2 - five sailors
 62 class sailorAttrs {
 63     int sailorId;
 64     int step;
 65     int star;
 66     int sailorAttrs;
 67 }
]]
function SailorData:receiveSailors(rType, sailorAttrs)
	local running_scene = GameUtil.getRunningScene()
	if tolua.isnull(running_scene) then
		return
	end

	if rType == 1 then
		if type(sailorAttrs[1]) ~= "table" then return end
		local sailor = self.ownSailors[sailorAttrs[1].sailorId]
		sailor.step = sailorAttrs[1].step
		sailor.starLevel = sailorAttrs[1].star
		self.honourRecruitSailor[1] = {["sailor"] = sailor, ["reward"] = sailorAttrs[1].reward}
		
		if getUIManager():isLive("clsSailorRecruit") then
			return 
		end

		local loginVipAwardUI = getUIManager():get("MainAwardUI") --如果是在登陆界面就先暂时不显示
		if not tolua.isnull(loginVipAwardUI) then
			loginVipAwardUI.sailorAwardData[sailorAttrs[1].sailorId] = sailorAttrs[1].sailorId
			return
		end

		----海神奖励处理
		local sailor_id = getGameData():getActivityData():getSeagodRewardId()
		if not sailor_id then
			getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {}, sailorAttrs[1].sailorId)
		end
	end
	self.honourRecruitSailor = {}

end

----招募到航海士的信息
function SailorData:setRecruitSailorInfo(rewards)
	self.recruitSailorInfo = rewards
end

function SailorData:getRecruitSailorInfo()
	return self.recruitSailorInfo
end
---满星航海士的奖励
function SailorData:setFullStarReward(rewards,id)
	self.fullStarReward[id] = rewards 
end
function SailorData:getFullStarReward()
	return self.fullStarReward
end

function SailorData:clearFullStarReward()
	self.fullStarReward = {}
end

---满星航海士删除
function SailorData:delFullStarSailor(sailorId)
	self.fullStarReward[sailorId] = nil 
end


---招募航海士奖励星章
function SailorData:setRecruitSailorReward(rewards, id)
	self.recruit_sailor_reward[id] = rewards 
end

function SailorData:getRecruitSailorReward()
	return self.recruit_sailor_reward
end

function SailorData:clearRecruitSailorReward()
	self.recruit_sailor_reward = {}
end

function SailorData:delRecruitSailorReward(sailorId)
	self.recruit_sailor_reward[sailorId] = nil 
end




function SailorData:getSailorBaseById(id)
	return sailorCfgInfo[id]
end

function SailorData:askRecruitSailor(portId,sailorId)
	self.recruitId = sailorId
	GameUtil.callRpc("rpc_server_sailor_buy", {portId, self.recruitId},"rpc_client_sailor_buy")
end

function SailorData:receiveRecruitSailorResult(result,err)
	if result==1 then
		local sailor = tool:getSailor(self.recruitId)
		if sailor then
			if sailor.sex==SEX_F then
				audioExt.playEffect(voice_info["VOICE_PLOT_1008"].res,false)
			else
				audioExt.playEffect(voice_info["VOICE_PLOT_1006"].res,false)
			end
		end
	end
end

--接收拥有水手的ID
function SailorData:receiveOwnSailors(list)
	self.ownSailors={}
	self.sailorCount=#list
	for i=1,self.sailorCount do
		self.ownSailors[list[i]] = tool:getSailor(list[i])
	end
end

---拥有过的航海士信息
function SailorData:setHasOwnSailr(list)
	self.hasOwnSailr = {}
	self.sailorCount=#list
	for i=1,self.sailorCount do
		self.hasOwnSailr[list[i]] = tool:getSailor(list[i])
	end	
end

function SailorData:getHasOwnSailr()
	return self.hasOwnSailr
end

function SailorData:isHadSailor(sailor_id) --曾经拥有过的和现在拥有的
	return self.hasOwnSailr[sailor_id] and true or false
end

function SailorData:addOwnSailor(sailorId)

	local sailor = tool:getSailor(sailorId)
	if sailorId == self.recruitId then
		Alert:warning({msg = string.format(news.SAILOR_RECRUIT_RESULT.msg,sailor.name), size = 26})
	end
	if not self.ownSailors then self.ownSailors={} end
	local sailor=tool:getSailor(sailorId)
	if not sailor then 
		cclog(T("找不到相应的水手"))
		return
	end
    self.sailorCount=self.sailorCount+1
	self.ownSailors[sailorId]=sailor
end

function SailorData:delOwnSailor(sailorId)
	self.ownSailors[sailorId] = nil
	--table.remove(self.self.ownSailors, 20)
end

function SailorData:getSailorCount()
   	return self.sailorCount
end

function SailorData:refressSkillLevel(skillId,skillLevel)
	for k,sailor in pairs(self.ownSailors) do
		for key,value in pairs(sailor.skills) do
			if value.id==skillId then
				value.level=skillLevel
			end
		end
	end
end

function SailorData:getOwnSailors()
	return self.ownSailors
end

function SailorData:getOwnSailorsById( sailorId )
	return self.ownSailors[sailorId]
end

function SailorData:isHaveSailor(sailorId)
	return self.ownSailors[sailorId] and true or false
end

function SailorData:getSailorActiveSkills(sailorId)
	local firstSkill = 0
	local firstSkillLevel = 0
	local secondSkill = 0
	local secondSkillLevel = 0
	local ringSkill = 0
	local ringSkillLevel = 0


	for k, skill in pairs(self.ownSailors[sailorId].skills) do
		if skill.id == 1001 then
			firstSkill = 1001
			firstSkillLevel = math.floor(skill.level + 0.5)
		end

		if skill_info[skill.id]["initiative"] == 1 then
			secondSkill = skill.id
			secondSkillLevel = math.floor(skill.level + 0.5)
			if firstSkill~=0 then break end
		end

		if skill_info[skill.id]["initiative"] == 2 then
			ringSkill = skill.id
			ringSkillLevel = math.floor(skill.level + 0.5)
			-- if secondSkill ~= 0 then break end
		end
	end

	return firstSkill, firstSkillLevel, secondSkill ,secondSkillLevel, ringSkill, ringSkillLevel
end

function SailorData:getSailorSail(sailorId)
	local sailor = self.ownSailors[sailorId]
	if  sailor then
		return sailor.sail
	end
end

--弃用，以后别用
function SailorData:getArenaCfSailorSail(sailorInfo)
	return sailorInfo.sail
end

--我们要知道info中保存的是水手特有的一些信息，基本的信息通过Id从sailor_info表中获得
function SailorData:receiveSailorInfo(info)
	local id = info.id
	local sailor = self.ownSailors[id]
	if not sailor then 
		self:addOwnSailor(id)
		sailor = self.ownSailors[id]
	end
	sailor.memoirChapter = info.memoirChapter
	sailor.memoirStatus = info.memoirStatus
	sailor.memoirDoneChapter = info.memoirDoneChapter

	if info.memoirDoneChapter and info.memoirDoneChapter ~= 0 and info.memoirDoneChapter > sailor.memoirChapter then
		sailor.memoirChapter = info.memoirDoneChapter
		sailor.memoirStatus = 2
	end

	sailor.id = info.id
	sailor.level = info.level
	sailor.exp = info.exp
	sailor.status=info.status
	sailor.starLevel = info.star --星级注意，这个和sailor_info 表中star有区别-是指航海士重复招募后的状态
	sailor.curStars = info.curStars
	sailor.power = info.power
	sailor.star = info.quality  ---星阶

	sailor.skills = info.skills
	sailor.attrs = info.attrs
	sailor.aptitudes = info.aptitudes --水手的资质
	

	-----招募相关的 没敢删除
	if sailor.id == self.recruitId then
		recruitId = nil
	end

	self:setSailorStatus(sailor.id,sailor.status)
end

function SailorData:setSailorStatus(sailorId,status) --STATUS_NULL STATUS_APPOINT STATUS_LEARN STATUS_CAPTAIN
	if not self.ownSailors[sailorId] then return end
	if status then
		self.ownSailors[sailorId].status=status
	else
		self.ownSailors[sailorId].status=STATUS_NULL
	end
end

function SailorData:getSailorStatus(sailorId)
	if self.ownSailors[sailorId] then
		return self.ownSailors[sailorId].status
	end
end

function SailorData:getShowSkills(skills_,sailor)
	local skills={}
	for k,skill in pairs(skills_) do
		if skill_info[skill.id] then
			local keyStr=string.sub(skill_info[skill.id].site,1,2)
			if not skills[keyStr] then skills[keyStr]=tool:getSkillSite(keyStr) end
			skills[keyStr][skill.id].level=skill.level
		end
	end
	--航海术等级
	if sailor then
		skills["aa"][1001].maxLevel=sailor.maxSkill
	end
	return skills
end

-- 获取水手拥有的技能
-- 格式:{[skill_id] = skill_level}
function SailorData:getSailorSkills(sailorId)
	local skills = {}
	if sailorId then
		if self.ownSailors[sailorId] and self.ownSailors[sailorId].skills then
			local skillData = getGameData():getSkillData()
			for k,v in pairs(self.ownSailors[sailorId].skills) do
				local lv = skillData:getSkillLevel(v.id,sailorId)
				skills[v.id] = lv
			end	
		end
	end
	return skills
end

--获取技能等级的数值 和持续时间
function SailorData:getSkillLevelValue(skillId,level)
	local value1,value2=nil
	if skill_info[skillId].value1 then
		value1= skill_info[skillId].value1[level]
	end
	if skill_info[skillId].value2 then
		value2= skill_info[skillId].value2[level]
	end
	return value1,value2
end

function SailorData:getSkillLevelTime(skillId,level)
	if skill_info[skillId].level_time then
		return skill_info[skillId].level_time[level]
	end
end

--战斗外技能的话，需要传入水手id
function SailorData:getSkillDescWithLv(skill_id, lv, sailor_id)
	local skill_item = skill_info[skill_id]
	local desc = {["base_desc"] = "", ["child_desc"] = ""}
	if skill_item.skill_ex_id and (string.len(skill_item.skill_ex_id) > 0) then
		local skill_map = require("game_config/battleSkill/skill_map")
		local ClsSkill = skill_map[skill_item.skill_ex_id]
		if ClsSkill then
			desc.base_desc = ClsSkill:get_skill_desc(skill_item, lv)
		end
	else
		local skill_str = "sk"..skill_id
		local other_skill_map = require("game_config/otherSkill/other_skill_map")
		local ClsSkill = other_skill_map[skill_str]
		local sailor_item = sailorCfgInfo[sailor_id]
		if ClsSkill then
			desc = ClsSkill:get_skill_desc(skill_item, sailor_item, lv)
		end
	end
	return desc
end

function SailorData:getColorSkillDescWithLv(skill_id, lv, sailor_id)
	local skill_item = skill_info[skill_id]
	local desc = {["base_desc"] = "", ["child_desc"] = ""}
	if skill_item.skill_ex_id and (string.len(skill_item.skill_ex_id) > 0) then
		local skill_map = require("game_config/battleSkill/skill_map")
		local ClsSkill = skill_map[skill_item.skill_ex_id]
		if ClsSkill then
			desc.base_desc = ClsSkill:get_skill_color_desc(skill_item, lv)
		end
	else
		local skill_str = "sk"..skill_id
		local other_skill_map = require("game_config/otherSkill/other_skill_map")
		local ClsSkill = other_skill_map[skill_str]
		local sailor_item = sailorCfgInfo[sailor_id]
		if ClsSkill then
			desc = ClsSkill:get_skill_color_desc(skill_item, sailor_item, lv)
		end
	end
	return desc
end


function SailorData:getSkillShortDesc(skill_id)
	local skill_item = skill_info[skill_id]
	local desc = ""
	if skill_item.skill_ex_id and (string.len(skill_item.skill_ex_id) > 0) then
		local skill_map = require("game_config/battleSkill/skill_map")
		local ClsSkill = skill_map[skill_item.skill_ex_id]
		if ClsSkill then
			desc = ClsSkill:get_skill_short_desc()
		end
	else
		local skill_str = "sk"..skill_id
		local other_skill_map = require("game_config/otherSkill/other_skill_map")
		local ClsSkill = other_skill_map[skill_str]
		local sailor_item = sailorCfgInfo[sailor_id]
		if ClsSkill then
			desc = ClsSkill:get_skill_short_desc()
		end
	end
	return desc
end

--获取从父技能和子技能中获取可用的描述（子技能有拿子技能，子技能没有拿父技能）
function SailorData:getChildDesOrBaseDesc(desc_tab)
    if desc_tab.child_desc and (string.len(desc_tab.child_desc) < 1) then
        return desc_tab.base_desc
    end
    return desc_tab.child_desc
end

function SailorData:getSkillCDTime(skillId)
	return skill_info[skillId].cd_time
end

function SailorData:setCfgBattleSailors(cfgBattleSailorList)
	self.cfgBattleSailors = cfgBattleSailorList
	if self.cfgBattleSailors~=nil then
		self.cfgBattleSailors.isCfgSailor = true
	end
end

function SailorData:setSaveSailorDatas(sailor)
	if sailor then
		self.saveSailorData = {level = sailor.level, exp = sailor.exp, id = sailor.id, attrs = sailor.attrs}
	else
		self.saveSailorData = nil
	end
end

function SailorData:getSaveSailorDatas()
	return self.saveSailorData
end

-- 组装发送往服务端的水手设置结果数据
function SailorData:mkMkBattleSailorServerPack()
	local serverPack = {}
	for i = 1, #self.battleSailors, 1 do
		local sailorId = self.battleSailors[i]
		if sailorId then
			serverPack[#serverPack + 1] = {pos = i, sailorId = sailorId}
		end
	end

	return serverPack
end

--通过水手Id获得装备了的宝物id集
function SailorData:getBattleSailorEquip(sailorId)
	if sailorId == nil then return {} end
	local sailor = self.ownSailors[sailorId]
	if sailor == nil then return {} end
	return sailor.baowuEquip or {}
end

--通过水手Id获得装备了的宝物key集
function SailorData:getBattleSailorEquipKey(sailorId)
	if sailorId == nil then return {} end
	local sailor = self.ownSailors[sailorId]
	if sailor == nil then return {} end
	return sailor.baowuEquipKey or {}
end


--哪件宝物由哪个水手装配的表
function SailorData:getSailorEquipMap()
	local equipMap = {}
	for i, sailor in pairs(self.ownSailors) do
		if sailor and sailor.baowuEquip then
			for pos, eId in pairs(sailor.baowuEquip) do
				if eId > 0 then
					equipMap[eId] = sailor
				end
			end
		end
	end
	return equipMap
end

--得到水手装备表(key，水手为v)
function SailorData:getSailorEquipMapKey()
	local equipMap = {}
	for i, sailor in pairs(self.ownSailors) do
		if sailor and sailor.baowuEquipKey then
			for pos, eId in pairs(sailor.baowuEquipKey) do
				equipMap[eId] = sailor
			end
		end
	end
	return equipMap
end

--[[
This is so fucking.
]]
--卸载装备
function SailorData:unEquipByEquipId(equipId)
	for i, sailor in pairs(self.ownSailors) do
		if sailor and sailor.baowuEquip then
			for pos, eId in pairs(sailor.baowuEquip) do
				if equipId == eId then
					sailor.baowuEquip[pos] = 0
					return
				end
			end
		end
	end
end

function SailorData:getRpcBattleSailorEquip(sailorId)
	local rpcSailorEqArray = {}
	for pos, eqId in pairs(self.ownSailors[sailorId].baowuEquip) do
		if eqId then rpcSailorEqArray[#rpcSailorEqArray + 1] = eqId end
	end

	return rpcSailorEqArray
end

function SailorData:setEnemySailors(sailorsList)
	for i, v in ipairs(sailorsList) do
		local sailorId = v.id
		local sailorCfg = sailorCfgInfo[sailorId]
		v.star = sailorCfg.star
		if v.level == nil then v.level = 1 end
	end

	local battleSailors = {}
	for k,v in ipairs(sailorsList) do
		if v.pos~=nil and v.pos~=0 then
			battleSailors[#battleSailors+1] = v
		end
	end

	local function sortSailor(a,b)
		return a.pos < b.pos
	end

	table.sort(battleSailors,sortSailor)

	self.enemySailors = battleSailors
end

function SailorData:setNpcBattleSailors(npcBattleSailorList)
	self.enemyNpcSailors = npcBattleSailorList
end

--[[
class fight_sailor_t {
int id;
int room;
int baowu;
int pos;
fight_skill_t* skills;
}
]]
-- fakeData 的存在，是便于开发初期，制作自我调试数据用，现在它只是一个安全参数，
-- 免于对外部调用添加繁琐的过滤行为。
function SailorData:getEnemySailors()
	local fakeData = {}

	return self.enemyNpcSailors or self.enemySailors or fakeData
end

-- 水手装备书籍后的技能提升
function SailorData:improveSailorSkill(sailorId, skillId, skillValue)
	if self.skillImprove[sailorId] == nil then self.skillImprove[sailorId] = {} end
	if skillValue == 0 then
		self.skillImprove[sailorId][skillId] = nil
	else
		self.skillImprove[sailorId][skillId] = skillValue
	end

end

function SailorData:getSkillImprove(sailorId, skill_id)
	local improve_lv = 0
	local sailor_skill_improve = self.skillImprove[tonumber(sailorId)]
	if sailor_skill_improve then 
		improve_lv = sailor_skill_improve[tostring(skill_id)] or 0
	end
	return improve_lv
end
--local MISSION_STATUS_DOING = 1

function SailorData:getSailorMissionState(sailor)
	sailor.missionState=1   --默认可以招募
	local missionDataHandler = getGameData():getMissionData()
	--1可招募》2可谈话（可接任务）》3 已接任务
	if sailor.mission_name and #sailor.mission_name > 0 then
		sailor.missionState=2
		local begin_mission = sailor.mission_name[1]
		local end_mission = nil
		local length = #sailor.mission_name
		if length > 1 then
			end_mission = sailor.mission_name[length]
		end

		local playerMissionTable = missionDataHandler:getPlayerMissionInfo()		--所有服务端下发的任务
		local missionTable = missionDataHandler:getCompleteMissionInfo()	

		if begin_mission then
			for k, v in pairs(playerMissionTable) do
				if v.name == begin_mission then
					sailor.missionState=3
                    --print("v.status  ----->",v.status,"v.name",v.name,"MISSION_STATUS_DOING",MISSION_STATUS_DOING,"end_mission",end_mission)
					if v.status ~= MISSION_STATUS_DOING then
						if end_mission==nil then
							sailor.missionState=1 --可招募
						else
							if v.name == end_mission then
								sailor.missionState=1 --可招募
							end
						end
					end
					break
				end
			end
		end
	end
	return sailor.missionState
end

function SailorData:isBaowuEquiped(id)
	for _, sailor in pairs(self.ownSailors) do
		for _, baowuid in pairs(sailor.baowuEquip) do
			if baowuid == id then 
				return true
			end
		end
	end
	return false
end

function SailorData:filterSailors(tab)

	local sailors = {}
	local otherSailors = {}	
    for sailorId, sailor in pairs(self.ownSailors) do
    	if tab[sailor.job[1]] then
    		table.insert(sailors, sailor)  
    	else
    		table.insert(otherSailors,sailor)
    	end
    	  
    end
    return sailors,otherSailors
end

function SailorData:selectStorySailor(tab)
	local sailor_list = {}
	if tab then
		sailor_list = tab
	else
		sailor_list = self.ownSailors
	end
	 
	local sailors = {}
	local otherSailors = {}
	for sailorId, sailor in pairs(sailor_list) do
		local sailor_mission = info_sailor_mission[sailor.id] -- 判断水手是否有传记任务  
		if sailor_mission then
			table.insert(sailors, sailor)
		else
			table.insert(otherSailors,sailor)
		end  	  
	end
	return sailors,otherSailors		
end

function SailorData:selectSailor(types)
	local sailors = {}
	for k,v in pairs(self.ownSailors) do
		if v.job[1] == types then
			table.insert(sailors,v)
		end
	end
	return sailors
end

function SailorData:saveFireSailorId(sailor_id)
	self.fire_sailor_Id = sailor_id
end

function SailorData:getFireSailorId(sailor_id)
	return self.fire_sailor_Id
end

function SailorData:getAppointSex(sailor_id)
	local sailor_info = self.ownSailors[sailor_id]
	if sailor_info then 
		return sailor_info.sex 
	end
end

-- 设置水手任命职位数据
-- class job_room_t {
--     int job;
--     int sailorId;
-- }
function SailorData:setSailorJobData(job_list)
	self.sailor_job_data = {}
	for k,v in pairs(job_list) do
		self.sailor_job_data[v.job] = v.sailorId
	end
end

function SailorData:getCaptain()   --大副
	if self.sailor_job_data then 
		return self.sailor_job_data[KIND_CAPTAIN] 
	end
end

function SailorData:getRoomSailor(job)   --获取职位对应的水手
	if self.sailor_job_data then 
		return self.sailor_job_data[job] 
	end
end

function SailorData:getKindExpore() --瞭望手
	return self:getRoomSailor(KIND_EXPORE)
end

function SailorData:getKindGun() --火炮手
	return self:getRoomSailor(KIND_GUN)
end

function SailorData:getKindSailor() --水手长
	return self:getRoomSailor(KIND_SAILOR)
end

function SailorData:getKindControl() --操控师
	return self:getRoomSailor(KIND_CONTROL)
end

function SailorData:setRoomSailorsSkill(skills_tab)
	self.room_sailor_skills = skills_tab
    local active_skill_ids = {}
    --分开写，防止遍历出错
    for k, v in pairs(self.room_sailor_skills) do
        active_skill_ids[#active_skill_ids + 1] = k
    end
    for k, v in ipairs(active_skill_ids) do
        if skill_info[v] then
            local main_skill_id_str = skill_info[v].main_skill_id
            if main_skill_id_str and string.len(main_skill_id_str) > 0 then
                local main_skill_id = tonumber(main_skill_id_str)
                if main_skill_id ~= v and (not self.room_sailor_skills[main_skill_id]) then
                    self.room_sailor_skills[main_skill_id] = table.clone(self.room_sailor_skills[v])
                    self.room_sailor_skills[main_skill_id].add_child_skill_id = v
                end
            end
        end
    end
end

function SailorData:getRoomSailorsSkill()   --获取激活水手的技能
	return self.room_sailor_skills
end

--开启水手传记
function SailorData:openSailorTask(sailor_id)
	GameUtil.callRpc("rpc_server_memoir_mission_open", {sailor_id},"rpc_client_memoir_mission_open")
end

--放弃水手任务
function SailorData:cancelSailorMission(sailor_id, mission_id)
	GameUtil.callRpc("rpc_server_memoir_mission_cancel", {sailor_id, mission_id},"rpc_client_memoir_mission_cancel")
end

function SailorData:setOpenSailorTaskTips(sailor)
	self.sailor_task_is_open = sailor
end

function SailorData:getUpLevelSeque()
	if not self.sailor_upLeve_seque then
		self.sailor_upLeve_seque = {}
	end
	return self.sailor_upLeve_seque
end

function SailorData:pushUpLevelSeque(data)
	table.insert(self.sailor_upLeve_seque, data)
end

function SailorData:popUpLevelSeque()
	local data = nil
	if self.sailor_upLeve_seque and self.sailor_upLeve_seque[1] then
		data = self.sailor_upLeve_seque[1]
		table.remove(self.sailor_upLeve_seque, 1)
	end
	return data
end

function SailorData:clearUpLevelSeque()
	self.sailor_upLeve_seque = {}
end

function SailorData:saveSailorTaskID(sailor_id)
	self.sailor_task_id = sailor_id
end

function SailorData:getSailorTaskID()
	return self.sailor_task_id
end

function SailorData:setSailorMissionReward(reward)
	self.sailor_mission_reward = reward
end

function SailorData:getSailorMissionReward()
	return self.sailor_mission_reward
end

--水手每分钟获得投资经验
function SailorData:getSailorExpStep(sailor_id)
	local sailor = self.ownSailors[sailor_id]
	local exp_step = 0
	if sailor then
		exp_step = math.floor(math.pow(2, sailor.star - 1) * 10 * math.pow(1.04, sailor.level))
	end
	return exp_step
end

return SailorData
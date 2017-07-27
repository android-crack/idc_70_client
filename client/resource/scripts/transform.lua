--表转化文件
require("module/gameBases")
require("transfrom/tableTrans")
--require("transfrom/tech_description")
-- require("transfrom/explore_event")
-- require("transfrom/explore_skill")
-- require("transfrom/achievement_info")
-- require("transfrom/chongzhi_reward")
-- require("transfrom/xunbao_info")
-- require("transfrom/tech_description")
-- require("transfrom/explore_event")
-- require("transfrom/explore_skill")
-- require("transfrom/achievement_info")
-- require("transfrom/chongzhi_reward")
-- require("transfrom/xunbao_info")

-- local transformUtil = require("module/transformUtil")
-- local port_path_info=require("transfrom/port_path_info")
-- local build_info=require("transfrom/build_info")
-- local sailor_job =require("transfrom/sailor_job")
-- local tutor_info=require("transfrom/tutor_info")
-- local role_info=require("transfrom/role_info")
-- local equip_info = require("transfrom/equip_info")
-- local equip_upgrade_info = require("transfrom/equip_upgrade_info")
-- local skill_info=require("transfrom/skill_info")
-- -- local shop_info=require("transfrom/shop_info")

-- local small_people_info =require("scripts/game_config/port/small_people_info")
-- local area_info =require("transfrom/area_info")
-- local port_info=require("transfrom/port_info")
-- local item_info=require("transfrom/item_info")
-- local goods_info=require("transfrom/goods_info")
-- local goods_type_info=require("transfrom/goods_type_info")
-- local achievement_info = require("transfrom/achievement_info")

-- local battle_type_info = require("transfrom/battle_type_info")
-- local relic_info = require("transfrom/relic_info")
-- local landReward=require("transfrom/login_reward")
-- local payReward=require("transfrom/chongzhi_reward")
-- local pirate_info = require("transfrom/pirate_info")
-- local box_data=require("transfrom/box_data")
--local box_reward_data=require("transfrom/box_reward_data")
-- local equip_drawing_info=require("transfrom/equip_drawing_info")
-- local upgrade_info = require("transfrom/upgrade_info")
-- local news = require("transfrom/news")
-- local random_loot_info = require("transfrom/random_loot_info")
-- -- local new_achieve_mission = require("transfrom/new_achieve_mission")
-- local pve_port_info = require("transfrom/pve_port_info")
-- local strongHold_pve_info = require("transfrom/pve_stronghold_info")
-- local area_mission_info = require("transfrom/area_mission_info")
-- local explore_whirlpool = require("transfrom/explore_whirlpool")

local function split(str, pat)
	if type(str) ~='string' then return end
	local t = {}
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

local function merge(dest,src)   --对数组有效
	if type(dest)~="table" or type(src)~="table" then return end

	for k,v in ipairs(src) do
		dest[#dest+1]=v
	end
	return dest
end

local function transToIdForTab(destTab,srcTab,key)
	key=key or 2
	for kDest,vDest in pairs(destTab) do
		local isFind=false
		for kSrc,vSrc in pairs(srcTab)do
			if vDest[key]==vSrc.name then
				vDest[key]=kSrc
				isFind=true
				break
			end
		end
		if not isFind then cclog("找不到相应的"..v[2]) end
	end
end

local function findId(name,srcTab,key)
	--if not srcTab then return name end
	key=key or "name"
	for k,v in pairs(srcTab) do
		if v[key]==name then return k end
	end
	if not name then
		cclog("findId 参数是空")
	else
		cclog("找不到.."..name)
	end
end

local function transEquip()
	local equip_info = require("transfrom/equip_info")
	local equipInfo={}
	local equipOrder={}
	for key,t in pairs(equip_info) do
		local reward = t.reward
		local te = split(reward, ",")
		for i, val in ipairs(te) do
			t1 = split(val, ":")
			if t1[1] == "经验" then
				t["exp"] = t1[2]
			elseif t1[1] == "金币" then
				t["gold"] = t1[2]
			elseif t1[1] == "银币" then
				t["silver"] = t1[2]
			elseif t1[1] == "水手" then
				tmp = string.gsub(t1[2], "\"", "")
				t["seaman"] = tmp
				print(temp)
			elseif t1[1] == "船舶" then
				tmp = string.gsub(t1[2], "\"", "")
				t["boat"] = tmp
			elseif t1[1] == "荣誉" then
				t["royal"] = t1[2]
			else
				assert(false, "transequip找不到对应的数据")
			end

		end
	end
	-- table.save(equip_info,"scripts/game_config/equip/equip_info.lua")
	local equip_kind_info = {}
	for key, val in pairs(equip_info) do
		local kind = val.kind
		local subkind = val.subkind
		local star = val.star
		local id = kind*100 + subkind*10 + star

		equip_kind_info[id] = key
	end
	-- table.save(equip_kind_info,"scripts/game_config/equip/equip_kind_info.lua")
end

local function tranEquipUpgrade()
	local data = {}
	for key, val in ipairs(equip_upgrade_info) do
		local id = val.kind * 100 + val.subkind * 10 +  val.star
		local level = val.level
		local ret = split(val.attribute,",")
		local attribute = {}
		for _, block in ipairs(ret) do
			local ret2 = split(block, ":")
			attribute[ret2[1]] = tonumber(ret2[2])
		end
		--主材料
		local main_material = split(val.main_material, ",")
		table.print(main_material)
		--副材料
		local sub_material = split(val.sub_material, ",")
		table.print(sub_material)
		--阶段一
		local step1attr = split(val.step_1_attr, ",")
		local step_1_attr = {}
		for _, block in ipairs(step1attr) do
			local attr = split(block, ":")
			step_1_attr[attr[1]] = tonumber(attr[2])
		end
		--阶段2
		local step2attr = split(val.step_2_attr, ",")
		local step_2_attr = {}
		for _, block in ipairs(step2attr) do
			local attr = split(block, ":")
			step_2_attr[attr[1]] = tonumber(attr[2])
		end

		--阶段3
		local step3attr = split(val.step_3_attr, ",")
		local step_3_attr = {}
		for _, block in ipairs(step3attr) do
			local attr = split(block, ":")
			step_3_attr[attr[1]] = tonumber(attr[2])
		end

		--阶段4
		local step4attr = split(val.step_4_attr, ",")
		local step_4_attr = {}
		for _, block in ipairs(step4attr) do
			local attr = split(block, ":")
			step_4_attr[attr[1]] = tonumber(attr[2])
		end

		--阶段5
		local step5attr = split(val.step_5_attr, ",")
		local step_5_attr = {}
		for _, block in ipairs(step5attr) do
			local attr = split(block, ":")
			step_5_attr[attr[1]] = tonumber(attr[2])
		end
		--阶段6
		local step6attr = split(val.step_6_attr, ",")
		local step_6_attr = {}
		for _, block in ipairs(step6attr) do
			local attr = split(block, ":")
			step_6_attr[attr[1]] = tonumber(attr[2])
		end	

		val.id = key
		val.attribute = attribute
		val.consume = consume
		val.material =  {}
		val.drawing = {}
		val.main_material = main_material
		val.sub_material = sub_material
		val.step_1_attr = step_1_attr
		val.step_2_attr = step_2_attr
		val.step_3_attr = step_3_attr
		val.step_4_attr = step_4_attr
		val.step_5_attr = step_5_attr
		val.step_6_attr = step_6_attr
	
		if data[id] == nil then data[id] = {} end
		data[id][level] = {}
		data[id][level] = val
	end
	table.save(data, "scripts/game_config/equip/equip_upgrade_info.lua")
end

local function transSailor()
    local sailor_info = require("transfrom/sailor_info")
	local sailorInfo={}
	for k, sailor in pairs(sailor_info) do
		sailor.id=k
		--sailor.topSkill={}
		--		sailor.level=1
		--sailor.sail=getSailLevel(sailor)
		local consume=split(sailor.consume,",")
		if consume[1] then
			local t1=split(consume[1],":")
			sailor.price=tonumber(t1[2])
		end
		if consume[2] then
			local t2=split(consume[2],":")
			sailor.honour=tonumber(t2[2])
		end

		sailor.consume=nil
		local skill=split(sailor.skills,",")
		sailor.skills={}
		for i=1,#skill do
			local t=split(skill[i],":")
			local id=tonumber(t[1])
			local level=1
			-- if id==1001 then
			-- 	level=sailor.sail
			-- end
			sailor.skills[#sailor.skills+1]={id=id,level=level}
		end
		sailorInfo[k]=sailor
	end
	table.save(sailorInfo,"scripts/game_config/sailor/sailor_info.lua")
end

local function transSailorJob()
	local jobToid={}
	--	local idTojob={}
	for k, job in ipairs(sailor_job) do
		jobToid[job.job]=k
		--		idTojob[k]={
		--			job=job.job,
		--			name=job.name,
		--			msg=job.msg,
		--		}
	end
	table.save(jobToid,"scripts/game_config/sailor/job_id.lua")
	table.save(sailor_job,"scripts/game_config/sailor/id_job.lua")
end

local function transSkill()
    local skill_info=require("transfrom/skill_info")
	local skill_site={}
	local site_kind={}
	local skillInfo={}
	for k, skill in pairs(skill_info) do
		local str=string.sub(skill.site,1,2)
		local index=tonumber(string.sub(skill.site,3,3))

		if not skill_site[str] then skill_site[str]={} end
		skill_site[str][k]={site=index,level=0}

		local function tranTab(tab_)
			if not tab_ or #tab_==0 then return end
			local tab=split(tab_,",")
			for k,v in pairs(tab) do
				tab[k]=tonumber(v)
			end
			return tab
		end

		skill.value1=tranTab(skill.value1)
		skill.value2=tranTab(skill.value2)
		skill.level_time=tranTab(skill.level_time)
		skill.cash=tranTab(skill.cash)
		skill.time=tranTab(skill.time)
		skill.honour=tranTab(skill.honour)

		skillInfo[k]=skill
	end
	for k,v in pairs(skill_site) do
		for k1,v1 in pairs(v) do
			site_kind[k]=skillInfo[k1].kind
			break
		end
	end
	table.save(site_kind,"scripts/game_config/skill/site_kind.lua")
	table.save(skill_site,"scripts/game_config/skill/skill_site.lua")
	table.save(skillInfo,"scripts/game_config/skill/skill_info.lua")
end

local function transBoat()
 local boat_info = require("transfrom/boat_info")
	local boatInfo = {}
	for k, v in pairs(boat_info) do
		boatInfo[k] = v
		boatInfo[k].id = k
		local t = v
		local t = split(t.consume,",")
		if t[1] then
			local t1=split(t[1],":")
			boatInfo[k].price=tonumber(t1[2])
		end
		if t[2] then
			local t2=split(t[2],":")
			boatInfo[k].honour=tonumber(t2[2])
		end

		local consume = {}
		local str = v
		local str1 = split(str.consume,",")
		consume["cash"] = 0
		consume["honour"] = 0
		for k1,v1 in pairs(str1) do
			local t2=split(v1,":")
			if t2[1] == "银币" then
				consume["cash"] = tonumber(t2[2])
			elseif t2[1] == "荣誉" then
				consume["honour"] = tonumber(t2[2])
			end
		end
		boatInfo[k].consume = consume

		local reform_consume = {}
		local t1 = v
		local t1 = split(t1.reform_consume,",")
		for k1,v1 in pairs(t1) do
			local t2=split(v1,":")
			if t2[1] == "银币" then
				reform_consume["cash"] = tonumber(t2[2])
			elseif t2[1] == "改造资材" then
				reform_consume["material"] = tonumber(t2[2])
			end
		end
		boatInfo[k].reform_consume = reform_consume

		boatInfo[k].init_load=v.grid
--		for gridKey,gridValue in pairs(boatInfo[k].grid) do
--			boatInfo[k].init_load=boatInfo[k].init_load+gridValue
--		end

		local esp = boatInfo[k].equip_sailor_percent
		local t3 = split(esp, ",")
		local equip_sailor_percent = {}
		for _, v in pairs(t3) do
			local t4 = split(v, ":")
			local kind = t4[1]
			local value = t4[2]
			equip_sailor_percent[tonumber(kind)] = value/100
		end
		boatInfo[k].equip_sailor_percent = equip_sailor_percent

	end

	table.save(boatInfo,"scripts/game_config/boat/boat_info.lua")
end

local function transAchive()
	local achievement_info = require("transfrom/achievement_info")
	for i, achievement in pairs(achievement_info) do
		--local finishkey = achievement.finishkey
		--achievement.finishkey = string.gsub(finishkey, "\"", "")
		
		
		local achieve = achievement.achieve
		achievement.achieve = {}
		local t = split(achieve, ",")
		for j, val in ipairs(t) do
			achievement.achieve[#achievement.achieve + 1] = tonumber(val)
		end

		local stats = achievement.stats
		achievement.stats = {}
		local t = split(stats, ",")
		for j, val in ipairs(t) do
			achievement.stats[#achievement.stats + 1] = tonumber(val)
		end

		local statslimit = achievement.statslimit
		achievement.statslimit = {}
		local t = split(statslimit, ",")
		for j, val in ipairs(t) do
			achievement.statslimit[#achievement.statslimit + 1] = tonumber(val)
		end

		local hasReward = 0
		local reward = achievement.reward
		--print(reward)
		local t = split(reward, ",")
		for j, val in ipairs(t) do
			t1 = split(val, ":")
			if t2 ~= '' then
				if t1[1] == "经验" then
					hasReward = 1
					achievement["exp"] = tonumber(t1[2])
				elseif t1[1] == "金币" then
					hasReward = 1
					achievement["gold"] = tonumber(t1[2])
				elseif t1[1] == "银币" then
					hasReward = 1
					achievement["silver"] = tonumber(t1[2])
				--[[elseif t1[1] == "水手" then
					tmp = string.gsub(t1[2], "\"", "")
					achievement["seaman"] = tmp
				elseif t1[1] == "船舶" then
					tmp = string.gsub(t1[2], "\"", "")
					achievement["boat"] = tmp]]
				elseif t1[1] == "荣誉" then
					hasReward = 1
					achievement["honour"] = tonumber(t1[2])
				end
			end
		end
		achievement.hasReward = hasReward
		achievement.reward = nil
	end
	table.save(achievement_info, "scripts/game_config/collect/achievement_info.lua")
end

local function transBaozang()
	local baozang_info = require("transfrom/baozang_info")
	local seaTab = {}
	for i = 1 , 8 do
		seaTab[i] = {}
	end

	for i, baozang in ipairs(baozang_info) do

		-- local attribute= baozang.attribute

		-- local t = split(attribute, ",")
		-- for i, val in ipairs(t) do
			-- t1 = split(val, ":")

			-- if t1[1] == "ap" then
				-- baozang["ap"] = t1[2]
			-- elseif t1[1] == "hp" then
				-- baozang["hp"] = t1[2]
			-- elseif t1[1] == "sp" then
				-- baozang["sp"] = t1[2]
			-- end
		-- end
		-- baozang.attribute= nil

		local reward = baozang.reward

		local t = split(reward, ",")
		for i, val in ipairs(t) do
			t1 = split(val, ":")

			if t1[1] == "经验" then
				baozang["exp"] = t1[2]
			elseif t1[1] == "金币" then
				baozang["gold"] = t1[2]
			elseif t1[1] == "银币" then
				baozang["silver"] = t1[2]
			elseif t1[1] == "水手" then
				tmp = string.gsub(t1[2], "\"", "")
				baozang["seaman"] = tmp
			elseif t1[1] == "船舶" then
				tmp = string.gsub(t1[2], "\"", "")
				baozang["boat"] = tmp
			elseif t1[1] == "荣誉" then
				baozang["royal"] = t1[2]
			end

		end
		baozang.reward = nil
		-- local kindId
		-- local kind = baozang.kind
		-- if kind == "武器" then
			-- kindId = 1
		-- elseif kind == "防具" then
			-- kindId = 2
		-- elseif kind == "书籍" then
			-- kindId = 3
		-- elseif kind == "古董" then
			-- kindId = 4
		-- elseif kind == "工具" then
			-- kindId = 5
		-- end
		-- baozang.kindId = kindId
		--table.foreach(achievement, print)

		-- 海域相关

		-- 海域相关
		local sea = baozang.sea
		if sea == '' then
			seaTab[8][#seaTab[8]+1] = i
		else
			local tab = split(sea, ",")
			local seaId = 8
			for k, name in pairs(tab) do
				for j=1,#area_info do
					if area_info[j].name == name then
						seaId = j
						break
					end
				end
				seaTab[seaId][#seaTab[seaId]+1] = i
			end
		end
	end
	table.save(baozang_info, "scripts/game_config/collect/baozang_info.lua")
	table.save(seaTab, "scripts/game_config/collect/baowu_sea.lua")
end

local function transMission(mission_info)
	for i, mission in ipairs(mission_info) do
		mission.id = i
		local reward = mission.reward
		local t = split(reward, ",")
		for i, val in ipairs(t) do
			t1 = split(val, ":")

			if t1[1] == "经验" then
				mission["exp"] = t1[2]
			elseif t1[1] == "金币" then
				mission["gold"] = t1[2]
			elseif t1[1] == "银币" then
				mission["silver"] = t1[2]
			elseif t1[1] == "水手" then
				tmp = string.gsub(t1[2], "\"", "")
				mission["seaman"] = tmp
			elseif t1[1] == "船舶" then
				tmp = string.gsub(t1[2], "\"", "")
				mission["boat"] = tmp
			elseif t1[1] == "荣誉" then
				mission["royal"] = t1[2]
			elseif t1[1] == "装备" then
				mission["equip"] = t1[2]
			elseif t1[1] == "藏宝图" then
				mission["treasure"] = t1[2]
			elseif t1[1] == "体力" then
				mission["power"] = t1[2]
			elseif t1[1] == "航海星章" then
				mission["starcrest"] = t1[2]
			end


		end
		mission.reward = nil

		-- local complete = mission.complete
		-- t = split(complete, ",")
		-- local str
		-- local totalProgress
		-- for i, val in ipairs(t) do
		-- t1 = split(val, ":")
		-- if t1[1] == "level" then
		-- str = "等级"..t1[2]
		-- elseif t1[1] == "cash" then
		-- str = "金钱"..t1[2]
		-- elseif t1[1] == "honour" then
		-- str = "荣誉达到"..t1[2]
		-- elseif t1[1] == "zhanli" then
		-- str = "累积荣誉"..t1[2]
		-- elseif t1[1] == "complete_battle" then
		-- str = "完成战役"..t1[2]
		-- elseif t1[1] == "event" then
		-- str = "达成"..t1[2]
		-- elseif t1[1] == "enter_port" then
		-- str = "进入"..t1[2].."港口"
		-- end
		-- totalProgress = tonumber(t1[2])
		-- if totalProgress == 0 or totalProgress == nil  then totalProgress = 1 end
		-- end
		-- mission.totalProgress = totalProgress

		-- 目标港口
		if mission.guide then
			local guideTable = {}
			for k, name in pairs(mission.guide) do
				local portId = findId(name, port_info)
				if portId then
					table.insert(guideTable, portId)
				end
			end
			mission.guide = guideTable
		end
	end
end

local function transMission_1()
	local mission_1_info = require("transfrom/mission_1_info")
	transMission(mission_1_info)
	table.save(mission_1_info, "scripts/game_config/mission/mission_1_info.lua")
end

local function transMission_2()
	local mission_2_info = require("transfrom/mission_2_info")
	transMission(mission_2_info)
	table.save(mission_2_info, "scripts/game_config/mission/mission_2_info.lua")
end

local function transMission_3()
	local mission_3_info = require("transfrom/mission_3_info")
	transMission(mission_3_info)
	table.save(mission_3_info, "scripts/game_config/mission/mission_3_info.lua")
end

local function transMission_4()
	local mission_4_info = require("transfrom/mission_4_info")
	transMission(mission_4_info)
	table.save(mission_4_info, "scripts/game_config/mission/mission_4_info.lua")
end

local function transUpgrade()
	for key,t in pairs(upgrade_info) do
		local reward = t.reward
		local te = split(reward, ",")
		local count = 0
		for i, val in ipairs(te) do
			t1 = split(val, ":")
			if t1[1] == "经验" then
				t["exp"] = t1[2]
			elseif t1[1] == "金币" then
				t["gold"] = t1[2]
			elseif t1[1] == "银币" then
				t["silver"] = t1[2]
			elseif t1[1] == "装备水手" then
				tmp = string.gsub(t1[2], "\"", "")
				t["seaman"] = tmp
				print(temp)
			elseif t1[1] == "船舶" then
				tmp = string.gsub(t1[2], "\"", "")
				t["boat"] = tmp
			elseif t1[1] == "荣誉" then
				t["royal"] = t1[2]
			elseif t1[1] == "银币上限" then
				t["silver_upper"] = t1[2]
			elseif t1[1] == "荣誉上限" then
				t["royal_upper"] = t1[2]
			elseif t1[1] == "体力" then
				t["power"] = t1[2]
			else
				assert(false, "transUpgrade找不到对应的数据")
			end
			count = count + 1
		end
		t.reward = nil
		t["count"] = count
	end
	table.save(upgrade_info,"scripts/game_config/reward/upgrade_info.lua")
end

local function transRelic()
	local relicsinfo = { }
	local relic_info = require("transfrom/relic_info")
	for i, relic in ipairs(relic_info) do
		if i > 0 then
			local area = relic.area
			for j=1,#area_info do
				if area_info[j].name==area then
					relic.areaId=j
					break
				end
			end
			relicsinfo[i] = relic
		end
	end
	table.save(relicsinfo, "scripts/game_config/collect/relic_info.lua")
end

local function transRelicAnswers()
	local answers = { }
	local relicAnswers = require("transfrom/relic_answers")
	for i, answer in ipairs(relicAnswers) do
		if i > 0 then
			answers[i] = answer
		end
	end
	table.save(answers, "scripts/game_config/collect/relic_answers.lua")
end

local function tranShop()
	local shop_info =require("transfrom/shop_info")
	for i, v in ipairs(shop_info) do
		t1 = split(v.name,":")
		local info = {}
		if t1[1] == "经验" then
			info.type = "exp"
		elseif t1[1] == "金币" then
			info.type = "gold"
		elseif t1[1] == "银币" then
			info.type = "silver"
		elseif t1[1] == "荣誉" then
			info.type = "royal"
		elseif t1[1] == "补给" then
			info.type = "power"
		elseif t1[1] == "vip" then
			info.type = "VIP"
		elseif t1[1] == "改造资材" then
			info.type = "item"
		end
		info.value = t1[2]
		v.name = info

		t1 = split(v.consume, ":")
		if t1[1] == "RMB" then
			v["type"] = "rmb"
			v["consume"] = t1[2]
		elseif t1[1] == "金币" then
			v["type"] = "gold"
			v["consume"] = t1[2]
		end

		t1 = split(v.reward,":")
		local _rewardInfo = {}
		if t1[1] == "经验" then
			_rewardInfo.type = "exp"
		elseif t1[1] == "金币" then

			_rewardInfo.type = "gold"
		elseif t1[1] == "银币" then

			_rewardInfo.type = "silver"
		elseif t1[1] == "荣誉" then

			_rewardInfo.type = "royal"
		elseif t1[1] == "改造资材" then

			_rewardInfo.type = "item"
		end

		_rewardInfo.value = t1[2]
		v.reward = _rewardInfo
	end
	table.save(shop_info, "scripts/game_config/shop/shop_info.lua")
end

local function transBattleinfo()
    local battle_info = require("transfrom/battle_info")
	local battleInfo=battle_info
	for battleId, battle in ipairs(battle_info) do
		local t = split(battle.reward,",")
		battle.reward = {}
		for i, val in ipairs(t) do
			local tab = split(val, ":")
			local key=nil

			if tab[1] == "经验" then
				key = "exp"
			elseif tab[1] == "金币" then
				key = "gold"
			elseif tab[1] == "银币" then
				key = "silver"
			elseif tab[1] == "荣誉" then
				key = "honour"
			end
			battle.reward[key] = tab[2]
		end

		local material={} --key 是materialId ,value 随便放 就数量了
		battle.material=split(battle.material,",")
		if battle.material then
			for k,materialId in pairs(battle.material) do
				materialId=string.sub(materialId,2,#materialId-1)
				local lootTab=random_loot_info[materialId]
				if lootTab then
					for key,value in pairs(lootTab.loot_table) do
						material[value.type] = material[value.type] or {}
                        material[value.type][value.id] = value.amount 
					end
				else
					cclog("----------第"..battleId.."场战斗表中材料库id "..materialId.." 找不到在材料随机库中")
					--table.print(battle.material)
				end
			end
			battle.material=material
		end

		local starPrompt = split(battle.starPrompt,",")  --星级提示
		battle.starPrompt = {}
		if starPrompt then
			for i, val in ipairs(starPrompt) do
				local tab = split(val, ":")
				battle.starPrompt[i] = tab[2]
			end
		end
	end
	table.save(battleInfo, "scripts/game_config/battle/battle_info.lua")
--	table.save(battle_type_info, "scripts/game_config/battle/battle_type_info.lua")
end

local function transBattleinfo_jy()
    local battle_info = require("transfrom/battle_jy_info")
	local battleInfo=battle_info
	for battleId, battle in ipairs(battle_info) do
		local t = split(battle.reward,",")
		battle.reward = {}
		for i, val in ipairs(t) do
			local tab = split(val, ":")
			local key=nil

			if tab[1] == "经验" then
				key = "exp"
			elseif tab[1] == "金币" then
				key = "gold"
			elseif tab[1] == "银币" then
				key = "silver"
			elseif tab[1] == "荣誉" then
				key = "honour"
			end
			battle.reward[key] = tab[2]
		end

		local material={} 
		battle.material=split(battle.material,",")
		if battle.material then
			for k,materialId in pairs(battle.material) do
				materialId=string.sub(materialId,2,#materialId-1)
				local lootTab=random_loot_info[materialId]
				if lootTab then
					for key,value in pairs(lootTab.loot_table) do

                        material[value.type] = material[value.type] or {}
                        material[value.type][value.id] = value.amount                  

					end
				else
					cclog("----------第"..battleId.."场战斗表中材料库id "..materialId.." 找不到在材料随机库中")
					--table.print(battle.material)
				end
			end
			battle.material=material
		end

		local starPrompt = split(battle.starPrompt,",")  --星级提示
		battle.starPrompt = {}
		if starPrompt then
			for i, val in ipairs(starPrompt) do
				local tab = split(val, ":")
				battle.starPrompt[i] = tab[2]
			end
		end
	end
	table.save(battleInfo, "scripts/game_config/battle/battle_jy_info.lua")
--	table.save(battle_type_info, "scripts/game_config/battle/battle_type_info.lua")
end

local function transReward()
	local reward1={}
	for k,v in pairs(landReward) do
		local tab={}
		for k1,v1 in pairs(v.reward_2) do
			local idTmp = 0
			local resTmp = ""
			local valueTmp = ""
			local scaleTmp = 100
			local descrTmp = ""
			if v.subType[k1]==2 or v.subType[k1]==3 then
				--水手或船舶图纸
				idTmp = v1[1]
				scaleTmp = v1[2]
			else
				resTmp = v1[1]
				valueTmp = v1[2]
			end

			if v.kind[k1] then
				tab[k1]={subType=v.subType[k1],id=idTmp,res=resTmp,value=valueTmp,kind=v.kind[k1],scale=scaleTmp,descr=descrTmp}
			else
				tab[k1]={subType=v.subType[k1],id=idTmp,res=resTmp,value=valueTmp,scale=scaleTmp,descr=descrTmp}
			end
		end
		reward1[k]=tab
	end
	table.save(reward1, "scripts/game_config/reward/login_reward.lua")

	local reward2={}
	for k,v in pairs(payReward) do
		local idTmp = 0
		local resTmp = ""
		local valueTmp = ""
		local scaleTmp = 100
		local descrTmp = ""
		if v.subType[1]==2 or v.subType[1]==3 then
			--水手或船舶图纸
			idTmp = v.reward[1]
			scaleTmp = v.reward[2]
		elseif v.subType[1]==4 then
			--权限
			valueTmp = v.reward
		else
			resTmp = v.reward[1]
			valueTmp = v.reward[2]
		end

		if v.kind~=0 then
			reward2[k]={subType=v.subType[1],id=idTmp,res=resTmp,value=valueTmp,scale=scaleTmp,payValue=v.value,name=v.name,kind=v.kind,descr=descrTmp}
		else
			reward2[k]={subType=v.subType[1],id=idTmp,res=resTmp,value=valueTmp,scale=scaleTmp,payValue=v.value,name=v.name,descr=descrTmp}
		end
	end
	table.save(reward2, "scripts/game_config/reward/chongzhi_reward.lua")
end

local function transXunbao()
	local xunbao_info = xunbao_info
	for i, v in ipairs(xunbao_info) do
		t1 = split(v.reward,":")
		local _rewardInfo = {}
		if t1[1] == "经验" then

			_rewardInfo.type = "exp"
		elseif t1[1] == "金币" then

			_rewardInfo.type = "gold"
		elseif t1[1] == "银币" then

			_rewardInfo.type = "silver"
		elseif t1[1] == "荣誉" then

			_rewardInfo.type = "royal"
		elseif t1[1] == "补给" then
			_rewardInfo.type = "power"
		elseif t1[1] == "水手" then
			_rewardInfo.type = "sailor"
		elseif t1[1] == "宝物" then
			_rewardInfo.type = "baowu"
		end
		_rewardInfo.desc =t1[1]
		_rewardInfo.value = t1[2]
		v.reward = _rewardInfo
	end
	table.save(xunbao_info, "scripts/game_config/battles/xunbao_info.lua")
end

local function transPortGood()
    local goods_info=require("transfrom/goods_info")
    local port_goods_info = require("transfrom/port_goods_info")
	local tabs={}
	local areaTabs = {}  --特产品（包括海域特产品和港口特产品）
	local areaDics = {}
	for k, v in pairs(port_goods_info) do
		local portId = findId(k,port_info)

		local seaId = findId(port_info[portId].sea_area,area_info)
		if not areaTabs[seaId] then
			areaTabs[seaId] = {}
		end
		if not areaDics[seaId] then
			areaDics[seaId] = {}
		end

		local tab={common={},area={},port={}}
		local common=split(v.common,",")
		local goodId = 0
		for k1,v1 in ipairs(common)do
			goodId = findId(v1,goods_info)
			tab.common[#tab.common+1]=goodId
		end

		local area=split(v.area,",")
		for k2,v2 in ipairs(area) do
			goodId = findId(v2,goods_info)
			tab.area[#tab.area+1]=goodId
			if not areaDics[seaId][goodId] then
				areaDics[seaId][goodId] = true
				areaTabs[seaId][#areaTabs[seaId] + 1] = goodId
			end
		end
		local port=split(v.port,",")
		for k3,v3 in ipairs(port)do
			goodId = findId(v3,goods_info)
			tab.port[#tab.port+1]=goodId
			if not areaDics[seaId][goodId] then
				areaDics[seaId][goodId] = true
				areaTabs[seaId][#areaTabs[seaId] + 1] = goodId
			end
		end
		
		tabs[portId]=tab
	end

	table.save(tabs,"scripts/game_config/port/port_goods_info.lua")
	table.save(areaTabs,"scripts/game_config/port/local_goods_info.lua")
end

local function transGoods()
	local port_goods_info=require("scripts/game_config/port/port_goods_info")
	local goods_info=require("transfrom/goods_info")
	local goods_type_info=require("transfrom/goods_type_info")
--	local class_info={
--		[1]={name="纺织品"},
--		[2]={name="工业品"},
--		[3]={name="酒类"},
--		[4]={name="奢侈品"},
--		[5]={name="食物"},
--		[6]={name="嗜好品"},
--		[7]={name="武器"},
--		[8]={name="香料"},
--		[9]={name="艺术品"},
--	}

	local tabs={}
	local supplyDemandTabs = {}
	for k,v in pairs(goods_info) do
		local supplyDemandTab = {}
		local material=split(v.material,",")
		v.id= k
		supplyDemandTab.goodId = k
		v.material={}
		if #material>0 then
			for k1,v1 in pairs(material) do
				table.insert(v.material,findId(v1,goods_info))
			end
		end

		local production=split(v.production,",")
		v.production={}
		if #production>0 then
			for k2,v2 in pairs(production) do
				table.insert(v.production,findId(v2,goods_info))
			end
		end

		--类别
        v.class=findId(v.class,goods_type_info)

		tabs[k]=v
		supplyDemandTabs[k] = supplyDemandTab

		local isBreak=false
		local supplyPorts = {}
		local demandPorts = {}
		for portId,value in pairs(port_goods_info) do
			isBreak=false
			for _,id in pairs(value.common) do
				if id==v.id then
					if not v.breed then
						v.breed="common"
					end
					isBreak=true
					supplyPorts[#supplyPorts+1]=portId
					break
				end
			end
			--if isBreak then break end
			for _,id in pairs(value.area) do
				if id==v.id then
					if not v.breed then
						v.breed="area"
					end
					isBreak=true
					supplyPorts[#supplyPorts+1]=portId
					break
				end
			end
			--if isBreak then break end
			for _,id in pairs(value.port) do
				if id==v.id then
					if not v.breed then
						v.breed="port"
					end
					isBreak=true
					supplyPorts[#supplyPorts+1]=portId
					break
				end
			end

			if not isBreak then
				demandPorts[#demandPorts+1]=portId
			end
		end
		supplyDemandTab.supplyPorts = supplyPorts
		supplyDemandTab.demandPorts = demandPorts
	end
	table.save(tabs,"scripts/game_config/port/goods_info.lua")
	table.save(supplyDemandTabs,"scripts/game_config/port/goods_supply_demand_info.lua")
end

local function transMap()  -- 地图导表
	print("创建地图")
	--local map = CCTMXTiledMap:create("explorer/map/tools/land_all.tmx")
	
	local map = CCTMXTiledMap:create("F:/work/tilemap/tools/land_all.tmx")
	local landLayer = map:layerNamed("land")
	local snowLayer = map:layerNamed("snow")
	local iceLayer  = map:layerNamed("ice")
	local landLayer2 = map:layerNamed("sand")
	local relicLayer = map:layerNamed("relic")
	local portLayer = map:layerNamed("port")
	local transitLayer = map:layerNamed("transit")
	local inlandLayer = map:layerNamed("inland")

	local waveLayer  = map:layerNamed("slow") -- 减速带

	local tiles_width = map:getMapSize().width
	local tiles_height = map:getMapSize().height
	local arr = {}
	print("初始化地图")

	local function isLand(i, j) -- 0 陆地, 1 海面， 2 减速带
		if waveLayer:tileGIDAt(ccp(i, j))~= 0 then
			return 2 -- 2 减速带
		elseif inlandLayer:tileGIDAt(ccp(i, j))~= 0 or landLayer:tileGIDAt(ccp(i, j))~= 0 or snowLayer:tileGIDAt(ccp(i, j))~= 0  -- 陆地
			or iceLayer:tileGIDAt(ccp(i, j))~= 0 or landLayer2:tileGIDAt(ccp(i, j))~= 0
			or relicLayer:tileGIDAt(ccp(i, j))~= 0 or transitLayer:tileGIDAt(ccp(i, j))~= 0 
			or portLayer:tileGIDAt(ccp(i, j))~= 0 then
			return 0 -- 0 陆地
		end
		return 1     -- 1 海面
	end

	for y = 0, tiles_height-1   do -- map[height][width]
		for x = 0, tiles_width-1  do
			if not arr[y*tiles_width+x+1] then
				local tmp = isLand(x, y)
				arr[y*tiles_width+x+1] = tmp
			end
		end
	end
	print("初始化地图结束")
	print(#arr)
	print(isLand(994, 296))
	table.save_map(arr, "scripts/game_config/explore/map.lua")
end

local function transClosePort()
    local port_path_info=require("transfrom/port_path_info")
	local nearest_port={}
	for k,v in pairs(port_path_info) do
		local start=findId(v.start,port_info)
		local terminal=findId(v.terminal,port_info)
        nearest_port[start]=nearest_port[start] or {}
        nearest_port[start][terminal]=v.dist
        print("start   --->",start," terminal --->",terminal)
        table.print(nearest_port[start])
	end
    table.save(nearest_port,"scripts/game_config/port/nearest_port.lua")
end

local function transPort()
    local small_people_info =require("scripts/game_config/port/small_people_info")
    local area_info =require("transfrom/area_info")
    local goods_info=require("transfrom/goods_info")
    local boat_info = require("transfrom/boat_info")
    local build_info=require("transfrom/build_info")
    local equip_material_info=require("transfrom/equip_material_info")
    local keepsake_info=require("transfrom/keepsake_info")
    
    local TILE_SIZE = 64
	local TILE_HEIGHT = 960
	local TILE_WIDTH  = 1695
    local w_size = 7  -- 港口占格子大小
	local h_size = 4

	local port_pos_tab = {}

    local area={}
    
	local portInfo={}
	local portLocks={}  --解锁所有物品列表
	local portCircleLocks={}
	local portLockBoats={}
	local portLockBuilds={}
	local portLockGoods={}
	local portLockMaterial={}
	local portLockKeepsake={}
	--local portLockHonour={}  --TODO:待删
	local portLockBook={}
	local portLockBoatRemould={}

	for k,port in pairs(port_info) do
		portInfo[k]=port
		if portInfo[k].tutor_cash==0 then  portInfo[k].tutor_cash=nil end
		if portInfo[k].tutor_honour==0 then portInfo[k].tutor_honour=nil end
		--tutor
		local learn_skill=split(portInfo[k].learn_skill,",")
		local skills={}
		for kSkill,vSkill in pairs(learn_skill) do
			local skill=split(vSkill,":")
			skills[#skills+1]={id=tonumber(skill[1]),level=tonumber(skill[2])}
		end
		if #skills==0 then skills=nil end
		portInfo[k].learn_skill=skills
		--小人
		local smallPeople=split(port.small_people,"、")
		local peoples={}
		for kPeople,vPeople in ipairs(smallPeople) do
			table.insert(peoples,findId(vPeople,small_people_info))
		end
		portInfo[k].people=peoples

		local new_invest_prosper = {}
		local invest_prosper = portInfo[k].invest_prosper
		local invest_prospers = split(invest_prosper,",")
		if invest_prospers then
			for k,v in pairs(invest_prospers) do
				local invest_add = split(v,":")
				if invest_add then
					new_invest_prosper[tonumber(invest_add[1])] = tonumber(invest_add[2])
				end
			end
		end
		portInfo[k].invest_prosper = new_invest_prosper

		portLocks[k]={} --市政厅使用  解锁里面用

		local key={"invest_consume_1","invest_consume_2","invest_consume_3","invest_consume_4","invest_consume_5","invest_consume_6","invest_consume_7"}

		local function getInvestComsume()
			for key,value in ipairs(key) do
				if key<=portInfo[k].invest_step and portInfo[k][value] then
					local tab=split(portInfo[k][value],",")
					local cashTab=split(tab[1],":")
					portLocks[k][key]={
						cash=tonumber(cashTab[2]),
						step=key,
					}
					portInfo[k][value]=nil
				end
			end
		end

		getInvestComsume()

		portLockBoats[k]={}   --保寸每个港口解锁船只的繁荣度值
		portLockBuilds[k]={}
		portLockGoods[k]={}
		portLockMaterial[k]={}
		portLockKeepsake[k]={}
		--portLockHonour[k]={}
		portLockBook[k]={}
		portLockBoatRemould[k]={}
		--解锁

		local function getLock(src,indexTab,amountStr)
			local dest={}
			local lock=split(src,",")
			for k,v in ipairs(lock) do
				local splitTab1=split(v,":")
				local amount=1
				local name=splitTab1[1]
				local step=tonumber(splitTab1[2])
				--table.print(splitTab)
				--print("name",name,"amount",amount,'step',step)
				if amountStr then
					local splitTab2=split(name,amountStr)
					name=splitTab2[1]
					amount=tonumber(splitTab2[2])
				end
				--print("name",name,"amount",amount,'step',step)
				if step>=1 then--投资度大于0 才用
					--if indexTab then
						dest[step]={
							id=findId(name,indexTab),
							amount=amount,
						}
					--end
				end
			end
			return dest
		end
		local function getRemouldLock(src)
			local dest={}
			local lock=split(src,",")
			for k,v in ipairs(lock) do
				local splitTab1=split(v,":")
				local step=tonumber(splitTab1[1])
				if step>=1 then--投资度大于0 才用
					dest[step]={
						id=4,
						amount=tonumber(splitTab1[2]),
					}
				end
			end
			return dest
		end

		local function getBoatDrawLock(src)
			local dest={}
			local lock=split(src,",")
			for k,v in ipairs(lock) do
				local splitTab1=split(v,":")
				local amount=1
				local step=tonumber(splitTab1[1])
				if step>=1 then--投资度大于0 才用
					dest[step]={
						id=tonumber(splitTab1[2]),
						amount=amount,
					}
				end
			end
			return dest
		end
		portLockGoods[k]=getLock(portInfo[k].invest_goods,goods_info)
		portLockBoats[k]=getBoatDrawLock(portInfo[k].invest_boat)
		portLockBuilds[k]=getLock(portInfo[k].invest_unlock,build_info)
		portLockKeepsake[k]=getLock(portInfo[k].invest_keepsake,keepsake_info,"-")
		portLockMaterial[k]=getLock(portInfo[k].invest_equip_material,equip_material_info,"-")
		portLockBoatRemould[k]=getRemouldLock(portInfo[k].invest_boat_remould)

		local function strToTab(str,splitStr)
			splitStr = splitStr or ","
			local tab=split(str,splitStr)
			local tab_2 = {}
			for k,v in pairs(tab) do
				local tab_1 = split(v,":")
				tab_2[tonumber(tab_1[1])]={
					id = 1,
					amount = tonumber(tab_1[2]),
				}
			end
			return tab_2
		end
		portLockBook[k]=strToTab(portInfo[k].invest_exp_book)

		-- local function strToTab(str,splitStr)
		-- 	splitStr = splitStr or ","
		-- 	local tab=split(str,splitStr)
		-- 	for k,v in pairs(tab) do
		-- 		tab[k]={
		-- 			amount=tonumber(v),
		-- 			id = 0,
		-- 		}
		-- 	end
		-- 	return tab
		-- end
		--portLockHonour[k]=strToTab(portInfo[k].invest_honour)

		local locks={}
		local function merge(tab,id,isLine)
			for step,v in pairs(tab) do
				locks[step]=locks[step] or {}
				table.insert(locks[step],{
					[id]=v.id,
					amount=v.amount,
					isLine=isLine,
				})
			end
		end
		merge(portLockGoods[k],"goodId",true)
		merge(portLockBoats[k],"boatDrawId",true)
		merge(portLockBuilds[k],"buildId",true)
		merge(portLockKeepsake[k],"keepsakeId",true)
		merge(portLockBoatRemould[k],"remouldId",true)
		merge(portLockBook[k],"bookId",true)
		merge(portLockMaterial[k],"materialId")
		--merge(portLockHonour[k],"honourId")

		local percent=100/#portLocks[k]
		for step,lock in pairs(portLocks[k]) do
			if locks[step] then  portLocks[k][step].lock = locks[step] end
			portLocks[k][step].percent = percent*step
		end

		portInfo[k].seaId=findId(portInfo[k].sea_area,area_info)
		portInfo[k].areaId=findId(port.sea_area,area_info)
		portInfo[k].invest_unlock=nil
		portInfo[k].invest_goods=nil
		portInfo[k].invest_boat=nil
		portInfo[k].small_people=nil
		portInfo[k].invest_step=nil
		portInfo[k].invest_honour=nil
		portInfo[k].invest_equip_material=nil
		portInfo[k].invest_exp_book=nil
		portInfo[k].invest_boat_remould=nil
		portInfo[k].invest_consume_6=nil
		portInfo[k].invest_consume_7=nil
		portInfo[k].invest_keepsake=nil
		--海域
        area[portInfo[k].areaId]= area[portInfo[k].areaId] or {}
        table.insert(area[portInfo[k].areaId],k)

        local sea_pos_x, sea_pos_y = port.sea_pos[1], port.sea_pos[2]
		local size_w = port.port_size[1]
		local size_h = port.port_size[2]
		for i = 0 , size_h-1 do
			for j = 0, size_w-1 do
				local key = (sea_pos_y-i)*TILE_WIDTH + sea_pos_x+j
				port_pos_tab[key] = k -- 对应的位置保存对应的港口id
			end
		end
	end
    table.save(area,"scripts/game_config/port/port_area.lua")
	table.save(portInfo,"scripts/game_config/port/port_info.lua")
	table.save(port_pos_tab,"scripts/game_config/explore/port_pos.lua")
	table.save(portLocks,"scripts/game_config/port/port_lock.lua")
	table.save(portLockBoats,"scripts/game_config/port/port_lock_boat.lua")
	table.save(portLockGoods,"scripts/game_config/port/port_lock_good.lua")
	table.save(portLockMaterial,"scripts/game_config/port/port_lock_material.lua")
	table.save(portLockKeepsake,"scripts/game_config/port/port_lock_keepsake.lua")
	--table.save(portLockHonour,"scripts/game_config/port/port_lock_honour.lua")
	table.save(portLockBook,"scripts/game_config/port/port_lock_book.lua")
	table.save(portLockBoatRemould,"scripts/game_config/port/port_lock_remould.lua")
end

local function transNewAchieve()
	local allData = {}
	for key, value in pairs(new_achieve_mission) do
		allData[key] = {}
		for _k, _v in pairs(value) do
			if _k == "reward" then
				local t = split(_v, ",")
				local reward = {}
				for i, val in ipairs(t) do
					local t1 = split(val, ":")

					if t1[1] == "经验" then
						reward["exp"] = tonumber(t1[2])
					elseif t1[1] == "金币" then
						reward["gold"] = tonumber(t1[2])
					elseif t1[1] == "银币" then
						reward["silver"] = tonumber(t1[2])
					elseif t1[1] == "水手" then
						reward["seaman"] = tonumber(t1[2])
					elseif t1[1] == "船舶" then
						reward["boat"] = tonumber(t1[2])
					elseif t1[1] == "荣誉" then
						reward["honour"] = tonumber(t1[2])
					end
				end
				allData[key][_k] = reward
			else
				allData[key][_k] = _v
			end
		end

		-- 目标港口
		if value.ports then
			local guideTable = {}
			for k, name in pairs(value.ports) do
				local portId = findId(name, port_info)
				if portId then
					table.insert(guideTable, portId)
				end
			end
			allData[key].ports = guideTable
		end
	end

	table.save(allData,"scripts/game_config/collect/new_achieve_mission.lua")
end

local function transPortPveInfo()

	local random_loot_info = require("game_config/random/random_loot_info")
	local maxStep = 3
	for checkPointId, info in ipairs(pve_port_info) do
		info.port_id = findId(info.port, port_info)

		local reward = {}
		for i = 1, maxStep do
			local rewardId = info["reward_"..i]
			rewardId = string.sub(rewardId, 2, #rewardId - 1)
			local lootTab = random_loot_info[rewardId]
			if lootTab then
				for k, v in pairs(lootTab.loot_table) do	
					if v.type == "exp" then
						reward["exp"] = v.amount
					elseif v.type=='cash' then
						reward["silver"] = v.amount
					elseif v.type=='gold' then
						reward["gold"] = v.amount
					elseif v.type == 'item' then
						if not reward["item"] then
							reward["item"] = {}
						end
						reward["item"][#reward["item"] + 1] = {id = v.id,amount = v.amount}
					end
				end
				info["reward_"..i] = reward
				reward = {}
			end

			
			-----------------------
			local reward={}
			local stepReward = info["fight_step_"..i.."_reward"]
			stepReward=split(stepReward,",")
			if stepReward then
				for k,rewardId in pairs(stepReward) do
					rewardId=string.sub(rewardId,2,#rewardId-1)
				
					local lootTab=random_loot_info[rewardId]
					if lootTab then
						for key,value in pairs(lootTab.loot_table) do
							if value.type=='exp' then
								reward["exp"]=value.amount
							elseif value.type=='cash' then
								reward["silver"]=value.amount
							elseif value.type=='gold' then
								reward["gold"]=value.amount
							elseif value.type=='sailor' then
								reward["sailor"]=value.id
							elseif value.type=='material' then
								if not reward["material"] then
									reward["material"] = {}
								end
								reward["material"][#reward["material"] + 1] = {id=value.id,amount=value.amount}
							end
						end
					else
						cclog("----------第"..checkPointId.."个港口关卡表中第"..i.."阶段奖励id "..rewardId.." 找不到在材料随机库中")
						--table.print(stepReward)
					end
				end
				info["fight_step_"..i.."_reward"] = reward
			end
		end
	end
	for checkPointId, info in ipairs(strongHold_pve_info) do
		local reward = {}
		for i = 1, maxStep do

			--额外的奖励
			local rewardId = info["reward_"..i]

			rewardId = string.sub(rewardId, 2, #rewardId - 1)
			
			local lootTab = random_loot_info[rewardId]

			if lootTab then
				for k, v in pairs(lootTab.loot_table) do
					if v.type == "exp" then
						reward["exp"] = v.amount
					elseif v.type == 'item' then
						if not reward["item"] then
							reward["item"] = {}
						end
						reward["item"][#reward["item"] + 1] = {id = v.id,amount = v.amount}
					end
				end
				info["reward_" .. i] = reward
				reward = {}
			end
			-----------------------
			local reward={}
			local stepReward = info["fight_step_"..i.."_reward"]
			stepReward=split(stepReward,",")
			if stepReward then
				for k,rewardId in pairs(stepReward) do
					rewardId=string.sub(rewardId,2,#rewardId-1)
					local lootTab=random_loot_info[rewardId]
					if lootTab then
						for key,value in pairs(lootTab.loot_table) do
							if value.type=='exp' then
								reward["exp"]=value.amount
							elseif value.type=='cash' then
								reward["silver"]=value.amount
							elseif value.type=='gold' then
								reward["gold"]=value.amount
							elseif value.type=='sailor' then
								reward["sailor"]=value.id
							elseif value.type=='material' then
								if not reward["material"] then
									reward["material"] = {}
								end
								reward["material"][#reward["material"] + 1] = {id=value.id,amount=value.amount}
							end
						end
					else
						cclog("----------第"..checkPointId.."个据点关卡表中第"..i.."阶段奖励id "..rewardId.." 找不到在材料随机库中")
						--table.print(stepReward)
					end
				end
				info["fight_step_"..i.."_reward"] = reward
			end
		end
	end

	local w_size = 1  -- 海上据点占格子大小
	local h_size = 1
	local TILE_WIDTH  = 1695
	local strongHold_pos_info = {}	
	for k, v in ipairs(strongHold_pve_info) do
		local x, y = v.name_pos[1], v.name_pos[2]
		for i = 0 , h_size-1 do
			for j = 0, w_size-1 do
				local key = (y-i)*TILE_WIDTH + x+j
				if strongHold_pos_info[key] == nil then
					strongHold_pos_info[key] = {}
				end
				table.insert(strongHold_pos_info[key], k) -- 对应的位置保存对应的海上据点id
			end
		end 
	end
	table.save(strongHold_pos_info, "scripts/game_config/portPve/strongHold_pos.lua")
	table.save(pve_port_info, "scripts/game_config/portPve/pve_port_info.lua")
	table.save(strongHold_pve_info, "scripts/game_config/portPve/pve_stronghold_info.lua")
end

local function transAreaMissionInfo()
	for id, info in ipairs(area_mission_info) do
		local newReward = {}
		local reward = {}
		local oldReward = info["reward"]
		oldReward=split(oldReward,",")
		if oldReward then
			-- for k,v in pairs(oldReward) do
			-- 	local reward = split(v,":")
			-- 	if reward[1] then
			-- 		if reward[1]=='荣誉' then
			-- 			newReward["honour"]=tonumber(reward[2])
			-- 		elseif reward[1]=='金币' then
			-- 			newReward["gold"]=tonumber(reward[2])
			-- 		elseif reward[1]=='银币' then
			-- 			newReward["cash"]=tonumber(reward[2])
			-- 		elseif reward[1]=='经验' then
			-- 			newReward["exp"]=tonumber(reward[2])
			-- 		end
			-- 	end
			-- end

			local randomLootInfo = require("game_config/random/random_loot_info")
			for k,rewardId in pairs(oldReward) do
				rewardId = string.sub(rewardId,2,#rewardId-1)
				local lootTab = randomLootInfo[rewardId]
				if lootTab then
					for key,value in pairs(lootTab.loot_table) do
						if value.type=='exp' then
							reward["exp"]=value.amount
						elseif value.type=='cash' then
							reward["silver"]=value.amount
						elseif value.type=='gold' then
							reward["gold"]=value.amount
						elseif value.type=='sailor' then
							reward["sailor"]=value.id
						elseif value.type == "keepsake" then
							if not reward["keepsake"] then
								reward["keepsake"] = {}
							end
							reward["keepsake"][#reward["keepsake"] + 1] = {id=value.id,amount=value.amount}
						elseif value.type=='material' then
							if not reward["material"] then
								reward["material"] = {}
							end
							reward["material"][#reward["material"] + 1] = {id=value.id,amount=value.amount}
						end
					end
				end
			end
		end
		info["reward"] = reward
	end

	table.save(area_mission_info, "scripts/game_config/explore/area_mission_info.lua")
end

local function transPortToPortDistance()
	local portDistance = 0
	local port_distance_info = {}

	local portLen = #port_info
	for i=1,portLen do
		for j=i+1,portLen do
			portDistance = 0
			portDistance = transformUtil.calculatePosToPosDistance(port_info[i].ship_pos, port_info[j].ship_pos)

			if not port_distance_info[i] then
				port_distance_info[i] = {}
			end
			if not port_distance_info[j] then
				port_distance_info[j] = {}
			end
			port_distance_info[i][j] = portDistance
			port_distance_info[j][i] = portDistance
			print("=============================portToPort Distance i="..i.." j="..j.." dis="..portDistance)
		end
	end

	table.save(port_distance_info, "scripts/game_config/port/port2port_distance_info.lua")
end

local function transPortToShDistance()
	local portDistance = 0

	local port_distance_info = {}

	local portLen = #port_info
	local shLen = #strongHold_pve_info
	for i=1,portLen do
		for j=1,shLen do
			portDistance = 0
			portDistance = transformUtil.calculatePosToPosDistance(port_info[i].ship_pos, strongHold_pve_info[j].ship_pos)

			if not port_distance_info[i] then
				port_distance_info[i] = {}
			end
			port_distance_info[i][j] = portDistance
			print("=============================portToSh Distance i="..i.." j="..j.." dis="..portDistance)
		end
	end

	table.save(port_distance_info, "scripts/game_config/port/port2sh_distance_info.lua")
end

local function transPortToRelicDistance()
	local map_partition = require("scripts/game_config/explore/explore_map_partition")
	local function getPartitionId(pos) 	
		for k, v in ipairs(map_partition) do
			local rect = CCRect(v.start_pos[1], v.start_pos[2], v.width, v.height)
			if rect:containsPoint(pos) then 
				return k
			end 
		end 
	end 

	local TILE_HEIGHT = 960	
	local TILE_WIDTH  = 1695
	local TILE_SIZE = 64
	local LAND_HEIGHT = TILE_SIZE * TILE_HEIGHT

	local cocosToTile2 = function(position)  
		return ccp(position.x*TILE_SIZE+TILE_SIZE/2, LAND_HEIGHT-position.y*TILE_SIZE-TILE_SIZE/2)
	end

	local astar     = require("gameobj/explore/qAstar")
	local res = "res/explorer/map.bit"
	local AStar = astar.new()
	AStar:initByBit(res, TILE_WIDTH, TILE_HEIGHT)

	local pos_st = ccp(0,0)
	local pos_end = ccp(0,0)
	local pos_now = ccp(0,0)
	local path = nil
	local pathLen = 0
	local pathIndex = 1
	local portDistance = 0
	local node_pos_st = ccp(0,0)
	local node_pos_end = ccp(0,0)

	local port_distance_info = {}
	local relic_info = require("transfrom/relic_info")
	local portLen = #port_info
	local shLen = #relic_info
	
	local function getDistance(dis_path)
		local dis_n = 0
		local dis_path_len = #dis_path
		local dis_path_index = 1
		for k=1,dis_path_len do
			if (dis_path_index+3) > dis_path_len then
				break
			end
			local node_pos_st = cocosToTile2(ccp(dis_path[dis_path_index], dis_path[dis_path_index+1]))
			local node_pos_end = cocosToTile2(ccp(dis_path[dis_path_index+2], dis_path[dis_path_index+3]))
			dis_n = dis_n + Math.distance(node_pos_st.x, node_pos_st.y, node_pos_end.x, node_pos_end.y)
			dis_path_index = dis_path_index + 2
		end
		return dis_n
	end
	
	local function getSaveDistance(port_id, port_x, port_y, relic_id, relic_x, relic_y)
		local dis_save_info = require("transfrom/iwork/port2relic_save_dis_info.lua")
		local dis_save_item = dis_save_info[port_id]
		if dis_save_item then
			item = dis_save_item[relic_id]
			if item then
				if (port_x == item[1]) and (port_y == item[2]) and (relic_x == item[3]) and (relic_y == item[4]) then
					return item[5]
				end
			end
		end
		return -1
	end
	
	local order_n = 2
	local offset_n = 26
	local is_all_out = true
	local save_data_is_help = true
	local is_save_save_date_again = false
	
	for i=1,portLen do
	
		if ((i > (order_n*offset_n)) and (i <= ((order_n + 1)*offset_n))) or (true == is_all_out) then
			pos_st.x = port_info[i].ship_pos[1]
			pos_st.y = port_info[i].ship_pos[2]

			for j=1,shLen do
				pathIndex = 1
				portDistance = 0
				pos_end.x = relic_info[j].ship_pos[1]
				pos_end.y = relic_info[j].ship_pos[2]
				
				local save_dis = getSaveDistance(i, pos_st.x, pos_st.y, j, pos_end.x, pos_end.y)
				if (save_dis >= 0) and (true == save_data_is_help) then
					if not port_distance_info[i] then
						port_distance_info[i] = {}
					end
					port_distance_info[i][j] = save_dis
				else
					pos_now.x = pos_st.x
					pos_now.y = pos_st.y
					--
					local par_st = getPartitionId(pos_st)
					local par_end = getPartitionId(pos_end)

					if par_st and par_end then 
						local pass_tab = map_partition[par_st].pass_partition[par_end]
						if pass_tab and #pass_tab > 0 then 
							local is_need_add_b = true
							for i = 1, #pass_tab do
								local partition_id = pass_tab[i]
								if not partition_id then
									portDistance = getDistance(AStar:searchPath(pos_now.x, pos_now.y, pos_end.x, pos_end.y, 1)) + portDistance  --路径
									pos_now.x = pos_end.x
									pos_now.y = pos_end.y
									is_need_add_b = false
								else 
									local pos = map_partition[partition_id].key_pos
									local tmp_goal_pos = ccp(pos[1], pos[2])
									portDistance = getDistance(AStar:searchPath(pos_now.x, pos_now.y, tmp_goal_pos.x, tmp_goal_pos.y, 1)) + portDistance  --路径
									pos_now.x = tmp_goal_pos.x
									pos_now.y = tmp_goal_pos.y
								end 
							end 
							if is_need_add_b then
								portDistance = portDistance + getDistance(AStar:searchPath(pos_now.x, pos_now.y, pos_end.x, pos_end.y, 1))  --路径
							end
						else
							portDistance = portDistance + getDistance(AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1))  --路径
						end 
					else
						portDistance = portDistance + getDistance(AStar:searchPath(pos_st.x, pos_st.y, pos_end.x, pos_end.y, 1))  --路径
					end

					if not port_distance_info[i] then
						port_distance_info[i] = {}
					end
					port_distance_info[i][j] = portDistance
					print("===============portToRelic Distance i="..i.." j="..j.." dis="..portDistance.." order_n = "..order_n)
				end
			end
		end
	end
	if is_all_out then
		table.save(port_distance_info, "scripts/game_config/port/port2relic_distance_info.lua")
	else
		table.save(port_distance_info, "scripts/game_config/port/port2relic_distance_info"..order_n.. ".lua")
	end
	if is_save_save_date_again then
		saveRelicDisInfo()
	end
end

local function saveRelicDisInfo()
	local relic_info = require("transfrom/relic_info")
	local port_info=require("transfrom/port_info")
	local dis_info=require("scripts/game_config/port/port2relic_distance_info")
	local port2relic_save_dis_info = {}
	for i = 1, #port_info do
		local port_x = port_info[i].ship_pos[1]
		local port_y = port_info[i].ship_pos[2]
		local info = {}
		for j = 1, #relic_info do
			local relic_x = relic_info[j].ship_pos[1]
			local relic_y = relic_info[j].ship_pos[2]
			info[j] = {[1] = port_x, [2] = port_y, [3] = relic_x, [4] = relic_y}
			info[j][5] = dis_info[i][j]
		end
		port2relic_save_dis_info[i] = info
	end
	table.save(port2relic_save_dis_info, "transfrom/iwork/port2relic_save_dis_info.lua")
end

local function transPortToWpDistance()
	local port_distance_info = {}
	local portDistance = 0
	local portLen = #port_info
	local wpLen = #explore_whirlpool
	for i=1,portLen do
		for j=1,wpLen do
			portDistance = 0
			portDistance = transformUtil.calculatePosToPosDistance(port_info[i].ship_pos, explore_whirlpool[j].sea_pos)

			if not port_distance_info[i] then
				port_distance_info[i] = {}
			end
			port_distance_info[i][j] = portDistance
			print("=============================portToWp Distance i="..i.." j="..j.." dis="..portDistance)
		end
	end

	table.save(port_distance_info, "scripts/game_config/port/port2wp_distance_info.lua")
end

local function transCampSiteInfo()
	local campsite_site_info = require("transfrom/campsite_site_info")
	local campSiteInfo = {}

	for k, v in pairs(campsite_site_info) do
		local site = v
		for key, val in pairs(v) do
			if key == "port" then
				local port_info = require("game_config/port/port_info")
				for pK, pV in pairs(port_info) do
					if pV.name == site["port"] then
						site["port"] = pK
					end
				end
			end
		end
		if campSiteInfo[site["port"]] == nil then
			campSiteInfo[site["port"]] = {}
		end

		campSiteInfo[site["port"]][site["level"]] = v
	end

	table.save(campSiteInfo, "scripts/game_config/camp/campsite_site_info.lua")
end

local function transCampMissonInfo()
	local campsite_mission_info = require("transfrom/campsite_mission_info")
	local random_loot_info = require("game_config/random/random_loot_info")
	local campMissionInfo = {}

	for k, v in pairs(campsite_mission_info) do
		local rateReward = {}
		local mission = v
		local oldReward = mission.rate_rewards

		for k1, v1 in pairs(oldReward) do

			local lootTab = random_loot_info[v1]
			if lootTab then
				local meterial = {}
				for key, value in pairs(lootTab.loot_table) do
					if value.type=='exp' then
						rateReward["exp"] = value.amount
					elseif value.type == 'cash' then
						rateReward["silver"] = value.amount
					elseif value.type =='gold' then
						rateReward["gold"] = value.amount
					elseif value.type == "honour" then
						rateReward["honour"] = value.amount
					elseif value.type == "keepsake" then
						if not rateReward["keepsake"] then
							rateReward["keepsake"] = {}
						end
						rateReward["keepsake"][#rateReward["keepsake"] + 1] = {id=value.id,amount=value.amount}
					elseif  value.type == 'material' then

						if not rateReward["material"] then
							rateReward["material"] = {}
						end

						rateReward["material"][#rateReward["material"] + 1] = {id = value.id, amount = value.amount}
					elseif value.type == 'item' then
						if not rateReward["item"] then
							rateReward["item"] = {}
						end
						rateReward["item"][#rateReward["item"] + 1] = {id = value.id,amount = value.amount}
					end
				end
				mission.rate_rewards = rateReward
			end
		end

		campMissionInfo[k] = mission
	end

	table.save(campMissionInfo, "scripts/game_config/camp/campsite_mission_info.lua")
end

local function transGuildMap()  -- 公会战地图导表
	print("创建地图")
	local map = CCTMXTiledMap:create("F:/work/dahanghai/document/tilemap/tools/stronghold.tmx")

	local landLayer2 = map:layerNamed("sand")
	local inlandLayer = map:layerNamed("inland")

	local waveLayer  = map:layerNamed("slow") -- 减速带

	local tiles_width = map:getMapSize().width
	local tiles_height = map:getMapSize().height
	local arr = {}
	print("初始化地图")

	local function isLand(i, j) -- 0 陆地, 1 海面， 2 减速带
		if waveLayer:tileGIDAt(ccp(i, j))~= 0 then
			return 2 -- 2 减速带
		elseif inlandLayer:tileGIDAt(ccp(i, j))~= 0   -- 陆地
			   or landLayer2:tileGIDAt(ccp(i, j))~= 0
			then
			return 0 -- 0 陆地
		end
		return 1     -- 1 海面
	end


	for y = 0, tiles_height-1   do -- map[height][width]
		for x = 0, tiles_width-1  do
			if not arr[y*tiles_width+x+1] then
				local tmp = isLand(x, y)
				arr[y*tiles_width+x+1] = tmp
			end
		end
	end
	print("初始化地图结束")
	print(#arr)
	print(isLand(64, 36))
	table.save_map(arr, "scripts/game_config/explore/guild_map.lua")
end


function transform()
--  transPortGood()
-- transPort()
-- transClosePort()
 -- transGoods()
-- transEquip()
--transBoat()
	-- tranEquipUpgrade()
 -- transReward()
-- transSailor()
 -- transSailorJob()
-- transSkill()
	-- transAchive()
 -- transBaozang()
	-- transRelic()
-- transRelicAnswers()
-- transExploreEvent()
 	-- tranShop()
	 -- transBattleinfo()
	 --transBattleinfo_jy()
 -- transMission_1()
 -- transMission_2()
 -- transMission_3()
 -- transMission_4()
	-- transUpgrade()
-- 	transXunbao()
-- 	transEquip()
--  transNewAchieve()
 	-- transMap()
 --	transGuildMap()
-- transPortPveInfo()
-- transAreaMissionInfo()
-- transPortToPortDistance()
-- transPortToShDistance()
-- transPortToWpDistance()
-- transPortToRelicDistance()
-- saveRelicDisInfo()
--transCampSiteInfo()
--transCampMissonInfo()
end

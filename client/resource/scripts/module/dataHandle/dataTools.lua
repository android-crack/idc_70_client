--数据封装防止修改数据
local boat_info=require("game_config/boat/boat_info")
local boat_attr=require("game_config/boat/boat_attr")
local goods_info=require("game_config/port/goods_info")
local sailor_info=require("game_config/sailor/sailor_info")
local port_info=require("game_config/port/port_info")
local port_type_info=require("game_config/port/port_type_info")
local skill_info=require("game_config/skill/skill_info")
local skill_site=require("game_config/skill/skill_site")
local port_set=require("game_config/port/portSet")
local small_people_info=require("game_config/port/small_people_info")
local port_locks=require("game_config/port/port_lock")
local battle_type_info = require("game_config/battle/battle_type_info")
local port_lock_good=require("game_config/port/port_lock_good")
local equip_material_info = require("game_config/boat/equip_material_info")
local equip_upgrade_info = require("game_config/equip/equip_upgrade_info")
local baowu_info = require("game_config/collect/baozang_info")
local propItem = require("game_config/propItem/item_info")
local info_title = require("game_config/title/info_title")
local ui_word = require("game_config/ui_word")
local baowu_primary_attr = require("game_config/collect/baowu_primary_attr")
local baowu_subprime_attr = require("game_config/collect/baowu_subprime_attr")
local area_info = require("game_config/port/area_info")

local tool={}

local type_map = 
{
	[ITEM_INDEX_MATERIAL] = equip_material_info,
	-- ITEM_INDEX_DARWING = 2
	-- ITEM_INDEX_EQUIP = 3
	-- ITEM_INDEX_GOODS = 4
	[ITEM_INDEX_CASH] = {res = "#common_icon_coin.png"},
	[ITEM_INDEX_EXP] = {res= "exp"},
	[ITEM_INDEX_GOLD] = {res = "gold"},
	[ITEM_INDEX_TILI] = {res = "tili"},
	[ITEM_INDEX_HONOUR] = {res = "#common_icon_honour.png"},
}

local bag_info_table = {
	[BAG_PROP_TYPE_SAILOR_BAOWU] = baowu_info,
	[BAG_PROP_TYPE_BOAT_BAOWU] = baowu_info,
	[BAG_PROP_TYPE_ASSEMB] = equip_material_info,
	[BAG_PROP_TYPE_COMSUME] = item_info,
	[BAG_PROP_TYPE_FLEET] = boat_attr,
}

local dataInfoTable = {
	[ITEM_INDEX_GOODS] = goods_info,
	[ITEM_INDEX_BAOWU] = baowu_info,
	[ITEM_INDEX_PROP] = propItem,
	[ITEM_INDEX_MATERIAL] = equip_material_info,
}


--过滤技能：有子技能过滤主技能，没有子技能显示主技能
tool.getSkillInfo = function(self, sailor)
	local sailorData = getGameData():getSailorData()
	local skills = table.clone(sailor.skills)
	local skillData = {}
	for k1,v1 in pairs(skills) do  
		table.insert(skillData, v1)
	end
	
	--技能排序
	table.sort( skillData, function ( a, b ) 
		local a_initiative, b_initiative = 0, 0
		if tonumber(skill_info[b.id].initiative) == 1 then
			b_initiative= 2
		elseif tonumber(skill_info[b.id].initiative) == 2 then
			b_initiative= 1
		end
		if tonumber(skill_info[a.id].initiative) == 1 then
			a_initiative = 2
		elseif tonumber(skill_info[a.id].initiative) == 2 then
			a_initiative = 1
		end
		if b_initiative == a_initiative then
			aQuality = tonumber(skill_info[a.id].quality)
			bQuality = tonumber(skill_info[b.id].quality)
			return aQuality > bQuality
		else
			return a_initiative > b_initiative
		end
	end )
	return skillData
end

tool.getItem = function(self, item_type, item_id)
	local dataInfo = dataInfoTable[item_type]
	if dataInfo == nil then return nil end
	
	return dataInfo[item_id]
end

tool.getPort = function(self, id)
	local t=port_info[id]
	if not t then cclog(T("错误的港口索引id")..id) return nil end
	local port=table.clone(t)
	port.id=id
	
	return port
end

tool.getPortTypeConfig = function(self, portType)
	local t=port_type_info[portType]
	if not t then cclog(T("错误的港口类型type")..portType) return nil end
	local portTypeConfig=table.clone(t)
	return portTypeConfig
end

tool.getPortLocks = function(self, portId)
	local t=port_locks[portId]
	if not t then cclog(T("找不到解锁的列表")) return end
	return table.clone(t)
end

tool.getPortLockGoods = function(self, portId)
	local t=port_lock_good[portId]
	if not t then cclog(T("找不到解锁商品的列表") .. portId) return end
	return table.clone(t)
end

tool.getPortSet = function(self, id)
	local t=port_set[id]
	if not t then cclog(T("错误的港口类型索引id错误")..id) return nil end
	local portSet=table.clone(t)

	portSet.res="ui/port/bg/"..portSet.res
	return portSet
end

tool.getPeople = function(self, id)
	local t=small_people_info[id]
	if not t then cclog(T("错误的小人索引id")..id) return nil end
	return table.clone(t)
end

tool.getSailor = function(self, id)
	local t=sailor_info[tonumber(id)]
	if not t then cclog(T("错误的水手索引id"),id) return nil end
	return table.clone(t)
end

tool.getSkill = function(self, id)
	if not id then 
		cclog(T("技能id为nil"))
		return
	end
	local t=skill_info[id]
	if not t then cclog(T("错误的技能索引id")..id) return nil end
	t.id=id
	return table.clone(t)
end

tool.getSkillSite = function(self, id)
	if not id then 
		cclog(T("技能位置索引id为nil"))
		return
	end
	local t=skill_site[id]
	if not t then cclog(T("错误的技能位置索引id "..id)) return nil end
	local skills={}
	for k, skill in pairs(t) do
		skills[k]={level=0,site=skill.site}
	end
	return skills
end

tool.getBoat = function(self, id)
	if not id then
		return
	end
	local t = boat_info[id]
	if not t then
		return
	end
	return table.clone(t)
end

tool.getNewBoat = function(self, id)
	if not id then
		return
	end
	local t = boat_attr[id]
	if not t then
		return
	end
	return table.clone(t)
end

tool.getGoods = function(self, id)
	local t=goods_info[id]
	if not t then cclog(T("错误的商品索引id")..id) return nil end
	return table.clone(t)
end

tool.getTitle = function(self, id)
	local t = info_title[id]
	if not t then return nil end
	return table.clone(t)
end

tool.getTimeStr = function(self, value) --分
	local str=""
	local d=math.modf(value/(24*60))
	local h=math.modf((value-d*(24*60))/60)
	local m=math.floor(value-d*(24*60)-h*60+0.5)

	if d>0 then str=d.."d " end
	if h>0 then str=str..h.."h " end
	if m>0 then str=str..m.."m" end

	return str
end

tool.getTimeStr1 = function(self, value) --秒
	local value = value/60
	local str=""
	local d=math.modf(value/(24*60))
	local h=math.modf((value - d*(24*60))/60)
	local m=math.floor(value - d*(24*60) - h*60 + 0.5)

	if d>0 then str=d.."d " end
	if h>0 then str=str..h.."h " end
	if m>0 then str=str..m.."m" end

	return str
end

tool.getTimeStr4 = function(self, value) --天 ，时
	local str="0"
	local d=math.modf(value/(24*60*60))
	local h=math.modf((value - d*(24*60*60))/(60*60))

	if d>0 then str=d.."d " end
	if h>=0 then str=str..h.."h " end

	return str	
end

tool.getTimeStr2 = function(self, value) --时：分：秒
	local str=""
	local h=math.modf((value)/(60*60))
	local m=math.modf((value-h*60*60)/60)
	local s=math.ceil(value-h*60*60-m*60)

	if h>0 then str=str..h.."h " end
	if m>0 then str=str..m.."m " end
	if s>0 then str=str..s.."s"	end

	return str
end

tool.getTimeStrNormal = function(self, value, not_need_hour, not_need_second) --00：00：00
	local str=""
	local h=math.modf((value)/(60*60))
	local m=math.modf((value-h*60*60)/60)
	local s=math.ceil(value-h*60*60-m*60)

	if not not_need_hour then
		if h < 10 then 
			str = str .. "0" .. h .. ":"
		else
			str = str .. h .. ":" 
		end
	end

	if m < 10 then 
		str = str .. "0" .. m
	else
		str = str .. m
	end

	if not not_need_second then
		str = str .. ":"
		if s < 10 then 
			str = str .. "0" .. s .. ""
		else
			str = str .. s
		end
	end

	return str
end

tool.getZnTimeStr = function(self, value)--统一规则   秒  保留前三位
	local str=""
	local d=math.modf(value/(24*60*60))
	local h=math.modf((value-d*24*60*60)/(60*60))
	local m=math.modf((value-d*24*60*60-h*60*60)/60)
	local s=math.ceil(value-d*24*60*60-h*60*60-m*60)
	if d>0 then
		str=d.."d "
		if h>0 or m>0 then str=str..h.."h " end
		if m>0 then str=str..m.."m" end
	else
		if h>0 then str=str..h.."h " end
		if m>0 or s>0 then str=str..m.."m" end
		if s>0 then str=str..s.."s"	end
	end
	return str
end

--VIP特权使用
tool.getZnTimeStrForVip = function(self, value)--统一规则   秒  保留前三位
	local str=""
	local d=math.ceil(value/(24*60*60))
	local h=math.modf((value-d*24*60*60)/(60*60))
	local m=math.modf((value-d*24*60*60-h*60*60)/60)
	local s=math.ceil(value-d*24*60*60-h*60*60-m*60)
	if d > 0 then
	   return d
	elseif h > 0 or m >0 or s >0 then
	   return 1
	else
	   return -1
	end
end

-- 根据时间戳转换成当天的第X秒
tool.getTimeIntraday = function(self, time)
	return (time + 28800) % 86400
end

tool.getCnTimeStr = function(self, value, not_need_second)--统一规则   秒  保留前三位
	local str=""
	local d=math.modf(value/(24*60*60))
	local h=math.modf((value-d*24*60*60)/(60*60))
	local m=math.modf((value-d*24*60*60-h*60*60)/60)
	local s=math.ceil(value-d*24*60*60-h*60*60-m*60)

	if d>0 then
		str=d..ui_word.COMMON_DAY.." "
		if h>0 or m>0 then str=str..h..ui_word.COMMON_HOUR.." " end
		if m>0 then str=str..m..ui_word.COMMON_MIN end
	else
		if h>0 then str=str..h..ui_word.COMMON_HOUR.." " end
		if m>0 or s>0 then str=str..m..ui_word.COMMON_MIN end
		if not not_need_second then
			if s>0 then str=str..s..ui_word.COMMON_SECOND	end
		end
	end
	return str
end

tool.getMostCnTimeStr = function(self, value) --统一规则  保留最高两位
	local str=""
	local d = math.modf(value / (24 * 60 * 60))
	local h = math.modf((value - d * 24 * 60 * 60) / (60 * 60))
	local m = math.modf((value-d*24*60*60-h*60*60)/60)
	local s = math.ceil(value - d * 24 * 60 * 60 - h * 60 * 60 - m * 60)
	local timeTable = {["d"] = d,["h"] = h ,["m"] = m ,["s"] = s}
	if d > 0 then
		str = d .. "d "
		if h > 0 then str = str .. h .. "h " end
	elseif (h > 0) then
		if h > 0 then str = str .. h .. "h " end
		if m > 0 then str=str..m.."m" end
	elseif m > 0 then
		if m > 0 then str=str..m.."m" end
		if s > 0 then str=str..s.."s"	end
	elseif s > 0 then
		str = str .. s .. "s"
	end

	return str, timeTable
end

tool.getTimeStr3 = function(self, value) --统一规则   秒  保留前三位,只显示天和小时
	local str = ""
	local d = math.modf(value / (24 * 60 * 60))
	local h = math.modf((value - d * 24 * 60 * 60) / (60*60))
	local ret = {}
	if d > 0 then
		str = d .. ""
		ret.str = str
		ret.day = true
	else
		if h > 0 then 
			str = str .. h 
		else
			str = str .. 1 
		end
		ret.str = str
		ret.h = true
	end
	return ret
end

local battlePorwerConsume =
	{
		[1] = {["level"] = 40, ["power"] = 1},
		[2] = {["level"] = 80, ["power"] = 2},
		[3] = {["level"] = 200, ["power"] = 3},
	}

--[[
--rewards :{{["type"] = "item", ["id"] = 1001, ["amount"] = 300},{}}
--return {{["key"] = 15, ["id"] = 1001, ["value"] = 300},{}}
]]
tool.getRewardData = function(self, data)
	local rewards = {}
	for k, v in pairs(data) do
		local reward = {}
		if v.type == "exp" then
			reward["key"] = ITEM_INDEX_EXP
		elseif v.type == "cash" then
			reward["key"] = ITEM_INDEX_CASH
		elseif v.type =='gold' then
			reward["key"] = ITEM_INDEX_GOLD
		elseif v.type == "honour" then
			reward["key"] = ITEM_INDEX_HONOUR
		elseif v.type == "keepsake" then
			reward["key"] = ITEM_INDEX_KEEPSAKE
		elseif  v.type == "material" then
			reward["key"] = ITEM_INDEX_MATERIAL
		elseif v.type == "item" then
			reward["key"] = ITEM_INDEX_PROP
		elseif v.type == "baowu" then
			reward["key"] = ITEM_INDEX_BAOWU
		end
		reward["value"] = v.amount
		reward["id"] = v.id
		rewards[#rewards + 1] = reward
	end
	return rewards
end

--[[
根据类型，id，获取对应的图标资源，
type 是和服务端共同协定的
]]-- 
tool.getItemRes = function(self, type, id)
	if not id  then return nil end

	--金币
	if type == 7 then
		return "#common_icon_diamond.png"
	end
	--银币
	if type == 5 then
		return "#common_icon_coin.png"
	end

	--荣誉
	if type == 9 then
		return "#common_icon_honour.png"
	end

	--食物
	if type == ITEM_INDEX_FOOD then
		return "#explore_food.png"
	end

	if id < 1 then return nil end

	--材料
	if type == 1 then
		if equip_material_info and equip_material_info[id] then
			return equip_material_info[id].res
		end
	--图纸
	end

	if type == 2 then
		local config = require("game_config/equip/equip_drawing_info")
		if config and config[id] then
			return config[id].res
		end
	end
	
	--物品
	if type == ITEM_INDEX_GOODS then
		local goods_info = require("game_config/port/goods_info")
		if goods_info and goods_info[id] then
			return goods_info[id].res
		end 
	end

	if type == 10 then
		local config = require("game_config/collect/baozang_info")
		if config and config[id] then
			return config[id].res
		end 
	--道具
	end
	if type == ITEM_INDEX_PROP then
		local config = require("game_config/propItem/item_info")
		if config and config[id] then
			return config[id].res
		end
	--信物
	end

	if type == 14 then
		local STAR = {
			[1] = "E",
			[2] = "D",
			[3] = "C",
			[4] = "B",
			[5] = "A",
			[6] = "S"
		}
		return string.format("#keepsake_s_%s.png", STAR[id])
	end

	return nil
end

tool.getShipyardMapRes = function(self, type, id)
	if type == ITEM_INDEX_PROP then
		local config = require("game_config/propItem/item_info")
		if config and config[id] then
			return config[id].shipyard_map
		end
	end
end

--todo 想办法弄成自动获取所有配置的类型，或者根据策划需求添加新类型
tool.stringToIconResType = function(self, key)
	local types = 
	{
		["exp"] = ITEM_INDEX_EXP,
		["cash"] = ITEM_INDEX_CASH,
		["gold"] = ITEM_INDEX_GOLD,
		["honour"] = ITEM_INDEX_HONOUR,
		["keepsake"] = ITEM_INDEX_KEEPSAKE,
		["material"] = ITEM_INDEX_MATERIAL,
		["item"] = ITEM_INDEX_PROP,
		["baowu"] = ITEM_INDEX_BAOWU,
	}
	
	return types[key]
end

tool.getBattleTypeInfo = function(self, id)
	local t = battle_type_info[id] 
	if t then return table.clone(t) end
end

tool.getFight = function(self, fightId, battleType) --获取战役里面的战斗
	local battle_info_config_data = getGameData():getBattleInfoConfigData()
	local battle_info = battle_info_config_data:getBattleConfigFileInfo(battleType)
	local t = battle_info[fightId] 
	if t then return table.clone(t) end
end

tool.getSailorIcon = function(self, id)
	local sailor = sailor_info[id]
	local res = ""
	if sailor then 
		res = sailor.res
	end
	return res
end

tool.getBoatFiType = function(self, boat_type)
	local boat = boat_attr[boat_type]
	local fi_type = 1
	if boat and boat.fi_type and boat.fi_type > 0 then
		fi_type = boat.fi_type
	end
	return fi_type
end

tool.getBoatFiTypeRes = function(self, fi_type)
	local BOAT_TYPE_RES = {
		"common_ship_type_near.png",
		"common_ship_type_far.png",
		"common_ship_type_defense.png",
		"common_ship_type_speed.png",
		"common_ship_type_trade.png",
	}
	return BOAT_TYPE_RES[fi_type]
end

tool.getBoatEquipInfo = function(self, kind, level)
	local upgrade_data = nil
	for k,v in pairs(equip_upgrade_info) do
		if v.kind == kind and v.total_lv == level then
			return v
		end
	end
	return upgrade_data
end

tool.getBoatQualityName = function(self, level)
	local quality_name = {
		{name = ui_word.QUALITY_LV1, color = COLOR_WHITE_STROKE},
		{name = ui_word.QUALITY_LV2, color = COLOR_GREEN_STROKE},
		{name = ui_word.QUALITY_LV3, color = COLOR_BLUE_STROKE},
		{name = ui_word.QUALITY_LV4, color = COLOR_PURPLE_STROKE},
		{name = ui_word.QUALITY_LV5, color = COLOR_ORANGE_STROKE},
		{name = ui_word.QUALITY_LV6, color = COLOR_ORANGE_STROKE},
	}
	local index = math.min(level, #quality_name)
	return quality_name[index]
end

tool.getOldPlotList = function(self, plot_file_name)
	if not plot_file_name or plot_file_name == "" then return end
	local data_path = "game_config/battles/" .. plot_file_name
	local data = require(data_path)
	if data == nil then return end
	return data
end

local role_txt = {
	[TAB_ADVENTURE] = "adventure",
	[TAB_NAVY] = "navy",
	[TAB_PIRATE] = "pirate",
}

tool.getRoleNameByRoleId = function(self, role_id)
	local LEN = 8  -- 名字长度
	local file_path = string.format("game_config/role/%s_name", role_txt[role_id])
	local name_info = require(file_path)

	local info = name_info[math.random(#name_info)] --随机一个名
	local len = LEN - info.surnameLen
	local names = {}
	for k, v in pairs(name_info) do
		if v.nameLen <= len then--姓的长度要符合
			table.insert(names, v.name)  --找到所有能用的姓
		end
	end
	local name = names[math.random(#names)]--随机出一个姓
	return string.format("%s%s", name, info.surname)
end

--获得宝物的属性信息, 默认第一个为主属性
-- 	ap = {text = ui_word.ATTR_SWORD_NAME},
	-- 	hp = {text = ui_word.ATTR_HP_NAME},
	-- 	remote_attack = {text = ui_word.FLEET_FAR_PORPERTY}, 
	-- 	melee_attack = {text = ui_word.FLEET_NEAR_PORPERTY},
	-- 	speed = {text = ui_word.ATTR_SPEED_NAME},
	-- 	defense = {text = ui_word.ATTR_DEFENSE_NAME},
	-- 	durable = {text = ui_word.ATTR_DURABLE_NAME},
	-- 	range = {text = ui_word.FLEET_PORPERTY_FAR_DIST},
	-- 	fire_rate = {text = ui_word.ATTR_ATTACK_SPEED_NAME, rate = 0.001, unit = ui_word.COMMON_SECOND},--：攻击速度
	-- 	baoji = {text = ui_word.ATTR_CRIT_NAME, rate = 0.1, unit = "%"},--暴击
	-- 	dodge = {text = ui_word.ATTR_DODGE_NAME, rate = 0.1, unit = "%"},--闪避
	-- 	minus_cd = {text = ui_word.ATTR_SKILL_CD_REDUCE_NAME, rate = 0.1, unit = "%"}, --技能cd降低
tool.getBaowuAttrInfo = function(self, attrs_data, baowu_step)
	local attr_list = {}
	local color_list = {
		[1] = COLOR_BLUE_STROKE,
		[2] = COLOR_PURPLE_STROKE,
		[3] = COLOR_ORANGE_STROKE,
		[4] = COLOR_YELLOW_STROKE,
	}
	local attr_info
	for k, v in ipairs(attrs_data) do
		local attr_name = ""
		local attr_desc = ""
		local attr_value = v.value
		local attr_color = nil
		local attr_percent = 0
		local range_info
		local is_essence = false
		local fi_type = nil
		attr_info = baowu_primary_attr[v.id]
		if attr_info then --主属性
			attr_name = attr_info.name
			if baowu_step then
				local limit_t = attr_info[STAR_SPRITE_SMALL[baowu_step] .. "_range"]
				local limit_value = limit_t[1].value
				local limit_last = limit_t[#limit_t].value
				attr_percent = (attr_value - limit_value[1]) / (limit_last[2] - limit_value[1]) * 100
				attr_percent = math.max(0, attr_percent)
				range_info = limit_value[1] .. "~" .. limit_last[2]
			end
			attr_desc = attr_name .. " +" .. attr_value
		else 
			--附加属性，有多个，区别开技能的类型信息
			attr_info = baowu_subprime_attr[v.id]
			is_essence = attr_info.is_essence == 1
			fi_type = attr_info.type_icon
			local cur_attr_value = attr_value / attr_info.rate
			if attr_info.attr == "sailor_skill" then
				attr_name = skill_info[tonumber(attr_info.range_color[1].value[1])].short_name
				attr_desc = string.format(attr_info.desc_single, attr_name, cur_attr_value)
				attr_color = attr_info.range_color[1].color
			else
				attr_desc = string.format(attr_info.desc_single, cur_attr_value)
				for i,v in ipairs(attr_info.range_color) do
					if not attr_color then
						if attr_value <= v.value[2] then
							attr_color = v.color
						end
					end
				end
				if not attr_color then
					print("========================attr_color is nil")
					table.print(v)
				end
				if attr_info.rate then
					attr_value = attr_value / attr_info.rate
					attr_value = string.format("%.2f", attr_value)
					attr_value = string.format("%.2g", attr_value)
				end
			end
		end
		if attr_color then
			attr_color = color_list[attr_color]
		end
		attr_list[v.order + 1] = {id = v.id, name = attr_name, value = attr_value, percent = attr_percent, desc = attr_desc, color = attr_color, type = attr_info.attr, range = range_info, is_essence = is_essence, fi_type = fi_type}
	end
	return attr_list
end

--根据繁荣度获取投资等级
tool.getCurInvestLevel = function(self, curProsper)
	local prosper_info = require("game_config/prosper/prosper_info")
	if curProsper >= prosper_info[#prosper_info].prosper then
		return #prosper_info
	end
	for k, v in ipairs(prosper_info) do
		if curProsper < v.prosper then
			return k - 1
		elseif curProsper == v.prosper then
			return k
		end
	end
end

tool.getBoatBaowuAttr = function(self, key, value)
	if not key then return value end

	local base_attr_info = require("game_config/base_attr_info")
	local attr_config = base_attr_info[key]
	local str = " +" .. (value * attr_config.rate) .. attr_config.unit
	return str
end

tool.getBaowuSpecialAttr = function(self, key, value)
	if not key then return value end

	local base_attr_info = require("game_config/base_attr_info")
	local attr_config = base_attr_info[key]
	local str = " +" .. (value * attr_config.rate_1) .. attr_config.unit_1
	return str
end

--计算宝物评定等级
tool.calBaowuStarLevel = function(self, refine_attr, baowu_config)
	local attr_change_per = 0
	local special_num = 0
	for i,attr_info in ipairs(refine_attr) do
		local cur_attr = attr_info.attr or attr_info.name
		if attr_info and attr_info.value and cur_attr then
			local attr_limit = baowu_config[cur_attr.."_limit"]
			if attr_limit then
				attr_change_per = attr_change_per + math.floor(attr_info.value / attr_limit* 100 + 0.0000000000001)
			end
			for k,attr_name in ipairs(baowu_config.special_attrs) do
				if attr_name == cur_attr then
					special_num = special_num + 1
				end
			end
		end
	end
	local baowu_refine_rank = require("game_config/collect/baowu_refine_rank")
	local refine_max_level = 0
	for i,v in ipairs(baowu_refine_rank) do
		if v.special_attr <= special_num then
			refine_max_level = i
		end
	end
	local attr_per = attr_change_per/4
	for i=1,refine_max_level do
		local rank_data = baowu_refine_rank[i]
		if rank_data.per >= attr_per then
			return i - 1
		end
	end
	return refine_max_level
end

tool.getNameWithAreaName = function(self, area_id, name)
	if not area_id or not area_info[area_id] then return name end

	return string.format(ui_word.ARENAA_MATCH_OPPONENT_NAME, area_info[area_id].name, name)
end


return tool
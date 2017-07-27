--登陆&VIP奖励数据控制器，其实协议的请求（ask开头的函数）应该放在rpc_前缀的lua文件中比较好:)
--配置
local loginAwardConfig=require("game_config/reward/login_reward")
local vipAwardConfig=require("game_config/reward/chongzhi_reward")
local sailorJobs=require("game_config/sailor/id_job")
local tool = require("module/dataHandle/dataTools")
local item_info = require("game_config/propItem/item_info")
local equip_material_info = require("game_config/boat/equip_material_info")
local bao_zang_info = require("game_config/collect/baozang_info")
local boat_info = require("game_config/boat/boat_info")
local boat_attr = require("game_config/boat/boat_attr")
local ui_word = require("game_config/ui_word")

local handler = class("LoginRewardData")

handler.LOGIN_AWARD_MAX_DAY = #loginAwardConfig --最大登陆天数
handler.VIP_AWARD_MAX_LEV = #vipAwardConfig --最大vip等级
handler.VIP_AWARD_SHOW_MAX_NUM = 5 --最多显示出来的vip奖励项

--领取状态
handler.AWARD_HASGETED_STATUS = 0 --已领取
handler.AWARD_CANGET_STATUS = 1  --可领取
handler.AWARD_CANNOTGET_STATUS = 2  --不可领取

-------------------------------请求/响应后端数据-------------------------------

function handler:ctor()
	self.needNotify = false
	self.isReqGetLoginAwarding = false

	self.loginAwardInfo = {
		["loginDay"] = 0, --当前连续登陆天数
		["isSpeAward"] = false, --是否为特殊奖励
		["hasGetedDay"] = 0, --已经领取了奖励的登陆天数
	}
	self.vipAwardInfo = {
		["vipLev"] = 0, --当前VIP等级
		["hasGetedLevs"] = {}, --已经领取了奖励的vip等级数组
		["awardStateDic"] = {}, --vip等级奖励领取状态字典，key为vip等级，value为true或false，true表示已领取，false则相反
		["minShowLev"] = 0, --可以展示出来的最小vip等级
		["maxShowLev"] = 0, --可以展示出来的最大vip等级
		["hasPayedMoney"] = 0, --已经充值多少钱
	}

	self.login_pop_data = {
		["is_login_reward_pop"] = 0, --是否需要弹出登录奖励
		["is_legend_activity_pop"] = 1, --是否需要弹出传说活动
		["boat_reform_data"] = {}, --是否获得的改造船数据，保存对应的船的key以及id
	}
	self.idle_awrd_info = nil
end

--一键领取登陆奖励
function handler:askGetLoginAwards()
	GameUtil.callRpc("rpc_server_get_login_and_vip_reward", {},"rpc_client_get_login_and_vip_reward")
end

--请求每日登陆奖励
function handler:askGetLoginAward()
	GameUtil.callRpc("rpc_server_huodong_login_reward_get_all",{})
end

--请求领取VIP奖励
function handler:askGetVipAward(vipLev)
	GameUtil.callRpc("rpc_server_huodong_login_reward_get_chongzhi", {vipLev},"rpc_client_huodong_login_reward_get_chongzhi")
end

function handler:receiveLoginVipAwardInfo(loginDay,hasGetedDay,isSpeAward,chongzhi,chongzhiId)
	local isSpeAwardBL = true
	if isSpeAward==0 then
		isSpeAwardBL = false
	end
	local curVipLev = 0
	local needMoney = 0
	for i=1,self.VIP_AWARD_MAX_LEV do
		needMoney = self:getAllNeedMoneyByLev(i)
		if chongzhi>=needMoney then
			curVipLev = i
		else
			break
		end
	end

	self:updateLoginAwardInfo(loginDay,isSpeAwardBL,hasGetedDay)
	self:updateVipAwardInfo(curVipLev,chongzhiId,chongzhi)

	--if self:hasLoginAwardToGet()==true or self:hasVipAwardToGet()==true then
	if self:hasLoginAwardToGet()==true then
		self.needNotify = true
	else
		self.needNotify = false
	end
end

function handler:receiveGetLoginAward(result, GetedLoginDays, vip_reward)
	if result==1 then
		--领取成功
		local has_vip_reward = false
		if vip_reward and vip_reward.amount >0 and vip_reward.type > 0 then
			has_vip_reward = true
		end
		--更新数据
		--self:updateLoginAwardInfo(self.loginAwardInfo["loginDay"],self.loginAwardInfo["isSpeAward"])
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsLoginAward = require("gameobj/quene/clsLoginAward")
		local close_func = function()
			local MainAwardUI = getUIManager():get("MainAwardUI")
			if MainAwardUI and not tolua.isnull(MainAwardUI) then
				MainAwardUI:updateUI()
			end
		end

		local get_login_reward_days = #GetedLoginDays
		local update_welfare_view = false
		for k,v in pairs(GetedLoginDays) do
			local curGetedLoginAConfig = self:getLoginACfgByDay(v,self.loginAwardInfo["isSpeAward"])
			if k == get_login_reward_days then
				update_welfare_view = true
			else
				update_welfare_view = false
			end
			if has_vip_reward then
				has_vip_reward = false
				--print("==============clsLoginAward======插入====1111=====")
				DialogQuene:insertTaskToQuene(clsLoginAward.new({reward = {day = v, config = curGetedLoginAConfig, vip_reward = vip_reward}, is_update_welfare = update_welfare_view, fun = close_func}))
			else
				--print("==============clsLoginAward======插入====2222=====")

				DialogQuene:insertTaskToQuene(clsLoginAward.new({reward = {day = v, config = curGetedLoginAConfig}, is_update_welfare = update_welfare_view,fun = close_func}))
			end
		end

	elseif result==2 then
		--领取失败
		--Alert:warning({msg = news.PORT_MARKET_SUCCESS.msg, size = 26})
	end
end

function handler:receiveGetVipAward(result,curGetedViplev)
	if result==1 then
		--领取成功

		--更新数据
		--self:updateVipAwardInfo(self.vipAwardInfo["vipLev"],curGetedViplev)

		local curGetedVipAConfig = self:getVipACfgByLev(curGetedViplev)

		EventTrigger(EVENT_LOGIN_VIP_AWARD_GET_SUC,2,0,curGetedViplev,curGetedVipAConfig)
	elseif result==2 then
		--领取失败
		--Alert:warning({msg = news.PORT_MARKET_SUCCESS.msg, size = 26})
	end
end

local function getStarNumberToString(num)
	local startNumberStringMap = {
		[1] = "e",
		[2] = "d",
		[3] = "c",
		[4] = "b",
		[5] = "a",
		[6] = "s",
	}
	return startNumberStringMap[num]
end

-------------------------------数据seter/geter/updater-------------------------------

--通过登陆天数获取对应的奖励配置
--isSpe：是否为特殊奖励
function handler:getLoginACfgByDay(day,isSpe)
	local config = loginAwardConfig[day]
	if config~=nil then
		if isSpe==true then
			config = loginAwardConfig[day][2]
			if config==nil then
				config = loginAwardConfig[day][1]
			end
		else
			config = loginAwardConfig[day][1]
		end
	end
	if config==nil then
		--找不到对应的配置
	elseif config["hasInitExtInfo"]==nil then
		config["hasInitExtInfo"] = true
		if config["subType"]==2 then
			local sailorInfo = tool:getSailor(config["id"])
			if sailorInfo~=nil then
				config["res"] = sailorInfo["res"]
				config["value"] = sailorInfo["name"]
				config["descr"] = sailorInfo["explain"]
				config["star"] = sailorInfo.star
				config["starRes"] = "#common_letter_"..getStarNumberToString(sailorInfo.star).."2.png"
				if sailorInfo.star == 6 then --6是s等级水手
					config["scale"] = 18
				else
					config["scale"] = 35
				end
				config["jobs"] = {}
				for k,v in pairs(sailorInfo.job) do
					table.insert(config["jobs"],{["res"]=string.format("#tag_%s.png",sailorJobs[v].job),["name"]=sailorJobs[v].name})
				end
			end
		end
		if config["subType"]==3 then
			config["res"] = boat_info[config.id].res
			config["value"] = boat_info[config.id].name
			config["descr"] = boat_info[config.id].explain
			local boat_star = boat_attr[config.id].quality
			--船的品阶已废除
			-- if boat_star == 100 then --传说船
				config["starRes"] = "#common_letter_legend.png"
			-- else
			-- 	config["starRes"] = "#common_letter_"..getStarNumberToString(boat_star).."2.png"
			-- end
			config["scale"] = 80
		end

		if config["subType"] == 5 then
			local item_id = config["res"]
			config["res"] = item_info[item_id].res
			config["count"] = config["value"]
			config["value"] = item_info[item_id].name
			config["descr"] = item_info[item_id].desc
			config["title"] = ui_word.LOGIN_VIP_AWARD_GET_TITLE3

			config["scale"] = 60

			config["id"] = item_id
		end

		if config["subType"] == 6 then
			local equip_material_id = config["res"]
			config["res"] = equip_material_info[equip_material_id].res
			config["count"] = config["value"]
			config["value"] = equip_material_info[equip_material_id].name
			config["descr"] = equip_material_info[equip_material_id].desc
			config["title"] = ui_word.LOGIN_VIP_AWARD_GET_TITLE3
			config["scale"] = 60
			config["id"] = equip_material_id
		end

		if config["subType"] == 7 then
			local baozang_id = config["res"]
			config["res"] = bao_zang_info[baozang_id].res
			config["count"] = config["value"]
			config["value"] = bao_zang_info[baozang_id].name
			config["descr"] = bao_zang_info[baozang_id].desc
			config["title"] = ui_word.LOGIN_VIP_AWARD_GET_TITLE3
			config["scale"] = 60
			config["id"] = baozang_id
		end
	end
	return config
end

--通过VIP等级获取对应的奖励配置
function handler:getVipACfgByLev(lev)
	local config = vipAwardConfig[lev]
	if config==nil then
		--找不到对应的配置
	elseif config["hasInitExtInfo"]==nil then
		config["hasInitExtInfo"] = true
		if config["subType"]==2 then
			local sailorInfo = tool:getSailor(config["id"])
			if sailorInfo~=nil then
				config["res"] = sailorInfo["res"]
				config["value"] = sailorInfo["name"]
				config["descr"] = sailorInfo["explain"]
				config["star"] = sailorInfo.star
				config["starRes"] = "#common_letter_"..getStarNumberToString(sailorInfo.star).."2.png"
				if sailorInfo.star == 6 then --6是s等级水手
					config["scale"] = 18
				else
					config["scale"] = 35
				end

				config["jobs"] = {}
				for k,v in pairs(sailorInfo.job) do
					table.insert(config["jobs"],{["res"]=string.format("#tag_%s.png",sailorJobs[v].job),["name"]=sailorJobs[v].name})
				end
			end
		end
		if config["subType"]==3 then
			--船舶图纸
			config["res"] = boat_info[config.id].res
			config["value"] = boat_info[config.id].name
			config["descr"] = boat_info[config.id].explain
			config["scale"] = 80

			local boat_star = boat_attr[config.id].quality
			if boat_star == 100 then --传说船
				config["starRes"] = "#common_letter_legend.png"
			else
				config["starRes"] = "#common_letter_"..getStarNumberToString(boat_star).."2.png"
			end
		end

		if config["subType"] == 5 then
			local item_id = config["res"]
			config["res"] = item_info[item_id].res
			config["value"] = item_info[item_id].name
			config["descr"] = item_info[item_id].desc
			config["title"] = ui_word.LOGIN_VIP_AWARD_GET_TITLE3
			config["scale"] = 70
		end

		if config["subType"] == 6 then
			local equip_material_id = config["res"]
			config["res"] = equip_material_info[equip_material_id].res
			config["value"] = equip_material_info[equip_material_id].name
			config["descr"] = equip_material_info[equip_material_id].desc
			config["title"] = ui_word.LOGIN_VIP_AWARD_GET_TITLE3
			config["scale"] = 70
		end
	end
	return config
end

--达到某一VIP等级需要充值的累积金额
function handler:getAllNeedMoneyByLev(lev)
	local allMoney = 0
	local config = nil
	for i=1,lev do
		config = vipAwardConfig[i]
		if config~=nil and config["payValue"]~=nil then
			allMoney = allMoney + config["payValue"]
		end
	end
	return allMoney
end

--更新登陆奖励数据
function handler:updateLoginAwardInfo(loginDay,isSpeAward,hasGetedDay)
	self.loginAwardInfo["loginDay"] = loginDay
	self.loginAwardInfo["isSpeAward"] = isSpeAward
	self.loginAwardInfo["hasGetedDay"] = hasGetedDay

	local MainAwardUI = getUIManager():get("MainAwardUI")
	if not tolua.isnull(MainAwardUI) then
		MainAwardUI:setData(self.loginAwardInfo)
	end
end

function handler:getVipCB()
end

--更新VIP奖励数据
function handler:updateVipAwardInfo(vipLev,hasGetedLevs,hasPayedMoney)
	self.vipAwardInfo["vipLev"] = vipLev
	self.vipAwardInfo["hasGetedLevs"] = hasGetedLevs
	self.vipAwardInfo["hasPayedMoney"] = hasPayedMoney

	for i=1,self.VIP_AWARD_MAX_LEV do
		self.vipAwardInfo["awardStateDic"][i]=false
		if i<=vipLev and self:isVipAwardPower(i)==true then
			--特权类奖励默认领取
			self.vipAwardInfo["awardStateDic"][i]=true
		end
	end
	for i=1,#hasGetedLevs do
		self.vipAwardInfo["awardStateDic"][hasGetedLevs[i]]=true
	end

	self.vipAwardInfo["minShowLev"] = self:getVipMinShowLev()
	self.vipAwardInfo["maxShowLev"] = self:getVipMaxShowLev()
end

--判断某VIP等级的奖励是否为特权类
function handler:isVipAwardPower(lev)
	local isPower = false
	local config = self:getVipACfgByLev(lev)
	if config~=nil and config["subType"]==4 then
		isPower = true
	end
	return isPower
end

--判断是否有登陆奖励可以领取
function handler:hasLoginAwardToGet()
	local hasAward = false
	for i=1,self.LOGIN_AWARD_MAX_DAY do
		local loginItemData = self:getLoginACfgByDay(i,self.loginAwardInfo["isSpeAward"])
		if loginItemData~=nil then
			loginItemData["day"] = i
			if loginItemData["day"]>self.loginAwardInfo["hasGetedDay"] then
				--未领取
				if loginItemData["day"]<=self.loginAwardInfo["loginDay"] then
					--可领取
					hasAward = true
					break
				else
					--不可领取
				end
			else
				--已领取
			end
		end
	end
	return hasAward
end

--判断某VIP等级的奖励是否已领取
function handler:isVipLevHasGeted(vipLev)
	if self.vipAwardInfo["awardStateDic"][vipLev]==true then
		return true
	end
	return false
end

--获取可以展示出来的最小VIP等级
function handler:getVipMinShowLev()
	-- local minShowLev = 0
	-- for i=1,self.vipAwardInfo["vipLev"] do
	-- 	if self:isVipLevHasGeted(i)==false then
	-- 		minShowLev = i
	-- 		break
	-- 	end
	-- end
	-- if minShowLev<=0 then
	-- 	if self.vipAwardInfo["vipLev"]>0 then
	-- 		minShowLev = self.vipAwardInfo["vipLev"]
	-- 	else
	-- 		minShowLev = 1
	-- 	end
	-- end
	-- for i=1,minShowLev do
	-- 	if minShowLev>(1+self.VIP_AWARD_MAX_LEV-self.VIP_AWARD_SHOW_MAX_NUM) then
	-- 		minShowLev = minShowLev - 1
	-- 	else
	-- 		break
	-- 	end
	-- end

	-- return minShowLev

	return 1
end

--获取可以展示出来的最大VIP等级
function handler:getVipMaxShowLev()
	local maxShowLev = 0
	if self.vipAwardInfo["vipLev"]<self.VIP_AWARD_SHOW_MAX_NUM then
		maxShowLev = self.VIP_AWARD_SHOW_MAX_NUM
	else
		maxShowLev = self.vipAwardInfo["vipLev"]+1
	end
	if maxShowLev>self.VIP_AWARD_MAX_LEV then
		maxShowLev = self.VIP_AWARD_MAX_LEV
	end
	return maxShowLev
end

--判断是否有VIP奖励可以领取
function handler:hasVipAwardToGet()
	local hasAward = false
	local hasGetedNum = 0
	for k,v in pairs(self.vipAwardInfo["awardStateDic"]) do
		if v==true then
			hasGetedNum = hasGetedNum + 1
		end
	end
	if hasGetedNum<self.vipAwardInfo["vipLev"] then
		hasAward = true
	end
	return hasAward
end

function handler:getCurLoginDay()
	return self.loginAwardInfo["loginDay"]
end

function handler:getIsSpeAward()
	return self.loginAwardInfo["isSpeAward"]
end

function handler:getHasGetedDay()
	return self.loginAwardInfo["hasGetedDay"]
end

function handler:getCurVipLev()
	return self.vipAwardInfo["vipLev"]
end

function handler:getHasGetedLevs()
	return self.vipAwardInfo["hasGetedLevs"]
end

--设置登录后的状态数据
function handler:setLoginPopData(reward_pop, auto_trade_cash, boat_key, boat_type)
	self.login_pop_data["is_login_reward_pop"] = reward_pop
	self.login_pop_data["auto_trade_cash"] = auto_trade_cash
	--显示为打开舰队强化界面时候有数据主动弹出
	self.login_pop_data["boat_reform_data"] = {key = boat_key, id = boat_type}
end

--是否有改造船信息，打开舰队强化界面时候有数据主动弹出
function handler:getReformBoatInfo()
	local boat_info = self.login_pop_data["boat_reform_data"]
	self.login_pop_data["boat_reform_data"] = {}
	return boat_info.key, boat_info.id
end

local function popViewCloseBack()
	local login_data_handle = getGameData():getLoginVipAwardData()
	login_data_handle:operatePopInfo()
end

--登录后需要处理的状态数据
function handler:operatePopInfo()
	if self.login_pop_data["is_login_reward_pop"] == 1 then
		self.login_pop_data["is_login_reward_pop"] = 0
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsAutoPopWelfare = require("gameobj/quene/clsAutoPopWelfare")
		DialogQuene:insertTaskToQuene(clsAutoPopWelfare.new({}))
	end
end

--获取离线奖励数据
function handler:askIdleAwardInfo()
	GameUtil.callRpc("rpc_server_business_auto_info", {}, "rpc_client_business_auto_info")
end

function handler:setIdleAwardInfo(info)
	self.idle_awrd_info = info
end

function handler:getIdleAwardInfo()
	return self.idle_awrd_info
end

function handler:clearIdleAwardInfo()
	self.idle_awrd_info = {}
	self.idle_awrd_info.is_get_reward = true
end

function handler:askIdleReward()
	GameUtil.callRpc("rpc_server_business_auto_get", {}, "rpc_client_business_auto_get")
end
return handler






require("module/gameBases")
local tool = require("module/dataHandle/dataTools")
local music_info = require("game_config/music_info")
local voice_info = getLangVoiceInfo()
local UiCommon = require("ui/tools/UiCommon")
local playerData = class("playerData")

function playerData:ctor()
	self.uid = nil         	 --游戏id
	self.name = nil          --玩家名字
	self.icon = nil          --玩家图标
	self.roleId = nil        --角色
	self.gold = nil          --金币
	self.cash = nil          --银币
	self.maxCash = nil
	self.honour = nil        --荣誉
	self.maxHonour = nil     --荣誉上限
	self.power = nil         --体力
	self.maxPower = nil      --体力上限
	self.exp = nil       	  --经验
	self.maxExp = nil        --经验上限
	self.profession = nil        --玩家职位
	self.level = nil         --玩家等级
	self.remainDay = nil     --剩余天数
	self.isGetRward = nil    --是否已经领奖
	self.isFirst = false     --默认不是第一次登陆
	self.maxPlayerLevel = 70
	self.missionInfo = {}
	self.dailyMissionInfo = {}
	self.account = nil --新用户注册/登录成功后的account
	self.explore_pirate_ids = {} --探索主线战boss和小怪列表
	self.time_delta = 0
	self.server_time = 0 --服务器的时间戳
	self.battle_power = 0 --玩家战斗力
	self.fighted_just_now = false --玩家刚刚经历了战斗
	self.choose_tag = 1 --玩家游戏中默认选中任务栏的页签
	self.old_exp_buff_list = {} --玩家经验buff
	self.grade_interval = nil --玩家等级区间
	self.pirate_num = nil    --玩家成功掠夺别人次数
	self.ship_effects = 0 --主舰流光
	
	IS_SYNC_SERVER_TIME = false
end

function playerData:setIsFightedJustNow(is_fighted)
	self.fighted_just_now = is_fighted
end

function playerData:getIsFightedJustNow()
	return self.fighted_just_now
end

function playerData:setAccount(account)
	self.account = account
end

function playerData:getAccount()
	return self.account
end

function playerData:receivePlayerInfo(info)
	self.name = info.name or self.name
	self.uid = info.uid
	self.icon = info.icon
	self.roleId = info.roleId
	self.ship_effects = info.shipEffects
	
	local role_info = require("game_config/role/role_info")
	self.profession = role_info[info.roleId].job_id

	local module_game_sdk = require("module/sdk/gameSdk")
	module_game_sdk.setRelinkUid(info.uid)

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
        port_layer:setName(self:getName())
	end

	--整点刷新
	self.hour = tonumber(os.date("%H", os.time()))
	local function updateCallBack()
		self:hourUpdate()
	end
	local honourTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(updateCallBack, 1, false)
end

function playerData:setFirstLogin()
   self.isFirst = true
end

function playerData:getFirstLogin()
   return self.isFirst
end

function playerData:callCashChangeFuc(value, max)
	self.cash = value
	self.maxCash = max
	EventTrigger(CASH_UPDATE_EVENT, value)
	return player_coin_item_list
end

function playerData:callGoldChangeFuc(value, max)
	self.gold = value
	EventTrigger(GOLD_UPDATE_EVENT, value)
	return player_diamond_item_list
end

function playerData:callLevelChangeFuc(value, max)
	local pre_level = self.level or 0
	self.level = value

	local cur_level_interval = getGameData():getRankData():whenLevelChange()
	self.grade_interval = cur_level_interval

	local port_layer = getUIManager():get("ClsPortLayer")
	if tolua.isnull(port_layer) then
		local running_scene = GameUtil.getRunningScene()
        if tolua.isnull(running_scene) then return end
        local battleData = getGameData():getBattleDataMt()
        local is_in_battle_b = false
        --特殊处理，现在只有掠夺出来才有
        if battleData:IsInBattle() then
            local battle_field_data = battleData:GetData("battle_field_data")
            if battle_field_data then
                if battle_field_data.fight_type == battle_config.fight_type_plunder then
                    is_in_battle_b = true
                end
            end
        end
        local is_in_explore_b = not tolua.isnull(getExploreLayer())
        if is_in_explore_b or is_in_battle_b then
	        -- if pre_level > 0 then
	        --     local upgrade_alert = require("gameobj/quene/clsUpgradeAlert")
	        -- 	local ClsUpgradeAlert = require("gameobj/quene/clsUpgradeAlert")
	        -- 	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	        -- 	ClsDialogSequence:insertTaskToQuene(ClsUpgradeAlert.new(value))
	        -- end
            if is_in_explore_b then
                local ship_obj = getExploreLayer().player_ship
                if ship_obj then
                    ship_obj:updateLevel(value)
                end
            end
        end
	end

	--升等级仓库要刷新
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:refreshBackpackInfo()
	end
	--升等级伙伴刷新
 	local fleet_ui = getUIManager():get("ClsFleetPartner")
 	if not tolua.isnull(fleet_ui) then
 		fleet_ui:updateView()
  	end
end

function playerData:callHonourChangeFuc(value, max)
	self.honour = value
	self.maxHonour = max
	return player_honour_item_list
end

function playerData:callPowerChangeFuc(value, max)
	self.power = value
	self.maxPower = max
	EventTrigger(POWER_UPDATE_EVENT, value)
	return player_power_item_list
end

function playerData:callExperienceChangeFuc(value, max)
	self.exp = value
	self.maxExp = max
	local explore_ui = getUIManager():get("ExploreUI")
	if not tolua.isnull(explore_ui) then
		explore_ui:updateExpUI()
	end
end

function playerData:callPirateChangeFuc(value)
	self.pirate_num = value
end

-- 获取下一个阶段投资所需要的玩家等级
function playerData:getNextInvestPlayerLevel()
	local ret_level = math.ceil((self.level + 0.1) / 10) * 10
	return ret_level
end

local type_func = {
	[TYPE_INFOR_CASH] = playerData.callCashChangeFuc,
	[TYPE_INFOR_COLD] = playerData.callGoldChangeFuc,
	[TYPE_INFOR_LEVEL] = playerData.callLevelChangeFuc,
	[TYPE_INFOR_HONOUR] = playerData.callHonourChangeFuc,
	[TYPE_INFOR_POWER] = playerData.callPowerChangeFuc,
	[TYPE_INFOR_EXPERIENCE] = playerData.callExperienceChangeFuc,
	[TYPE_INFOR_PIRATE] = playerData.callPirateChangeFuc,
}

--玩家点数设定
function playerData:receivePlayerAttribute(kind, value, max)
	--根据金币，钻石，体力，荣誉类型进行获取在clsPlayerInfoItem中的刷新列表
	print("kind--------------------", kind, value, max)
	local need_update_list = nil
	if type(type_func[kind]) == "function" then
		need_update_list = type_func[kind](self, value, max)
	end

	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:updatePlayerInfo(kind, value, max)
    end

    local explore_ui = getUIManager():get("ExploreUI")
    if not tolua.isnull(explore_ui) then
        explore_ui:updatePlayerInfo(kind, value, max)
    end

	if need_update_list then
		for k,v in pairs(need_update_list) do
			if not tolua.isnull(v) then
				v:updateInfo(value)
			end
		end
	end
end

--创建角色
function playerData:askRoleId(role_id, name)
	GameUtil.callRpc("rpc_server_new_uid", {self.account, role_id, name}, "rpc_client_login_result")
end

function playerData:enterGame(uid)
	GameUtil.callRpc("rpc_server_enter_game", {self.account, uid}, "rpc_client_login_result")
end

function playerData:getRoleId()
	return self.roleId
end

function playerData:getUid()
	return self.uid
end

function playerData:setName(name_)
	self.name = name_
end

function playerData:getName()
	return self.name
end


function playerData:setRoleList(role_list)
	self.role_list = {}
	for k,v in pairs(role_list) do
		self.role_list[v.role] = v
	end
end

function playerData:getRoleList()
	return self.role_list
end

--玩家头像
function playerData:changeIcon(value) -- value 水手ID
	self.icon = tonumber(value)
end

function playerData:getIcon()
	return self.icon or "101"
end

function playerData:setIcon(icon)
	self.icon = icon
end

--等级
function playerData:getLevel()
	return self.level or 0
end

--等级区间(1/2/.../6)
function playerData:getGradeInterval()
	return self.grade_interval
end

--等级区间(1,10 / 11,20 / 21,30 /.../ 51,60)
function playerData:getGradeRange()
	return self.grade_interval * 10 - 9, self.grade_interval * 10
end

--最大等级
function playerData:getMaxLevel()
	return self.maxPlayerLevel
end

--金币
function playerData:getGold()
	return self.gold or 0
end

--银币
function playerData:getCash()
	return self.cash or 0
end

--掠夺次数
function playerData:getPirateNum()
	return self.pirate_num or 0
end

function playerData:getMaxCash()
	return self.maxCash or 0
end

--荣誉
function playerData:getHonour()
	return self.honour or 0
end

function playerData:getMaxHonour()
	return self.maxHonour or 0
end
--体力
function playerData:getPower()
	return self.power or 0
end

function playerData:getMaxPower()
	return self.maxPower or 0
end

function playerData:isFullPower()
	return self.maxPower <= self.power
end
--经验
function playerData:getExp()
	return self.exp or 0
end

function playerData:getMaxExp()
	return self.maxExp or 0
end

function playerData:setFriendNum(value)
	self.friendNum = value
end

function playerData:getFriendNum()
	return self.friendNum or 0
end

--是否有流光状态
function playerData:setShipEffects(value)
	self.ship_effects = value
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:updateShip3DEffect()
	end
end

function playerData:getShipEffects()
	return self.ship_effects % 4 + 1
end

function playerData:setMissionInfo(missionInfo)
	local missionId = missionInfo.missionId
	if self.missionInfo[missionId] then
		if missionInfo.status ~= nil then
			self.missionInfo[missionId].status = missionInfo.status
		end
		if missionInfo.progress ~= nil then
			self.missionInfo[missionId].missionProgress = missionInfo.progress
		end
		if missionInfo.time ~= nil then
			self.missionInfo[missionId].acceptTime = missionInfo.time
		end
		return DATA_DEAL_RESULT_SUCC
	end
	missionInfo.progress = missionInfo.progress or 0
	missionInfo.time = missionInfo.time or 0

	self.missionInfo[missionId] = {["id"] = missionInfo.missionId, ["status"] = missionInfo.status,
									["missionProgress"] = missionInfo.progress, ["acceptTime"] = missionInfo.time}

	local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
	ClsGuideMgr:addGuide(missionId)

	return DATA_DEAL_RESULT_SUCC
end

function playerData:receiveMissionInfo(missionInfo)
	if not missionInfo then
		return DATA_DEAL_RESULT_EXCE
	end

	local result = self:setMissionInfo(missionInfo)

	return result
end

function playerData:receiveMissionAllInfo(missionInfos)
	if not missionInfos then
		return DATA_DEAL_RESULT_EXCE
	end

	local allResult = DATA_DEAL_RESULT_SUCC
	local oneResult = nil
	for k,v in ipairs(missionInfos) do
		oneResult = self:setMissionInfo(v)
		if oneResult == DATA_DEAL_RESULT_EXCE then
			allResult = oneResult
		end
	end

	return allResult
end

function playerData:addDailyMissionInfo(missionId, id, progress, amount)
	self.dailyMissionInfo = {}
	table.insert(self.dailyMissionInfo, {["missionId"] = missionId, ["id"] = id, ["missionProgress"] = progress, ["amount"] = amount})
end

function playerData:removeDailyMission()
	self.dailyMissionInfo = {}
end

function playerData:setAccpetHotelRewardData(data)
	self.accpetRewardData = {}
	self.accpetRewardData = data
end

function playerData:removeMission(missionId)
	self.missionInfo[missionId] = nil
end

function playerData:getMission(missionId)
	return self.missionInfo[missionId]
end

function playerData:hourUpdate()
	local hour = tonumber(os.date("%H",os.time()))
	if self.hour ~= hour then
		self.hour = hour
		--客户端整点刷新
		local mapAttrs = getGameData():getWorldMapAttrsData()  --需求品整点刷新
		if self.hour == 0 then --12点刷新数据
			GameUtil.callRpc("rpc_server_huodong_login_reward_info", {})

			local port_data = getGameData():getPortData()
			local market_data = getGameData():getMarketData()
			market_data:askStoreGoods(port_data:getPortId())

			GameUtil.callRpc("rpc_server_map_hotsell_port", {})
            mapAttrs:askAllNeedGood()

            GameUtil.callRpc("rpc_server_port_list", {})
        elseif self.hour == 6 then --6点刷新数据
        	mapAttrs:askAllNeedGood()
        elseif self.hour == 12 then --12点刷新数据
        	mapAttrs:askAllNeedGood()
        elseif self.hour == 18 then --18点刷新数据
        	mapAttrs:askAllNeedGood()
		end
	end
end

--获得玩家的职位
function playerData:getProfession()
	return self.profession or 1
end

function playerData:setVipRemainDay(remain)
   self.remainDay = remain
end

function playerData:getVipRemainDay()
   return self.remainDay
end

function playerData:isVip()
   return self.remainDay and self.remainDay > 0
end

function playerData:setIsGetAward(isGetRward)
  self.isGetRward = isGetRward
end

function playerData:getIsGetAward()
	return self.isGetRward
end

function playerData:setExplorePirates(pirate, boss_pirate)
  self.explore_pirate_ids.pirate = pirate
  self.explore_pirate_ids.boss_pirate = boss_pirate
end

function playerData:getExplorePirates()
   return self.explore_pirate_ids
end

function playerData:setTimeDelta(value, server_time)
	self.time_delta = value
	self.server_time = server_time
	IS_SYNC_SERVER_TIME = true
end

function playerData:getTimeDelta()
	return self.time_delta
end

function playerData:getCurServerTime()
	return self.time_delta + os.time()
end

function playerData:getServerTime()
	return self.server_time
end

function playerData:getBattlePower()
	return self.battle_power or 0
end
--玩家战斗力
function playerData:setBattlePower(value)
	self.battle_power = value
	local port_layer = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(port_layer) then
		port_layer:updateBattlePower()
	end
end

function playerData:setChooseTag(tag)
	self.choose_tag = tag
end

function playerData:getChooseTag()
	return self.choose_tag
end

function playerData:askHuoDongLoginRewardInfo()
	GameUtil.callRpc("rpc_server_huodong_login_reward_info", {})
end

function playerData:askFriendList()
	GameUtil.callRpc("rpc_server_friend_list", {})
end

function playerData:askAchieveList()
	GameUtil.callRpc("rpc_server_achieve_list", {})
end

function playerData:askPortExploreConsume()
	GameUtil.callRpc("rpc_server_port_explore_consume", {})
end

function playerData:askMailInfo()
	GameUtil.callRpc("rpc_server_mail_list", {})
end

function playerData:askCollectRelicList()
	GameUtil.callRpc("rpc_server_collect_relic_list", {})
end

function playerData:askCheckPointOccupiedPorts()
	-- GameUtil.callRpc("rpc_server_checkpoint_occupied_ports", {})
end

function playerData:setExpBuffStatus(status)
	self.exp_buff_status = status
	local port_layer = getUIManager():get("ClsPortLayer")

    if not tolua.isnull(port_layer) then
        port_layer:updateExpBuffStatus()
    end
end

function playerData:askReName()
	GameUtil.callRpc("rpc_server_modify_name_time", {})
end

function playerData:changeName(name, is_share_to_friend)
	GameUtil.callRpc("rpc_server_modify_role_name", {name, is_share_to_friend})
end

function playerData:getExpBuffStatus()
	return self.exp_buff_status
end

function playerData:setOldExpBuff(buff_id)
	self.old_exp_buff_list[buff_id] = true
end

function playerData:getOldExpBuff(buff_id)
	return self.old_exp_buff_list[buff_id]
end

function playerData:setFeedBackTime()
	self.feed_back_time = os.time()
end

function playerData:getFeedBackTime()
	return self.feed_back_time 
end
return playerData

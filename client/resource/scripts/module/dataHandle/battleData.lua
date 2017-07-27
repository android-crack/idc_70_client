local battle_type_info = require("game_config/battle/battle_type_info")
local battle_jy_info = require("game_config/battle/battle_jy_info")
local tool = require("module/dataHandle/dataTools")
local alert = require("ui/tools/alert")
local news=require("game_config/news")

--Type 大章节；fight 就是普通的小战役

local BattleData = class("BattleData")

local battleTypeInfo = nil

function BattleData:ctor()
	self.generalMaxBattleId = nil      --最高级战役id
	self.generalMaxBattleParent = nil
    self.eliteMaxBattleId = nil      --最高级战役id
	self.eliteMaxBattleParent = nil
    self.assist_count = 0 --协助奖励次数

    self.is_all_completed = false   ---精英战役最后一场是否完成
    --直接进入战斗，不需要组队的战役
    self.untilFightBattle = {
        31,
        32,
    }
end

function BattleData:setAllComplated(status)
    self.is_all_completed = status
end

function BattleData:getAllComplated( )
    return self.is_all_completed
end

function BattleData:setFightId(id) 
    self.fighting_id = id 
end

function BattleData:getFightId()
    return self.fighting_id
end

function BattleData:getMaxBattleId()
	local battle_info_config_data = getGameData():getBattleInfoConfigData()
    if battle_info_config_data:isGeneralConfig() then
	    return self.generalMaxBattleId, self.generalMaxBattleParent
    else
        return self.eliteMaxBattleId, self.eliteMaxBattleParent
    end
end

function BattleData:isOpenFight(fightId)
	if not battleTypeInfo then return end 
	local fight=tool:getFight(fightId)
	if fight then
		local battle=battleTypeInfo[fight.parent]
		if battle then
			local battleFight=battle.generalBattle[fightId]
			local battle_info_config_data = getGameData():getBattleInfoConfigData()
            if battle_info_config_data:isEliteConfig() then
                battleFight = battle.eliteBattle[fightId]
            end
			if battleFight and battleFight.status~=BATTLE_STATUS_UNOPEN then
				return true
			end
		end
	end
end

function BattleData:isOpenType(typeId)
	local battleType = battleTypeInfo[typeId]
	if battleType then
		local battle_info_config_data = getGameData():getBattleInfoConfigData()
        if battle_info_config_data:isEliteConfig() then
            return battleType.eliteOpen
        else
			return battleType.open
		end
	end
    return false
end

function BattleData:initBattleTypeInfo()
    if not battleTypeInfo then   --初始化所有battle列表
		battleTypeInfo={}
		for k,v in pairs(battle_type_info) do
			battleTypeInfo[k]={}
			battleTypeInfo[k].explain = v.explain
			battleTypeInfo[k].name = v.name
			battleTypeInfo[k].level = v.level
			battleTypeInfo[k].map = v.map
			battleTypeInfo[k].pos = v.pos
            battleTypeInfo[k].used = v.used
			battleTypeInfo[k].open = false  --是否能打
            battleTypeInfo[k].eliteOpen = false  --是否能打
			battleTypeInfo[k].generalBattle = {}
			battleTypeInfo[k].star_reward = v.star_reward
			for key,id in ipairs(v.generalBattle) do
				battleTypeInfo[k].generalBattle[id] = {
					star = 0,
					index = key,
					status = BATTLE_STATUS_UNOPEN,
				}
			end
            --精英战役
            battleTypeInfo[k].eliteBattle = {}
			for key,id in ipairs(v.eliteBattle) do
				local isLast = false
				if key == #v.eliteBattle then isLast = true end 
				battleTypeInfo[k].eliteBattle[key] = {
					fight_id = id,
					head_res = "",
					grade = battle_jy_info[id].grade,
					last_battle = battle_jy_info[id].last_battle,
					used = battle_jy_info[id].used,
					is_finally = 0,
					star = 0,
					index = key,
					status = BATTLE_STATUS_UNOPEN,
					max_time = battle_jy_info[id].times,
                    times = 0,
					isLast = isLast,
				}
			end
		end
	end
end

function BattleData:receiveBattleInfo(info,battle_type_flag)

	local taskData = getGameData():getTaskData()
	local onOffData = getGameData():getOnOffData()
	local on_off_info=require("game_config/on_off_info")

	self:initBattleTypeInfo()

    if not info then return end 

    if info.id <= 0 then
       return 
    end

    local battle_info_config_data = getGameData():getBattleInfoConfigData()
    local battle_info = battle_info_config_data:getBattleConfigFileInfo(battle_type_flag)
	local battle = battle_info[info.id]   --和fight 是一个类型的
	if battle.parent and battleTypeInfo[battle.parent] then --检查是否在列表中存在
		local fight = battleTypeInfo[battle.parent].generalBattle[info.id]
        if battle_type_flag and battle_type_flag == battle_info_config_data.ELITE_CONFIG then
        	for _, v in pairs(battleTypeInfo[battle.parent].eliteBattle) do
        		if v.fight_id == info.id then
        			fight = v
        			break
        		end
        	end
        end
		if fight then 

			fight.star = info.star
			fight.status = info.status

            if info.status == 0 then
                fight.status = BATTLE_STATUS_UNOPEN
            end
            
            if info.times  then
                battleTypeInfo.ELITE_ABLE = true
                --jingz
                fight.times = info.times
                fight.is_finally = info.is_finally
            else
                battleTypeInfo.GENERAL_ABLE = true
            end

            if battle_type_flag then
                --  精英战役
                if self.eliteMaxBattleId == nil or self.eliteMaxBattleId < info.id then
				    self.eliteMaxBattleParent = battle.parent
				    self.eliteMaxBattleId = info.id

			    end

                if not battleTypeInfo[battle.parent].eliteOpen then
				    battleTypeInfo[battle.parent].eliteOpen = true
			    end
            else
                --  普通战役
                if self.generalMaxBattleId == nil or self.generalMaxBattleId < info.id then
				    self.generalMaxBattleParent = battle.parent
				    self.generalMaxBattleId = info.id
			    end

                if info.status ~= BATTLE_STATUS_UNOPEN and not battleTypeInfo[battle.parent].open then
				    battleTypeInfo[battle.parent].open = true
			    end
            end	
		end
	end
end


function BattleData:receiveEliteBattleInfo(info, battle_type_flag)


    self:initBattleTypeInfo()

    if not info then return end 

    if info <= 0 then
       return 
    end

    local battle_info_config_data = getGameData():getBattleInfoConfigData()
    local battle_info = battle_info_config_data:getBattleConfigFileInfo(battle_type_flag)
    local battle = battle_info[info]   --和fight 是一个类型的
    if battle.parent and battleTypeInfo[battle.parent] then --检查是否在列表中存在
        local fight = battleTypeInfo[battle.parent].generalBattle[info]
        if battle_type_flag and battle_type_flag == battle_info_config_data.ELITE_CONFIG then
            for _, v in pairs(battleTypeInfo[battle.parent].eliteBattle) do
                if v.fight_id == info then
                    fight = v
                    break
                end
            end
        end


        if battle_type_flag then
            --  精英战役
            if self.eliteMaxBattleId == nil or self.eliteMaxBattleId < info then
                self.eliteMaxBattleParent = battle.parent
                self.eliteMaxBattleId = info

            end

            if not battleTypeInfo[battle.parent].eliteOpen then
                battleTypeInfo[battle.parent].eliteOpen = true
            end

        end
    end    
end

function BattleData:getBattleInfo()
    if not battleTypeInfo then
        self:initBattleTypeInfo()
    end
	return battleTypeInfo
end

function BattleData:getBattleGeneralAble()
    if not battleTypeInfo then
        return false
    end

	return battleTypeInfo.GENERAL_ABLE

end
function BattleData:getBattleEliteAble()
    if not battleTypeInfo then
        return false
    end
    return battleTypeInfo.ELITE_ABLE
end

function BattleData:getBattleAble()
    if not battleTypeInfo then
        return false
    end

 --    local battle_info_config_data = getGameData():getBattleInfoConfigData()	
	-- if battle_info_config_data:isEliteConfig() then
    	return self:getBattleEliteAble()
--     else
       	-- return self:getBattleGeneralAble()
--     end
end

function BattleData:isEliteBattleOpen() --判断是否已有战役开启
    if self.eliteMaxBattleParent == nil then
        local error_info = require("game_config/error_info")
        alert:warning({msg =error_info[68].message, size = 26})
        return false
    end
    return true
end

function BattleData:setAssistCount(count)
    self.assist_count = count
end

function BattleData:getAssistCount()
    return self.assist_count
end

function BattleData:isUntilFight()
    for _, fight_id in pairs(self.untilFightBattle) do
        if fight_id == self.eliteMaxBattleId then
            return true
        end
    end
    return false
end

---------------------------------------------------------------------
--请求战役章节内数据
function BattleData:askBattleList(battleTypeId)
	local battle_info_config_data = getGameData():getBattleInfoConfigData()
    if battle_info_config_data:isGeneralConfig() then
	    GameUtil.callRpc("rpc_server_battle_list", {}, "rpc_client_battle_info")
    elseif battle_info_config_data:isEliteConfig() then
        if battleTypeId <= 0 then return end
        GameUtil.callRpc("rpc_server_elite_battle_list", {battleTypeId}, "rpc_client_elite_battle_list")
    end
end

--请求精英战役的协助奖励次数
function BattleData:askAssistCount()
    GameUtil.callRpc("rpc_server_elite_assist_count", {}, "rpc_client_elite_assist_count")
end


----请求精英战役数据
function BattleData:askEliteBattleInfo()
    GameUtil.callRpc("rpc_server_elite_info", {}, "rpc_client_elite_info")
end

---------------------------------------------------------------------

return BattleData
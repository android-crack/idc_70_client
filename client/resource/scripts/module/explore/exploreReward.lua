local ExploreReward = class("ExploreReward")

local function getAppointSkillInfo(skill_id)
    local appointSkills = getGameData():getSailorData():getRoomSailorsSkill()
    if not appointSkills[skill_id] then   -- 未拥有此技能
        return {}
    end
    local info = {}
    info.level = appointSkills[skill_id].level
    info.seaman_id = appointSkills[skill_id].sailorId
    return info
end

local function putReward(icon, num, value)
	local DialogQuene = require("gameobj/quene/clsDialogQuene")
	local ClsExploreRewardEffect = require("gameobj/quene/clsExploreRewardEffect")
	DialogQuene:insertTaskToQuene(ClsExploreRewardEffect.new({image = icon, num = num, reward = value}))
end

local function addFood(value, kind)
    if kind == ITEM_INDEX_FOOD then
    end
end

--打捞宝物奖励 --wmh todo 删除，多余
local function werckReward(eventType, rewards)
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")

    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.effective_skill_id] then
            local collectDataHandle = getGameData():getCollectData()
            local tempEffectParams = collectDataHandle:getEffectParams()
            if tempEffectParams then
                tempEffectParams.num = tempEffectParams.num + 1
                if tempEffectParams.num == 2 then
                    tempEffectParams.rewards = rewards
                    return
                end
            end
            
            local skill_data = table.clone(explore_skill[tempEventConfig.effective_skill_id])
            local rewardNum = 0
            local treasureName = ""
            local treasureNum = 0
            local tempRewards = {}
            for key, value in ipairs(rewards) do
                addFood(value.amount, value.type)
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                if value.type == ITEM_INDEX_CASH then
					rewardNum = amount
                else
                    treasureName = name
					treasureNum = amount
                end
                tempRewards[#tempRewards + 1] = {res = res, amount = amount, rewards = value}
            end
            local skill_info = EventTrigger(EVENT_EXPLORE_GET_SKILL_INFO, skill_data.skill_info_id)
            local sailorId = skill_info.seaman_id  -- 水手头像
            local tipsId = skill_data.tip_id[1]
            if tempEffectParams then
                tipsId = skill_data.tip_id[2]
            end

            local function endCall( )
                local tempEffectParams = collectDataHandle:getEffectParams()
                
                if tempEffectParams and tempEffectParams.num == 2 then
                    print(T("第二次奖励======================"), tempEffectParams.rewards)
                    table.print(tempEffectParams.rewards)
                    EventTrigger(EVENT_EXPLORE_SKILL_DO, tempEffectParams.target.baseData.effective_skill_id, 
                    getExploreLayer().player_ship, tempEffectParams.target, tempEffectParams.rewards)
                else
                    for key, value in ipairs(tempRewards) do
                        putReward(value.res, value.amount, value.rewards)
                    end
                end
            end

            if tempEffectParams then
                local skillCalc = require("module/battleAttrs/skill_calc")
                local function func()
                    print(T("设置特效========================="))
                end
                for key, value in ipairs(tempRewards) do
                    putReward(value.res, value.amount, value.rewards)
                end
            end

            local function beganCall( )
                
            end
            local treasureEffectParam = {rewardNum, treasureNum, treasureName}
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = beganCall, call_back = endCall, tip_id = tipsId, seaman_id = sailorId}, treasureEffectParam)
            
            
        end
    end
end

--打捞宝物奖励
local function boxReward(eventType, rewards)
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")
    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.effective_skill_id] then
            local skill_data = table.clone(explore_skill[tempEventConfig.effective_skill_id])
          
            local tempRewards = {}
            local params = { }
            for key, value in ipairs(rewards) do
                addFood(value.amount, value.type)
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                table.insert(params, amount)
                table.insert(params, name)
                tempRewards[#tempRewards + 1] = {res = res, amount = amount, rewards = value}
            end
            local skill_info = getAppointSkillInfo(skill_data.skill_info_id)
            local sailorId = skill_info.seaman_id  -- 水手头像
            local tipsId = skill_data.tip_id[1]
            local function endCall( )
                for key, value in ipairs(tempRewards) do
                    putReward(value.res, value.amount, value.rewards)
                end
            end

            local function beganCall( )
            end
            
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = beganCall, call_back = endCall, tip_id = tipsId, seaman_id = sailorId}, params)
            
        end
    end
end


--打捞宝物奖励
local function fatReward(eventType, rewards)
   boxReward(eventType, rewards)
end

local function rockReward(eventType, rewards)
    --rewards 排序
    --[[-- 奖励类型
ITEM_INDEX_MATERIAL = 1             --材料
ITEM_INDEX_DARWING = 2              --图纸
ITEM_INDEX_EQUIP = 3                --装备
ITEM_INDEX_GOODS = 4                --物品
ITEM_INDEX_CASH = 5                 --银币
ITEM_INDEX_EXP = 6                  --经验
ITEM_INDEX_GOLD = 7                 --金币
ITEM_INDEX_TILI = 8                 --体力
ITEM_INDEX_HONOUR = 9               --荣誉
ITEM_INDEX_BAOWU = 10               --宝物
ITEM_INDEX_ARENA = 11               --竞技场点数
ITEM_INDEX_SAILOR = 12              --水手
ITEM_INDEX_NO = 13                  --
ITEM_INDEX_KEEPSAKE = 14              --信物
ITEM_INDEX_PROP = 15                --道具
ITEM_INDEX_STATUS = 17              --各种状态
ITEM_INDEX_HOTEL_REWARD = 18        --各种状态
ITEM_INDEX_CONTRIBUTE = 19          --贡献
ITEM_INDEX_DONATE = 20              --捐献
ITEM_INDEX_FOOD = 21                --食物]]
    local configReward = {[1] = ITEM_INDEX_PROP, [2] = ITEM_INDEX_MATERIAL}
    local sortRewards = {}
    for index, itemType in ipairs(configReward) do
        for key, value in ipairs(rewards) do
            if itemType == value.type then
                sortRewards[#sortRewards + 1] = value
            end
        end
    end
    rewards = sortRewards
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")
    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.effective_skill_id] then
            local skill_data = table.clone(explore_skill[tempEventConfig.effective_skill_id])
            local tempRewards = {}
            local params = { }
            for key, value in ipairs(rewards) do
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                if key <= 1 then
                    table.insert(params, amount)
                    table.insert(params, name)
                end
                tempRewards[#tempRewards + 1] = {res = res, amount = amount, rewards = value}
            end
            local skill_info = getAppointSkillInfo(skill_data.skill_info_id)
            local sailorId = skill_info.seaman_id  -- 水手头像
            local tipsId = skill_data.tip_id[1]
            local function endCall( )
                for key, value in ipairs(tempRewards) do
                    putReward(value.res, value.amount, value.rewards)
                end
            end

            local function beganCall( )
            end
            
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = beganCall, call_back = endCall, tip_id = tipsId, seaman_id = sailorId}, params)
            
        end
    end
end

local function iceReward(eventType, rewards)
    rockReward(eventType, rewards)
end

local function biteBoatReward(eventType, rewards) --鲨鱼
    local configReward = {[1] = 1, [2] = 3}
    if eventType == 19 then
        configReward = {[1] = 3, [2] = 1}
    else
        configReward = {[1] = 1, [2] = 3}
    end
    -- local sortRewards = {}
    -- for index, itemId in ipairs(configReward) do
    --     for key, value in ipairs(rewards) do
    --         if itemId == value.id then
    --             sortRewards[#sortRewards + 1] = value
    --             break;
    --         end
    --     end
    -- end
    -- rewards = sortRewards
    -- print("排序奖励==================")
    -- table.print(sortRewards)
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")
    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.effective_skill_id] then
            local skill_data = table.clone(explore_skill[tempEventConfig.effective_skill_id])
            local tempRewards = {}
            local params = { }
            for key, value in ipairs(rewards) do
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                table.insert(params, amount)
                table.insert(params, name)
                tempRewards[#tempRewards + 1] = {res = res, amount = amount,rewards = value}
            end
            local skill_info = getAppointSkillInfo(skill_data.skill_info_id)
            if not skill_info then
                return
            end
            local sailorId = skill_info.seaman_id  -- 水手头像
            local tipsId = skill_data.tip_id[1]
            local function endCall( )
                for key, value in ipairs(tempRewards) do
                    putReward(value.res, value.amount, value.rewards)
                end
            end

            local function beganCall( )
            end
            
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {beganCallBack = beganCall, call_back = endCall, tip_id = tipsId, seaman_id = sailorId}, params)
            
        end
    end
end

local function mermaidReward(eventType, rewards)
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")
    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.skill_id] then
            local skill_data = table.clone(explore_skill[tempEventConfig.skill_id])
            local tempRewards = {}
            local params = { }
            for key, value in ipairs(rewards) do
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                table.insert(params, amount)
                table.insert(params, name)
                tempRewards[#tempRewards + 1] = {res = res, amount = amount,rewards = value}
            end
            local tipsId = skill_data.tip_id[1]
            for key, value in ipairs(tempRewards) do
                putReward(value.res, value.amount, value.rewards)
            end
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {tip_id = skill_data.tip_id[1]}, params)            
        end
    end
end

local function forgeReward(eventType, rewards)
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")
    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.effective_skill_id] then
            local skill_data = table.clone(explore_skill[tempEventConfig.effective_skill_id])
            local tempRewards = {}
            local params = { }
            for key, value in ipairs(rewards) do
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                table.insert(params, amount)
                table.insert(params, name)
                tempRewards[#tempRewards + 1] = {res = res, amount = amount, rewards = value}
            end
            local tipsId = skill_data.tip_id[1]
            for key, value in ipairs(tempRewards) do
                putReward(value.res, value.amount, value.rewards)
            end
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {tip_id = skill_data.tip_id[1]}, params)            
        end
    end
end

local function stormReward(eventType, rewards)
    local explore_event = require("game_config/explore/explore_event")
    local explore_skill = require("game_config/explore/explore_skill")
    if explore_event[eventType] then
        local tempEventConfig = table.clone(explore_event[eventType])
        if explore_skill[tempEventConfig.effective_skill_id] then
            local skill_data = table.clone(explore_skill[tempEventConfig.effective_skill_id])
            local tempRewards = {}
            local params = { }
            for key, value in ipairs(rewards) do
                local tempValue = {key = value.type, value = value.amount, id = value.id}
                local res, amount, scale, name = getCommonRewardIcon(tempValue) 
                table.insert(params, amount)
                table.insert(params, name)
                tempRewards[#tempRewards + 1] = {res = res, amount = amount, rewards = value}
            end
            local tipsId = skill_data.tip_id[1]
            for key, value in ipairs(tempRewards) do
                putReward(value.res, value.amount, value.rewards)
            end
            EventTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, {tip_id = skill_data.tip_id[1]}, params)            
        end
    end
end

local function monsterReward(eventType, rewards) --海怪
    biteBoatReward(eventType, rewards)
end

local rewardConfig = {
    [1] = rockReward,
    [2] = iceReward,
    [3] = biteBoatReward,
    [4] = mermaidReward,
    [5] = boxReward,
    [6] = fatReward,
    [7] = nwWindReward,
    [9] = true,
    [10] = true,
    [11] = stormReward,
    [12] = forgeReward,
    [13] = true,
    [14] = true,
    [15] = true,
    [16] = true,
    [18] = werckReward,
    [17] = true,
    [19] = monsterReward,
    [20] = true, 
    [21] = true,
    [22] = true,
    [23] = true,
    [24] = true,
}

function ExploreReward:showRewardEffect(eventType, rewards)
    local func = rewardConfig[eventType]
    if func and type(func) == "function" then
        func(eventType, rewards)
    end
end

return ExploreReward
local skill_info = require("game_config/skill/skill_info")
local sailor_info = require("game_config/sailor/sailor_info")

local skillCalc = {
    NonBattleCalc = {}, --战斗外加成
    BattleCalc = {}, --战斗内加成
}

local initDefaultFunc = function(pTable)
    pTable.default = function(old_value, ...) print(T("===================模块-战斗内/外技能加成：未找到对应处理函数！")) return old_value end
    setmetatable(pTable, {__index = function(t, key) 
            return t.default
    end})
end

--获取对应技能的信息
local function getInfosFromOtherSkill(skill_id)
    if nil == skill_id then
        print("输入空的技能id，错误！！！！！")
        print(debug.traceback())
    end
    local other_skill_map = require("game_config/otherSkill/other_skill_map")
    local ClsSkill = other_skill_map["sk"..tostring(skill_id)]
    if ClsSkill then
        local active_skills = getGameData():getSailorData():getRoomSailorsSkill()
        if active_skills[skill_id] then
            local lv = active_skills[skill_id].level
            return ClsSkill:formula(skill_info[skill_id], sailor_info[active_skills[skill_id].sailorId], lv)
        end
    end
    return nil
end

--获取对应技能的触发几率
local function getPercentFromOtherSkill(skill_id)
    local skill_info = getInfosFromOtherSkill(skill_id)
    if skill_info then
        if skill_info.rate then
            return skill_info.rate
        end
    end
    return 0
end

local function isInRandom(rand_n)
    if rand_n > 0 then
        local rand_value = math.random(1, 100)
        if rand_value <= rand_n then
            return true
        end
    end
    return false
end

--触发技能弹框
local function triggerSkillDialog(skill_id)
    local skill_item = skill_info[skill_id]
    if skill_item then
        if skill_item.isDialog and skill_item.isDialog >= 1 then
            EventTrigger(EVENT_EXPLORE_SHOW_SKILL_DIALOG, skill_id)
        end
    end
end

---------------------------------------战斗外加成---------------------------------begin

skillCalc.EXPLORE_REMOVE_ROCK_ICE = 1124 --1124 一劳永逸 子技能 增加对浮冰礁石的伤害，并有几率直接清除
skillCalc.EXPLORE_REMOVE_NET_MONSTER = 1081 --1081 一击致命　子技能  增加对鲨鱼海兽的伤害，并有几率直接捕猎


local NonBattleCalc = skillCalc.NonBattleCalc
initDefaultFunc(NonBattleCalc)
local common_skills = {
}

for k, v in pairs(common_skills) do
    local skill_id = v[1]
    local skill_type = v[2]
    if skill_id and skill_type then
        local target_func = nil
        if "add" == skill_type then
            target_func = function(old_value)
                    local rate_n = getPercentFromOtherSkill(skill_id)
                    return math.ceil(old_value*(rate_n/100 + 1))
                end
        elseif "sub" == skill_type then
            target_func = function(old_value)
                    local rate_n = getPercentFromOtherSkill(skill_id)
                    return math.ceil(old_value*(1 - rate_n/100))
                end
        end
        if target_func then
            NonBattleCalc[skill_id] = target_func
        end
    end
end

NonBattleCalc[skillCalc.EXPLORE_REMOVE_ROCK_ICE] = function(old_value) --1124 一劳永逸 子技能 增加对浮冰礁石的伤害，并有几率直接清除
    local skill_id = skillCalc.EXPLORE_REMOVE_ROCK_ICE
    local rate_n = getPercentFromOtherSkill(skill_id)
    if isInRandom(rate_n) then
        EventTrigger(EVENT_EXPLORE_SHOW_SKILL_DIALOG, skill_id)
        return old_value
    end
    return 0
end

NonBattleCalc[skillCalc.EXPLORE_REMOVE_NET_MONSTER] = function(old_value) --1081 一击致命　子技能  增加对鲨鱼海兽的伤害，并有几率直接捕猎
    local skill_id = skillCalc.EXPLORE_REMOVE_NET_MONSTER
    local rate_n = getPercentFromOtherSkill(skill_id)
    if isInRandom(rate_n) then
        EventTrigger(EVENT_EXPLORE_SHOW_SKILL_DIALOG, skill_id)
        return old_value
    end
    return 0
end

---------------------------------------战斗外加成---------------------------------end

return skillCalc  

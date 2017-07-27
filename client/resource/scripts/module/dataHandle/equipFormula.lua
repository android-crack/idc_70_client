--[[
1.船只属性计算内去除水手修正公式。
2.航海士加成增加幅度，公式如下：
航海士加成=[(59%/（180-20）*（水手当前航海术-20）+1%]
船长加成=[(39%/（180-20）*（水手当前航海术-20）+1%]
具体公式如下：
文档地址：​https://192.168.0.3/qtz/mg01/design/玩法系统/Z装备系统/船舶装配研究系统.doc
第6章：装备属性计算公式
6 装备属性计算公式：
6.1 火炮伤害计算公式：（既远程攻击）
火炮伤害=（长管炮伤害+加农炮伤害）*（1+航海士or船长加成）。
长管炮伤害=长管炮装备数量*长管炮装备数值。
加农炮伤害=加农炮装备数量*加农炮装备数值。
6.2 水手伤害计算公式（掠夺为古老未修改公式，不用测试）（既近战攻击）
水手伤害=（掠夺水手伤害+武装水手伤害）*（1+航海士or船长加成）。
掠夺水手伤害=掠夺水手装备数量*掠夺水手装备伤害数值。
武装水手伤害=武装水手装备数量*武装水手装备伤害数值。
荣誉掠夺加成=（掠夺数值-20）/10+3/5
银币掠夺加成=（掠夺数值-20）/10+3/5*45
该公式是在现有的掠夺效率的基础上额外增加的掠夺数量。只有船只有私掠水手时，该公式才会生效。
例如：原本每次攻击掠夺游戏币100，增加掠夺数值到40后，那么每次攻击掠夺的游戏币为：100+((40-20)/10+3/5*45)=129
6.3 船只耐久公式
船只耐久=（船只初始耐久+装甲装备数量*装甲装备数值）*（1+航海士or船长加成）。
6.4 船只速度公式
船只速度=（船只初始速度+风帆装备数量*风帆装备数值）*（1+航海士or船长加成）。
2.除旗舰属性界面外，所有船只属性界面属性计算按上列公式统一，界面有：
舰队船只界面
船厂制造界面
3.船舶装配界面暂时停用，此处不开放即可。]]
local tool = require("module/dataHandle/dataTools")

local equipFormula = {}

function equipFormula:getPower(fireClose, fireFar, ship_defense, armor, speed)
    --单艘船的战力=(船只耐久/10+近战攻击+远程攻击+防御)*(1+(移动速度-60)/100)
    local power = 0
    ship_defense = ship_defense or 1
    power = (armor / 10 + fireClose + fireFar + ship_defense) * (1 + (speed - 60) / 100)
    power = tonumber(string.format("%0.2f", power))
    return power
end



--航海术加成
function equipFormula:sailLevelAdd(sailorInfo, isPlayer, is_max) --百分比=1%+航海术级别/1200
   local add = 0
   --[[KIND_EXPORE=1    --瞭望手
KIND_CAPTAIN=2   --大副
KIND_GUN=3       --火炮手
KIND_SAILOR=4    --水手长
KIND_CONTROL=5   --操控师
KIND_MEASURE=6   --木工
KIND_ACCOUNT=7   --会计师]]
    local job = sailorInfo.job[1]
    local sailorSail = sailorInfo.sail

    if isPlayer then
        local sailorData = getGameData():getSailorData()
        -- + sailorData:getSkillImprove(sailorInfo.id, 1001)
        sailorSail = sailorSail
    end
    if is_max then
        sailorSail = sailorInfo.maxSkill
    end
    --[[(宝物-瞭望手) 百分比=1%+航海术级别/1200
（速度-操控师）速度p=1+航海术级别/40 
（经商利润-会计师）百分比=1%+航海术级别/1200]]
    local function normal()
        local temp =  sailorSail / 400
        return temp
    end

    local function kindExploreAdd()
        local temp =  sailorSail / 1200 + 0.01
        return temp
    end

    local function kindCaptainAdd()
        local temp =  sailorSail / 400
        return temp
    end

    local function kindGunAdd()
        return normal()
    end

    local function kindSailorAdd()
        return normal()
    end

    local function kindControlAdd()
        local temp =  sailorSail / 40 + 1
        return temp
    end

    local function kindMeasureAdd()
        return normal()
    end

    local function kindAccountAdd()
        local temp =  sailorSail / 1200 + 0.01
        return temp
    end

    local jobAdd = {
        [KIND_EXPORE] = kindExploreAdd, 
        [KIND_CAPTAIN] = kindCaptainAdd, 
        [KIND_GUN] = kindGunAdd, 
        [KIND_SAILOR] = kindSailorAdd, 
        [KIND_CONTROL] = kindControlAdd, 
        [KIND_MEASURE] = kindMeasureAdd, 
        [KIND_ACCOUNT] = kindAccountAdd, 
    }

    add = jobAdd[job]()
    add = tonumber(string.format("%0.2f", add))
    --print("加成值=============", add, "职业===", job)
    return add
end

function equipFormula:salvageSkillAdd(sail)
    --[[新增公式：打捞宝物星级n=round(（int(航海术等级/100)*2+2）^0.5,0)
船员界面显示文字“寻宝：k级宝物”（PS：星级1，k=E；星级2，k=D;星级3，k=C；星级4，k=B；星级5，k=A；星级6，k=S）]]
    local value = math.floor(sail / 100)
    local star =  value * 2 + 2
    star = math.pow(star, 0.5)
    star = math.floor(star + 0.5)
    local starStr = STAR_SPRITE[star]
    local uiWord = require("game_config/ui_word")
    return string.format(uiWord.ROOM_SALVALE_TIPS, starStr)
end

function equipFormula:salvageSkillStar(sail)
    --[[新增公式：打捞宝物星级n=round(（int(航海术等级/100)*2+2）^0.5,0)
船员界面显示文字“寻宝：k级宝物”（PS：星级1，k=E；星级2，k=D;星级3，k=C；星级4，k=B；星级5，k=A；星级6，k=S）]]
    local value = math.floor(sail / 100)
    local star =  value * 2 + 2
    star = math.pow(star, 0.5)
    star = math.floor(star + 0.5)
    return star
end

return equipFormula

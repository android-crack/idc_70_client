local music_info = require("game_config/music_info")
local sailor_info = require("game_config/sailor/sailor_info")
local armatureManager = CCArmatureDataManager:sharedArmatureDataManager()
local SkillDialog = {}

local skill_touch_pri = -6000

local function createShowLayer(sailorId, skillId, endCallBack)
    local tool = require("module/dataHandle/dataTools")
    local sailorData = getGameData():getSailorData()
    local ownSailors = sailorData:getOwnSailors()
    local skillData = getGameData():getSkillData()
    local sailorInfo = sailor_info[sailorId]

    local appointSkills = getGameData():getSailorData():getRoomSailorsSkill() --{sailor== ,level==}
    local level = 0
    if appointSkills[skillId] then
        level = appointSkills[skillId].level
    end
    
    local colorLayer = CCLayerColor:create(ccc4(0,0,0,180))
    
    local ui_layer = UILayer:create()
    ui_layer:setTouchPriority(skill_touch_pri)
    colorLayer:addChild(ui_layer, 1)

    local json_ui = GUIReader:shareReader():widgetFromJsonFile("json/tips_skill.json")
    ui_layer:addWidget(json_ui)
    
    local head_spr = getConvertChildByName(json_ui, "sailor_head")
    local dialog_text_lab = getConvertChildByName(json_ui, "dialog_text")
    local skill_text_lab = getConvertChildByName(json_ui, "skill_info_text")
    local skill_level_lab = getConvertChildByName(json_ui, "skill_level")
    local skill_name_lab = getConvertChildByName(json_ui, "skill_name")
    local skill_icon_spr = getConvertChildByName(json_ui, "skill_icon")
    
    --水手头像
    head_spr:loadTexture(sailorInfo.res,UI_TEX_TYPE_LOCAL)
    if sailorInfo.star >= 6 then
        head_spr:setScale(0.5)
    else
        head_spr:setScale(1)
    end
    
    local skillInfo = tool:getSkill(skillId)
    local tips_str = skillInfo.dialog_tips
    dialog_text_lab:setText(tips_str)
    
    local SailorDataHander = getGameData():getSailorData()
    local desc_tab = SailorDataHander:getSkillDescWithLv(skillId, level, sailorId)
    local desc_str = SailorDataHander:getChildDesOrBaseDesc(desc_tab)
    skill_text_lab:setText(desc_str)
    
    skill_name_lab:setText(skillInfo.name)
    local name_pos = skill_name_lab:getPosition()
    --技能等级
    skill_level_lab:setText("Lv." .. level)
    local level_pos = skill_level_lab:getPosition()
    skill_level_lab:setPosition(ccp(name_pos.x + skill_name_lab:getContentSize().width + 10, level_pos.y))
    --技能图标
    skill_icon_spr:changeTexture(convertResources(skillInfo.res), UI_TEX_TYPE_PLIST)
    
    --特效skill_dialog_light
    local lightGaf = CCArmature:create("tx_0045")
    local armatureAnimation = lightGaf:getAnimation()
    armatureAnimation:addMovementCallback(function() 
    end)
    armatureAnimation:playByIndex(0,-1,-1,0)
    local pos = ccp(display.cx, display.cy + 100)
    lightGaf:setPosition(ccp(pos.x , pos.y))
    colorLayer:addChild(lightGaf, 0)

    local speedGaf = CCArmature:create("tx_0046")
    local armatureAnimation = speedGaf:getAnimation()
    armatureAnimation:addMovementCallback(function(eventType) 
        if eventType == 1 then
            speedGaf:removeFromParentAndCleanup(true)
        end
    end)
    armatureAnimation:playByIndex(0,-1,-1,0)

    pos = ccp(display.cx + 30, display.cy - 28)
    speedGaf:setPosition(ccp(pos.x , pos.y))
    colorLayer:addChild(speedGaf, 2)
    colorLayer.lightGaf = lightGaf
    return colorLayer
end

function SkillDialog:createDialog(sailorId, skillId, endCallBack)	
    local running_scene = display.getRunningScene()
    self.plist = {
        ["ui/skill_icon.plist"] = 1,
    }
    LoadPlist(self.plist)

    self.armatureTab = {
        "effects/tx_0045.ExportJson",
        "effects/tx_0046.ExportJson",
    }
    LoadArmature(self.armatureTab)

    if tolua.isnull(running_scene) then return end


    local layer = createShowLayer(sailorId, skillId, endCallBack)
    local function tempCallBack()
        if not tolua.isnull(layer) then
            layer.lightGaf:removeFromParentAndCleanup(true)
            layer:removeFromParentAndCleanup(true)            
        end
        endCallBack()
        UnLoadPlist(self.plist)
        UnLoadArmature(self.armatureTab)
    end
    local function onTouch(eventType, x, y)
        if eventType == "began" then
            if not layer.is_lock_touch then
                tempCallBack()
            end
            return true
        end
    end
    layer:registerScriptTouchHandler(onTouch, false, skill_touch_pri, true)
    audioExt.playEffect(music_info.SKILL_TRIGGER.res)
    running_scene:addChild(layer, ZORDER_DIALOG + 50)

    layer:setTouchEnabled(true)
    layer.is_lock_touch = true
    local sequence_1 = CCSequence:createWithTwoActions(CCDelayTime:create(1), 
        CCCallFunc:create(function() layer.is_lock_touch = false end))
    local sequence_2 = CCSequence:createWithTwoActions(CCDelayTime:create(5), CCCallFunc:create(tempCallBack))
    layer:runAction(CCSpawn:createWithTwoActions(sequence_1, sequence_2))
end

function SkillDialog:showDialog(sailorId, skillId, callBack)
    --老队列 屏蔽
    -- local dialogSequence = require("gameobj/mission/dialogSequence")
    -- local dialogType = dialogSequence:getDialogType()
    -- if dialogSequence:hasSameSkillIdDialog(skillId) then
    --     return
    -- end

    -- local ClsFleetPartner = getUIManager():get("ClsFleetPartner")
    -- if tolua.isnull(ClsFleetPartner) then
    --     dialogSequence:insertDialogTable({func = callBack, skillID = skillId, sailorID = sailorId, dialogType = dialogType.skillDialog})  
    --     return
    -- end

    self:createDialog(sailorId, skillId, function()
        if type(callBack) == "function" then
            callBack()
        end
    end)
end

return SkillDialog
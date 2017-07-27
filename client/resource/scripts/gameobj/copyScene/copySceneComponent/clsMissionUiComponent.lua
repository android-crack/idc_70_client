--2016/07/23
--create by wmh0497
--组件基类
local ui_word = require("scripts/game_config/ui_word")
local alert = require("ui/tools/alert")
local ClsComponentBase = require("ui/view/clsComponentBase")
local ClsMissionUiComponent = class("ClsMissionUiComponent", ClsComponentBase)

function ClsMissionUiComponent:onStart()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_my_name = getGameData():getSceneDataHandler():getMyName()
    self:initMissionTip()
end

function ClsMissionUiComponent:initMissionTip()
    local treasure_panel = getConvertChildByName(self.m_explore_sea_ui, "copy_treasure")
    treasure_panel:setVisible(true)

    local need_widget_name = {
        lbl_mission_tips = "task_tips_text",
        btn_arrow = "btn_close",
        spr_arrow = "close_arrow",
        pro_myself = "bar",
        lbl_myself = "bar_num",
        spr_task_bg = "task_bg",
    }
    for k, v in pairs(need_widget_name) do
        self[k] = getConvertChildByName(treasure_panel, v)
    end

    self.lbl_mission_tips:setText("")
    self.lbl_myself:setText("")
    self.pro_myself:setPercent(0)
    self.pos_task_bg = ccp(self.spr_task_bg:getPosition().x, self.spr_task_bg:getPosition().y)
    self.spr_task_bg:setPosition(ccp(self.pos_task_bg.x, self.pos_task_bg.y))
    self.mission_switch = false

    self.btn_arrow:addEventListener(function()
        self.btn_arrow:setTouchEnabled(false)
        local actions = CCArray:create()
        if self.mission_switch then
            actions:addObject(CCEaseBackOut:create(CCMoveTo:create(0.5, self.pos_task_bg)))
            actions:addObject(CCCallFunc:create(function() 
                self.spr_arrow:setFlipX(false)
                self.btn_arrow:setTouchEnabled(true)
            end))
        else
            actions:addObject(CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(-self.pos_task_bg.x, self.pos_task_bg.y))))
            actions:addObject(CCCallFunc:create(function() 
                self.spr_arrow:setFlipX(true)
                self.btn_arrow:setTouchEnabled(true)
            end))
        end
        self.mission_switch = not self.mission_switch
        self.spr_task_bg:runAction(CCSequence:create(actions))
    end, TOUCH_EVENT_ENDED)
    -- self:showMissionTips()
end

function ClsMissionUiComponent:showMissionTips()
    self.btn_arrow:setTouchEnabled(false)
    local actions = CCArray:create()
    actions:addObject(CCEaseBackOut:create(CCMoveTo:create(1, self.pos_task_bg)))
    actions:addObject(CCDelayTime:create(1))
    actions:addObject(CCCallFunc:create(function()
        self.btn_arrow:setTouchEnabled(true)
    end))
    self.spr_task_bg:runAction(CCSequence:create(actions))
end


function ClsMissionUiComponent:updateMissions()
    if tolua.isnull(self.m_parent) then
        return
    end

    if not tolua.isnull(self.mission_layer) then
        self.mission_layer:removeFromParentAndCleanup(true)
    end
    self.mission_layer = UILayer:create()
    
    -- self.mission_layer:setTouchPriority(-1)
    local copy_scene_data = getGameData():getCopySceneData()

    local missions = copy_scene_data:getTreasureMissions()
    local pos_height = 46 * 3
    for i = 1, #missions do
        local panel = GUIReader:shareReader():widgetFromJsonFile("json/explore_copy_list.json")
        local need_widget_name = {
            lbl_player_name = "player_text",
            lbl_mission_info = "task_info",
        }
        for k, v in pairs(need_widget_name) do
            self.mission_layer[k] = getConvertChildByName(panel, v)
        end
        local player_name_str = missions[i].name
        self.mission_layer.lbl_player_name:setText(player_name_str)
        
        local mission_info = copy_scene_data:getMissionInfo(missions[i].type)
        if missions[i].uid == self.m_my_uid then
            local str_mission_tips = string.format(ui_word.STR_COPY_SCENE_PLAYER_MISSION_TIPS, mission_info.name)
            self.lbl_mission_tips:setText(str_mission_tips)
            if missions[i].progress >= missions[i].times then 
                self.lbl_myself:setText(ui_word.STR_COPY_SCENE_PLAYER_MISSION_COMPLETE_TIPS)
            else
                self.lbl_myself:setText(missions[i].progress .. "/" .. missions[i].times)
            end
            self.pro_myself:setPercent(missions[i].progress / missions[i].times * 100)
        end

        local str_mission = string.format(ui_word.STR_COPY_SCENE_MISSION_NAME, mission_info.name, 
            missions[i].progress, missions[i].times)
        self.mission_layer.lbl_mission_info:setText(str_mission)
        if missions[i].progress == missions[i].times and not self.first_complete and missions[i].uid == self.m_my_uid then
            self.first_complete = true
            alert:warning({msg = ui_word.STR_COPY_SCENE_COMPLETE_MISSION})
        end
        panel:setPosition(ccp(-90, pos_height - (i * 46) - 75))
        self.mission_layer:addWidget(panel)
    end
    self.spr_task_bg:addCCNode(self.mission_layer)
end

function ClsMissionUiComponent:update(dt)
end

function ClsMissionUiComponent:onExit()
end

return ClsMissionUiComponent




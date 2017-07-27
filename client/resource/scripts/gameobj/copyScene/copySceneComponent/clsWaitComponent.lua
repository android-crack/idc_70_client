--
-- Author: lzg0946
-- Date: 2016-09-12 11:14:55
-- Function: 副本描述

local ClsComponentBase = require("ui/view/clsComponentBase")
local clsDataTools = require("module/dataHandle/dataTools")

local clsWaitComponent = class("clsWaitComponent", ClsComponentBase)

function clsWaitComponent:onStart()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initUI()
end

function clsWaitComponent:initUI()
    local melee_panel = getConvertChildByName(self.m_explore_sea_ui, "copy_melee")
    melee_panel:setVisible(true)

    self.melee_wait = getConvertChildByName(self.m_explore_sea_ui, "melee_wait_bg")
    self.melee_wait:setVisible(true)
    self.melee_begin_time = getConvertChildByName(self.m_explore_sea_ui, "melee_begin_time")
    self.melee_begin_time:setText("")
    self.melee_begin_people_num = getConvertChildByName(self.m_explore_sea_ui, "melee_begin_people_num")
    self.melee_begin_people_num:setText("")
end

function clsWaitComponent:updateWaitTime(time)
    self.end_time = time
    local arr_action = CCArray:create()
    local player_data = getGameData():getPlayerData()
    arr_action:addObject(CCCallFunc:create(function()
        local cur_time = os.time() + player_data:getTimeDelta()
        local remain_time = self.end_time - cur_time
        remain_time = remain_time - 1
        if remain_time <= 0 then
            self.melee_begin_time:stopAllActions()
            return
        end
        self.melee_begin_time:setText(clsDataTools:getTimeStrNormal(remain_time))
    end))
    arr_action:addObject(CCDelayTime:create(1))
    self.melee_begin_time:runAction(CCRepeatForever:create(CCSequence:create(arr_action)))
end

function clsWaitComponent:playfightEffect()
    local copy_scene_manager = require("gameobj/copyScene/copySceneManage")
    local copy_scene_ui = copy_scene_manager:getSceneUILayer()
    if not tolua.isnull(copy_scene_ui) then
        copy_scene_ui:showFightEffect()
    end
end

function clsWaitComponent:updateJoinAmount(cur_amount, max_amount)
    self.melee_begin_people_num:setText(cur_amount .. "/" .. max_amount)
end

function clsWaitComponent:hideWaitTime()
    self.melee_begin_time:stopAllActions()
    self.melee_wait:setVisible(false)
end

return clsWaitComponent
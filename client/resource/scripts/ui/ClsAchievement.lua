local uiTools = require("gameobj/uiTools")
local AchieveList = require("gameobj/achieve/AchieveList")
local AchieveCell = require("gameobj/achieve/AchieveCell")
local music_info = require("scripts/game_config/music_info")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info=require("game_config/on_off_info")
local Alert = require("ui/tools/alert")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsBaseView = require("ui/view/clsBaseView")
local armatureRes = "effects/box.ExportJson"
local voice_info = getLangVoiceInfo()

-----------------------------成就收集----------------------------------

local ClsAchievement = class("ClsAchievement", ClsBaseView)

function ClsAchievement:getViewConfig(...)
    return {
        is_back_bg = true,
        effect = UI_EFFECT.DOWN,
    }
end


function ClsAchievement:onEnter(  )
    local achieveData = getGameData():getAchieveData()
    achieveData:askAchieveInfo("")

    self.plistTab = {
        ["ui/achieve_ui.plist"] = 1,
    }
    LoadPlist(self.plistTab)

    CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(armatureRes)
    self:initUI()
   
    audioExt.playEffect(music_info.PAPER_STRETCH.res)
    audioExt.playEffect(voice_info.VOICE_SWITCH_1006.res)
end

function ClsAchievement:onExit()
    UnLoadPlist(self.plistTab)
    UnLoadArmature(armatureRes)
end

function ClsAchievement:initUI()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/achieve.json")
    convertUIType(panel)
    self:addWidget(panel)
    self.btn_close = getConvertChildByName(panel, "btn_close")
    self.btn_close:setPressedActionEnabled(true)
    self.btn_close:addEventListener(function()
        audioExt.playEffect(music_info.COMMON_CLOSE.res)
        self:close()
    end, TOUCH_EVENT_ENDED)
end

function ClsAchievement:showAchieveList(achieves)
    if not tolua.isnull(self.list) then
        self.list:removeFromParentAndCleanup(true)
        self.list = nil
    end
    if not self.list or  tolua.isnull(self.list) then
        self.list = ClsScrollView.new(760, 420, true, function()
            local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/achieve_list.json")
            --cell_ui.text_lab = getConvertChildByName(cell_ui, "giveup_text")
            return cell_ui
        end, {is_fit_bottom = true})
        self.list:setPosition(ccp(100, 45))
        self:addWidget(self.list)
    end
    self.list:removeAllCells()
    if not achieves then
        return
    end
    local achieve_data = getGameData():getAchieveData()
    local show_achieve_dic = achieve_data:getShowAchieveDic()
    
    local achieveList = {}
    for k, v in pairs(show_achieve_dic) do
        for i = 1, #v do
            local achieve = achieves[v[i]]
            if achieve.status == ACHIEVE_FINSH_NO_REWARD then
                if i == #v then
                    achieve.step = i
                    achieveList[#achieveList + 1] = achieve
                    break
                end
            else
                achieve.step = i - 1
                achieveList[#achieveList + 1] = achieve
                break
            end
        end
    end

    table.sort(achieveList, function(a, b)
        return a.order < b.order
    end)
    self.cells = {}
    index = 1
    self.achieve_datas = {}
    for i = 1, #achieveList do
        local achieve = achieveList[i]
        if achieve then 
            local item_cell = AchieveCell.new(CCSize(760, 130), {index = index, data = achieve})
            self.cells[index] = item_cell
            index = index + 1
            self.achieve_datas[#self.achieve_datas + 1] = achieve
        end
    end
    self.achieveList = achieveList
    self.list:addCells(self.cells)
end

function ClsAchievement:setCurrentListIndex()
    local index = 1
    local finish = false
    for i = 1, #self.achieve_datas do
        local achieve = self.achieve_datas[i]
        if achieve ~= nil and achieve.status == ACHIEVE_FINISH_REWARD then
            index = i
            finish = true
            break
        end
    end
    if not finish then
        index = self.last_index or index
    end
    self.last_index = index

    self.list:scrollToCellIndex(index, true)
end

function ClsAchievement:updateAchieve()
    local player_data = getGameData():getPlayerData()
    local achieve_data = getGameData():getAchieveData()
    local show_achieve_dic = achieve_data:getShowAchieveDic()
    local achieves = achieve_data:getAchieveData(player_data:getUid())

    if not tolua.isnull(self.list) and not tolua.isnull(self.reward_cell) then
        local achieve = self.reward_cell.config
        local achieve_num = #show_achieve_dic[self.reward_cell.config.cell_index]
        for i = 1, achieve_num do
            achieve = achieves[show_achieve_dic[self.reward_cell.config.cell_index][i]]
            if achieve.status == ACHIEVE_FINSH_NO_REWARD then
                if i == achieve_num then
                    achieve.step = i
                    break
                end
            else
                achieve.step = i - 1
                break
            end
        end
           
    end
    self:showAchieveList(achieves)
    self:setCurrentListIndex() --暂时屏蔽新的ui-listview还没有支持
end

function ClsAchievement:showReward(cell, otherReward, callBackFunc)
    Alert:showCommonReward(otherReward)
    if callBackFunc ~= nil then
        callBackFunc()
    end

    self.reward_cell = cell
end

return ClsAchievement
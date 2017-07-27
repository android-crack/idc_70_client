local ui_word = require("scripts/game_config/ui_word")
local music_info = require("scripts/game_config/music_info")
local missionGuide = require("gameobj/mission/missionGuide")
local sailor_stroy_achieve = require("scripts/game_config/sailor/sailor_stroy_achieve")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")
local Alert = require("ui/tools/alert")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local AchieveCell = class("AchieveCell", ClsScrollViewItem)

function AchieveCell:initUI(cell_date)
    self.panel = self.m_cell_ui
    self.config = cell_date.data
end

function AchieveCell:updateUI(cell_date, cell_ui)
    local panel = self.panel
    local list_bg = getConvertChildByName(getConvertChildByName(panel, "list_panel"), "list_bg")

    local star_bg = getConvertChildByName(list_bg, "star_bg")
    self.star = {}
    self.star_bg = {}
    self.star[1] = getConvertChildByName(star_bg, "star_1")
    self.star[2] = getConvertChildByName(star_bg, "star_3")
    self.star[3] = getConvertChildByName(star_bg, "star_2")
    self.star_bg[1] = getConvertChildByName(star_bg, "star_bg_1")
    self.star_bg[2] = getConvertChildByName(star_bg, "star_bg_3")
    
    if self.config.totalStar == 1 then  --只有一个星
        self.star[3]:setVisible(true)
        if not ((self.config.step == self.config.totalStar) and (self.config.status ~= ACHIEVE_NO_FINISH)) then
            self.star[3]:setVisible(false)
        end
    else
        for i = 1, 3 do
            if self.config.step >= i then
                self.star[i]:setVisible(true)
            elseif self.star_bg[i] then 
                self.star_bg[i]:setVisible(true)
            end
        end
    end

    local progress = 0
    local totalProgress = 0
    for k,v in ipairs(self.config.progressInfos) do
        progress = progress + v.progress
        totalProgress = totalProgress + v.totalProgress
    end
    if totalProgress == 0 then
        totalProgress = 1
    end

    if progress < 0 then
        progress = totalProgress
    end

    local progress_bar = getConvertChildByName(getConvertChildByName(list_bg, "progress_bg"), "progress_bar")
    progress_bar:setPercent(100*progress/totalProgress)
    local progress_num = getConvertChildByName(list_bg, "progress_num")
    progress_num:setText(string.format("%d/%d", progress, totalProgress))

    local achieve_name = getConvertChildByName(list_bg, "achieve_name")
    achieve_name:setText(self.config.name)
    local achieve_info = getConvertChildByName(list_bg, "achieve_info")
    achieve_info:setText(self.config.desc)

    local award_num = getConvertChildByName(list_bg, "award_num")
    local award_icon = getConvertChildByName(list_bg, "award_icon")
    local btn_get = getConvertChildByName(list_bg, "btn_get")
    btn_get:setPressedActionEnabled(true)
    local btn_get_text = getConvertChildByName(btn_get, "btn_get_text")
    --奖励
    self.reward = {["key"] = ITEM_INDEX_CASH, ["value"] = 0}
    if self.config.gold then
        self.reward.value = self.config.gold
        self.reward.key = ITEM_INDEX_GOLD
        award_icon:changeTexture("common_icon_diamond.png", UI_TEX_TYPE_PLIST)
    else
        self.reward.value = self.config.silver
    end
    award_num:setText(self.reward.value)

    btn_get:setVisible(false)
    if self.config.status == ACHIEVE_FINSH_NO_REWARD then  --完成领取
        getConvertChildByName(list_bg, "complete_pic"):setVisible(true)
    else
        if self.config.status == ACHIEVE_NO_FINISH then  --未完成
        else --完成可领取
            btn_get:setVisible(true)
            btn_get:addEventListener(function()
                audioExt.playEffect(music_info.COMMON_BUTTON.res)
                local achieve_main_ui = getUIManager():get("ClsAchievement")
                btn_get:disable()
                btn_get_text:setText(ui_word.REWARD_FINISH)
                self:getReward()
            end, TOUCH_EVENT_ENDED)
        end
    end
end

function AchieveCell:getReward()
    local achieveData = getGameData():getAchieveData()
    local achieveUi = getUIManager():get("ClsAchievement")
    achieveUi:showReward(self, {self.reward}, function()
        if tolua.isnull(self) or not self.config then
            return
        end
        --领奖
        local achieveData = getGameData():getAchieveData()
        achieveData:askGetReward(self.config.id)
    end)

end


return AchieveCell
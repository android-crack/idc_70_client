--
-- Author: lzg0946
-- Date: 2016-08-31 19:20:46
-- Function: 积分排行榜

local ClsComponentBase = require("ui/view/clsComponentBase")
local clsScrollView = require("ui/view/clsScrollView")
local ui_word = require("game_config/ui_word")

local clsIntegraUiComponet = class("clsIntegraUiComponet", ClsComponentBase)

local m_rank_color = nil

function clsIntegraUiComponet:onStart()
    self.m_my_uid = getGameData():getSceneDataHandler():getMyUid()
    self.m_my_name = getGameData():getSceneDataHandler():getMyName()
    self.m_explore_sea_ui = self.m_parent:getJsonUi()
    self:initUI()

end

function clsIntegraUiComponet:initUI()
    local melee_panel = getConvertChildByName(self.m_explore_sea_ui, "copy_melee")
    melee_panel:setVisible(true)

    self.melee_rank = getConvertChildByName(melee_panel, "melee_rank_bg")
    self.melee_rank:setVisible(true)

    self.my_rank = getConvertChildByName(self.melee_rank, "my_rank")
    self.my_rank:setText(string.format(ui_word.STR_MYSELF_RANK, 0))

    local switch = false
    local btn_close_melee = getConvertChildByName(self.melee_rank, "btn_close_melee")
    local spr_btn_close = getConvertChildByName(self.melee_rank, "close_arrow_0")
    btn_close_melee:addEventListener(function()
        btn_close_melee:setTouchEnabled(false)
        switch = not switch
        local arr_action = CCArray:create()
        if switch then
            arr_action:addObject(CCMoveTo:create(0.2, ccp(1059, self.melee_rank:getPosition().y)))
        else
            arr_action:addObject(CCMoveTo:create(0.2, ccp(860, self.melee_rank:getPosition().y)))
        end
        arr_action:addObject(CCCallFunc:create(function()
            -- btn_close_melee:setFlipX(not switch)
            -- spr_btn_close:setFlipX(switch)
            btn_close_melee:setTouchEnabled(true)
        end))
        self.melee_rank:runAction(CCSequence:create(arr_action))
    end, TOUCH_EVENT_ENDED)

    local btn_check_reward = getConvertChildByName(self.melee_rank, "rule_btn")
    btn_check_reward:addEventListener(function() 
        getUIManager():create("gameobj/copyScene/clsMeleeRewardDec")
    end, TOUCH_EVENT_ENDED)
end

local clsRankItem = class("clsRankItem", require("ui/view/clsScrollViewItem"))
function clsRankItem:updateUI(data, cell)
    self.data = data
    self.panel = cell
    local needWidgetName = {
        lbl_rank_num = "rank_num",
        lbl_rank_name = "name_text",
        spr_top_pic = "top_pic"
    }

    for k, v in pairs(needWidgetName) do
        self[k] = getConvertChildByName(self.panel, v)
    end

    self.lbl_rank_name:setText(self.data.name)
    self.lbl_rank_num:setText(self.data.rank)
    self.spr_top_pic:setVisible(self.data.point <= 3)

    if self.data.point <= 3 then
        local str_png = string.format("common_top_%d.png", self.data.point)
        self.spr_top_pic:changeTexture(str_png, UI_TEX_TYPE_PLIST)
    end

    local copy_scene_data = getGameData():getCopySceneData()
    if m_rank_color then
        local color = copy_scene_data:getRankNameColor(self.data.uid)
        setUILabelColor(self.lbl_rank_name, ccc3(dexToColor3B(color)))
    end
end

-- rank_color 积分排行榜的颜色
function clsIntegraUiComponet:updateRankUI(list, my_rank, rank_color)
    m_rank_color = rank_color
    if not tolua.isnull(self.list_view) then
        self.list_view:removeFromParentAndCleanup(true)
    end

    self.list_view = clsScrollView.new(200, 130, true, function()
        return  GUIReader:shareReader():widgetFromJsonFile("json/explore_copy_melee_list.json")
    end, {is_fit_bottom = true})
    self.list_view:setPosition(ccp(-95, -65))

    local cells = {}
    for k, v in ipairs(list) do
        local datas = v
        datas.point = k
        local cell = clsRankItem.new(CCSize(200, 36), datas)
        cells[#cells + 1] = cell
    end
    self.list_view:addCells(cells)
    self.melee_rank:addChild(self.list_view)
    self.my_rank:setText(string.format(ui_word.STR_MYSELF_RANK, my_rank))
end

return clsIntegraUiComponet

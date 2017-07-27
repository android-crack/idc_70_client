--
-- Author: chenlurong
-- Date: 2016-04-19 15:02:18
--

local ClsUiWord = require("game_config/ui_word")
local ClsGuildExitViewPanel = require("gameobj/guild/guildExitViewPanel")
local ClsGuildEachMemberInfoPanel = require("gameobj/guild/guildEachMemberInfoPanel")
local ClsMusicInfo =require("scripts/game_config/music_info")
local ClsAlert = require("ui/tools/alert")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")

local ClsGuildApplyManagerItem = class("ClsGuildApplyManagerItem", ClsScrollViewItem)


function ClsGuildApplyManagerItem:initUI(cell_date)
    local data = cell_date
    if not data then
        return
    end
    self.data = data
    self.ui_layer = UIWidget:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_manage_list.json")
    convertUIType(self.panel)
    self.ui_layer:addChild(self.panel)
    self:addChild(self.ui_layer)

    self.member_name = getConvertChildByName(self.panel, "guild_name")
    self.member_name:setText(data.name)

    self.member_level = getConvertChildByName(self.panel, "member_amount")
    self.member_level:setText("Lv." .. data.level)

    self.member_power = getConvertChildByName(self.panel, "power_num")
    self.member_power:setText(tostring(data.zhandouli))

    self.member_selected = getConvertChildByName(self.panel, "guild_selected")
end 

---------------------------------------------------------------------------------

local rect = CCRect(310, 133, 330, 180)
local select_guild_cell = nil

local ClsGuildApplyManagerUI = class("ClsGuildApplyManagerUI", ClsBaseView)

function ClsGuildApplyManagerUI:getViewConfig(...)
    return {
        is_back_bg = true,
        effect = UI_EFFECT.SCALE, 
    }
end

function ClsGuildApplyManagerUI:onEnter()
    self.limit_level = GUILD_SYSTEM_GRADE[GUILD_SYSTEM_TAB.GUILD_APPLY_MANAGER]
    self:configUI()
    self:configEvent()
    local guild_info_data = getGameData():getGuildInfoData()
    guild_info_data:askGuildApplyList()
end


function ClsGuildApplyManagerUI:configUI()
    self.ui_layer = UIWidget:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_manage.json")
    convertUIType(self.panel)
    self.ui_layer:addChild(self.panel)
    self:addWidget(self.ui_layer)

    --排序按钮
    self.btn_arrow_left = getConvertChildByName(self.panel, "btn_arrow_left")
    self.btn_arrow_right = getConvertChildByName(self.panel, "btn_arrow_right")
    self.write_text = getConvertChildByName(self.panel, "write_text")
    self.btn_agree = getConvertChildByName(self.panel, "btn_agree")
    self.btn_refuse = getConvertChildByName(self.panel, "btn_refuse")
    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.no_message = getConvertChildByName(self.panel, "no_message")


    self.btn_arrow_left:disable()
    self.btn_arrow_right:disable()
    self.btn_agree:disable()
    self.btn_refuse:disable()

    self.no_message:setVisible(false)
    self.write_text:setText(ClsUiWord.STR_GUILD_APPLY_REQUIRE_FREE)

    self.apply_item_list = {}
end

function ClsGuildApplyManagerUI:configEvent()
    self.btn_arrow_left:setPressedActionEnabled(true) 
    self.btn_arrow_left:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:changeJoinType()
        end,TOUCH_EVENT_ENDED)

    self.btn_arrow_right:setPressedActionEnabled(true) 
    self.btn_arrow_right:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:changeJoinType(true)
        end,TOUCH_EVENT_ENDED)

    self.btn_agree:setPressedActionEnabled(true) 
    self.btn_agree:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:replyApplyInfo(true)
        end,TOUCH_EVENT_ENDED)

    self.btn_refuse:setPressedActionEnabled(true) 
    self.btn_refuse:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:replyApplyInfo()
        end,TOUCH_EVENT_ENDED)

    self.btn_close:setPressedActionEnabled(true) 
    self.btn_close:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
            self:close()
        end,TOUCH_EVENT_ENDED)
end

--更新状态
function ClsGuildApplyManagerUI:replyApplyInfo(is_accept)
    if not select_guild_cell then
        return
    end
    local state = 0
    if is_accept then
        state = 1
    end 
    local guild_info_data = getGameData():getGuildInfoData()
    guild_info_data:guildApplyReply(select_guild_cell.data.uid, state)
    self.list_view:removeCell(select_guild_cell)
    self:updateApplyBtnState()
end

--更新状态
function ClsGuildApplyManagerUI:changeJoinType( is_next )
    local guild_info_data = getGameData():getGuildInfoData()
    if guild_info_data:getGuildGrade() < self.limit_level then
        ClsAlert:warning({msg = string.format(ClsUiWord.STR_GUILD_APPLY_OPEN_TIPS, self.limit_level), size = 26})
        return
    end
    
    if not self.join_type then
        return
    end
    local join_type = self.join_type
    if is_next then
        join_type = join_type + 1
    else
        join_type = join_type - 1
    end
    local guild_info_data = getGameData():getGuildInfoData()
    guild_info_data:changeJoinType(join_type)
end

--更新状态
function ClsGuildApplyManagerUI:updateJoinType( join_type )
    local is_captain = getGameData():getGuildInfoData():isCaptain()
    self.join_type = join_type
    if self.join_type == 0 then
        self.write_text:setText(ClsUiWord.STR_GUILD_APPLY_REQUIRE_FREE)
        self.btn_arrow_left:disable()
        if is_captain then
            self.btn_arrow_right:active() 
        else
            self.btn_arrow_right:disable()       
        end

    else
        self.btn_arrow_left:active()
        self.btn_arrow_right:disable()
        if is_captain then
            self.btn_arrow_left:active() 
        else
            self.btn_arrow_left:disable()       
        end
        self.write_text:setText(ClsUiWord.STR_GUILD_APPLY_REQUIRE_NEED)
    end
end

function ClsGuildApplyManagerUI:updateApplyList( list )

    if #list > 0 then
        self.no_message:setVisible(false) 
    else
        self.no_message:setVisible(true) 
    end

    table.sort(list,function (a,b)
        return a.timeout > b.timeout
    end)
   
    self.apply_item_list = {}

    select_guild_cell = nil
    local list_num = 5
    local cell_size = CCSizeMake(rect.size.width, rect.size.height/list_num) 
    for i, data in ipairs( list ) do       
        local apply_item_ui = ClsGuildApplyManagerItem.new(cell_size, data)   
        self.apply_item_list[#self.apply_item_list + 1] = apply_item_ui

        apply_item_ui.onTap = function(cell_self,x, y) -- 选中
            local cell = cell_self
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            if select_guild_cell ~= cell then
                if select_guild_cell then
                    select_guild_cell.member_selected:setVisible(false)
                end
                select_guild_cell = cell
            end
            self.current_guild_info = cell.data
            cell.member_selected:setVisible(true)
   

            if self.current_guild_info ~= getGameData():getPlayerData():getUid() then
                self.exit_view = ClsGuildExitViewPanel.new(-1)
                local curCellW, curCellH = cell:getWidth(), cell:getHeight()
                local worldPos = cell:convertToWorldSpace(ccp(curCellW / 2, curCellH / 2))
                local tmpView = ClsGuildEachMemberInfoPanel.new(self.current_guild_info, worldPos, self, true,self)          
                self.exit_view:addChild(tmpView)
                self.exit_view:setTouchEnabled(true)
                self:addWidget(self.exit_view)
            end
        end
    end

    if not tolua.isnull(self.exit_view) then
        self.exit_view:removeFromParentAndCleanup(true)
    end

    if self.apply_item_list ~= nil and #self.apply_item_list > 0 then
        if tolua.isnull(self.list_view) then
            self.list_view = ClsScrollView.new(rect.size.width,rect.size.height,true,nil,{is_fit_bottom = true})
            self.list_view:setPosition(rect.origin)

            self:addWidget(self.list_view)
            self.list_view:addCells(self.apply_item_list)
        end

    end

    self:updateApplyBtnState()
end

function ClsGuildApplyManagerUI:updateApplyBtnState()
    if self.list_view then
        select_guild_cell = self.list_view:getCells()[1]
    end
    if select_guild_cell then
        self.btn_agree:active()
        self.btn_refuse:active()
        select_guild_cell.member_selected:setVisible(true)
    else
        self.btn_agree:disable()
        self.btn_refuse:disable()
    end
end

function ClsGuildApplyManagerUI:setTouch(enable)
    if not tolua.isnull(self.list_view) then 
        self.list_view:setTouchEnabled(enable)
    end
    if not tolua.isnull(self.ui_layer) then 
        self.ui_layer:setTouchEnabled(enable)
    end
end

function ClsGuildApplyManagerUI:onExit()

end

return ClsGuildApplyManagerUI
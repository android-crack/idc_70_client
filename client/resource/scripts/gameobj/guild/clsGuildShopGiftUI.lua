-- 商会商店礼包界面
local uiTools = require("gameobj/uiTools")
local music_info = require("scripts/game_config/music_info")
local ClsDataTools = require("module/dataHandle/dataTools")
local ui_word = require("scripts/game_config/ui_word")
local tool = require("module/dataHandle/dataTools")
local Alert = require("ui/tools/alert")
local group_gift_reason = require("game_config/guild/group_gift_reason")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsScrollView = require("ui/view/clsScrollView")

local scheduler = CCDirector:sharedDirector():getScheduler()

local MY_HORIZONTAL_SHOW_GIF_NUM = 1
local ALL_HORIZONTAL_SHOW_GIF_NUM = 2

local all_sort_rule = {
	[GUILD_GIFT_GVIING_OUT] = 1,
	[GUILD_GIFT_CLOSE] = 2,
	[GUILD_GIFT_NOT_GIVE_OUT] = 3
}

local my_sort_rule = {
	[GUILD_GIFT_NOT_GIVE_OUT] = 1,
	[GUILD_GIFT_GVIING_OUT] = 2,
	[GUILD_GIFT_CLOSE] = 3
}

local all_cell_info = {
	[1] = {name = "gift_icon_closed", status = GUILD_GIFT_NOT_GIVE_OUT},
	[2] = {name = "gift_icon_full", status = GUILD_GIFT_GVIING_OUT},
	[3] = {name = "gift_icon_empty", status = GUILD_GIFT_CLOSE},
	[4] = {name = "state_unsent", status = GUILD_GIFT_NOT_GIVE_OUT},
	[5] = {name = "state_sent", status = GUILD_GIFT_GVIING_OUT},
	[6] = {name = "state_empty", status = GUILD_GIFT_CLOSE},
	[7] = {name = "player_name"},
	[8] = {name = "get_text"},
	[9] = {name = "diamond_amount"},
	[10] = {name = "countdown_time"},
    [11] = {name = "getted_gift_pic"}
}

local my_cell_info = {
	[1] = {name = "gift_icon_closed", status = GUILD_GIFT_NOT_GIVE_OUT},
	[2] = {name = "gift_icon_full", status = GUILD_GIFT_GVIING_OUT},
	[3] = {name = "gift_icon_empty", status = GUILD_GIFT_CLOSE},
	[4] = {name = "state_unsent", status = GUILD_GIFT_NOT_GIVE_OUT},
	[5] = {name = "state_sent", status = GUILD_GIFT_GVIING_OUT},
	[6] = {name = "state_empty", status = GUILD_GIFT_CLOSE},
	[7] = {name = "get_text"},
	[8] = {name = "diamond_amount"},
}

local ClsGiftBase = class("ClsGiftBase", ClsScrollViewItem)

function ClsGiftBase:setPanelPos(k, show_num)
	local panel = self.panels[k]
	local cell_size = self.size
	local panel_size = panel:getContentSize()
	local horizantal_space = math.floor((cell_size.width - show_num * panel_size.width) / (show_num + 1))
    local vertical_space = math.floor((cell_size.height - panel_size.height) / 2)
    panel:setPosition(ccp(k * horizantal_space + (k - 1) * panel_size.width, vertical_space))
end

function ClsGiftBase:grabRedPackageEvent(v, guild_shop_ui, player_uid)--抢红包
    local guild_shop_data = getGameData():getGuildShopData()
    local tip_ui = getUIManager():get("ClsGuildGiftTip")
    if not tolua.isnull(tip_ui) then
        local tip_gift_info = tip_ui:getData()
        if tip_gift_info.giftId == v.giftId then
            tip_ui:closeView()
        end
    end

    for i, j in ipairs(v.rewardlist) do
        if j.uid == player_uid then
            getUIManager():create("gameobj/guild/ClsGuildGiftPopup", nil, {kind = GUILD_GIFT_GRAB_INFO, gift_info = v})--创建
            return
        end
    end
    guild_shop_data:askGrabGuildGif(v.giftId)
end

function ClsGiftBase:clickClosedEvent(v, guild_shop_ui)--已领完   
    getUIManager():create("gameobj/guild/ClsGuildGiftPopup", nil, {kind = GUILD_GIFT_GRAB_INFO, gift_info = v})--创建
end

function ClsGiftBase:clickNotOpenEvent(v, guild_shop_ui, player_uid)--未开放
    if v.owner ==  player_uid then
        guild_shop_ui:setTouch(false)
        getUIManager():create("gameobj/guild/ClsGuildGiftPopup", nil, {kind = GUILD_GIFT_GIVE, gift_info = v})--创建
    else
        Alert:warning({msg = ui_word.GUILD_GIFT_NOT_OPEN, size = 26})
    end
end

local event_by_status = {
    [GUILD_GIFT_GVIING_OUT] = ClsGiftBase.grabRedPackageEvent,
    [GUILD_GIFT_CLOSE] = ClsGiftBase.clickClosedEvent,
    [GUILD_GIFT_NOT_GIVE_OUT] = ClsGiftBase.clickNotOpenEvent,
}

function ClsGiftBase:clickCellCallBack(v)
    local guild_shop_ui = getUIManager():get("ClsGuildShopUI")
    local guild_shop_data = getGameData():getGuildShopData()
    local player_data = getGameData():getPlayerData()
    local player_uid = player_data:getUid()
    event_by_status[v.status](self, v, guild_shop_ui, player_uid)
end

local ClsAllGiftCell = class("ClsAllGiftCell", ClsGiftBase)

function ClsAllGiftCell:onTap(x, y)
    local mid_pos = 385
    local index = 0
    if x < 380 then
       index = 1
    elseif x >390 then
        index = 2
        
    end
    if not tolua.isnull(self.panels[index]) then
        self.panels[index]:touchCallBack()
    end
    
end

function ClsAllGiftCell:initUI(data)
    data = self.datas
    self:removeCCNode(true)
    self.size = CCSize(588, 114)
    index = data.index
    self.panels = {}
    for k, v in ipairs(self.datas) do
        local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_gift_item1.json")
        panel.data = v
        panel.index = k
        self.panels[#self.panels + 1] = panel
        panel.status_views = {}
        self:addChild(panel)
        local panel_size = panel:getContentSize()
       	self:setPanelPos(k, ALL_HORIZONTAL_SHOW_GIF_NUM)
       	local pos = panel:getPosition()
       	panel.touch_rect = CCRect(pos.x, pos.y, panel_size.width, panel_size.height)

       	for i, j in ipairs(all_cell_info) do
	   		panel[j.name] = getConvertChildByName(panel, j.name)
	   		panel[j.name].status = j.status
	   		panel[j.name]:setVisible((not j.status) or (v.status == j.status))
	    end

	    panel.countdown_time:setVisible(false)
        local name = v.name == '' and ui_word.GUILD_NAME or v.name 
	   	panel.player_name:setText(name)
	   	panel.get_text:setText(group_gift_reason[v.reason].title)
	   	panel.diamond_amount:setText(v.gold)

        local player_data = getGameData():getPlayerData()
        local player_uid = player_data:getUid()

        panel.getted_gift_pic:setVisible(false)
        for i, j in pairs(v.rewardlist) do
            if j.uid == player_uid then
                panel.getted_gift_pic:setVisible(true)
                break
            end
        end

       	function panel:touchCallBack()
       		ClsAllGiftCell.super.clickCellCallBack(self, v)
       	end

       	if v.status == GUILD_GIFT_GVIING_OUT then
       		self:openScheduler(panel)
       	end
    end
end

function ClsAllGiftCell:closeCountDownScheduler(target)
	if target.update_count_shceduler then
  		scheduler:unscheduleScriptEntry(target.update_count_shceduler)
        target.update_count_shceduler = nil
	end
end

function ClsAllGiftCell:openScheduler(target)
    local function updateCount()
        if tolua.isnull(target) then return end
    	current_time = os.time()
    	local player_data = getGameData():getPlayerData()
	    current_time = current_time + player_data:getTimeDelta()
	    local time = target.data.delete_time or 0
        if current_time < time then
        	local show_txt = tostring(tool:getTimeStrNormal(time - current_time))
            target.countdown_time:setText(show_txt)
            if not target.countdown_time:isVisible() then
            	target.countdown_time:setVisible(true)
            end
        else
        	target.countdown_time:setVisible(false)
            self:closeCountDownScheduler(target)
            local guild_shop_data = getGameData():getGuildShopData()
            guild_shop_data:deleteGiftByGiftId(target.data.giftId)
            local tip_ui = getUIManager():get("ClsGuildGiftTip")
            if not tolua.isnull(tip_ui) then
                local data = tip_ui:getData()
                if data.giftId == target.data.giftId then
                    tip_ui:closeView()
                end
            end
            local guild_shop_gift_ui = getUIManager():get("ClsGuildShopUI"):getGuildGiftUI()
            guild_shop_gift_ui:updateView()
        end
    end

    self:closeCountDownScheduler(target)
    target.update_count_shceduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

function ClsAllGiftCell:insertData(data)
    if not self.datas then self.datas = {} end
    self.datas[#self.datas + 1] = data
end

local ClsMyGiftCell = class("ClsMyGiftCell", ClsGiftBase)

function ClsMyGiftCell:initUI(date)
    self.size = CCSize(179, 114)
    
end
function ClsMyGiftCell:setData(data)
    self.data = data
end

function ClsMyGiftCell:onTap(x, y)
    self:clickCellCallBack(self.data)
end

function ClsMyGiftCell:updateUI(cell_date, cell_ui)
    local panel = cell_ui
    panel:setPosition(ccp(3, 0))

    local panel_size = panel:getContentSize()
    self.panels = {panel}
    local data = self.data
   	self:setPanelPos(1, MY_HORIZONTAL_SHOW_GIF_NUM)
   	for i, j in ipairs(my_cell_info) do
   		panel[j.name] = getConvertChildByName(panel, j.name)
   		panel[j.name].status = j.status
   		panel[j.name]:setVisible((not j.status) or (data.status == j.status))
	end

   	panel.get_text:setText(group_gift_reason[data.reason].title)
   	panel.diamond_amount:setText(self.data.gold)
end

local ClsGuildShopGiftUI = class("ClsGuildShopGiftUI", function () return UIWidget:create() end)

function ClsGuildShopGiftUI:ctor()
    self.res_plist = {
        --["ui/box.plist"] = 1,
    }
    LoadPlist(self.res_plist)
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_gift.json")
    convertUIType(self.panel)
    self:addChild(self.panel)
	self:updateView()

    local guild_shop_data = getGameData():getGuildShopData()
    guild_shop_data:askGuildGifInfo()
end

function ClsGuildShopGiftUI:updateView()
	self:updateAllGiftListView()
	self:updateMyGiftListView()
end

function ClsGuildShopGiftUI:deleteListView(target)
	if not tolua.isnull(target) then 
		target:removeAllCells()
	end
end

function ClsGuildShopGiftUI:sortGift(target)
	for k, v in ipairs(target) do
		v.sort_index = target.sort_rule[v.status]
	end
	table.sort(target, function(a, b)
		return a.sort_index < b.sort_index
	end)
end

function ClsGuildShopGiftUI:updateAllGiftListView()
	self:deleteListView(self.all_list_view)
	local guild_shop_data = getGameData():getGuildShopData()
	local all_gift = guild_shop_data:getAllGift()
	if #all_gift < 1 then return end
	all_gift.sort_rule = all_sort_rule
	self:sortGift(all_gift)
    local time_list = {}
    local remain_list = {}
    for k, v in ipairs(all_gift) do
        if v.status == GUILD_GIFT_GVIING_OUT then
            table.insert(time_list, v)
        else
            table.insert(remain_list, v)
        end
    end

    table.sort(time_list, function(a, b) 
        return a.delete_time > b.delete_time
    end)

    for k, v in ipairs(remain_list) do
        table.insert(time_list, v)
    end

    all_gift = time_list
    if tolua.isnull(self.all_list_view) then
        self.all_list_view = ClsScrollView.new(592, 340, true, function()
            return cell_ui
        end, {is_fit_bottom = true})
        self.all_list_view:setPosition(ccp(95, 28))

        self:addChild(self.all_list_view)
    end
   
    
    local current_cell = nil
    
    local current_cells = {}
    local current_cell 
    local index = 1
	for k, v in ipairs(all_gift) do
        if k % ALL_HORIZONTAL_SHOW_GIF_NUM == 1 then

            current_cell = ClsAllGiftCell.new(CCSize(588, 114),{index = index})
            current_cells[index] = current_cell
            index = index + 1
           
        end
        current_cell:insertData(v)
    end
    self.all_list_view:addCells(current_cells)
   
end

function ClsGuildShopGiftUI:updateMyGiftListView()
	self:deleteListView(self.my_list_view)
	local guild_shop_data = getGameData():getGuildShopData()
	local my_gift = guild_shop_data:getMyGift()
	if #my_gift < 1 then return end
	my_gift.sort_rule = my_sort_rule
	self:sortGift(my_gift)
	
    if tolua.isnull(self.my_list_view) then
        self.my_list_view = ClsScrollView.new(179, 340, true, function()
            local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_gift_item2.json")
            return cell_ui
        end, {is_fit_bottom = true})
        self.my_list_view:setPosition(ccp(688, 28))

        self:addChild(self.my_list_view)
    end
    
    local current_cells = {}
    local current_cell = nil
    index = 1
	for k, v in ipairs(my_gift) do
        current_cell = ClsMyGiftCell.new(CCSize(179, 114), v)
        current_cell:setData(v)
        -- current_cell:setTapCallFunc(function(current_cell, x, y)
        --     current_cell:clickCellCallBack(current_cell.data)
        -- end)
        index = index + 1
       	current_cells[#current_cells + 1] = current_cell
    end
    self.my_list_view:addCells(current_cells)
    -- self.my_list_view:setCurrentIndex(1)
    -- self.my_list_view:setTouchEnabled(true)
    -- self.ui_layer:addChild(self.my_list_view)
end

function ClsGuildShopGiftUI:setTouch(enable)
	
end

--没必要更新到很细小，更新cell就行
function ClsGuildShopGiftUI:updateListViewCell(gift_info)
    if not gift_info then return end
    if not tolua.isnull(self.my_list_view) then
        for k, v in ipairs(self.my_list_view:getCells()) do
            if v.data.giftId == gift_info.giftId then
                v:setData(gift_info)

                v:callUpdateUI()
                break
            end
        end
    end
    if not tolua.isnull(self.all_list_view) then
        for k, v in ipairs(self.all_list_view:getCells()) do
            for i, j in ipairs(v.datas) do
            
                if j.giftId == gift_info.giftId then
                    v.datas[i] = gift_info
                    v:initUI()

                    break
                end
            end
        end
    end
end

function ClsGuildShopGiftUI:cleanListView()
   print("刘大大删了的代码-----------看到这个以后麻烦告诉刘大大或者亚亚")
   print(debug.traceback())
end

function ClsGuildShopGiftUI:onExit()
    UnLoadPlist(self.res_plist)
end

return ClsGuildShopGiftUI
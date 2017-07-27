local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local Alert = require("ui/tools/alert")
local news = require("game_config/news") 
local uiTools = require("gameobj/uiTools")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")

local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsFriendScrollView = require("gameobj/friend/clsFriendScrollView")

local ASK_OFFSET = 20

--cell配置
local ClsCellBase = class("ClsCellBase", ClsScrollViewItem)
function ClsCellBase:configBaseInfo()
	local data = self.m_cell_date

    self.player_name:setText(data.name)
    self.player_level:setText(string.format("Lv.%s", data.level))
    self.player_power_num:setText(data.rank_zhandouli)
    local player_photo_id = nil
    if not data.icon or data.icon == "" or tonumber(data.icon) == 0 then
        player_photo_id = 101
    else
        player_photo_id = tonumber(data.icon)
    end
    
    self.head_icon:changeTexture(sailor_info[player_photo_id].res, UI_TEX_TYPE_LOCAL)
    local head_size = self.head_icon:getContentSize()
    self.head_icon:setScale(90 / head_size.height)
    self:configEvent()
end

function ClsCellBase:onTap(x, y)
	local select_cell = self.m_scroll_view.select_cell
	if not tolua.isnull(select_cell) then
	    select_cell.select_pic:setVisible(false)
	end
	self.select_pic:setVisible(true)
	self.m_scroll_view.select_cell = self
	local main_ui = getUIManager():get("ClsFriendMainUI")
	main_ui:openExpandPanel(self)
end

--应付以后策划推荐和搜索不同显示的需求
local new_cell_info = {
	[1] = {name = "head_icon"},
	[2] = {name = "player_name"},
	[3] = {name = "player_level"},
	[4] = {name = "player_power_num"},
	[5] = {name = "btn_pass"},
	[6] = {name = "btn_refuse"},
	[7] = {name = "select_pic"},
}

local ClsNewCell = class("ClsNewCell", ClsCellBase)
function ClsNewCell:init()
	self.is_new_cell = true
end

function ClsNewCell:updateUI(cell_date, panel)
	local data = cell_date
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_new_friend_cell.json")
    self:addChild(self.panel)
    self.btn_tab = {}
    for k, v in ipairs(new_cell_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item.name = v.name
        if item:getDescription() == "Button" then
        	item:setTouchEnabled(true)
            item:setPressedActionEnabled(true)
            table.insert(self.btn_tab, item)
        end
        self[v.name] = item
    end

    self:configBaseInfo()
end

function ClsNewCell:configEvent()
	local friend_data_handler = getGameData():getFriendDataHandler()
	--通过
    self.btn_pass:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local current_frined_num = friend_data_handler:getFriendNum()
        if current_frined_num < FRIENT_MAX_NUM then
            friend_data_handler:askAllowOrRefuseFriend(self.m_cell_date.uid, 1)
        else
            Alert:warning({msg = ui_word.FRIEND_ADD_FAILED})
        end
    end, TOUCH_EVENT_ENDED)

    --拒绝
    self.btn_refuse:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        local main_ui = getUIManager():get("ClsFriendMainUI")
        local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
        if not tolua.isnull(add_ui) then
            add_ui:removeApplyCellByUid(self.m_cell_date.uid)
        end
        friend_data_handler:askAllowOrRefuseFriend(self.m_cell_date.uid, 0)
        friend_data_handler:deleteObj(DATA_APPLY, self.m_cell_date.uid)
    end, TOUCH_EVENT_ENDED)
end

local add_cell_info = {
	[1] = {name = "head_icon"},
	[2] = {name = "player_name"},
	[3] = {name = "player_level"},
	[4] = {name = "tips_recommend"},
	[5] = {name = "player_power_num"},
	[6] = {name = "btn_add"},
	[7] = {name = "select_pic"},
}

local ClsAddCellBase = class("ClsAddCellBase", ClsCellBase)
function ClsAddCellBase:updateUI(cell_date, panel)
	local data = cell_date
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_add_friend_cell.json")
    self:addChild(self.panel)
    self.btn_tab = {}
    for k, v in ipairs(add_cell_info) do
        local item = getConvertChildByName(self.panel, v.name)
        item.name = v.name
        if item:getDescription() == "Button" then
        	item:setTouchEnabled(true)
            item:setPressedActionEnabled(true)
            table.insert(self.btn_tab, item)
        end
        self[v.name] = item
    end

    self:configBaseInfo()
    self.btn_add.text = getConvertChildByName(self.btn_add, "btn_text")

    if not data.status then
		self.btn_add:setVisible(false)
	else
		if data.status == APPLY_FRIEND_STATUS then
			self.btn_add:disable()
			self.btn_add.text:setText(ui_word.TIP_APPLYED)
		else
			self.btn_add.text:setText(ui_word.STR_ADDFRIEND)
			self.btn_add:active()
		end
	end

	local friend_data_handler = getGameData():getFriendDataHandler()
	if friend_data_handler:isMyFriend(data.uid) then
		self.btn_add:setVisible(true)
		self.btn_add:disable()
		self.btn_add.text:setText(ui_word.FRIEND_ALREADY_ADD)
	end

	self:showOtherView()

	local main_ui = getUIManager():get("ClsFriendMainUI")
    if tolua.isnull(main_ui.btn_add) then
        if data.status and data.status ~= APPLY_FRIEND_STATUS then
            main_ui.btn_add = self.btn_add
        end
    end

    local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
    ClsGuideMgr:tryGuide("ClsFriendMainUI")
end

function ClsAddCellBase:configEvent()
	self.btn_add.last_time = 0	
	self.btn_add:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if CCTime:getmillistimeofCocos2d() - self.btn_add.last_time < 2000 then return end
		self.btn_add.last_time = CCTime:getmillistimeofCocos2d()

		local friend_data_handler = getGameData():getFriendDataHandler()
		local cur_num = friend_data_handler:getFriendNum()
		if cur_num <= FRIENT_MAX_NUM then
			friend_data_handler:askRequestAddFriend(self.m_cell_date.uid)
		else
			Alert:warning({msg = ui_word.FRIEND_ADD_FAILED})
		end
	end, TOUCH_EVENT_ENDED)
end

--搜索的cell
local ClsSearchCell = class("ClsSearchCell", ClsAddCellBase)
function ClsSearchCell:showOtherView(cell_date, panel)
	self.tips_recommend:setVisible(false)
end

--推荐的cell
local ClsRecommendCell = class("ClsSearchCell", ClsAddCellBase)
function ClsRecommendCell:showOtherView(cell_date, panel)
	self.tips_recommend:setVisible(true)
end

--主界面配置
local ClsAddPanelUI = class("ClsAddPanelUI", function() return UIWidget:create() end)
function ClsAddPanelUI:ctor()
	self.content_status = DATA_RECOMMEND
	self:configUI()
	self:configEvent()
	self:updateListView()
	local friend_data_handler = getGameData():getFriendDataHandler()
	friend_data_handler:askRecommedFriendList()
end

function ClsAddPanelUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/friend_add_friend.json")
    self:addChild(self.panel)

    self.btn_find = getConvertChildByName(self.panel, "btn_find")
    self.friend_num = getConvertChildByName(self.panel, "friend_num")
    self.refuse_check = getConvertChildByName(self.panel, "refuse_check")

    local sprite = CCScale9Sprite:createWithSpriteFrame(display.newSpriteFrame("common_9_block3.png"))

    if not tolua.isnull(self.edit_box) then
    	self.edit_box:removeFromParentAndCleanup(true)
    end

	self.edit_box = CCEditBox:create(CCSize(322, 42), sprite)
	self.edit_box:setPosition(339, 473)
	self.edit_box:setFont(font_tab[FONT_MICROHEI_BOLD], 18)
	self.edit_box:setFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.edit_box:setInputFlag(kEditBoxInputFlagSensitive)
	self.edit_box:setPlaceHolder(ui_word.PLEASE_INPUT_PLAYER_NAME)
	self:addCCNode(self.edit_box)

	self.tip = getConvertChildByName(self.panel, "tip")
	self.tip:setVisible(false)
	self:updateRefuseApplyView()
end

function ClsAddPanelUI:configEvent()
	local friend_data_handler = getGameData():getFriendDataHandler()
	self.btn_find:setPressedActionEnabled(true)
	self.btn_find:setTouchEnabled(true)
	self.btn_find:addEventListener(function()
		self.content_status = DATA_SEARCH
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local edit_box_text = self.edit_box:getText()
		if edit_box_text == nil or edit_box_text == "" then 

		end
		local commonBase  = require("gameobj/commonFuns")
        edit_box_text = commonBase:returnUTF_8CharValid(edit_box_text) 
        local has = check_string_has_invisible_char(edit_box_text)
        if has then
            Alert:warning({msg = ui_word.INPUT_ILLEGAL, color = ccc3(dexToColor3B(COLOR_RED))})
            return
        end
        local string_length = commonBase:utfstrlen(edit_box_text)
        if string_length < 2 then
        	Alert:warning({msg = news.FRIENDS_SEARCH_3WORDS.msg, color = ccc3(dexToColor3B(COLOR_RED))})
        	return
        end

        if string_length > 8 then
        	Alert:warning({msg = ui_word.FIND_KEYWORDS_TOO_LONG, color = ccc3(dexToColor3B(COLOR_RED))})
        	return
       	end
		
		local uid = tonumber(edit_box_text)
		if uid > 4294967295 then
			Alert:warning({msg = ui_word.FIND_KEYWORDS_TOO_LONG, color = ccc3(dexToColor3B(COLOR_RED))})
        	return
		end

		local player_data = getGameData():getPlayerData()
		if player_data:getUid() == uid then
			Alert:warning({msg = ui_word.FRIEND_SEARCH_MYSELF, color = ccc3(dexToColor3B(COLOR_RED))})
			return
		else
			self:removeListView()
			friend_data_handler:askSearchFriend(edit_box_text, uid)
		end
	end,TOUCH_EVENT_ENDED)
	
	self.refuse_check:setTouchEnabled(true)
    self.refuse_check:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        friend_data_handler:askRefuseApply(FRIEND_APPLY_REFUSE)
    end, CHECKBOX_STATE_EVENT_SELECTED)

    self.refuse_check:addEventListener(function() 
        audioExt.playEffect(music_info.COMMON_BUTTON.res)
        friend_data_handler:askRefuseApply(FRIEND_APPLY_UNREFUSE)
    end, CHECKBOX_STATE_EVENT_UNSELECTED)
end

function ClsAddPanelUI:updateRefuseApplyView(enable)
	local is_refuse_apply = nil
	if enable == nil then
		local friend_data_handler= getGameData():getFriendDataHandler()
		is_refuse_apply = friend_data_handler:getRefuseApply()
	else
		is_refuse_apply = enable
	end
    self.refuse_check:setSelectedState(is_refuse_apply)
end

function ClsAddPanelUI:removeListView()
	if not tolua.isnull(self.list_view) then
		self.list_view:removeFromParentAndCleanup(true)
		self.list_view = nil
	end
end

function ClsAddPanelUI:updateListView(kind, not_show_apply)
	self:removeListView()
	local empty_obj_list = 0
	local friend_data_handler = getGameData():getFriendDataHandler()

	local apply_list = nil
	if not not_show_apply then
		apply_list = friend_data_handler:getApplyList()
		if not apply_list or #apply_list < 1 then 
			empty_obj_list = empty_obj_list + 1 
		end
	end

	local goal_list = {}
	if kind == DATA_RECOMMEND then
		goal_list = friend_data_handler:getRecommendList()
	elseif kind == DATA_SEARCH then
		goal_list = friend_data_handler:getSearchList()
	end
	
	if not goal_list or #goal_list < 1 then
		empty_obj_list = empty_obj_list + 1
		if empty_obj_list == 2 then
			return
		end
	end

	self.list_view = ClsFriendScrollView.new(785, 420, true, function()

    end)

	--移动的时候推荐
	local function askRecommendList(drag)
		local main_ui = getUIManager():get("ClsFriendMainUI")
        main_ui:closeExpandPanel()

		if math.abs(drag.end_y - drag.start_y) < ASK_OFFSET then return end
		if self.is_asking then return end
		self.is_asking = true

		local friend_data_handler = getGameData():getFriendDataHandler()
		local latest_num = friend_data_handler:getLatestRcommendNum()
		if latest_num >= PER_ASK_RECOMMEND_MORE_THAN then
			friend_data_handler:askNextRecommend()
		else
			self.is_asking = false
		end
	end

	if kind == DATA_RECOMMEND then
		self.list_view:setMoveCall(askRecommendList)
	elseif kind == DATA_SEARCH then
		self.list_view:setMoveCall(function() 
	        local main_ui = getUIManager():get("ClsFriendMainUI")
	        main_ui:closeExpandPanel()
   		end)
	end

    self.cells = {}
    local cell_size = CCSize(768, 104)

    if not not_show_apply then
	    --先创建新好友的cell
	    for k, v in ipairs(apply_list) do
	    	local cell = ClsNewCell.new(cell_size, v)
	    	table.insert(self.cells, cell)
	    end
	end

    --对应类型的cell
    for k, v in ipairs(goal_list) do
    	local cell_type = (kind == DATA_SEARCH) and ClsSearchCell or ClsRecommendCell
        local cell = cell_type.new(cell_size, v)
        table.insert(self.cells, cell)
    end

    self.list_view:addCells(self.cells)
    self.list_view:setPosition(ccp(185, -13))
    self:addChild(self.list_view)
    self.getGuideObj = function()
		if not self.cells then return end
		local guide_layer = self.list_view:getInnerLayer()
		for k, cell in ipairs(self.cells) do
			table.print(cell)
			if k == 1 and not cell.is_new_cell then
				local world_pos = cell:convertToWorldSpace(ccp(680, 55))
				local parent_pos = guide_layer:convertToWorldSpace(ccp(0,0))
				local guide_node_pos = {['x'] = world_pos.x - parent_pos.x, ['y'] = world_pos.y - parent_pos.y}
				return guide_layer, guide_node_pos, {['w'] = 133, ['h'] = 40}
			end
		end
	end

	local arr = CCArray:create()
    arr:addObject(CCDelayTime:create(0.5))
    arr:addObject(CCCallFunc:create(function() 
        local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
        ClsGuideMgr:tryGuide("ClsFriendMainUI")
    end))
    self:runAction(CCSequence:create(arr))
end

--添加搜索好友cell
function ClsAddPanelUI:addSearchCell(info)
	if self.content_status == DATA_RECOMMEND then return end

	if tolua.isnull(self.list_view) then
		self:updateListView(DATA_SEARCH, true)
	else
		local is_exist = false
		for i, j in ipairs(self.list_view.m_cells) do
			if j.m_cell_date.uid == info.uid then
				is_exist = true
			end
		end
		if not is_exist then
			local cell = ClsSearchCell.new(CCSize(768, 104), info)
			self.list_view:addCell(cell)
		end
	end
end

--添加推荐好友cell
function ClsAddPanelUI:addRecommendCell(info)
	if self.content_status == DATA_SEARCH then return end

	if tolua.isnull(self.list_view) then
		self:updateListView(DATA_RECOMMEND)
	else
		local is_exist = false
		for i, j in ipairs(self.list_view.m_cells) do
			if j.m_cell_date.uid == info.uid then
				is_exist = true
			end
		end
		if not is_exist then
			local cell = ClsRecommendCell.new(CCSize(768, 104), info)
			self.list_view:addCell(cell)
		end
	end
end

--插入申请cell
function ClsAddPanelUI:insertApplyCell(info)
	local main_ui = getUIManager():get("ClsFriendMainUI")
    main_ui:closeExpandPanel()
	if self.content_status == DATA_SEARCH then return end

	if tolua.isnull(self.list_view) then
		self:updateListView()
	else
		local is_exist = false
		for i, j in ipairs(self.list_view.m_cells) do
			if j.m_cell_date.uid == info.uid and j.is_new_cell then
				is_exist = true
			end
		end
		if not is_exist then		
			local friend_data_handler = getGameData():getFriendDataHandler()
			local cell = ClsNewCell.new(CCSize(768, 104), info)
			local apply_list = friend_data_handler:getApplyList()
			self.list_view:addCellByIndex(cell, 1)
		end
	end
end

function ClsAddPanelUI:removeApplyCellByUid(uid)
	local main_ui = getUIManager():get("ClsFriendMainUI")
    main_ui:closeExpandPanel()
    
	if tolua.isnull(self.list_view) then return end
	for k, v in ipairs(self.list_view.m_cells) do
		if v.m_cell_date.uid == uid and v.is_new_cell then
			self.list_view:removeCell(v)
			break
		end
	end
end

--更新添加好友按钮的状态
function ClsAddPanelUI:updateAddBtnStatus(uid, status)
	local main_ui = getUIManager():get("ClsFriendMainUI")
    main_ui:closeExpandPanel()
	if tolua.isnull(self.list_view) then return end

	local friend_data_handler = getGameData():getFriendDataHandler()
	for k, v in ipairs(self.list_view.m_cells) do
		if v.m_cell_date.uid == uid then
			v.m_cell_date.status = status
			if not tolua.isnull(v.btn_add) then
				if friend_data_handler:isMyFriend(uid) then
					v.btn_add:disable()
					v.btn_add.text:setText(ui_word.FRIEND_ALREADY_ADD)
				else
					if status == 1 then--申请中
						v.btn_add:disable()
						v.btn_add.text:setText(ui_word.TIP_APPLYED)
					else
						v.btn_add:active()
						v.btn_add.text:setText(ui_word.STR_ADDFRIEND)
					end
				end
				v.btn_add:setVisible(true)
			end
		end
	end
end

function ClsAddPanelUI:updateCell(info)
	if tolua.isnull(self.list_view) then return end
    for k, v in ipairs(self.list_view.m_cells) do
        if v.m_cell_date.uid == info.uid then
            v.m_cell_date = info
            if v:getIsCreate() then
                v:callUpdateUI()
            end
        end
    end	
end

function ClsAddPanelUI:setEditBoxTouch(enable)
	self.edit_box:setTouchEnabled(enable)
end

function ClsAddPanelUI:setAskStatus(bool)
	self.is_asking = bool
end

function ClsAddPanelUI:updateFriendNum()
	local friend_data_handler = getGameData():getFriendDataHandler()
	local current_num = friend_data_handler:getFriendNum()
    local show_text = string.format("%s/%s", current_num, FRIENT_MAX_NUM)
    self.friend_num:setText(show_text)
end

function ClsAddPanelUI:setTipVisible(enable)
	self.tip:setVisible(enable)
end

return ClsAddPanelUI

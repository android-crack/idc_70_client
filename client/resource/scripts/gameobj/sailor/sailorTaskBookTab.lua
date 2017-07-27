-- 航海士传记
-- Author: Ltian
-- Date: 2015-11-23 15:02:25
--
local info_sailor_mission =  require("game_config/sailor/info_sailor_mission")
local element_mgr = require("base/element_mgr")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local MyTransition  = require("ui/tools/MyTransition")
local music_info=require("game_config/music_info")
local dialog = require("ui/dialogLayer")
local reward_info = require("game_config/sailor/reward_sailor_mission")

local ClsSailorTaskItem = class("ClsSailorTaskItem", require("ui/tools/SwitchViewCell"))

function ClsSailorTaskItem:ctor(size, data, index, sailor)

	element_mgr:add_element("ClsSailorTaskItem", self)
	self.mission_info = data
	self.rect = rect
	self.index = index
	self.sailor = sailor

end
local widget_name = {
	"book_lock",
	"btn_item",
	"book_select_bg",
	"book_icon",
}
--判断触摸点是否在按钮内
function ClsSailorTaskItem:containsPoint( obj, rect )
	obj = tolua.cast(obj, "UIWidget")
    local point = obj:getTouchEndPos()
    if not rect:containsPoint(ccp(point.x, point.y)) then
  		return false
    else
     	return true
    end
end

function ClsSailorTaskItem:mkUi(index)
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_sailor_story_list.json")
	convertUIType(self.panel)
	self.layer:addWidget(self.panel)
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	-- self.item_lock:setVisible(true)
	-- self.btn_item:setTouchEnabled(false)
-- self.item_icon:setTouchEnabled(false)
	-- self.item_icon:setVisible(true)
	-- self.item_lock:setTouchEnabled(false)
	self:updateView()
end

function ClsSailorTaskItem:updateView()
	self.book_icon:changeTexture(convertResources(self.mission_info.res), UI_TEX_TYPE_PLIST)
	local status = true
	if self.sailor.memoirChapter < self.index then
		-- if (self.sailor.memoirChapter == self.index - 1) and (self.sailor.memoirStatus == 2) then --判断前一个任务完成
		-- 	status = false
		-- else
			status = true
		-- end
	else
		status = false
	end
	self.book_lock:setVisible(status)
	self.book_icon:setVisible(not status)
end
function ClsSailorTaskItem:select(index)
	if self.select_call_back ~= nil then
        self:select_call_back()
    end
end

function ClsSailorTaskItem:unSelect(index)
	
end

function ClsSailorTaskItem:setSelectCallBack(callBackFunc)
	self.select_call_back = callBackFunc
end

function ClsSailorTaskItem:mkItem(index)
	if tolua.isnull(self) then return end
	if not tolua.isnull(self.layer) then return end
   	self.layer = UILayer:create()
    self:addChild(self.layer)
	self:mkUi(index)
end

function ClsSailorTaskItem:setSelect(flag)
	self.book_select_bg:setVisible(flag)
	if self.index > self.sailor.memoirChapter then
		if flag then
			self.book_lock:changeTexture("hotel_story_icon4.png", UI_TEX_TYPE_PLIST)
		else
			self.book_lock:changeTexture("hotel_story_icon3.png", UI_TEX_TYPE_PLIST)
		end
	else
		self.book_select_bg:setVisible(flag)
	end
end

function ClsSailorTaskItem:setTapCallFunc(func)
	self.tapFunc = func
end

function ClsSailorTaskItem:onTap(x,y)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local element = element_mgr:get_element("ClsSailorTaskBookTab")
	if element and not tolua.isnull(element) then
		element:selectMission(self.index)
	end
end

function ClsSailorTaskItem:delItem()
	if tolua.isnull(self) then return end
	if tolua.isnull(self.layer) then return end
	self.layer:removeFromParentAndCleanup(true)
    self.layer = nil
end


-----------------------------传记tab-------------------------------------------------------
local ClsDynSwitchView = require("ui/tools/DynSwitchView")
local ClsSailorTaskBookTab = class("ClsSailorTaskBookTab", function() return CCLayerColor:create(ccc4(0,0,0,127)) end)
local tab_widget = {
	"btn_open",
	"name_info_text",
	"story_info",
	"state_info_text",
	"award_info_num",
	"btn_close",
	"book_arrow_right",
	"book_arrow_left",
	"gold_icon",
	"open_info_3",
	"open_info_2",
	"open_info_1",
	"btn_open_text",
}
function ClsSailorTaskBookTab:ctor(sailor, is_dialog, num, opacity)
	if opacity then
		self:setOpacity(127)
	else
		self:setOpacity(0)
	end
	self.layer = display.newLayer()
	self:addChild(self.layer)
	self.num = num                  --招募翻盘下一个翻盘的位置
	self.is_dialog = is_dialog      --是否是招募传记弹框翻出
	self.is_give_up_mission = false
	self.select_mission = 0
	element_mgr:add_element("ClsSailorTaskBookTab", self)
	self.sailor = sailor
	self.plist = {
		["ui/hotel_ui.plist"] = 1,
        ["ui/skill_icon.plist"] = 1,
        ["ui/baowu.plist"] = 1, 
        ["ui/equip_icon.plist"] = 1, 
    }
	LoadPlist(self.plist)
	self.cells = {}
	self:mkUI()
	self:regFunc()
    local Tips = require("ui/tools/Tips")
    audioExt.playEffect(music_info.TOWN_CARD.res)
    Tips:runAction(self.layer)

end

function ClsSailorTaskBookTab:mkUI()
	self.ui_layer = UILayer:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_sailor_story.json")
	self.layer:addChild(self.ui_layer)
	self.ui_layer:addWidget(self.panel)
	for k,v in pairs(tab_widget) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:initUI()
	self:regCB()
end

function ClsSailorTaskBookTab:initUI()
	self.story_infos = info_sailor_mission[self.sailor.id]
	self:createList()
	
end

function ClsSailorTaskBookTab:createList()
	local _rect = CCRect(60, 350, 282, 100)
	local cell_size = CCSize(100, 100)
	self.list_view = ClsDynSwitchView.new({rect = _rect, x = 0, y = 0, direct = 1, isButton = false,
	widget_left_btn = self.book_arrow_left,
	widget_right_btn = self.book_arrow_right})
	self.book_arrow_left:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local index = self.list_view:getCurrentIndex()
		self.list_view:scrollToCell(index - 1,true)
	end, TOUCH_EVENT_ENDED)
	self.book_arrow_right:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local index = self.list_view:getCurrentIndex()
		self.list_view:scrollToCell(index + 1,true)
	end, TOUCH_EVENT_ENDED)
	self.panel:addCCNode(self.list_view)
	for k,v in ipairs(self.story_infos) do
		self.cells[k] = ClsSailorTaskItem.new(cell_size, v, k, self.sailor)
		self.list_view:addCell(self.cells[k])
	end
	local defult_index = 1
	local sailorData = getGameData():getSailorData()
	local sailor_task_id = sailorData:getSailorTaskID()
	if self.sailor.id == sailor_task_id then
		defult_index = self.sailor.memoirChapter
	end
	self.list_view:setCurrentIndex(defult_index)
	self:selectMission(defult_index)
end

function ClsSailorTaskBookTab:selectMission(index)
	self.index = index
	if self.select_target then
		self.select_target:setSelect(false)
	end
	self.select_target = self.cells[index]
	local mission = self.story_infos[index]
	self.cells[index]:setSelect(true)
	self:updateMissionInfo(mission, index)
end

function ClsSailorTaskBookTab:setPriority(priority)
	self.ui_layer:setTouchPriority(priority)
	self.list_view:setTouchPriority(priority - 1)
end

function ClsSailorTaskBookTab:updateMissionInfo(mission)
	self.is_give_up_mission = false
	self.select_mission = mission.mission
	self.name_info_text:setText(mission.tips)
	self.story_info:setText(mission.tips_info)
	
	local memoir_chapter = self.sailor.memoirChapter
	local memoir_status = self.sailor.memoirStatus

	if mission.chapter > memoir_chapter then          --任务状态
		self.state_info_text:setText(ui_word.PORT_LOCK)
	elseif mission.chapter == memoir_chapter then
		if memoir_status == 0 then
			self.state_info_text:setText(ui_word.IS_NOT_OPEN)
		elseif memoir_status == 2 then
			self.state_info_text:setText(ui_word.GUILD_TASK_DONE)
		else
			self.state_info_text:setText(ui_word.IS_DOING)
		end
	else
		self.state_info_text:setText(ui_word.GUILD_TASK_DONE)
	end
	
	local lock_count = #mission.unlock
	for i=1,3 do
		self["open_info_"..i]:setVisible(false)
	end
	for i,v in ipairs(mission.unlock) do
		self["open_info_"..i]:setText(v)
		self["open_info_"..i]:setVisible(true)
	end
	local ccps = self.story_info:getPosition()
	local offset_Y =  -40 - 20 *lock_count
	self.story_info:setPosition(ccp(ccps.x, offset_Y))
	

	local sailor_data = getGameData():getSailorData()
	local sailor_task_id = sailor_data:getSailorTaskID() --获取正在做水手任务的水手id

	if mission.chapter == memoir_chapter then
		if memoir_status == 1 then
			self.btn_open:setVisible(true)
			self.btn_open_text:setText(ui_word.HOTEL_REWARD_GIVE_UP_TASK)
			self.btn_open:setTouchEnabled(true)
			self.is_give_up_mission = true
		elseif memoir_status == 0 then
			self.btn_open_text:setText(ui_word.SYS_OPEN)
			self.btn_open:setVisible(true)
			self.btn_open:setTouchEnabled(true)
		else
			self.btn_open:setVisible(false)
		end
	else
		self.btn_open:setVisible(false)
	end
	local reward = self:getRewardInfo(self.select_mission)
	
	local icon, amount, scale, name, di_tu, armature_res = getCommonRewardIcon(reward)
	-- ITEM_INDEX_BAOWU
	self.gold_icon:changeTexture(convertResources(icon), UI_TEX_TYPE_PLIST)
	--self.gold_icon:setScale(scale)
	local info
	if reward.key == ITEM_INDEX_BAOWU then
		info = "  "..name
	else
		info = "  "..name.." "..amount
	end
	self.award_info_num:setText(info)


end
function ClsSailorTaskBookTab:regCB()
	self.btn_open:setPressedActionEnabled(true)
	self.btn_open:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if not self.select_target then return end
		self.btn_open:setTouchEnabled(false)
		local sailor_data = getGameData():getSailorData()
		if self.is_give_up_mission then  --放弃水手任务
			sailor_data:cancelSailorMission(self.sailor.id, self.select_mission)
			return
		end
		
		sailor_data:openSailorTask(self.sailor.id)
	end, TOUCH_EVENT_ENDED)
	
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		MyTransition:delLayer(self, nil, true)
		if self.is_dialog then
			dialog.hideDialog()
			local clsSailorRecruitView = element_mgr:get_element("clsSailorRecruitView")
			if not tolua.isnull(clsSailorRecruitView) then
	            clsSailorRecruitView:turnTheCard(self.num, true)
	            
			end
		end


	end, TOUCH_EVENT_ENDED)
end

function ClsSailorTaskBookTab:getRewardInfo(mission_id)
	local tab = {
		["material"] = ITEM_INDEX_MATERIAL,
		["darwing"] = ITEM_INDEX_DARWING,
		["keepsake"] = ITEM_INDEX_KEEPSAKE,
		["item"] = ITEM_INDEX_PROP,
		["equip"] = ITEM_INDEX_EQUIP,
		["exp"] = ITEM_INDEX_EXP,
		["cash"] = ITEM_INDEX_CASH,
		["gold"] = ITEM_INDEX_GOLD,
		["tili"] = ITEM_INDEX_TILI,
		["honour"] = ITEM_INDEX_HONOUR,
		["sailor"] = ITEM_INDEX_SAILOR,
		["status"] = ITEM_INDEX_STATUS,
		["food"] = ITEM_INDEX_FOOD,
		["baowu"] = ITEM_INDEX_BAOWU,
		["contribute"] = ITEM_INDEX_CONTRIBUTE,
		["prestige"] = ITEM_INDEX_DONATE,	
		["prosper"] = ITEM_INDEX_PROSPER,
	}
	local list_tab = reward_info[tostring(mission_id)]
	
	local reward_info = {}
	reward_info.key = tab[list_tab.type]
	reward_info.id = list_tab.id
	reward_info.amount = list_tab.cnt
	return reward_info
end


function ClsSailorTaskBookTab:updateMission()
	self:selectMission(self.index)
end

function ClsSailorTaskBookTab:onExit()
	element_mgr:del_element("ClsSailorTaskBookTab")
	UnLoadPlist(self.plist)
end

function ClsSailorTaskBookTab:regFunc()
	self:registerScriptHandler(function(event)
		if event == "exit" then self:onExit() end
	end)
end

return ClsSailorTaskBookTab
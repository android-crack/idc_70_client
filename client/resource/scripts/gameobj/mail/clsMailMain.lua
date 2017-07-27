--
-- Author: Ltian
-- Date: 2015-10-21 10:46:25
--
local uiTools = require("gameobj/uiTools")
local music_info=require("game_config/music_info")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsMailItem = require("gameobj/mail/clsMailItem")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsAlert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")

local ClsMailMain = class("ClsMailMain", ClsBaseView)

local widget_name = {
	"btn_close",
	"btn_tips"
}


function ClsMailMain:getViewConfig(...)
	return {
		is_back_bg = true,
		effect = UI_EFFECT.DOWN,
	}
end

function ClsMailMain:onEnter()
	self.plistTab = {
		["ui/baowu.plist"] = 1,
		["ui/equip_icon.plist"] = 1,
		["ui/material_icon.plist"] = 1,
		["ui/ship_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}
   
	
	LoadPlist(self.plistTab)
	self.cells = {}
	self:initUi()
	self:readMail()
end

function ClsMailMain:readMail()
	local mail_data = getGameData():getmailData()
	local mail_list = mail_data:getLimit20Mail()
	local is_to_read = false --是否有未读邮件
	for k,v in pairs(mail_list) do
		if v.status == 0 then
			is_to_read = true
			mail_data:readMail(v.id)
		end
	end
	if not is_to_read then
		getGameData():getTaskData():setTask(on_off_info.MAIL_SYSTEM.value, false)
	end
end

function ClsMailMain:initUi()
	
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/mail.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	self:mkUi()
end


function ClsMailMain:bundlingJson()
	for k, v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:regListener()
end
function ClsMailMain:mkUi()
	self:bundlingJson()
	self:createList()
end

function ClsMailMain:createList()
	local HAS_GET = 2
	local index = 1
	if not self.list_view or tolua.isnull(self.list_view) then
		self.list_view = ClsScrollView.new(738, 420, true, function()
			local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/mail_list.json")
			--cell_ui.text_lab = getConvertChildByName(cell_ui, "giveup_text")
			return cell_ui
		end, {is_fit_bottom = true})
		self.list_view:setPosition(ccp(115, 42))
		self:addWidget(self.list_view)
	end
	index = self.list_view:getTopCellIndex()
	self.list_view:removeAllCells()
	local mail_data = getGameData():getmailData()
	local mail_list = mail_data:getSortedLimit20Mail()
	if #mail_list < 1 then return end


	--cocosStudio的， is_fit_bottom = true是滑动到底部时最后一个cell在底下，而不是在顶上
	
	
	self.cells = {}
	local cell_size = CCSize(455, 128)
	index = 1
	for k,v in ipairs(mail_list) do
		if v.status ~= HAS_GET then
			self.cells[index] = ClsMailItem.new(cell_size, {index = index, data = v})
			index = index + 1
		end
	end
	self.list_view:addCells(self.cells)

	self.list_view:scrollToCellIndex(index)
end

function ClsMailMain:updateAllCell()
	self:createList()
end

function ClsMailMain:updateView(mail_id)
	local index = 1
	self:createList()

end

function ClsMailMain:regListener()
	-- tips
	self.btn_tips:setPressedActionEnabled(true)
	self.btn_tips:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		getUIManager():create("gameobj/mail/clsMailInstruction")
	end, TOUCH_EVENT_ENDED)

	-- close
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		--audioExt.playEffect(music_info.PAPER_STRETCH.res)
		self:close()
	end, TOUCH_EVENT_ENDED)

	RegTrigger(POWER_UPDATE_EVENT, function()
		local port_layer = getUIManager():get("ClsPortLayer")
		if tolua.isnull(port_layer) then
			return
		end
		if not tolua.isnull(self) then
			ClsAlert:goMunicipalWork(self)
		end
	end)  
end



function ClsMailMain:onExit()
	UnRegTrigger(POWER_UPDATE_EVENT)
	UnLoadPlist(self.plistTab)
end


return ClsMailMain
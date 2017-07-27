--
--酒馆主界面

local ui_word = require("game_config/ui_word")
local on_off_info = require("game_config/on_off_info")
local music_info = require("game_config/music_info")
local UiCommon = require("ui/tools/UiCommon")
local ClsSailorListView = require("gameobj/sailor/sailorListView")
local ClsSailorRecruit = require("gameobj/sailor/clsSailorRecruit")
local missionGuide = require("gameobj/mission/missionGuide")
local uiTools = require("gameobj/uiTools")
local voice_info = getLangVoiceInfo()
local ClsPlayerInfoItem = require("ui/tools/clsPlayerInfoItem")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")


local ClsHotelMain = class("ClsHotelMain", ClsBaseView)

local TREAT_TAB_INDEX = 1
local LIST_TAB_INDEX = 2
local SAILOR_AWAKE = 3

local btn_name = {
	{res = "tab_treat", text = "btn_treat_text", onOffValue = on_off_info.PORT_HOTEL_ENLIST.value,taskKeys = {
    	on_off_info.WINE_ENLIST.value,--普通招募，包含免费次数
    	--on_off_info.PORT_HOTEL_ENLIST.value,
    }},
	{res = "tab_list", text = "btn_list_text", onOffValue = on_off_info.PORT_HOTEL_STUDY.value},
	{res = "tab_wake", text = "btn_wake_text", onOffValue = on_off_info.LEGEND_SAILOR_HOTEL.value},
}

local widget_name = {
	"btn_close",
	"diamond_bg",
	"wine_bg",
}

function ClsHotelMain:getViewConfig()
    return {
        is_swallow = true,          
        effect = UI_EFFECT.FADE,   
        hide_before_view = true,
    }
end

function ClsHotelMain:onFadeFinish()
    self.is_finish_effect = true
	if not tolua.isnull(self.childPanel) then
		self.childPanel:setViewVisible(true)
	end
end

function ClsHotelMain:mkUI()
	missionGuide:disableAllGuide()
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	---开关		
	local onOffData = getGameData():getOnOffData()
	for k,v in pairs(btn_name) do
		self[v.res] = getConvertChildByName(self.panel, v.res)
		self[v.res].text = getConvertChildByName(self.panel, v.text)
		self[v.res]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:selcetView(k)
		end,TOUCH_EVENT_ENDED)

		
		
		onOffData:pushOpenBtn(v.onOffValue, {openBtn=self[v.res], openEnable=true, addLock = true, parent = "ClsHotelMain",
			labelOpacity = 255*0.75,btnRes = "#common_btn_tab7.png", callBack=function(isOpen)
			end})

		if v.taskKeys then
			local taskData = getGameData():getTaskData()
			taskData:regTask(self[v.res],v.taskKeys,KIND_RECTANGLE,v.onOffValue, 74, 32, true)
		end

		missionGuide:pushGuideBtn(v.onOffValue, {guideBtn=self[v.res], guideLayer=self, x=100, y = 350 + (k - 1) * 80, isUIWidget=true})
	end
	if not onOffData:isOpen(on_off_info.LEGEND_SAILOR_HOTEL.value) then
		self.tab_wake:setVisible(false)
	end
	
	local diamond_layer = ClsPlayerInfoItem.new(ITEM_INDEX_GOLD)
	self.diamond_bg:addCCNode(diamond_layer)
	local wine_layer = ClsPlayerInfoItem.new(ITEM_INDEX_HONOUR)
	self.wine_bg:addCCNode(wine_layer)

	self:BtnCallBack()
	self:defaultView(self.tab)
end

function ClsHotelMain:defaultView(tab)
	self:selcetView(tab)
end

function ClsHotelMain:BtnCallBack()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)

		if getUIManager():isLive("ClsSailorListView") then
			getUIManager():get("ClsSailorListView"):close()
		end
		if getUIManager():isLive("clsSailorRecruit") then
			getUIManager():get("clsSailorRecruit"):close()
		end
		self:effectClose()
		--self:close()

	end,TOUCH_EVENT_ENDED)
end

function ClsHotelMain:selcetView(tab)

	if self.tab_view then
		if getUIManager():isLive(self.tab_view) then
			getUIManager():get(self.tab_view):close()
		end
	end

	for k,v in pairs(btn_name) do
		self[v.res]:setFocused(tab == k)
		self[v.res]:setTouchEnabled(tab ~= k)
		if tab == k then
			setUILabelColor(self[v.res].text, ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
		else
			setUILabelColor(self[v.res].text, ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
		end
	end

	if tab == TREAT_TAB_INDEX then

		self.childPanel = getUIManager():create("gameobj/sailor/clsSailorRecruit")
		self.btn_close:setVisible(true)
		self.tab_view = "clsSailorRecruit"
	elseif tab == LIST_TAB_INDEX then

		local function closeCallBack()
			self:close()
		end

		self.childPanel = getUIManager():create("gameobj/sailor/sailorListView" , {}, closeCallBack, self.equik_id, self.partner_data)
		self.btn_close:setVisible(false)
		self.tab_view = "ClsSailorListView"
	elseif tab == SAILOR_AWAKE then
		local function closeCallBack()
			self:close()
		end
		self.childPanel = getUIManager():create("gameobj/sailor/clsSailorAwakeList" , {}, closeCallBack)
		self.btn_close:setVisible(false)
		self.tab_view = "ClsSailorAwakeList"
	end
	
	if not self.is_finish_effect and not tolua.isnull(self.childPanel)  then
		self.childPanel:setViewVisible(false)
	end


	self.tab = tab 
	self.diamond_bg:setVisible(tab == TREAT_TAB_INDEX)
	self.wine_bg:setVisible(tab == TREAT_TAB_INDEX)	

	ClsGuideMgr:tryGuide("ClsHotelMain")
end

---alert中星章不足用到
function ClsHotelMain:getCurrentTabIndex()
	return self.tab
end

function ClsHotelMain:getSailorRecruitBtn()
	return self.tab_treat
end

function ClsHotelMain:getSailorListBtn()
	return self.tab_list
end

function ClsHotelMain:setBtnTouchEnable(enable)
	self.tab_treat:setTouchEnabled(enable)
	self.tab_list:setTouchEnabled(enable)
end

function ClsHotelMain:onEnter(tab)
	self.plistTab = {
		["ui/skill_icon.plist"] = 1,
		["ui/hotel_ui.plist"] = 1,
	}
	LoadPlist(self.plistTab)	
	self.is_finish_effect = false

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_background.json")
	self:addWidget(self.panel)

	if equik_id then
		self.equik_id = equik_id 
	end 
	if partner_data then
		self.partner_data = partner_data 
	end 

	self.tab = tab or 1
	if self.tab == TREAT_TAB_INDEX then
		audioExt.playEffect(voice_info["VOICE_PLOT_1005"].res, false)
	end

	self.tab_view = nil 
	self:mkUI()
end

function ClsHotelMain:onExit()
	UnLoadPlist(self.plistTab)
end

return ClsHotelMain
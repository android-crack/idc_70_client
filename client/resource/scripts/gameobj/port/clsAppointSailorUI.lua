--
-- Author: lzg0496
-- Date: 2016-07-11 11:10:16
-- Function: 市政厅任命水手界面

local music_info = require("game_config/music_info")
local ClsSailorListItem = require("gameobj/port/clsAppointSailorItem")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")
local voice_info = getLangVoiceInfo()
local ClsSwitchView = require("ui/tools/SwitchView")
local ui_word = require("game_config/ui_word")
local ClsPartnerInfoView = require("gameobj/partner/clsPartnerInfoView")
local alert = require("ui/tools/alert")
local sailor_info = require("game_config/sailor/sailor_info")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info = require("game_config/on_off_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
--港口投资状态
local SAILOR_PORT_INVEST_STATAS = 5
local SAILOR_GUILD_APPOINT_STATUS = 4
local SAILOR_BOAT_APPOINT_STATUS = 2
local needWidgetName = {
	btn_close = "btn_close",
	btn_left_view = "btn_left_arrow",
	btn_right_view = "btn_right_arrow",
	btn_appoint = "btn_appoint",
	lbl_appoint_txt = "btn_appoint_text",
	lab_title = "title",
	lab_title_sailor = "title_sailor",
}

local widget_btn = {
	"btn_adventure",			
	"btn_navy",
	"btn_pirate",
}

local text_name = {	
	"btn_adventure_text",
	"btn_navy_text",
	"btn_pirate_text",
}

local btn_pic = {
	"adventure_selected",
	"navy_selected",
	"pirate_selected",
}

local clsAppointSailorUI = class("clsAppointSailorUI", ClsBaseView)

function clsAppointSailorUI:getViewConfig()
    return {
        is_swallow = true,          
        effect = UI_EFFECT.FADE,   
    }
end

----view_pos:从编制界面（小伙伴）显示  sailor_pos :航海士任命的位置
function clsAppointSailorUI:onEnter( view_pos, sailor_pos)
	self.view_pos = view_pos
	self.sailor_pos = sailor_pos 
	self.plistTab = {
		["ui/hotel_ui.plist"] = 1,
	}
	LoadPlist(self.plistTab)

	self.sialor_jobs = {
		[1] = 1,
		[2] = 2,
		[3] = 3,
	}

	self.filter_tab = {  --航海士过滤表
		false,
		false,
		false,
	}

    self.is_men_voice = true ---航海士音效控制
	self.is_women_voice = true

	self.is_sailor_order = false

	self.cells = {}
	self:makeUI()
	self:configEvent()
	self:updateTab()	
end

function clsAppointSailorUI:makeUI()

	self.hotel_appoint = GUIReader:shareReader():widgetFromJsonFile("json/hotel_appoint.json")
	self:addWidget(self.hotel_appoint)

	for k, v in pairs(needWidgetName) do
		self[k] = getConvertChildByName(self.hotel_appoint, v)
	end

	for k,v in pairs(text_name) do
		self[v] = getConvertChildByName(self.hotel_appoint, v)
	end

	for k,v in pairs(btn_pic) do
		self[v] = getConvertChildByName(self.hotel_appoint, v)
	end	

	for k,v in pairs(widget_btn) do
		self[v] = getConvertChildByName(self.hotel_appoint, v)

		self[v]:setTouchEnabled(true)
		self[v]:addEventListener(function()
			self[v]:setScale(1.2)
		end,TOUCH_EVENT_BEGAN)

		self[v]:addEventListener(function()
			self[v]:setScale(1.0)
			self:updateTab()
		end,TOUCH_EVENT_CANCELED)

		self[v]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)			
			--self[v]:setScale(1.0)
			self:regBtnCB(k)
		end, TOUCH_EVENT_ENDED)
	end

	self.lab_title:setVisible(not self.view_pos)
	self.lab_title_sailor:setVisible(self.view_pos)
	if not self.sailor_pos then
		self.btn_appoint:setVisible(false)
	end


	missionGuide:pushGuideBtn(on_off_info.HOTEL_APPOINT.value, {guideLayer = self, rect = CCRect(786, 18, 134, 42)})
	ClsGuideMgr:tryGuide("clsAppointSailorUI")
end

function clsAppointSailorUI:updateTab()
	for k,v in pairs(self.filter_tab) do
		self[widget_btn[k]]:setFocused(v)
		self[text_name[k]]:setVisible(v)
		self[text_name[k]]:setColor(ccc3(dexToColor3B(COLOR_WHITE_STROKE)))
	end

	self:updateList(nil, self.is_sailor_order)
end

function clsAppointSailorUI:regBtnCB(index)
	self.filter_tab[index] = not self.filter_tab[index]

	for k,v in pairs(self.filter_tab) do
		if k ~= index and v then
			self.filter_tab[k] = not self.filter_tab[k] 
		end
	end

	for k,v in pairs(btn_pic) do
		self[v]:setVisible(self.filter_tab[k])
	end

	for k,v in pairs(self.filter_tab) do
		local scale = 1
		if v then
			scale = 1.2	
		end
		self[widget_btn[k]]:setScale(scale)
	end
	self:updateTab()
end

function clsAppointSailorUI:updateList(is_old_set, is_order)
	if self.list_view and not tolua.isnull(self.list_view) then
		self.old_index = self.list_view:getTopCellIndex()
		self.list_view:removeAllCells()
		self.cells = {}
	else

	    local score_view = ClsScrollView.new(900, 400, false, nil, {is_fit_bottom = true})
	    score_view:setPosition(ccp(25, 90))
	    self:addWidget(score_view)
	    self.list_view = score_view		
	end


	local sailorData = getGameData():getSailorData()

	local sailor = {}
	local otherSailor = {}

	local sailor_re, otherSailor_re = sailorData:filterSailors(self.filter_tab)----过滤过的不同职业的航海士	

	local sailors = sailorData:getOwnSailors()
	

	sailor = sailor_re
	otherSailor = otherSailor_re


	sailor = self:sequenceListByStar(sailor)      ----稀有度
	otherSailor = self:sequenceListByStar(otherSailor)	

 	local sailor_select = {}--table.clone(sailor)--sailor
 	local sailor_unslect ={}

	sailor_select = sailor
	sailor_unslect = otherSailor
	if self:isSelectSailorJob() then

	else
		for k,v in pairs(sailor_unslect) do
			sailor_select[#sailor_select + 1] = v
		end
	end
    self.sailor_list = sailor_select 


   	local sailor_count = #self.sailor_list
	local cell_size = CCSize(165, 400)
	local raw = 2		--一列放2个cell
	local toalCol = math.ceil(sailor_count/raw) --cell的总数
	for i=1,toalCol do
		local tab = {}
		for j=1,2 do
			local index = (i - 1) * raw + j
			if sailor_select[index] then
				table.insert(tab, sailor_select[index])	
			end
		end

		self.cells[i] = ClsSailorListItem.new(cell_size, {key = tab, is_fire = self.is_fire, view_pos = self.view_pos, sailor_id = self.selecte_partner_id})

	end
	self.list_view:addCells(self.cells)

	self.btn_left_view:setVisible(sailor_count ~= 0)
	self.btn_right_view:setVisible(sailor_count ~= 0)

	if is_old_set then
		self.list_view:scrollToCellIndex(self.old_index)
	else
		self.list_view:scrollToCellIndex(1)
	end

	if sailor_count < 1 then return end
	self:addWidget(self.list_view)
	--self.list_view:setCurrentIndex(1)

end

function clsAppointSailorUI:updateUI()
	self:updateList()
end

function clsAppointSailorUI:isSelectSailorJob()
	for k,v in pairs(self.filter_tab) do
		if v then
			return true	
		end
	end
	return false
end

function clsAppointSailorUI:priorityByExpStep(a, b)
	local sailor_data = getGameData():getSailorData()
	local a_exp_step = sailor_data:getSailorExpStep(a.id)
	local b_exp_step = sailor_data:getSailorExpStep(b.id)
	return a_exp_step == b_exp_step, a_exp_step > b_exp_step
end

function clsAppointSailorUI:priorityByWork(a, b)
	return a.status == b.status, a.status < b.status
end


--稀有度优先级
function clsAppointSailorUI:priorityByStar(a, b)
	return a.star == b.star, a.star > b.star
end

--等级优先级
function clsAppointSailorUI:priorityByLevel(a, b)
	return a.level == b.level, a.level > b.level
end

--星级优先级
function clsAppointSailorUI:priorityBystarLevel(a, b)
	return a.starLevel == b.starLevel, a.starLevel > b.starLevel
end

---获取职业的优先级
function clsAppointSailorUI:getSailorPriority(sailor)
	return self.sialor_jobs[sailor.job[1]]
end

--职业排序
function clsAppointSailorUI:priorityByJob(a, b)
	local ajob = self:getSailorPriority(a)
	local bjob = self:getSailorPriority(b) 
	return ajob == bjob, ajob < bjob
end
---id排序
function clsAppointSailorUI:priorityById(a, b)
	return a.id == b.id, a.id < b.id
end

--稀有度优先级
function clsAppointSailorUI:sequenceListByStar(sailors)
	local temp = {}
	for k, v in pairs(sailors) do
		temp[#temp + 1] = v
	end
	table.sort(temp, function(a, b)
		local flag, result = self:priorityByWork(a, b)    --在职
		if flag ~= true then return result end
		local flag, result = self:priorityByStar(a, b)    --品质
		if flag ~= true then return result end    
		flag, result = self:priorityByLevel(a, b)   --等级
		if flag ~= true then return result end  
		flag, result = self:priorityByJob(a, b)   --职业
		if flag ~= true then return result end 
		flag, result = self:priorityById(a, b)   --id
		if flag ~= true then return result end 
		return result
	end)
	return temp
end

function clsAppointSailorUI:configEvent()
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)

		self:close()
	end, TOUCH_EVENT_ENDED)

	
	self.btn_left_view:setPressedActionEnabled(true)
	self.btn_left_view:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local index = self.list_view:getTopCellIndex()

		local set_index = index - 5
		if set_index <= 0 then 
			set_index = 1
		end 
		self.list_view:scrollToCellIndex(set_index)
	end, TOUCH_EVENT_ENDED)

	self.btn_right_view:setPressedActionEnabled(true)
	self.btn_right_view:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local index = self.list_view:getTopCellIndex()
		self.list_view:scrollToCellIndex(index + 5)
	end, TOUCH_EVENT_ENDED)

	self.btn_appoint:setPressedActionEnabled(true)

	self.btn_appoint:addEventListener(function ()
		if self.selecte_sailor_status ~= STATUS_NULL then
			self.btn_appoint:disable()
		end
	end,TOUCH_EVENT_BEGAN)

	self.btn_appoint:addEventListener(function ()
		if self.selecte_sailor_status ~= STATUS_NULL then
			self.btn_appoint:disable()
			self.btn_appoint:setTouchEnabled(true)
		end
	end,TOUCH_EVENT_CANCELED)

	self.btn_appoint:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if #self.sailor_list == 0 then
			alert:warning({msg = ui_word.INVEST_SAILOR_NO_APPOINT, size = 26})
			return 
		end

		local sailor_sex = sailor_info[self.selecte_sailor_id]["sex"]
		if sailor_sex == SEX_M then
			sound = voice_info["VOICE_BOAT_1001"].res 
		else
			sound = voice_info["VOICE_BOAT_1003"].res
		end
		audioExt.playEffect(sound)

		local investData = getGameData():getInvestData()
		if self.selecte_sailor_status == STATUS_NULL then
			---任命到船上
			if self.view_pos then
				local partner_data = getGameData():getPartnerData()
				local sailor_job = sailor_info[self.selecte_sailor_id]["job"][1]
				local boat_key = partner_data:getBoatKeyBySailorId(self.sailor_pos)

				if boat_key ~= 0 then
					local ship_data = getGameData():getShipData()
					local boat = ship_data:getBoatDataByKey(boat_key)
					if boat then	
						local is_match = partner_data:sailorMatchBoat(sailor_job, boat.id)
						if not is_match then
							alert:warning({msg = ui_word.INVEST_SAILOR_NO_MATCH, size = 26})
						end	
					end				
				end
				partner_data:askForPartnerApponit(self.sailor_pos, self.selecte_sailor_id)

			else
				investData:sendSetAppointSailor(self.selecte_sailor_id)  ---任命到市政厅				
			end

		else
			self.btn_appoint:disable()
			self.btn_appoint:setTouchEnabled(true)
			if self.selecte_sailor_status == SAILOR_PORT_INVEST_STATAS then   ---卸任市政厅航海士

				if self.view_pos then
					alert:warning({msg = ui_word.BOAT_SAILOR_NO_APPOINT, size = 26})
					return
				else
					investData:sendUnsetAppointSailor(self.selecte_sailor_id) 					
				end
  	
			elseif self.selecte_sailor_status == SAILOR_GUILD_APPOINT_STATUS  then  ---商会卸任
				alert:warning({msg = ui_word.GUILD_SAILOR_NO_APPOINT, size = 26})
				return 
			elseif self.selecte_sailor_status == SAILOR_BOAT_APPOINT_STATUS  then ---船航海士卸任
				alert:warning({msg = ui_word.BOAT_SAILOR_NO_APPOINT, size = 26})
				return 
			end
		end
		--self:setTouch(false)
	end, TOUCH_EVENT_ENDED)

end

function clsAppointSailorUI:getSailorList()
	return self.sailor_list
end

function clsAppointSailorUI:closeView()

	self:close()
end

function clsAppointSailorUI:sailorListTouch(enable)
	self.list_view:setTouchEnabled(enable)
	self.btn_left_view:setTouchEnabled(enable)
	self.btn_right_view:setTouchEnabled(enable)
end

function clsAppointSailorUI:updateSailorSelect(select_pic, sailor)
	local sound
	if sailor.sex == SEX_M then
		if self.is_men_voice then
			sound = voice_info["VOICE_BOAT_1000"].res
			audioExt.playEffect(sound)
			self.is_men_voice = false
		end
	else
		if self.is_women_voice then
			sound = voice_info["VOICE_BOAT_1002"].res 
			audioExt.playEffect(sound)
			self.is_women_voice = false
		end
	end

	if self.select_pic and not tolua.isnull(self.select_pic) then
		self.select_pic:setVisible(false)
	end
	self.select_pic = select_pic
	self.select_pic:setVisible(true)
	self.selecte_sailor_id = sailor.id
	self.selecte_sailor_status = sailor.status

	if sailor.status == STATUS_NULL then  --任命
		--self.lbl_appoint_txt:setText(ui_word.INVEST_APPOINT)
		self.btn_appoint:active()
	else
		--self.lbl_appoint_txt:setText(ui_word.INVEST_DEPARTURE)  --xi
		self.btn_appoint:disable()
		self.btn_appoint:setTouchEnabled(true)
	end
end

function clsAppointSailorUI:openSailorView(sailor)
	if not self.is_open_sailor_view then
		self.is_open_sailor_view = true		

		self.selecte_partner_id = sailor.id 
		if not getUIManager():isLive("ClsPartnerInfoView") then
			getUIManager():create("gameobj/partner/clsPartnerInfoView", {}, sailor)
		end

	end	
end

function clsAppointSailorUI:closeSailorViewCB()
	self.is_open_sailor_view = false
	self:updateList(true)
end


function clsAppointSailorUI:onExit()

	UnLoadPlist(self.plistTab)
end

return clsAppointSailorUI


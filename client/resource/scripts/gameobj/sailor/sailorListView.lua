--
-- Author: Ltian
-- Date: 2015-11-20 14:46:52
--
--航海士列表



local missionGuide = require("gameobj/mission/missionGuide")
local ClsSailorListItem = require("gameobj/sailor/sailorListItem")
local ui_word = require("game_config/ui_word")
local fire_reward = require("game_config/sailor/fire_reward")
local ClsAlert = require("ui/tools/alert")
local sailor_exp_info = require("game_config/sailor/sailor_exp_info")
local on_off_info=require("game_config/on_off_info")
local music_info=require("game_config/music_info")
local voice_info = getLangVoiceInfo()
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")


local ClsSailorListView = class("ClsSailorListView", ClsBaseView)
--local TOUCH_PRIORITY = 500

---航海士任命状态
local SAILOR_PORT_INVEST_STATAS = 5
local SAILOR_GUILD_APPOINT_STATUS = 4
local SAILOR_BOAT_APPOINT_STATUS = 2


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

local widget_name = {
	"btn_close",
	"btn_fire",
	"btn_fire_text",
	"btn_cancel",
	"btn_right_arrow",
	"btn_left_arrow",
	"choise_sailor",
    "star_bg", ---星章
    "star_num", --星章数量
    "star_pic",
    "no_sailor_txt",
    "tips_bg",
    "xingzhang_tips_bg",
}

local fire_sailor_name = {
	"bg",
	"medal_num",
	"book_num",
	"confirm_btn",
	"close_btn",
} 

function ClsSailorListView:getViewConfig()
    return {
        is_swallow = false,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        --effect = UI_EFFECT.FADE,    --(选填) ui出现时的播放特效
    }
end

function ClsSailorListView:onEnter(closeCallBack,equip_id,partner_data)
	if equip_id then
		self.equip_id = equip_id
	end
	if partner_data then
		self.partner_data = partner_data
	end


	self.closeCallBack = closeCallBack
	self._up_star_item_id = 50
	self.filter_tab = {  --航海士过滤表
		false,
		false,
		false,
	}
	self.plist = {
        ["ui/skill_icon.plist"] = 1,
        ["ui/hotel_ui.plist"] = 1,
    }

    self.guide_tbl = {
    	[4] = {key = on_off_info.SEAMAN_CHOICE.value,},
    	[7] = {key = on_off_info.ADVANCER_SELECT.value},
	}
    
    LoadPlist(self.plist)
    self.select_tips_name = 1  ---默认选中筛选标签的第一个
    self.is_fire = false
    self.fire_btn_status = true

    self.is_men_voice = true ---航海士音效控制
	self.is_women_voice = true
    self.fire_list = {}
	self.cells = {}


	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_sailor_list.json")
	self:addWidget(self.panel)

	self:mkUi()
end


function ClsSailorListView:setFireList(id)
	if self.fire_list[id] then
		self.fire_list[id] = false
	else
		self.fire_list[id] = true
	end
	local falg = false
	for k,v in pairs(self.fire_list) do
		if  v then
			falg = true
		end
	end
	if falg then
		self.btn_fire:active()
	else
		self.btn_fire:disable()
	end
	
end

function ClsSailorListView:getFireList()
	return self.fire_list
end

function ClsSailorListView:updateTab()
	for k,v in pairs(self.filter_tab) do
		self[widget_btn[k]]:setFocused(v)
		self[text_name[k]]:setVisible(v)
		self[text_name[k]]:setColor(ccc3(dexToColor3B(COLOR_WHITE_STROKE)))
	end

	self:updateList()
end

-----更新选择标记
function ClsSailorListView:updateSailorSelect(select_pic, sailor)
	local sound
	if 	sailor.sex == SEX_M then
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
	self.selecte_sailor = sailor
end

---航海士状态
function ClsSailorListView:priorityByWork(a, b)
	return a.status == b.status, a.status < b.status
end


--稀有度优先级
function ClsSailorListView:priorityByStar( a, b )
	return a.star == b.star, a.star > b.star
end

--等级优先级
function ClsSailorListView:priorityByLevel( a, b )
	return a.level == b.level, a.level > b.level
end

--星级优先级
function ClsSailorListView:priorityBystarLevel( a, b )
	return a.starLevel == b.starLevel, a.starLevel > b.starLevel
end

---获取职业的优先级
function ClsSailorListView:getSailorPriority(sailor)
    if  sailor.job[1] == 1 then return 6 end ----瞭望手
    if  sailor.job[1] == 2 then return 1 end ----大幅
    if  sailor.job[1] == 3 then return 2 end ----火炮手
    if  sailor.job[1] == 4 then return 3 end ----水手
    if  sailor.job[1] == 5 then return 5 end ----操控师
	if  sailor.job[1] == 6 then return 7 end ----木工
    if  sailor.job[1] == 7 then return 4 end ----会计
    return 0	
end
--职业排序
function ClsSailorListView:priorityByJob( a, b )
	local ajob = self:getSailorPriority(a)
	local bjob = self:getSailorPriority(b) 
	return ajob == bjob, ajob < bjob
end

---id排序
function ClsSailorListView:priorityById( a, b )
	return a.id == b.id, a.id < b.id
end

--稀有度优先级
function ClsSailorListView:sequenceListByStar(sailors)
	local temp = {}
	for k, v in pairs(sailors) do
		temp[#temp + 1] = v
	end
	table.sort(temp, function(a, b)
		local flag, result = self:priorityByWork(a, b)    --在职
		if flag ~= true then return result end		
		local flag, result = self:priorityByStar(a, b)    --星阶
		if flag ~= true then return result end  
		local flag, result = self:priorityBystarLevel(a, b)    --星级  
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

function ClsSailorListView:mkUi()

	for k,v in pairs(text_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	for k,v in pairs(btn_pic) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	for k,v in pairs(widget_btn) do
		self[v] = getConvertChildByName(self.panel, v)
		self[v]:addEventListener(function()
			self[v]:setScale(1.2)
		end,TOUCH_EVENT_BEGAN)
		self[v]:addEventListener(function()
			self[v]:setScale(1.0)
			self:updateTab()
		end,TOUCH_EVENT_CANCELED)		
		self[v]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)			
			self:regBtnCB(k)
		end, TOUCH_EVENT_ENDED)
	end
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	
	self.star_pic:setVisible(true)
    self.star_bg:setVisible(true)
	self.star_num:setVisible(true)
	self.tips_bg:setVisible(true)

	self:updateStarNum()
	self:resetBtn()   
	self:regCB()
	self:updateTab()	
end

function ClsSailorListView:updateStarNum()
	local propDataHandle = getGameData():getPropDataHandler()
	local item_info = propDataHandle:hasPropItem(self._up_star_item_id)
	local has_item_num = 0
    if item_info then
        has_item_num = item_info.count or 0
    end
	self.star_num:setText(has_item_num)
end

function ClsSailorListView:regBtnCB(index)
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

function ClsSailorListView:updateList(fire, is_old_set)
	if fire then
		self.is_fire = fire
	end
	--if not self.is_fire then
		self.fire_list = {}
	--end

	if self.list_view and not tolua.isnull(self.list_view) then
		self.old_index = self.list_view:getTopCellIndex()
		self.list_view:removeAllCells()
		self.cells = {}
	else

	    local score_view = ClsScrollView.new(730, 380, false, nil, {is_fit_bottom = true})
	    score_view:setPosition(ccp(200, 120))
	    self:addWidget(score_view)
	    self.list_view = score_view		
	end

	local sailorData = getGameData():getSailorData()
	local sailor_re ,otherSailor_re = sailorData:filterSailors(self.filter_tab)----过滤过的不同职业的航海士	
	
	local sailor = {}
	local otherSailor = {}
	local appiont_sailor_re = {}
	local no_appiont_sailor_re = {}
	local appiont_otherSailor_re = {}
	local no_appiont_otherSailor_re = {}

	local sailor_task_id = sailorData:getSailorTaskID()	  ---传记任务的航海士id
	---解雇的时候任命状态的航海士不显示
	if self.is_fire then
		---将任命中的航海士删除 
		for k,v in pairs(sailor_re) do
			if v.status == 0 and v.id ~= sailor_task_id then
				sailor[#sailor + 1] = v
			end
		end

		for k,v in pairs(otherSailor_re) do
			if v.status == 0 and v.id ~= sailor_task_id then
				otherSailor[#otherSailor + 1] = v
			end
		end

		sailor = self:sequenceListByStar(sailor)
		otherSailor = self:sequenceListByStar(otherSailor)

		if #sailor >= 0 and self:isSelectSailorJob() then
			self.no_sailor_txt:setVisible(#sailor == 0)
		else
			for k,v in pairs(otherSailor) do
				sailor[#sailor + 1] = v
			end		
		end
	else
		sailor = self:sequenceListByStar(sailor_re)  
		otherSailor = self:sequenceListByStar(otherSailor_re) 

		if not self:isSelectSailorJob() then
			for k,v in pairs(otherSailor) do
				sailor[#sailor + 1] = v
			end	
		end
	end

	self.no_sailor_txt:setVisible(#sailor == 0) 
	self.no_sailor_txt:setText(ui_word.SAILOR_BACKGROUND_EXPLAIN_NOTGET)

	self.sailor_list = sailor 
	local sailor_count = #sailor 
	local _listcellTab = {}
	local cell_size = CCSize(165, 350)
	local raw = 2		--一列放2个cell
	local toalCol = math.ceil(sailor_count/raw) --cell的总数

	for i=1,toalCol do
		local tab = {}
		for j=1,2 do
			local index = (i - 1) * raw + j
			if sailor[index] then
				table.insert(tab, sailor[index])
				if self.guide_tbl[sailor[index].id] then
					missionGuide:pushGuideBtn(self.guide_tbl[sailor[index].id].key, {guideLayer=self,rect = CCRect(215+(i-1)*168, 315-(j-1)*185, 133, 168)})
				end	
			end
		end

		self.cells[i] = ClsSailorListItem.new(cell_size, {key = tab, is_fire = self.is_fire, sailor_id = self.selecte_partner_id})

	end
	self.list_view:addCells(self.cells)


	self.btn_left_arrow:setVisible(sailor_count ~= 0)
	self.btn_right_arrow:setVisible(sailor_count ~= 0)

	self.btn_left_arrow:addEventListener(function ()		
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local index = self.list_view:getTopCellIndex()

		local set_index = index - 4
		if set_index <= 0 then 
			set_index = 1
		end 
		self.list_view:scrollToCellIndex(set_index)
	end, TOUCH_EVENT_ENDED)
	
	self.btn_right_arrow:addEventListener(function ()		
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local index = self.list_view:getTopCellIndex()

		self.list_view:scrollToCellIndex(index + 4)
	end, TOUCH_EVENT_ENDED)

	if not self.is_fire then
		self.btn_fire_text:setText(ui_word.SURE_FIRE)
		self.btn_fire:active()
		self.choise_sailor:setText(ui_word.SELECT_YOU_SAILOR)
		local onOffData = getGameData():getOnOffData()
    	onOffData:pushOpenBtn(on_off_info.SAILOR_FIRE.value, {openBtn = self.btn_fire, openEnable = true, addLock = true, 
    		btn_scale = 0.7, btnRes = "#common_btn_blue1.png", parent = "ClsSailorListView"})
	end

	if is_old_set then
		self.list_view:scrollToCellIndex(self.old_index)
	else
		self.list_view:scrollToCellIndex(1)
	end
	
	if sailor_count < 1 then return end
	self:addWidget(self.list_view)
end

---判断是否筛选职业
function ClsSailorListView:isSelectSailorJob()
	for k,v in pairs(self.filter_tab) do
		if v then
			return true	
		end
	end
	return false
end


function ClsSailorListView:getSailorList()
	return self.sailor_list
end

function ClsSailorListView:selecteAppiontSailor(sailor_list)
	local appiont_sailor = {}
	local no_appiont_sailor = {}
	for k,v in pairs(sailor_list) do
		if v.status == 0 then
			no_appiont_sailor[#no_appiont_sailor + 1] = v
		else
			appiont_sailor[#appiont_sailor + 1] = v
		end
	end
	return no_appiont_sailor,appiont_sailor	
end

function ClsSailorListView:regCB()

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		local sailorData = getGameData():getSailorData()
    	local sailor_list = sailorData:getOwnSailors()
		for k,v in pairs(sailor_list) do
			if v.info == 1 then 
				v.info = 0
			end
		end

		self:close()
		if type(self.closeCallBack) == "function" then
        	self.closeCallBack()
        end
		end, TOUCH_EVENT_ENDED)

	self.btn_fire:setPressedActionEnabled(true)
	self.btn_fire:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if self.fire_btn_status then
			self.fire_btn_pos = self.btn_fire:getPosition()
			self.btn_fire:setPosition(ccp(self.fire_btn_pos.x - 100, self.fire_btn_pos.y))
			self.btn_cancel:setVisible(true)
			self.btn_cancel:setTouchEnabled(true)
			self:updateList(true)
			self.btn_fire_text:setText(ui_word.MAIN_OK_FIRE_SAILOR)
			self.fire_btn_status = false
			self.btn_fire:disable(false)
			self.tips_bg:setVisible(false)
			self.choise_sailor:setText(ui_word.SELECT_YOU_FIRE_SAILOR)
		else
			self:fireSailor()			
		end	

	end, TOUCH_EVENT_ENDED)

	missionGuide:pushGuideBtn(on_off_info.SAILOR_FIRE.value,
	 {rect = CCRect(240, 10, 100, 40), guideLayer = self})

	self.btn_cancel:setPressedActionEnabled(true)
	self.btn_cancel:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.fire_btn_status = true
		self.is_fire = false
		self:resetBtn()
		self:updateList(false)
	end, TOUCH_EVENT_ENDED)

	self.star_bg:setTouchEnabled(true)
	self.star_bg:addEventListener(function (  )

		self.xingzhang_tips_bg:setVisible(not self.xingzhang_tips_bg:isVisible())

	end,TOUCH_EVENT_ENDED)

end

function ClsSailorListView:resetBtn()
	self.fire_btn_pos = self.btn_fire:getPosition()
	self.btn_fire:setPosition(ccp(self.fire_btn_pos.x + 100, self.fire_btn_pos.y))
	self.btn_cancel:setVisible(false)
	self.btn_cancel:setTouchEnabled(false)
	self.tips_bg:setVisible(true)
end


function ClsSailorListView:sailorListTouch(enable)
	self.list_view:setTouchEnabled(enable)
	self.btn_left_arrow:setTouchEnabled(enable)
	self.btn_right_arrow:setTouchEnabled(enable)
end

function ClsSailorListView:fireSailor()

	local fire_sailors = {}
	for k,v in pairs(self.fire_list) do
		if v then
			table.insert(fire_sailors, k)
		end
	end

	if #fire_sailors < 1 then
		ClsAlert:warning({msg = ui_word.SELECT_YOU_FIRE_SAILOR, size = 26})
		return 		
	end

	local function ok_call_back_func()
		GameUtil.callRpc("rpc_server_sailor_fire", {fire_sailors}, "rpc_client_sailor_fire")			
	end
	ClsAlert:showAttention(ui_word.FIRE_SAILOR_GET_REWARD, ok_call_back_func, close_call_back_func, nil, {hide_cancel_btn = true})
end

----解雇协议回调刷新sailorlist
function ClsSailorListView:updateSailorList()
	self:updateList(true)
end


function ClsSailorListView:onExit()
	UnLoadPlist(self.plist)
end

function ClsSailorListView:openShowAttention(ok_func,close_func)
	if not self.is_open_show_attention then
		local function ok_call_back_func()
			self.is_open_show_attention = false
			ok_func()
		end 

		local function close_call_back_func()
			self.is_open_show_attention = false
			close_func()
		end 		
		ClsAlert:showAttention(ui_word.SELECT_FIRE_TIP, ok_call_back_func, close_call_back_func, nil, {hide_cancel_btn = true})
		self.is_open_show_attention = true	
	end
end

function ClsSailorListView:getShowAttention()
	return self.is_open_show_attention
end

function ClsSailorListView:openSailorView(sailor)
	if not self.is_open_sailor_view then
		self.is_open_sailor_view = true		
		if not getUIManager():isLive("ClsPartnerInfoView") then
			getUIManager():create("gameobj/partner/clsPartnerInfoView", {}, sailor)
		end
		self.selecte_partner_id = sailor.id 

	end	
end

function ClsSailorListView:getFireBtn()
	return self.btn_fire
end

function ClsSailorListView:closeSailorViewCB()
	self.is_open_sailor_view = false
	self:updateList(nil, true)
end

return ClsSailorListView
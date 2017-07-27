-- 航海士觉醒列表
-- Author: Ltian
-- Date: 2017-02-02 15:56:45
--

local missionGuide = require("gameobj/mission/missionGuide")
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local on_off_info=require("game_config/on_off_info")
local music_info=require("game_config/music_info")
local voice_info = getLangVoiceInfo()
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")

--
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local music_info=require("game_config/music_info")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")
local CompositeEffect = require("gameobj/composite_effect")
local sailor_info = require("game_config/sailor/sailor_info")

local ClsSailorHeard = class("ClsSailorHeard", function() return UIWidget:create() end)

local widget_heard = {
	"level_icon",
	"sailor_name",
	"star_1",
	"star_2",
	"star_3",
	"star_4",
	"star_5",
	"star_6",
	"star_7",
	"select_pic",
	"sailor_icon",
	"sailor_type_icon",
	"selected_pic",
	"btn_story",
	"star_panel",
	"list_sailor_bg",
	"lvl_num",
}


function ClsSailorHeard:ctor(sailor, isFire, selecte_partner_id)
	self.sailor = sailor
	
	self:mkUi()
end
function ClsSailorHeard:mkUi()

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_sailor_card.json")
	convertUIType(self.panel)
	for k,v in pairs(widget_heard) do
		self[v] =  getConvertChildByName(self.panel, v)
	end
	self:addChild(self.panel)
	self:updateView()
end


--更新视图
function ClsSailorHeard:updateView()
	self.sailor_icon:changeTexture(self.sailor.res, UI_TEX_TYPE_LOCAL)
	self.sailor_name:setText(self.sailor.name)

	self.level_icon:changeTexture(STAR_SPRITE_RES[self.sailor.star].big, UI_TEX_TYPE_PLIST)
	local is_scale = sailor_info[self.sailor.id].big_or_small
	if is_scale == 1 then
		self.sailor_icon:setScale(0.45)
	end
	self.sailor_type_icon:changeTexture(JOB_RES[self.sailor.job[1]], UI_TEX_TYPE_PLIST)
	local star = self.sailor.starLevel

	if  star%2 == 0 then
		local size = self.star_panel:getPosition()
		self.star_panel:setPosition(ccp(size.x+8, size.y))
	end

    for i=1,7 do
    	if i > star then
        	self["star_"..i]:setVisible(false)
    	end
    end    

    if self.sailor.status ~= 0 then
    	local camp_task_status = 4
    	local cityhall_task_status = 5
    	if self.sailor.status == camp_task_status then
    		self.select_pic:changeTexture("ui/txt/txt_stamp_guild.png", UI_TEX_TYPE_LOCAL)
		elseif self.sailor.status == cityhall_task_status then
    		self.select_pic:changeTexture("ui/txt/txt_stamp_cityhall.png", UI_TEX_TYPE_LOCAL)		
    	end
    	self.select_pic:setVisible(true)----显示已经加入编队的标示
    else
    	self.select_pic:setVisible(false)
    end

    

    local sailor_mission = info_sailor_mission[self.sailor.id]
    local sailor_mission_count = 0
    local is_task_all = false
    if sailor_mission then
    	sailor_mission_count = #sailor_mission
    	local memoir_chapter = self.sailor.memoirChapter
		local memoir_status = self.sailor.memoirStatus
		if memoir_chapter == sailor_mission_count and memoir_status ==2 then
			is_task_all = true
		end
    end



    -----航海士传记图标

	if info_sailor_mission[self.sailor.id] and not is_task_all then
		
	else
		self.btn_story:setVisible(false)
		if self.effect and not tolua.isnull(self.effect) then
			self.effect:removeFromParentAndCleanup(true)
		end
	end

	self.lvl_num:setVisible(true)
	self.lvl_num:setText("Lv."..self.sailor.level)

	
	

end


function ClsSailorHeard:touchCB()
	getUIManager():create("gameobj/sailor/clsSailorAwakeView", nil, self.sailor)
end


-----------------------------listview cell 包含多个sailorheard-------------------------------------------
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsSailorListItem = class("ClsSailorListItem", ClsScrollViewItem)

local roe_num = 2
function ClsSailorListItem:initUI(cell_data)
	
	self.data = cell_data.key
	self.items = {}
	local index = 0
	local offset_Y = 185

	for i=1,roe_num do
		if not self.data[i] then return end
		local item = ClsSailorHeard.new(self.data[i])
		
		self.items[i] = item
		item:setPosition(ccp(10, 190 - offset_Y * index))
		item.rect = CCRect(15 , 190- offset_Y * index, 120, 150)
		index = index + 1
		self:addChild(item)		
	end
	
end

function ClsSailorListItem:onTap(x,y)
	local pos = self:getWorldPosition()
	local node_pos = ccp(x - pos.x, y - pos.y)

	for k,v in pairs(self.items) do
		rect = v.rect
		if rect and rect:containsPoint(node_pos) then
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local array = CCArray:create()
			local scale = CCScaleTo:create(0.1, 0.8)
			array:addObject(scale)
			local scale_re = CCScaleTo:create(0.1, 1.0)
			array:addObject(scale_re)
			array:addObject(CCCallFunc:create(function ()
				v:touchCB()	
			end))			
			v.list_sailor_bg:runAction(CCSequence:create(array))		
		end
	end
	
end

-----------------------------------------------------------------------------
local ClsSailorAwakeList = class("ClsSailorAwakeList", ClsBaseView)
--local TOUCH_PRIORITY = 500

---航海士任命状态
local SAILOR_PORT_INVEST_STATAS = 5
local SAILOR_GUILD_APPOINT_STATUS = 4
local SAILOR_BOAT_APPOINT_STATUS = 2





local widget_name1 = {
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
    "btn_panel",
    "choise_sailor",
    "no_s_sailor_txt",
    "xingzhang_tips_bg",
}

local fire_sailor_name = {
	"bg",
	"medal_num",
	"book_num",
	"confirm_btn",
	"close_btn",
} 

function ClsSailorAwakeList:getViewConfig()
    return {
        is_swallow = false,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        --effect = UI_EFFECT.FATE,    --(选填) ui出现时的播放特效
    }
end

function ClsSailorAwakeList:onEnter(closeCallBack)
	self._up_star_item_id = 50
	self.closeCallBack = closeCallBack
    self.is_men_voice = true ---航海士音效控制
	self.is_women_voice = true
	self.cells = {}


	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_sailor_list.json")
	self:addWidget(self.panel)

	self:mkUi()
end

-----更新选择标记
function ClsSailorAwakeList:updateSailorSelect(select_pic, sailor)
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


function ClsSailorAwakeList:mkUi()

	for k,v in pairs(widget_name1) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self.choise_sailor:setText(ui_word.AWAKE_SELECT_TIPS)
	self.star_bg:setTouchEnabled(true)
	self.star_bg:addEventListener(function (  )

		self.xingzhang_tips_bg:setVisible(not self.xingzhang_tips_bg:isVisible())

	end,TOUCH_EVENT_ENDED)
	--self.btn_panel:setVisible(false)
	
	getConvertChildByName(self.panel, "btn_navy"):setVisible(false)
	getConvertChildByName(self.panel, "btn_cancel"):setVisible(false)
	getConvertChildByName(self.panel, "btn_adventure"):setVisible(false)
	getConvertChildByName(self.panel, "btn_fire"):setVisible(false)
	getConvertChildByName(self.panel, "btn_pirate"):setVisible(false)
	
	self:updateStarNum() 
	self:updateList()
	self:regCB()	
end

function ClsSailorAwakeList:updateStarNum()
	local propDataHandle = getGameData():getPropDataHandler()
	local item_info = propDataHandle:hasPropItem(self._up_star_item_id)
	local has_item_num = 0
    if item_info then
        has_item_num = item_info.count or 0
    end
	self.star_num:setText(has_item_num)
end


function ClsSailorAwakeList:updateList()
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
	local sailor = sailorData:getCanAwakeSailor() 
	local sailor_count = #sailor 
	local _listcellTab = {}
	local cell_size = CCSize(165, 350)
	local raw = 2		--一列放2个cell
	local toalCol = math.ceil(sailor_count/raw) --cell的总数
	if sailor_count == 0 then
		self.no_s_sailor_txt:setVisible(true)
	end

	for i=1,toalCol do
		local tab = {}
		for j=1,2 do
			local index = (i - 1) * raw + j
			if sailor[index] then
				table.insert(tab, sailor[index])
				
			end
		end

		self.cells[i] = ClsSailorListItem.new(cell_size, {key = tab})

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

		local index = self.list_view:getTopCellIndex() or 0

		self.list_view:scrollToCellIndex(index + 4)
	end, TOUCH_EVENT_ENDED)

	
	
	self.list_view:scrollToCellIndex(1)
	
	if sailor_count < 1 then return end
	self:addWidget(self.list_view)
end



function ClsSailorAwakeList:regCB()

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

end


function ClsSailorAwakeList:onExit()
end


return ClsSailorAwakeList
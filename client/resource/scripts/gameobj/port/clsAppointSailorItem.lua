--
-- Author: lzg0496
-- Date: 2016-07-11 11:50:40
-- Function: 市政厅任务水手item

local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local info_sailor_mission = require("scripts/game_config/sailor/info_sailor_mission")
local CompositeEffect = require("gameobj/composite_effect")
local sailor_info = require("game_config/sailor/sailor_info")

local ClsSailorHeard = class("ClsSailorHeard", function() return UIWidget:create() end)

local STORY_MISSION_FILTER_SAILOR = 4
local widget_heard = {
	"level_icon",
	"sailor_name",
	"star_1",
	"star_2",
	"star_3",
	"star_4",
	"star_5",
	"select_pic",
	"sailor_icon",
	"level",
	"new_bg",
	"sailor_type_icon",
	"new_text",   ---new标记
	"selected_pic",
	"btn_story",
	"star_panel",
	"list_sailor_bg",
	"lvl_num",
	"sailor_car_panel",
	"invest_text",
}


function ClsSailorHeard:ctor(sailor, isfire, view_pos, selecte_partner_id)
	self.sailor = sailor
	--self.rect = rect
	self.view_pos = view_pos
	self.selecte_partner_id = selecte_partner_id
	self:mkUi()
end
function ClsSailorHeard:mkUi()

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_appoint_list.json")
	convertUIType(self.panel)
	for k,v in pairs(widget_heard) do
		self[v] =  getConvertChildByName(self.panel, v)
	end
	self:addChild(self.panel)
	self:updateView()
end

-- --判断触摸点是否在按钮内
-- function ClsSailorHeard:containsPoint(obj, rect)
-- 	obj = tolua.cast(obj, "UIWidget")
--     local point = obj:getTouchEndPos()
--     if not rect:containsPoint(ccp(point.x, point.y)) then
--   		return false
--     else
--      	return true
--     end
-- end

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
	

    for i=1,5 do
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

    ----选中特效
	local effect_tx = "tx_0156"
	if not self.effect_skill then
		self.effect_skill = CompositeEffect.new(effect_tx, 70, 110, self.sailor_car_panel, nil, nil, nil, nil, true)
		self.effect_skill:setVisible(false)
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
	local sailor_view = getUIManager():get("clsAppointSailorUI")
	local sailor_list = sailor_view:getSailorList()
	if sailor_list[1].id == self.sailor.id or self.selecte_partner_id == self.sailor.id then
		sailor_view:updateSailorSelect(self.effect_skill, self.sailor)
	end	

	local sailor_data = getGameData():getSailorData()
	local exp_step = sailor_data:getSailorExpStep(self.sailor.id)
	local str = string.format(ui_word.INVEST_SAILOR_EXP_STEP_2, exp_step)
	self.invest_text:setText(str)
	if self.view_pos then
		self.invest_text:setVisible(false)
	end
end

function ClsSailorHeard:touchCB()
	local sailor_list_view = getUIManager():get("clsAppointSailorUI")
	if self.effect_skill:isVisible() then
		sailor_list_view:openSailorView(self.sailor)
		if self.sailor.info == 1 then
           self.sailor.info = 0
		end	
	end	
	sailor_list_view:updateSailorSelect(self.effect_skill, self.sailor)
end

-----------------------------listview cell 包含多个sailorheard-------------------------------------------

local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local clsAppointSailorItem = class("clsAppointSailorItem", ClsScrollViewItem)

local roe_num = 2
function clsAppointSailorItem:initUI(cell_data)
	self.isfire = cell_data.is_fire
	self.selecte_partner_id = cell_data.sailor_id
	self.view_pos = cell_data.view_pos
	self.data = cell_data.key
	self.items = {}
	local index = 0
	local offset_Y = 190

	for i=1,roe_num do
		if not self.data[i] then return end
		local item = ClsSailorHeard.new(self.data[i], self.isfire, self.view_pos, self.selecte_partner_id)
		
		self.items[i] = item
		item:setPosition(ccp(10, 190 - offset_Y * index))
		item.rect = CCRect(15 , 190- offset_Y * index, 120, 150)
		index = index + 1
		self:addChild(item)		
	end
	
end

function clsAppointSailorItem:onTap(x,y)
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

return clsAppointSailorItem

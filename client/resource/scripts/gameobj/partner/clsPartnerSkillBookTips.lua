
--fmy0570
--水手技能tips


local Alert = require("ui/tools/alert")
local on_off_info = require("game_config/on_off_info")
local ui_word = require("game_config/ui_word")
local item_info = require("game_config/propItem/item_info")
local music_info = require("game_config/music_info")
local skill_info = require("game_config/skill/skill_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
-----------------------------------技能书cell-----------------------------
local ClsPartnerSkillBookCell = class("ClsPartnerSkillBookCell", ClsScrollViewItem)

local cell_name = {
	"book_icon",
	"book_num",
	"book_name",
	"book_icon_bg",
}

local sailor_star = 1

function ClsPartnerSkillBookCell:initUI(data)
	self.skill_book_id = data

	local skill_book_list = {[165] = 1, [166] = 2, [167] = 3, [168] = 4, [169] = 5}
	self.skill_book_num = {}
    local propDataHandle = getGameData():getPropDataHandler()
    local item = propDataHandle:hasPropItem(self.skill_book_id)
    if item then
		self.skill_book_num[self.skill_book_id] = item.count
	else
		self.skill_book_num[self.skill_book_id] = 0
    end


	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_skill_book_list.json")
	self:addChild(self.panel)

	for k,v in ipairs(cell_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end	
	self.book_name:setText(item_info[self.skill_book_id].name)
	self.book_num:setText(self.skill_book_num[self.skill_book_id])
	self.book_icon:changeTexture(convertResources(item_info[self.skill_book_id].res), UI_TEX_TYPE_PLIST)

	local skill_step = item_info[self.skill_book_id].quality
	local skill_box_res = string.format("item_box_%s.png", skill_step)
	self.book_icon_bg:changeTexture(convertResources(skill_box_res), UI_TEX_TYPE_PLIST)	

	self.book_icon:setGray(sailor_star < (skill_step + 1))
	self.book_icon_bg:setGray(sailor_star < (skill_step + 1))

	if self.skill_book_num[self.skill_book_id] == 0 then
		setUILabelColor(self.book_num, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	else
		setUILabelColor(self.book_num, ccc3(dexToColor3B(COLOR_WHITE_STROKE)))
	end

end

function ClsPartnerSkillBookCell:onTap()
    if self.tapFunc then
        self:tapFunc()
    end
end

function ClsPartnerSkillBookCell:setTapCallFunc(func)
    self.tapFunc = func
end


-----------------------------------技能书tips-----------------------------
local ClsPartnerSkillBookTips = class("ClsPartnerSkillBookTips", ClsBaseView)

local SKILL_TYPE_NUM = 5	---技能数目

local TYPE_ADD_SKILL = 1  --添加水手技能
local TYPE_EXCHAGE_SKILL = 2 --交换水手技能
local TYPE_UP_SKILL = 3 ----升级水手技能


function ClsPartnerSkillBookTips:onEnter(parent, sailor_id, pos, skill_pos, skill_add_type, skill_id)

	self.m_zhandouli  = getGameData():getPlayerData():getBattlePower()
	self.parent = parent
	self.pos = pos
	self.skill_pos = skill_pos
	self.skill_add_type = skill_add_type
	if skill_id then
		self.skill_id = skill_id
	end
	local sailor_data = getGameData():getSailorData()
	self.own_sailors = sailor_data:getOwnSailors()
	self.sailor = self.own_sailors[sailor_id]
	sailor_star = self.sailor.star
   	local skill_panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_skill_book.json")
	self:addWidget(skill_panel)
	self:setPosition(pos)

	self.skill_title = getConvertChildByName(skill_panel, "skill_title")

	self.size_width = 286
	self.size_height = 434
	self:regTouchEvent(self, function(event, x, y)
		return self:onTouch(event, x, y) end)
	self:initUI()	
end

function ClsPartnerSkillBookTips:getSkillBookIdList()
	self.skill_book = {165, 166, 167, 168, 169} 
	local use_skill_book = {}
	local no_use_skill_book = {}
	local star_in_book = self.sailor.star - 1

	if self.skill_add_type == TYPE_UP_SKILL then
		star_in_book = skill_info[self.skill_id].quality + 1
	end

	if self.skill_add_type == TYPE_UP_SKILL then
		for k,v in pairs(self.skill_book) do
			if star_in_book == k then
				use_skill_book[#use_skill_book + 1] = v 
			else
				no_use_skill_book[#no_use_skill_book + 1] = v 
			end 
		end	
	else	
		for k,v in pairs(self.skill_book) do
			if star_in_book >= k then
				use_skill_book[#use_skill_book + 1] = v 
			else
				no_use_skill_book[#no_use_skill_book + 1] = v 
			end 
		end
		table.sort(use_skill_book, function (a_book_id, b_book_id)
			return a_book_id > b_book_id
		end)				
	end


	if #no_use_skill_book > 0 and self.skill_add_type ~= TYPE_UP_SKILL then
		table.sort(no_use_skill_book, function (a_book_id, b_book_id)
			return a_book_id > b_book_id
		end)
		for k,v in pairs(no_use_skill_book) do
			use_skill_book[#use_skill_book + 1] = v 
		end		
	end	

	return use_skill_book
end

function ClsPartnerSkillBookTips:initUI()
	self.skill_book_type = {"D","C","B","A","S"}
	--self.skill_book = {165, 166, 167, 168, 169} 

	self.skill_book_list = self:getSkillBookIdList()

	self.cells = {}

	if self.list_view and not tolua.isnull(self.list_view) then
		self.list_view:removeAllCells()
		self.list_view = nil
	end

	local cell_size	= CCSize(250, 104)

	self.list_view = ClsScrollView.new(250, 280, true, nil, {is_fit_bottom = true})
	self.list_view:setPosition(ccp(30, 10)) 
	self:addWidget(self.list_view)

	for k,v in pairs(self.skill_book_list) do
		local curCell = ClsPartnerSkillBookCell.new(cell_size, v)
		self.list_view:addCell(curCell)  		
        curCell:setTapCallFunc(function()
            self:onCellTap(v,k)
        end)

        self.cells[#self.cells+1] = curCell 
	end

	local str = ui_word.ADD_SAILOR_SKILL_LBL
	if self.skill_add_type ==  TYPE_UP_SKILL then
		str = ui_word.UP_SAILOR_SKILL_LBL
	elseif self.skill_add_type == TYPE_EXCHAGE_SKILL then
		str = ui_word.EXCHAGE_SAILOR_SKILL_LBL
	end

	self.skill_title:setText(str)
end

function ClsPartnerSkillBookTips:onCellTap(skill_book_id, book_type)

	local propDataHandle = getGameData():getPropDataHandler()
	local item = propDataHandle:hasPropItem(skill_book_id)
	local skill_book_num = 0
	if item then
		skill_book_num = item.count
	end

	if skill_book_num == 0 then
		self.parent:clearTips()
		Alert:showJumpWindow(SKILL_BOOK_NOT_ENOUGH, self.parent)
		return 
	end

	if (self.sailor.star - 1) < book_type then
		Alert:warning({msg = ui_word.SAILOR_SKILL_BOOK_STEP, size = 26})
		return 
	end

	if self.skill_add_type == TYPE_EXCHAGE_SKILL then

		local skill_step = skill_info[self.skill_id].quality + 1
		local skill_name = skill_info[self.skill_id].name 
		local skill_type = self.skill_book_type[skill_step]
		local str =  string.format(ui_word.EXCHAGE_SKILL_STR, skill_type, skill_name)
		Alert:showAttention(str,function ()
			local partner_data = getGameData():getPartnerData()
			partner_data:askAddSkill(self.sailor.id, self.skill_book_list[book_type], self.skill_pos, self.skill_add_type)
		end)
		return
	end

	local partner_data = getGameData():getPartnerData()
	partner_data:askAddSkill(self.sailor.id, self.skill_book_list[book_type], self.skill_pos, self.skill_add_type)
end

function ClsPartnerSkillBookTips:onExit()  
	local curZhandouli  = getGameData():getPlayerData():getBattlePower()
	if self.skill_add_type == TYPE_UP_SKILL and (curZhandouli > self.m_zhandouli)then
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsBattlePower = require("gameobj/quene/clsBattlePower")
		DialogQuene:insertTaskToQuene(clsBattlePower.new({newPower = curZhandouli,oldPower = self.m_zhandouli}))
	end
end

function ClsPartnerSkillBookTips:onTouch(event, x, y)
	if event == "began" then
		self:onTouchBegan(x, y)
	end
end

function ClsPartnerSkillBookTips:onTouchBegan(x , y)

	if x > self.pos.x and x < self.pos.x + self.size_width and y > self.pos.y and y < self.pos.y + self.size_height then	
		return true

	else
		self:close()
		self.parent:clearTips()
		return false
	end
end

return ClsPartnerSkillBookTips
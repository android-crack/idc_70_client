--收藏室水手收集界面
local music_info = require("game_config/music_info")
local sailor_info = require("game_config/sailor/sailor_info")
local sailor_job = require("game_config/sailor/sailor_job")
local skill_info = require("game_config/skill/skill_info")
local skill_site = require("game_config/skill/skill_site")
local info_sailor_mission =  require("game_config/sailor/info_sailor_mission")
local ui_word = require("game_config/ui_word")
local PageTurn = require("ui.tools.PageTurn")
local DataTools = require("module/dataHandle/dataTools")
local ListView = require("ui/tools/ListView")
local ListCell = require("ui/tools/ListCell")

local ClsCollectSailorUI = class("ClsCollectSailorUI", require('ui/view/clsBaseView'))

ClsCollectSailorUI.getViewConfig = function(self)
	return { 
		hide_before_view = true,
		effect = UI_EFFECT.FADE,
	}
end

---------------------------book begin ----------------------
---[[
local Book= class("Book", PageTurn)
Book.ctor = function(self, rect,pageCount)
	self.super.ctor(self, rect)
	self.page={ }
	self.menu = {}
	self.btn = {}
	self.story_back = {}
	self.btn_story_name = {}
	self.list_view = {}
	local sprite = display.newSprite("#collect_sailor_page_left.png")
	sprite:setPosition(ccp(display.cx, display.cy + 14))
	sprite:setAnchorPoint(ccp(1, 0.5))
	self:addChild(sprite)
	self.page[1] = sprite
	for i = 1,((pageCount-2)/2) do
		local sprite = display.newSprite("#collect_sailor_page_right.png")
		sprite:setPosition(ccp(display.cx, display.cy + 14))
		sprite:setAnchorPoint(ccp(0, 0.5))
		self:addCell(sprite)
		self.page[i*2] = sprite

		local sprite = display.newSprite("#collect_sailor_page_left.png")
		sprite:setPosition(ccp(display.cx, display.cy + 14))
		sprite:setAnchorPoint(ccp(1, 0.5))
		self:addCell(sprite)
		self.page[i*2+1] = sprite
	end
	local sprite = display.newSprite("#collect_sailor_page_right.png")
	sprite:setPosition(ccp(display.cx, display.cy + 14))
	sprite:setAnchorPoint(ccp(0, 0.5))
	self:addChild(sprite)
	self.page[pageCount] = sprite
	self.func = nil
end

Book.setPageEndCallFunc = function(self, func)
	self.func = func
end

Book._turnLeft = function(self)
	self.super.turnLeft(self, true)
end

Book._turnRight = function(self)
	self.super.turnRight(self, true)
end

Book.turnLeft = function(self)
	self.super.turnLeft(self)
	if self.func then self.func(self.currentIndex) end
end

Book.turnRight = function(self)
	self.super.turnRight(self)
	if self.func then self.func(self.currentIndex) end
end

Book.indexPage = function(self, pageNum)
	local count = #self.cells --最大
	if pageNum > count then pageNum = count+1	end
	if pageNum < 1 then pageNum = 1 end
	local dPage = pageNum - self.currentIndex
	local pageCount = 0      -- 已经翻的页数
	local turnNum = math.floor(math.abs(dPage)/2) --要翻的页数

	local doStep = function()  --连续翻页
		self.curRcell = self:getCurrentCell()
		self.curLcell = self:getCellForIndex(self:getCurrentIndex() - 1)

		if pageCount == turnNum then
			audioExt.playEffect(music_info.ROOM_BOOK.res)
			if self.hander_time then
				self.scheduler:unscheduleScriptEntry(self.hander_time)
				self.hander_time = nil
				if self.func then self.func(self.currentIndex) end
				return
			end
		else
			pageCount = pageCount + 1
		end
		if dPage < 0 then
			self:_turnRight()
		elseif dPage > 0 then
			self:_turnLeft()
		end
	end

	if turnNum > 0  then
		if self.hander_time == nil then
			self.hander_time = self.scheduler:scheduleScriptFunc(doStep, 0.01, false)
		end
	else
		if self.func then self.func(self.currentIndex) end
	end
end
-------------------------------

local widget_name = {
	"tab_normal", --普通按钮
	"tab_advanced",
	"tab_legend",
	"btn_close",
	"normal_text", --普通文本
	"normal_amount",
	"advanced_text",
	"advanced_amount",
	"legend_text",
	"legend_amount",
	"page_num_left", --左边页签
	"page_num_right", --右边页签
}


local TAB_NORMAL = 1
local TAB_SENIOR = 2
local TAB_LEGEND = 3

local TYPE_PREV_LAYER = 0
local TYPE_CUR_LAYER = 1
local TYPE_NEXT_LAYER = 2

ClsCollectSailorUI.onEnter = function(self, data)
	self.player_id = data.player_id
	self.from = data.from 
	self.sailor_id = data.sailor_id
	self.res_plist = {
		["ui/collect_sailor.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}
	LoadPlist(self.res_plist)

	self.normalSailors = {}
	self.seniorSailors = {}
	self.legendSailors = {}

	self:initData()
	self:initUI()
	self:initBtns()
	-- self.book:indexPage(10)
	if self.sailor_id then
		local index = self:getSailorPageByIndex(self.sailor_id)
		self.book:indexPage(index)
	end
end

ClsCollectSailorUI.clearTips = function(self)
	if not tolua.isnull(self.tips) then
		self.tips:removeFromParentAndCleanup(true)
		self.book:setTouchEnabled(true)
	end
end

ClsCollectSailorUI.getSailorPageByIndex = function(self, sailor_id)
	local normal_sailor_count = #self.normalSailors
	local senior_sailor_count = #self.seniorSailors
	local legend_sailor_count = #self.legendSailors
	local pos, index = 0, 0
	for i,v in ipairs(self.normalSailors) do
		if v == sailor_id then
			pos, index = 1, i
		end
	end

	for i,v in ipairs(self.seniorSailors) do
		if v == sailor_id then
			pos, index = 2, i
		end
	end
	for i,v in ipairs(self.legendSailors) do
		if v == sailor_id then
			pos, index = 3, i
		end
	end
	if pos == 1 then
		return index
	elseif pos == 2 then
		return normal_sailor_count + index
	else
		return normal_sailor_count + senior_sailor_count + index * 2 -1
	end
end

ClsCollectSailorUI.onExit = function(self)
	UnLoadPlist(self.res_plist)
	ReleaseTexture()
end

ClsCollectSailorUI.calSailorPage = function(self)
	local normalPages = #self.normalSailors--math.ceil(normalLen/2)
	local seniorPages = #self.seniorSailors--math.ceil(seniorLen/2)
	local legendPages = #self.legendSailors * 2
	local nullPages = math.ceil((normalPages + seniorPages)%2)

	local pageCount = normalPages + seniorPages + nullPages + legendPages
	local pages = { }
	pages.page ={ }
	pages.page.pageCount = pageCount
	pages.page.normalIndex = 1
	pages.page.seniorIndex = normalPages + 1
	pages.page.legendIndex = normalPages + seniorPages + nullPages + 1


	for i =  1, normalPages do
		pages[i] = {list ={ }, showType = "normal"}
		local sailor = self.normalSailors[i]	--[(i-1)*2+j]
		if sailor then
			table.insert(pages[i].list, sailor)
		end
	end
	for i =  normalPages + 1, normalPages + seniorPages do
		pages[i] = {list ={ },showType = "normal"}
		local sailor = self.seniorSailors[i-normalPages]--[(i-1- normalPages)*2+j]
		if sailor then
			table.insert(pages[i].list, sailor)
		end
	end
	for i = normalPages+seniorPages+nullPages+1, pageCount do
		pages[i] = {list ={ }}
		if i % 2 == 0 then
			pages[i].showType="legendExplain"
		else
			pages[i].showType="legendHead"
		end
		local c = i - normalPages - seniorPages -nullPages+1
		table.insert(pages[i].list,(self.legendSailors[math.floor(c/2)]))
	end

	return pages, pages.page.pageCount, pages.page.normalIndex, pages.page.seniorIndex, pages.page.legendIndex
end

ClsCollectSailorUI.initUI = function(self)
	-- self.ui_layer = UILayer:create()
	self.ui_layer = UIWidget:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_tab.json")
	convertUIType(self.panel)
	self.ui_layer:addChild(self.panel)
	self:addWidget(self.ui_layer)
	--self.ui_layer:setTouchEnabled(false)

	-- 绑定json
	for k, v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	-- 设置数量
	self:initAmountLabel()

	self.pageCount, self.normalIndex, self.seniorIndex, self.legendIndex = 2,1,1,1

	self.pageInfo, self.pageCount, self.normalIndex, self.seniorIndex, self.legendIndex = self:calSailorPage()

	local book = Book.new(CCRect(0, 20, display.width - 80, display.height - 20),  self.pageCount)
	book:setPosition(ccp(-20,0))
	self.panel:addCCNode(book)
	self.book = book

	--PageTurn的touch事件
	for i = 1, self.pageCount do
		self.book.page[i].onTap = function(this,x,y)
		end
	end

	-- @mid
	self:regTouchEvent(self.book, function(...) return book:onTouch(...) end)

	self.last_index = 0 --翻页前的index
	self.prev_layer = {} --前一页两个水手的layer
	self.cur_layer = {} --当前页两个水手的layer
	self.next_layer = {} --后一页两个水手的layer

	book:setPageEndCallFunc(function(index)
		self:showDetails(index)
	end)

end

ClsCollectSailorUI.initAmountLabel = function(self)
	local str_format = "(%s/%s)"
	local normal_count, advanced_count, legend_count = self:getCountOfType()
	self.normal_amount:setText(string.format(str_format, normal_count, #self.normalSailors))
	self.advanced_amount:setText(string.format(str_format, advanced_count, #self.seniorSailors))
	self.legend_amount:setText(string.format(str_format, legend_count, #self.legendSailors))
end

ClsCollectSailorUI.getCountOfType = function(self)
	local normal_count, advanced_count, legend_count = 0, 0, 0
	local sailor_config = require("game_config/sailor/sailor_info")
	for k, v in pairs(getGameData():getFriendDataHandler():getTempFriendSailor()) do
		local id = v.sailorId
		if sailor_config[id] and sailor_config[id].collect == 1 then
			if sailor_config[id].star <= 3 then -- 普通水手
				normal_count = normal_count + 1
			elseif sailor_config[id].star == 4 or sailor_config[id].star == 5  then --高级水手
				advanced_count = advanced_count + 1
			elseif sailor_config[id].star == 7 or sailor_config[id].star == 6  then --传奇水手
				legend_count = legend_count + 1
			end
		end
	end
	return normal_count, advanced_count, legend_count
end

--清除self.prev_layer数据
ClsCollectSailorUI.clearPrevLayer = function(self)
	for k, v in pairs(self.prev_layer) do
		if not tolua.isnull(v) then
			v:removeFromParentAndCleanup(true)
		end
	end
	self.prev_layer = {}
end

--清除self.cur_layer数据
ClsCollectSailorUI.clearCurLayer = function(self)
	for k, v in pairs(self.cur_layer) do
		if not tolua.isnull(v) then
			v:removeFromParentAndCleanup(true)
		end
	end
	self.cur_layer = {}
end

--清除self.next_layer数据
ClsCollectSailorUI.clearNextLayer = function(self)
	for k, v in pairs(self.next_layer) do
		if not tolua.isnull(v) then
			v:removeFromParentAndCleanup(true)
		end
	end
	self.next_layer = {}
end

ClsCollectSailorUI.createPageNum = function(self, panel, index)
	local page_num_panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_page_num.json")
	convertUIType(page_num_panel)

	-- local pos = self.page_num_left:getPosition()
	local pos = ccp(204, 54)
	if index % 2 == 0 then
		pos = ccp(220, 54)
	end

	page_num_panel:setPosition(pos)
	panel:addChild(page_num_panel)

	local num = getConvertChildByName(page_num_panel, "cur_page_num")
	num:setText(index .. "/" .. self.pageCount)
end


--[[
@api
	普通水手信息显示
]]
ClsCollectSailorUI.showNormal = function(self, sailor_id, index)
	local bookpage = self.book.page[index]

	local exist_sailor = getGameData():getCollectData():isFriendOwnSailor(sailor_id)

	-- 因为要加在一个Sprite上 所以没法改,还是保留ui_layer
	local container = UILayer:create()
	local normal_panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_normal.json")
	convertUIType(normal_panel)
	container:addWidget(normal_panel)

	local pos = ccp(-6, 0)
	if index % 2 == 0 then
		pos = ccp(-20, 0)
	end
	container:setPosition(pos)

	local widget_name = {

		"sailor_bg", --头像背景
		"sailor_rank", --星级
		"sailor_head", --头像
		"sailor_name", --航海士名字
		"personality_info", ---航海士个性 短描述
		"personality_long", -- 航海士个性 长描述
		"sailor_job_icon", -- 职业图标
		"sailor_job_text", -- 职业名称

		"btn_text", -- 介绍按钮
		"btn_story", --传记按钮

		-- "sailor_text_bg", -- 人物介绍面板
		-- "sailor_text", -- 人物介绍文本

		"skill_bg_1", -- 按钮
		"skill_icon_1", -- 图标
		"skill_active_1", -- 说明外框
		"skill_active_text_1", -- 说明文本
		"skill_selected_1", --选中框

		"skill_bg_2", -- 按钮
		"skill_icon_2", -- 图标
		"skill_active_2", -- 说明外框
		"skill_active_text_2", -- 说明文本
		"skill_selected_2", --选中框

		"skill_effect", -- 详细说明
		"skill_name", -- 名称
	}

	-- local container = {}
	for k, v in pairs(widget_name) do
		container[v] = getConvertChildByName(normal_panel, v)
	end

	--书页
	self:createPageNum(normal_panel, index)
	local sailor_config = sailor_info[sailor_id]

	-- 星级
	container.sailor_rank:changeTexture(STAR_SPRITE_RES[sailor_config.star].big, UI_TEX_TYPE_PLIST)
	-- 头像
	container.sailor_head:changeTexture(sailor_config.res, UI_TEX_TYPE_LOCAL)
	if not exist_sailor then
		container.sailor_bg:setGray(true)
		container.sailor_head:setGray(true)
		container.sailor_rank:setGray(true)
	end
	-- 航海士名字
	container.sailor_name:setText(sailor_config.name)
	-- 航海士个性 短描述
	container.personality_info:setText(sailor_config.nature)
	-- 航海士个性 长描述
	container.personality_long:setText(sailor_config.nature_dec)

	-- 职业icon
	container.sailor_job_icon:changeTexture(JOB_RES[sailor_config.job[1]], UI_TEX_TYPE_PLIST)
	-- 职业名称
	container.sailor_job_text:setText(ROLE_OCCUP_NAME[sailor_config.job[1]])

	-- 故事
	-- container.sailor_text:setText(sailor_config.explain)

	-- 介绍按钮
	self:registBtn(container.btn_text,index,function ()
		local tips = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_tip.json")
		getConvertChildByName(tips,"text"):setText(sailor_config.explain)
		local x = (index+1)%2*400 - 220
		tips:setAnchorPoint(ccp(0.5,0.5))
		tips:setPosition(ccp(display.cx + x ,display.cy))

		getUIManager():create("ui/view/clsBaseTipsView", nil, "collectSailoreTips", {is_back_bg = false, effect = 0 }, tips , true)
	end,true)
	-- 传纪按钮
	-- 暂时不显示
	container.btn_story:setVisible(false)
	-- self:registBtn(container.btn_story,function () end)

	local skills = sailor_config.tujian_skills
	local sailorData = getGameData():getSailorData()

	for i=1,2 do
		container[string.format('skill_bg_%d',i)]:setVisible(false)
	end
	for i,v in ipairs(skills) do
		container[string.format('skill_bg_%d',i)]:setVisible(true)
		local skill_data = skill_info[v]
		container[string.format('skill_icon_%d',i)]:changeTexture(convertResources(skill_data.res), UI_TEX_TYPE_PLIST)
	end

	local updateSelectSkill = function(index)
		for i=1,2 do
			local skill_data = skill_info[skills[i]]
			container[string.format('skill_selected_%d',i)]:setVisible( i == index )
			container[string.format('skill_icon_%d',i)]:changeTexture(convertResources(skill_data.res), UI_TEX_TYPE_PLIST)
			container[string.format('skill_active_%d',i)]:setVisible(skill_data.initiative == 1)
			--container[string.format('skill_bg_%d',i)]:changeTexture(SAILOR_SKILL_BG[skills[i].quality], SAILOR_SKILL_BG[skills[i].quality], SAILOR_SKILL_BG[skills[i].quality], UI_TEX_TYPE_PLIST)
		end
		container.skill_name:setText(skill_info[skills[index]].name)
		container.skill_effect:setText(sailorData:getSkillShortDesc(skills[index]))
	end

	-- 技能按钮一
	self:registBtn(container.skill_bg_1,index,function ()
		updateSelectSkill(1)
	end)

	self:registBtn(container.skill_bg_2,index,function ()
		updateSelectSkill(2)
	end)
	updateSelectSkill(1)

	return container
end

--[[
@api
	注册函数 兼容现有的UI框架 其实应该提取到框架部分的代码中
]]
ClsCollectSailorUI.registBtn = function(self, ui, index, callback, is_not_btn_effect)

	local btn_onTouchBegan = function(x,y)

		local book_index = self.book.currentIndex
		-- 判断是否是当前页
		local judge_index = (index%2 == 0) and book_index + 1 or book_index
		if not (index == judge_index) then
			return false
		end

		-- 判断是否是目标按钮的点击范围
		local rect = CCRectMake(0, 0, ui:getContentSize().width, ui:getContentSize().height)
		-- 两个全局坐标相减得出相对坐标 还得兼顾锚点变化
		local touch_x = x - ui:getWorldPosition().x+0.5*ui:getContentSize().width
		local touch_y = y - ui:getWorldPosition().y+0.5*ui:getContentSize().height

		return rect:containsPoint(ccp(touch_x,touch_y))
	end

	local btn_onTouchMoved = function(x,y)
	end

	local btn_onTouchEnded = function(x,y)
		if type(callback) == 'function' then
			if not is_not_btn_effect then
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
			end
			
			callback()
		end
	end

	local btn_onTouchCancelled = function(x,y)
	end

	local btn_onTouch = function(event,x,y)
		if event == "began" then
			return btn_onTouchBegan(x, y)
		elseif event == "moved" then
			 -- btn_onTouchMoved(x, y)
		elseif event == "ended" then
			btn_onTouchEnded(x, y)
		else
			-- cancelled
			btn_onTouchCancelled(x, y)
		end
	end

	-- @mid
	self:regTouchEvent(ui, function(...) return btn_onTouch(...) end,10)
end


ClsCollectSailorUI.setSailorMemoirInfo = function(self, sailor)
	-- local sailors = sailorData:getOwnSailors()
	-- local sailor = sailors[sailor_id]
	local sailor_mission = info_sailor_mission[sailor.id]
	local memoir_chapter = sailor.memoirChapter
	local cell_list = {}
	for i = 1, memoir_chapter do
		local layer = CCLayer:create()
		local memoir_info = createBMFont({text = "    " .. sailor_mission[i].tips_info, size = 14, width = 350, color = ccc3(dexToColor3B(COLOR_BROWN)), fontFile = FONT_CFG_1,
			align = ui.TEXT_VALIGN_TOP})
		memoir_info:setAnchorPoint(ccp(0,0))
		local height =  memoir_info:getContentSize().height
		layer:setContentSize(CCSize(350, height + 30))
		layer:addChild(memoir_info)
		local cell = ListCell.new(CCSize(350, height), layer)
		cell_list[i] = cell
	end

	return cell_list
end

ClsCollectSailorUI.showLegendHead = function(self, sailor_id, index)
	local bookpage = self.book.page[index]

	local playerData = getGameData():getPlayerData()
	-- local collectData = getGameData():getCollectData()
	local my_uid = playerData:getUid()

	local exist_sailor = getGameData():getSailorData():getOwnSailors()[sailor_id]


	local ui_layer = UILayer:create()
	local normal_panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_legend_head.json")
	convertUIType(normal_panel)
	ui_layer:addWidget(normal_panel)

	local pos = ccp(-6, 0)
	if index % 2 == 0 then
		pos = ccp(-20, 0)
	end
	ui_layer:setPosition(pos)

	local widget_name = {
		"sailor_rank", --星级
		"sailor_bg",
		"sailor_head", --头像
		"btn_story", --传记按钮
		"sailor_name", --名字
		"sailor_job_icon",
		"sailor_job_text",
		"sailor_text",  --描述
		"personality_info", ---航海士个性
		"personality_long",
		"source_bg",
		"source_txt",
	}

	local legend_head_layer = {}
	for k, v in pairs(widget_name) do
		legend_head_layer[v] = getConvertChildByName(normal_panel, v)
	end

	legend_head_layer.btn_story:setVisible(false)

	--书页
	self:createPageNum(normal_panel, index)

	local sailor_config = sailor_info[sailor_id]

	if sailor_config.get_way ~= "" then
		legend_head_layer.source_bg:setVisible(true)
		legend_head_layer.source_txt:setText(sailor_config.get_way)
	else
		legend_head_layer.source_bg:setVisible(false)
		legend_head_layer.source_txt:setText("")
	end
	--星级
	legend_head_layer.sailor_rank:changeTexture(STAR_SPRITE_RES[sailor_config.star].big, UI_TEX_TYPE_PLIST)

	--头像
	legend_head_layer.sailor_head:changeTexture(sailor_config.res, UI_TEX_TYPE_LOCAL)
	legend_head_layer.sailor_head:setScale(1)
	local size = legend_head_layer.sailor_head:getContentSize()
	legend_head_layer.sailor_head:setScale(130/size.width) 

	if not exist_sailor then
		legend_head_layer.sailor_bg:setGray(true)
		legend_head_layer.sailor_head:setGray(true)
		legend_head_layer.sailor_rank:setGray(true)
	end

	--名字
	legend_head_layer.sailor_name:setText(sailor_config.name)

	--职业icon
	legend_head_layer.sailor_job_icon:changeTexture(JOB_RES[sailor_config.job[1]], UI_TEX_TYPE_PLIST)
	legend_head_layer.sailor_job_text:setText(ROLE_OCCUP_NAME[sailor_config.job[1]])

	--描述
	legend_head_layer.sailor_text:setText(sailor_config.explain)

	--个性
	legend_head_layer.personality_info:setText(sailor_config.nature)
	legend_head_layer.personality_long:setText(sailor_config.nature_dec)

	--传记
	local sailor_mission = info_sailor_mission[sailor_id]
	if sailor_mission then
		local playerData = getGameData():getPlayerData()
		local myUid = playerData:getUid()

		local sailorData = getGameData():getSailorData()
		local owned = sailorData:hasOwned(sailor_id)

		if myUid == self.player_id and owned then --访问自己的

			legend_head_layer.btn_story:setVisible(true)
			legend_head_layer.btn_story:setPressedActionEnabled(true)
			legend_head_layer.btn_story:addEventListener(function()
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				-- self:showSailorStory(index, sailor_id, true)
			end, TOUCH_EVENT_ENDED)
		end
	end
	return ui_layer
end

ClsCollectSailorUI.showLegendExplore = function(self, sailor_id, index)
	local bookpage = self.book.page[index]

	local ui_layer = UILayer:create()
	local normal_panel = GUIReader:shareReader():widgetFromJsonFile("json/collect_sailor_legend_skill.json")
	convertUIType(normal_panel)
	ui_layer:addWidget(normal_panel)

	local pos = ccp(-6, 0)
	if index % 2 == 0 then
		pos = ccp(-20, 0)
	end
	ui_layer:setPosition(pos)

	local widget_name = {
		"skill_bg_1", --技能按钮1
		"skill_bg_2",

		"skill_active_1",
		"skill_active_2",

		"skill_icon_1", --技能图标1
		"skill_icon_2",

		"skill_selected_1", --技能选中图标1
		"skill_selected_2",

		"skill_name",  --名字
		"skill_effect_1", --说明1
		"skill_effect_2",
	}

	local layer = {}
	for k, v in pairs(widget_name) do
		layer[v] = getConvertChildByName(normal_panel, v)
	end

	--书页
	self:createPageNum(normal_panel, index)

	local sailor_config = sailor_info[sailor_id]

	--技能
	for i = 1, 2 do
		layer["skill_icon_" .. i]:setVisible(false)
	end

	local skills = DataTools:getSkillInfo(sailor_config)
	local sailorData = getGameData():getSailorData()

	local skill_btns = {}

	for k, v in pairs(sailor_config.tujian_skills) do 
		layer["skill_icon_" .. k]:setVisible(true)
		local skill = skill_info[v]

		layer["skill_icon_" .. k]:changeTexture(convertResources(skill.res), UI_TEX_TYPE_PLIST)
		layer["skill_bg_" .. k]:changeTexture(convertResources(SAILOR_SKILL_BG[skill.quality]), convertResources(SAILOR_SKILL_BG[skill.quality]),
				convertResources(SAILOR_SKILL_BG[skill.quality]), UI_TEX_TYPE_PLIST)

		local main_skill = 1
		layer["skill_active_" .. k]:setVisible(skill.initiative == main_skill)


		skill_btns[k] = layer["skill_bg_" .. k]
		skill_btns[k].skill_selected = layer["skill_selected_" .. k]




		layer["skill_bg_" .. k]:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
		end, TOUCH_EVENT_BEGAN)

		layer["skill_bg_" .. k]:addEventListener(function()
			layer.skill_name:setText(skill.name)

			local desc = sailorData:getSkillShortDesc(v)
			layer.skill_effect_1:setText(desc)
			layer.skill_effect_2:setVisible(false)

			for i = 1, #skill_btns do
				skill_btns[i].skill_selected:setVisible(k == i)
				skill_btns[i]:setTouchEnabled(k ~= i)
			end
		end, TOUCH_EVENT_ENDED)

		self:registBtn(layer["skill_bg_" .. k],index,function ()
			layer["skill_bg_" .. k]:executeEvent(TOUCH_EVENT_ENDED)
		end)

	end
	layer["skill_bg_" .. 1]:executeEvent(TOUCH_EVENT_ENDED)

	return ui_layer
end

--创建对应index航海士
ClsCollectSailorUI.showSailorByIndex = function(self, index)

	local info = self.pageInfo[index]
	if not info then return end

	local bookpage = self.book.page[index]
	if info.showType == "normal" then
		for k, sailor_id in pairs(info.list) do
			bookpage.normalNode = self:showNormal(sailor_id, index)
			bookpage:addChild(bookpage.normalNode)
			return bookpage.normalNode
		end
	end
	if info.showType == "legendHead" then
		for _, sailor_id in pairs(info.list) do
			bookpage.normalNode = self:showLegendHead(sailor_id, index)
			bookpage:addChild(bookpage.normalNode)
			return bookpage.normalNode
		end
	end
	if info.showType == "legendExplain" then
		for _, sailor_id in pairs(info.list) do
			bookpage.normalNode = self:showLegendExplore(sailor_id, index)
			bookpage:addChild(bookpage.normalNode)
			return bookpage.normalNode
		end
		return nil
	end
	return nil
end

ClsCollectSailorUI.addToLayer = function(self, layer, left_index, right_index)
	table.insert(layer, self:showSailorByIndex(left_index))
	table.insert(layer, self:showSailorByIndex(right_index))
end


--更新的当前页（包括左侧和右侧）
ClsCollectSailorUI.showDetails = function(self, index)

	--删除传记的显示
	for i = 1, #self.cur_layer do
		if i > 2 then
			if not tolua.isnull(self.cur_layer[i]) then
				self.cur_layer[i]:removeFromParentAndCleanup(true)
			end
			self.cur_layer[i] = nil
		else
			--航海士信息显示出来
			self.cur_layer[i]:setVisible(true)
		end
	end


	if self.last_index + 2 == index then --当前向后翻页
		self:clearPrevLayer() --删除原来保存的prev_layer
		self.prev_layer = self.cur_layer
		self.cur_layer = self.next_layer
		self:clearNextLayer()

		if index + 3 <= self.pageCount then
			self:addToLayer(self.next_layer, index + 2, index + 3)
		end
		self:clearCurLayer()
		self:addToLayer(self.cur_layer, index, index + 1)
	elseif self.last_index  - 2 == index then --当前向前翻页
		self:clearNextLayer() --删除原来保存的next_layer
		self.next_layer = self.cur_layer
		self.cur_layer = self.prev_layer
		self:clearPrevLayer()

		if index - 2 > 0 then
			self:addToLayer(self.prev_layer, index - 1, index - 2)
		end
		self:clearCurLayer()
		self:addToLayer(self.cur_layer, index, index + 1)
	else --直接翻到x页
		self:clearPrevLayer() --删除原来保存的prev_layer
		self:clearCurLayer()
		self:clearNextLayer()

		if index - 2 > 0 then
			self:addToLayer(self.prev_layer, index - 1, index - 2)
		end

		self:addToLayer(self.cur_layer, index, index + 1)

		if index + 3 <= self.pageCount then
			self:addToLayer(self.next_layer, index + 2, index + 3)
		end
	end

	--根据当前页数，判断tab页选中的改变
	if index >= self.normalIndex and index < self.seniorIndex and self.last_select_tab ~= TAB_NORMAL  then
		self:updateTabSelected(TAB_NORMAL)
	end

	if index >= self.seniorIndex and index < self.legendIndex and self.last_select_tab ~= TAB_SENIOR then
		self:updateTabSelected(TAB_SENIOR)
	end

	if index >= self.legendIndex and self.last_select_tab ~= TAB_LEGEND then
		self:updateTabSelected(TAB_LEGEND)
	end

	self.last_index = index

	for k, v in pairs(self.prev_layer) do
		v:setTouchEnabled(false)
	end

	for k, v in pairs(self.next_layer) do
		v:setTouchEnabled(false)
	end

	self:setTouch(true)
end


ClsCollectSailorUI.initBtns = function(self)
	--关闭按钮
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:effectClose()
		--self:close()


	end, TOUCH_EVENT_ENDED)

	self.tab_normal.label = self.normal_text
	self.tab_normal.amount_lab = self.normal_amount

	self.tab_advanced.label = self.advanced_text
	self.tab_advanced.amount_lab = self.advanced_amount

	self.tab_legend.label = self.legend_text
	self.tab_legend.amount_lab = self.legend_amount

	self.tabs = {self.tab_normal, self.tab_advanced, self.tab_legend}

	for i = 1, #self.tabs do
		self.tabs[i]:addEventListener(function()
			local color = ccc3(dexToColor3B(COLOR_BTN_SELECTED))
			setUILabelColor(self.tabs[i].label, color)
			setUILabelColor(self.tabs[i].amount_lab, color)
		end, TOUCH_EVENT_BEGAN)

		self.tabs[i]:addEventListener(function()

			-- if self.book:getIsIndexing() then
			-- 	return
			-- end

			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateTabSelected(i)

			local index = self.normalIndex
			if i == TAB_SENIOR then
				index = self.seniorIndex
			elseif i == TAB_LEGEND then
				index = self.legendIndex
			end
			self.book:indexPage(index)

		end, TOUCH_EVENT_ENDED)

		self.tabs[i]:addEventListener(function()
			local color = ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
			setUILabelColor(self.tabs[i].label, color)
			setUILabelColor(self.tabs[i].amount_lab, color)
		end, TOUCH_EVENT_CANCELED)
	end

	self.tabs[TAB_NORMAL]:executeEvent(TOUCH_EVENT_ENDED)
end

--改变tab页的UI显示 选中焦点 字体颜色等
ClsCollectSailorUI.updateTabSelected = function(self, tag)
	-- self:setTouch(false)
	for i = 1, #self.tabs do
		self.tabs[i]:setFocused(tag == i)
		self.tabs[i]:setTouchEnabled(tag ~= i)

		local color = ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
		if tag == i then 
			color = ccc3(dexToColor3B(COLOR_BTN_SELECTED))
		end
		setUILabelColor(self.tabs[i].label, color)
		setUILabelColor(self.tabs[i].amount_lab, color)
	end

	self.last_select_tab = index
end

ClsCollectSailorUI.setTouch = function(self, enable)

end

ClsCollectSailorUI.initData = function(self)
	local collectData = getGameData():getCollectData()
	collectData:initSailorData()

	self.normalSailors = collectData:getNormalSailors()
	self.seniorSailors = collectData:getSeniorSailors()
	self.legendSailors = collectData:getLegendSailors()
end

return ClsCollectSailorUI

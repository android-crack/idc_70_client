-- @author: mid
-- @date: 2016年12月1日19:34:46
-- @desc: 角色称号列表界面

-- include
local alert = require("ui/tools/alert")
local cfg = require("game_config/title/info_title")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")

-- define
local clsRoleTitleUI = class("clsRoleTitleUI",require("ui/view/clsBaseView"))
local clsRoleTitleItem = class("clsRoleTitleItem",require("ui/view/clsScrollViewItem"))

local QQ_TITLE_ID = 80001
local LEGEND_ARENA_TITLE_TAG = 5
-- override
function clsRoleTitleUI:onEnter()
	self:resetData()
	self:initUI()
	self:updateUI()
end

function clsRoleTitleUI:getViewConfig()
	return {
		is_back_bg = true,
 		effect = UI_EFFECT.SCALE
 	}
end

function clsRoleTitleUI:preClose()
	self:resetData()
end

-- tools
function getUTF8Length(input)
	local len  = string.len(input)
	local left = len
	local cnt  = 0
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i   = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
	end
	return cnt
end

-- logic
function clsRoleTitleUI:resetData()
	self.data = {}
	self.query_list = {}
	self.is_init_ui = false
	self.cur_index = 1
end

function clsRoleTitleUI:updateData()
	-- print("clsRoleTitleUI updateData ------------- begin ")

	local all_title_list = {}
	local id = getGameData():getTitleData():getCurTitle()
	local cur_title = {}

	cur_title.id = id
	cur_title.cfg = cfg[id]
	cur_title.is_get = true
	all_title_list[#all_title_list+1] = cur_title

	-- print("------ 当前已获得的所有称号")
	-- table.print(getGameData():getTitleData():getAllTitleList())

    local module_game_sdk = require("module/sdk/gameSdk")
    local platform = module_game_sdk.getPlatform()
    local is_qq = false
    if platform == PLATFORM_QQ and not GTab.IS_VERIFY then
    	is_qq = true
	end

	local sort_list = {}
	for k,v in pairs (cfg) do
		local title_is_true = true
		if not is_qq and k ==  QQ_TITLE_ID then
			title_is_true = false
		end

		if v.set == 1 and k ~= id and title_is_true then

			local new = {}
			new.id = k
			new.cfg = cfg[k]
			new.is_get = (getGameData():getTitleData():getTitleDataById(k) and true or false)
			sort_list[#sort_list+1] = new

		end
	end

	-- print(" ------ sort_list ")
	-- table.print(sort_list)

	table.sort(sort_list,function ( a,b )

		if a.is_get == b.is_get then
			if a.cfg.priority == b.cfg.priority then
				if a.cfg.title_type == b.cfg.title_type then
					return a.id > b.id
				else
					return a.cfg.title_type > b.cfg.title_type
				end
			else
				return a.cfg.priority > b.cfg.priority
			end
		else
			return a.is_get and true or false
		end
	end)

	for k,v in pairs(sort_list) do
		all_title_list[#all_title_list+1] = v
	end

	self.data.all_list = all_title_list
	-- table.print(all_title_list)
	-- print("clsRoleTitleUI updateData ------------- end ")
end

function clsRoleTitleUI:initUI()
	if self.is_init_ui then return end
	local main_ui = GUIReader:shareReader():widgetFromJsonFile("json/partner_title.json")
	self.main_ui = main_ui
	convertUIType(main_ui)
	main_ui:setPosition(ccp(display.cx*0.5+25,20))
	self:addWidget(main_ui)
	local wgts = {
		["list_bg"]           = "grey_bg", -- 列表背景 自己创建的列表控件放在上面
		["text_obtain_way"]   = "tips_text", -- 获取途径
		["btn_change_tilte"]  = "btn_change", -- 更换称号
		-- ["btn_hide_title"] = "btn_hidden", -- 隐藏称号
		["btn_close"]         = "btn_close", -- 关闭按钮
	}
	for k,v in pairs(wgts) do
		main_ui[k] = getConvertChildByName(main_ui,v)
	end

	-- 宽 326 高 190 默认 水平方向
	main_ui.list = require("ui/view/clsScrollView").new(326,186,true,nil,{ is_widget = true,is_fit_bottom = true })
	main_ui.list:setPosition(ccp(-163,-93))
	main_ui.list:removeAllCells() -- 移除所有子节点
	main_ui.list_bg:addChild(main_ui.list)

	local data = getGameData():getTitleData()

	local function close_callback()
		-- 关闭界面
		-- print(" ------ 关闭界面 ------ ")
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()
	end
	main_ui.btn_close:addEventListener(close_callback,TOUCH_EVENT_ENDED)
	local function hide_callback()
		-- 隐藏称号
		-- print(" ---- 隐藏称号 ---- 后端暂无实现,等")
	end
	local function change_callback()
		-- print("----- 更换称号")
		-- 更换称号
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		
		local item = self.data.all_list[self.cur_index]
		local cur_id = item.id
		-- table.print(item)
		if not item.is_get then
			alert:warning({msg = ui_word.CHANGE_TITLE_TIP1})
		end
		if cur_id and item.is_get then
			data:requestChangeTitle(cur_id) -- 发送当前称号
		end
	end
	main_ui.btn_change_tilte:addEventListener(change_callback,TOUCH_EVENT_ENDED)

	self.is_init_ui = true
end

function clsRoleTitleUI:showChangeTitleTips()
	alert:warning({msg = ui_word.CHANGE_TITLE_TIP2})
	self:close()
end

function clsRoleTitleUI:updateUI()
	if not self.is_init_ui then return end -- check

	-- 更新数据
	self:updateData()

	local list = self.main_ui.list
	list:removeAllCells()
	list.cells = {}

	local cells = {}
	for i,v in ipairs(self.data.all_list) do
		-- print("------------cell_index",i)
		v.cell_index = i
		cells[i] = clsRoleTitleItem.new(CCSize(338,44),v)
		cells[i]:setTouch(true)
		list:addCell(cells[i])
	end
	self.main_ui.list = list
	self.cells = cells

	self:updateListUI()
end

function clsRoleTitleUI:updateListUI()
	if not self.is_init_ui then return end

	-- print("--------updateListUI")

	local cur_item_cell = nil
	local cur_index = self.cur_index
	local main_ui = self.main_ui

	local cur_item_cell = nil
	for i,v in ipairs(self.cells) do
		v:updateItemUI(i == cur_index)
		if i == cur_index then
			cur_item_cell = v
		end
		if i == self.cur_index then
			cur_item_cell = v
		end
	end

	if cur_item_cell then

		-- print("------cur_item_cell")
		-- table.print(cur_item_cell.data)

		if cur_item_cell.data then
			if cur_item_cell.data.is_get then
				main_ui.btn_change_tilte:active()
			else
				main_ui.btn_change_tilte:disable()
			end
		end
	end

	-- table.print(self.data.all_list[self.cur_index])

	local data = self.data.all_list[cur_index]
	main_ui.text_obtain_way:setText(data.cfg.desc)

end

-------------------------------------------------------------

function clsRoleTitleItem:initUI(data)

	-- print(" ------------- clsRoleTitleItem initUI ---------data----")
	-- table.print(data)

	local data = data
	local item = GUIReader:shareReader():widgetFromJsonFile("json/partner_title_info.json")
	convertUIType(item)

	self.item = item
	self:addChild(item)
	self.data = data

	local wgts = {
		["bg"] = "partner_title_info", -- 背景底图
		["name"] = "title", -- 称号名字
		["selected"] = "select_bg", -- 选中框
		["left_logo"] = "title_left", -- 左边图片
		["right_logo"] = "title_right", -- 右边图片
	}

	for k,v in pairs(wgts) do
		item[k] = getConvertChildByName(item, v)
	end

	local str = data.cfg.title
	if not data.is_get then
		str = string.gsub(data.cfg.title,"%%s","")
	else
		local item = getGameData():getTitleData():getTitleDataById(data.id)
		-- print("------item")
		-- table.print(item)
		if item and item.args[1] then
			str = string.format(str,item.args[1] or "")
		end
	end

	local to_roman = {T("Ⅰ"),T("Ⅱ"),T("Ⅲ"),T("Ⅳ"),T("Ⅴ"),T("Ⅵ"),T("Ⅶ"),T("Ⅷ"),T("Ⅸ"),T("Ⅹ"),T("Ⅺ"),T("Ⅻ")}

	if data.cfg.class ~= -1 and math.floor(data.cfg.class/10) ~= LEGEND_ARENA_TITLE_TAG then
		local lv = (data.cfg.class)%10
		str = str ..to_roman[lv]
	end

	item.left_logo:setVisible(false)
	item.right_logo:setVisible(false)
	if not data.is_get and data.id ~= 0 then
		item.left_logo:setGray(false)
		item.right_logo:setGray(false)
		setUILabelColor(item.name, ccc3(dexToColor3B(COLOR_CREAM_STROKE)))
	end

	if data.id == 0 then
		str = ui_word.HIDE_CHENGHAO
	end

	item.name:setText(str)

	-- 颜色

	local length = getUTF8Length(str)
	if length > 4 then
		local spacing = (length - 4)*7
		item.left_logo:setPosition(ccp(111-spacing,22))
		item.right_logo:setPosition(ccp(225+spacing,22))
	end

	-- print("-------------- length",length)

	local index

	local target_ui = getUIManager():get("clsRoleTitleUI")
	if not tolua.isnull(target_ui) then
		index = target_ui:getCurIndex()
	else
		return
	end

	item.selected:setVisible(index == data.cell_index)
	if index == data.cell_index then
		item.left_logo:setVisible(true)
		item.right_logo:setVisible(true)
	end

	local function click_item_callback()
		-- print(" ----------------- click item ----------------- ")
		target_ui:setCurIndex(data.id)
		target_ui:updateListUI()
	end
end

function clsRoleTitleItem:updateItemUI(state)
	-- print(self)
	-- table.print(self)
	local item = self.item
	if item then
		local is_get = self.data.is_get
		item.selected:setVisible(state) -- 不是一开始就都创建出来的
		item.left_logo:setVisible(state)
		item.right_logo:setVisible(state)
		item.left_logo:setGray(not is_get)
		item.right_logo:setGray(not is_get)
		self.item.left_logo:setVisible(state)
		self.item.right_logo:setVisible(state)
		self.item.left_logo:setGray(not self.data.is_get)
		self.item.right_logo:setGray(not self.data.is_get)
	end
end

function clsRoleTitleItem:onTap(x,y)

	local target_ui = getUIManager():get("clsRoleTitleUI")
	if not tolua.isnull(target_ui) then
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		index = target_ui:getCurIndex()
	else
		return
	end

	-- print(" --------------------- onTap ---------------- ",self.data.cell_index)
	-- table.print(self.data)

	target_ui:setCurIndex(self.data.cell_index)
	target_ui:updateListUI()
end

function clsRoleTitleUI:setCurIndex(id)
	self.cur_index = id
end

function clsRoleTitleUI:getCurIndex()
	return self.cur_index
end

return clsRoleTitleUI

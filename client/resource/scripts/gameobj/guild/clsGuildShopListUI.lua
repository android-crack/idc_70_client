-- 商会商店列表数据
-- Author: chenlurong
-- Date: 2015-12-16 14:39:15
--

local guild_shop_info = require("game_config/guild/guild_shop_goods")
local music_info=require("scripts/game_config/music_info")
local ui_word = require("scripts/game_config/ui_word")
local Alert = require("ui/tools/alert")
local on_off_info=require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local ClsUiCommon = require("ui/tools/UiCommon")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local COL = 3
local ROW = 3

--------------------item-------------------
local ClsGuildShopItem = class("ClsGuildShopItem", function()  
		return UIWidget:create()
	end)

function ClsGuildShopItem:ctor(size, index)
	self.size = size
	self.data_index = index
	--LoadPlist({["ui/item_box.plist"] = 1})
end

function ClsGuildShopItem:setData(data)
	local shop_id = data.shopId
	self.data = guild_shop_info[shop_id]
	self.data.shop_id = shop_id
	self.data.shop_info = data
end

function ClsGuildShopItem:getData()
	return self.data
end

function ClsGuildShopItem:mkUi(index)
	self.index = index
	self.ui_layer = UIWidget:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_item.json")
	self.panel:setPosition(ccp(0, 8))
	convertUIType(self.panel)
	self.ui_layer:addChild(self.panel)
	self:addChild(self.ui_layer)

	self.black_pic = getConvertChildByName(self.panel, "black_pic")
	self.lock_text = getConvertChildByName(self.panel, "lock_text")
	self.item_name = getConvertChildByName(self.panel, "item_name")
	self.contribution_cost = getConvertChildByName(self.panel, "contribution_cost")
	self.item_bg = getConvertChildByName(self.panel, "item_bg")
	self.icon = getConvertChildByName(self.panel, "icon")
	self.icon_bg = getConvertChildByName(self.panel , "icon_bg")
	self.cost_bg = getConvertChildByName(self.panel , "cost_bg")
	self.sold_out = getConvertChildByName(self.panel , "sold_out")
	self.num_left = getConvertChildByName(self.panel , "num_left")
	self.item_num = getConvertChildByName(self.panel , "item_num")

	local index = math.ceil(self.data.level / 10)
	self.icon_bg:changeTexture("item_box_"..index..".png" , UI_TEX_TYPE_PLIST)

	self.item_num:setText("x" .. self.data.amount)

	local guild_data = getGameData():getGuildInfoData()
	local guild_level = guild_data:getGuildGrade()

	local unlock_level = self.data.guild_level[1]
	self.data.is_lock = guild_level < unlock_level
	if self.data.is_lock then
		self.lock_text:setText(string.format(ui_word.STR_GUILD_SHOP_UNLOCK, unlock_level))
		self.black_pic:setVisible(true)
	else
		self.black_pic:setVisible(false)
	end

	if self.data.stock > 0 then
		local left_num = math.max(0, self.data.stock - tonumber(self.data.shop_info.already_buy))
		self.num_left:setText(string.format(ui_word.STR_GUILD_SHOP_NUM_DESC, left_num))
		self.cost_bg:setVisible(left_num > 0)
		self.sold_out:setVisible(left_num <= 0)
		self.data.left_num = left_num
		self.icon:setGray(left_num <= 0)
	else
		self.data.left_num = 1000
		self.sold_out:setVisible(false)
		self.num_left:setVisible(true)
		self.num_left:setText(ui_word.STR_GUILD_SHOP_NO_LIMIT)
	end
	self.item_name:setText(self.data.name)
	self.contribution_cost:setText(self.data.price)
	self.item_bg:setPressedActionEnabled(true)
	self.item_bg:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
	end, TOUCH_EVENT_ENDED)

	self.icon:changeTexture(self.data.res, UI_TEX_TYPE_PLIST)

	local guild_shop_data = getGameData():getGuildShopData()
	local contribute = guild_shop_data:getContribute()
	self:changeTextColor(contribute >= self.data.price)
end

function ClsGuildShopItem:changeTextColor(is_enough)
	if self.contribution_cost then
		if is_enough then
			setUILabelColor(self.contribution_cost, ccc3(dexToColor3B(COLOR_WHITE)))
		else
			setUILabelColor(self.contribution_cost, ccc3(dexToColor3B(COLOR_RED)))
		end
	end
end

function ClsGuildShopItem:canClick()
	return not self.data.is_lock
end

function ClsGuildShopItem:changeSelectState(state)
	if self.is_selected ~= state then
		self.item_bg:setFocused(state)
	end
	self.is_selected = state
end

function ClsGuildShopItem:updateShopLeftNum(shop_id, num)
	if not self.data or self.data.shop_id ~= shop_id then
		return
	end
	if self.data.stock <= 0 then
		return
	end
	local left_num = self.data.left_num - num
	self.data.left_num = left_num 
	self.num_left:setText(string.format(ui_word.STR_GUILD_SHOP_NUM_DESC, left_num))
	self.cost_bg:setVisible(left_num > 0)
	self.sold_out:setVisible(left_num <= 0)
	self.icon:setGray(left_num <= 0)
end

--------------------cell-------------------
local ClsGuildShopCell = class("ClsGuildShopCell", ClsScrollViewItem)

function ClsGuildShopCell:updateCost()
	local guild_shop_data = getGameData():getGuildShopData()
	local contribute = guild_shop_data:getContribute()
	if self.item_list then
		for j, item in pairs(self.item_list) do
			local data = item:getData()
			item:changeTextColor(contribute >= data.price)
		end
	end
end

function ClsGuildShopCell:updateShopLeftNum(shop_id, num)
	if self.item_list then
		for j, item in pairs(self.item_list) do
			item:updateShopLeftNum(shop_id, num)
		end
	end
end

function ClsGuildShopCell:initUI(cell_date)
	self.size = cell_date.size
	self.call_back = cell_date.call_back

	self.item_list = {}
	self.bounding_list = {}

	local num = cell_date.num
	local shop_data = cell_date.data

	local item_width = self.size.width / COL
	for i = 1, num do
		local item = ClsGuildShopItem.new(CCSize(item_width, self.size.height), i)
		local pos = ccp(item_width*(i - 1), 0)
		item:setPosition(pos)
		self:addChild(item)
		self.item_list[i] = item
		item:setData(shop_data[i])

		item.touch_rect = CCRect(pos.x, 0, item_width, self.size.height)

		-- 尺寸有修改
		local item_size = CCSize(232, 122)
		local bounding_layer = UIWidget:create()
		local width_dis = item_width - item_size.width
		local height_dis = self.size.height - item_size.height
		-- bounding_layer:setContentSize(CCSize(item_size.width, item_size.height))
		bounding_layer:setPosition(ccp(item_width*(i - 1) + width_dis/2, height_dis/2))

		self:addChild(bounding_layer)
		self.bounding_list[i] = bounding_layer
	end
	-- {["index"] = math.ceil(i/ROW),["num"] = num,["call_back"] = function(item, x, y)
	self:mkUi(cell_date.index)
end

function ClsGuildShopCell:mkUi(index)
	self.index = index
	for k, v in ipairs(self.item_list) do
		v:mkUi(index)
	end
end

function ClsGuildShopCell:getItemList()
	return self.item_list
end

function ClsGuildShopCell:onTap(x, y)
	-- local pos = self:convertToNodeSpace(ccp(x, y))
	local touch_pos = self:getWorldPosition()
	local touch_x = x - touch_pos.x
	local touch_y = y - touch_pos.y
	for _,select_item in pairs(self.item_list) do
		print(touch_x,touch_y)
    	if select_item.touch_rect:containsPoint(ccp(touch_x,touch_y)) then
    		if select_item:canClick() then
				self.call_back(select_item, x, y)
			end
    		break
    	end		
	end

end

--------------------shop list--------------

local ClsGuildShopListUI = class("ClsGuildShopListUI", function() return UIWidget:create() end)

function ClsGuildShopListUI:ctor()
	self.is_enable = true
 	self:initUI()
	self.item_list = {}

	-- 商会数据
	self.guild_data = getGameData():getGuildInfoData()
	-- 玩家基础数据
	self.player_data = getGameData():getPlayerData()

	self.guide_tbl = {
		[170] = {on_off_key = on_off_info.DRAWING_10.value,},
	}
end

function ClsGuildShopListUI:initUI()
	self.uiLayer = UIWidget:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_shop_contribution.json")
    convertUIType(self.panel)
    self.uiLayer:addChild(self.panel)
    self:addChild(self.uiLayer)

    local guild_shop_data = getGameData():getGuildShopData()
	guild_shop_data:askShopList()

    self.guild_devote_num = getConvertChildByName(self.panel, "contribution_num")
    local contribute = guild_shop_data:getContribute()
	self.guild_devote_num:setText(tostring(contribute))
	missionGuide:pushGuideBtn(on_off_info.ARMOR_SELECT.value, {rect = CCRect(306, 325, 164, 69), guideLayer=self})
	
	ClsGuideMgr:tryGuide("ClsGuildShopUI")
end

-- 更新整个列表
function ClsGuildShopListUI:updateList(shop_list)
	if not tolua.isnull(self.list_view) then 
		-- self.list_view:removeFromParentAndCleanup(true)
		self.list_view:removeAllCells()
	end
	-- 对商品列表进行排序，比较规则：先比较等级，同等级比较类型
	local function sortFunc(a, b)
		local first_data = guild_shop_info[a.shopId]
		local second_data = guild_shop_info[b.shopId]

		local first_level = first_data.guild_level[1]
		local second_level = second_data.guild_level[1]

		if first_level < second_level then
			return true
		elseif first_level == second_level then
			local first_type = first_data.guild_shop_type
			local second_type = second_data.guild_shop_type

			if first_type < second_type then
				return true
			end
		end
		return false
	end
	table.sort(shop_list, sortFunc)
	

	local rect = CCRect(118, 26, 736, 368)
	if tolua.isnull(self.list_view) then

		self.list_view = ClsScrollView.new(rect.size.width,rect.size.height,true,nil,{is_fit_bottom = true})
		self.list_view:setPosition(rect.origin)
		self:addChild(self.list_view)
	end
	
	local cell_size = CCSizeMake(rect.size.width, rect.size.height / ROW -5)
	local row_item_list = nil
	local total_amount = #shop_list
	for i, v in ipairs(shop_list) do
		local col = (i - 1) % COL + 1
		if col == 1 then
			local num = 0
			if total_amount >= COL then 
				num = COL
				total_amount = total_amount - num
			else
				num = total_amount
			end
			local shop_data = {}

			for j=0,num-1 do
				table.insert(shop_data, shop_list[i + j])
			end

			local cell_date = {["data"] = shop_data, ["size"] = cell_size,["index"] = math.ceil(i/ROW),["num"] = num,["call_back"] = function(item, x, y)
				self:selectItem(item, x, y)
			end}
			local cell = ClsGuildShopCell.new(cell_size, cell_date)
			self.list_view:addCell(cell)
			-- row_item_list = cell:getItemList()
			-- self.item_list[#self.item_list + 1] = row_item_list
		end
		-- row_item_list[col]:setData(v.shopId)

		local item_id = guild_shop_info[v.shopId].item_id
		if v.lock < 1 and self.guide_tbl[item_id] then
			missionGuide:pushGuideBtn(self.guide_tbl[item_id].on_off_key, {guideLayer=self,rect = CCRect(121+(i-1)*248, 292-(math.ceil(i/ROW)-1)*111, 231, 103)})
		end
	end

	if self.player_data:getLevel() >= 40 and
		self.guild_data:getGuildGrade() >= 32
		then
		self.list_view:scrollToCellIndex(3, true)
	else

	end

	if not self.is_enable then
		self:setTouch(self.is_enable)
	end
end

function ClsGuildShopListUI:buyShop(data)
	local guild_shop_data = getGameData():getGuildShopData()
	local contribute = guild_shop_data:getContribute()
	if contribute >= data.price then 
		-- local str = string.format(ui_word.STR_GUILD_SHOP_BUY, data.price, data.name)
		-- Alert:showAttention(str, function()
		-- 	local guild_shop_data = getGameData():getGuildShopData()
		-- 	guild_shop_data:buyShop(data.shop_id, 1)
		-- end)

		-- guild_shop_data:buyShop(data.shop_id, 1)
		-- self:setTouch(false)
		local shop_alert = getUIManager():create("gameobj/guild/clsShopAlertPanel")
		local max_num = math.floor(contribute/data.price)
		local left_num = data.left_num
		shop_alert:showShopByItem(data.shop_id,data,data.price,shop_alert.TYPE_CONTRIBUTE,math.min(max_num, left_num),function(id,amount)
			guild_shop_data:buyShop(id,amount)
			end)


	else
		local guild_shop = getUIManager():get("ClsGuildShopUI")
        Alert:showJumpWindow(CONTRIBUTE_NOT_ENOUGH, guild_shop)
	end
end

-- 更新贡献值
function ClsGuildShopListUI:updateContribute(value)
	ClsUiCommon:numberEffect(self.guild_devote_num, tonumber(self.guild_devote_num:getStringValue()), value)
	
	-- 判断每个商品是否够贡献值购买
	if not tolua.isnull(self.list_view) then
		for i,cell in pairs(self.list_view:getCells()) do
			-- print(i,v)
			cell:updateCost()
		end
	end

end

-- 更新商品库存
function ClsGuildShopListUI:updateShopLeftNum(shop_id, num)	
	-- 判断每个商品是否够贡献值购买
	if not tolua.isnull(self.list_view) then
		for i,cell in pairs(self.list_view:getCells()) do
			print(i,v)
			cell:updateShopLeftNum(shop_id, num)
		end
	end

end

function ClsGuildShopListUI:selectItem(item, x, y)
	local data = item:getData()
	if data.stock > 0 and data.left_num <= 0 then
        Alert:warning({msg = ui_word.NOT_GOODS, size = 26})
        return
    end
	-- 动画效果
	local array = CCArray:create()
	array:addObject(CCCallFunc:create(function()
		item:changeSelectState(true)
		end))
	array:addObject(CCDelayTime:create(0.15))
	array:addObject(CCCallFunc:create(function()
		item:changeSelectState(false)
		end))

	item:runAction(CCSequence:create(array))

	
	self:buyShop(data)
end

function ClsGuildShopListUI:setTouch( enable )
	self.is_enable = enable
	if not tolua.isnull(self.uiLayer) then
		self.uiLayer:setTouchEnabled(enable)
	end

	if not tolua.isnull(self.list_view) then
		self.list_view:setTouchEnabled(enable)
	end
end

return ClsGuildShopListUI
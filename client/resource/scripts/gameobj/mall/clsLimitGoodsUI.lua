-- 限时折扣
-- Author: Ltian
-- Date: 2016-11-20 15:27:58
--
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local item_info = require("game_config/propItem/item_info")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")
local CompositeEffect = require("gameobj/composite_effect")

local ClsGoodsItem = class("ClsGoodsItem", function () return UIWidget:create() end)
local widget_name = {
	"sales_banner",
	"gold_icon",
	"gold_num",
	"item_pic",
	"gift_txt",
	"diamond_num",
	"item_normal",
	"price_banner",
	"diamond_icon",
	"sales_text",
	"sold_out",
	"sold_out_txt",
}

function ClsGoodsItem:ctor(data,is_limit)
	self.data = data
	if self.data.goods_type == "cash" then --金币有自己的计算公式
		local level = getGameData():getPlayerData():getLevel()
		local one_diamand_to_gold = getGameData():getShopData():getOneGoldCount(level)
		local all_gold = one_diamand_to_gold * self.data.price
		self.data.goods_amount = all_gold
	end
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/shop_item_normal.json")
	
	convertUIType(self.panel)
	self:addChild(self.panel)
	for i,v in ipairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	self:mkUI()
	if self.data.discount_count <= 0 then
		self.sold_out:setVisible(true)
		self.sold_out_txt:setText(self.data.sale_end_tips)
		self:setGray(true)
	end
	
end

function ClsGoodsItem:mkUI()
	local item_res, amount, scale = getCommonRewardIcon({key = ITEM_TYPE_MAP[self.data.goods_type], id = self.data.goods_id, value = self.data.goods_amount})
	self.gold_icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	self.gold_num:setText(tostring(self.data.goods_amount))
	if self.data.pic_icon ~= "" then
		self.item_pic:changeTexture(convertResources(self.data.pic_icon), UI_TEX_TYPE_PLIST)
	else
		self.item_pic:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
	end
	
	self.gift_txt:setText(self.data.sales_text[1])
	local discount = self.data.discount[#self.data.discount + 1 - self.data.discount_count]
	local price = self.data.price
	if discount and type(discount) == "number" then
		local dis = discount/10
		self.price = Math.round(price * dis / 10)
		self.sales_text:setText(string.format(ui_word.DISCOUNT, tostring(dis)))
	else
		self.sales_banner:setVisible(false)

	end
	if self.data.is_show_limit == 1 then
		print(ui_word.SALE_LIMIT)
		self.sales_text:setText(ui_word.SALE_LIMIT)
	end
	self.diamond_num:setText(self.price or price)
	size = self.diamond_num:getContentSize()
	if size.width < 20 then
		local pos = self.diamond_num:getPosition()
		self.diamond_num:setPosition(ccp(pos.x + 25 - size.width, pos.y))
	end
end

function ClsGoodsItem:setGray(bGray)
	self.is_gray = true
	local imgs = {"sales_banner" , "gold_icon"  , "item_normal", "price_banner", "diamond_icon", "item_pic"}
	for __ , name in ipairs(imgs) do
		self[name]:setGray(bGray)
	end


	local texts = {"diamond_num", "gold_num", "gift_txt", "sales_text"}
	for __ , name in ipairs(texts) do
		setUILabelColor(self[name] , ccc3(dexToColor3B(COLOR_GREY_STROKE)))
		self[name]:setOpacity(127)
	end
end



function ClsGoodsItem:onTap(x, y)
	
	if self.data.discount_count <= 0 then
		return
	end
	local max_sele_count = self.data.discount_count
	if self.data.goods_type == ITEM_TYPE_TIEM then
		local prop_data_dandler = getGameData():getPropDataHandler()
		local prop_count = prop_data_dandler:getPropNumByID(self.data.goods_id)
		local max_count = item_info[self.data.goods_id].max_limit
		local can_get_count = math.ceil((max_count - prop_count) / self.data.goods_amount)
		if can_get_count < max_sele_count then
			max_sele_count = can_get_count
		end
		if max_count == prop_count then
			print("max_count", max_count, prop_count)
			local tips = string.format(ui_word.BUY_PORP_FULL_TIPS, self.data.name)
			Alert:warning({msg = tips, size = 26})
			return
		end
	elseif self.data.goods_type == ITEM_TYPE_TILI then
		local player_data = getGameData():getPlayerData()
		local is_full = player_data:isFullPower()
		local power = player_data:getPower()
		local max_power = player_data:getMaxPower()


		local can_get_count = math.ceil((max_power - power) / self.data.goods_amount)
		if can_get_count < max_sele_count then
			max_sele_count = can_get_count
		end
		if is_full then
			local tips = string.format(ui_word.BUY_PORP_FULL_TIPS, self.data.name)
			Alert:warning({msg = tips, size = 26})
			return
		end
		
	end
   
	local play_data = getGameData():getPlayerData()
	local gold = play_data:getGold()
	-- if self.price > gold then
	-- 	--Alert:warning({msg = ui_word.GET_GOLD_LACK_TIPS, size = 26})
	-- 	local alertType = Alert:getOpenShopType()
	-- 	Alert:showJumpWindow(DIAMOND_NOT_ENOUGH_GOSHOP, self, {come_type = alertType.VIEW_NORMAL_TYPE})
	-- 	return 
	-- end
	local item_res, amount, scale = getCommonRewardIcon({key = ITEM_TYPE_MAP[self.data.goods_type], id = self.data.goods_id, value = self.data.goods_amount})
	local dese = self.data.product_desc
	local config = {
		icon = item_res,
		name = self.data.name,
		desc = dese,
		id = self.data.id,
		discount_count = self.data.discount_count,
		goods_type = self.data.goods_type
	}
		config.amount = self.data.goods_amount
		config.max_partner = max_sele_count
		if self.data.goods_type == "cash" or self.data.goods_type == "tili" then
			config.max_partner = 1
		end
		config.price_icon = "common_icon_diamond.png"
		--config.price = self.price
		local price_tab = {}
		local index = #self.data.discount - self.data.discount_count + 1
		for i=index, #self.data.discount do
			price_tab[#price_tab +1] = Math.round(self.data.discount[i] / 100 * self.data.price)
		end
	  
		config.price_tab = price_tab
		local callback = function (amount)
			local shop_data = getGameData():getShopData()
			shop_data:askBuyShopItem(self.data.id, amount)
		end
 
	getUIManager():create("gameobj/mall/clsMallBuyTips", nil, {config_data = config, buy_fun = callback,is_limit = true})

end

local ClsGoodsCell = class("ClsGoodsCell", ClsScrollViewItem)

function ClsGoodsCell:initUI()
	self.items = {}
	for i,v in ipairs(self.datas) do
		self.items[i] = ClsGoodsItem.new(v)
		self.items[i]:setPosition(ccp(0, 384 - 192*i))
		self:addChild(self.items[i])
	end
	
end
function ClsGoodsCell:insertData(data)
	if not self.datas then self.datas = {} end
	self.datas[#self.datas + 1] = data
end

function ClsGoodsCell:onTap(x, y)
	
	for i,v in ipairs(self.items) do
		local pos = self.items[i].item_normal:convertToWorldSpace(ccp(0, 0))
		local size = self.items[i].item_normal:getContentSize()
		local rect = CCRect(pos.x - size.width/2, pos.y - size.height/2, size.width, size.height)
		local in_rect = rect:containsPoint(ccp(x, y))

		if in_rect then
			self.items[i]:onTap(x, y)
		end
	end
	

end


function ClsGoodsCell:getGoodItem()
	return self.items
end


local ClsLimitGoodsUI = class("ClsLimitGoodsUI", function () return UIWidget:create() end)

function ClsLimitGoodsUI:ctor( ... )
	-- body
	self:mkUI()
	self:playAction()
end

local ALL_HORIZONTAL_SHOW_GIF_NUM = 2
local ONE_ROW_COUNT = 4
function ClsLimitGoodsUI:mkUI()
	if tolua.isnull(self.list_view) then
		self.list_view = ClsScrollView.new(682, 384, false, function()
			return cell_ui
		end, {is_fit_bottom = true})
		self.list_view:setPosition(ccp(89, 85))
		self.list_view:setZOrder(100)
		self:addChild(self.list_view)
	end
   self.list_view:removeAllCells()
	
	local mall_data = getGameData():getShopData()
	local limit_goods = mall_data:getLimitGoodsInfo()
	local current_cells = {}
	local current_cell
	if #limit_goods > 8 then
		for k, v in ipairs(limit_goods) do
			if k % ALL_HORIZONTAL_SHOW_GIF_NUM == 1 then

				current_cell = ClsGoodsCell.new(CCSize(168, 387),{index = index})
				current_cells[#current_cells + 1] = current_cell
			   
			end
			current_cell:insertData(v)
		end
	else
		for k, v in ipairs(limit_goods) do
			if k <= ONE_ROW_COUNT then
				print("current_cells", k)
				local current_cell = ClsGoodsCell.new(CCSize(168, 387),{index = index})
				current_cell:insertData(v)
				current_cells[#current_cells + 1] = current_cell
			else
				current_cells[k - 4]:insertData(v)
			end
			
		end
	end
	

	
	self.list_view:addCells(current_cells)
	
end

function ClsLimitGoodsUI:updateView()
	self:mkUI()
end

function ClsLimitGoodsUI:playAction()
	
	local cells = self.list_view:getCells()
	local items = {}
	for i=1,5 do
		if not tolua.isnull(cells[i]) then
			local good_items = cells[i]:getGoodItem()
		
			if type(good_items) == "table" then
				items[#items + 1] = good_items
				for k,v in ipairs(good_items) do
					v.item_normal:setVisible(false)
				end
			end
		end
	end
	local array = CCArray:create()

	
	for i=1,2 do
		for _,item in ipairs(items) do
			array:addObject(CCCallFunc:create(function ( )
				if not tolua.isnull(item[i]) then
					item[i].item_normal:setVisible(true)
					item[i].item_normal:setScale(0.8)
					item[i].item_normal:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.08, 1.2), CCScaleTo:create(0.04, 1)))
					if not item[i].is_gray then
						CompositeEffect.new("tx_shop_item", 0, 0, item[i].item_normal, nil, nil, nil, nil, true)
					end
					
				end
				
			end))
			array:addObject(CCDelayTime:create(0.12))
		end
	end
	self:runAction(CCSequence:create(array))
	
end
return ClsLimitGoodsUI
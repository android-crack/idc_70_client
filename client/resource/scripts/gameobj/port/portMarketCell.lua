local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local news=require("game_config/news")
local music_info=require("game_config/music_info")
local CompositeEffect = require("gameobj/composite_effect")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local on_off_info = require("game_config/on_off_info")
local UiCommon = require("ui/tools/UiCommon")
local dataTools = require("module/dataHandle/dataTools")
local port_goods_info = require("game_config/port/port_goods_info")
local local_goods_info = require("game_config/port/local_goods_info")
local goods_type_info = require("game_config/port/goods_type_info")
local goods_info = require("game_config/port/goods_info")

local armatureManager=CCArmatureDataManager:sharedArmatureDataManager()

--left_state:如果不是居中的文本，左边对其就双倍大小
local function adjustPos(node1, node2, node3, label, x, y, left_state) --调整图标和名字的坐标
	local width1 = 22
	local width2 = label:getContentSize().width + 2

	-- if not tolua.isnull(node3) then
	--     node3:setPosition(x - width2/2 - 15, y)
	-- end

	if width2 > 80 then
		width2 = 62
	elseif width2 > 68 then
		width2 = 50
	elseif width2 > 48 then
		width2 = 45
	elseif width2 > 38 then
		width2 = 38
	end
	if left_state then
		width2 = width2 * 2
	end

	if tolua.isnull(node1) then
		if tolua.isnull(node2) then
			return
		else
			node2:setPosition(x + width2, y)
		end
	else
		if tolua.isnull(node2) then
			node1:setPosition(x + width2, y + 2)
		else
			node2:setPosition(x + width2, y)
			node1:setPosition(x + width1 + width2, y + 2)
		end
	end
end

--hard code
widthStoreCell = 340           --细胞大小
heightStoreCell = 127

widthCargoCell = 457          --细胞大小
heightCargoCell = 107

CellStore = class("CellCargo", ClsScrollViewItem)

function CellStore:mkItem(store)
	local opacity=255
	local sprite = UIWidget:create()

	local bounding_layer = display.newLayer()
	bounding_layer:setContentSize(CCSize(116, 86))
	sprite.bounding_layer = bounding_layer

	sprite.panel = GUIReader:shareReader():widgetFromJsonFile("json/market_buy.json")
	convertUIType(sprite.panel)
	sprite:addChild(sprite.panel)

	local res_icon = getConvertChildByName(sprite.panel, "goods_icon")
	sprite.amountLabel = getConvertChildByName(res_icon, "goods_amont")

	local res = string.sub(store.res, 2)
	res_icon:changeTexture(res, UI_TEX_TYPE_PLIST)

	local goods_silver = getConvertChildByName(sprite.panel, "goods_silver")
	local goods_price = getConvertChildByName(sprite.panel, "goods_price")
	local goods_unlock_text = getConvertChildByName(sprite.panel, "goods_unlock_text")
	local goods_type = getConvertChildByName(sprite.panel, "goods_type")
	local nameLabel = getConvertChildByName(sprite.panel, "goods_name")

	if store.kind == STORE_NORMAL then       --可以购买
		goods_price:setText(store.price)
		store.tradeAmount = store.tradeAmount or 0
		sprite.amountLabel:setText(store.amount - store.tradeAmount)
	else
		opacity = HALF_OPACITY
		goods_silver:setVisible(false)
		goods_price:setVisible(false)
		goods_unlock_text:setVisible(true)
		sprite.amountLabel:setVisible(false)
		if store.kind == STORE_EMPTY then
			goods_unlock_text:setText(news.PORT_COUNT_NOT_ENOUGH.msg)
		elseif store.kind == STORE_LOCK then
			goods_unlock_text:setText(news.PORT_BOOM_NOT_ENOUGH.msg)
		end
		goods_unlock_text:setOpacity(opacity)
		goods_price:setOpacity(opacity)
		res_icon:setOpacity(opacity)
		goods_type:setOpacity(opacity)
		nameLabel:setOpacity(opacity)
	end

	--需求品牌子变化
	local lightSprite
	local portData = getGameData():getPortData()
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local level = 0
	if goods_info[store.id] then
		level = goods_info[store.id].level
	end
	goods_type:setText(string.format(ui_word.PORT_GOOD_LEVEL, level, goods_type_info[store.class].name))
	nameLabel:setText(store.name)

	local hot_Sprite = nil
	local particle = nil
	if store.isHotSell == 1 then
		hot_Sprite = display.newSprite("#common_hotsell.png")
		hot_Sprite:setOpacity(opacity)
		sprite:addCCNode(hot_Sprite)
		if opacity ~= HALF_OPACITY then
			particle = CCParticleSystemQuad:create("effects/tx_1033.plist")
			particle:setPosition(ccp(38, 77))
			sprite:addCCNode(particle)
		end
	end

	---商会需要的商品
	-- local guild_research_data = getGameData():getGuildResearchData()
	-- local is_guild_need = guild_research_data:isGoodsGuildNeed(store.id)
	local guild_sprite = nil
	-- if is_guild_need then
	--     guild_sprite = getChangeFormatSprite("ui/txt/txt_goods_guild.png")
	--     guild_sprite:setScale(0.6)
	--     guild_sprite:setOpacity(opacity)
	--     sprite:addCCNode(guild_sprite)
	-- end

	local tagSprite = nil
	local showTag = nil
	if store.breed == GOOD_TYPE_AREA then
		showTag = "#txt_common_goods_area.png"
	elseif store.breed == GOOD_TYPE_PORT then
		showTag = "#txt_common_goods_port.png"
	end

	local nameLb_x = 70
	local nameLb_y = 16
	if showTag then
		if tolua.isnull(particle) and opacity~=HALF_OPACITY and store.breed ~= GOOD_TYPE_AREA then
			particle = CCParticleSystemQuad:create("effects/tx_1033.plist")
			particle:setPosition(ccp(38, 77))
			sprite:addCCNode(particle)
		end

		local width = nameLabel:getContentSize().width
		tagSprite = display.newSprite(showTag)
		tagSprite:setOpacity(opacity)
		tagSprite:setScale(0.6)
		tagSprite:setPosition(ccp(nameLb_x + width, nameLb_y))
		sprite:addCCNode(tagSprite)
	end

	adjustPos(hot_Sprite, tagSprite, guild_sprite, nameLabel, nameLb_x, nameLb_y)

	sprite.item = store
	return sprite
end

function CellStore:initUI(cell_data)
	self.sprites = {}
	if cell_data.store1 then
		self.sprites[1] = self:mkItem(cell_data.store1)
		self.sprites[1]:setPosition(ccp(0, 10))
		self:addChild(self.sprites[1])

		self.sprites[1].bounding_layer:setPosition(ccp(0, 22))
		self:addCCNode(self.sprites[1].bounding_layer)
	end
	if cell_data.store2 then
		self.sprites[2] = self:mkItem(cell_data.store2)
		self.sprites[2]:setPosition(ccp(160, 10))
		self:addChild(self.sprites[2])
		self.sprites[2].bounding_layer:setPosition(ccp(160, 22))
		self:addCCNode(self.sprites[2].bounding_layer)
	end
end

function CellStore:touchHandle(sprite)  --返回最后改变的细胞索引位置
	local marketLayer = getUIManager():get("ClsPortMarket")
	--		print(sprite.kind,"种类","商品名字",sprite.item.name,"  amount ",sprite.item.amount," tradeAmount ",sprite.item.tradeAmount)
	if sprite.item.kind ~= 1 then return end   --不能买
	--判断目前操作后的剩余量
	local remainAmount = sprite.item.amount + sprite.item.tradeAmount
	if remainAmount <= 0 then
		Alert:warning({msg = news.PORT_MARKET_NOT_GOODS.msg, size = 26})
		return
	end
	--判断钱是否连一个都买的起
	local canBuyAmount = self:getBuyAmountOfCash(sprite.item.price)  --钱不够 也不能买

	if canBuyAmount <=0 then
		Alert:showJumpWindow(CASH_NOT_ENOUGH, marketLayer, {need_cash = sprite.item.price, come_type = marketLayer:getParentViewType(), come_name = "market"})
		return
	end

	local cells = marketLayer:getCargoCellList()
	for k,cell in ipairs(cells) do
		if cell.item.boat_type > 0 then
			local good = cell.item
			if good.good_id > 0 then --同样的商品看能否空位可以填写
				if good.good_id == sprite.item.id then
					local bulkAmount = good.load - (good.amount + good.tradeAmount)
					if bulkAmount > 0 then  --填充满当前已有的货物的格子
						audioExt.playEffect(music_info.MARKET_OK.res)
						return self:buy(sprite, cell, canBuyAmount, remainAmount, bulkAmount, good, k)
					end
				end
			else--新格子
				audioExt.playEffect(music_info.MARKET_OK.res)
				return self:buy(sprite, cell, canBuyAmount, remainAmount, good.load, good, k)
			end
		end
	end
	--如果还没return掉证明没交易成功
	Alert:warning({msg = news.PORT_MARKET_BUY_1.msg, size = 26})
end

function CellStore:buy(sprite, cell, canBuyAmount, remainAmount, bulkAmount, good, cellIndex)
	local marketLayer = getUIManager():get("ClsPortMarket")
--    print("remainAmount",remainAmount,"canBuyAmount",canBuyAmount,"bulkAmount",bulkAmount)
	if good.good_id == 0 then
		good.good_id = sprite.item.id
		good.good_info = dataTools:getGoods(good.good_id)
		good.type = sprite.item.type
		good.is_hot = sprite.item.isHotSell
		good.base_price = sprite.item.price
		good.price = sprite.item.price
		good.profit = 0
		good.amount = 0
		good.tradeAmount = 0
		good.tipsCount = 0
	end
	good.isHas = true --代表左边交易所已经有
	good.canSell = true --可以返回出去

	local realBuyAmount = math.min(canBuyAmount, remainAmount, bulkAmount)
	--左边的值和显示变化
	sprite.item.tradeAmount = sprite.item.tradeAmount - realBuyAmount
	sprite.amountLabel:setText(sprite.item.amount + sprite.item.tradeAmount)
	--右边的值和显示变化
	good.tradeAmount = good.tradeAmount + realBuyAmount
	--ui上效果变化
	-- print("=================================CellStore:buy", realBuyAmount, canBuyAmount, remainAmount, bulkAmount)
	marketLayer:setTradeValue(sprite.item.price, nil, realBuyAmount, nil, sprite.item)
	--滚动列表
	local curIndex = marketLayer.cargoList:getTopCellIndex()
	if cellIndex < 5 then
		if curIndex ~= 1 then
			marketLayer.cargoList:scrollToCellIndex(1)
			curIndex = 1
		end
	else
		local new_index = cellIndex - 3
		if curIndex ~= new_index then
			marketLayer.cargoList:scrollToCellIndex(new_index)
		end
		curIndex = new_index
	end

	if not curIndex or curIndex == 0 then curIndex = 1 end
	local gapIndex = cellIndex - curIndex
	local pos = ccp(600, 444 - gapIndex * 110)

	marketLayer:moveGood(sprite.item.res, self.touchPos, pos, nil, function()
		if not tolua.isnull(cell) then
			cell:mkItem()
		end
	end)
	return realBuyAmount
end

function CellStore:getBuyAmountOfCash(price)   --获取临时操作后还有多少钱
	local marketLayer = getUIManager():get("ClsPortMarket")
	return math.modf(marketLayer:getTradeValue()/price)
end

function CellStore:onTap(x,y)
	if tolua.isnull(self) then return end
	self.touchPos = ccp(x,y)
	local pos = self:getWorldPosition()
	local node_pos = ccp(x - pos.x, y - pos.y)
	for k,sprite in pairs(self.sprites) do
		if not tolua.isnull(sprite) then
			if sprite.bounding_layer:boundingBox():containsPoint(node_pos) then
				self:touchHandle(sprite)
				break
			end
		end
	end
end

function CellStore:autoTap(goods_id, mission_need_num)
	if not goods_id then return end

	local marketLayer = getUIManager():get("ClsPortMarket")
	local marketData = getGameData():getMarketData()

	local doBuy = function(sprite)
		if sprite.item.kind ~= 1 then return end   --不能买
		--判断目前操作后的剩余量
		local remainAmount = sprite.item.amount + sprite.item.tradeAmount
		if remainAmount <= 0 then
			return
		end
		--判断钱是否连一个都买的起
		local canBuyAmount = self:getBuyAmountOfCash(sprite.item.price)  --钱不够 也不能买
		if canBuyAmount <= 0 then
			--判断钱是否连一个都买的起
			if not marketData.has_show_nonenough then
				Alert:showJumpWindow(CASH_NOT_ENOUGH, marketLayer, {need_cash = sprite.item.price, come_type = marketLayer:getParentViewType(), come_name = "market"})
				marketData.has_show_nonenough = true
			end
			return
		end

		local cells = marketLayer.cargo_list
		local has_buy_amount = 0
		for k,cell in ipairs(cells) do
			has_buy_amount = 0
			if canBuyAmount <= 0 then
				return
			end
			if cell.item.boat_type > 0 then
				local good = cell.item
				remainAmount = sprite.item.amount + sprite.item.tradeAmount
				if mission_need_num then
					if mission_need_num <= 0 then
						return
					end
					mission_need_num = mission_need_num - good.load
				end
				if remainAmount <= 0 then
					return
				end
				if good.good_id > 0 then --同样的商品看能否空位可以填写
					if good.good_id == sprite.item.id then
						local bulkAmount = good.load - (good.amount + good.tradeAmount)
						if bulkAmount>0 then  --填充满当前已有的货物的格子
							has_buy_amount = self:buy(sprite, cell, canBuyAmount, remainAmount, bulkAmount, good, k)
						end
					end
				else--新格子
					has_buy_amount = self:buy(sprite, cell, canBuyAmount, remainAmount, good.load, good, k)
				end
			end
			if has_buy_amount > 0 and not marketData.has_music then
				marketData.has_music = true
				audioExt.playEffect(music_info.MARKET_OK.res)
			end
			canBuyAmount = canBuyAmount - has_buy_amount
		end
	end

	local sprite_size = nil
	local sprite_pos = nil
	local pos = self:getWorldPosition()
	for k,v in pairs(self.sprites) do
		if v.item.id and v.item.id == goods_id then
			sprite_pos = v:getPosition()
			sprite_size = v.bounding_layer:getContentSize()
			self.touchPos = ccp(pos.x + sprite_pos.x + sprite_size.width/2, pos.y + sprite_pos.y + sprite_size.height/2)
			doBuy(v)
		end
	end
end

--buyCell
CellCargo = class("CellCargo", ClsScrollViewItem)
function CellCargo:initUI(item)
	self.item = item
	self:addCCNode(display.newSprite("#market_shelf.png", 41, 6))

	if self.item.boat_type and self.item.boat_type > 0 then
		local boat = dataTools:getBoat(self.item.boat_type)
		self.resArmature = string.format("armature/ship/%s/%s.ExportJson", boat.effect, boat.effect)
		armatureManager:addArmatureFileInfo(self.resArmature)
		local shipSprite = CCArmature:create(boat.effect)
		shipSprite:getAnimation():playByIndex(0)
		shipSprite:setScale(0.15)
		local height=shipSprite:getContentSize().height
		shipSprite:setPosition(40, boat.boatPos[2] + 43)
		self:addCCNode(shipSprite)
		self.bulkLabel=createBMFont({text = "20/40", fontFile = FONT_CFG_1,size = 13, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), x=40, y= 8})
		self:addCCNode(self.bulkLabel)
	else
		self:addCCNode(display.newSprite("#market_no_ship.png",38, 35))
	end
	self.itemNode = UIWidget:create()
	self:addChild(self.itemNode)
	self:mkItem()
end

-- function CellCargo:onExit()
--     if self.item.good_info then
--         RemoveTextureForKey(self.item.good_info.res)
--     end
--     if self.resArmature then armatureManager:removeArmatureFileInfo(self.resArmature) end
-- end

local function find(values,value)
	for k,v in pairs(values) do
		if v == value then return true end
	end
end

local function checkPort(goods_id, port_area_id)
	if not port_area_id or not goods_id then return true end
	for k, v in ipairs(local_goods_info[port_area_id]) do
		if v == goods_id then
			return true
		end
	end
	return false
end

function CellCargo:mkItem(is_clear)
	local marketLayer = getUIManager():get("ClsPortMarket")
	self.itemNode:removeCCNode(true)
	self.item_effect_node = UIWidget:create()
	self.itemNode:addChild(self.item_effect_node)
	local good = self.item

	if is_clear or good.good_id <= 0 then
		if not tolua.isnull(self.bulkLabel) then
			self.bulkLabel:setString("0/" .. self.item.load)
		end
		good.good_id = 0
		return
	end
	local good_info = good.good_info
	if not tolua.isnull(self.bulkLabel) then
		self.bulkLabel:setString((good.amount + good.tradeAmount).. "/".. good.load)
	end
	local portData = getGameData():getPortData()
	local portGoods = port_goods_info[portData:getPortId()]
	if good.amount and good.amount ~= 0 then   --查找左边时候有这个货物 就不能买卖
		good.isHas = find(portGoods.common, good.good_id)
		if not good.isHas then
			good.isHas = find(portGoods.port, good.good_id)
		end
		if not good.isHas then
			good.isHas = find(portGoods.area, good.good_id)
		end
	end

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/market_sell.json")
	convertUIType(self.panel)
	self.panel:setPosition(ccp(heightCargoCell/2 + 45, 17))
	self.itemNode:addChild(self.panel)

	self.icon = getConvertChildByName(self.panel, "goods_icon")
	self.lableAmount = getConvertChildByName(self.panel, "goods_amont")
	local labelPrice = getConvertChildByName(self.panel, "goods_price")
	local goods_type = getConvertChildByName(self.panel, "goods_type")
	self.nameLabel = getConvertChildByName(self.panel, "goods_name")
	self.profitLabel = getConvertChildByName(self.panel, "goods_profit")
	local goods_silver = getConvertChildByName(self.panel, "goods_silver")

	local res = string.sub(good_info.res, 2)
	self.icon:changeTexture(res, UI_TEX_TYPE_PLIST)

	-- print(' --------------- test -------,good.can_sell',good.can_sell)
	-- good.can_sell = good.can_sell or 1
	-- self.is_can_sell = true
	-- if good.can_sell == 0 then
	--     self.is_can_sell = false
	--     self.icon:setGray(true)
	-- end

	local opacity=255
	if good.is_cur_area_good then
		opacity = HALF_OPACITY
	end

	self.icon:setOpacity(opacity)
	self.lableAmount:setOpacity(opacity)
	labelPrice:setOpacity(opacity)
	goods_type:setOpacity(opacity)
	self.nameLabel:setOpacity(opacity)
	self.profitLabel:setOpacity(opacity)
	goods_silver:setOpacity(opacity)

	--需求品牌子变化
	local lightSprite
	local mapAttrs = getGameData():getWorldMapAttrsData()
	local portToNeeds = mapAttrs:getPortNeed(portData:getPortId())
	local level = 0
	if goods_info[good.good_id] then
		level = goods_info[good.good_id].level
	end
	goods_type:setText(string.format(ui_word.PORT_GOOD_LEVEL, level, goods_type_info[good_info.class].name))
	good.isPortNeed = false
	if portToNeeds then
		for k,v in ipairs(portToNeeds) do
			if good_info.class == v then
				good.isPortNeed = true
				break
			end
		end
	end
	local power = getGameData():getPlayerData():getPower()
	if good.isPortNeed and not good.isHas and power > 0 and
		(good_info.breed ~= GOOD_TYPE_AREA) then--or (good_info.breed == GOOD_TYPE_AREA and not checkPort(good.good_id, portData:getPortAreaId())))then
		lightSprite = CCArmature:create("fire")
		lightSprite:getAnimation():playByIndex(0)
		lightSprite:setPosition(326, 55)
		self.item_effect_node:addCCNode(lightSprite)
	end

	--商品名字
	self.nameLabel:setText(good_info.name)

	local hot_prite = nil
	if good.is_hot == 1 then
		hot_prite = display.newSprite("#common_hotsell.png")
		hot_prite:setOpacity(opacity)
		self.itemNode:addCCNode(hot_prite)
		hot_prite:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(1, 1.3),CCScaleTo:create(0.8, 1)))
	end
	local xLen = 164
	
	---商会需要的商品
	-- local guild_research_data = getGameData():getGuildResearchData()
	-- local is_guild_need = guild_research_data:isGoodsGuildNeed(good_info.id)
	local guild_sprite = nil
	-- if is_guild_need then
	--     xLen = 190
	--     guild_sprite = getChangeFormatSprite("ui/txt/txt_goods_guild.png")
	--     guild_sprite:setScale(0.6)
	--     guild_sprite:setOpacity(opacity)
	--     self.itemNode:addCCNode(guild_sprite)
	-- end


	local tagSprite=nil
	local showTag = nil
	if good_info.breed == GOOD_TYPE_AREA then
		showTag = "#txt_common_goods_area.png"
	elseif good_info.breed == GOOD_TYPE_PORT then
		showTag = "#txt_common_goods_port.png"
	end

	if showTag then
		local width = self.nameLabel:getContentSize().width
		tagSprite = display.newSprite(showTag)
		tagSprite:setScale(0.6)
		tagSprite:setOpacity(opacity)
		self.itemNode:addCCNode(tagSprite)
	end

	
	adjustPos(hot_prite, tagSprite, guild_sprite, self.nameLabel, xLen, 75, true)

	--价钱
	labelPrice:setText(good.price * (good.amount + good.tradeAmount))

	if good_info.breed == GOOD_TYPE_PORT or good_info.breed == GOOD_TYPE_AREA then
		setUILabelColor(labelPrice, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
	end
	--利润
	good.base_price = good.base_price or good.price
	local profitPercent=math.floor(100 * good.price/good.base_price + 0.5)
	self.profitLabel:setText(profitPercent.."%")
	if profitPercent < 100 then
		setUILabelColor(self.profitLabel, ccc3(dexToColor3B(COLOR_RED_STROKE)))
	else
		setUILabelColor(self.profitLabel, ccc3(dexToColor3B(COLOR_GRASS_STROKE)))
	end
	--容量
	self.lableAmount:setText(good.tradeAmount + good.amount)

end

function CellCargo:onTap(x, y, toDeleteObj, is_auto)
	if self.item.good_id == 0 then
		return
	end
	if tolua.isnull(self.panel) then
		return
	end
	if self.item.is_cur_area_good then--当前海域的海域商品，不能卖
		if not is_auto then
			Alert:warning({msg = ui_word.PORT_MARKET_AREA_SELL_TIPS, size = 26})
		end
		return
	end

	-- if not self.is_can_sell then
	--     return
	-- end

	local marketLayer = getUIManager():get("ClsPortMarket")

	local icon_pos = self.icon:getPosition()--效果飞动
	local pos = self:convertToWorldSpace(ccp(icon_pos.x, icon_pos.y))

	if self.item.isHas then   --商店有这个货物
		if not self.item.canSell then  --不可以返还
			marketLayer:setAccountantTips(ui_word.PORT_MARKET_NOT_SELL_TIPS)
			-- return
		end
		if self.item.tradeAmount <= 0 and is_auto then return end
		--可以返还回去
		audioExt.playEffect(music_info.MARKET_OK.res)

		for cellKey, cell in pairs(marketLayer.store_list) do --还回去
			for spriteKey, sprite in pairs(cell.sprites) do
				if sprite.item.kind == 1 and sprite.item.id == self.item.good_id then
					sprite.item.tradeAmount = sprite.item.tradeAmount + self.item.tradeAmount + self.item.amount
					local total_amount = sprite.item.amount + sprite.item.tradeAmount
					total_amount = math.min(200, total_amount)
					sprite.item.tradeAmount = total_amount - sprite.item.amount
					sprite.amountLabel:setText(total_amount)
					marketLayer:setTradeValue(self.item.price, nil, -self.item.tradeAmount, self.item.profit, self.item.good_info)
					if self.item.amount > 0 then
						self.item.tradeAmount = 0
						self.item.canSell = false
					else
						marketLayer:moveGood(self.item.good_info.res, ccp(pos.x, pos.y + 15), ccp(360, pos.y + 15),0.3)
						self:mkItem(true)
						return
					end
				end
			end
		end
	end
	--效果指引处理
	audioExt.playEffect(music_info.COMMON_CASH.res)  --ui上处理
	marketLayer:moveGood(self.item.good_info.res,ccp(pos.x, pos.y + 15), ccp(360,pos.y + 15),0.3)

	--整一个格子货物卖出
	marketLayer:setTradeValue(nil, self.item.price, self.item.amount, self.item.profit, self.item.good_info)
	self.item.tradeAmount = - self.item.amount

	table.insert(marketLayer.items, table.clone(self.item))  --保存卖出的记录
	--TODO这里要看最新是否支持，2016.11.9
	marketLayer.cargoList:scrollToCellIndex(1)--
	if self.item.boat_type and self.item.boat_type > 0 then
		self:mkItem(true) --清空格子的商品
	else
		if ( toDeleteObj ) then
			table.insert(toDeleteObj, self)
		else
			marketLayer:delCargoCell(self)
		end
	end
end

function CellCargo:autoTap(toDeleteObj)
	if self.item.good_id == 0 then return end
	if self.item.isHas and self.item.canSell then
		--从左边售货点击过来的
		return
	end
	local pos = self:getWorldPosition()
	self:onTap(pos.x + 140, pos.y + 45, toDeleteObj, true)
end

local ListView = require("ui/tools/ListView")
local music_info = require("game_config/music_info")
local equip_material_info = require("game_config/boat/equip_material_info")
local equip_drawing_info = require("game_config/equip/equip_drawing_info")
local goods_info = require("game_config/port/goods_info")
local sailor_info = require("game_config/sailor/sailor_info")
local baowu_info = require("game_config/collect/baozang_info")
local item_info = require("game_config/propItem/item_info")
local plotVoiceAudio=require("gameobj/plotVoiceAudio")
local alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local collectCommon = {}
local math_floor = math.floor
collectCommon.picTable = {
	{name = "gold", res = "#common_icon_diamond.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_GOLD},
	{name = "royal", res = "#common_icon_honour.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_HONOUR}, -- royal
	{name = "honour", res = "#common_icon_honour.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_HONOUR}, -- honor
	{name = "silver", res = "#common_icon_coin.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_CASH},
	{name = "exp", res = "#common_icon_exp.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_EXP},
	{name = "power", res = "#common_icon_power.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_POWER},
	{name = "promote", res = "#bo_load.png", scale = {0.4,0.5}, type = "string"},
	{name = "starcrest", res = "#common_item_medal.png", scale = {0.4,0.5}, type = "number"},
	{name = "trearuse", res = "#common_item_trearusemap.png", scale = {0.4,0.5}, type = "number"}, 
	{name = "baowu", res = nil, scale = {0.4,0.5}, type = "string"},
	{name = "item", res = nil, scale = {0.4,0.5}, type = "string"},
	{name = "shipyard_map", res = "#common_item_letter.png", scale = {0.4,0.5}, type = "number"},
	{name = "rum", res = "#common_icon_honour.png", scale = {0.4,0.5}, type = "number", nameStr = ui_word.MAIN_HONOUR}
}

collectCommon.reward_type_to_config = {
	["baowu"] = baowu_info,
	["item"] = item_info,
}

function collectCommon:getRewardNum(data)
	local rewardNum = 0
	if not data or type(data) ~= "table" then
		return rewardNum
	end
	for i, v in ipairs(self.picTable) do
		local name = v.name
		if data[name] then
			rewardNum = rewardNum + 1
		end
	end

	return rewardNum
end

function collectCommon:createListView(layer, rect, listCellTab, showCell, direction)
	layer.list = ListView.new(rect, listCellTab, showCell, direction)
	layer.list:setTouchEnabled(true)
	layer:addChild(layer.list)
	return layer.list
end

function collectCommon:createReward(item)
	--direction:奖励内容的方向，有列方向和横方向竖向
	--direct_count:该方向上具有多少个奖励内容
	--例如，如果direction是横方向，direct_count则代表至多有多少排，
	--picType: 1为小图，2为大图
	
	local bgNode = display.newNode()--= item.bgNode
	item.bgNode:addChild(bgNode)
	bgNode.label = {}
	local data = item.data
	local posX = item.posX or 0
	local posY = item.posY or 0
	local direction = item.direction or DIRECTION_VERTICAL
	local direct_count = item.direct_count or 1
	local rowDetal = item.rowDetal or 120
	local colDetal = item.colDetal or 35 
	local index = item.index or 1
	local picType = item.picType or 2 
	local fontSize = item.fontSize or 16
	local picSize = item.picSize or 1
	local showNum = item.showNum
	local showName = item.showName
	local picWidth = item.picWidth or 40
	local fontSet = item.fontSet or {}
	local gapDx = item.gapDx or 10
	local nameGapDx = item.nameGapDx or 0
	local labelAbsoluteLayout = item.labelAbsoluteLayout
	fontSet.strFont = fontSet.strFont or FONT_COMMON
	fontSet.numFont = fontSet.numFont or FONT_COMMON
	fontSet.strSize = fontSet.strSize or 14
	fontSet.numSize = fontSet.numSize or 16
	fontSet.strColor = fontSet.strColor or COLOR_BROWN
	fontSet.numColor = fontSet.numColor or COLOR_GREEN
	local missionReward = data.reward_table

	local widthCount = 0
	
	local function createRewardItem(params)
		local bgNode = params.bgNode
		local res = params.res
		local val = params.val
		local name = params.name
		local x = params.x
		local y = params.y
		local scaleVal = params.scaleVal
		local scaleRes = params.scaleRes
		local row, col
		if direction == DIRECTION_VERTICAL then
			row =  math_floor((index - 1)/direct_count) + 1
			col = index - (row - 1)*direct_count
		elseif direction == DIRECTION_HORIZONTAL then
			col = math_floor((index - 1)/direct_count) + 1
			row = (index - direct_count*(col - 1))
		end
		
		local posX = x + (col-1)*rowDetal
		local posY = y - (row - 1)*colDetal
		index = index + 1
		
		local fieldScale = picSize
		
		local field = display.newSprite(res, posX, posY)
		if scaleRes then 
			field:setScale(scaleRes)
			fieldScale = scaleRes
		else		
			if scaleVal then
				local fiedWidth = field:getContentSize().width
				fieldScale = scaleVal / fiedWidth
			end
			field:setScale(fieldScale)
		end

		local field_label_x = 0
		if labelAbsoluteLayout then
			field_label_x = field:getPositionX() + field:getContentSize().width+gapDx
		else
			field_label_x = field:getPositionX() + field:getContentSize().width * fieldScale/2+gapDx
		end

		local name_label_x = 0
		if labelAbsoluteLayout then
			name_label_x = field:getPositionX() + field:getContentSize().width+nameGapDx
		else
			name_label_x = field:getPositionX() + field:getContentSize().width * fieldScale/2+nameGapDx
		end

		local field_num
		local field_label
		if type(val) == "string" then
			
			field_num = string.format("%s", val)
			field_label = createBMFont({text = field_num, fontFile = fontSet.strFont, size = fontSet.strSize, 
			color = ccc3(dexToColor3B(fontSet.strColor)), x = field_label_x, y = posY})
		elseif type(val) == "number" then 
			field_num = string.format("%d", val)
			field_label = createBMFont({text = field_num, fontFile = fontSet.numFont, size = fontSet.numSize, 
			color = ccc3(dexToColor3B(fontSet.numColor)), x = field_label_x, y = posY})
		end
		if showNum~=nil then
			field_label:setVisible(showNum)
		end
		field_label:setAnchorPoint(ccp(0, 0.5))
		bgNode:addChild(field)
		bgNode:addChild(field_label)

		if name and showName then
			local name_label = createBMFont({text = name, fontFile = fontSet.strFont, size = fontSet.strSize, 
			color = ccc3(dexToColor3B(fontSet.strColor)), x = name_label_x, y = posY})
			name_label:setAnchorPoint(ccp(0, 0.5))
			bgNode:addChild(name_label)
		end

		if bgNode.label == nil then bgNode.label = {} end
		bgNode.label[#bgNode.label + 1] = field_label

		local width = field_label:getContentSize().width + field:getContentSize().width * fieldScale + gapDx + nameGapDx
		if direction == DIRECTION_HORIZONTAL then
			widthCount = width + widthCount
		else
			if width > widthCount then
				widthCount = width
			end
		end
	end	

	local function getRewardNameStr(nameType, nameValue)
		local is_exp = false
		local nameStr = ""
		if not nameType then
			return nameStr
		end

		if nameType == "gold" then
			nameStr = ui_word.MAIN_GOLD
		elseif nameType == "royal" then
			nameStr = ui_word.MAIN_HONOUR
		elseif nameType == "rum" then
			nameStr = ui_word.MAIN_HONOUR
		elseif nameType == "silver" then
			nameStr = ui_word.MAIN_CASH
		elseif nameType == "exp" then
			nameStr = ui_word.MAIN_EXP
			is_exp = true
		elseif nameType == "power" then
			nameStr = ui_word.MAIN_POWER
		elseif nameType == "seaman" then
			
		end

		return nameStr, is_exp
	end

	for i, v in ipairs(self.picTable) do
		local name = v.name
		local res = v.res
		local scale = v.scale[picType]
		local strType = v.type
		local config = self.reward_type_to_config[name]
		if data[name] then 
			local text 
			local nameText, is_exp = getRewardNameStr(name)
			if item.extraText ~= nil and item.extraText[name] ~= nil then
				text = item.extraText[name]..data[name]
			else
				text = data[name]
			end
			if is_exp then
				text = getGameData():getBuffStateData():getExpUpResult(text)
			end
			if strType == "string" then
				if type(data[name]) == "table" then
					if config then
						res = config[text.id].res
						nameText = config[text.id].name
					end
					text = text.amount
					createRewardItem({bgNode = bgNode, name = nameText, res = res, val = text, x = posX, y = posY, scaleRes= scale})
				elseif string.len(data[name]) ~= 0 then
					if config then
						text = config[toint(text)].name
					end
					createRewardItem({bgNode = bgNode, name = nameText, res = res, val = text, x = posX, y = posY, scaleRes= scale})
				end
			else
				if type(data[name]) == "table" then
					if config then
						res = config[text.id].res
						nameText = config[text.id].name
					end
					text = text.amount
				end
				createRewardItem({bgNode = bgNode, name = nameText, res = res, val = tonumber(text), x = posX, y = posY, scaleRes= scale})
			end
		end
	end
	
	if missionReward ~= nil then
		for i = 1, #missionReward do
			local rt = missionReward[i]
			local res = nil
			if rt.type == "material" then
				res = equip_material_info[rt.id].res
			elseif rt.type == "sailor" then
				res = sailor_info[rt.id].res
			elseif rt.type == "darwing" then
				res = equip_drawing_info[rt.id].res
			elseif rt.type == "goods" then
				res = goods_info[rt.id].res
			elseif rt.type == "exp" then
				res = "#common_icon_exp.png"
			elseif rt.type == "cash" then
				res = "#common_icon_coin.png"
			elseif rt.type == "gold" then
				res = "#common_icon_diamond.png"
			end
			createRewardItem({bgNode = bgNode, res = res, val = tonumber(rt.amount), x = posX, y = posY, scaleVal = picWidth})
		end
	end
	
	return posX,bgNode,widthCount
end

function collectCommon:getRewarItemCfgByLootTable(Loot_table)
	local configs = {}

	if Loot_table==nil then
		return configs
	end
	
	for i = 1, #Loot_table do
		local rt = Loot_table[i]
		local config = nil
		if rt.type == "material" then
			config = equip_material_info[rt.id]
		elseif rt.type == "sailor" then
			config = sailor_info[rt.id]
		elseif rt.type == "darwing" then
			config = equip_drawing_info[rt.id]
		elseif rt.type == "goods" then
			config = goods_info[rt.id]
		end
		if config~=nil then
			configs[#configs+1] = table.clone(config)
		end
	end
	return configs
end

function collectCommon:parseRandomRewardFromRandomLootTable(configItemId) --参数random_loot 表的Id
	
	local random_loot_info = require("game_config/random/random_loot_info")
	local randomInfo = random_loot_info[configItemId]
	if randomInfo == nil or randomInfo.loot_table == nil then
		cclog(T("配置表为空==========================="))
		return
	end
	local mode = randomInfo.mode
	local lootTable = randomInfo.loot_table
	local configTable = {}

	for i = 1, #lootTable do
		local rt = lootTable[i]
		local item = {}
		local config = nil
		if rt.type == "material" then
			config = equip_material_info[tonumber(rt.id)]
			item.type = ITEM_INDEX_MATERIAL
		elseif rt.type == "sailor" then
			config = sailor_info[tonumber(rt.id)]
			item.type = ITEM_INDEX_SAILOR
		elseif rt.type == "goods" then
			config = goods_info[tonumber(rt.id)]
			item.type = ITEM_INDEX_GOODS
		elseif rt.type == "exp" then
			item.type = ITEM_INDEX_EXP
		elseif rt.type == "honour" then
			item.type = ITEM_INDEX_HONOUR
		elseif rt.type == "cash" then
			item.type = ITEM_INDEX_CASH
			config = {}
			config.name = ui_word.MAIN_CASH -- "银币"
			config.res = "#common_icon_coin.png"
		elseif rt.type == "item" then
			item.type = ITEM_INDEX_PROP
			local item_info = require("game_config/propItem/item_info")
			config = item_info[rt.id]
		elseif rt.type == "status" then
			item.time = rt.time
			item.type = ITEM_INDEX_STATUS
		elseif rt.type == "food" then
			item.type = ITEM_INDEX_FOOD
			config = {}
			config.name = ui_word.REWARD_FOOD_TIPS -- "食物"
			config.res = "#explore_food.png"
		end
		item.typeStr = rt.type
		item.config = config
		item.id = rt.id or 0
		item.id = tonumber(item.id)
		item.random = rt.random or 0
		item.random = tonumber(item.random)
		item.amount = rt.amount or 0
		item.amount = tonumber(item.amount)
		configTable[#configTable + 1] = item
	end
	return configTable, mode

end


function collectCommon:createRewardForRewardDlg(item)
    -- 实现和createReward基本一致：为了需求#11307 [20140612]通用提示框UI优化
	-- 区别在于创建出来的信息放在底板的中间
	-- [todo]:需要重构，和createReward代码大部分重复
	local bgNode = display.newNode()--= item.bgNode
	item.bgNode:addChild(bgNode)
	local data = item.data
	local posX = item.posX or 0
	local posY = item.posY or 0
	local direction = item.direction or DIRECTION_VERTICAL
	local direct_count = item.direct_count or 1
	local rowDetal = item.rowDetal or 120
	local colDetal = item.colDetal or 40 
	local index = item.index or 1
	local picType = item.picType or 2 
	local fontSize = item.fontSize or 16
	local picSize = item.picSize or 1
	local fontSet = item.fontSet or {}
	fontSet.strFont = fontSet.strFont or FONT_COMMON
	fontSet.numFont = fontSet.numFont or FONT_COMMON
	fontSet.strSize = fontSet.strSize or 14
	fontSet.numSize = fontSet.numSize or 20
	fontSet.strColor = fontSet.strColor or COLOR_BROWN
	fontSet.numColor = fontSet.numColor or COLOR_GREEN

	local rewardCount = 0
	for key, val in pairs(data) do
        local reward_t = {"royal", "honor", "silver", "exp", "gold", "seaman", "boat", "promote", "equip", "treasure", "shipyard_map"}
        for _, v in pairs(reward_t) do
            if key == v and val ~= '' then 
                rewardCount = rewardCount + 1
            end
        end
	end
	local coord = {}
	if rewardCount == 1 then 
		coord[1] = ccp(204,115)
	end
	if rewardCount == 2 then
		coord[1] = ccp(204, 130)
		coord[2] = ccp(204, 90)
	end
	
	local widthCount = 0
	
	local function createRewardItem(params)
		local bgNode = params.bgNode
		local val = params.val
		local x = params.x
		local y = params.y
		local res = params.res
		local scaleRes = params.scaleRes
		
		local posX = x
		local posY = y
		local field = display.newSprite(res)
        
		field:setScale(picSize)
		if res == "#common_item_trearusemap.png" then		--暂时做特殊处理，因为暂时没相应图标
			field:setScale(0.5)
		end
		
        local field_size = field:getContentSize()
        local scaleX, scaleY = field:getScaleX(), field:getScaleY()
        local field_real_size = CCSize(field_size.width*scaleX, field_size.height*scaleY)


        local field_num
		local field_label
		local gapDx = 10
		if type(val) == "string" then
			field_num = string.format("%s", val)
			field_label = createBMFont({text = field_num, fontFile = fontSet.strFont, size = fontSet.strSize, color = ccc3(dexToColor3B(fontSet.strColor))})
		elseif type(val) == "number" then 
			field_num = string.format("%d", val)
			field_label = createBMFont({text = field_num, fontFile = fontSet.numFont, size = fontSet.numSize , color = ccc3(dexToColor3B(fontSet.numColor))})
		end
		bgNode:addChild(field)
		bgNode:addChild(field_label)
		if bgNode.label == nil then bgNode.label = {} end
		bgNode.label[#bgNode.label + 1] = field_label

		local width = field_label:getScaledContentSize().width + field:getContentSize().width * picSize + gapDx
        
		if width > widthCount then
			widthCount = width
		end
		
        field:setAnchorPoint(ccp(0, 0.5))
		field_label:setAnchorPoint(ccp(0, 0.5))
        field:setPosition(posX - width/2, posY)
        field_label:setPosition(field:getPositionX() + field:getContentSize().width + gapDx, posY)
        return widthCount
	end	
	
	local posI = 1
	for i, v in ipairs(self.picTable) do
		local name = v.name
		local res = v.res
		local scale = v.scale[picType]
		local strType = v.type
		if data[name] then 
			local text 
			if item.extraText ~= nil and item.extraText[name] ~= nil then
				text = item.extraText[name]..data[name]
			else
				text = data[name]
			end
			if strType == "string" then
				if string.len(data[name]) ~= 0 then
					if name == "equip" then
						print("=====================equip_info已删除，查下怎么出来的")
					end
					local posX, posY = coord[posI].x,coord[posI].y
					createRewardItem({bgNode = bgNode, res = res, val = text, x = posX, y = posY, scaleRes= scale})
					posI = posI + 1
				end
			else
				local posX, posY = coord[posI].x,coord[posI].y
				createRewardItem({bgNode = bgNode, res = res, val = tonumber(text), x = posX, y = posY, scaleRes= scale})
				posI = posI + 1
			end
		end
	end

	return posX,bgNode,widthCount
end

return collectCommon

--
local valMenuItem = require("ui/tools/valMenuItem")
local RelicAnswers = require("game_config/collect/relic_answers")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local commonBase  = require("gameobj/commonFuns")
local music_info = require("game_config/music_info")
local relic_info = require("game_config/collect/relic_info")
local relic_star_info = require("game_config/collect/relic_star_info")
local tips = require("game_config/tips")
local typeCollection ={ TYPE_FRIEND = 1, TYPE_SELF = 0, type = 0}
local relic_image_ZOrder = 10
local armatureManager = CCArmatureDataManager:sharedArmatureDataManager()
local compositeEffect = require("gameobj/composite_effect")
local RelicPanelView = {}

function RelicPanelView:spliteString(str, number)
	local strTable = {}
	local strLen = commonBase:utfstrlen(str)
	local reminder = strLen % number
	local n = 0
	if reminder == 0 then
		n = math.floor(strLen / number)
	else
		n = math.floor(strLen / number) + 1
	end
	local startIndex = 1
	for i = 1, n do
		local tmpStr = commonBase:utf8sub(str, startIndex, number)
		startIndex = startIndex + number
		strTable[#strTable + 1] = tmpStr
	end
	return strTable
end

--遗迹建筑按钮回调
function RelicPanelView:exploreRelicBtnClicked(relicValue)
end

--创建遗迹的进入按钮(只有一个地方用到)
function RelicPanelView:createExploreImage(relicValue, pos, parent)
	local relicData = relicValue.relicInfo
	--按钮
	local name = ui_word.BOAT_RELIC_VIEW_TITLE
	name_bg_str = "#explore_name1.png"
	local relicEventBtn = display.newSprite(name_bg_str)
	relicEventBtn:setPosition(pos.x, pos.y)

	local relicNameLabel = createBMFont({text = tostring(name), size = 24, color=ccc3(dexToColor3B(COLOR_CREAM_STROKE))})
	relicNameLabel:setAnchorPoint(ccp(0.5, 0.5))
	relicEventBtn:addChild(relicNameLabel, 5)
	local size = relicEventBtn:getContentSize()
	relicNameLabel:setPosition(size.width/2, size.height/2 + 8)
	parent:addChild(relicEventBtn)

	return relicEventBtn
end

function RelicPanelView:updateExploreRelic(relics_tab, toPos, ship_x, ship_y, parent)
	for k, relic_info_item in pairs(relic_info) do
		local relic_ui_item = relics_tab[k]
		local relic_pos = toPos(ccp(relic_info_item.world_coord[1], relic_info_item.world_coord[2]))
		local max_dis_n = 921600  -- 960*960
		local now_dis_n = math.pow(relic_pos.x - ship_x, 2) + math.pow(relic_pos.y - ship_y, 2)
		if now_dis_n <= max_dis_n then
			--在发现半径内
			if not relic_ui_item then
				local target_relic_info = {}
				target_relic_info.id = k
				target_relic_info.relicInfo = relic_info_item
				local name_pos = toPos(ccp(relic_info_item.name_pos[1], relic_info_item.name_pos[2]))
				local relic_btn = self:createExploreImage(target_relic_info, name_pos, parent)
				relics_tab[k] = relic_btn
			end
		else
			--不在发现半径内，去掉
			if relic_ui_item and (not tolua.isnull(relic_ui_item)) then
				relic_ui_item:removeFromParentAndCleanup(true)
			end
			relics_tab[k] = nil
		end
	end
end

--创建航船气泡的
function RelicPanelView:createRelicAirBubbles(relicData, parent, pos, target_pos, my_shop)
	local sPos = ccp(pos.x - 60, pos.y + 115)
	local mPos = ccp(pos.x - 80, pos.y + 140)
	local bPos = ccp(pos.x - 100, pos.y + 195)
	if not tolua.isnull(self.actionLayer) then
		self.AirSmallSprite:setPosition(sPos)
		self.AirMiddleSprite:setPosition(mPos)
		self.AirBigSprite:setPosition(bPos)
		return
	else
		local tipId = 164
		local relicName = relicData.relicInfo.name
		EventTrigger(EVENT_EXPLORE_SHOW_DIALOG, {tip_id = tipId}, tostring(relicName))

		self.actionLayer = display.newLayer()
		self.actionLayer:setPosition(ccp(0, 0))
		if relicData == nil then
			return
		end
		local relicInfo = relicData.relicInfo

		local smallSprite = display.newSprite("#airbubble_small.png", sPos.x, sPos.y)
		self.AirSmallSprite = smallSprite
		local middleSprite = display.newSprite("#airbubble_middle.png", mPos.x, mPos.y)
		self.AirMiddleSprite = middleSprite
		local bigSprite = display.newSprite("#airbubble_big.png", bPos.x, bPos.y)
		self.AirBigSprite = bigSprite

		local bigSpriteSize = bigSprite:getContentSize()
		local base_arrow_ui = display.newSprite()
		base_arrow_ui:setPosition(ccp(bigSpriteSize.width / 2, bigSpriteSize.height / 2))
		bigSprite:addChild(base_arrow_ui, 10)
		self.ArrowSprite = base_arrow_ui

		local arrow_eff = nil
		arrow_eff = compositeEffect.new("tx_0082", 51, 0, base_arrow_ui, nil, function()
				arrow_eff:removeFromParentAndCleanup(true)
				arrow_eff:removeTexture()
			end)
		arrow_eff:setZOrder(5)

		local relicSprite = getChangeFormatSprite("ui/yiji/" .. relicInfo.res)
		relicSprite:setScale(0.1)
		relicSprite:setPosition(ccp(bigSpriteSize.width / 2, bigSpriteSize.height / 2))
		bigSprite:addChild(relicSprite)

		self.actionLayer:addChild(bigSprite, 3)
		self.actionLayer:addChild(smallSprite, 1)
		self.actionLayer:addChild(middleSprite,2)
		self.AirSmallSprite:setVisible(false)
		self.AirBigSprite:setVisible(false)
		self.AirMiddleSprite:setVisible(false)
		parent:addChild(self.actionLayer)
		--
		local actions = CCArray:create()
		local function start()
			self.AirSmallSprite:setVisible(false)
			self.AirBigSprite:setVisible(false)
			self.AirMiddleSprite:setVisible(false)
		end
		local funcCallBack = CCCallFunc:create(start)
		actions:addObject(funcCallBack)

		local function sCallBack()
			self.AirSmallSprite:setVisible(true)
		end
		funcCallBack = CCCallFunc:create(sCallBack)
		actions:addObject(funcCallBack)

		local function mCallBack()
			self.AirMiddleSprite:setVisible(true)

		end
		local time = 0.6
		local deAction = CCDelayTime:create(time)
		actions:addObject(deAction)
		funcCallBack = CCCallFunc:create(mCallBack)
		actions:addObject(funcCallBack)

		local function bCallBack()
			self.AirBigSprite:setVisible(true)
			local x, y = my_shop:getPos()
			x = bPos.x + x
			y = bPos.y + y
			local dis_n = Math.distance(x, y, target_pos[1], target_pos[2])
			local angle_n = math.abs(math.deg(math.acos((target_pos[1] - x)/dis_n)))
			if target_pos[2] > y then
				angle_n = - 1 * angle_n + 360
			end
			self.ArrowSprite:runAction(CCRotateTo:create(0.001, angle_n))
		end
		deAction = CCDelayTime:create(time)
		actions:addObject(deAction)
		funcCallBack = CCCallFunc:create(bCallBack)
		actions:addObject(funcCallBack)
		deAction = CCDelayTime:create(time + 0.3)
		actions:addObject(deAction)
		local action = CCSequence:create(actions)

		local repaeat = CCRepeatForever:create(action)
		self.actionLayer:runAction(repaeat)
	end

end

function RelicPanelView:getActionLayer()
	return self.actionLayer
end

return RelicPanelView

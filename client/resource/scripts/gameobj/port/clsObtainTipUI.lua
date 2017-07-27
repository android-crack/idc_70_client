-- @author: mid
-- @date: 2016年11月17日9:18:06
-- @desc: 市政厅 投资界面 提升投资级别 升级效果

-- include
local alert = require("ui/tools/alert")
local boat_attribute = require("game_config/boat/boat_attr")
local boat_info = require("game_config/boat/boat_info")
local CompositeEffect = require("gameobj/composite_effect")
local goods_info = require("game_config/port/goods_info")
local goods_type_info=require("game_config/port/goods_type_info")
local item_info = require("game_config/propItem/item_info")
local music_info=require("game_config/music_info")
local port_info = require("game_config/port/port_info")
local port_lock = require("game_config/port/port_lock")
local port_reward_info = require("game_config/port/port_reward_info")
local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local UiCommon = require("ui/tools/UiCommon")


local scheduler = CCDirector:sharedDirector():getScheduler()

-- const value define
-- 特效资源
local effect_res_table = {
	"tx_0133_green",
	"tx_0133_blue",
	"tx_0133_purple",
	"tx_0133_orange",
}
local SCALE_VALUE_OF_CARD_PANEL = 0.6
local SCALE_VALUE_OF_PRESTIGE_EFFECT = 0.6
local SCALE_VALUE_OF_GOODS_ICON = 1.3

-- logic
local clsObtainTipUI = class("clsObtainTipUI", require("ui/view/clsBaseView"))

-- override
function clsObtainTipUI:onEnter(data)
	local port_id,pre_power = data.port_id,data.pre_power
	self.port_id = port_id
	self.pre_power = pre_power or 0
	self.callback = data.callback
	self.callback1 = data.callback1
	self.is_can_close = false
	self:initData()
	self:initUI()
	self:updateUI()
end



-- 数据初始化
function clsObtainTipUI:initData()

	self.plist = {
		["ui/hotel_ui.plist"] = 1,
		["ui/cityhall_ui.plist"] = 1,
	}
	LoadPlist(self.plist)
	-- data
	local data = getGameData():getInvestData():getInvestDataByPortId(self.port_id)
	local lv = data.investStep
	local port_id = data.portId
	local lock_data = port_lock[port_id][lv]

	local _type = nil
	local key = nil

	-- 获得类型
	if lock_data.lock then
		-- "goods"
		_type = lock_data.lock.type
	else
		key = string.format(" %d_%d",port_id,lv)
		local port_reward_data = port_reward_info[key]
		_type = port_reward_data.type
		-- boat honour item material sailor
	end

	self.data = {}
	self.data.lv = lv
	self.data.port_id = port_id
	self.data.lock_data = lock_data
	self.data._type = _type
	self.data.key = key
	self.data.id = 0 -- 用于水手类型特殊判断
end

-- UI 初始化
function clsObtainTipUI:initUI()

	-- load json
	self.card_panel = GUIReader:shareReader():widgetFromJsonFile("json/hotel_card.json")
	convertUIType(self.card_panel)

	-- 黑色底图
	self.bg = CCLayerColor:create(ccc4(0, 0, 0, 196))
	self.bg:setTouchEnabled(false)

	local function bg_touch_close_callback()
		if self.is_can_close then
			self:close()
		end
	end
	self:regTouchEvent(self.bg, bg_touch_close_callback, TOUCH_BG_ORDER)


	self:addChild(self.bg,-1,-1)

	self:addWidget(self.card_panel)

	-- 等级提升特效节点
	self.node_inverst_level_up_effect = UIWidget:create()
	self:addWidget(self.node_inverst_level_up_effect)

	-- 声望提升特效节点
	self.node_effect_prestige = UIWidget:create()
	self:addWidget(self.node_effect_prestige)

	self.card_panel:setVisible(false,false)
	self.card_panel:setScale(SCALE_VALUE_OF_CARD_PANEL)

	local function initCardUI()
		local wgts = {
			["bg"] = "card_back", -- 卡片背面
			["effect"] = "card_panel", -- 特效层?
		}
		for k,v in pairs(wgts) do
			self.card_panel[k] = getConvertChildByName(self.card_panel,v)
		end
		self.card_panel:setPosition(ccp(display.width*0.5 - self.card_panel:getContentSize().width*0.5*SCALE_VALUE_OF_CARD_PANEL + 70, display.height*0.5-self.card_panel:getContentSize().height*0.5*SCALE_VALUE_OF_CARD_PANEL + 50))
		self.card_panel.bg:setVisible(true)

		local _type = self.data._type
		if _type == "goods" then
			self:initGoodsUI(self:parseGoodsUIData())
		elseif _type == "item" then
			self:initPropUI(self:parsePropUIData())
		elseif _type == "sailor" then
			self:initSailorUI(self:parseSailorUIData())
		elseif _type == "honour" then
			self:initPropUI(self:parseWineData())
		end
	end
	initCardUI()
end

-- 播放投资等级提升特效
function clsObtainTipUI:playInverstLevelUpEffect()
	-- local function callback()
	-- end
	local wgt = self.node_inverst_level_up_effect
	wgt:removeAllChildren()

	local effect_layer = UIWidget:create()
	wgt:addChild(effect_layer)
	local effect = CompositeEffect.new("tx_txt_port_upgrade", display.cx + 70, display.cy*2+ 190, effect_layer, nil, nil, nil, nil, true)
end

-- 播放翻盘特效 自动关闭UI倒计时也放这里
function clsObtainTipUI:playFlopEffect()
	-- 关闭
	local function close_callback()
		-- local target_ui = getUIManager():get("clsPortTownUI")
		-- if not tolua.isnull(target_ui) then
		-- 	target_ui:updateUI(1)
		-- end
		-- self:close()
		self.is_can_close = true

	end


	-- 卡片背面图片 一段时间后 渐隐 执行回调
	-- 卡片正面图片 一段时间后 缩放x为原本缩放系数的1倍  执行回调


	local change_visible_op_1 = CCCallFunc:create(function ()
		self.card_panel.bg:setVisible(false)
		self.card_panel.panel:setVisible(true)
	end)
	-- 一点延时
	local change_visible_op_2 = CCDelayTime:create(0.01)

	-- 播放翻牌特效
	local flop_op_1 = CCCallFunc:create(function ()
		local wgt = self.card_panel.effect
		wgt:removeAllChildren()
		local effect_layer = UIWidget:create()
		effect_layer:setPosition(ccp(166,220))
		wgt:addChild(effect_layer)

		-- 翻牌特效回调函数
		local function flop_effect_callback()
			-- print(" 播放声望 ------- ")
			-- 播放升级特效
			self:playPrestigeEffect()

			-- 判断是否是水手 如果是已经获得的水手 将水手转为星章
			if self.data._type =="sailor" then
				if self.data.id then
					if getGameData():getSailorData():getOwnSailors()[self.data.id] ~= nil then
						-- print(" ---------------- 将水手转为星章 ---------- ",self.data.id)
						-- table.print(getGameData():getSailorData():getOwnSailors()[self.data.id])

						local reward_list = getGameData():getSailorData():getRecruitSailorReward()

						-- test data 里斯本 港口投资3级
						-- reward_list =
						-- {
						-- 	[34] = {
						-- 		[1] = {
						-- 			["amount"] = 10.000000,
						-- 			["id"] = 50.000000,
						-- 			["memoJson"] = "",
						-- 			["type"] = 15.000000,
						-- 			},
						-- 		},
						-- }


						-- print(" ------------ reward_list ")
						-- for k,v in pairs(reward_list) do
							-- print(k,v)
						-- end

						local size = 0
						for k,v in pairs(reward_list) do
							size = size + 1
						end

						-- 容错处理 服务器暂时有莫名回到里斯本的bug QC说
						local is_bug = true
						if size > 0 then
							-- print("--------------check reward_list ")
							if self.data then
								if self.data.id then
									if reward_list[self.data.id] then
										if reward_list[self.data.id][1] then
											is_bug = false
										end
									end
								end
							end
							if is_bug then print("--- invest tab prot_id error --") end
						end

						-- print("reward_list")
						-- table.print(reward_list)
						-- print("type",type(reward_list))
						-- print("is_bug",is_bug)

						-- 奖励内容不为空
						if size > 0 and not is_bug then
							local icon_str, amount, scale, name = getCommonRewardIcon(reward_list[self.data.id][1])
							-- 转为道具类型的结构
							local t = {}
							t.name = name
							t.res = icon_str
							t.name_num = string.format("%s * %s",t.name,amount)
							-- 转为道具类型界面
							self:setVisibleByCardType("prop")
							self:initPropUI(t)
							self.card_panel.panel:setScaleX(1) -- 缩放重置.
						end
					else
						print("error flop_effect_callback")
					end
				end
			end

			-- 自动关闭按钮倒计时
			local close_op_1 = CCDelayTime:create(1.6)
			-- 关闭函数回调
			local close_op_2 = CCCallFunc:create(close_callback)

			local arr = CCArray:create()
			arr:addObject(close_op_1)
			arr:addObject(close_op_2)

			self.card_panel.bg:stopAllActions()
			self.card_panel.bg:runAction(CCSequence:create(arr))
		end

		local effect = CompositeEffect.new("tx_0153",0,0, effect_layer, 1.6,flop_effect_callback, nil, nil,true)
		effect:setScale(1.6)
	end)

	local arr = CCArray:create()
	-- arr:addObject(a1)
	arr:addObject(change_visible_op_1)
	arr:addObject(change_visible_op_2)
	arr:addObject(flop_op_1)
	self.card_panel.bg:runAction(CCSequence:create(arr))

	local arr2 = CCArray:create()
	a1 = CCScaleTo:create(0.4,1,1)

	arr2:addObject(a1)

	self.card_panel.panel:runAction(CCSequence:create(arr2))
end

-- 播放声望特效
function clsObtainTipUI:playPrestigeEffect()
	local function callback( )
		-- print(debug.traceback())
		-- print(" ------------------- callback 声望")
	end
	local end_num = getGameData():getPlayerData():getBattlePower()
	local start_num = self.pre_power
	local show_time = 1.2

	-- 只显示增加的声望值
	local effect_ui = self:createPrestigeEffectUI(math.abs(end_num - start_num),nil, show_time, callback)
	local pos = ccp(display.cx-250, display.cy-320)

	local effect_layer = UIWidget:create()
	effect_layer:setPosition(pos)
	effect_layer:addChild(effect_ui)
	effect_layer:setScale(0.7)

	local wgt = self.node_effect_prestige
	wgt:removeAllChildren()
	wgt:addChild(effect_layer)

end

-- 解析货物类型数据
function clsObtainTipUI:parseGoodsUIData()

	local data = self.data
	local t = {}
	local goods_data = goods_info[data.lock_data.lock.id]

	-- 商品图片资源
	t.res = goods_data.res
	t.name = goods_data.name
	-- 商品等级信息
	t.lv = string.format(ui_word.PORT_GOOD_LEVEL, goods_data.level, goods_type_info[goods_data.class].name)
	-- 商品类型描述: 普通/特产
	t.type = ui_word.PORT_NORMAL_GOOD
	if goods_data.breed == GOOD_TYPE_AREA then
		t.type = ui_word.PORT_AREA_GOOD
		t.logo_img_res = "txt_common_goods_area.png"
	elseif goods_data.breed == GOOD_TYPE_PORT then
		t.type = ui_word.PORT_PORT_GOOD
		t.logo_img_res = "txt_common_goods_port.png"
	end
	-- 是否特产
	t.is_special = (t.type ~= ui_word.PORT_NORMAL_GOOD)

	return t
end

-- 初始化卡牌UI 货物类型
function clsObtainTipUI:initGoodsUI(data)
	local wgts = {
		["panel"] = "card_goods", -- 商品面板
		["icon"] = "goods_icon", -- 图标
		["logo"] = "special_icon", -- 特产图标
		["name"] = "goods_name", -- 名字
		["lv"] = "goods_type", -- 级别
		["type"] = "goods_special", -- 类型
	}
	local card_panel = self.card_panel
	for k,v in pairs(wgts) do
		card_panel[k] = getConvertChildByName(card_panel,v)
	end

	card_panel.panel:setVisible(true)
	card_panel.panel:setScaleX(0)
	local res = convertResources(data.res)
	card_panel.icon:changeTexture(res, UI_TEX_TYPE_PLIST)
	card_panel.icon:setScale(1/SCALE_VALUE_OF_CARD_PANEL * SCALE_VALUE_OF_GOODS_ICON)
	card_panel.logo:setVisible(data.is_special)
	card_panel.logo:changeTexture(data.logo_img_res,UI_TEX_TYPE_PLIST)
	card_panel.name:setText(data.name)
	card_panel.lv:setText(data.lv)
	card_panel.type:setText(data.type)
end

-- 解析道具数据
function clsObtainTipUI:parsePropUIData()
	local data = self.data
	local t = {}
	local prop_data = port_reward_info[data.key]
	t.res = item_info[prop_data.id].res
	t.name_num = prop_data.memo
	return t
end

-- 初始化卡牌UI 道具类型
function clsObtainTipUI:initPropUI(data)
	local wgts = {
		["panel"] = "card_item", -- 道具面板
		["icon"] = "item_icon", -- 图标
		["name_num"] = "item_name", -- 名字*数量
	}
	local card_panel = self.card_panel
	for k,v in pairs(wgts) do
		card_panel[k] = getConvertChildByName(card_panel,v)
	end
	card_panel.panel:setVisible(true)
	card_panel.panel:setScaleX(0)
	local res = data.res
	if string.find(res, "#") == 1 then
		local tmp_res = string.sub(res, 2)
		card_panel.icon:changeTexture(tmp_res,UI_TEX_TYPE_PLIST)
	end
	card_panel.name_num:setText(data.name_num)
end

-- 解析水手数据
function clsObtainTipUI:parseSailorUIData()
	local data = self.data
	local t = {}
	local reward_sailor_data = port_reward_info[data.key]
	-- local sailor_data = getGameData():getSailorData():getOwnSailors()[reward_sailor_data.id]
	local id = reward_sailor_data.id
	self.data.id = id
	local sailor_data = sailor_info[id]

	t.name = sailor_data.name
	t.res = sailor_data.res
	t.lv = STAR_SPRITE_RES[sailor_data.star].big

	-- 判断是否是已有的水手,如果已有,则用已有水手存放的星级数据 如果不是 则为1星,配置表里的弃用目前.

	if getGameData():getSailorData()[id] ~= nil then
		-- t.star = sailor_data.star
		t.star = 1 -- 又改回去了..都是显示1星
	else
		t.star = 1
	end
	t.job = JOB_RES[sailor_data.job[1]]
	return t
end

-- 重新设置可见属性
function clsObtainTipUI:setVisibleByCardType(card_type)
	local wgts = {
		["sailor"] = "card_sailor", -- 水手面板
		["prop"] = "card_item", -- 道具面板
		["goods"] = "card_goods", -- 货物面板
		["bg"] = "card_back", -- 卡片背面
	}
	local card_panel = self.card_panel
	for k,v in pairs(wgts) do
		card_panel[k] = getConvertChildByName(card_panel,v)
		card_panel[k]:setVisible(card_type == k)
	end
end

-- 初始化卡牌UI 水手界面
function clsObtainTipUI:initSailorUI(data)
	local wgts = {
		["panel"] = "card_sailor", -- 水手面板
		["icon"] = "sailor_pic", -- 图标
		-- ["stat"] = "star_2", -- 星级
		["lv"] = "sailor_lv", -- 级别
		["job"] = "sailor_job", -- 职业类型
		["name"] = "sailor_name", -- 名字
	}
	-- 星级
	local card_panel = self.card_panel
	for k,v in pairs(wgts) do
		card_panel[k] = getConvertChildByName(card_panel,v)
	end
	card_panel.panel:setVisible(true)
	card_panel.panel:setScaleX(0)
	card_panel.star = {}
	for i=1,5 do
		card_panel.star[i] = getConvertChildByName(card_panel,string.format("star_%d",i))
		card_panel.star[i]:setVisible(i<=data.star)
	end
	card_panel.icon:changeTexture(data.res)
	card_panel.name:setText(data.name)
	card_panel.lv:changeTexture(data.lv ,UI_TEX_TYPE_PLIST)
	card_panel.job:changeTexture(data.job,UI_TEX_TYPE_PLIST)
end

-- 解析朗姆酒数据 使用道具的界面类型
function clsObtainTipUI:parseWineData()
	local data = self.data
	local t = {}
	local prop_data = port_reward_info[self.data.key]
	t.name = ui_word.PORT_HONOR
	t.res = "#common_icon_honour.png"
	t.name_num = prop_data.memo
	return t
end

-- 刷新界面
function clsObtainTipUI:updateUI()
	-- print("clsObtainTipUI updateUI")
	self.card_panel:setVisible(true,true)
	self:playInverstLevelUpEffect()
	self:playFlopEffect()
	-- self:playPrestigeEffect()

end

function clsObtainTipUI:preClose()
	local target_ui = getUIManager():get("clsPortTownUI")
	if not tolua.isnull(target_ui) then
		target_ui:updateUI(1)
	end
	if self.callback1 and type(self.callback1) == "function" then
		self.callback1() -- 执行传入的回调函数 更新UI
	end
	if self.callback and type(self.callback) == "function" then
		self.callback() -- 执行传入的回调函数 队列重开
	end
end

-- 退出资源释放
function clsObtainTipUI:onExit()
	UnLoadPlist(self.plist)
	ReleaseTexture(self)
end

--[[
	创建声望升级特效 由公共接口变更而来
	Alert:showZhanDouLiEffect
]]
function clsObtainTipUI:createPrestigeEffectUI(value,start_num, show_time, call_back)

	local layer = UIWidget:create()
	local effect_layer = UIWidget:create()
	local start_number = start_num or 0
	local label_zhandouli = createBMFont({text = start_number, size = 20, color = ccc3(dexToColor3B(COLOR_YELLOW_STROKE)), fontFile = FONT_NUM_COMBAT})
	local label_pic

	-- 只显示增加的声望.不显示总声望
	if start_num then
		label_pic = display.newSprite("ui/txt/txt_prestige_total_1.png")
	else
		label_pic = getChangeFormatSprite("ui/txt/txt_get_force.png")
	end

	label_pic:setScale(0.5)
	layer:addChild(effect_layer)

	audioExt.playEffect(music_info.PRESTIGE_RAISE.res)
	local effect_node = CompositeEffect.new("tx_0184_stop", display.cx, display.cy, effect_layer, nil, nil, nil, nil, true)
	local pos_x,pos_y = display.cx ,display.cy

	local array_action = CCArray:create()
	array_action:addObject(CCDelayTime:create(0.6))
	array_action:addObject(CCCallFunc:create(function (  )
		label_zhandouli:setPosition(ccp(pos_x+480, pos_y-25))
	end) )

	layer:addCCNode(label_zhandouli)
	local label_wgt = UIWidget:create()
	label_wgt:addCCNode(label_pic)
	label_wgt:setPosition(ccp(-5,0))
	layer:addChild(label_wgt)

	array_action:addObject(CCMoveTo:create(0.3, ccp(500,pos_y-25)))
	array_action:addObject(CCDelayTime:create(0.2))
	array_action:addObject(CCCallFunc:create(function ()
		UiCommon:numberEffect(label_zhandouli, start_number or 0, value, 30)
	end) )
	-- array_action:addObject(CCDelayTime:create(1.3))
	-- array_action:addObject(CCMoveTo:create(0.2, ccp(-20,pos_y-25)))
	-- array_action:addObject(CCFadeOut:create(0.2))
	-- array_action:addObject(CCFadeIn:create(0.01)) -- mid
	label_zhandouli:runAction(CCSequence:create(array_action))


	local array_action_pic = CCArray:create()
	array_action_pic:addObject(CCDelayTime:create(0.6))
	array_action_pic:addObject(CCCallFunc:create(function ()
		label_pic:setPosition(ccp(pos_x-370, 288))
	end))

	array_action_pic:addObject(CCMoveTo:create(0.3, ccp(402, 288)))

	-- array_action_pic:addObject(CCDelayTime:create(1.4))
	-- array_action_pic:addObject(CCMoveTo:create(0.25, ccp(1000,288)))
	-- array_action_pic:addObject(CCFadeOut:create(0.25))
	-- array_action_pic:addObject(CCFadeIn:create(0.01))
	label_pic:runAction(CCSequence:create(array_action_pic))


	-- local scheduler = CCDirector:sharedDirector():getScheduler()
	local function callBack()
		if type(call_back) == "function" then
			call_back()
			if layer then
				if layer.scheduleHandler then
					scheduler:unscheduleScriptEntry(layer.scheduleHandler)
					layer.scheduleHandler = nil
				end
			end
		end
	end

	layer.scheduleHandler = scheduler:scheduleScriptFunc(callBack, show_time or 3, false)

	-- 根本不会执行 --bug
	layer.touchCallBack = function()
		print(" -------------- touchCallBack")
		callBack()
	end

	layer.close = call_back

	-- 根本不会执行 --bug
	layer.onExit = function(layer)
		print(" ---------------------- 执行 onExit")
		if  layer.scheduleHandler then
			scheduler:unscheduleScriptEntry(layer.scheduleHandler)
			layer.scheduleHandler = nil
		end

	end
	return layer
end

return clsObtainTipUI

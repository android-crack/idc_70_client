-- @author: mid
-- @date: 2016年11月17日
-- @desc: 市政厅 和 港口信息面板 投资升级奖励信息 格子

local ui_word = require('game_config/ui_word')
local port_reward_info = require("game_config/port/port_reward_info")
local boat_info = require("game_config/boat/boat_info")
local build_info = require("game_config/port/build_info")
local item_info = require("game_config/propItem/item_info")
local goods_info = require('game_config/port/goods_info')
local goods_type_info=require('game_config/port/goods_type_info')
local sailor_info = require("game_config/sailor/sailor_info")

local music_info = require("game_config/music_info")

local STAR = {"e", "d", "c", "b", "a", "s"}
local LINE_WIDTH = 40
local FRAME_WIDTH = 60

local TIPS_TYPE = {
	['TIPS_TYPE_INVESTTAB'] = 1, -- 在投资界面中
	['TIPS_TYPE_MAP'] = 2, -- 在探索小地图中
}

local clsInvestCell = class("clsInvestCell", function () return UIWidget:create() end)
--[[
@api
	旧接口 根据解锁信息创建节点
]]
function clsInvestCell:ctor(lock_data,id,tips_type)

	self.tips_type = tips_type or TIPS_TYPE.TIPS_TYPE_INVESTTAB

	self.id = id

	local ui_layer  = UIWidget:create()
	local cityhall_invest_icon = GUIReader:shareReader():widgetFromJsonFile("json/cityhall_invest_icon.json")
	convertUIType(cityhall_invest_icon)
	ui_layer:addChild(cityhall_invest_icon)
	self:addChild(ui_layer)
	local needWidgetName = {
		["spr_item_icon"] = "item_icon",
		["btn_item"] = "btn_item",
		["lbl_step"] = "item_num",
		["lbl_goods_type"] = "goods_type",
		["spr_goods_type_bg"] = "goods_type_bg",
		["item_letter_bg"] = "item_letter_bg",
		["item_letter"] = "item_letter",
		["icon_panel"] = "icon_panel",
	}

	for k, v in pairs(needWidgetName) do
		self[k] = getConvertChildByName(cityhall_invest_icon, v)
	end

	self.width = self.icon_panel:getContentSize().width
	self.height = self.icon_panel:getContentSize().height

	self.spr_goods_type_bg:setVisible(false)
	self.lbl_step:setText(string.format(ui_word.PORT_INVEST_STEP, lock_data.step))

	local title, res, name, desc, isboat, goods_type, goods_decs, star_lv = self:parseItemData(lock_data)

	local invest_data = getGameData():getInvestData():getInvestDataByPortId(id)
	local unlock = (invest_data.investStep >= lock_data.step)

	-- print('----------------id step',id,step)

	local type_icon, goods_type_res, star_icon = nil, nil, nil
	if goods_type == ui_word.PORT_AREA_GOOD then
		self.lbl_goods_type:setText(goods_type)
		setUILabelColor(self.lbl_goods_type, ccc3(dexToColor3B(COLOR_COFFEE)))
		self.spr_goods_type_bg:setVisible(true)
	elseif goods_type == ui_word.PORT_PORT_GOOD then
		self.lbl_goods_type:setText(goods_type)
		setUILabelColor(self.lbl_goods_type, ccc3(dexToColor3B(COLOR_BROWN)))
		self.spr_goods_type_bg:setVisible(true)
	elseif star_lv then
		self.item_letter_bg:setVisible(unlock and true or false)
		type_icon = self.item_letter_bg
		goods_type_res = "#common_letter_bg.png"
		star_icon = STAR_SPRITE_RES[star_lv].gray
		self.item_letter:changeTexture(star_icon, UI_TEX_TYPE_PLIST)
		star_icon = "#" .. star_icon
	end

	if type_icon and not unlock then
		local sprite = newQtzGraySprite(goods_type_res, type_icon:getPosition().x, type_icon:getPosition().y, 1)
		sprite:setScale(0.9)
		self.btn_item:addRenderer(sprite, 1)
		if star_icon then
			local size = sprite:getContentSize()
			sprite_star = newQtzGraySprite(star_icon, size.width/2, size.height/2, 1)
			sprite_star:setScale(0.6)
			sprite:addChild(sprite_star)
		end
		self.btn_item.spr_star = sprite
		self.btn_item.type_icon = type_icon
	end

	if unlock then
		setUILabelColor(self.lbl_step, ccc3(dexToColor3B(COLOR_GREEN)))
	end

	-- 增加遮罩 和 特产类型
	if self.tips_type == TIPS_TYPE.TIPS_TYPE_MAP then
		if lock_data then
			if lock_data.lock then
				if lock_data.lock.type == "goods" then

					local goods_id = lock_data.lock.id

					local res
					local goods_special_type = goods_info[goods_id].breed
					if goods_special_type == GOOD_TYPE_AREA then
						res = "#txt_common_goods_area.png"
					elseif goods_special_type == GOOD_TYPE_PORT then
						res = "#txt_common_goods_port.png"
					end

					if res then
						local icon = display.newSprite(res)
						self.spr_item_icon:addRenderer(icon,1)
						icon:setPosition(ccp(25,-25))
						icon:setScale(0.8)
						if not unlock then
							icon:setOpacity(153)
						end
					end

					local progress = nil

					if unlock then
						local cur,max
						local goods_list = getGameData():getMarketData():getStoreGoodsByPortId(self.id)
						-- table.print(goods_list)
						for k,v in pairs(goods_list) do
							if v.goodsId == goods_id then
								cur,max = v.cur_good_num,v.max
								break
							end
						end
						local percent = nil
						if cur and max then
							if cur >= 0 and max > 0 then
								percent = 100 - math.floor(cur/max*100)
								progress = CCProgressTimer:create(display.newSprite("#map_goods_bg.png"))
								progress:setType(kCCProgressTimerTypeRadial)
								-- percent = 60
								-- "#txt_common_goods_area.png"
								progress:setReverseDirection(true)
								progress:setPercentage(percent)
								progress:setPosition(ccp(0,-41))
								progress:setScale(1.8)
								progress:setZOrder(-1)
								self.btn_item:addRenderer(progress,1)
							end
						end
					end
				end
			end
		end
	end


	local scale = 1
	if not isboat then
		local size, texture = nil, nil
		if string.find(res, "#") == 1 then
			local tmp_res = string.sub(res, 2)
			self.spr_item_icon:changeTexture(tmp_res, UI_TEX_TYPE_PLIST)

			local sprite = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(tmp_res)
			size = sprite:getOriginalSize()
		else
			self.spr_item_icon:changeTexture(res)

			local texture = CCTextureCache:sharedTextureCache():textureForKey(res)
			size = texture:getContentSize()
		end

		self.spr_item_icon:setScale(LINE_WIDTH/size.width)
		scale = FRAME_WIDTH/size.width
	else
		self.spr_item_icon:setVisible(false)
		local cur_boat = boat_info[res]
		local key = cur_boat.armature
		self.armatureTab[key] = string.format("armature/ship/%s/%s.ExportJson", key, key)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(self.armatureTab[key])
		self.boat_icon = CCArmature:create(key)
		self.boat_icon:getAnimation():playByIndex(0)
		self.boat_icon:setCascadeOpacityEnabled(true)
		self.boat_icon:setScale((LINE_WIDTH + 20)/self.boat_icon:getContentSize().width)
		self.boat_icon:setPosition(ccp(0, -35))
		self.spr_item_icon:getParent():addCCNode(self.boat_icon)
		scale = (FRAME_WIDTH + 20)/self.boat_icon:getContentSize().width
		if not unlock then
			self.boat_icon:setOpacity(255/3)
		end
	end

	self.btn_item:setTouchEnabled(true)
	self.btn_item:setPressedActionEnabled(true)
	self.btn_item:addEventListener(function()
		local step = getGameData():getInvestData():getStep()
		local unlock = (step >= lock_data.step)

		local data = {
			step = lock_data.step, -- 投资阶段
			res = res, -- 图片资源
			scale = scale, -- 缩放比例
			name = name, -- 名字
			title = title, -- 称号?
			unlock = unlock, -- 解锁与否状态
			isboat = isboat, -- 是否是船只类型
			desc = desc, -- 描述
			goods_type = goods_type, -- 商品类型
			goods_decs = goods_decs, -- 商品描述
			star_lv = star_lv, -- 星级
		}

		local layer = nil

		if self.tips_type == TIPS_TYPE.TIPS_TYPE_INVESTTAB then
			layer = self:createItemTipUI(data)
		elseif self.tips_type == TIPS_TYPE.TIPS_TYPE_MAP then
			layer = self:createItemTipUI2(data)
		end

		layer.hideBg = true
		layer.isUpdateImage = true
		local container = UIWidget:create()
		layer:setPosition(ccp(76,6))
		container:addChild(layer)

		getUIManager():create("ui/view/clsBaseTipsView", nil, "clsPortInvestUITip1", {is_back_bg = true}, container, true)

	end, TOUCH_EVENT_ENDED)

end


function clsInvestCell:parseItemData(lock_data)
	local res = ""
	local isboat = false
	local name = ""
	local title = ""
	local unlock = false
	local desc = ""
	local goods_type = nil
	local goods_decs = nil
	local star_lv = nil
	if lock_data.lock then
		if lock_data.lock.type == "goods" then
			local goods_tab = goods_info[lock_data.lock.id]
			goods_decs = string.format(ui_word.PORT_GOOD_LEVEL, goods_tab.level, goods_type_info[goods_tab.class].name)
			goods_type = ui_word.PORT_NORMAL_GOOD
			if goods_tab.breed == GOOD_TYPE_AREA then
				goods_type = ui_word.PORT_AREA_GOOD
			elseif goods_tab.breed == GOOD_TYPE_PORT then
				goods_type = ui_word.PORT_PORT_GOOD
			end
			res = goods_tab.res
			name = goods_tab.name
			title = ui_word.PORT_INVEST_TYPE_GOODS
			desc = goods_tab.explain
		elseif lock_data.lock.type == "build" then
			res = "#cityhall_item_building.png"
			title = ui_word.PORT_INVEST_TYPE_BUILD
			name = ui_word.PORT_BUILD
			desc = ui_word.PORT_PORT_INVEST_TYPE_BUILD_DESC
		end
	else
		local portData = getGameData():getPortData()
		local curPortId = self.id
		local key = string.format(" %d_%d", curPortId, lock_data.step)

		local port_reward_data = port_reward_info[key]
		local r_type = port_reward_data.type
		if r_type == "item" then
			res = item_info[port_reward_data.id].res
			name = item_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_ITEM
			desc = item_info[port_reward_data.id].desc
		elseif r_type == "boat" then
			res = port_reward_data.id
			isboat = true
			name = boat_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_BOAT
			desc = boat_info[port_reward_data.id].explain
			star_lv = boat_attribute[port_reward_data.id].boat_level
		elseif r_type == "sailor" then
			res = sailor_info[port_reward_data.id].res
			name = sailor_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_SAILOR
			desc = sailor_info[port_reward_data.id].explain
			star_lv = sailor_info[port_reward_data.id].star
		elseif r_type == "material" then
			res = equip_material_info[port_reward_data.id].res
			name = equip_material_info[port_reward_data.id].name
			title = ui_word.PORT_INVEST_TYPE_MATERIAL
			desc = equip_material_info[port_reward_data.id].desc
		elseif r_type == "honour" then
			res = "#common_icon_honour.png"
			name = ui_word.PORT_HONOR
			title = ui_word.PORT_HONOR
			desc = ui_word.PORT_HONOR_DESC
		end
		if port_reward_data.cnt >= 1 then
			name = string.format("%s x %d", name, port_reward_data.cnt)
		end
	end
	return title, res, name, desc, isboat, goods_type, goods_decs, star_lv
end

--[[
@api
	旧接口 item的详情页
]]
function clsInvestCell:createItemTipUI(data)
	local ui_layer = UIWidget:create()
	local cityhall_invest_unlock = GUIReader:shareReader():widgetFromJsonFile("json/cityhall_invest_unlock.json")
	convertUIType(cityhall_invest_unlock)
	ui_layer:addChild(cityhall_invest_unlock)

	local lbl_title = getConvertChildByName(cityhall_invest_unlock, "title")
	lbl_title:setText(data.title)
	local lbl_name = getConvertChildByName(cityhall_invest_unlock, "item_name")
	lbl_name:setText(data.name)
	local lbl_desc = getConvertChildByName(cityhall_invest_unlock, "item_info")
	lbl_desc:setText(data.desc)
	local lbl_unlock = getConvertChildByName(cityhall_invest_unlock, "unlock_tips")
	local spr_unlock = getConvertChildByName(cityhall_invest_unlock, "lock_icon")
	local btn_close = getConvertChildByName(cityhall_invest_unlock,'btn_close')
	btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		getUIManager():close("clsPortInvestUITip1")
	end, TOUCH_EVENT_ENDED)

	lbl_unlock:setVisible(not data.unlock)
	spr_unlock:setVisible(not data.unlock)
	lbl_unlock:setText(string.format(ui_word.PORT_INVEST_TIP2, data.step))

	local spr_icon = getConvertChildByName(cityhall_invest_unlock, "icon")
	if not data.isboat then
		if string.find(data.res, "#") == 1 then
			spr_icon:changeTexture(string.gsub(data.res, "#", ""), UI_TEX_TYPE_PLIST)
		else
			spr_icon:changeTexture(data.res)
		end
		if data.scale then
			spr_icon:setScale(data.scale)
		end
	else
		spr_icon:setVisible(false)
		local cur_boat = boat_info[data.res]
		local key = cur_boat.armature
		self.armatureTab[key] = string.format("armature/ship/%s/%s.ExportJson", key, key)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(self.armatureTab[key])
		local icon = CCArmature:create(key)
		icon:getAnimation():playByIndex(0)
		icon:setCascadeOpacityEnabled(true)
		icon:setScale(data.scale)
		spr_icon:getParent():addCCNode(icon)
	end

	local lbl_goods_level = getConvertChildByName(cityhall_invest_unlock, "item_type")
	lbl_goods_level:setVisible(false)
	if data.goods_type then
		local spr_goods_type = getConvertChildByName(cityhall_invest_unlock, "goods_type_bg")
		local lbl_goods_type = getConvertChildByName(cityhall_invest_unlock, "goods_type_text")
		spr_goods_type:setVisible(true)
		lbl_goods_level:setVisible(true)
		lbl_goods_type:setText(data.goods_type)
		lbl_goods_level:setText(data.goods_decs)
	elseif data.star_lv then
		local letter_bg = getConvertChildByName(cityhall_invest_unlock, "letter_bg")
		letter_bg:setVisible(true)
		local letter = getConvertChildByName(cityhall_invest_unlock, "letter")
		letter:changeTexture(string.format("common_letter_%s1.png", STAR[data.star_lv]), UI_TEX_TYPE_PLIST)
	end

	return ui_layer
end

function clsInvestCell:createItemTipUI2(data)

	-- table.print(data)

	local container = UIWidget:create()
	local main_ui = GUIReader:shareReader():widgetFromJsonFile('json/backpack_tips.json')
	convertUIType(main_ui)
	container:addChild(main_ui)
	local wgts = {
		['no_need_ui_1'] = 'consume_panel', -- 消耗信息面板隐藏
		['no_need_ui_2'] = 'btn_sell', -- 出售按钮
		['no_need_ui_3'] = 'btn_compound_right', -- 合成按钮
		['no_need_ui_4'] = 'box_tips', -- 文本
		['no_need_ui_5'] = 'box_tips_num', -- 文本
		['no_need_ui_6'] = 'btn_use', -- 使用按钮

		['name'] = 'box_name', -- 物品名称
		['desc'] = 'box_introduce', -- 物品描述
		['icon'] = 'box_icon', -- 物品图标
	}

	-- 绑定控件
	for k, v in pairs(wgts) do
		main_ui[k] = getConvertChildByName(main_ui, v)
	end

	-- 隐藏不用的
	for i=1,6 do
		main_ui[string.format('no_need_ui_%d',i)]:setVisible(false)
	end

	main_ui.name:setText(data.name)
	main_ui.desc:setText(data.desc)

	if string.find(data.res, "#") == 1 then
		main_ui.icon:changeTexture(string.gsub(data.res, "#", ""), UI_TEX_TYPE_PLIST)
	else
		main_ui.icon:changeTexture(data.res)
	end
	if data.scale then
		main_ui.icon:setScale(data.scale)
	end

	main_ui.name:removeAllChildren()

	local str,str2 = nil,nil

	if data.star_lv then -- 航海士
		str = string.format(ui_word.STR_FRIEND_LV .. ': %s', string.upper(STAR[data.star_lv]))
	elseif data.goods_type then -- 商品
		-- str = T(string.format('%s%s',data.goods_type,data.goods_decs)) -- 换行怎么不能用
		str = data.goods_type
		str2 = data.goods_decs
	else --道具 朗姆酒
		str = ''
	end

	local data_txt = {}
	data_txt.text = str
	data_txt.size = 16
	data_txt.x = 0
	data_txt.y = 0
	data_txt.color = ccc3(dexToColor3B(COLOR_YELLOW))
	data_txt.anchor = ccp(0,0)
	-- data_txt.opacity = 255


	local txt = createBMFont(data_txt)
	txt:setPosition(ccp(0,-38))
	main_ui.name:addCCNode(txt)

	if str2 then
		data_txt.text = str2
		local txt2 = createBMFont(data_txt)
		txt2:setPosition(0,-63)
		main_ui.name:addCCNode(txt2)
	end

	main_ui:setPosition(ccp(270,100))

	return container

end

return clsInvestCell

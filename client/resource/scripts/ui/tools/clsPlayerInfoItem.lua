--
-- Author: 玩家金币等信息元件
-- Date: 2016-03-21 14:56:29
--
local ClsUiCommon = require("ui/tools/UiCommon")

--币框列表
player_coin_item_list = {} 
--钻石框列表
player_diamond_item_list = {}
--荣誉即为朗姆酒框列表
player_honour_item_list = {}
--体力框列表
player_power_item_list = {}

local ClsPlayerInfoItem = class("ClsPlayerInfoItem", function()
	return display.newLayer()
end)

--type对应类型为：
--ITEM_INDEX_CASH为金币，币类
--ITEM_INDEX_GOLD为钻石，币类
--ITEM_INDEX_TILI为体力
--ITEM_INDEX_HONOUR为荣誉
--使用只需ClsPlayerInfoItem.new(ITEM_INDEX_CASH)，然后add到对应的位置即可，
--父类json拼的话可能有防止对应层容器，否则手动创建的就自己设置坐标
function ClsPlayerInfoItem:ctor(type_index)
	local player_data = getGameData():getPlayerData()
	local res_list = {
		[ITEM_INDEX_CASH] = {res = "json/shop_coin.json", table = player_coin_item_list, value = function()
			return player_data:getCash()
		end},
		[ITEM_INDEX_GOLD] = {res = "json/shop_diamond.json", table = player_diamond_item_list, value = function()
			return player_data:getGold()
		end},
		[ITEM_INDEX_TILI] = {res = "json/shop_power.json", table = player_power_item_list, value = function()
			return player_data:getPower()
		end},
		[ITEM_INDEX_HONOUR] = {res = "json/shop_rum.json", table = player_honour_item_list, value = function()
			return player_data:getHonour()
		end},
	}

	self.ui_layer = UILayer:create()
    self.info_panel = GUIReader:shareReader():widgetFromJsonFile(res_list[type_index].res)
    convertUIType(self.info_panel)
    self.ui_layer:addWidget(self.info_panel)
    self:addChild(self.ui_layer)

    self.num_lb = getConvertChildByName(self.info_panel, "resource_num")
    self.num_lb:setText(res_list[type_index].value())

    self.player_list = res_list[type_index].table
    self.player_list[self] = self

    self:registerScriptHandler(function(event)
		if event == "exit" then
			self:onExit()
		end
	end)
end

function ClsPlayerInfoItem:updateInfo(value)
	ClsUiCommon:numberEffect(self.num_lb, tonumber(self.num_lb:getStringValue()), value)
end

function ClsPlayerInfoItem:onExit()
	self.player_list[self] = nil
end

return ClsPlayerInfoItem
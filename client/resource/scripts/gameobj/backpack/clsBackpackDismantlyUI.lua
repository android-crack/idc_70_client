-- 船舶拆解界面
-- Author: chenlurong
-- Date: 2016-07-12 14:40:59
--

local music_info=require("scripts/game_config/music_info")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local boat_fleet_config = require("game_config/boat/boat_fleet_config")
local boat_attr = require("game_config/boat/boat_attr")
local ClsBaseView = require("ui/view/clsBaseView")

local ClsBackpackDismantlyUI = class("ClsBackpackDismantlyUI", ClsBaseView)

--页面参数配置方法，注意，是静态方法
function ClsBackpackDismantlyUI:getViewConfig()
    return {
        name = "ClsBackpackDismantlyUI",       --(选填）默认 class的名字
        type = UI_TYPE.VIEW,        --(选填）默认 UI_TYPE.VIEW, 页面类型，决定ui到底在哪一层上显示
        -- is_swallow = true,          --(选填) 默认true, 是否吞掉下层页面的触摸事件
        effect = UI_EFFECT.SCALE,    --(选填) ui出现时的播放特效
        is_back_bg = true,
    }
end

function ClsBackpackDismantlyUI:onEnter(key, dismantling_data, type, is_all_dismantic)
	self.plist_tab = {
		["ui/material_icon.plist"] = 1,
	}
	LoadPlist(self.plist_tab)

	self.key = key
	self.dismantling_data = dismantling_data
	self.type = type
	self.is_all_dismantic = is_all_dismantic

	self:initUI()
	self:initEvent()
end

function ClsBackpackDismantlyUI:initUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_dismantle.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)
    self.panel:setPosition(ccp(215, 58))

    self.btn_close = getConvertChildByName(self.panel, "btn_close")
    self.btn_disassembly = getConvertChildByName(self.panel, "btn_disassembly")

    local boat_config = boat_attr[self.boat_id]
    local ship_data = getGameData():getShipData()
	local boat_data = ship_data:getBoatDataByKey(self.boat_key)

	-- table.print(self.dismantling_data)
	self.equip_icon_list = {}
	for i=1,4 do
		local icon = getConvertChildByName(self.panel, "icon" .. i)
		local icon_num = getConvertChildByName(self.panel, "icon_num" .. i)
		self.equip_icon_list[i] = {num = icon_num, icon = icon}

		local reward_info = self.dismantling_data[i]
		if reward_info then
			local item_res, amount, scale = getCommonRewardIcon(reward_info)
			icon:changeTexture(convertResources(item_res), UI_TEX_TYPE_PLIST)
			icon_num:setText(amount)
		else
			icon:setVisible(false)
			icon_num:setText("")
		end
	end
end

function ClsBackpackDismantlyUI:setViewEnabled()
	local backpack_ui = getUIManager():get("ClsBackpackMainUI")
	if not tolua.isnull(backpack_ui) then
		backpack_ui:setViewTouchEnabled(false)
	end

	local clsFleetPartner = getUIManager():get("ClsFleetPartner")
	if not tolua.isnull(clsFleetPartner) then 
		clsFleetPartner:setViewTouchEnabled(false)
	end
end

function ClsBackpackDismantlyUI:initEvent()
	self.btn_disassembly:setPressedActionEnabled(true)
	self.btn_disassembly:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		if self.is_all_dismantic then
			local dismantic_list = getGameData():getBagDataHandler():getDismantleList()
			getGameData():getPartnerData():askPartnerPrefetDismantic(dismantic_list)
			self:setViewEnabled()
			self:close()
			return
		end

		if self.type == BAG_PROP_TYPE_FLEET then
			local ship_data = getGameData():getShipData()
			self:setViewEnabled()
			ship_data:askBoatSplit(self.key)
		elseif self.type == BAG_PROP_TYPE_SAILOR_BAOWU then
			local baowu_data = getGameData():getBaowuData()
			self:setViewEnabled()
			baowu_data:askBaowuDisassemble(self.key)
		end
		self:close()
    end,TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		self.btn_close:setTouchEnabled(false)
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:close()

		if self.is_all_dismantic then
			local backpack_ui = getUIManager():get("ClsBackpackMainUI")
			if not tolua.isnull(backpack_ui) then
				backpack_ui:updatePerfetDismanticBack(true)
			end
		end
    end,TOUCH_EVENT_ENDED)
end

function ClsBackpackDismantlyUI:onExit()
	UnLoadPlist(self.plist_tab)
	ReleaseTexture(self)
end

return ClsBackpackDismantlyUI
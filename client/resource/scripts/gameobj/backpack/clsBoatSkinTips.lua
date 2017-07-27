-- 
-- Author: Ltian
-- Date: 2017-03-23 14:43:59
--

local baozang_info = require("game_config/collect/baozang_info")
local base_attr_info = require("game_config/base_attr_info")
local ClsBaseTipsView = require("ui/view/clsBaseTipsView")
local item_info = require("game_config/propItem/item_info")
local news = require("game_config/news")
local Alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")

local ClsBoatSkinTips = class("ClsBoatSkinTips", ClsBaseTipsView)

function ClsBoatSkinTips:getViewConfig(name_str, params, sailor_id, item_id, boat_key)
	return ClsBoatSkinTips.super.getViewConfig(self, name_str, params, partner_index, item_key, x, y)
end
local widget_name = {
	"box_icon",
	"box_bg",
	"box_name",
	"box_introduce",
	"btn_use_text",
	"btn_unload",
	"btn_use",
	"attr_txt_1",
	"attr_num_1",
	"attr_txt_2",
	"attr_num_2",
	"attr_txt_3",
	"attr_num_3",
	"time_num",
}

function ClsBoatSkinTips:onEnter(name_str, params, sailor_id, item_id, boat_key, is_form_skin_btn)
	self.sailor_id = sailor_id
	self.item_id = item_id
	self.boat_key = boat_key
	self.is_form_skin_btn = is_form_skin_btn
	local item_data = item_info[self.item_id]
	self.skin_id = item_data.skin_id
	local ui_layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/backpack_skin.json")
	convertUIType(panel)
	ui_layer:addChild(panel)
	ClsBoatSkinTips.super.onEnter(self, name_str, params, ui_layer, true)
	ui_layer:setPosition(ccp(display.cx - 170, display.cy - 210))
	for i,v in ipairs(widget_name) do
		self[v] =  getConvertChildByName(panel, v)
	end

	local partner_data = getGameData():getPartnerData()
	local skin_data = partner_data:getBagEquipSkinByBoatKey(self.boat_key)
	local skin_add_list = partner_data:getSkinAddBuff(self.skin_id)
	table.print(skin_add_list)
	local index = 1
	for k,v in pairs(skin_add_list) do
		if index > 3 then break end
		local attr_name =  base_attr_info[k].name
		self["attr_txt_"..index]:setText(attr_name)
		self["attr_num_"..index]:setText(v)
		index = index + 1

	end

	if skin_data then
		self.boat_skin_id = skin_data.skin_id
		self.boat_item_id = skin_data.item_id
	end
	self.skin_data = skin_data
	self.box_icon:changeTexture(convertResources(item_data.res) , UI_TEX_TYPE_PLIST)
	self.box_name:setText(item_data.name)
	setUILabelColor(self.box_name, ccc3(dexToColor3B(QUALITY_COLOR_NORMAL[item_data.quality])))
	self.box_introduce:setText(item_data.desc)
	self.time_num:setText(item_data.skin_time..ui_word.COMMON_DAY)
	local btn_res = string.format("item_box_%s.png", item_data.quality)
	self.box_bg:changeTexture(btn_res, UI_TEX_TYPE_PLIST)
	self.btn_use:setPressedActionEnabled(true)
	self.btn_use:addEventListener(function()
		if ClsSceneManage:doLogic("checkAlert") then return end
		if self.boat_skin_id then -- 原来装了船
			local item_name = item_info[self.boat_item_id].name or ""
			local skin_time = item_info[self.item_id].skin_time or ""
			local use_item_name = item_info[self.item_id].name or ""
			if self.boat_skin_id == self.skin_id then --原来的船和现在的船一样
				tips = string.format(news.SKIN_USE_SAME.msg, item_name, skin_time)
				Alert:showAttention(tips, function ( )
					self:useItem()
				end)
			else
			
				tips = string.format(news.SKIN_USE_DIFF.msg, item_name, use_item_name, skin_time)
				Alert:showAttention(tips, function( )
					self:useItem()
				end)
				--Alert:showAttention(ui_word.TREASUREMAP_ITEM_TIPS, ok_call_back_func, close_call_back_func)
			end
		else
			self:useItem()
		end
	end, TOUCH_EVENT_ENDED)
	if self.is_form_skin_btn then
		self:updateFromSkinBoxBtn()
	end
end

function ClsBoatSkinTips:useItem()
	self:isExploreAlert(function ()
		local collectDataHandle = getGameData():getCollectData()
		collectDataHandle:sendUseItemMessage(self.item_id, nil, self.sailor_id)
		self:close()
	end)

end

function ClsBoatSkinTips:isExploreAlert(fun)
	if isExplore  then
		if not self.is_from_backpack and is_backpack_pass then
			fun()
			return
		end
		local port_info = require("game_config/port/port_info")
		local Alert = require("ui/tools/alert")
		local portData = getGameData():getPortData()
		local portName = port_info[portData:getPortId()].name
		local tips = require("game_config/tips")
		local str = string.format(tips[77].msg, portName)
		Alert:showAttention(str, function()
				self:close()
				if getGameData():getTeamData():isLock() then
					Alert:warning({msg = ui_word.TEAM_VIEW_CAN_NOT_DO_ANYTHING})
					return
				end
				---回港
				portData:setEnterPortCallBack(function() 
					getUIManager():create("gameobj/backpack/clsBackpackMainUI")
				end)
				portData:askBackEnterPort()

		end, nil, nil, {hide_cancel_btn = true})	
	else
		fun()
	end
end

function ClsBoatSkinTips:timeFarmat(remain_time)
	local ClsDataTools = require("module/dataHandle/dataTools")
	local show_time_str, time_tab = ClsDataTools:getCnTimeStr(remain_time)
	return show_time_str
end

function ClsBoatSkinTips:updateFromSkinBoxBtn()
	local remain_time = self.skin_data.skin_end_time
	local show_time_str = self:timeFarmat(remain_time)
	self.time_num:setText(show_time_str)

	local skin_status = self.skin_data.skin_enable
	if skin_status == 1 then --装上了
		self.btn_unload:setTouchEnabled(true)
		self.btn_unload:setVisible(true)
		self.btn_use:setTouchEnabled(false)
		self.btn_use:setVisible(false)
	else
		self.btn_unload:setTouchEnabled(false)
		self.btn_unload:setVisible(false)
		self.btn_use:setTouchEnabled(true)
		self.btn_use:setVisible(true)
	end
	self.btn_unload:setPressedActionEnabled(true)
	self.btn_unload:addEventListener(function()
		self:isExploreAlert(function( )
			local partner_data = getGameData():getPartnerData()
			partner_data:changeBoatSkin(self.sailor_id)
			self:close()
		end)
	end, TOUCH_EVENT_ENDED)
	self.btn_use:addEventListener(function()
		self:isExploreAlert(function( )
			local partner_data = getGameData():getPartnerData()
			partner_data:changeBoatSkin(self.sailor_id)
			self:close()
		end)
		
	end, TOUCH_EVENT_ENDED)
end

function ClsBoatSkinTips:bgOnTouch(event, x, y)
    if event == "began" then
    	self:close()
        return false
    end
end


return ClsBoatSkinTips

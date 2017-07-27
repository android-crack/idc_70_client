--
-- Author: chenlurong
-- Date: 2015-11-10 11:04:21
--
local music_info = require("game_config/music_info")
local boat_info = require("game_config/boat/boat_info")
local item_info = require("game_config/propItem/item_info")
local baozang_info = require("game_config/collect/baozang_info")
local on_off_info = require("game_config/on_off_info")
local sailor_info = require("game_config/sailor/sailor_info")
local skill_info = require("game_config/skill/skill_info")
local ui_word = require("game_config/ui_word")
local CommonBase = require("gameobj/commonFuns")
local compositeEffect = require("gameobj/composite_effect")
local Alert = require("ui/tools/alert")
-- local DialogQuene = require("gameobj/quene/clsDialogQuene")
local ITEM_W = 120
local ITEM_H = 95

-------------------------------------------------------------------------------
local LoginAwardItem = class("LoginAwardItem", function() return CCLayerColor:create(ccc4(0,0,0,0)) end)


local SKILL_MAIN_STATUS = 1
function LoginAwardItem:ctor()
	self.ui_layer = UILayer:create()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_checkin_item.json")
    convertUIType(self.panel)
    self.ui_layer:addWidget(self.panel)
    self:addChild(self.ui_layer)
	-- self.grayBg = CCGraySprite:createWithSpriteFrameName("loginVipAward_itemBg.png") --newQtzGraySprite("ui/loginVipAward/loginVipAward_itemBg.png",0,0)
	-- self.grayBg:setZOrder(0)
	-- self.grayBg:setVisible(false)
	-- self:addChild(self.grayBg)	
	-- self._load_image_tab = {}

	self.award_info_day_bg_pic = getConvertChildByName(self.panel, "award_info_day_bg_pic")
	self.dayLabel = getConvertChildByName(self.panel, "award_info_select_day")
	self.icon = getConvertChildByName(self.panel, "award_info_pic")
	self.award_info = getConvertChildByName(self.panel, "award_num") ---奖励数据
	self.award_info_day_bg_pic:setVisible(false)
	self.spr_star_bg = getConvertChildByName(self.panel, "award_level_bg")
	self.spr_star = getConvertChildByName(self.panel, "award_level")

	self.effect0 = nil

	self.data = nil
end

function LoginAwardItem:setData(data)
	self.data = data
	local loginVipDataHandle = getGameData():getLoginVipAwardData()

	if self.icon_special ~=nil then
		self.icon_special:removeFromParentAndCleanup(true)
		self.icon_special = nil
	end

	self.dayLabel:setText(ui_word.LOGIN_VIP_AWARD_DAYLABEL1..".."..ui_word.LOGIN_VIP_AWARD_DAYLABEL2)
	-- self.strValueLabel:setVisible(false)
	-- self.numValueLabel:setVisible(false)
	if self.effect0~=nil then
		self.effect0:removeTexture()
		self.effect0:removeFromParentAndCleanup(true)
		self.effect0 = nil
	end
	if data~=nil then
		--self.dayLabel:setText(ui_word.LOGIN_VIP_AWARD_DAYLABEL1..numberToCNumber(data["day"])..ui_word.LOGIN_VIP_AWARD_DAYLABEL2)

		self.dayLabel:setText(string.format(ui_word.LOGIN_VIP_AWARD_DAYLABEL, numberToCNumber(data["day"])))
		local value = tostring(data["value"])
		if CommonBase:utfstrlen(value) > 6 then
			value = CommonBase:utf8sub(value, 1, 6) .. ui_word.SIGN_THREE_POINT
		end
		self.award_info:setText(value)
		
		-- self:addImageToReleasePool(data)
		if data["res"] then
			local is_find_index = string.find(data["res"], "#")
			local data_res = data["res"]
			local type_res = UI_TEX_TYPE_LOCAL
			if is_find_index then
				data_res = string.sub(data_res, 2)
				type_res = UI_TEX_TYPE_PLIST
			end
			if data["bgRes"] then
				local is_find_bg_index = string.find(data["bgRes"], "#")
				local data_bg_res = data["bgRes"]
				local type_res = UI_TEX_TYPE_LOCAL
				if is_find_bg_index then
					data_bg_res = string.sub(data_bg_res, 2)
					type_res = UI_TEX_TYPE_PLIST
				end
				self.icon:changeTexture(data_bg_res, type_res)

				self.icon_special = display.newSprite(data["res"], 0, 0)
				self.icon:addCCNode(self.icon_special)
			else
				self.icon:changeTexture(data_res, type_res)
				if data["subType"] == 2 then
					self.icon:setPosition(ccp(54, 54))
					self.spr_star_bg:setVisible(true)
					local str_star = STAR_SPRITE_RES[data.star].gray
					self.spr_star:changeTexture(str_star, UI_TEX_TYPE_PLIST)
				elseif data["subType"] == 3 then
					self.icon:setPosition(ccp(54, 54))
				end
			end
			
			local iconScale = 1.0
			local scale_tbl = {
				[1] = true,
				[7] = true,
				[8] = true,
				[9] = true,
				[10] = true,
			}
			if data["scale"]~=nil then
				iconScale = data["scale"]/100
				if scale_tbl[data["subType"]] then
					iconScale = 0.6
				end
			end

			self.icon:setScale(iconScale)
			if data["getStatus"]==loginVipDataHandle.AWARD_HASGETED_STATUS then
				self.icon:setOpacity(128)
			else
				self.icon:setOpacity(255)
			end
		end

		local labelColor = nil
		if data["getStatus"]==loginVipDataHandle.AWARD_CANGET_STATUS then ---可领取
			if data["isCurDay"]==true then
				labelColor = ccc3(dexToColor3B(COLOR_YELLOW_STROKE))
			else
				labelColor = ccc3(dexToColor3B(COLOR_COFFEE))
			end
			
			self.effect0 = compositeEffect.new("tx_0145", 48, 46, self, nil, nil)
			self.effect0:setZOrder(-1)
			audioExt.playEffect(music_info.LOGIN_AWARD.res)
		elseif data["getStatus"]==loginVipDataHandle.AWARD_HASGETED_STATUS then ---已领取
			labelColor = ccc3(dexToColor3B(COLOR_GREY_STROKE))
		else
			labelColor = ccc3(dexToColor3B(COLOR_COFFEE))
		end

		setUILabelColor(self.dayLabel, labelColor)
		setUILabelColor(self.award_info, labelColor)
		
		if data["isCurDay"]==true and data["getStatus"]==loginVipDataHandle.AWARD_CANGET_STATUS then
			self.award_info_day_bg_pic:setVisible(true)
		else
			self.award_info_day_bg_pic:setVisible(false)
		end
	end
end

------------------------------------------------------------------------------
local ClsLoginAwardUI = class("ClsLoginAwardUI",require("ui/view/clsBaseView"))

function ClsLoginAwardUI:getViewConfig()
    return {
    	name = "MainAwardUI",
        is_swallow = false,
    }
end


function ClsLoginAwardUI:onEnter(close_callback)
	-- DialogQuene:pauseQuene("MainAwardUI")
	self.plistTab = {
        ["ui/ship_icon.plist"] = 1,
        ["ui/skill_icon.plist"] = 1,
        ["ui/account_ui.plist"] = 1,
        ["ui/award_ui.plist"] = 1,
        ["ui/equip_icon.plist"] = 1,
        ["ui/item_box.plist"] = 1,
	}
	LoadPlist(self.plistTab)
	self.close_callback = close_callback
	self:configUI()
	self:configEvent()

	self.sailorAwardData = {} --奖励航海士的配置表
	self.m_creatId = {} 
end

function ClsLoginAwardUI:configUI()
    self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_checkin.json")
    convertUIType(self.panel)
    self:addWidget(self.panel)
    self.btn_get = getConvertChildByName(self.panel, "btn_collect")
    self.vip = getConvertChildByName(self.panel, "vip")
    self.sup_vip_bg = getConvertChildByName(self.panel, "sup_vip_bg")
    self.qq_vip_bg = getConvertChildByName(self.panel, "qq_vip_bg")
    self.start = getConvertChildByName(self.panel, "start")
    self.wechat_start_icon = getConvertChildByName(self.panel, "wechat_start_icon")
    self.qq_start_icon = getConvertChildByName(self.panel, "qq_start_icon")
    
    --self.vip_card = getConvertChildByName(self.panel, "vip_pic")
    self.loginItemPoses = {}
    for i = 1, 7 do
    	local award_item = getConvertChildByName(self.panel, string.format("award_%d", i))
    	local award_item_pos = ccp(award_item:getPosition().x, award_item:getPosition().y)
    	self.loginItemPoses[i] = award_item:getParent():convertToWorldSpace(award_item_pos)
    end
   
	self.loginItems = {}

	self:configLoginItems()

	local on_off_data = getGameData():getOnOffData()
	on_off_data:pushOpenBtn(on_off_info.REWARD_RECEIVE.value, {openBtn = self.btn_get, openEnable = true, addLock = true, 
		labelOpacity = 255 * 0.75, btn_scale = 0.72, btnRes = "#common_btn_blue1.png", parent = "MainAwardUI"})
	self:updateQQVipStatus()
	self:updateBootStatus()
end

function ClsLoginAwardUI:updateQQVipStatus()
	local vip_status = getGameData():getBuffStateData():getQQVipStatus()
    if vip_status == 0 then
        self.vip:setVisible(false)
    elseif vip_status == 1 then
        self.vip:setVisible(true)
        self.sup_vip_bg:setVisible(false)
        self.qq_vip_bg:setVisible(true)
    elseif vip_status == 2 then
        self.vip:setVisible(true)
        self.sup_vip_bg:setVisible(true)
        self.qq_vip_bg:setVisible(false)
    end
end

function ClsLoginAwardUI:updateBootStatus()
	local boot_status = getGameData():getBuffStateData():getBootStatus()
	if boot_status == BOOT_QQ then --qq启动
		self.start:setVisible(true)
		self.wechat_start_icon:setVisible(false)
		self.qq_start_icon:setVisible(true)
	elseif boot_status == BOOT_WX then
		self.start:setVisible(true)
		self.wechat_start_icon:setVisible(true)
		self.qq_start_icon:setVisible(false)
	else
		self.start:setVisible(false)
	end
end

function ClsLoginAwardUI:updateUI()

	if not tolua.isnull(self.btn_get) then
		self.btn_get:disable()		
	end

	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local loginAInfo = loginVipDataHandle.loginAwardInfo
	for i = 1,#self.loginItems do
		local loginItemData = loginVipDataHandle:getLoginACfgByDay(i,loginAInfo["isSpeAward"])
		if loginItemData ~= nil then
			loginItemData["day"] = i
			if loginItemData["day"] > loginAInfo["hasGetedDay"] then
				if loginItemData["day"] <= loginAInfo["loginDay"] then
					loginItemData["getStatus"] = loginVipDataHandle.AWARD_HASGETED_STATUS
				else
					loginItemData["getStatus"] = loginVipDataHandle.AWARD_CANNOTGET_STATUS
				end
			else
				loginItemData["getStatus"] = loginVipDataHandle.AWARD_HASGETED_STATUS
			end
			loginItemData["isCurDay"] = false
		end
		self.loginItems[i]:setData(loginItemData)
	end
end

function ClsLoginAwardUI:configLoginItems()
	local loginVipDataHandle = getGameData():getLoginVipAwardData()

	for i = 1, #self.loginItems do
		self.loginItems[i]:removeFromParentAndCleanup(true)
	end

	self.loginItems = {}

	for i = 1, loginVipDataHandle.LOGIN_AWARD_MAX_DAY do
		if self.loginItemPoses[i]~=nil then
			local loginItem = LoginAwardItem.new()
			loginItem:setPosition(self.loginItemPoses[i])
			self:addChild(loginItem)
			table.insert(self.loginItems, loginItem)
		end
	end
end

function ClsLoginAwardUI:setGetBtnState(bool)
	self.btn_get:setTouchEnabled(bool)
	if bool then
		self.btn_get:active()
	else
		self.btn_get:disable()
	end
end

function ClsLoginAwardUI:setData(data)
	if data == nil then
		return
	end
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local loginAInfo = loginVipDataHandle.loginAwardInfo

	local has_received_times = 0
	for i = 1,#self.loginItems do
		local loginItemData = loginVipDataHandle:getLoginACfgByDay(i,loginAInfo["isSpeAward"])
		if loginItemData ~= nil then
			loginItemData["day"] = i
			if loginItemData["day"] > loginAInfo["hasGetedDay"] then
				--未领取
				if loginItemData["day"] <= loginAInfo["loginDay"] then
					--可领取
					loginItemData["getStatus"] = loginVipDataHandle.AWARD_CANGET_STATUS
				else
					--不可领取
					loginItemData["getStatus"] = loginVipDataHandle.AWARD_CANNOTGET_STATUS
				end
			else
				--已领取
				loginItemData["getStatus"] = loginVipDataHandle.AWARD_HASGETED_STATUS
				has_received_times = has_received_times + 1
			end
			if loginItemData["day"] == loginAInfo["loginDay"] then
				--当天
				loginItemData["isCurDay"] = true
			else
				--非当天
				loginItemData["isCurDay"] = false
			end
		end
		self.loginItems[i]:setData(loginItemData)
	end

	if has_received_times < loginAInfo["loginDay"] then
		self:setGetBtnState(true)
	else
		self:setGetBtnState(false)
	end

	-- local playerData = getGameData():getPlayerData()
 --   	self.remain_day = playerData:getVipRemainDay()
 --   	if self.remain_day and self.remain_day > 0 then
 --   		self.vip_card:setGray(false)
 --   	else
 --   		self.vip_card:setGray(true)
   		
 --   	end
end

function ClsLoginAwardUI:onTouch(eventType, x, y)
	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	local loginPanelPos = ccp(x, y)

	local show_tips = {
		[2] = true,
		[4] = true,
		[5] = true,
		[7] = true,
	}
	if eventType == "began" then
		for k, v in ipairs(self.loginItems) do
			self.loginItemRect.origin.x = self.loginItems[k]:boundingBox().origin.x - 10 --- self.loginItems[k]:getAnchorPoint().x * self.loginItemRect.size.width
			self.loginItemRect.origin.y = self.loginItems[k]:boundingBox().origin.y --- self.loginItems[k]:getAnchorPoint().y * self.loginItemRect.size.height
			if self.loginItemRect:containsPoint(loginPanelPos) and v.data ~= nil and show_tips[v.data["subType"]] then
				getUIManager():create("ui/view/clsBaseTipsView", nil, "LoginAwardTip", {is_back_bg = true}, self:mkTipsNode(v.data), true)
				return true
			end
		end
		return false
	end
end

function ClsLoginAwardUI:configEvent()
	self.btn_get:setPressedActionEnabled(true)
    self.btn_get:addEventListener(function()
	        audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.btn_get:setTouchEnabled(false)
			local loginDataHandle = getGameData():getLoginVipAwardData()
			loginDataHandle:askGetLoginAward()
        end,TOUCH_EVENT_ENDED)

 	local loginVipDataHandle = getGameData():getLoginVipAwardData()
	self:setData(loginVipDataHandle.loginAwardInfo)
	EventTrigger(EVENT_PORT_LAYER_TOUCH,false)

    RegTrigger(EVENT_LOGIN_VIP_AWARD_GET_SUC,function(getType,curGetDay,curGetVipLev,configInfo, vip_reward, is_update_welfare_view, callback)
		if tolua.isnull(self) then 
			callback()
			return 
		end
		self:showGetSucEff(getType,curGetDay,curGetVipLev,configInfo, vip_reward, is_update_welfare_view, callback)
	end)

	self.loginItemRect = CCRect(0, 0, ITEM_W, ITEM_H)

	self:regTouchEvent(self, function(eventType, x, y)
		self:onTouch(eventType, x, y)
	end)
end

function ClsLoginAwardUI:getPropertyTip(data)
	local info_tbl = {
		[5] = item_info,
		[7] = baozang_info,
	}
	local itemInfo = info_tbl[data.subType][data.id]
	local ui_layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/award_item_info.json")
	local needWidgetName = {
		lbl_property_name = "item_name",
		spr_property_icon = "sailor_icon",
		lbl_property_use = "use_info",
		lbl_property_drop = "drop_info",
		lbl_property_skill = "skill_info",
		lbl_property_close = "btn_close"
	}
	for k,v in pairs(needWidgetName) do
        ui_layer[k] = getConvertChildByName(panel,v)
    end	
    ui_layer.lbl_property_name:setText(data.value)
    ui_layer.lbl_property_skill:setText(data.descr)
    ui_layer.lbl_property_drop:setText(itemInfo.drop)
    ui_layer.spr_property_icon:changeTexture(string.gsub(data.res, "#", ""), UI_TEX_TYPE_PLIST)

    ui_layer.lbl_property_use:setVisible(false)
    if itemInfo.use then
    	ui_layer.lbl_property_use:setVisible(true)
    	ui_layer.lbl_property_use:setText(itemInfo.use)
    end

    ui_layer.lbl_property_close:addEventListener(function ()
    	audioExt.playEffect(music_info.COMMON_CLOSE.res)
    	getUIManager():close("LoginAwardTip")
    end, TOUCH_EVENT_ENDED)

	convertUIType(panel)
    ui_layer:addChild(panel)
	return ui_layer   
end

function ClsLoginAwardUI:getSailorTip(data)
	local ui_layer = UIWidget:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/award_checkin_info.json")

	local needWidgetName = {
		lbl_sailor_name = "sailor_name",
		spr_sailor_icon = "sailor_icon",
		spr_sailor_star = "level_icon",
		spr_skill_icon_1 = "skill_icon_1",
		spr_skill_icon_2 = "skill_icon_2",
		spr_skill_bg_1 = "skill_bg_1",
		spr_skill_bg_2 = "skill_bg_2",
		spr_skill_select_1 = "skill_select_1",
		spr_skill_select_2 = "skill_select_2",
		spr_skill_main_1 = "skill_main_1",
		spr_skill_main_2 = "skill_main_2",
		spr_skill_main = "skill_main",
		lbl_skill_name = "name_text",
		lbl_skill_decs = "skill_info",
		lbl_sailor_personality = "personality_info",
		lbl_sailor_personality_long = "personality_long",
		btn_close = "btn_close",
		spr_sailor_job = "name_icon",
	}

	for k,v in pairs(needWidgetName) do
        ui_layer[k] = getConvertChildByName(panel,v)
    end

    ui_layer.lbl_sailor_name:setText(data.value)


    ui_layer.spr_sailor_star:changeTexture(string.gsub(data.starRes, "#", ""), UI_TEX_TYPE_PLIST)
    ui_layer.spr_sailor_icon:changeTexture(data.res)

    ui_layer.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
    	getUIManager():close("LoginAwardTip")
    end, TOUCH_EVENT_ENDED)

    if data.id == 59 then
    	ui_layer.spr_sailor_icon:setScale(0.45)
    end

	local sailor = sailor_info[data.id]
    ui_layer.lbl_sailor_personality:setText(sailor.nature)	
    ui_layer.lbl_sailor_personality_long:setText(sailor.nature_dec)

 	ui_layer.spr_sailor_job:changeTexture(convertResources(JOB_RES[sailor.job[1]]), UI_TEX_TYPE_PLIST)


	for i = 1, 2 do
		local skill = sailor.skills[i]
		if skill then
			--ui_layer["lbl_skill_level_" .. i]:setText(string.format(ui_word.LOGIN_VIP_AWARD_SAILOR_LEVEL, skill.level))

			skill = skill_info[skill.id]
			ui_layer["spr_skill_main_"..i]:setVisible(skill.initiative == SKILL_MAIN_STATUS)
			ui_layer["spr_skill_icon_".. i]:changeTexture(string.gsub(skill.res, "#", ""), UI_TEX_TYPE_PLIST)
			ui_layer["spr_skill_bg_"..i]:changeTexture(SAILOR_SKILL_BG[skill.quality], UI_TEX_TYPE_PLIST)
			ui_layer["spr_skill_icon_".. i]:setTouchEnabled(true)
			ui_layer["spr_skill_icon_".. i]:addEventListener(function()
				local sailorData = getGameData():getSailorData()
				ui_layer.lbl_skill_decs:setText(sailorData:getSkillShortDesc(sailor.skills[i].id))
				ui_layer.lbl_skill_name:setText(skill.name)
				for j=1,2 do
					ui_layer["spr_skill_select_".. j]:setVisible(j == i)
				end
			end, TOUCH_EVENT_ENDED)
		else
			ui_layer["spr_skill_icon_".. i]:setVisible(false)
			ui_layer["spr_skill_icon_".. i]:setTouchEnabled(false)
			--ui_layer["lbl_skill_level_" .. i]:setVisible(false)
		end
	end

	local skill = sailor.skills[1]
	local sailorData = getGameData():getSailorData()
	ui_layer.lbl_skill_decs:setText(sailorData:getSkillShortDesc(skill.id))
	ui_layer.spr_skill_select_1:setVisible(true)
	skill = skill_info[skill.id]
	ui_layer.lbl_skill_name:setText(skill.name)

	convertUIType(panel)
    ui_layer:addChild(panel)
	return ui_layer
end

local tip_by_type = {
	[2] = ClsLoginAwardUI.getSailorTip,
	[5] = ClsLoginAwardUI.getPropertyTip,
	[7] = ClsLoginAwardUI.getPropertyTip,
}
function ClsLoginAwardUI:mkTipsNode(data)
	local tip = tip_by_type[data.subType](self, data)
	return tip
end

function ClsLoginAwardUI:setViewTouch()
	self:setTouchEnabled(true)
end

function ClsLoginAwardUI:reateNewSailor(  )
	if(#self.m_creatId > 0)then
		getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {},self.m_creatId[1])
		table.remove(self.m_creatId,1)
	end
end

--type：大类（1登陆奖励 2VIP奖励）
function ClsLoginAwardUI:showGetSucEff(getType, curGetDay, curGetVipLev, configInfo, vip_reward, is_update_welfare_view, callback)
	local curGetItem = nil
	if getType == 1 then
		curGetItem = self.loginItems[curGetDay]
	end
	if configInfo == nil then return end
	--kind：类型（1银币 2金币 3荣誉 4体力 5水手 6船舶）
	local kind = 0
	if configInfo["subType"] == 1 then		
		kind = configInfo["kind"]
	elseif configInfo["subType"] == 2 then
		kind = 5
	elseif configInfo["subType"] == 3 then --船舶
		kind = 6
	elseif configInfo["subType"] == 5 then --道具
		kind = 7
	elseif configInfo["subType"] == 6 then
		kind = 8
	elseif configInfo["subType"] == 7 then
		kind = 9
	elseif configInfo["subType"] == 8 then
		kind = 10
	elseif configInfo["subType"] == 9 then
		kind = 11	
	elseif configInfo["subType"] == 10 then
		kind = 3		
	end

	if kind == 0 or kind == 4 then return end


	self.callback = callback
	--local is_update_welfare_view = true
	if kind == 5 and not vip_reward then
		--is_update_welfare_view = false
		--if(getUIManager():isLive("clsSailorWineRecruit"))then
			--table.insert(self.m_creatId,configInfo.id)
		--else
			getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {}, configInfo.id, nil, callback, is_update_welfare_view)
		--end

	end
	if kind == 1 then
		audioExt.playEffect(music_info.COMMON_CASH.res, false)
	elseif kind == 2 then
		audioExt.playEffect(music_info.COMMON_GOLD.res, false)
	elseif kind == 3 then
		audioExt.playEffect(music_info.COMMON_HONOUR.res, false)
	end

	if kind == 6 and not vip_reward then
		local uiTools = require("gameobj/uiTools")
		local boat_info = require("game_config/boat/boat_info")
		local boat = boat_info[configInfo.id]
		uiTools:showGetRewardEfffect(self, nil, boat.res, 1, ccp(display.cx - 182, display.cy - 130), nil)
		return
	end

	if (kind >= 1 and kind <= 4) or kind > 6 then
		local type_table = {
			[1] = ITEM_INDEX_CASH,
			[2] = ITEM_INDEX_GOLD,
			[3] = ITEM_INDEX_HONOUR,
			[4] = ITEM_INDEX_TILI,
			[7] = ITEM_INDEX_PROP,
			[8] = ITEM_INDEX_MATERIAL,
			[10] = ITEM_INDEX_CONTRIBUTE,
			[11] = ITEM_INDEX_BOX,
		}

		local value = configInfo.value
		if configInfo.count then
			value = configInfo.count
		end

		local reward_table = {}

		if kind == 9 then
			local random_loot_info = require("game_config/random/random_loot_info")
			local key = configInfo.spe_reward
			local rewards = random_loot_info[key].loot_table
			for k, reward in ipairs(rewards) do
				reward_table[#reward_table + 1] = {key = ITEM_INDEX_BAOWU,value = reward.amount, id = reward.id}
			end
		else
			reward_table = {
				[1] = {key = type_table[kind], value = value, id = configInfo.id},
			}
		end

		if vip_reward then
			reward_table[#reward_table + 1] = {key = vip_reward.type, value = vip_reward.amount}
		end
		Alert:showCommonReward(reward_table, function()
			if type(callback) == "function" then
				callback()

				if is_update_welfare_view then
					local ClsWefareMain = getUIManager():get("ClsWefareMain")
					if not tolua.isnull(ClsWefareMain) then
						ClsWefareMain:updateMkUI()
					end
					
				end
			end
		end)
	elseif vip_reward then
		local vip_reward_alert = {
			[1] = {key = vip_reward.type, value = vip_reward.amount},
		}
		Alert:showCommonReward(vip_reward_alert, function()
			if kind == 5 then
				if(getUIManager():isLive("clsSailorWineRecruit"))then
					table.insert(self.m_creatId,configInfo.id)
				else
					getUIManager():create("gameobj/sailor/clsSailorWineRecruit", {}, configInfo.id)
				end
			elseif kind == 6 then
				local uiTools = require("gameobj/uiTools")
				local boat_info = require("game_config/boat/boat_info")
				local boat = boat_info[configInfo.id]
				uiTools:showGetRewardEfffect(self, nil, boat.res, 1, ccp(display.cx - 182, display.cy - 130), nil)
			end
		end)

	end

end

function ClsLoginAwardUI:updateCallBack()
	if self.callback and type(self.callback) == "function" then
		self.callback()
	end	
end


function ClsLoginAwardUI:onExit()

	-- if self.callback and type(self.callback) == "function" then
	-- 	self.callback()
	-- end
	
	if self.effect0 and (not tolua.isnull(self.effect0)) then
		self.effect0:removeTexture()
	end

	UnLoadPlist(self.plistTab)
	--UnLoadArmature(shipArmatureResTable)
	ReleaseTexture(self)

end

return ClsLoginAwardUI
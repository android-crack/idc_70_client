--开放系统的数据储存
local on_off_info=require("game_config/on_off_info")
local portButtonEffect = require("gameobj/port/portButtonEffect")
local element_mgr = require("base/element_mgr")

local handler=class("OnOffData")

function handler:ctor()
	self.opens={
		--舰队的水手 前段写死开放 红点提示需要开放才能显示

	}
	---保存被暂停打启的按钮KEY值
	self.pauseOpenKeys = {}
	self.isPause = false
	self.openNewBtns = {}
end

function handler:receiveOpen(key)--新开的单个
--	print("新开的单个--------------------------》" .. key)
	if self.isPause then
		self.pauseOpenKeys[#self.pauseOpenKeys + 1] = key
	else
		self:setOpen(key, true)
		self:tryOpen(key)
		self:setRedPointOpen(key)
		self:openNewFunc(key)
	end
end

function handler:pauseOpen()
	self.isPause = true
end

function handler:openNewButton()
	self.isPause = false
	if self.pauseOpenKeys == nil or #self.pauseOpenKeys < 1 then return end
	for k,v in pairs(self.pauseOpenKeys) do
		self:setOpen(v, true)
		self:tryOpen(v)
		self:setRedPointOpen(v)
		self:openNewFunc(v)
	end
	self.pauseOpenKeys = {}
end

function handler:openNewFunc(key)
	
end

function handler:receiveOpens(list) --已开的所有
	if not list then return end
	for k,v in pairs(list) do
		self:setOpen(v)
		self:setRedPointOpen(v)
	end
end

local shieldKeys = {}
--前端主动屏蔽的
function handler:isShield(key)
--	print("+++++++++++++++前段主动屏蔽+++++++++++++++=")
	if shieldKeys[key] then
		return true
	end
	return nil
end

function handler:setRedPointOpen(key)
	if not key then
		return
	end
	local taskData = getGameData():getTaskData()
	local state = taskData:getTaskState(key)
	if state then
		taskData:setTask(key, true)
	end
end

function handler:setOpen(key, isNewOpen)
	-- if key ==on_off_info.PORT_SHIPYARD.value then
	-- 	print("屏蔽营地")
	-- 	return false
	-- end

	if not key then return end
	if self:isShield(key) then return end
	self.opens[key]=true
	local taskData = getGameData():getTaskData()


    taskData:onOffEffect(key)

	--设置按钮状态
	if isNewOpen then
		portButtonEffect:openButtonEffectStatus(key)
	end

	--主界面
	if key == on_off_info.MAIN_FRIEND.value
		or key == on_off_info.RECHARGE_PAGE.value 
		or key == on_off_info.PORT_BULLY.value
		or key == on_off_info.MAIL_SYSTEM.value
		or key == on_off_info.ACTIVITY_BUTTON.value
		or key == on_off_info.CHARACTER_BUTTON.value
		or key == on_off_info.QUESTIONNAIRE_BUTTON.value
		or key == on_off_info.WELFARE_BUTTON.value
		or key == on_off_info.SKILL_SYSTEM.value
		or key == on_off_info.SHOP_BUTTON.value
		or key == on_off_info.MAIN_BUY_GOLD.value
		or key == on_off_info.MAYDAY_ACTIVITY.value
		or key == on_off_info.RANKING_LIST_UI_BUTTON.value then
		
        local port_layer = getUIManager():get("ClsPortLayer")
        if not tolua.isnull(port_layer) then
        	port_layer:open(key)
        end

        local expore_ui = getUIManager():get("ExploreUI")
		if not tolua.isnull(expore_ui) then
			expore_ui:open(key)
		end

		return
	elseif key==on_off_info.RED_POINT.value then --红点系统开放
		taskData:onOffAllEffect()
		return
	elseif key==on_off_info.PORT_HOTEL_STUDY.value
		or key==on_off_info.PORT_HOTEL_ENLIST.value then
        local hotelLayer = getUIManager():get("ClsHotelMain")

        	-- if not tolua.isnull(hotelLayer) then hotelLayer:open(key) end
		return

	elseif key==on_off_info.PORT_MARKET.value then  --交易所里面
        local marketLayer = getUIManager():get("ClsPortMarket")
        if not tolua.isnull(marketLayer) then marketLayer:open(key) end
		return
	elseif key==on_off_info.PORT_HOTEL_STUDY.value --航海士招募
		or key==on_off_info.PORT_HOTEL_ENLIST.value
		or key==on_off_info.WINE_ENLIST.value
		or key==on_off_info.RECRUIT_DIAMOND.value then
        local sailorRecruitUI = getUIManager():get("clsSailorRecruit")
        if sailorRecruitUI and not tolua.isnull(sailorRecruitUI) then

        end
		return
	--elseif --key==on_off_info.BOXROOM_TREASURE.value
	-- elseif	key==on_off_info.BOXROOM_EQUIP.value then
 --  --       local collectMainUi=element_mgr:get_element("ClsCollectMainUI")
 --  --       if not tolua.isnull(collectMainUi) then collectMainUi:open(key) end
	-- 	-- return
	-- 	--收藏室
	-- 	local target_ui = getUIManager():get('ClsCollectMainUI')
	-- 	-- 如果不为空
	-- 	if not tolua.isnull(target_ui) then
	-- 		-- 先移除
	-- 		getUIManager():get("ClsCollectMainUI"):open(key)
	-- 	end
	-- 	-- 再添加
	-- 	-- target_ui = getUIManager():create('gameobj/port/clsCollectMainUI',nil,1)
	-- 	return
	elseif key==on_off_info.MAIN_FRIEND.value
		or key==on_off_info.FRIEND_THANKS.value then
        local friendMainUi=element_mgr:get_element("ClsFriendMainUI")
        if not tolua.isnull(friendMainUi) then friendMainUi:open(key) end
		return
	elseif key==on_off_info.SAILORSKILL_PAGE.value then
		local parner_info_ui = getUIManager():get("ClsPartnerInfoView")
		if not tolua.isnull(parner_info_ui) then
			parner_info_ui:open(key)
		end
		return
	elseif key == on_off_info.PEERAGES.value 
		or key == on_off_info.SKILL_SYSTEM.value 
		or key == on_off_info.PLUNDEOPEN_SYSTEM.value then
		local expore_ui = getUIManager():get("ExploreUI")
		if not tolua.isnull(expore_ui) then
			expore_ui:open(key)
		end
		return
	elseif key == on_off_info.TOWN_WORK.value or key == on_off_info.PORT_FIGHT.value then
		local port_town_ui = getUIManager():get("clsPortTownUI")
		if not tolua.isnull(port_town_ui) then
			port_town_ui:open()
		end

		local guild_skill_research_main = getUIManager():get("ClsGuildSkillResearchMain")
		if not tolua.isnull(guild_skill_research_main) then
			guild_skill_research_main:open()
		end
	elseif key == on_off_info.SEA_STAR.value and isNewOpen then
		getGameData():getSeaStarData():askSeaStarList()

	end
end

function handler:getOnOffConfig(value)
	if not value then
		return
	end

	for k,v in pairs(on_off_info) do
		if v.value == value then
			return v
		end
	end
end

--btn_info表示按钮的各种信息
function handler:pushOpenBtn(key, btn_info)
	if not key or not btn_info then return end

	if not self.openNewBtns[key] then
		self.openNewBtns[key] = {}
	end

	if not btn_info.name then
		btn_info.name = "none"
	end

	self.openNewBtns[key][btn_info.name] = btn_info
	return self:tryOpen(key)
end

function handler:pullOpenBtn(key)
	local info_dic = self.openNewBtns[key]
	return info_dic
end

function handler:isOpen(key)
	if not key then return false end
	return self.opens[key]
end

------------------------------------------------------------------------------------------------------------------------
require("ui/tools/MyMenu")
require("ui/tools/MyMenuItem")
local MyMenuEx = class("MyMenuEx", MyMenu)

MyMenuEx.ctor = function(self, item, touch_priority, btn, isUIWidget)
	if not isUIWidget then
		self.can_touch = function() return btn:isEnabled() end
	else
		self.can_touch = function() return btn:isTouchEnabled() end
	end
	MyMenuEx.super.ctor(self, item, touch_priority)
end

MyMenuEx.onTouchBegan = function(self, x, y)
	-- return true
	if not self:can_touch() or self.m_eState ~= 0 or not self.m_bEnabled or not self:isVisible() then
		return false
	end
	local parent = self:getParent()
	while parent do
		if not parent:isVisible() then
			return false
		end
		parent = parent:getParent()
	end
	local chat_main_ui = element_mgr:get_element("ClsChatSystemMainUI")
	if not tolua.isnull(chat_main_ui) and chat_main_ui:getChatBg().is_show then
		return false
	else
		self.m_pSelectedItem = self:itemForTouch(x,y)
		if self.m_pSelectedItem then
			self.m_eState = 1
			self.m_pSelectedItem:selected()
			return true
		end
	end
	return false
end

------------------------------------------------------------------------------------------------------------------------
-- on_off_data:pushOpenBtn(kind, {openBtn = target, openEnable = true,
-- addLock = true, btnRes = "#common_btn_green1.png", parent = "ClsPortMainUI"})

function handler:tryOpen(key)
	if not key then return end
	local openBtnInfoDic = self:pullOpenBtn(key)
	if not openBtnInfoDic then return end
	local tab = {}
	for k,v in pairs(openBtnInfoDic) do--k表示每个控件的name
		btn = self:open(key, v)
		tab[#tab + 1] = btn
	end
	return tab
end

--能传入的参数：callBack, openBtn, addLock, btnRes, btn_pos, btn_scale, tipZorder, disable_text, active_text,
--parent为按钮父类对象，getUIManager使用的name
--btnNormal为true，就是不创建灰色，用原图
--有label的话，labelOpacity默认值为半透明
--isCreateBtn是否为创建的btn，默认是UIWidget对象
function handler:open(key, btn_info)
	local is_open = true
	if not self:isOpen(key) then is_open = false end

	if not btn_info.openBtn then
		if type(btn_info.callBack) == "function" then
			btn_info.callBack(is_open)
		end
		return
	end

	if tolua.isnull(btn_info.openBtn) then return end

	local current_btn = btn_info.openBtn
	if btn_info.openEnable then  --按钮是否可点击
		--锁定图标跟提示
		if btn_info.addLock then
			if not is_open or current_btn.not_open_btn then
				if not tolua.isnull(current_btn.onOffBtn) then
					if type(btn_info.callBack) == "function" then
						btn_info.callBack(is_open)
					end
					return
				end
				if not btn_info.parent then
					print("没有传ViewBase====================")
					return
				end
				local parent = getUIManager():get(btn_info.parent)
				print(parent, tolua.isnull(parent))
				local value = self:getOnOffConfig(key)
				local buttonTip = parent:createLockButton({ selectScale = 1.0, sound = ""})
				local size = current_btn:getContentSize()
				buttonTip:setTouchRect(size.width,size.height)
				buttonTip:setPosition(btn_info.btn_pos or ccp(0,0))

				current_btn.onOffBtn = buttonTip
				current_btn.tips = {}
				table.insert(current_btn.tips, buttonTip)
				buttonTip:regCallBack(function()
					if #value.btnTip > 0 then
						local Alert = require("ui/tools/alert")
						Alert:warning({msg = value.btnTip, size = 26})
					end
				end)
				if btn_info.btnRes then
					local btnSprite
					if btn_info.btnNormal then
						btnSprite = display.newSprite(btn_info.btnRes)
					else
						btnSprite = newQtzGraySprite(btn_info.btnRes, 0, 0, 0.6)
					end
					btnSprite:setScale(btn_info.btn_scale or 1)
					buttonTip:addChild(btnSprite)
				end

				local tipZorder = btn_info.tipZorder or ZORDER_UI_LAYER
				for k,v in ipairs(current_btn.tips) do
					if btn_info.isCreateBtn then  --是否为cocostudio拼装界面
						current_btn:addChild(v, tipZorder - 1)
					else
						current_btn:addRenderer(v, tipZorder - 1)
					end
					tipZorder = tipZorder + 1
				end

				if current_btn.label and not btn_info.noLabel then
					current_btn.label:setOpacity(btn_info.labelOpacity or (255 * 0.5))
					if current_btn.disable_text then
						current_btn.label:setText(current_btn.disable_text)
					end
				end
			else
				if current_btn.label and not btn_info.noLabel then
					if current_btn:isEnabled() then
				        current_btn.label:setOpacity(255)
				    else
				        current_btn.label:setOpacity(HALF_OPACITY)
					end
					if current_btn.active_text then
						current_btn.label:setText(current_btn.active_text)
					end
				end
				if current_btn.tips then
					for k,v in ipairs(current_btn.tips) do
						v:removeFromParentAndCleanup(true)
					end
					current_btn.tips = nil
				end
			end
		else
			if btn_info.isCreateBtn then  --是否为cocostudio拼装界面
				current_btn:setEnabled(is_open)
			else
				if is_open then
					current_btn:active(false)
				else
					current_btn:disable(false)
				end
			end
		end
	else
		current_btn:setVisible(is_open)
	end

	if type(btn_info.callBack) == "function" then
		btn_info.callBack(is_open)
	end
	return current_btn.onOffBtn
end

return handler

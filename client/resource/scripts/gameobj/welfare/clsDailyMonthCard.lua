--
-- Author: Ltian
-- Date: 2015-08-17 11:26:49
--

local music_info= require("game_config/music_info")
local ui_word= require("game_config/ui_word")
local missionGuide = require("gameobj/mission/missionGuide")
local on_off_info=require("game_config/on_off_info")
local boat_info = require("game_config/boat/boat_info")
local Main3d = require("gameobj/mainInit3d")
local Game3d = require("game3d")
local scheduler = CCDirector:sharedDirector():getScheduler()
local ClsDailyMonthCard = class("ClsDailyMonthCard",require("ui/view/clsBaseView"))

local BUY_VIP_CARD_KEY = "com.tencent.qmdhh.monthpay30"


function ClsDailyMonthCard:getViewConfig()
    return {
        is_swallow = false,
    }
end

local widget_name = {
	--"day_num",
	--"day_txt",
	"day_txt",
	"get_btn",
	"buy_btn",
	"rmb_icon",
	"rmb_num",
	"free_buy_txt",
	"ship_base",
}
function ClsDailyMonthCard:onEnter()
	self.plist = {
	}
	LoadPlist(self.plist)
	self:initView()
end

function ClsDailyMonthCard:initView()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/award_vip.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	self:mkUi()
	GameUtil.callRpc("rpc_server_vip_month_time",{})
	missionGuide:pushGuideBtn(on_off_info.FREE_GET.value, {rect = CCRect(533, 32, 82, 35), guideLayer = self})
end

function ClsDailyMonthCard:mkUi()
	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	local task_data = getGameData():getTaskData()
    local task_keys = {
        on_off_info.FREE_GET.value,
    }
    for i,v in ipairs(task_keys) do
        task_data:setTask(v, false)
    end

    local btn_task_keys = {
        on_off_info.VIP_DIAMONDGET.value,
    }
    self.get_btn.task_keys = btn_task_keys
    task_data:regTask(self.get_btn, btn_task_keys, KIND_RECTANGLE, btn_task_keys[1], 68, 15, true)

    local onOffData = getGameData():getOnOffData()
    onOffData:pushOpenBtn(on_off_info.VIP_PAGE.value, {openBtn = self.buy_btn,openEnable = true, addLock = true,btnRes = "#common_btn_green1.png", parent = "ClsDailyMonthCard"})
	
	self:init3D()

	self:updateButtonStatus()
    --主界面的自己船舶
    local partner_data = getGameData():getPartnerData()
    local boat_id = partner_data:getShowMainBoatId()

	self:showShip3D(boat_id)
end

function ClsDailyMonthCard:init3D()
	self.layer_id = 1
	self.scene_id = SCENE_ID.VIP
	local parent = CCNode:create()
	self.ship_base:addCCNode(parent)
	
	Main3d:createScene(self.scene_id) 
	
	-- layer
	Game3d:createLayer(self.scene_id, self.layer_id, parent)
    self.layer3d = Game3d:getLayer3d(self.scene_id, self.layer_id)

	self.layer3d:setTranslation(CameraFollow:cocosToGameplayWorld(ccp(-170,-110)))

end 

-- 显示3D船
function ClsDailyMonthCard:showShip3D(boat_id)	
	if boat_info[boat_id] == nil then return end 
	self.layer3d:removeAllChildren()

	local path = SHIP_3D_PATH
	local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
	local Sprite3D = require("gameobj/sprite3d")
	local item = {
		id = boat_id,
		key = boat_key,
		path = path,
		is_ship = true,
		node_name = node_name,
		ani_name = node_name,
		parent = self.layer3d,
		star_level = BOAT_ADD_FLOW_COLOR,
		pos = {x = 0, y = 0, angle = 90}
	}
	Sprite3D.new(item)
end 


function ClsDailyMonthCard:setButtonsStatus(isVip, bool)
	if isVip then
		self.free_buy_txt:setVisible(true)
		self.free_buy_txt:setText(ui_word.REWARD_HAD_GET)
		self.rmb_icon:setVisible(false)
		self.rmb_num:setVisible(false)
		self.buy_btn:disable()
		self.buy_btn:setTouchEnabled(false)
	else
		
		self.free_buy_txt:setVisible(false)
		self.rmb_icon:setVisible(true)
		self.rmb_num:setVisible(true)
		self.buy_btn:active()
		self.buy_btn:setPressedActionEnabled(true)
	end
	self.buy_btn:setVisible(bool)
	--self.free_buy_txt:setVisible(bool)
	self.get_btn:setVisible(not bool)

	if not bool then
		local task_data = getGameData():getTaskData()
		for i,v in ipairs(self.get_btn.task_keys) do
			task_data:onOffEffect(v)
		end
	end
end


function ClsDailyMonthCard:updateButtonStatus()
	local playerData = getGameData():getPlayerData()
   	self.remain_day = playerData:getVipRemainDay()
   	self.is_get_reward = playerData:getIsGetAward()
	if self.remain_day >= 1 then
		--self.day_txt:setVisible(true)
		if not self.rich_text then
			local str = string.format("$(c:COLOR_COFFEE)%s$(c:COLOR_YELLOW_STROKE)%s$(c:COLOR_COFFEE)%s", ui_word.LOGIN_VIP_AWARD_REMAIN_DAY_LABLE1, self.remain_day, ui_word.LOGIN_VIP_AWARD_REMAIN_DAY_LABLE2)
			self.rich_text = createRichLabel(str, 300, 20, 18, 0, true, true)
			self.rich_text:setAnchorPoint(ccp(1,0.5))
			self.rich_text:setPosition(ccp(474,45))
			self:addChild(self.rich_text)
		end
		self.rich_text:setVisible(true)

		self.get_btn:setPressedActionEnabled(true)
		self.get_btn:addEventListener(function()

			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			GameUtil.callRpc("rpc_server_vip_get_day_reward",{})
			self:setButtonsStatus(true, true)
		end, TOUCH_EVENT_ENDED)

		if self.is_get_reward then
			self:setButtonsStatus(true, true)
		else	
			self:setButtonsStatus(true, false)
		end
	else 
		if self.rich_text then
			self.rich_text:setVisible(false)
		end
		self:setButtonsStatus(false, true)
		self.buy_btn:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.beginPay(BUY_VIP_CARD_KEY)

		end, TOUCH_EVENT_ENDED)
	end
end

function ClsDailyMonthCard:updateView()
	self:updateButtonStatus()
end

function ClsDailyMonthCard:onExit()
	UnLoadPlist(self.plist)
	--self.item:release()
	Main3d:removeScene(self.scene_id)
end

return ClsDailyMonthCard
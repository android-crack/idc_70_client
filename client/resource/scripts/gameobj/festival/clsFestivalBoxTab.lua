--
-- 女神宝箱
--
local music_info 		= require("game_config/music_info")
local ui_word 			= require("game_config/ui_word")
local compositeEffect 	= require("gameobj/composite_effect")
local ClsAlert   		= require("ui/tools/alert")

local ClsFestivalBoxTab = class("ClsFestivalBoxTab", function() return UIWidget:create() end)

local OPEN_BOX_TIME 	= 5000 -- ms
-- 开启奖励的特效
local GodnessEffect		= 
{	
	res 	= "tx_activity_duanwu",
	x 		= 485,
	y 		= 250,
	parent 	= "activity_panel",
	time 	= nil
}
-- json地址
local TAB_JSON_URL		= "json/activity_dw_godness.json"

local amount_str		= "%s/1"
-- 需要获取的控件名
local widget_name 		=
{
	"btn_check", 
	"btn_open",
	"heart_amount",
	"get_list"
}

function ClsFestivalBoxTab:ctor()
	self["panel"] 		= nil 		-- 界面
	self["get_list"]	= nil 		-- list
	self["btn_check"] 	= nil 		-- 打开奖励介绍页面
	self["btn_open"] 	= nil 		-- 打开女神宝箱
	self["heart_amount"]= nil 		-- 海洋之心的数量
	self["rare_list"] 	= nil 		-- 显示稀有奖励获取列表
	self["is_opening"]	= false 	-- 正在播放特效

	self:mkUI()
end

function ClsFestivalBoxTab:mkUI()
	self.panel = GUIReader:shareReader():widgetFromJsonFile(TAB_JSON_URL)
	self:addChild(self.panel)

	for k, name in ipairs(widget_name) do
		self[name] = getConvertChildByName(self.panel, name)
	end

	self.heart_amount:setVisible(false) -- 需要richlabel，在clsFestivalActivityMain里加了

	self:initCheckBtn() 			-- 初始化btn_check
	self:initOpenBtn() 				-- 初始化btn_open
end

function ClsFestivalBoxTab:initCheckBtn()
	self.btn_check:setPressedActionEnabled(true)
	self.btn_check:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/festival/clsFestivalRewardTips")
	end, TOUCH_EVENT_ENDED )
end

function ClsFestivalBoxTab:initOpenBtn()
	self.btn_open:setTouchEnabled(true)

	self.btn_open:setPressedActionEnabled(true)
	self.btn_open:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if getGameData():getFestivalActivityData():getSeaHeartNum() > 0 then

			if not self.is_opening then  -- 没在播放特效，那就播放特效
				self.is_opening = true
				local parent = getUIManager():get("ClsFestivalActivityMain")
				self.black_layer = CCLayerColor:create(ccc4(0, 0, 0, 200))
				parent:addChild(self.black_layer)
				local effNode = compositeEffect.new(GodnessEffect.res, GodnessEffect.x, GodnessEffect.y, self.black_layer, GodnessEffect.time, function()
					self.is_opening = false
					getGameData():getFestivalActivityData():askOpenGoddessBox()
					self.black_layer:removeFromParentAndCleanup(true)
				end)
			end

		else
			ClsAlert:warning({msg = ui_word.NO_SEA_HEART_ALERT_TIP_51})
		end
	end, TOUCH_EVENT_ENDED)
end


return ClsFestivalBoxTab
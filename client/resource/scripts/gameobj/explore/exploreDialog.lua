-- 探索对话框

local ui = require ("base/ui/ui")
local uiTools = require("gameobj/uiTools")
local sailor_info = require("game_config/sailor/sailor_info")
local ui_word = require("game_config/ui_word")
local tips = require("game_config/tips")
local ClsExploreChatBubble = require("gameobj/explore/clsExploreChatBubble")
local ClsBaseView = require("ui/view/clsBaseView")

local Dialog = class("Dialog", ClsBaseView)

function Dialog:onEnter(cfg)
	local x, y = -33,-80
	self.total_ui = display.newSprite()
	self:addChild(self.total_ui)
	self.eff_spr = display.newSprite()
	self.eff_spr:setPosition(x,y)
	self.total_ui:addChild(self.eff_spr)
	self.bg = display.newSprite("#common_dialog_sea.png")
	local bg_size = self.bg:getContentSize()
	self.bg:setPosition(ccp(84 - x, -1*bg_size.height - y))
	self.eff_spr:addChild(self.bg)
	
	self.total_ui:setPosition(ccp(display.cx - 84, display.cy + 66))
	
	self.call_back = cfg.call_back
	self.seaman_id = cfg.seaman_id
	self.duration  = cfg.duration or 5
	self.action = cfg.action or nil
	self.is_touch = cfg.is_touch or nil
    self.is_touch_pass = cfg.is_touch_pass or false
	local name = ""
	if not sailor_info[self.seaman_id] then  -- 用角色信息代替
        local sceneDataHandle = getGameData():getSceneDataHandler()
		local role_name = sceneDataHandle:getMyName()
		name = string.format("%s%s", role_name, ui_word.SIGN_COLON)
		local icon = sceneDataHandle:getMyIcon()
		icon = string.format("ui/seaman/seaman_%s.png", icon)
		self.seaman = display.newSprite(icon, 45, 55)
	else
		local seaman_res = sailor_info[self.seaman_id].res
		self.seaman = display.newSprite(seaman_res, 45, 55)
		name = sailor_info[self.seaman_id].name..ui_word.SIGN_COLON
	end 
	
	self.bg:addChild(self.seaman)	
	local seaman_width = self.seaman:getContentSize().width
	local show_width = 80
	local scale = show_width/seaman_width
	self.seaman:setScale(scale)
	
	self.name = createBMFont({text = name, size = 16, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_CFG_1, x = 100, y = 90})
	self.name:setAnchorPoint(ccp(0, 0.5))
	self.bg:addChild(self.name)
	
	self.txt = cfg.txt
	self.label = createBMFont({text =self.txt, size = 16, width = 280, color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)),fontFile = FONT_CFG_1, x = 101, y = 50})
	self.label:setAnchorPoint(ccp(0, 0.5))
	self.bg:addChild(self.label)
	
	if not self.is_touch then
	--touch
        self:regTouchEvent(self, function(eventType, x, y) 
			if eventType =="began" then 
				return self:onTouchBegan(x,y)
			end
		end)
	end

	if not self.action then
		local actions = {}
		actions[1] = CCDelayTime:create(self.duration)
		actions[2] = CCCallFunc:create(function() 
			self:hideLayer()
		end)
		local ac = transition.sequence(actions)
		self:runAction(ac)
	end
	self.eff_spr:setScale(0)
	self.eff_spr:runAction(CCEaseBackOut:create(CCScaleTo:create(0.3, 1, 1)))
end

function Dialog:hideLayer()
    local back = self.call_back
    self:close()
	if type(back) == "function" then
		back()
	end
end 

function Dialog:onTouchBegan(x,y)
    if self.is_touch_pass then
        self:hideLayer()
        return false
    end
	if self.bg:boundingBox():containsPoint(ccp(x, y)) then
		self:hideLayer()
		return true 
	end
	return false 
end

--对话层
local dialogLayer = nil
local function showDialog(cfg) 
    dialogLayer = getUIManager():get("Dialog")
	if not tolua.isnull(dialogLayer) then 
		dialogLayer:hideLayer()
		dialogLayer = nil
	end 
    
    local running_scene = getExploreScene()
	if not running_scene then return end 
    dialogLayer = getUIManager():create("gameobj/explore/exploreDialog", nil, cfg)
end

local function hideDialog()
    dialogLayer = getUIManager():get("Dialog")
	if not tolua.isnull(dialogLayer) then
		dialogLayer:hideLayer()
		dialogLayer = nil
	end
end

local plotDialogLayer = nil
local function createPlotDialog(cfg)
    local clsExplorePlotDialog = getUIManager():get("clsExplorePlotDialog")
    if not tolua.isnull(clsExplorePlotDialog) then return end
    plotDialogLayer = getUIManager():create("gameobj/explore/clsExplorePlotDialog", nil, cfg)
    return plotDialogLayer
end

local function showShipDialog(cfg)
    if cfg.clean_before then
        if not tolua.isnull(getUIManager():get("Dialog")) then
            getUIManager():close("Dialog")
        end
    end
	local dialog = getUIManager():create("gameobj/explore/exploreDialog", nil, cfg)
	dialog.total_ui:setPosition(cfg.pos)
end

RegTrigger(EVENT_EXPLORE_BOX_SHOW, showDialog)
RegTrigger(EVENT_EXPLORE_BOX_HIDE, hideDialog)
RegTrigger(EVENT_EXPLORE_PLOT_DIALOG, createPlotDialog)

RegTrigger(EVENT_EXPLORE_SHOW_SHIP_DIALOG, showShipDialog)

-- 注册事件
local function exploreShowDialog(item, tip_agr)  --探索对话框(item参数表， tip_agr为tip参数)
    if not item.tip_id then return end
    local tip_id = item.tip_id
    local dailog_callback = item.call_back
    local sound_res = item.sound
    local params = tip_agr
    local msg_str = tips[tip_id].msg
    if params then 
        if type(params) == "table" then 
            msg_str = string.format(msg_str, unpack(params))
        else 
            msg_str = string.format(msg_str, params)
        end
    end

    if sound_res then
        audioExt.playEffect(sound_res, false) --音效
    end 

    local explore_layer = getExploreLayer()
    if tolua.isnull(explore_layer) then
        explore_layer = getUIManager():get("ClsCopySceneLayer") 
    end
    local shipLayerBase = explore_layer:getShipsLayer()
    if tolua.isnull(shipLayerBase) then return end
    local sceneDataHandle = getGameData():getSceneDataHandler()
    shipLayerBase:showShipChatBubble({direction = DIRECTION_RIGHT, 
            sender = sceneDataHandle:getMyUid(), show_msg = msg_str})
end
RegTrigger(EVENT_EXPLORE_SHOW_DIALOG, exploreShowDialog)

local function showPlotDialog(item, tip_agr)  --探索对话框(item参数表， tip_agr为tip参数)
    if not item.tip_id then return end
    
    local tip_id = item.tip_id
    local params = tip_agr
    local msg_str = tips[tip_id].msg
    if params then 
        if type(params) == "table" then 
            msg_str = string.format(msg_str, unpack(params))
        else 
            msg_str = string.format(msg_str, params)
        end
    end

    local dailog_callback = item.call_back
    local startCallBack = item.beganCallBack
    local sailor_data = getGameData():getSailorData()
    local seaman_id = item.seaman_id or sailor_data:getCaptain() -- 大副id

	if item.noDialogSequence then
		EventTrigger(EVENT_EXPLORE_PLOT_DIALOG, {txt = msg_str, seaman_id = seaman_id, call_back = dailog_callback, beganCallBack = startCallBack})
	else
		local DialogQuene = require("gameobj/quene/clsDialogQuene")
		local clsExplorePlotDialogQuene = require("gameobj/explore/clsExplorePlotDialogQuene")
		DialogQuene:insertTaskToQuene(clsExplorePlotDialogQuene.new({txt = msg_str, seaman_id = seaman_id, callBack = dailog_callback, beganCallBack = startCallBack}))
	end
end
RegTrigger(EVENT_EXPLORE_SHOW_PLOT_DIALOG, showPlotDialog)

local function showGetRewardEfffect(endCallBack, image, num)
    if not tolua.isnull(getExploreUI()) then
        uiTools:showGetRewardEfffect(getExploreUI(),endCallBack,image,num , nil , nil , nil)
        local music_info = require("game_config/music_info")
        audioExt.playEffect(music_info.SHIPYARD_DISMANTLE_AWARD.res)
    end
end
RegTrigger(EVENT_EXPLORE_SHOW_GET_REWARD_EFFECT, showGetRewardEfffect) --wmh todo 换完新队列后可删



return Dialog












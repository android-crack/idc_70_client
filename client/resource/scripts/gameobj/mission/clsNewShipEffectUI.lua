-- 
-- Author: Ltian
-- Date: 2017-02-13 14:02:52
--
local ClsBaseView = require("ui/view/clsBaseView")
local Game3d = require("game3d")
local ui_word = require("game_config/ui_word")
local Main3d = require("gameobj/mainInit3d")
local boat_info = require("game_config/boat/boat_info")
local clsNewShipEffectUI = class("clsNewShipEffectUI", ClsBaseView)

function clsNewShipEffectUI:getViewConfig()
    return {
    	type = UI_TYPE.TIP,
    	--effect = UI_EFFECT.FADE,
    	is_back_bg = true,
    }
end

function clsNewShipEffectUI:onEnter(callBack)
	local partner_data = getGameData():getPartnerData()
	self.boat_id = partner_data:getShowMainBoatId() or 9
	self.callBack = callBack
	self:initUI()
	self:init3D()
	self:regFunc()
end

function clsNewShipEffectUI:initUI()
	local bg = CCLayerColor:create(ccc4(0, 0, 0, 127))
	bg:setZOrder(-1)
	self:addChild(bg)
	local arrow = display.newSprite("#common_arrow3.png")
	arrow:setScaleX(-1)
	arrow:setPosition(display.cx, display.cy)
	self:addChild(arrow, 111)
	local line =  display.newSprite("#common_line_7.png")
	line:setScaleX(200)
	line:setPosition(display.cx, display.cy - 100)
	self:addChild(line, 111)
	local rich_label = createRichLabel(ui_word.SHIP_EFFECT_TIPS, 320, 34, 18)
    rich_label:setAnchorPoint(ccp(0.5, 0.5))
    rich_label:setPosition(ccp(display.cx, 115))
    rich_label:regTouchFromView(getUIManager():get("clsNewShipEffectUI"), 1)
    self:addChild(rich_label)

	
end



function clsNewShipEffectUI:init3D()
	local layer_id = 1
    local scene_id = SCENE_ID.SHIP_EFFECT_UI
    Main3d:createScene(scene_id) 
    local parent = CCNode:create()
    self:addChild(parent)
    
    Game3d:createLayer(scene_id, layer_id, parent)
    self.layer3d = Game3d:getLayer3d(scene_id,layer_id)
    self:runEffectAction()
    
end

function clsNewShipEffectUI:regFunc()
	local status = false
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function( )
		status = true
	end)))
	self:regTouchEvent(self, function(eventType, x, y)	
		if status then
			self:closeView()
		end
	end)
	-- self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(4), CCCallFunc:create(function ()
	-- 	self:closeView()
	-- end)))
end

function clsNewShipEffectUI:show3Dship(boat_id, star_level, pos)
	if boat_info[boat_id] == nil then return end 
	local path = SHIP_3D_PATH
    local node_name = string.format("boat%.2d", boat_info[boat_id].res_3d_id)
    local Sprite3D = require("gameobj/sprite3d")

 
    local item = {
        id = boat_id,
        key = boat_key,
        path = path,
        is_ship = true,
        star_level = star_level,
        node_name = node_name,
        ani_name = node_name,
        parent = self.layer3d,
        pos = {x = pos.x, y = pos.y, angle = -120},
    }
    local ship_3d = Sprite3D.new(item)
    --ship_3d:updateStatus(star_level)
    --ship_3d.node:scale(1.5)
    return ship_3d
end

function clsNewShipEffectUI:showOldShip()
	local ship_3d = self:show3Dship(self.boat_id, 1, {x = -170, y = -20})

end

function clsNewShipEffectUI:showNewShip( )
	local ship_3d = self:show3Dship(self.boat_id, 3, {x = 270, y = -20})

	local keyCount = 2
	local keyTimes = {0, 400}
	local node = ship_3d:getNode()
	local pos = node:getTranslationWorld()
	
	local endPosX = pos:x() - 100
	local endPosY = pos:y()
	local endPosZ = pos:z()
	
	local keyValues = {pos:x(), pos:y(), pos:z(), 
						endPosX, endPosY, endPosZ}	
	local ani = node:createAnimation("Move", Transform.ANIMATE_TRANSLATE(),
												keyCount, keyTimes, keyValues, "LINEAR")
	ani:play()
end


function clsNewShipEffectUI:runEffectAction()
	self:showOldShip()
	self:showNewShip()
	--self:runAction()
end

function clsNewShipEffectUI:closeView()
	self:close()
end



function clsNewShipEffectUI:preClose(...)
	if type(self.callBack) == "function" then
		self.callBack()
	end
    self.layer3d = nil
    Main3d:removeScene(SCENE_ID.SHIP_EFFECT_UI)
end
return clsNewShipEffectUI
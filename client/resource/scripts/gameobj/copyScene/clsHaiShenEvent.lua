local SceneEffect = require("gameobj/battle/sceneEffect")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local ClsHaiShenEvent = class("ClsHaiShenEvent", ClsCopySceneEventObject)
local ParticleSystem = require("particle_system")

local EFFECT_NAME = "tx_attack_up"

function ClsHaiShenEvent:initEvent(prop_data)
	self.event_data = prop_data
	self.event_id = prop_data.id
	self.event_type = prop_data.type

	local item = ClsSceneManage.model_objects:getModel(prop_data.type)
	item.id = prop_data.id
	item.node:setTag("scene_event_id", tostring(prop_data.id))
	item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
	item:setAngle(ClsSceneConfig[prop_data.type].dir)
	item.node:setScale(ClsSceneConfig[prop_data.type].scale / 100)
	self.item_model = item
	self.action_radius = 300
	self.m_name_ui = nil
	self.is_touch = false
	self.is_decoration = ClsSceneConfig[prop_data.type].is_adornment
end

function ClsHaiShenEvent:updataInteractiveResult(interactive_type, result)
	if result > 0 then return end
end

function ClsHaiShenEvent:initUI()
	-- local name_str = ClsSceneConfig[self.event_data.type].name
	-- if not self.m_name_ui then
	-- 	self.m_name_ui = display.newSprite("#explore_name1.png")
 --        local ui_size = self.m_name_ui:getContentSize()
 --        getSceneShipUI():addChild(self.m_name_ui)
 --        local pos_x, pos_y = self.event_data.sea_pos.x, self.event_data.sea_pos.y
 --        self.m_name_ui:setPosition(ccp(pos_x, pos_y - 10))

 --        local name_lab = createBMFont({text = name_str, size = 24, x = ui_size.width/2, y = ui_size.height/2 + 7})
 --        self.m_name_ui:addChild(name_lab)
	-- end
	if getGameData():getCopySceneData():getIsNewRound() and self.is_decoration ~= 1 then
		self:showEventEffect(true)
	end
end

function ClsHaiShenEvent:__endEvent()
	ClsHaiShenEvent.super.__endEvent(self)
	if self.u3d_effect then
		self.u3d_effect:Release()
		self.u3d_effect = nil
	end
	if self.item_model then
		ClsSceneManage.model_objects:removeModel(self.item_model)
		self.item_model = nil
	end
	if self.m_name_ui and not tolua.isnull(self.m_name_ui) then
		self.m_name_ui:removeFromParent()
		self.m_name_ui = nil
	end
	self.is_touch = false
end

function ClsHaiShenEvent:update(dt)
end

function ClsHaiShenEvent:release()
	self:__endEvent()
end

function ClsHaiShenEvent:showEventEffect(is_new_round)
	local effect_time = 3
    self.u3d_effect = ParticleSystem.new(EFFECT_3D_PATH..EFFECT_NAME..PARTICLE_3D_EXT)
    local pos = Vector3.new(0, 0, 100)
    pos:add(self.item_model.node:getTranslation())

    Explore3D:getLayerShip3d():addChild(self.u3d_effect:GetNode())
    self.u3d_effect:GetNode():setTranslation(pos)
    self.u3d_effect:Start()

    local copySceneData = getGameData():getCopySceneData()
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(effect_time))	
	array:addObject(CCCallFunc:create(function()
		if self.u3d_effect then
			self.u3d_effect:Release()
			self.u3d_effect = nil
		end

		ClsSceneManage:doLogic("setPlayerShipMove", true)
		if is_new_round then
			if copySceneData:getIsNewRound() and self.is_decoration ~= 1 then
				copySceneData:askMoveCamera()
				copySceneData:setIsNewRound(nil)
			end
		else
			self:sendInteractiveMessage()
		end
	end))
	getSceneShipUI():runAction(CCSequence:create(array))
end

function ClsHaiShenEvent:clickEvent()
	if self.is_touch then return end
	self.is_touch = true
	getGameData():getCopySceneData():askClickEvent(self.event_id)
end

function ClsHaiShenEvent:touch(node)
	-- if not node then return end
	-- local event_id = node:getTag("scene_event_id")
	-- if not event_id then
	-- 	return
	-- end
	-- -- print("点击海神事件------------------------", event_id, self:getEventId())
	-- event_id = tonumber(event_id)
	-- if event_id ~= self:getEventId() then
	-- 	return
	-- end
	-- if getGameData():getTeamData():isLock() then
	-- 	return
	-- end
	-- local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	-- local scene_layer = ClsSceneManage:getSceneLayer()
	-- local x, y = self.item_model:getPos()
	-- local px, py = scene_layer.player_ship:getPos()
	-- local dis = Math.distance(px, py, x, y)
	-- if dis < self.action_radius / 2 then
	-- 	self:clickEvent()
	-- else
	-- 	local news = require("game_config/news")
	-- 	local Alert = require("ui/tools/alert")
	-- 	Alert:warning({msg = news.COPY_TREASURE_BOX_EVENT_TIP.msg})
	-- end
	-- return true
end

return ClsHaiShenEvent
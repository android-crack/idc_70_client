--
-- Author: lzg0496 
-- Date: 2017-01-17 17:24:42
-- Function: 市长雕像

local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local cfg_copy_scene_prototype = require("game_config/copyScene/copy_scene_prototype")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local cfg_qte_config = require("game_config/copyScene/qte_config")
local ClsAlert = require("ui/tools/alert")
local cfg_ui_word = require("game_config/ui_word")
local port_battle_objects = require("game_config/copyScene/port_battle_objects")
local cfg_music_info = require("game_config/music_info")
local clsCommonFuns = require("gameobj/commonFuns")
local cfg_error_info = require("game_config/error_info")

local ClsSculptureEvent = class("ClsSculptureEvent", ClsCopySceneEventObject)

local QTE_ACTION_CONFIG = {
	ATTACK = 1,
	COLLECT = 3,
}

function ClsSculptureEvent:getEventId()
	return self.event_id
end

function ClsSculptureEvent:initEvent(prop_data)
	self.event_data = prop_data
	self.event_create_time = prop_data.create_time
	self.event_id = prop_data.id
	self.event_type = prop_data.type
	self.config = port_battle_objects[prop_data.attr.index]

	if (device.platform == "windows") then
		table.print(self.event_data)
	end

	local item = ClsSceneManage.model_objects:getModel(self.event_type)
	item.id = prop_data.id
	item.node:setTag("scene_event_id", tostring(self.event_id))
	item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
	self.item_model = item
	self.hp = self.event_data.attr.hp or 0
	self.event_data.attr.hp = self.hp
	self.max_hp = self.event_data.attr.max_hp

	ClsSceneManage:doLogic("setHallHp", self.hp / self.max_hp * 100)

	self.hit_radius = self.config.hit_radius or 300
  
	self.m_attr = self.event_data.attr
	self.m_camp = self.m_attr.camp
	self.player_camp = getGameData():getSceneDataHandler():getMyCamp()
	self.m_qte_attack_key = string.format("copy_event_id_%s_qte_attack_key", tostring(self.event_id))
	self.m_qte_supply_key = string.format("copy_event_id_%s_qte_supply_key", tostring(self.event_id))
	self.m_wait_reason = string.format("copy_event_id_%s_wait_1s", tostring(self.event_id))
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index] = self.m_attr
	port_battle_datas[self.m_attr.index].event_obj = self
	self.hp_effects = {}
	self.bullets = {}
end

function ClsSculptureEvent:update(dt)
	self:updateTimerHander(dt)

	local x, y = self.item_model:getPos()
	local scene_layer = ClsSceneManage:getSceneLayer()
	local px, py = scene_layer.player_ship:getPos()
	local dis = Math.distance(px, py, x, y)
	if dis < self.hit_radius then
		if not self.is_supply then
			if self.player_camp == self.m_camp and ClsSceneManage:doLogic("isHasSupply") then
				self.is_supply = true

				if ClsSceneManage:doLogic("isNotCanSailing") then
					self.is_supply = false
					return
				end

				self.m_event_layer:addActiveKey(self.m_qte_supply_key, function() 
					return self:getQteBtn(self.m_wait_reason, 0, function()
							 if not ClsSceneManage:doLogic("isNotCanInteractive") then
								audioExt.playEffect(cfg_music_info.UI_FIX.res)
								self:sendSalvageMessage()
							 end
						end, cfg_qte_config[QTE_ACTION_CONFIG.COLLECT].res) 
				end)
			end
		end

		if not self.is_firing then
			if self.player_camp ~= self.m_camp then
				if ClsSceneManage:doLogic("isCanFight", self.m_attr.index) then
					self.is_firing = true

					self.m_event_layer:addActiveKey(self.m_qte_attack_key, function() 
						return self:getQteBtn(self.m_wait_reason, 0, function()
								if ClsSceneManage:doLogic("isNotCanInteractive") then
									self.is_firing = false
									return
								end

								if ClsSceneManage:doLogic("isNotCanSailing") then
									ClsAlert:warning({msg = cfg_ui_word.STR_NOT_SAILING_TIP})
									self.is_firing = false
									return
								end

								self:addTimer(1, function()
									local playerShipsData = getGameData():getExplorePlayerShipsData()
									playerShipsData:setAttr(self.m_my_uid, "touch_something", self.event_id)
									local event_id = playerShipsData:getAttr(self.m_my_uid, "touch_something") or 0
									if event_id ~= self.event_id then
										self:removeTimer()
										return
									end

									local ship_data = getGameData():getExplorePlayerShipsData()
									if ship_data:isGhostStatus(self.m_my_uid) then
										self:removeTimer()
										return
									end
									self:sendAttackMessage()
								end, true)
							end, cfg_qte_config[QTE_ACTION_CONFIG.ATTACK].res) 
					end)
				end
			end
		end
	else
		self.is_supply = false
		self.is_firing = false
		self.m_event_layer:removeActiveKey(self.m_qte_supply_key)
		self.m_event_layer:removeActiveKey(self.m_qte_attack_key)
		self:removeTimer()
	end

end

function ClsSculptureEvent:updataAttr(key, value)
	self.m_attr[key] = value
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index].attr = self.m_attr
	if "hp" == key then
		self.is_lock_touch = nil
		self.hp = value
		ClsSceneManage:doLogic("updateEventUI")
	end
	local valuePercent = self.hp / self.max_hp * 100
	self.hpProgress:setPercentage(valuePercent)

	ClsSceneManage:doLogic("setHallHp", valuePercent)

	if "sub_hp" == key then
		self:subHpEffect(value)
	end

	if "add_hp" == key then
		local str = string.format(cfg_ui_word.STR_SUPPLY_ADD_HP, self.config.name, value)
		ClsAlert:warning({msg = str})
		self:showAddHPEffect()
	end

	if "attack_camp" == key then
		ClsSceneManage:doLogic("updateEventUI")
	end
end

function ClsSculptureEvent:initUI()
	local hpProgressBg = self:createHpProgress()
	local valuePercent = self.hp / self.max_hp * 100
	self.hpProgress:setPercentage(valuePercent)
	self.item_model.ui:addChild(hpProgressBg)
	hpProgressBg:setPosition(ccp(-20, 30))

	local name = ClsSceneManage:doLogic("getSculptureName")
	local color_n = ClsSceneManage:doLogic("getCampColor", self.m_camp)
	if name then
		self.m_name_ui = display.newSprite("#explore_name1.png")
		local ui_size = self.m_name_ui:getContentSize()
		local name_lab = createBMFont({text = name, size = 24, color = ccc3(dexToColor3B(color_n)), x = ui_size.width/2, y = ui_size.height/2 + 7})
		self.m_name_ui:addChild(name_lab)
		self.item_model.ui:addChild(self.m_name_ui)
		self.m_name_ui:setPosition(ccp(-20, 65))
	end
	ClsSceneManage:doLogic("updateMap")
end

function ClsSculptureEvent:__endEvent()
	if self.item_model then
		ClsSculptureEvent.super.__endEvent(self)
		ClsSceneManage.model_objects:removeModel(self.item_model)
		self.m_is_delete = true
		self.item_model = nil
	end
end

function ClsSculptureEvent:subHpEffect(sub_hp)
	if tolua.isnull(self.item_model.ui) then
		return 
	end
	local ui_size = self.item_model.ui:getContentSize()
	local sub_hp_lab = createDamageWord(-sub_hp, nil, nil, nil, 1)
	sub_hp_lab:setPosition(ccp(ui_size.width/2, ui_size.height + 20))
	self.item_model.ui:addChild(sub_hp_lab)
end

function ClsSculptureEvent:showAddHPEffect()
	local _, hp_effect = clsCommonFuns:addNodeEffect(self.item_model.node, "jn_jiagu_health")
	hp_effect:Start()
	table.insert(self.hp_effects, hp_effect)

	local arr_action = CCArray:create()
	arr_action:addObject(CCDelayTime:create(1))
	arr_action:addObject(CCCallFunc:create(function()
		if self.hp_effects[1] then
			self.hp_effects[1]:Release()
			table.remove(self.hp_effects, 1)
		end
	end))
	self.item_model.ui:runAction(CCSequence:create(arr_action))
end

function ClsSculptureEvent:fireFromShip(params, ship, is_sound)
	if ship then
		local bullet = nil
		local function eff_action()
			self.bullets[bullet]:Release()
			self.bullets[bullet] = nil
			self:subHpEffect(params.sub_hp)
		end

		if is_sound then
			 audioExt.playEffect(cfg_music_info.FIRE_MEDIUM.res)
		end
		
		local ExploreBulletCls = require("gameobj/copyScene/copySceneBullet")
		local bullet_param = {
			targetNode = self.item_model.node,
			ship = ship,
			targetCallBack = eff_action,
			down = 30 --炮弹打中的位置下移down单位
		}
		bullet = ExploreBulletCls.new(bullet_param)
		self.bullets[bullet] = bullet
	else
		self:subHpEffect(params.sub_hp)
	end
	
	for key, value in pairs(params) do
		if key == "hp" then
			self:updataAttr(key, value)
		end
	end
end

-- function ClsSculptureEvent:touch(node)
--     if not node then return end
--     local event_id = node:getTag("scene_event_id")
--     if not event_id then
--         return
--     end
--     event_id = tonumber(event_id)
--     if event_id ~= self:getEventId() then
--         return
--     end

--     local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
--     local scene_layer = ClsSceneManage:getSceneLayer()
	
--     if self.player_camp ~= self.m_camp then
--         local Alert = require("ui/tools/alert")
--         Alert:warning({msg = cfg_error_info[849].message})
--     end
--     return true
-- end


function ClsSculptureEvent:release()
	if self.m_is_delete then
		return
	end

	if self.player_camp == self.m_camp then
		ClsSceneManage:doLogic("showResultTips", self.m_camp)
	end

	for k, v in pairs(self.hp_effects) do
		v:Release()
	end
	self.hp_effects = {}

	for k, v in pairs(self.bullets) do
		v:Release()
	end
	self.bullets = {}
	
	self:__endEvent()
end

return ClsSculptureEvent

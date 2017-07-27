--
-- Author: lzg0496
-- Date: 2017-01-17 17:24:58
-- Function: 副本炮塔

local port_battle_objects = require("game_config/copyScene/port_battle_objects")
local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local ClsPropEntity = require("gameobj/copyScene/copySceneProp")
local cfg_copy_scene_prototype = require("game_config/copyScene/copy_scene_prototype")
local cfg_music_info = require("game_config/music_info")
local cfg_qte_config = require("game_config/copyScene/qte_config")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ClsAlert = require("ui/tools/alert")
local cfg_ui_word = require("game_config/ui_word")
local clsCommonFuns = require("gameobj/commonFuns")

local clsBatteryEvent = class("clsBatteryEvent", ClsCopySceneEventObject)

local QTE_ACTION_CONFIG = {
	ATTACK = 1,
	COLLECT = 3,
}

function clsBatteryEvent:initEvent(prop_data)
	self.event_data = prop_data
	self.event_create_time = prop_data.create_time
	self.event_id = prop_data.id
	self.event_type = prop_data.type
	if (device.platform == "windows") then
		table.print(self.event_data)
	end
	self.config = port_battle_objects[prop_data.attr.index]
	local res = cfg_copy_scene_prototype[self.event_type].res
	local item = nil
	self.item_models = {}
	self.bullets = {}
	res = string.split(res, ";")
	for k, v in ipairs(res) do
		local params = {
			res = v, 
			hit_radius = cfg_copy_scene_prototype[self.event_type].hit_radius
		}
		item = ClsPropEntity.new(params)
		item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
		self.item_models[#self.item_models + 1] = item
	end
	self.item_model = item
	self.item_model.id = self.event_id
	self.item_model.node:setTag("scene_event_id", tostring(self.event_id))
	self.m_qte_attack_key = string.format("copy_event_id_%s_qte_attack_key", tostring(self.event_id))
	self.m_qte_supply_key = string.format("copy_event_id_%s_qte_supply_key", tostring(self.event_id))
	self.m_wait_reason = string.format("copy_event_id_%s_wait_1s", tostring(self.event_id))
	self.hp = self.event_data.attr.hp or 0
	self.event_data.attr.hp = self.hp
	self.max_hp = self.event_data.attr.max_hp
	self.hit_radius = self.config.hit_radius or 300
	self.m_attr = self.event_data.attr 
	self.m_camp = self.m_attr.camp
	self.item_model.shootNode = self.item_model.node:findNode("center", true)
	self.player_camp = getGameData():getSceneDataHandler():getMyCamp()
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index] = self.m_attr
	port_battle_datas[self.m_attr.index].event_obj = self
	ClsSceneManage:doLogic("setTurretVisible", self.m_attr.index, true)
	self.hp_effects = {}
end

function clsBatteryEvent:update(dt)
	local x, y = self.item_model:getPos()
	local scene_layer = ClsSceneManage:getSceneLayer()
	local px, py = scene_layer.player_ship:getPos()
	local dis = Math.distance(px, py, x, y) 
	if dis < self.hit_radius then
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

		if not self.is_supply then
			if self.player_camp == self.m_camp and ClsSceneManage:doLogic("isHasSupply") then
				self.is_supply = true
				self.m_event_layer:addActiveKey(self.m_qte_supply_key, function() 
					return self:getQteBtn(self.m_wait_reason, 0, function()
							if ClsSceneManage:doLogic("isNotCanInteractive") then
								return
							end

							audioExt.playEffect(cfg_music_info.UI_FIX.res)
							self:sendSalvageMessage()
						end, cfg_qte_config[QTE_ACTION_CONFIG.COLLECT].res) 
				end)
			end
		end
	else
		self.is_firing = false
		self.is_supply = false
		self.m_event_layer:removeActiveKey(self.m_qte_attack_key)
		self.m_event_layer:removeActiveKey(self.m_qte_supply_key)
		self:removeTimer()
	end

	self:updateTimerHander(dt)
end

function clsBatteryEvent:updataAttr(key, value)
	self.m_attr[key] = value
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index].attr = self.m_attr
	if "hp" == key then
		self.is_lock_touch = nil
		self.hp = value
		ClsSceneManage:doLogic("updateEventUI")
		ClsSceneManage:doLogic("setTurretHP", self.m_attr.index, self.hp / self.max_hp * 100)
	end
	local valuePercent = self.hp / self.max_hp * 100
	self.hpProgress:setPercentage(valuePercent)

	if "sub_hp" == key then
		self:subHpEffect(value)
	end

	if "add_hp" == key then
		local str = string.format(cfg_ui_word.STR_SUPPLY_ADD_HP, self.config.name, value)
		ClsAlert:warning({msg = str})
		self:showAddHPEffect()
	end
end

function clsBatteryEvent:fireCallBack()
	audioExt.playEffect(cfg_music_info.EX_ROCK_HIT.res)
end

function clsBatteryEvent:showAddHPEffect()
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

function clsBatteryEvent:release()
	if self.is_delete then
		return
	end
	if self.bullet then
		self.bullet:Release()
		self.bullet = nil
	end

	for k, v in pairs(self.item_models) do
		v:release()
		v = nil
	end

	for k, v in pairs(self.bullets) do
		v:Release()
	end
	self.bullets = {}

	for k, v in pairs(self.hp_effects) do
		v:Release()
	end
	self.hp_effects = {}

	self.item_models = {}

	self:__endEvent()
end

function clsBatteryEvent:__endEvent()
	if self.item_model then
		clsBatteryEvent.super.__endEvent(self)
		self.is_delete = true
		self.item_model = nil
	end
	self.m_event_layer:removeActiveKey(self.m_qte_supply_key)
	self.m_event_layer:removeActiveKey(self.m_qte_attack_key)
	ClsSceneManage:doLogic("setTurretVisible", self.m_attr.index, false)
	self.hp = 0
	self.m_attr.hp = 0
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index].attr = self.m_attr
end

function clsBatteryEvent:initUI()
	local hpProgressBg = self:createHpProgress()
	local valuePercent = self.hp / self.max_hp * 100
	self.hpProgress:setPercentage(valuePercent)
	self.item_model.ui:addChild(hpProgressBg)
	ClsSceneManage:doLogic("updateMap")
end

function clsBatteryEvent:touch(node)
end

function clsBatteryEvent:fireFromShip(params, ship, is_sound)
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

function clsBatteryEvent:subHpEffect(sub_hp_n)
	if tolua.isnull(self.item_model.ui) then
		return 
	end
	local ui_size = self.item_model.ui:getContentSize()
	local sub_hp_lab = createDamageWord(-sub_hp_n, nil, nil, nil, 1)
	sub_hp_lab:setPosition(ccp(ui_size.width/2, ui_size.height + 20))
	self.item_model.ui:addChild(sub_hp_lab)
end

return clsBatteryEvent

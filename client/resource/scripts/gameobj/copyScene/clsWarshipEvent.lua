--
-- Author: lzg0496
-- Date: 2017-01-17 17:25:09
-- Function: 巨舰

local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local cfg_copy_scene_prototype = require("game_config/copyScene/copy_scene_prototype")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
local ClsExploreShip3d = require("gameobj/explore/exploreShip3d")
local port_battle_objects = require("game_config/copyScene/port_battle_objects")
local cfg_music_info = require("game_config/music_info")
local cfg_qte_config = require("game_config/copyScene/qte_config")
local ClsAlert = require("ui/tools/alert")
local cfg_ui_word = require("game_config/ui_word")
local composite_effect = require("gameobj/composite_effect")
local clsCommonFuns = require("gameobj/commonFuns")
local port_battle_model = require("game_config/copyScene/port_battle_model")

local clsWarshipEvent = class("clsWarshipEvent", ClsCopySceneEventObject)

local QTE_ACTION_CONFIG = {
	ATTACK = 1,
	COLLECT = 3,
}

local QTE_ACTIVITY_TIME = 1

local left_pos_list = {ccp(10,70),ccp(39,62),ccp(64,61),ccp(95,55),ccp(111,55),ccp(123,44)}
local right_pos_list = {ccp(10,10),ccp(37,14),ccp(63,20),ccp(95,24),ccp(116,29),ccp(123,38)}

local function getCurBoatId(val)
	local cur_built_val = val or 1
	local obj_index = nil
	for _, info in ipairs(port_battle_model) do
		if info.build >= cur_built_val then
			obj_index = tonumber(info.model)
			break
		end
	end
	if obj_index and cfg_copy_scene_prototype[obj_index] then
		local boat_id = cfg_copy_scene_prototype[obj_index].special_attr["boatId"]
		if boat_id then
			return boat_id
		end
	end
end

clsWarshipEvent.initEvent = function(self, prop_data)
	self.create_time = CCTime:getmillistimeofCocos2d() / 1000
	local scene_layer = ClsSceneManage:getSceneLayer()
	self.event_data = prop_data
	self.event_create_time = prop_data.create_time
	self.event_id = prop_data.id
	self.event_type = prop_data.type

	if (device.platform == "windows") then
		table.print(self.event_data)
	end

	self.bullets = {} 
	self.config = table.clone(port_battle_objects[prop_data.attr.index])
	self.m_cfg_path = self.config.path
	
	local ship_id = getCurBoatId(self.event_data.attr.max_hp) or 18
	local ship_pos = ccp(prop_data.sea_pos.x, prop_data.sea_pos.y)
	self.m_ship = ClsExploreShip3d.new({
		id = ship_id,
		pos = ship_pos,
		speed = EXPLORE_BASE_SPEED,
		ship_ui = getSceneShipUI(),
		turn_speed = 60,
	})
	self.m_ship:setAngle(90)
	local scale = cfg_copy_scene_prototype[self.event_type].scale
	if scale >= 0 then
		self.m_ship.node:setScale(scale / 100)
	end
	self.m_ship.land = scene_layer:getLand()
	self.item_model = self.m_ship
	self.item_model.id = self.event_id
	self.item_model.node:setTag("scene_event_id", tostring(self.event_id))
	self.max_hp = self.event_data.attr.max_hp or 1
	self.hp = self.event_data.attr.hp or 0
	self.event_data.attr.hp = self.hp
	self.hit_radius = self.config.hit_radius or 300
	self.m_attr = self.event_data.attr 
	self.m_ship:setPause(true)
	self.m_camp = self.m_attr.camp
	self.player_camp = getGameData():getSceneDataHandler():getMyCamp()
	self.m_qte_supply_key = string.format("copy_event_id_%s_qte_supply_key", tostring(self.event_id))
	self.m_qte_attack_key = string.format("copy_event_id_%s_qte_attack_key", tostring(self.event_id))
	self.m_wait_reason = string.format("copy_event_id_%s_wait_1s", tostring(self.event_id))
	self.line = nil
	self.init_time = 0
	self.wait_pause_time = 0
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index] = self.m_attr
	port_battle_datas[self.m_attr.index].event_obj = self.item_model
	local dir_ship = "left" --默认第二阵营是左边的巨舰
	if self.m_camp == 3 then --默认第三阵营是右边的巨舰
		dir_ship = "right"
	end
	ClsSceneManage:doLogic("setShipVisible", dir_ship, true)
	ClsSceneManage:doLogic("setShipHp", dir_ship,  self.hp / self.max_hp * 100)
	self.hp_effects = {}
	self.btn_qte_time = 0
	self.target_pos = nil
	self.ship_move_b = false
	self.ship_show_fire = false
	self.ship_show_broken = false
	
	self.m_start_load_info = {
			index = 0,
			pass_rate = 0,
		}
end

--["warship_path"] = "[[30,90],[90,95],[115,85],[140,85],[155,95],[180,65]]"
clsWarshipEvent.convertPath = function(self, warship_path)
	local path = {}
	if string.len(warship_path) == 0 then return path end

	local t_warship_path = string.gsub(warship_path, "%[", "")
	t_warship_path = string.gsub(t_warship_path, "%]", "")
	t_warship_path = string.split(t_warship_path, ",")
	for i = 1, #t_warship_path, 2 do
		path[#path + 1] = ccp(tonumber(t_warship_path[i]), tonumber(t_warship_path[i + 1]))
	end
	return path
end

local math_abs = math.abs

clsWarshipEvent.update = function(self, dt)
	if self.m_is_delete then return end

	local ClsSceneManage = require("gameobj/copyScene/copySceneManage") 
	local scene_layer = ClsSceneManage:getSceneLayer()
	local translate1 = self.m_ship.node:getTranslationWorld()

	if self.lineAStar and not self.m_ship:isPause() then
		local sum_time = CCTime:getmillistimeofCocos2d() / 1000 - self.create_time - self.wait_pause_time - self.init_time
		if self.init_time == 0 then
			self.init_time = sum_time
			sum_time = 0
		end
		local cur_pos, pos_index, rate_n = self.lineAStar:getCurPos(sum_time)
		cur_pos = self.m_ship.land:tileSizeToCocos(ccp(cur_pos.x, cur_pos.y))

		self:setUiShipPos(pos_index, rate_n)
		LookAtPoint(self.item_model.node, Vector3.new(cur_pos.x, 0, - 2 * cur_pos.y))
		self.m_ship:setPos(cur_pos.x, cur_pos.y)
	elseif self.m_ship:isPause() then
		self.wait_pause_time = self.wait_pause_time + dt
	end
	ClsSceneManage:doLogic("updataEventPos", self)

	self.btn_qte_time = self.btn_qte_time + dt

	if self.btn_qte_time >= QTE_ACTIVITY_TIME then
		self.btn_qte_time = 0
		local x, y = self.item_model:getPos()
		local px, py = scene_layer.player_ship:getPos()
		local dis = Math.distance(px, py, x, y)

		if dis < self.hit_radius then
			if self.player_camp ~= self.m_camp then
				self.m_event_layer:addActiveKey(self.m_qte_attack_key, function() 
					return self:getQteBtn(self.m_wait_reason, 0, function()
							if ClsSceneManage:doLogic("isNotCanInteractive") then
								return
							end

							if ClsSceneManage:doLogic("isNotCanSailing") then
								ClsAlert:warning({msg = cfg_ui_word.STR_NOT_SAILING_TIP})
								self.is_supply = false
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

			if not self.is_supply then
				if self.player_camp == self.m_camp and ClsSceneManage:doLogic("isHasSupply") then
					self.is_supply = true
					self.m_event_layer:addActiveKey(self.m_qte_supply_key, function() 
						return self:getQteBtn(self.m_wait_reason, 0, function()
								if ClsSceneManage:doLogic("isNotCanSailing") then
									ClsAlert:warning({msg = cfg_ui_word.STR_NOT_SAILING_TIP})
									self.is_supply = false
									return
								end

								if ClsSceneManage:doLogic("isNotCanInteractive") then
									self.is_supply = true
									return
								end
								audioExt.playEffect(cfg_music_info.UI_FIX.res)
								self:sendSalvageMessage()
							end, cfg_qte_config[QTE_ACTION_CONFIG.COLLECT].res) 
					end)
				end
			end
		else
			self.is_supply = false
			self.m_event_layer:removeActiveKey(self.m_qte_supply_key)
			self.m_event_layer:removeActiveKey(self.m_qte_attack_key)
			self:removeTimer()
		end
	end

	self:updateTimerHander(dt)
end

clsWarshipEvent.setUiShipPos = function(self, pos_index_n, rate_n)
	if not self.lineAStar then return end
	local dir_ship = "left" --默认第二阵营是左边的巨舰
	if self.m_camp == 3 then --默认第三阵营是右边的巨舰
		dir_ship = "right"
	end

	local max_path_len = 6
	local raw_pos_index_n = pos_index_n
	if #self.config.path ~= max_path_len then
		pos_index_n = max_path_len - #self.config.path + raw_pos_index_n
		local pos_list = left_pos_list
		if self.m_camp == 3 then --默认第三阵营是右边的巨舰
			pos_list = right_pos_list
		end
		if raw_pos_index_n == self.m_start_load_info.index then
			rate_n = self.m_start_load_info.pass_rate + (rate_n * (1 - self.m_start_load_info.pass_rate))
		end
	end
	ClsSceneManage:doLogic("setShipPos", dir_ship, pos_index_n, rate_n)
end

clsWarshipEvent.updataAttr = function(self, key, value)
	self.m_attr[key] = value
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index].attr = self.m_attr

	if self.m_is_delete then return end

	if "hp" == key then
		self.is_lock_touch = nil
		self.hp = value
	end
	local valuePercent = self.hp / self.max_hp * 100
	self.hpProgress:setPercentage(valuePercent)

	local dir_ship = "left" --默认第二阵营是左边的巨舰
	local vs_pos_x = -160 
	local off_x = -35
	if self.m_camp == 3 then --默认第三阵营是右边的巨舰
		dir_ship = "right"
		vs_pos_x = 160
		off_x = 35
	end
	ClsSceneManage:doLogic("setShipHp", dir_ship, valuePercent)

	--注释掉，特效出来，再还原
	-- if valuePercent >= 50 and self.ship_show_fire then
	--      self.ship_show_fire = false
	--     self.m_ship:hideSmoke()
	-- elseif valuePercent < 50 then
	--     if not self.ship_show_fire then
	--         self.ship_show_fire = true
	--         self.m_ship:showSmoke()
	--         self.m_ship:showSuipian01()
	--     end
	-- end

	-- if valuePercent < 30 then
	--     if not self.ship_show_broken then
	--         self.ship_show_broken = true
	--         self.m_ship:broken()
	--         self.m_ship:showSuipian02()
	--     end
	-- elseif valuePercent > 30  then
	--     if self.ship_show_broken then
	--         self.ship_show_broken = false
	--         self.m_ship:unBroken()
	--     end
	-- end

	if "warship_path" == key then
		self.config.path = self:convertPath(value)
		local pos = self.m_ship.land:tileSizeToCocos(ccp(self.config.path[1].x, self.config.path[1].y))
		self.m_ship:setPos(pos.x, pos.y)
		self.lineAStar = require("ui/tools/clsLineAStar").new(self.config.path, EXPLORE_BASE_SPEED, MAP_TILE_SIZE)
		self.wait_pause_time = 0
		local max_len_n = #self.m_cfg_path
		local new_pos_index = max_len_n - #self.config.path + 1
		if new_pos_index > max_len_n then
			new_pos_index = max_len_n
		end
		if new_pos_index < 1 then
			new_pos_index = 1
		end
		self.m_start_load_info.index = 0
		
		local new_pos_start = self.config.path[1]
		local cfg_pos_start = self.m_cfg_path[new_pos_index]
		local new_pos_end = self.config.path[2]
		if new_pos_start and cfg_pos_start and new_pos_end then
			local new_dis_n = Math.distance(new_pos_start.x, new_pos_start.y, new_pos_end.x, new_pos_end.y)
			local cfg_dis_n = Math.distance(cfg_pos_start[1], cfg_pos_start[2], new_pos_end.x, new_pos_end.y)
			self.m_start_load_info.pass_rate = 1 - (new_dis_n/cfg_dis_n)
			local cur_pos, pos_index, rate_n = self.lineAStar:getCurPos(0)
			self.m_start_load_info.index = pos_index
			self:setUiShipPos(pos_index, 0)
		end
	end

	if "ship_move" == key then
		self.m_ship:setPause(value == 0)
	end

	if "sub_hp" == key then
		self:subHpEffect(value)
	end

	if "add_hp" == key then
		local str = string.format(cfg_ui_word.STR_SUPPLY_ADD_HP, self.config.name, value)
		ClsAlert:warning({msg = str})
		self:showAddHPEffect()
	end

	--在ship_move属性发生改变时下发下来。
	if "coordinate" == key then
		local str_pos = string.gsub(value, "%[", "")
		str_pos = string.gsub(str_pos, "%]", "")
		local pos = string.split(str_pos, ",")
		table.print(pos)
		pos = self.m_ship.land:tileSizeToCocos(ccp(pos[1], pos[2]))
		self.m_ship:setPos(pos.x, pos.y)
	end
end

clsWarshipEvent.showAddHPEffect = function(self)
	local _, hp_effect = clsCommonFuns:addNodeEffect(self.m_ship.node, "jn_jiagu_health")
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
	self.m_ship.ui:runAction(CCSequence:create(arr_action))
end

clsWarshipEvent.getPos = function(self)
	return self.m_ship:getPos()
end

clsWarshipEvent.fireCallBack = function(self)
	audioExt.playEffect(cfg_music_info.EX_ROCK_HIT.res)
end

clsWarshipEvent.initUI = function(self)
	local hpProgressBg = self:createHpProgress()
	local valuePercent = self.hp / self.max_hp * 100
	self.hpProgress:setPercentage(valuePercent)
	self.item_model.ui:addChild(hpProgressBg)
	hpProgressBg:setPosition(ccp(-20, 30))

	local name = ClsSceneManage:doLogic("getWarshipName")
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

clsWarshipEvent.__endEvent = function(self)
	ClsSceneManage:doLogic("updataEventVisible", self)
	if self.item_model then 
		self:showDieEffect(function()
			clsWarshipEvent.super.__endEvent(self)
			self.item_model:release()
			self.item_model = nil
			local dir_ship = "left" --默认第二阵营是左边的巨舰
			if self.m_camp == 3 then --默认第三阵营是右边的巨舰
				dir_ship = "right"
			end
			ClsSceneManage:doLogic("setShipVisible", dir_ship, false)
		end)
	end
end

-- 沉船反向
local drownDir
drownDir = function()
	local idx = math.random(1,3)
	local dir = 1
	if math.random(-1, 1) < 0 then dir = -1 end
	if math.random(-1, 1) > 0 then dir = 1 end
	local axi

	if idx == 1 then
		axi = "x"
	elseif idx == 2 then 
		axi = "y"
	else
		axi = "z"
	end
	return axi, dir
end

clsWarshipEvent.showDieEffect = function(self, callback)
	local pos = Vector3.new(0, 30, 0)
	self.item_model:showEffect("tx_die", nil, pos)
	audioExt.playEffect(cfg_music_info.UI_SKIN.res, false)
	self.item_model:showSuipian03()    
	local array = CCArray:create()
	local delay_tm = 1.5
	local drownTm = 3.5
	array:addObject(CCDelayTime:create(delay_tm))
	array:addObject(CCCallFunc:create(function()
		local scheduler = CCDirector:sharedDirector():getScheduler()
		local tick_count = 0
		--TODO:使用这个接口mainColor直接会被设置成1，1，1，
		SetTranslucent(self.item_model.node, nil, 1)
		local axi, dir = drownDir()
		local totalRotate = 0
		self.drownTimer = nil
		self.drownTimer = scheduler:scheduleScriptFunc(function(dt)     
			if self.item_model.node then 
				SetTranslucent(self.item_model.node, nil, (1 - tonumber(string.format("%0.1f",(tick_count/drownTm)))))
				tick_count = tick_count + dt
				local base_y = cfg_copy_scene_prototype[self.event_type].scale * -40 / 100
				if base_y == 0 then
					base_y = -40
				end
				self.item_model.node:setTranslationY(base_y * tick_count / drownTm)
				local base = cfg_copy_scene_prototype[self.event_type].scale * 2 / 100
				if base == 0 then
					base = 2
				end
				if totalRotate < math.rad(60) then
					if axi == "x" then 
						self.item_model.node:rotateX(dt/base*dir)
					elseif axi == "y" then
						self.item_model.node:rotateY(dt/base*dir)
					else
						self.item_model.node:rotateZ(dt/base*dir)
					end
				end
				totalRotate = totalRotate + dt/base
				if tick_count >= drownTm then
					local scheduler = CCDirector:sharedDirector():getScheduler() 
					scheduler:unscheduleScriptEntry(self.drownTimer)                   
					if type(callback) == "function" then
						callback()
					end
				end
			end
		end,0.02,false)
	end))
	self.item_model.ui:runAction(CCSequence:create(array))
end

clsWarshipEvent.fireFromShip = function(self, params, ship, is_sound)
	if self.m_is_delete then return end
	local target_uid = params.target
	if ship then
		local bullet = nil
		local eff_action
		eff_action = function()
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

clsWarshipEvent.subHpEffect = function(self, sub_hp)
	if tolua.isnull(self.item_model.ui) then
		return 
	end
	local ui_size = self.item_model.ui:getContentSize()
	local sub_hp_lab = createDamageWord(-sub_hp, nil, nil, nil, 1)
	sub_hp_lab:setPosition(ccp(ui_size.width/2, ui_size.height + 20))
	self.item_model.ui:addChild(sub_hp_lab)
end

clsWarshipEvent.release = function(self)
	local port_battle_datas = ClsSceneManage:getSceneAttr("port_battle_datas")
	port_battle_datas[self.m_attr.index] = nil

	if self.m_is_delete then
		return
	end

	if self.player_camp == self.m_camp then
		ClsSceneManage:doLogic("showResultTips", self.m_camp)
	end
	
	if self.bullet then
		self.bullet:Release()
		self.bullet = nil
	end

	for k, v in pairs(self.bullets) do
		v:Release()
	end
	self.bullets = {}

	for k, v in pairs(self.hp_effects) do
		v:Release()
	end
	self.hp_effects = {}
	self.m_event_layer:removeActiveKey(self.m_qte_supply_key)
	self.m_event_layer:removeActiveKey(self.m_qte_attack_key)
	self.m_is_delete = true
	self:__endEvent()
end

return clsWarshipEvent


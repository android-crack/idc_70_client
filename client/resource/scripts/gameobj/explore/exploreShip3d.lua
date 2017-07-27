-- 探索船
local boat_info = require("game_config/boat/boat_info")
local role_info = require("game_config/role/role_info")
local progressTimer = require("ui/tools/ProgressTimer")
local exploreWalk = require("gameobj/explore/exploreWalk")
local composite_effect = require("gameobj/composite_effect")
local prosper_info = require("game_config/prosper/prosper_info")
local sailor_info = require("game_config/sailor/sailor_info")
local info_title = require("game_config/title/info_title")
local CompositeEffect = require("gameobj/composite_effect")
local scheduler = CCDirector:sharedDirector():getScheduler()
local Boat = require("gameobj/ship3d")
local tool = require("module/dataHandle/dataTools")
local ExploreShip = class("ExploreShip", Boat)
local ui_word = require("scripts/game_config/ui_word")
local guild_badge = require("game_config/guild/guild_badge")
local port_info = require("game_config/port/port_info")
local on_off_info = require("game_config/on_off_info")
local Alert = require("ui/tools/alert")
local cfg_scene_title = require("game_config/copyScene/scene_title")

local TAB_ADVENTURE = 1
local TAB_NAVY = 2
local TAB_PIRATE = 3

local MAX_DT_TIME = 0.15

local head_bg_res = {
	[TAB_ADVENTURE] = "adventure",
	[TAB_NAVY] = "navy",
	[TAB_PIRATE] = "pirate",
}

local SAIL_UP_STATE   = 1   --升帆状态
local SAIL_DOWN_STATE = 0   --降帆状态
local TITLE_GROUP_ID = 2
local FOLLOW_AI = "explore_follow_ai"
ExploreShip.ctor = function(self, item)

	self.m_is_vip_wave = item.is_vip_wave or false
	item.parent = Explore3D:getLayerShip3d()
	ExploreShip.super.ctor(self, item)
	self.m_is_lock_move = false
	self.player_uid = item.player_uid
	self.activeAttack = item.activeAttack
	self.is_sea_player = item.is_sea_player
	self.playerSeaShip = item.playerSeaShip
	self.serverEventID = item.serverEventID
	self.isPortShip = item.isPortShip
	self.isOver = item.isOver
	self.is_click = item.is_click --是否可以点击船
	self.is_bot = item.is_bot --机器人
	self.camp = item.camp or CAMP_TYPE_NAVY
	self.item_info = item
	self.player_name = item.name
	self.player_level = item.player_level
	self.role_id = item.role_id
	self.is_red_name_status = false
	self.m_is_fighting = false
	self.m_is_ghost = false
	self.m_ship_flow_state_name = nil
	self.m_is_check_camera_follow = false
	self.m_free_camera_pos = nil
	self.player_name_lab = nil
	self.ship_update_forward_callback = nil
	self.next_trans_info = nil
	self.m_player_head_sprs = {}
	self.m_red_name_attack = {}
	self.m_red_name_attack.is_attack = false
	self.m_red_name_attack.btn = nil

	self.m_trade_attack = {}
	self.m_trade_attack.is_attack = false
	self.m_trade_attack.btn = nil

	--ai相关
	self.new_ai = {}
	self.running_ai = {}
	self.is_add_ai = false
	--ai相关 end
	if item.is_player then    -- 自己的船
		--self:createHp()
		self.moveStatus = SAIL_UP_STATE
		self:regAnimationEvent() --注册动画播放事件
	else                      -- 掠夺的船
		--self:createName(item)
	end
	self:createName(item)
end

ExploreShip.initUI = function(self)
	self.ui = CCNode:create()
	self.ship_ui:addChild(self.ui, 0)
	self.tips_ui = CCNode:create()
	self.ship_ui:addChild(self.tips_ui, 1)
end

ExploreShip.initBoatEffect = function(self)
	-- 船体公共特效配置
	self.effect_control:preload(string.format("%sboat.modelparticles", EFFECT_3D_PATH))
	self.effect_control:preload(string.format("%sboat%0.2d.modelparticles", EFFECT_3D_PATH, self.boat_effect_id))
	self:setIsShowVipWave(self.m_is_vip_wave, true)
end

local key_to_effect = {
	[true] = "vipwave",
	[false] = "wave",
}
ExploreShip.setIsShowVipWave = function(self, is_vip_wave, is_first_set)
	if self.m_is_vip_wave ~= is_vip_wave or (true == is_first_set) then
		if true ~= is_first_set then
			self.effect_control:hide(key_to_effect[self.m_is_vip_wave])
		end
		self.m_is_vip_wave = is_vip_wave
		-- 将默认的特效开启
		self.effect_control:show(nil, key_to_effect[self.m_is_vip_wave])
		self.effect_control:show(nil, "shadow")
	end
end

ExploreShip.getPlayerName = function(self)
	return self.player_name
end

ExploreShip.getPlayerLevel = function(self)
	return self.player_level
end

ExploreShip.getPlayerUid = function(self)
	return self.player_uid or 0
end

ExploreShip.getIconId = function(self)
	if self.item_info and self.item_info.icon then
		return tonumber(self.item_info.icon)
	end
	return 0
end

ExploreShip.getRoleId = function(self)
	return self.role_id
end

ExploreShip.setShipMoveStatus = function(self, value)
	self.moveStatus = value
end

ExploreShip.getShipMoveStatus = function(self)
	return self.moveStatus
end

ExploreShip.regAnimationEvent = function(self)
	local sailupClip = self.animation:getClip(ani_name_t.sailup)
	sailupClip:addEndListener("scripts/gameobj/gameplayFunc.lua#exploreShipAnimationEnd")
	local saildownClip = self.animation:getClip(ani_name_t.saildown)
	saildownClip:addEndListener("scripts/gameobj/gameplayFunc.lua#exploreShipAnimationEndUp")
end

ExploreShip.setSpeedAdd = function(self, value)
	self.hasSpeeAdd = value
end

ExploreShip.setNextTranslation = function(self, translation, end_callback)
	self.next_trans_info = {}
	self.next_trans_info.trans = translation
	self.next_trans_info.call_back = end_callback
end

ExploreShip.update = function(self, dt) --此时间是每帧时间的1000分之一
	--防止卡帧dt值过大
	if dt > MAX_DT_TIME then dt = MAX_DT_TIME end 

	if not self.land then return end
	if self.is_add_ai then
		self:updateAI(dt)
	end
	if self.is_pause or self.m_is_lock_move then
		self:updateUI(dt)
		return
	end
	self:updatePosition(dt)
	self:updateUI(dt)
	self:updateForward(dt)
	self:updateRotate(dt)


	----------------------------------------------------------
	-- modify By Hal 2015-08-05, Type(REBUILD) - Redmine 11902
	if self.effect_control ~= nil then
		self.effect_control:update( dt );				-- dt 单位：秒
	end
	----------------------------------------------------------
end

ExploreShip.updateUI = function(self, dt)
	local translate = self.node:getTranslationWorld()
	local pos = gameplayToCocosWorld(translate)
	if not tolua.isnull(self.ui) then
		self.ui:setPosition(pos)
	end
	if not tolua.isnull(self.dialog) then
		self.dialog:setPosition(pos)
	end
	if not tolua.isnull(self.tips_ui) then
		self.tips_ui:setPosition(pos)
	end
end

ExploreShip.updatePosition = function(self, dt)
	local speed = nil
	if self.is_use_auto_speed then
		speed = self.auto_speed
	else
		speed = self.speed * self:getSpeedRate()
	end
	local tran = self.node:getForwardVectorWorld():normalize()
	tran:scale(speed * dt)
	local translate = self.node:getTranslationWorld()

	if self.next_trans_info and self.next_trans_info.trans then
		local next_tran = Vector3.new()
		Vector3.subtract(self.next_trans_info.trans, translate, next_tran)

		if next_tran:length() < tran:length() then
			tran:set(next_tran:x(), next_tran:y(), next_tran:z())
			if self.next_trans_info.call_back then
				self.next_trans_info.call_back()
			end
			self.next_trans_info = nil
		end
	end


	local vec3 = Vector3.new()
	Vector3.add(translate, tran, vec3)
	local screen_pos = Vector3ToScreen(vec3, Explore3D:getScene():getActiveCamera())

	if exploreWalk.checkCollision(self, screen_pos) then
		self.node:translate(tran)
		if self.ship_update_forward_callback then
			local pos = gameplayToCocosWorld(tran)
			self.ship_update_forward_callback(pos)
		end
		self:updateMapUI(dt)
		self:updateChildsPos(dt)
	end

	if self.m_is_check_camera_follow then
		self:updateCameraFollow(screen_pos)
	end
end

ExploreShip.setShipUpdateForwardCallback = function(self, callback)
	self.ship_update_forward_callback = callback
end

ExploreShip.updateMapUI = function(self, dt)
	--TODO 子类去重写---------------
end

ExploreShip.updateChildsPos = function(self, dt)
	--TODO 子类去重写---------------
end

ExploreShip.updateCameraFollow = function(self, screen_pos)
	local collision_x = nil
	collision_x = exploreWalk.checkLandPosX(screen_pos)

	local collision_y = nil
	collision_y = exploreWalk.checkLandPosY(screen_pos)
	local ship_pos = self.node:getTranslationWorld()

	if not self.m_free_camera_pos then
		self.m_free_camera_pos = ship_pos
	end

	if collision_x then
		self.m_free_camera_pos:z(ship_pos:z())
	end

	if collision_y then
		self.m_free_camera_pos:x(ship_pos:x())
	end
	if collision_x and collision_y then --如果到了边界的四个角
		local colli_pos = exploreWalk.getCollisionPos(screen_pos)
		if colli_pos then
			self.m_free_camera_pos = cocosToGameplayWorld(colli_pos)
		end
	end
	if collision_x or collision_y then
		--
	else
		self.m_free_camera_pos = nil
	end
	CameraFollow:SetFreeMove(self.m_free_camera_pos)
end

ExploreShip.updateForward = function(self, dt)
	if not self.is_need_turn then return end

	local dangle = dt*self.turn_speed
	if not self:checkTurnStop(dangle) then
		if self.turn_type == 1 then
			self.node:rotateY(math.rad(-dangle))
		else
			self.node:rotateY(math.rad(dangle))
		end
	end
end


ExploreShip.checkTurnStop = function(self, dangle)
	local forward = self.node:getForwardVectorWorld()
	local boat_pos = self.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(self.target_pos, boat_pos, dir)
	local angle = math.deg(Vector3.angle(forward, dir))

	if angle < dangle then
		LookForward(self.node, dir)
		self.is_need_turn = false
		self.turn_type = 0
		local boatID = 9
		if self.id ~= boatID then
			if self.moveStatus == SAIL_UP_STATE then
				self:playAnimation(ani_name_t["move"..self.ani_post_fix], true)
			else
				self:playAnimation(ani_name_t["move2"..self.ani_post_fix], true)
			end
		else
			self:playAnimation(ani_name_t["move"..self.ani_post_fix], true)
		end
		return true
	end
end

ExploreShip.rotateStop = function(self)
	self.is_need_rotate = false
	self.is_need_turn = false
	self.rotate_angle = 0
	if self.moveStatus == SAIL_UP_STATE then
		self:playAnimation(ani_name_t["move"..self.ani_post_fix], true)
	else
		self:playAnimation(ani_name_t["move2"..self.ani_post_fix], true)
	end
end

ExploreShip.playSailAnimation = function(self, sailState)
	if sailState == SAIL_UP_STATE then
		self:playAnimation(ani_name_t.saildown, false)
	else
		self:playAnimation(ani_name_t.sailup, false)
	end
end

ExploreShip.moveToTPos = function(self, target_tx, target_ty, is_use_auto_speed, tile_size, end_callback)
	local p = ccp(self:getPos())
	local pos_st = self.land:tileToCocos(p)
	if target_tx == pos_st.x and target_ty == pos_st.y then
		self.is_use_auto_speed = false
		if end_callback then
			end_callback()
		end
	else
		self:stopAutoHandler()
		local callBack
		callBack = function()
			self.is_use_auto_speed = false
			if end_callback then
				end_callback()
			end
		end
		self.is_use_auto_speed = is_use_auto_speed
		local offset_x = math.abs(target_tx - pos_st.x)
		local offset_y = math.abs(target_ty - pos_st.y)
		local cut_offset = math.abs(offset_x - offset_y)
		local max_offset = math.max(offset_x, offset_y)
		self.auto_speed = (max_offset - cut_offset)*tile_size + cut_offset*tile_size*1.42
		self:goToDesitinaion(ccp(target_tx, target_ty), callBack)
	end
end

ExploreShip.stopAutoHandler = function(self)
	ExploreShip.super.stopAutoHandler(self)
	self.is_use_auto_speed = false
end

ExploreShip.moveTo = function(self, pos)
	if self.is_need_rotate then return end

	-- 大于一定角切换动作
	local forward = self.node:getForwardVectorWorld()
	local boat_pos = self.node:getTranslationWorld()
	local dir = Vector3.new()
	Vector3.subtract(pos, boat_pos, dir)
	local result = Vector3.dot(dir:normalize(), forward:normalize())

	self.target_pos:set(pos:x(), 0, pos:z())
	self.is_need_turn = true


	local is_cross_ani = true
	if result > 0.85 then
		is_cross_ani = false
	end

	if IsPointAtRight(self.node, pos) then
		self.turn_type = 1
		if is_cross_ani then
			local boatID = 9
			if self.id ~= boatID then
				if self.moveStatus == SAIL_UP_STATE then
					self:playAnimation(ani_name_t["turnRight"..self.ani_post_fix], true)
				else
					self:playAnimation(ani_name_t["turn4"..self.ani_post_fix], true)
				end
			else
				self:playAnimation(ani_name_t["turnRight"..self.ani_post_fix], true)
			end
		end
	else
		self.turn_type = -1
		if is_cross_ani then
			local boatID = 9
			if self.id ~= boatID then
				if self.moveStatus == SAIL_UP_STATE then
					self:playAnimation(ani_name_t["turnLeft"..self.ani_post_fix], true)
				else
					self:playAnimation(ani_name_t["turn3"..self.ani_post_fix], true)
				end
			else
				self:playAnimation(ani_name_t["turnLeft"..self.ani_post_fix], true)
			end
		end
	end
end


ExploreShip.createHp = function(self)
	self.food_hp = progressTimer.new({backgr = "#common_bar_bg1.png", progress = "#common_bar1.png"})
	self.food_hp:setScaleX(0.47)
	self.food_hp:setScaleY(0.56)
	self.food_hp:setPosition(0, 80)
	self.ui:addChild(self.food_hp, 5)
	local bar_size = self.food_hp:getProgressBgSize()
	local food_sp = display.newSprite("#explore_food.png", -bar_size.width * 0.6, 0)
	food_sp:setScale(0.57)
	self.food_hp:addChild(food_sp)
	local supplyData = getGameData():getSupplyData()
	local food_rate = supplyData:getCurFood()/supplyData:getTotalFood()*100
	self.food_hp:setPercentage(food_rate)

	self.sailor_hp = progressTimer.new({backgr = "#common_bar_bg1.png", progress = "#common_bar1.png"})
	self.sailor_hp:setScaleX(0.47)
	self.sailor_hp:setScaleY(0.56)
	self.sailor_hp:setPosition(0, 50)
	self.ui:addChild(self.sailor_hp, 5)
	local sailor_sp = display.newSprite("#explore_seaman.png", -bar_size.width * 0.6, 0)
	sailor_sp:setScale(0.57)
	self.sailor_hp:addChild(sailor_sp)
	local sailor_rate = supplyData:getCurSailor()/supplyData:getTotalSailor()*100
	self.sailor_hp:setPercentage(sailor_rate)
end

ExploreShip.setFoodHp = function(self, cur_food)
	local supplyData = getGameData():getSupplyData()
	local rate = cur_food/supplyData:getTotalFood()*100
	self.food_hp:setPercentage(rate)
end

ExploreShip.setSailorHp = function(self, cur_sailor)
	local supplyData = getGameData():getSupplyData()
	local rate = cur_sailor/supplyData:getTotalSailor()*100
	self.sailor_hp:setPercentage(rate)
end

ExploreShip.createLevelIcon = function(self, parent, icon_pos)
	local level_str = "Lv." .. tostring(self.item_info.player_level)
	local label_level = createBMFont({text = level_str, fontFile = FONT_CFG_1, size = 16,
						color = ccc3(dexToColor3B(COLOR_WHITE_STROKE)), x = icon_pos.x, y = icon_pos.y - 18})
	self.label_level = label_level
	parent:addChild(label_level, 3)
end

ExploreShip.createSailorUpLevelEffect = function(self, sailor_id,cell_back)
	if not tolua.isnull(self.ui) then

		local sailor_name = sailor_info[sailor_id].name
		local level_name = "LEVEL UP!"
		local label_name  = createBMFont({text = sailor_name, fontFile = FONT_CFG_1, size = 16,
							color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = 70, y = 10})

		local level_up  = createBMFont({text = level_name, fontFile = FONT_CFG_1, size = 16,
							color = ccc3(dexToColor3B(COLOR_GRASS_STROKE)), x = 0, y = 25})

		label_name:addChild(level_up)
		self.ui:addChild(label_name)

		local close_array = CCArray:create()
		close_array:addObject(CCMoveBy:create(0.5, ccp(0, 15)))
		close_array:addObject(CCCallFunc:create(function (  )
			CompositeEffect.new("tx_0047" ,-10 ,-80, level_up)
		end))
		close_array:addObject(CCDelayTime:create(1.6))
		close_array:addObject(CCCallFunc:create(function (  )
				level_up:removeFromParentAndCleanup(true)
				level_up = nil
				label_name:removeFromParentAndCleanup(true)
				label_name = nil
				print("----createSailorUpLevelEffect---")

				cell_back()			
		end))
		label_name:runAction(CCSequence:create(close_array))

	else
		print("----createSailorUpLevelEffect---null")
		cell_back()
	end
end

ExploreShip.updateLevel = function(self, level)
	level = level or 0
	if not tolua.isnull(self.label_level) then
		self.item_info.player_level = level
		local level_str = "Lv." .. tostring(self.item_info.player_level)
		self.label_level:setString(level_str)
	end
end

ExploreShip.createSailorIcon = function(self, parent, icon_pos)
	local role_cfg_item = role_info[self.role_id]
	local job_id = role_cfg_item.job_id
	local job_str = SAILOR_JOB_BG[job_id].normal
	local captain_bg = display.newSprite(string.format("#%s", job_str))
	captain_bg:setScale(0.9)
	captain_bg:setPosition(ccp(icon_pos.x, icon_pos.y - 20))
	parent:addChild(captain_bg, 0)
	self.m_player_head_sprs.captain_bg_spr = captain_bg

	local icon_res = role_cfg_item.res
	local icon_sprite = display.newSprite(icon_res)
	icon_sprite:setPosition(ccp(icon_pos.x, icon_pos.y - 10))
	icon_sprite:setScale(0.3)
	parent:addChild(icon_sprite, 1)
	self.m_player_head_sprs.role_icon_spr = icon_sprite
	return captain_bg, icon_sprite
end

ExploreShip.createSailorName = function(self, parent, icon_pos)
	local color_n = self.item_info.name_color or COLOR_WHITE_STROKE
	local label_name = createBMFont({text = self.item_info.name,color = ccc3(dexToColor3B(color_n)), size = 16,
		x = icon_pos.x, y = icon_pos.y - 5})
	parent:addChild(label_name)
	label_name:setAnchorPoint(ccp(0, 0.5))
	self.player_name_lab = label_name
	self.item_info.name_color = color_n
	return label_name
end

ExploreShip.updatePlayerNameColor = function(self, color_n)
	if self.item_info.name_color ~= color_n then
		self.item_info.name_color = color_n
		if not tolua.isnull(self.player_name_lab) then
			self.player_name_lab:setColor(ccc3(dexToColor3B(color_n)))
		end
	end
end

ExploreShip.setIsRedNameStatus = function(self, is_red_name_status)
	self.is_red_name_status = is_red_name_status
	if self.is_red_name_status then
		self:updatePlayerNameColor(COLOR_RED_STROKE)
	else
		self:updatePlayerNameColor(COLOR_WHITE_STROKE)
	end
end

ExploreShip.setIsGhost = function(self, is_ghost)
	if not self.m_ship_flow_state_name then
		self.m_ship_flow_state_name = self:getCurFlowState()
	end

	if self.m_is_ghost == is_ghost then
		return
	end
	self.m_is_ghost = is_ghost
	if self.m_is_ghost then
		self:setFlowState("texture_flow2")
	else
		self:setFlowState("default")
		if "default" ~= self.m_ship_flow_state_name then
			self:setFlowState(self.m_ship_flow_state_name)
		end
	end
end

ExploreShip.setIsFighting = function(self, is_fighting)
	if self.m_is_fighting == is_fighting then
		return
	end
	self.m_is_fighting = is_fighting
	if self.m_is_fighting then
		self:showEffect("dao")
	else
		self:hideEffect("dao")
	end
end

ExploreShip.getTipsUI = function(self)
	return self.tips_ui
end

ExploreShip.getCaptainBgSpr = function(self)
	return self.m_player_head_sprs.captain_bg_spr
end

ExploreShip.updateStatus = function(self, star_level)
	if self.m_is_ghost then
		return
	end
	ExploreShip.super.updateStatus(self, star_level)
end


ExploreShip.createGuildAndTitleInfoIcon = function(self, parent)

	local ignore_ids = {20029,20030,20031}

--[[
	目前只处理 info_title.xls 中set为1的称号类型的处理 旧的代码先注释(纹饰,多行之类的弃用)
	逻辑:
		是否有
			商会,商会职位
			称号,竞技场称号

		显示规则 (第一行是名字 在名字上加商会信息和称号信息,不超过三行)
			如果没有称号,有商会,
				有商会职位
					商会和商会职位 作为两行处理,也就是总共三行. 名字/商会职位/商会
				没有商会职位
					总共两行. 名字/商会
			如果有称号,有商会
				有商会职位
					商会和商会职位作为一行处理,称号一行,总共三行. 名字/商会+商会职位/称号
				没有商会职位
					总共三行. 名字/商会/称号

		称号
			竞技场称号图片的显示要特殊处理 class 不为 -1

]]
	-- test

	local data = self.item_info

	-- data.guild_icon = "1"

	-- print('----------data')
	-- table.print(data)

	local is_exist_guild = data.guild_name and data.guild_name ~= ""
	local is_exist_title = data.title.title_id ~= 0 and ( not (ignore_ids[data.title.title_id] and true or false ))
	local is_exist_guild_job = data.guild_job > 1
	local is_exist_title_arean = (data.title.class ~= -1)

	local str_line_1 = nil
	local str_line_2 = nil
	local rich_label_guild = nil
	local rich_label_title = nil

	local str_title = data.title.performance
	local str_guild_name = "$(font:FONT_CFG_1,COLOR_LIGHT_BLUE_STROKE)"..data.guild_name
	local str_guild_job = "$(font:FONT_CFG_1,COLOR_YELLOW_STROKE)"..returnProfessionStr(data.guild_job)

	local str_guild_icon_res = nil

	if data.guild_icon ~= "" then
		str_guild_icon_res = "#"..guild_badge[tonumber(data.guild_icon)].explore
	end

	-- 节点
	local node = display.newNode()
	local node_guild_icon = nil
	local node_guild_name = nil
	local node_guild_job = nil
	local node_title = nil


	node:setPosition(ccp(10,130))
	parent:addChild(node)

	-- local
	local createRichLabel = createRichLabel
	local display = display
	local string_format = string.format

	local createRichLabel_byStr
	createRichLabel_byStr = function(str)
		local node = createRichLabel(str,160,20,16,nil,true)
		node:ignoreAnchorPointForPosition(false)
		node:setAnchorPoint(ccp(0,0))
		return node
	end

	-- 如果有称号
	if is_exist_title then
		-- 如果有商会职位
		node_title = createRichLabel_byStr(str_title)
		self.title_node = node_title
		node:addChild(node_title)
		local set_x = 0
		local set_y = 0
		local figure_offset = data.title.picture_offset
		if figure_offset and not table.is_empty(figure_offset) then
			set_x = figure_offset[1]
			set_y = figure_offset[2]
		end

		if is_exist_guild then
			-- 商会会徽
			node_guild_icon = display.newSprite(str_guild_icon_res)
			node_guild_icon:setScale(0.8)
			node:addChild(node_guild_icon)
			-- 商会名字
			if is_exist_guild_job then
				node_guild_name = createRichLabel_byStr(str_guild_name..str_guild_job)
			else
				node_guild_name = createRichLabel_byStr(str_guild_name)
			end
			node_guild_name:setPosition(ccp(16,-12))
			node:addChild(node_guild_name)
			node_title:setPosition(ccp(-30 + set_x, 5 + set_y))
		else
			node_title:setPosition(ccp(-30 + set_x,-20 + set_y))
		end
	-- 如果没有称号
	else
		-- 如果有商会
		if is_exist_guild then
			-- 如果有商会职位
			-- 商会会徽
			node_guild_icon = display.newSprite(str_guild_icon_res)
			node_guild_icon:setScale(0.8)
			node:addChild(node_guild_icon)

			-- 商会名字
			node_guild_name = createRichLabel_byStr(str_guild_name)
			node_guild_name:setPosition(ccp(16,-12))
			node:addChild(node_guild_name)

			if is_exist_guild_job then
				-- 职位
				node_guild_job = createRichLabel_byStr(str_guild_job)
				node:addChild(node_guild_job)
				self.guild_job = node_guild_job
				node_guild_job:setPosition(ccp(-10,12))
			end
		end
	end

	-- 竞技场类型的称号特殊处理 存在称号
	if data.title.class and data.title.class ~= -1 and node_title then
		local data = data.title.class
		local rank_type = math.floor(data/10)+1
		local rank_lv = data%10

		local str_res_bg = string_format("#arena_rank_%d.png",rank_type)
		local roman = {'i','ii','iii','iv','v','vi'}
		local str_res_icon = string_format("#arena_rank_%s.png",roman[rank_lv])
		local node_bg = display.newSprite(str_res_bg)
		node_bg:setAnchorPoint(ccp(0,0))
		local node_lv = display.newSprite(str_res_icon)
		node_lv:setAnchorPoint(ccp(0,0))

		node_bg:addChild(node_lv)
		node_bg:setScale(0.24)
		node_title:addChild(node_bg)

		if is_exist_guild then
			node_bg:setPosition(ccp(-35,-5))
			node_title:setPosition(ccp(20,18))
		else
			node_bg:setPosition(ccp(-35,-5))
			node_title:setPosition(ccp(23,-8))
		end
	end

end

ExploreShip.resetNameInfo = function(self, item, is_keep_tips_chat)
	self.ui:removeAllChildrenWithCleanup(true)
	if not is_keep_tips_chat then
		self.tips_ui:removeAllChildrenWithCleanup(true)
	end
	self.player_name = item.name
	self.player_level = item.player_level
	self.role_id = item.role_id or self.role_id
	self.player_uid = item.player_uid or self.player_uid

	self.m_red_name_attack = {}
	self.m_red_name_attack.is_attack = false
	self.m_red_name_attack.btn = nil

	self.m_trade_attack = {}
	self.m_trade_attack.is_attack = false
	self.m_trade_attack.btn = nil

	for k, v in pairs(item) do
		if v then
			self.item_info[k] = v
		end
	end
	self:createName(item)
end

ExploreShip.createName = function(self, item)
	local posX = 10
	local start_y = 110
	local icon_pos = ccp(-38, 140)
	local level_pos_y = 110


	if item.role_id then
		self:createSailorIcon(self.ui, icon_pos)
	end
	if item.player_level then
		self:createLevelIcon(self.ui, ccp(icon_pos.x, level_pos_y))
	end

	self.front_name = self:createFrontName(item)
	posX = 35
	local posY = start_y
	if item.name then
		local label_name = self:createSailorName(self.ui, ccp(posX+5, posY))
		self.sailor_name = label_name
		if self.front_name then
			self.front_name:setPosition(ccp(posX - 15 , posY - 4.5))
		end

		posY = posY + label_name:getContentSize().height
		if not item.title then --当没有称号的时候，出海时玩家的名字往上调整
			label_name:setPosition(ccp(posX+5, posY))
			if self.front_name then
				-- 如果是NPC，没有称号，名字前移
				self.front_name:setPosition(ccp(posX - 15 , posY))
			else
				label_name:setPosition(ccp(posX - 30 , posY))
			end
		else
			posY = start_y + label_name:getContentSize().height / 2 + 5
		end
	end

	if item.force_power_res then
		self:createForcePowerIcon(self.ui, ccp(posX - 70, posY))
	end

	if item.title then
		self:createGuildAndTitleInfoIcon(self.ui)
	end
end

ExploreShip.getSailorName = function(self)
	return self.sailor_name
end

ExploreShip.setPlayerNamePos = function(self, pos)
	if not tolua.isnull(self.player_name) then
		self.player_name:setPosition(pos)
	end 
end

ExploreShip.createForcePowerIcon = function(self, parent, icon_pos)
	local force_power_icon = display.newSprite(self.item_info.force_power_res)
	force_power_icon:setPosition(icon_pos)
	parent:addChild(force_power_icon)
end

ExploreShip.createFrontName = function(self, item)
	local playersDetailData = getGameData():getPlayersDetailData()
	local nobility_id = playersDetailData:getPlayerInfoNobility(item.player_uid)
	if not nobility_id then
		return
	end

	local nobility_data = getGameData():getNobilityData()
	local nobility_info = nobility_data:getNobilityDataByID(nobility_id)
	if not nobility_info then
		return
	end
	local file_name = nobility_info.peerage_before

	local sprite = display.newSprite(file_name)
	sprite:setScale(0.65)
	if file_name ~= "#title_name_knight.png" then
		-- 如果称号是骑士，则没有特效
		effect = CompositeEffect.new("tx_0197" , 6 , 21 , sprite)
		effect:setScale(1.1)
	end
	self.ui:addChild(sprite)
	return sprite
end

ExploreShip.initCollision = function(self)
	local boundingSphere = self.node:getBoundingSphere()
	self.node:setCollisionObject("GHOST_OBJECT", PhysicsCollisionShape.sphere(boundingSphere:radius()))
end

ExploreShip.removeCollision = function(self)
	local collsionObject = self.node:getCollisionObject()
	if collsionObject then
		self.node:setCollisionObject("NONE")
	end
end

ExploreShip.setRotateAngle = function(self, angle)
	if self.is_ban_rotate then return end
	if self.is_need_rotate then return end

	self.rotate_angle = angle
	self.is_need_rotate = true
	self.is_need_turn = false

	if self.rotate_angle < -5 then
		self:playAnimation(ani_name_t["turnRight"..self.ani_post_fix], true)
	elseif self.rotate_angle > 5 then
		self:playAnimation(ani_name_t["turnLeft"..self.ani_post_fix], true)
	end
end

ExploreShip.setActive = function(self, is_visible)
	self:setPathNode(is_visible)
	if self.node then
		self.node:setActive(is_visible)
	end
	if not tolua.isnull(self.ui) then
		self.ui:setVisible(is_visible)
	end
	self:stopAutoHandler()
end

ExploreShip.setLockMove = function(self, status)
	self.m_is_lock_move = status
end

ExploreShip.getIsLockMove = function(self)
	return self.m_is_lock_move
end

ExploreShip.setIsCheckCameraFollow = function(self, is_follow)
	self.m_is_check_camera_follow = is_follow
end

ExploreShip.getTargetTotalSpeed = function(self)
	local speed = self.speed * self:getSpeedRate()
	if self.is_use_auto_speed then
		speed = self.auto_speed
	end
	return speed
end

ExploreShip.getForwardPos = function(self)
	local speed_rate = self:getSpeedRate()
	local tran = self.node:getForwardVectorWorld():normalize()
	tran:scale(self.speed * speed_rate)
	local translate = self.node:getTranslationWorld()
	local t_vec3 = Vector3.new()
	Vector3.add(translate, tran, t_vec3)
	local t_screen_pos = Vector3ToScreen(t_vec3, Explore3D:getScene():getActiveCamera())
	local p_screen_pos = Vector3ToScreen(translate, Explore3D:getScene():getActiveCamera())
	local pos_x, pos_y = self:getPos()
	return pos_x + t_screen_pos:x() - p_screen_pos:x(), pos_y + t_screen_pos:y() - p_screen_pos:y()
end

ExploreShip.goToDesitinaionWithPos = function(self, pos)
	self:stopAutoHandler()
	local pos_end = self.land:tileToCocos(pos) -- 开始坐标
	self:setPause(false)
	self:goToDesitinaion(pos_end, function()
			self:setPause(true)
		end)
end

ExploreShip.moveToVec3 = function(self, vec3)
	self:moveTo(vec3)
	self:setPause(false)
	self:setNextTranslation(vec3, function() self:setPause(true) end)
end

ExploreShip.breakTouchMove = function(self, is_pause)
	self:setNextTranslation()
	if is_pause then
		self:setPause(true)
	end
end

--检查是否越界，保留函数，可能有用，以后再加内容
ExploreShip.checkBoundOut = function(self)
end


--掠夺有关船基类的接口

--创建cd icon
ExploreShip.createLootCdView = function(self)
	self.ui.cd_icon = display.newSprite("#explore_plunder_cd.png")
	self.ui.cd_label = createBMFont({text = "", size = 16, color = ccc3(dexToColor3B(COLOR_RED))})
	local size = self.ui.cd_icon:getContentSize()
	self.ui.cd_label:setPosition(ccp(size.width / 2, size.height / 2 - 2))
	self.ui.cd_icon:addChild(self.ui.cd_label)
	self.ui.cd_icon:setVisible(false)
	self.ui:addChild(self.ui.cd_icon)
end

ExploreShip.removeLootCdView = function(self)
	if tolua.isnull(self.ui) then return end
	if not tolua.isnull(self.ui.cd_icon) then
		self.ui.cd_icon:removeFromParentAndCleanup(true)
		self.ui.cd_icon = nil
	end
end

ExploreShip.setTradeAttackStatus = function(self, is_show, is_show_gray, show_gray_reason)
	if self.m_trade_attack.is_attack == is_show then
		if is_show then
			if self.m_trade_attack.is_show_gray == is_show_gray and
				self.m_trade_attack.show_gray_reason == show_gray_reason then
				return
			end
		else
			return
		end
	end
	self.m_trade_attack.is_attack = is_show
	self.m_trade_attack.is_show_gray = is_show_gray
	self.m_trade_attack.show_gray_reason = show_gray_reason

	if not tolua.isnull(self.m_trade_attack.btn) then
		self.m_trade_attack.btn:removeFromParentAndCleanup(true)
	end

	self.m_trade_attack.btn = nil
	if not is_show then return end

	local show_spr = nil
	if not is_show_gray then
		show_spr = display.newSprite("#map_task_diamond.png")
	else
		show_spr = CCGraySprite:createWithSpriteFrameName("map_task_diamond.png")
	end

	local knife_sword_btn = getExploreLayer():createButton({image = "#explore_plunder_txt.png"})
	knife_sword_btn:setPosition(ccp(0, -30))
	knife_sword_btn:addChild(show_spr)

	local show_text = createBMFont({text = ui_word.STR_LUEDUO, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
	knife_sword_btn:addChild(show_text)
	knife_sword_btn.last_time = 0
	knife_sword_btn:regCallBack(function()
		if CCTime:getmillistimeofCocos2d() - knife_sword_btn.last_time < 500 then return end
		knife_sword_btn.last_time = CCTime:getmillistimeofCocos2d()
		if is_show_gray then
			Alert:warning({msg = ui_word[show_gray_reason]})
			return
		end

		getGameData():getExploreData():askLootPlayer(self.player_uid)
	end)
	knife_sword_btn:setTouchEnabled(not is_show_gray)

	self.ui:addChild(knife_sword_btn)
	self.m_trade_attack.btn = knife_sword_btn
end

ExploreShip.setRedNameAttackStatus = function(self, is_show, is_show_gray, show_gray_reason, normal_tip)
	if self.m_red_name_attack.is_attack == is_show then
		if is_show then
			if self.m_red_name_attack.is_show_gray == is_show_gray and
				self.m_red_name_attack.show_gray_reason == show_gray_reason and
				self.m_red_name_attack.normal_tip == normal_tip then
				return
			end
		else
			return
		end
	end
	self.m_red_name_attack.is_attack = is_show
	self.m_red_name_attack.is_show_gray = is_show_gray
	self.m_red_name_attack.show_gray_reason = show_gray_reason
	self.m_red_name_attack.normal_tip = normal_tip

	if not tolua.isnull(self.m_red_name_attack.btn) then
		self.m_red_name_attack.btn:removeFromParentAndCleanup(true)
	end

	self.m_red_name_attack.btn = nil
	if not is_show then return end

	local show_spr = nil
	if not is_show_gray then
		show_spr = display.newSprite("#explore_plunder.png")
	else
		show_spr = CCGraySprite:createWithSpriteFrameName("explore_plunder.png")
	end

	local knife_sword_btn = getExploreLayer():createButton({image = "#explore_plunder_txt.png"})
	knife_sword_btn:setPosition(ccp(0, -30))
	knife_sword_btn:addChild(show_spr)

	local show_text = createBMFont({text = ui_word.STR_LUEDUO, size = 16, color = ccc3(dexToColor3B(COLOR_RED_STROKE)), x = 0, y = 8})
	knife_sword_btn:addChild(show_text)
	knife_sword_btn.last_time = 0
	knife_sword_btn:regCallBack(function()
		if CCTime:getmillistimeofCocos2d() - knife_sword_btn.last_time < 500 then return end
		knife_sword_btn.last_time = CCTime:getmillistimeofCocos2d()

		if is_show_gray then
			Alert:warning({msg = ui_word[show_gray_reason]})
			return
		end

		local ok_callback = function() getGameData():getExploreData():askLootPlayer(self.player_uid) end
		if normal_tip then
			local paramemter = {
				kind = LOOT_ATTACT_PANEL,
				text = ui_word[normal_tip],
				okCall = ok_callback,
			}
			getUIManager():create("gameobj/explore/clsExploreLootTip", nil, paramemter)
		else
			ok_callback()
		end
	end)

	self.ui:addChild(knife_sword_btn)
	self.m_red_name_attack.btn = knife_sword_btn
end

ExploreShip.closeLootCdShceduler = function(self)
	if self.loot_cd_shceduler then
		scheduler:unscheduleScriptEntry(self.loot_cd_shceduler)
		self.loot_cd_shceduler = nil
	end
end

ExploreShip.openLootCdShceduler = function(self, time)
	if tolua.isnull(self.ui.icon) then
		self:createLootCdView()
	end
	local player_data = getGameData():getPlayerData()
	local updateCount
	updateCount = function()
		if not tolua.isnull(self.ui) then
			local current_time = os.time()
			local current_time = current_time + player_data:getTimeDelta()
			if current_time < time then
				if not tolua.isnull(self.ui.cd_label) then
					self.ui.cd_label:setString(tostring(tool:getTimeStrNormal(time - current_time)))
					if (not self.ui.cd_icon:isVisible()) then
						self.ui.cd_icon:setVisible(true)
					end
				end
			else
				self:closeLootCdShceduler()
				self:removeLootCdView()
			end
		else
			self:closeLootCdShceduler()
		end
	end
	self:closeLootCdShceduler()
	self.loot_cd_shceduler = scheduler:scheduleScriptFunc(updateCount, 1, false)
end

ExploreShip.removeScheduler = function(self)
	self:closeLootCdShceduler()
end

ExploreShip.createLeaderIcon = function(self)
	if not tolua.isnull(self.ui.spr_leader) then
		return
	end
	local spr_leader = display.newSprite("#common_icon_flagship.png")
	spr_leader:setPosition(ccp(-60, 115))
	spr_leader:setScale(0.6)
	self.ui.spr_leader = spr_leader
	self.ui:addChild(spr_leader)
end

ExploreShip.clearLeaderIcon = function(self)
	if not tolua.isnull(self.ui.spr_leader) then
		self.ui.spr_leader:removeFromParentAndCleanup(true)
	end
end

ExploreShip.release = function(self)
	ExploreShip.super.release(self)
	if not tolua.isnull(self.tips_ui) then
		self.tips_ui:removeFromParentAndCleanup(true)
	end
	self.tips_ui = nil
end

ExploreShip.showOrHideSupplyIcon = function(self, is_show)
	if is_show and tolua.isnull(self.ui.spr_supply) then
		local supply_res = display.newSprite("#explore_btn_collect.png")
		self.ui:addChild(supply_res)
		self.ui.spr_supply = supply_res
	else
		if not is_show and not tolua.isnull(self.ui.spr_supply) then
			self.ui.spr_supply:removeFromParentAndCleanup(true)
		end
	end
end

ExploreShip.hideTitleNode = function(self)
	if not tolua.isnull(self.title_node) then
		self.title_node:setVisible(false)
	end

	if not tolua.isnull(self.guild_job) then
		self.guild_job:setVisible(false)
	end
end

ExploreShip.createKillTitle = function(self, kill_title_n, camp_color)
	local scene_title = cfg_scene_title[kill_title_n]
	if not scene_title then
		return 
	end

	self.node:setScale(scene_title.scale)

	if tolua.isnull(self.kill_node) then
		local node = display.newNode()
		self.ui:addChild(node)
		self.kill_node = node
	end

	local color = QUALITY_COLOR_STROKE[scene_title.font_color]

	if not tolua.isnull(self.kill_node.title) then
		self.kill_node.title:removeFromParent()
	end

	self.kill_node.title = createBMFont({text = scene_title.name, fontFile = FONT_CFG_1, size = scene_title.font_size,
					color = ccc3(dexToColor3B(color)), x = 50, y = 150})
	self.kill_node:addChild(self.kill_node.title)
end

----------------------------------- 新版本AI系统有关函数 Begin -------------------------------------
ExploreShip.isRunningFollowAi = function(self)
end

require("gameobj/battle/ai/ai_base")

-- AI心跳
ExploreShip.updateAI = function(self, deltaTime)
	-- 新AI系统的心跳
	for ai_id, ai_obj in pairs(self.running_ai) do
		ai_obj:heartBeat( deltaTime )
	end
	self:tryOpportunity(AI_OPPORTUNITY.TACTIC)
end

ExploreShip.tryOpportunity = function(self, opportunity, params)
	local tmp_new_ai = table.keys(self.new_ai)
	for _, ai_id in pairs( tmp_new_ai ) do
		if (not self.running_ai[ai_id] ) and self.new_ai[ai_id] then
			self.new_ai[ai_id]:tryRun( opportunity, params )
		end
	end
end

-- 添加AI
ExploreShip.addAI = function(self, ai_id, params)
	local clazz_name = string.format("%s%s", DEFAULT_AI_DIR, ai_id )
	local ClsAI = require(clazz_name)
	local aiObj = ClsAI.new(params, self, "explore_ship")
	-- 将AI数据记录下来
	-- 到真正运行时再实例化
	self.new_ai[ai_id] = aiObj
	self.is_add_ai = true
end

ExploreShip.getAI = function(self, ai_id)
	return self.new_ai[ai_id]
end

-- 删除AI
ExploreShip.deleteAI = function(self, ai_id)
	self.new_ai[ai_id] = nil
end


ExploreShip.setRunningAI = function(self, aiObj)
	local ai_id = aiObj:getId()
	self.running_ai[ai_id] = aiObj
end

ExploreShip.isRunningAI = function(self)
	return table.nums(self.running_ai) > 0
end

ExploreShip.completeAI = function(self, aiObj)
	local ai_id = aiObj:getId();

	-- 删除正在执行AI
	self.running_ai[ai_id] = nil
end

ExploreShip.initAI = function(self)
	self.new_ai = {}
	self.running_ai = {}
	self.is_add_ai = false
	self:setSpeedRate(1)
end

ExploreShip.isAddAI = function(self)
	return self.is_add_ai
end

ExploreShip.getId = function(self)
	return self.player_uid
end

ExploreShip.setFollowAI = function(self, ship_uid, get_ship_func, miss_ship_func)
	if not self.is_add_ai then
		self:addAI(FOLLOW_AI, {})
		self:getAI(FOLLOW_AI):setData("__follow_ship_uid", ship_uid)
		self:getAI(FOLLOW_AI):setData("__get_ship_func_by_uid", get_ship_func)
		self:getAI(FOLLOW_AI):setData("__miss_ship_func_by_uid", miss_ship_func)
	end
end

ExploreShip.getIsNeedToHideState = function(self)
	return self.is_need_to_hide
end

return ExploreShip




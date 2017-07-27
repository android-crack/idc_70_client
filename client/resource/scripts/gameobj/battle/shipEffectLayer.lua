local role_info = require("game_config/role/role_info")
local sailor_info = require("game_config/sailor/sailor_info")
local ShipBuffIconNode = require("gameobj/battle/ShipBuffIconNode")

local BOAT_TYPE_RES = {
    "common_job_adventure.png",
    "common_job_navy.png",
    "common_job_pirate.png",
}

local HEAD_TYPE_LEADER = 1
local HEAD_TYPE_PARTNER = 2
local HEAD_TYPE_OTHER = 3

local HEAD_BG_RES = 
{
	"#battle_hp_role.png",
	"#battle_hp_partner.png",
	"#battle_hp_no_icon.png",
}

local MISS = "#battle_miss.png"
local CRITICAL = "#battle_crit.png"

------------------------------------------------------------------------------------------------------------------------

local function getResType(ship)
	local battle_data = getGameData():getBattleDataMt()
	local battle_type = battle_data:GetData("battle_field_data").fight_type

	local res_type = HEAD_TYPE_PARTNER
	
	if not ship:getSailorID() or ship:getSailorID() < 1 then
		res_type = HEAD_TYPE_OTHER
	else
		if ship:is_leader() or ship:getHeadID() == 1 then
			res_type = HEAD_TYPE_LEADER
		else
			res_type = HEAD_TYPE_PARTNER
		end
	end

	return res_type, 
			ship.teamId == battle_config.target_team_id or ship.teamId == battle_config.enemy_team_id,
			ship.uid == battle_data:getCurClientUid()
end

local role_json_name = {
	"json/battle_hp_me_role.json",
	"json/battle_hp_me_partner.json",
	"json/battle_hp_me_nobody.json",
}

local enemy_json_name = {
	"json/battle_hp_enemy_role.json",
	"json/battle_hp_enemy_partner.json",
	"json/battle_hp_enemy_nobody.json",
}

local widget_name = {
	"head_bg",
	"head_pic",
	"role_level",
	"role_title",
	"role_name",
	"ship_type",
	"ship_type_icon",
	"sailor_quality",
	"flagship_icon",
	"hp_bar",
	"sailor_quality_icon",
	"buff_attack",
	"buff_defense",
	"buff_speed",
	"buff_cure",
	"buff_dizzy",
}

local function createHeadInfo(ship)
	local res_type, reverse_flag, is_self = getResType(ship)
	local json_file = {}
	if reverse_flag then
		json_file = enemy_json_name
	else
		json_file = role_json_name
	end

	local layer = UILayer:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile(json_file[res_type])
	convertUIType(panel)
	panel:setAnchorPoint(ccp(0.5,-0.5))	
	layer:addWidget(panel)
	ship.body.ui:addChild(layer)

	local battle_data = getGameData():getBattleDataMt()
	if not battle_data:getShowShipUI() then
		ship.body.ui:setVisible(false)
	end

	if ship.body.hpBG then
		ship.body.hpBG:removeFromParentAndCleanup(true)
	end
	ship.body.hpBG = layer
	
	for k,v in pairs(widget_name) do
		layer[v] = getConvertChildByName(panel, v)
	end
	if not is_self and not reverse_flag then
		if res_type == HEAD_TYPE_LEADER then
            setUILabelColor(layer.role_level, ccc3(dexToColor3B(COLOR_LIGHT_BLUE_STROKE)))
			layer.hp_bar:loadTexture("battle_hp_role2.png", UI_TEX_TYPE_PLIST)
		elseif res_type == HEAD_TYPE_PARTNER then	
			setUILabelColor(layer.role_level, ccc3(dexToColor3B(COLOR_LIGHT_BLUE_STROKE)))	
			layer.hp_bar:loadTexture("battle_hp_partner2.png", UI_TEX_TYPE_PLIST)
		end
	elseif is_self and not reverse_flag then --单人pve特殊处理
		local battle_data = getGameData():getBattleDataMt()
		if not battle_data:isSummon() and res_type == HEAD_TYPE_PARTNER then
			layer.hp_bar:loadTexture("battle_hp_partner2.png", UI_TEX_TYPE_PLIST)
		end
	end

	---头像
	local seaman_res = nil 
	local sailor_job = nil 
	if ship:getSailorID() and ship:getSailorID() > 0 then	
		if ship:getRole() then
			sailor_job = role_info[ship:getRole()].job_id
			seaman_res = role_info[ship:getRole()].res
		else
			sailor_job = sailor_info[ship:getSailorID()].job[1]
			seaman_res = sailor_info[ship:getSailorID()].res
		end		
	end
	layer.head_pic:changeTexture(seaman_res, UI_TEX_TYPE_LOCAL)	

	local size = res_type == HEAD_TYPE_LEADER and 40 or 35
	layer.head_pic:setScale(size/layer.head_pic:getContentSize().width)

	---头像背景
	if ship:getSailorID() and ship:getSailorID() > 0 then 
		local job_bg 
		local scale = 1
		if ship:is_leader() then
			job_bg = SAILOR_JOB_BG[sailor_job].normal
			scale = 60
		else
			job_bg = SAILOR_JOB_BG[sailor_job].battle
			scale = 50
		end
		layer.head_bg:changeTexture( job_bg, UI_TEX_TYPE_PLIST)
		local size = layer.head_bg:getContentSize()
		layer.head_bg:setScale(scale/size.width)
		layer.ship_type:setVisible(true)
		---船舶类型
		layer.ship_type_icon:changeTexture(convertResources(BOAT_TYPE_RES[sailor_job]), UI_TEX_TYPE_PLIST)
		layer.ship_type_icon:setScale(0.35)
	else
		layer.ship_type:setVisible(false)
	end


	if res_type == HEAD_TYPE_OTHER then
		layer.head_bg:setVisible(false)
		layer.head_pic:setVisible(false)
		--layer.ship_type:setVisible(false)
	end
	
	---旗舰标志
	if ship:is_leader() then
		layer.flagship_icon:setVisible(true)
	else
		layer.flagship_icon:setVisible(false)
	end

	---水手名字
	local sailor_name = ""
	if ship:isPVEShip() then		
		sailor_name = ship:getName()
	else
		if ship:is_leader() then
			sailor_name = ship:getFighterName()
		else
			local sailor_id = ship:getSailorID() 
			-- sailor_name = sailor_info[sailor_id].name 
			sailor_name = ""	
		end
	end

	layer.role_name:setText(sailor_name)
	if sailor_name == "" then --因为创建了一个空的字符，在界面上会有像素点
		layer.role_name:setVisible(false)
	end

	ship.body.name = layer.role_name

	---等级
	if ship.baseData.level then
		layer.role_level:setText("Lv."..ship.baseData.level)
	else
		layer.role_level:setVisible(false)
	end
	if ship.baseData.tag and ship.baseData.tag == battle_config.FEN_SHEN_TAG then
		layer.role_level:setPosition(ccp(layer.role_level:getPosition().x + 5, 0))
	end
	ship.body.level = layer.role_level

	---称号
	if ship:getRole() then
		layer.role_title:setVisible(true)
		local title_id = ship:getNobility()
		local nobility_data = getGameData():getNobilityData()
	    local nobility_info = nobility_data:getNobilityDataByID(title_id)
	    if nobility_info then
		    local title_pic = nobility_info.peerage_before
			layer.role_title:changeTexture(convertResources(title_pic), UI_TEX_TYPE_PLIST)
		else
			layer.role_title:setVisible(false)
		end

		if reverse_flag then
			local pos = layer.role_name:getPosition()
			local size = layer.role_name:getContentSize()
			layer.role_title:setPosition(ccp(pos.x - size.width, pos.y))
		end
	else
		layer.role_title:setVisible(false)
	end

	ship.body.title = layer.role_title

	local rate = math.floor(ship:getHpRate()*100)
	layer.hp_bar:setPercent(rate)
	ship.body.hpBar = layer.hp_bar

	if res_type == HEAD_TYPE_LEADER then
		ship.body.hp_grey = getConvertChildByName(panel, "hp_grey")
		ship.body.hp_grey:setPercent(rate)
	end

	---伙伴船上航海士级别
	if ship:getSailorID() and res_type == HEAD_TYPE_PARTNER then
		local star_pic = STAR_SPRITE_RES[ship:getSailorLV()].gray
		layer.sailor_quality_icon:changeTexture(star_pic, UI_TEX_TYPE_PLIST)
		layer.sailor_quality_icon:setScale(20/layer.sailor_quality_icon:getContentSize().width)

		if ship:isPVEShip() then  ---敌军pve
			layer.sailor_quality:setVisible(false)
			layer.sailor_quality_icon:setVisible(false)
		else
			layer.sailor_quality:setVisible(true)
			layer.sailor_quality_icon:setVisible(true)
		end
	else
		layer.sailor_quality:setVisible(false)
		layer.sailor_quality_icon:setVisible(false)
	end

	layer.buff_attack:setVisible(false)
	layer.buff_defense:setVisible(false)
	layer.buff_speed:setVisible(false)
	layer.buff_cure:setVisible(false)
	layer.buff_dizzy:setVisible(false)
	---特效
	local buff_pic = {
		layer.buff_attack, layer.buff_defense, layer.buff_speed, layer.buff_cure, layer.buff_dizzy,
	}
	local reverseFlag = (ship.teamId == battle_config.target_team_id) or (ship.teamId == battle_config.enemy_team_id)
    local buffIconsBar = ShipBuffIconNode.new(ship.body.ui, reverseFlag, buff_pic)

    ship.body.ui.buffIconsBar = buffIconsBar
end

local function createPropInfo(ship)
	local layer = UILayer:create()
	local panel = GUIReader:shareReader():widgetFromJsonFile("json/battle_hp_item.json")
	convertUIType(panel)
	panel:setAnchorPoint(ccp(0.5, -0.5))
	panel:setPosition(ccp(0, 70))
	layer:addWidget(panel)
	ship.body.ui:addChild(layer)

	if ship.body.hpBG then
		ship.body.hpBG:removeFromParentAndCleanup(true)
	end
	ship.body.hpBG = layer

	local hp_bar_bg = getConvertChildByName(panel, "hp_bar_bg")

	ship.body.hpBar = getConvertChildByName(hp_bar_bg, "hp_bar")
	ship.body.name = getConvertChildByName(hp_bar_bg, "role_name")

	if ship:getTeamId() == battle_config.target_team_id or ship:getTeamId() == battle_config.enemy_team_id then
		setUILabelColor(ship.body.name, ccc3(dexToColor3B(COLOR_RED_STROKE)))
		
		ship.body.hpBar:loadTexture("battle_hp_partner3.png", UI_TEX_TYPE_PLIST)
	end

	ship.body.hpBar:setPercent(math.floor(ship:getHpRate()*100))

	ship.body.name:setText(ship:getName())

	layer.buff_attack = getConvertChildByName(panel, "buff_attack")
	layer.buff_defense = getConvertChildByName(panel, "buff_defense")
	layer.buff_speed = getConvertChildByName(panel, "buff_speed")
	layer.buff_cure = getConvertChildByName(panel, "buff_cure")
	layer.buff_dizzy = getConvertChildByName(panel, "buff_dizzy")

	layer.buff_attack:setVisible(false)
	layer.buff_defense:setVisible(false)
	layer.buff_speed:setVisible(false)
	layer.buff_cure:setVisible(false)
	layer.buff_dizzy:setVisible(false)
	---特效
	local buff_pic = {
		layer.buff_attack, layer.buff_defense, layer.buff_speed, layer.buff_cure, layer.buff_dizzy,
	}
	local reverseFlag = (ship.teamId == battle_config.target_team_id) or (ship.teamId == battle_config.enemy_team_id)
    local buffIconsBar = ShipBuffIconNode.new(ship.body.ui, reverseFlag, buff_pic)

    ship.body.ui.buffIconsBar = buffIconsBar
end

------------------------------------------------------------------------------------------------------------------------

-- isCure:是否加血
function createDamageWord(value, isCure, tbResult, show_left, scale)
	local w_size = 18
	local w_color

	if isCure then
		w_color = ccc3(dexToColor3B(COLOR_GREEN_STROKE))
	else 
		w_color = ccc3(dexToColor3B(COLOR_RE_STROKE))
	end
	
	local text = ""
	if value > 0 then
		text = "+"..tostring(value)
	elseif value < 0 then
		if tbResult then
			if tbResult.baoji_flag then
				w_size = 24
				w_color = ccc3(dexToColor3B(COLOR_OR_STROKE))
			elseif tbResult.is_near_attack then
				w_color = ccc3(dexToColor3B(COLOR_PU_STROKE))
			end
		end
		text = text .. tostring(value)
	end

	local info_label = createBMFont({text = text, size = w_size, color = w_color, fontFile = FONT_AVA_BEBI})
	info_label:setPosition(0, 50)
	info_label:setScale(scale)

	local direct = show_left and -1 or 1

	local actions = {}
	local ani_tick = 0.5

	if value < 0 then
		local random = math.random(3)

		if tbResult and tbResult.baoji_flag then
			local sprite = display.newSprite(CRITICAL)
			local x = - sprite:getContentSize().width/2 - info_label:getContentSize().width/2 - 5
			sprite:setPosition(ccp(x, 0))
			info_label:addChild(sprite)

			ani_tick = 0.1
			actions[#actions + 1] = CCMoveBy:create(ani_tick, ccp(20*(random - 2) , 60))
			actions[#actions + 1] = CCScaleBy:create(ani_tick, 1.5)
			actions[#actions + 1] = CCScaleBy:create(ani_tick, 1/1.5)
			actions[#actions + 1] = CCDelayTime:create(0.5)
			actions[#actions + 1] = CCFadeOut:create(0.5)
		else
			info_label:setPosition(30*direct, 50)

			local ac1 = CCMoveBy:create(ani_tick, ccp(30*direct, 10 + 15*random))
			local ac2 = CCScaleTo:create(ani_tick, 0.8)
			actions[#actions + 1] = CCSpawn:createWithTwoActions(ac1, ac2)

			local ac3 = CCMoveBy:create(ani_tick, ccp(30*direct, -20))
			local ac4 = CCFadeOut:create(ani_tick)
			actions[#actions + 1] = CCSpawn:createWithTwoActions(ac3, ac4)
		end
	else
		w_size = 20
		info_label:setPosition(0, 60)

		local move_up = ccp(0, 25)
		
		local ac1 = CCMoveBy:create(ani_tick, move_up)
		local ac2 = CCScaleTo:create(ani_tick, 1)
		actions[#actions + 1] = CCSpawn:createWithTwoActions(ac1, ac2)

		local ac3 = CCMoveBy:create(0.3, move_up)
		local ac4 = CCFadeOut:create(0.3)
		actions[#actions + 1] = CCSpawn:createWithTwoActions(ac3, ac4)
	end
	
	actions[#actions + 1] = CCCallFunc:create(function() 
		info_label:removeFromParentAndCleanup(true)
	end)
	info_label:runAction(transition.sequence(actions))

	return info_label
end

local function showDamageWord(ship_data, value, isCure, tbResult, show_left)
	if not ship_data or tolua.isnull(ship_data.body.ui) then return end

	local scale = 1
	if value < 0 and math.abs(value)/ship_data:getMaxHp() > 0.1 then
		scale = 1.5
	end

	local info_label = createDamageWord(value, isCure, tbResult, show_left, scale)

	ship_data.body.ui:addChild(info_label)
end

local function showSmokeEffect(ship_data, smoke_type)
	if ship_data.body.node == nil then return end
	ship_data.body:showSmoke()
end

local function hideSmokeEffect(ship_data)
	if ship_data.body.node == nil then return end
	ship_data.body:hideSmoke()
end

-- 垂危表现
local function showDangerEffect(ship_data)
	local battle_data = getGameData():getBattleDataMt()
	local battleUI = battle_data:GetLayer("battle_ui")
	if tolua.isnull(battleUI) then return end 
	
	if tolua.isnull(ship_data.danger_sp) then 
		local frame = display.newSpriteFrame("battle_danger.png")
		local sp = CCScale9Sprite:createWithSpriteFrame(frame)
		sp:setContentSize(CCSize(display.width, display.height))
		sp:setPosition(display.cx, display.cy)
		battleUI:addChild(sp, 10)
		ship_data.danger_sp = sp
	else 
		ship_data.danger_sp:stopAllActions()
		ship_data.danger_sp:setVisible(true)
	end 
	
	local ac = CCFadeOut:create(2)
	ship_data.danger_sp:runAction(ac)
end 

local function updateShipHp(target_data, value)
	local node = target_data.body.hpBar

	if tolua.isnull(node) then return end
	
	local new_ratio = math.floor(target_data:getHpRate()*100)
	
	local battle_data = getGameData():getBattleDataMt()
	local battleUI = battle_data:GetLayer("battle_ui")
	if not tolua.isnull(battleUI) then
		battleUI:setHp(new_ratio, target_data)
	end 
	
	node:setPercent(new_ratio)
	if new_ratio > 60 then
		if target_data.body.isSmoke then
			hideSmokeEffect(target_data)
		end
		if target_data.body.isBroken then 
			target_data.body:unBroken()
		end
	elseif new_ratio <= 60 and new_ratio > 30 then
		if not target_data.body.isSmoke then 
			showSmokeEffect(target_data)
		end
		if target_data.body.isBroken then 
			target_data.body:unBroken()
		end
		if not target_data.body.isSuipian01 then 
			target_data.body:showSuipian01()
		end
	elseif new_ratio <= 30 and new_ratio >= 0 then
		if not target_data.body.isBroken then
			target_data.body:broken()
		end
		if not target_data.body.isSmoke then 
			showSmokeEffect(target_data)
		end
		if not target_data.body.isSuipian02 then 
			target_data.body:showSuipian02()
		end
	end
	
	if value and value < 0 then 
		if battle_data:isCurClientControlShip(target_data:getId()) and new_ratio < 40 then 
			showDangerEffect(target_data)
		end 
		
		-- local damage_ratio = - value*100/target_data:getMaxHp()
		-- if damage_ratio >= 50 then 
		-- 	CameraFollow:SceneShake(5, 5)
		-- end 
	end
end

local function updateShipHpGrey(ship_data)
	if not ship_data or not ship_data.body or not ship_data.body.hp_grey then return end

	local cur_rate = ship_data.body.hp_grey:getPercent()

	local new_rate = math.floor(ship_data:getHpRate()*100)

	if cur_rate <= new_rate then return end

	ship_data.body.hp_grey:setPercent(cur_rate - 0.05)
end

local function changeTeam(ship_data)
	if ship_data.is_ship then
		createHeadInfo(ship_data)
		updateShipHp(ship_data)
	elseif ship_data:getName() and ship_data:getName() ~= "" and ship_data:getName() ~= "0" then
		createPropInfo(ship_data)
	end
end

local function onBorn(ship_data)
	changeTeam(ship_data)
end

local function hideShipUI(shipsToHide)
	local battle_data = getGameData():getBattleDataMt()
	for k, v in pairs(battle_data:GetShips()) do
		if not v.isDeaded then 		
			v.body.ui:setVisible(false)
		end
	end
	if not shipsToHide or not next(shipsToHide) then return end
	for k, v in pairs(shipsToHide) do
		if not v.isDeaded then 		
			v.body.ui:setVisible(true)
		end		
	end	
end

local function showShipUI(shipsToShow)
	local battle_data = getGameData():getBattleDataMt()
	if shipsToShow and next(shipsToShow) then 
		for k, v in pairs(shipsToShow) do
			if not v.isDeaded then 
				v.body.ui:setVisible(true)
			end
		end
	else
		for k, v in pairs(battle_data:GetShips()) do
			if not v.isDeaded then 		
				v.body.ui:setVisible(true)
			end
		end
	end
end

local function showStatusPrompt(ship, txt, from_stack)
	if not txt or txt == "" then return end

	if not ship:getBody() or not ship:getBody().ui then return end

	local function is_exit(ship, txt)
		for k, v in ipairs(ship.status_prompt) do
			if v == txt then return true, k end
		end

		return false, 1
	end

	if not from_stack then
		if is_exit(ship, txt) then return end

		ship.status_prompt[#ship.status_prompt + 1] = txt

		if ship.status_show_count > 0 then
			ship.status_prompt_stack[#ship.status_prompt_stack + 1] = txt
			return
		end
	end

	local label = createBMFont({text = txt, size = 16, color = ccc3(dexToColor3B(COLOR_WHITE_STROKE))})
	label:setPosition(ccp(0, 20))

	ship:getBody().ui:addChild(label)

	ship.status_show_count = ship.status_show_count + 1

	local actions = {}

	actions[#actions + 1] = CCFadeIn:create(0.5)

	local ac_1 = CCDelayTime:create(0.3)
	local ac_2 = CCCallFunc:create(function()
		ship.status_show_count = ship.status_show_count - 1
		if #ship.status_prompt_stack > 0 then
			local txt = table.remove(ship.status_prompt_stack, 1)
			showStatusPrompt(ship, txt, true)
		end
	end)
	actions[#actions + 1] = CCSequence:createWithTwoActions(ac_1, ac_2)

	local ac_3 = CCFadeOut:create(2)
	local ac_4 = CCMoveBy:create(2, ccp(0, 50))
	actions[#actions + 1] = CCSpawn:createWithTwoActions(ac_3, ac_4)

	actions[#actions + 1] = CCCallFunc:create(function()
		local ret, index = is_exit(ship, txt)
		if ret then
			table.remove(ship.status_prompt, index)
		end
		label:removeFromParentAndCleanup(true)
	end)

	label:runAction(transition.sequence(actions))
end

local function showMiss(ship)
	local body = ship:getBody()

	if not body or tolua.isnull(body.ui) then return end

	if body.miss then 
		body.miss:removeFromParentAndCleanup(true)
		body.miss = nil
	end

	local miss = display.newSprite(MISS)
	miss:setPosition(ccp(0, 20))
	body.ui:addChild(miss)

	local array = CCArray:create()
	array:addObject(CCMoveBy:create(0.2, ccp(0, 15)))
	array:addObject(CCDelayTime:create(1))
	array:addObject(CCFadeOut:create(0.5))
	array:addObject(CCCallFunc:create(function()
		if body then
			body.miss:removeFromParentAndCleanup()
			body.miss = nil
		end
	end))

	miss:runAction(CCSequence:create(array))

	body.miss = miss
end

local shipEffect = {
	showDamageWord = showDamageWord,
	updateShipHp = updateShipHp,
	onBorn = onBorn,
	changeTeam = changeTeam,
	hideShipUI = hideShipUI,
	showShipUI = showShipUI,
	showStatusPrompt = showStatusPrompt,
	showMiss = showMiss,
	updateShipHpGrey = updateShipHpGrey,
}

return shipEffect

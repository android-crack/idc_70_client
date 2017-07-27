--2016/09/05
--create by wmh0497
--用于显示3d的选角界面
local ClsDataTools = require("module/dataHandle/dataTools")
local ClsCommonFuns = require("scripts/gameobj/commonFuns")
local ui_word = require("game_config/ui_word")
local ClsU3dSceneParse = require("gameobj/u3d/u3dSceneParse")
local ClsAlert = require("ui/tools/alert")
-- local sceneConfig = require("game_config/u3d_data/sceneConfig")
local sceneConfig = require("game_config/u3d_data/Q3_03")
local role_info = require("game_config/role/role_info")
local music_info = require("game_config/music_info")
local news = require("game_config/news")
local element_mgr = require("base/element_mgr")
local CompositeEffect = require("gameobj/composite_effect")

local userDefault = CCUserDefault:sharedUserDefault()
-- 预加载资源
local res_tab = {
	plist = {
		["ui/role_ui.plist"] = 1,
		["ui/title_name.plist"] = 1,
		["ui/guild_badge.plist"] = 1,
	},
}

local job_id_to_unity_key = {
	[TAB_ADVENTURE] = 2,
	[TAB_NAVY] = 3,
	[TAB_PIRATE] = 1,
}

local animation_clip_list = {
	[1] = {res = "mountain", key = {"mountain_2001", nil, "mountain_2003"}},
	[2] = {res = "water", key = {"water_2001", nil, "water_2003"}},
	["2001C"] = {res = "2001C", key = {"camera1", "camera2"}},
	["2002C"] = {res = "2002C", key = {"camera1", "camera2"}},
	["2003C"] = {res = "2003C", key = {"camera1", "camera2"}},
}

local key_config = {
	[TAB_ADVENTURE] = "adventure",
	[TAB_NAVY] = "navy",
	[TAB_PIRATE] = "pirate",
}

local txt_config = {
	[TAB_ADVENTURE] = "adv_txt_bg",
	[TAB_NAVY] = "navy_text_bg",
	[TAB_PIRATE] = "pirate_txt_bg",
}

local role_music = {
	[TAB_ADVENTURE] = {["role_res"] = music_info.LOGIN_ADV_BGM.res, ["extra_music"] = {
		{name = music_info.LOGIN_ADV_VIOLIN.res, delay = 2.8, isLoop = true,},
		{name = music_info.LOGIN_ADV_WAVE.res, delay = 9.26, isLoop = true, },
	}}, --冒险者
	[TAB_NAVY] = {["role_res"] = music_info.LOGIN_NAVY_BGM.res, ["extra_music"] = {
		{name = music_info.LOGIN_NAVY_CLOTHES.res, delay = 1.5, isLoop = false, },
		{name = music_info.LOGIN_NAVY_WAVE.res, delay = 5, isLoop = true, },
	}}, --海军
	[TAB_PIRATE] = {["role_res"] = music_info.LOGIN_PIRATE_BGM.res, ["extra_music"] = {
		{name = music_info.LOGIN_PIRATE_WAVE.res, delay = 12, isLoop = true, },
	}}, --雇佣兵
}

local ClsSelectRole3dUi = class("clsSelectRole3dUi", function() return display.newLayer() end)

ClsSelectRole3dUi.ctor = function(self)
	self.show_black_layer = 0
	self:registerScriptHandler(function(event)
		if event == "enter" then
			self:onEnter()
		elseif event == "exit" then
			self:onExit()
		end
	end)
	
	self.plist_table = {
		["ui/role_ui.plist"] = 1,
		["ui/title_name.plist"] = 1,
		["ui/guild_badge.plist"] = 1,
	}
	LoadPlist(self.plist_table)
	
	local player_data = getGameData():getPlayerData()
	self.role_list = player_data:getRoleList() or {}

	self.role_count = 0

	for k,v in pairs(self.role_list) do
		self.role_count = self.role_count + 1
	end
	
	
	self.default_role_id = userDefault:getIntegerForKey(LAST_SELECT_ROLE_ID)
	element_mgr:add_element("SelectRole", self)
end


ClsSelectRole3dUi.onEnter = function(self)
	local sound = music_info.LOGIN_WAVE
	audioExt.pauseMusic()
	audioExt.playEffect(sound.res, true)
	--经过这个界面那么就将它设置成第一次登陆
	local playerData = getGameData():getPlayerData()
	playerData:setFirstLogin()
	
	self.m_u3d_scene = ClsU3dSceneParse.new(self, sceneConfig)
	self.m_scene_ui = self.m_u3d_scene:getSceneUi()
	self.m_tips_lab = createBMFont({text = "", x = 480, y = 320})
	self.m_scene_ui:addChild(self.m_tips_lab)
	self.m_role3d_infos = {}
	self.m_select_job_id = 0
	for i = 1, 3 do
		local role3d_info = {}
		local key = job_id_to_unity_key[i]
		role3d_info.ship = self.m_u3d_scene:getNodeByName(string.format("role_ship_0%d", key))
		role3d_info.person_model = self.m_u3d_scene:getNodeByName(string.format("200%d", key))
		role3d_info.camrea = self.m_u3d_scene:getNodeByName(string.format("200%dC", key))
		
		role3d_info.is_show_particle = true
		role3d_info.particle_parent = self.m_u3d_scene:getNodeByName(string.format("200%deffects", key))
		role3d_info.sky_material_str = string.format("sky_200%d", key)
		
		role3d_info.ship:playAnimation("stand1", true)
		role3d_info.person_model:playAnimation("stand1", true)
		
		self.m_role3d_infos[i] = role3d_info
	end
	self:initJsonUI()
	--self:initTestUiBtn()
	self:hideAllShipEffect()

	-- 特殊处理，放大包围球
	for i = 1, 3 do
		local sphere = self.m_role3d_infos[i].person_model:getTrueModelNode():getBoundingSphere()
		sphere:set(sphere:center(), 100000)
	end 

	
	--激活第二个摄像头
	self.m_role3d_infos[2].camrea:setActiveCamera()
	
	self.m_camrea = self.m_role3d_infos[2].camrea
	
	self.m_mountains_node = self.m_u3d_scene:getNodeByName("mountain")

	--海水
	self.m_sea = self.m_u3d_scene:getNodeByName("WaterSurface")

	-- 天空盒动画
	local sky = self.m_u3d_scene:getNodeByName("sky_xuanzhuang")
	sky:playU3dCfgAnimation()
	self.m_sky_model = self.m_u3d_scene:getNodeByName("sky")
	
	--待机界面动画
	self.m_waiting_effect_info = {}
	self.m_waiting_effect_info.is_show = true
	self.m_waiting_effect_info.root_node = self.m_u3d_scene:getNodeByName(string.format("waiteffects", key))
	self:initOldRoleInfo()
	-- else 
		-- 船的点击区域
	self.ship_touch_rect = {
		[TAB_PIRATE] = CCRect(100, 20, 270, 460),
		[TAB_ADVENTURE] = CCRect(370, 20, 270, 460),
		[TAB_NAVY] = CCRect(670, 20, 270, 460), 
	}
	-- todo
	local touch_layer = display.newLayer()
	self:addChild(touch_layer)
	touch_layer:registerScriptTouchHandler(function(event, x, y)

		if event == "began" then
			for k, v in ipairs(self.ship_touch_rect) do
				if v:containsPoint(ccp(x,y)) then 
					touch_layer:removeFromParentAndCleanup(true)
					self:selectJobId(k)
					return
				end 
			end 
		end 
	end, false, 1, false)
	touch_layer:setTouchEnabled(true)
	self.touch_layer = touch_layer
	
	if tonumber(self.default_role_id) > 0 and self.role_count > 0 then
		self:selectJobId(self.default_role_id)
	end
end

ClsSelectRole3dUi.initJsonUI = function(self)
	self.m_ui_layer = UILayer:create()
	self.m_scene_ui:addChild(self.m_ui_layer)
	
	self.m_role_ui = GUIReader:shareReader():widgetFromJsonFile("json/role.json")
	self.m_ui_layer:addWidget(self.m_role_ui)
	
	self.m_job_btns = {}
	for i = 1, 3 do
		local info = {}
		info.job_btn = getConvertChildByName(self.m_role_ui, string.format("btn_%s", key_config[i]))
		info.unselect_job_lab = getConvertChildByName(self.m_role_ui, string.format("%s_text", key_config[i]))
		
		info.select_name_spr = getConvertChildByName(info.job_btn, "name_selected")
		info.select_btn_spr = getConvertChildByName(info.job_btn, "btn_selected")
		
		info.job_btn:setScale(0.8)
		info.job_btn:setPressedActionEnabled(true)
		info.job_btn:addEventListener(function()
				self:selectJobId(i)
			end, TOUCH_EVENT_ENDED)
		self.m_job_btns[i] = info

		info.job_text_bg = getConvertChildByName(self.m_role_ui, txt_config[i])
		info.job_text_bg:addEventListener(function()
			self:selectJobId(i)
		end, TOUCH_EVENT_ENDED)
		info.job_text_bg:setTouchEnabled(true)
	end
	self.m_ui_layer.btn_switch = getConvertChildByName(self.m_role_ui, "btn_switch")
	self.m_ui_layer.btn_service = getConvertChildByName(self.m_role_ui, "btn_service")
	self:showSpecialBtn()
	
	self.m_select_info = {}
	local select_ui = getConvertChildByName(self.m_role_ui, "info_bg")
	self.job_bg = getConvertChildByName(self.m_role_ui, "job_bg")
	select_ui:setVisible(true)
	self.m_select_info.select_ui = select_ui
	self.m_select_info.role_info = getConvertChildByName(select_ui, "role_info")
	self.m_select_info.role_intro = getConvertChildByName(select_ui, "role_intro")
	self.m_select_info.input_bg_spr = getConvertChildByName(select_ui, "input_box")
	self.m_select_info.desc_lab = getConvertChildByName(select_ui, "introduce_info")
	self.m_select_info.enter_btn = getConvertChildByName(select_ui, "btn_enter")
	self.m_select_info.rand_name_btn = getConvertChildByName(select_ui, "btn_name_rand")
	self.m_select_info.job_attr = getConvertChildByName(select_ui, "job_text_2")
	self.m_select_info.star_1 = getConvertChildByName(select_ui, "star_1")
	self.m_select_info.star_2 = getConvertChildByName(select_ui, "star_2")
	self.m_select_info.star_3 = getConvertChildByName(select_ui, "star_3")
	self.m_select_info.btn_enter_text = getConvertChildByName(select_ui, "btn_enter_text")
	
	local power_sprs = {}
	for i = 1, 3 do
		power_sprs[i] = getConvertChildByName(select_ui, string.format("%s_polygon", key_config[i]))
	end
	self.m_select_info.power_sprs = power_sprs
	
	
	self.m_select_info.rand_name_btn:setPressedActionEnabled(true)
	self.m_select_info.rand_name_btn:addEventListener(function()
		self.m_select_info.rand_name_btn:setOpacity(0)
			if not tolua.isnull( self.select_name_effect) then
				 self.select_name_effect:removeFromParentAndCleanup(true)
			end
			audioExt.playEffect(music_info.LOGIN_RANDOM_NAME.res)
			self.select_name_effect = CompositeEffect.new("tx_login_dice", 0, 0, self.m_select_info.rand_name_btn, nil, nil, nil, nil, true)
			self:freshRoleName(self.m_select_job_id)
		end, TOUCH_EVENT_ENDED)
	
	self.m_select_info.enter_btn:setPressedActionEnabled(true)
	self.m_select_info.enter_btn:addEventListener(function()
			self:enterOK()
			audioExt.pauseMusic()
			audioExt.stopAllEffects()
			audioExt.playEffect(music_info.LOGIN_ENTER.res, false)
		end, TOUCH_EVENT_ENDED) 

	self.m_ui_layer.btn_switch:setPressedActionEnabled(true)
	self.m_ui_layer.btn_switch:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.switchAccount()
		end, TOUCH_EVENT_ENDED)
	
	self.m_ui_layer.btn_service:setPressedActionEnabled(true)
	self.m_ui_layer.btn_service:addEventListener(function()
			audioExt.playEffect(music_info.COMMON_BUTTON.res, false)
			local module_game_sdk = require("module/sdk/gameSdk")
			module_game_sdk.openLoginService()
		end, TOUCH_EVENT_ENDED)
	
	local input_pos = self.m_select_info.input_bg_spr:getPosition()
	local frame = display.newSpriteFrame("role_rename.png")
	self.m_name_editbox = CCEditBox:create(CCSize(248,50),CCScale9Sprite:createWithSpriteFrame(frame))
	self.m_name_editbox:setPosition(ccp(input_pos.x, input_pos.y))
	self.m_name_editbox:setPlaceholderFont("ui/font/title.fnt", 22)
	self.m_name_editbox:setFont("ui/font/title.fnt", 22)
	self.m_name_editbox:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_GRASS)))
	self.m_name_editbox:setMaxLength(21)  --8个中文
	self.m_name_editbox:setFontColor(ccc3(dexToColor3B(COLOR_WHITE)))
	self.m_name_editbox:setFontSize(22)
	self.m_name_editbox:setInputFlag(kEditBoxInputFlagSensitive)
	self.m_name_editbox:setAnchorPoint(ccp(0.5, 0.5))
	self.m_name_editbox:registerScriptEditBoxHandler(function(eventType)
		if eventType == "ended" then
			local is_ok, name_str = self:checkInputText(true)
			self.m_name_editbox:setText(name_str)
			self.m_name_editbox.org_name_str = name_str
		end
	end)
	self.m_name_editbox:setZOrder(-1)
	self.m_select_info.input_bg_spr:getParent():addCCNode(self.m_name_editbox)
	self.m_select_info.input_bg_spr:setVisible(false)
	self.m_name_editbox:setTouchEnabled(false)
	self.m_name_editbox:setVisible(false)
	
	self:hideRoleDetail(true)	
end

ClsSelectRole3dUi.enterOK = function(self)
	if self.btn_lock then return end
	self.btn_lock = true
	require("framework.scheduler").performWithDelayGlobal(function()
		self.btn_lock = false
	end , 3)
	audioExt.playEffect(music_info.COMMON_BUTTON.res)
	local is_ok = true
	local name_str = ""
	local old_role_data = self.role_list[self.m_select_job_id]
	if not old_role_data then
		is_ok, name_str = self:checkInputText()
	end
	if is_ok then
		userDefault:setIntegerForKey(LAST_SELECT_ROLE_ID, self.m_select_job_id)
		userDefault:flush()
		local old_role_data = self.role_list[self.m_select_job_id]
		if old_role_data then --这个角色已经创建了帐号
			getGameData():getPlayerData():enterGame(old_role_data.uid)
			return
		end
		
		getGameData():getPlayerData():askRoleId(self.m_select_job_id, name_str)
	end
end 

ClsSelectRole3dUi.shipRunning = function(self)
	setNetPause(true)
	self:setEnterBtnEnable(false)
	self:hideRoleDetail()
	self:hideSpecialBtn()
	
	local id = self.m_select_job_id
	local role_id = job_id_to_unity_key[id]
	if role_id == 2 then 
		self.m_role3d_infos[id].particle_parent:setActive(false)			
	end 
	
	local camera_key = string.format("200%dC", role_id)
	local camera_ani_info = animation_clip_list[camera_key]
	local camera_clip = camera_ani_info.key[2]
	local camera = self.m_role3d_infos[id].camrea
	camera:playU3dCfgAnimationByClip(camera_ani_info.res, camera_clip)
	local dtime = camera:getAnimationDuration(camera_clip)/1000
	require("framework.scheduler").performWithDelayGlobal(function()
		setNetPause(false)
	end , dtime)
end

ClsSelectRole3dUi.checkInputText = function(self, is_trip)
	local text = self.m_name_editbox:getText()
	if text == "" then
		text = self.m_name_editbox:getPlaceHolder()
	elseif is_trip then
		text = string.gsub(text, "%s", "")--去掉空格字符
	end
	text = ClsCommonFuns:returnUTF_8CharValid(text)
	local has = check_string_has_invisible_char(text)
	if has then
		ClsAlert:warning({msg = ui_word.INPUT_ILLEGAL, color = ccc3(dexToColor3B(COLOR_RED))})
		return false, text
	end
		
	local len_n = ClsCommonFuns:utfstrlen(text)
	if len_n < 2 then
		ClsAlert:warning({msg = news.LOGIN_IPUT_NAME.msg})
		return false, text
	elseif len_n > 7.5 then
		ClsAlert:warning({msg = news.ROLE_NAME_LONG.msg})
		return false, text
	elseif not checkNameTextValid(text) or not checkChatTextValid(text) then
		return false, text
	end
	return true, text
end

local role_info_panel = {
	{panel = "player_adventure", level = "player_level_adventure", name = "player_name_adventure", title = "player_title_adventure"}, --位置2
	{panel = "player_navy", level = "player_level_navy", name = "player_name_navy", title = "player_title_navy"}, --位置3 
	{panel = "player_pirate", level = "player_level_pirate", name = "player_name_pirate", title = "player_title_pirate"}  --位置1
}

ClsSelectRole3dUi.initOldRoleInfo = function(self)
	local player_panel = getConvertChildByName(self.m_role_ui, "player_panel")
	--player_panel:setVisible(false)
	local role_info_table = {}
	for i,v in ipairs(role_info_panel) do
		role_info_table[i] = getConvertChildByName(player_panel, v.panel)
		role_info_table[i].name =  getConvertChildByName(player_panel, v.name)
		role_info_table[i].level =  getConvertChildByName(player_panel, v.level)
		role_info_table[i].title =  getConvertChildByName(player_panel, v.title)
		if tolua.isnull(role_info_table[i].effect) then
			role_info_table[i].effect = CompositeEffect.new("tx_role_select_1", 0, 10, role_info_table[i], nil, nil, nil, nil, true)
		end
		
		role_info_table[i].level:setVisible(false)
		role_info_table[i].name:setText(ui_word.PLEASE_CREATE)
		role_info_table[i].name:setAnchorPoint(ccp(0.5, 0.5))
		role_info_table[i].title:setVisible(false)
	end
	
	for k,v in pairs(self.role_list) do
		role_info_table[k]:setVisible(true)
		role_info_table[k].title:setVisible(true)
		role_info_table[k].level:setVisible(true)
		role_info_table[k].name:setText(v.name)
		role_info_table[k].level:setText("Lv."..v.level)
		local nobility_data = getGameData():getNobilityData()
		local nobility_info = nobility_data:getNobilityDataByID(v.nobility)
		if nobility_info then
			role_info_table[k].title:changeTexture(convertResources(nobility_info.peerage_before), UI_TEX_TYPE_PLIST)
		else
			role_info_table[k].title:setVisible(false)
		end
		self:adaptTitleName(role_info_table[k].title, role_info_table[k].name, role_info_table[k].level)
	
	end

	self.role_info_table = role_info_table
end

--适配位置，中心对齐
ClsSelectRole3dUi.adaptTitleName = function(self, left_panel, center_panel, right_panel)

	local center_size = center_panel:getContentSize()
	local center_pos = center_panel:getPosition()
	
	local left_x = center_pos.x - center_size.width/2
	local rigth_x = center_pos.x + center_size.width/2
	
	local left_pos = left_panel:getPosition()
	left_panel:setPosition(ccp(left_x, left_pos.y))
	
	local right_pos = right_panel:getPosition()
	right_panel:setPosition(ccp(rigth_x, right_pos.y))
end


ClsSelectRole3dUi.hideOtherPlayerPanel = function(self, index)
	for i,v in ipairs(self.role_info_table) do
		if i == index and self.role_list[index] then
			v:setOpacity(0)
			local effect = CompositeEffect.new("tx_role_select_2", 0, 5, v, nil, nil, nil, nil, true)
			effect:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1), CCCallFunc:create(function ( )
				effect:removeFromParentAndCleanup(true)
				v:setVisible(false)
			end)))
		else
			v:setVisible(false)
		end
	end
end

ClsSelectRole3dUi.resetPlayerPanel = function(self)
	local player_panel = getConvertChildByName(self.m_role_ui, "player_panel")
	player_panel:setVisible(true)
	for k,v in pairs(self.role_info_table) do
		v:setVisible(true)
	end
end


ClsSelectRole3dUi.selectJobId = function(self, id_n)
	self.touch_layer:removeFromParentAndCleanup(true)
	if self.show_black_layer > 0 then
		local black_layer = CCLayerColor:create(ccc4(0, 0, 0, 255))
		black_layer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCFadeOut:create(1)))
		black_layer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.2), CCCallFunc:create(function ()
			black_layer:removeFromParentAndCleanup(true)
		end)))
		self:addChild(black_layer, 11)
	else
		self:hideOtherPlayerPanel(id_n)
		local player_panel = getConvertChildByName(self.m_role_ui, "player_panel")
		player_panel:setVisible(true)
		player_panel:stopAllActions()
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(3))
		array:addObject(CCCallFunc:create(function( )
			player_panel:setVisible(false)
		end))
		player_panel:runAction(CCSequence:create(array))
	end
	--self:resetPlayerPanel()
	self.show_black_layer = self.show_black_layer + 1
	
	
	
	self.m_select_job_id = id_n
	local mountain_ani_info = animation_clip_list[1]
	local sea_ani_info = animation_clip_list[2]
	for i, job_btn_info in ipairs(self.m_job_btns) do
		local role3d_info = self.m_role3d_infos[i]
		if i == id_n then
			job_btn_info.job_btn:setScale(1)
			job_btn_info.job_btn:setTouchEnabled(false)
			job_btn_info.job_text_bg:setTouchEnabled(false)
			job_btn_info.unselect_job_lab:setVisible(false)
			job_btn_info.select_name_spr:setVisible(true)
			job_btn_info.select_btn_spr:setVisible(true)
			self.m_select_info.power_sprs[i]:setVisible(true)
			self.m_select_info.desc_lab:setText(role_info[i].detailed_des)
			self.m_select_info.job_attr:setText(role_info[id_n].job_atr)
			local job_difficulty = role_info[id_n].job_difficulty
			for i=1,3 do
				if i <= job_difficulty then
					self.m_select_info["star_"..i]:setVisible(true)
				else
					self.m_select_info["star_"..i]:setVisible(false)
				end
			end

			
			local old_role_data = self.role_list[self.m_select_job_id]
			if old_role_data then --这个角色已经创建了帐号
				self:updateRoleInfoPanel()
				self.m_select_info.role_info:setVisible(true)
				self.m_select_info.role_intro:setVisible(false)
				self.m_select_info.btn_enter_text:setText(ui_word.SELECT_ENTER_GEME)
			else
				self.m_select_info.role_info:setVisible(false)
				self.m_select_info.role_intro:setVisible(true)
				self.m_select_info.btn_enter_text:setText(ui_word.SELECT_SELECT_ROLE)
			end
			
			if role3d_info then
				role3d_info.camrea:setActiveCamera()
				--role3d_info.camrea:playAnimation()
				local camera_key = string.format("200%dC", job_id_to_unity_key[id_n])
				local camera_ani_info = animation_clip_list[camera_key]
				local camera_clip = camera_ani_info.key[1]
				role3d_info.camrea:playU3dCfgAnimationByClip(camera_ani_info.res, camera_clip)
				
				role3d_info.ship:playAnimation("move", false, false)
				role3d_info.person_model:playAnimation("move", false, false)
				role3d_info.person_model:playU3dCfgAnimation()
				role3d_info.ship:playU3dCfgAnimation()
				self:hideRoleDetail()
				self:freshRoleName(i)
				self:regMoveEndAnim(i)
				--self:showTargetShipEffect(i)
				self:hideWaitingEffect()
				
				--播放天空材质动画 ，切换材质后要重新加载模型动画，否则会出现模型报错
				self.m_sky_model:stopU3dCfgAnimation()
				self.m_sky_model:setMaterial(role3d_info.sky_material_str)
				self.m_sky_model:initModelAnim()
				self.m_sky_model:playU3dCfgAnimation()

				local mountain_name = mountain_ani_info.res
				local mountain_clip = mountain_ani_info.key[job_id_to_unity_key[i]]
				for _, mountain in pairs(self.m_mountains_node:getAllChildNode()) do
					mountain:playU3dCfgAnimationByClip(mountain_name, mountain_clip)
				end
				local sea_clip = sea_ani_info.key[job_id_to_unity_key[i]]
				self.m_sea:playU3dCfgAnimationByClip(sea_ani_info.res, sea_clip)
			end
		else
			job_btn_info.job_btn:setScale(0.8)
			job_btn_info.job_btn:setTouchEnabled(true)
			job_btn_info.job_text_bg:setTouchEnabled(true)
			job_btn_info.unselect_job_lab:setVisible(true)
			job_btn_info.select_name_spr:setVisible(false)
			job_btn_info.select_btn_spr:setVisible(false)
			self.m_select_info.power_sprs[i]:setVisible(false)
			role3d_info.person_model:resetU3dCfgAnimation()
			role3d_info.ship:resetU3dCfgAnimation()
			if role3d_info then
				if role3d_info.ship:isPlayAnimation("move") then
					role3d_info.ship:playAnimation("stand1", true)
					role3d_info.person_model:playAnimation("stand1", true)
				end
			end
		end
	end

	local sky = self.m_u3d_scene:getNodeByName("sky")
	sky:playU3dCfgAnimation()

	self:playRoleMusicByIndex(id_n)

	self:hideSpecialBtn()
end

ClsSelectRole3dUi.playRoleMusicByIndex = function(self, id)
	local role_music_info = role_music[id]
	audioExt.pauseMusic()
	audioExt.stopAllEffects()
	audioExt.playMusic(role_music_info.role_res, false)

	self:stopAllActions()
	local array = CCArray:create()
	for k, sound_info in ipairs(role_music_info.extra_music) do
		if sound_info.delay then
			array:addObject(CCDelayTime:create(sound_info.delay))
		end
		array:addObject(CCCallFunc:create(function()
			if sound_info.is_music then
				audioExt.playMusic(sound_info.name, sound_info.isLoop)
			else
				audioExt.playEffect(sound_info.name, sound_info.isLoop)
			end
		end))
	end
	local action = CCSequence:create(array)
	self:runAction(action)
end

ClsSelectRole3dUi.updateRoleInfoPanel = function(self)
	local panel = self.m_select_info.role_info
	local select_role_info = self.role_list[self.m_select_job_id]
	local name_right = getConvertChildByName(panel, "name_right")
	local level_right = getConvertChildByName(panel, "level_right")
	local prestige_num = getConvertChildByName(panel, "prestige_num")
	local uid_num  = getConvertChildByName(panel, "uid_num")
	name_right:setText(select_role_info.name)
	level_right:setText("Lv."..select_role_info.level)
	uid_num:setText(select_role_info.uid)
	prestige_num:setText(select_role_info.prestige)
	local nobility_data = getGameData():getNobilityData()
	local nobility_info = nobility_data:getNobilityDataByID(select_role_info.nobility)
	local title_pic = getConvertChildByName(panel, "title_pic")
	if nobility_info then
		title_pic:changeTexture(convertResources(nobility_info.peerage_before), UI_TEX_TYPE_PLIST)
	else
		title_pic:setVisible(false)
	end
	
	local guild_id = select_role_info.groupId
	local group_icon = select_role_info.groupIcon
	local group_name = select_role_info.groupName

	if  guild_id <= 0 or tostring(group_icon) == "" or tostring(group_name) == "" then 
		local guild_level = getConvertChildByName(panel, "guild_level")
		local guild_name = getConvertChildByName(panel, "guild_name")
		local guild_icon = getConvertChildByName(panel, "guild_icon")
	   
		guild_level:setVisible(false)
		guild_name:setVisible(false)
		guild_icon:setVisible(false)
	else 
		local guild_level = getConvertChildByName(panel, "guild_level")
		local guild_name = getConvertChildByName(panel, "guild_name")
		local guild_icon = getConvertChildByName(panel, "guild_icon")
		local guild_no = getConvertChildByName(panel, "guild_no_txt")
			
		local ClsGuildBadge = require("game_config/guild/guild_badge")
		guild_level:setText("Lv."..select_role_info.groupLevel)
		guild_name:setText(select_role_info.groupName)
		
		local badge_data = ClsGuildBadge[tonumber(select_role_info.groupIcon)]
		guild_icon:changeTexture(convertResources(badge_data.res), UI_TEX_TYPE_PLIST)
		guild_level:setVisible(true)
		guild_name:setVisible(true)
		guild_icon:setVisible(true)
		guild_no:setVisible(false)
	end
end

--协议发送失败后返回更新界面按钮提示
ClsSelectRole3dUi.rpcBack = function(self, err, role_id)
	local Alert = require("ui/tools/alert")
	Alert:warning({msg = error_info[err].message, color = ccc3(dexToColor3B(COLOR_RED))})
	self:setEnterBtnEnable(true)
end

ClsSelectRole3dUi.setEnterBtnEnable = function(self, enable)
	self.m_ui_layer:setTouchEnabled(enable)
end

ClsSelectRole3dUi.hideRoleDetail = function(self, not_hide_job)
	self.m_select_info.select_ui:setEnabled(false)
	self.m_select_info.select_ui:stopAllActions()
	
	self:updatePlayerNamePanel(false)
	if not not_hide_job then
	   self.job_bg:setVisible(false) 
	end
end

ClsSelectRole3dUi.showRoleDetail = function(self, select_id)
	self.m_select_info.select_ui:setEnabled(true)
	self.m_select_info.select_ui:stopAllActions()
	self.m_select_info.select_ui:setOpacity(0)
	self.m_select_info.select_ui:runAction(CCFadeIn:create(0.3))
	self.job_bg:setVisible(true)
	self.job_bg:setOpacity(0)
	self.job_bg:runAction(CCFadeIn:create(0.3))
	self:updatePlayerNamePanel(true)
	self:showSpecialBtn()
end

ClsSelectRole3dUi.showSpecialBtn = function(self)
	local module_game_sdk = require("module/sdk/gameSdk")
	local platform = module_game_sdk.getPlatform()
	self.m_ui_layer.btn_service:setVisible(platform == PLATFORM_WEIXIN or platform == PLATFORM_QQ)
	if self.m_ui_layer.btn_service:isVisible() and GTab.IS_VERIFY then
		self.m_ui_layer.btn_service:setVisible(false)
	end
	self.m_ui_layer.btn_switch:setVisible(true)
end

ClsSelectRole3dUi.hideSpecialBtn = function(self)
	self.m_ui_layer.btn_switch:setVisible(false)
	self.m_ui_layer.btn_service:setVisible(false)
end

ClsSelectRole3dUi.updatePlayerNamePanel = function(self, status)
	local updateDetailPlayerName
	updateDetailPlayerName = function(status)
		self.m_name_editbox:setTouchEnabled(status)
		self.m_name_editbox:setVisible(status)
		--self.m_select_info.player_name_bg:setVisible(not status)
		self.m_select_info.rand_name_btn:setVisible(status)
		self.m_select_info.rand_name_btn:setTouchEnabled(status)
	end
	if not status then
		self.m_name_editbox:setTouchEnabled(status)
		self.m_name_editbox:setVisible(status)
		
		self.m_select_info.rand_name_btn:setVisible(status)
		self.m_select_info.rand_name_btn:setTouchEnabled(status)
	else
		 updateDetailPlayerName(not self.role_list[self.m_select_job_id]) 
	end
	self.m_select_info.rand_name_btn:setOpacity(255)
end

ClsSelectRole3dUi.hideAllShipEffect = function(self)
	self:showTargetShipEffect()
end

ClsSelectRole3dUi.showTargetShipEffect = function(self, select_id)
	for i, role3d_info in pairs(self.m_role3d_infos) do
		if role3d_info.particle_parent then
			if select_id == i then
				role3d_info.is_show_particle = true
				self:setIsShowEffects(role3d_info.particle_parent, true)
			else
				if role3d_info.is_show_particle then
					self:setIsShowEffects(role3d_info.particle_parent, false)
				end
				role3d_info.is_show_particle = false
			end
		end
	end
end

ClsSelectRole3dUi.hideWaitingEffect = function(self)
	if self.m_waiting_effect_info.is_show then
		self.m_waiting_effect_info.is_show = false
		self:setIsShowEffects(self.m_waiting_effect_info.root_node, false)
	end
end

ClsSelectRole3dUi.setIsShowEffects = function(self, root_node, is_show)
	local setNodeEffects
	setNodeEffects = function(node_target, is_show_effect)
		local nodes = node_target:getAllChildNode()
		for _, node in pairs(nodes) do
			if node:getType() == "model" then
				setNodeEffects(node, is_show_effect)
			else
				if is_show_effect then
					node:stop()
					node:start()
				else
					node:stop()
				end
			end
		end
	end
	setNodeEffects(root_node, is_show)
	root_node:setActive(is_show)
end

ClsSelectRole3dUi.regMoveEndAnim = function(self, select_id)
	self.m_scene_ui:stopAllActions()
	local role3d_info = self.m_role3d_infos[select_id]
	if role3d_info then
		local call_act = CCCallFunc:create(function()
				local role3d_info = self.m_role3d_infos[select_id]
				if role3d_info.person_model:isPlayAnimationEnd("move") then
					role3d_info.person_model:playAnimation("stand2", true, true)
					role3d_info.ship:playAnimation("stand2", true, true)
					self.m_scene_ui:stopAllActions()
					self:showRoleDetail(select_id)
				end
			end)
		local delay_act = CCDelayTime:create(0.01)
		self.m_scene_ui:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(delay_act, call_act)))
	end
end

ClsSelectRole3dUi.freshRoleName = function(self, select_id)
	if select_id > 0 then
		local new_name_str = ClsDataTools:getRoleNameByRoleId(select_id)
		self.m_name_editbox.org_name_str = new_name_str
		self.m_name_editbox:setText(new_name_str)
	end
end

local doBtnEffect
doBtnEffect = function(camrea, btn, lab)
	local cfg = btn.cfg
	local tran = cfg.offset.tran
	local rotate = cfg.offset.rotate
	
	if tran.x ~= 0 or tran.y ~= 0 or tran.z ~= 0 then
		local pos_vec3 = camrea:getNode():getTranslation()
		--camrea:getNode():setTranslation(Vector3.new(pos_vec3:x() + tran.x, pos_vec3:y() + tran.y, pos_vec3:z() + tran.z))
		camrea:getNode():setTranslation(pos_vec3:x() + tran.x, pos_vec3:y() + tran.y, pos_vec3:z() + tran.z)
		if lab then
			local pos_vec3 = camrea:getNode():getTranslation()
			lab:setString(string.format("(x,y,z) = (%d, %d, %d)", math.floor(pos_vec3:x()), math.floor(pos_vec3:y()), math.floor(pos_vec3:z())))
		end
	end
	
	local rate_n = math.pi/180
	if rotate.x ~= 0 then
		camrea:getNode():rotateX(rotate.x*rate_n)
	end
	if rotate.y ~= 0 then
		camrea:getNode():rotateY(rotate.y*rate_n)
	end
	if rotate.z ~= 0 then
		camrea:getNode():rotateZ(rotate.z*rate_n)
	end
end

ClsSelectRole3dUi.initTestUiBtn = function(self)
	local config = {
		[1] = {pos = {x = 100, y = 100}, name = "上", offset = {tran = {x = 0, y = 1, z = 0}, rotate = {x = 0, y = 0, z = 0}}},
		[2] = {pos = {x = 150, y = 100}, name = "下", offset = {tran = {x = 0, y = -1, z = 0}, rotate = {x = 0, y = 0, z = 0}}},
		[3] = {pos = {x = 200, y = 100}, name = "前", offset = {tran = {x = 0, y = 0, z = -1}, rotate = {x = 0, y = 0, z = 0}}},
		[4] = {pos = {x = 250, y = 100}, name = "后", offset = {tran = {x = 0, y = 0, z = 1}, rotate = {x = 0, y = 0, z = 0}}},
		[5] = {pos = {x = 300, y = 100}, name = "左", offset = {tran = {x = -1, y = 0, z = 0}, rotate = {x = 0, y = 0, z = 0}}},
		[6] = {pos = {x = 350, y = 100}, name = "右", offset = {tran = {x = 1, y = 0, z = 0}, rotate = {x = 0, y = 0, z = 0}}},
		[7] = {pos = {x = 400, y = 100}, name = "转上", offset = {tran = {x = 0, y = 0, z = 0}, rotate = {x = 1, y = 0, z = 0}}},
		[8] = {pos = {x = 450, y = 100}, name = "转下", offset = {tran = {x = 0, y = 0, z = 0}, rotate = {x = -1, y = 0, z = 0}}},
		[9] = {pos = {x = 500, y = 100}, name = "转左", offset = {tran = {x = 0, y = 0, z = 0}, rotate = {x = 0, y = 1, z = 0}}},
		[10] = {pos = {x = 550, y = 100}, name = "转右", offset = {tran = {x = 0, y = 0, z = 0}, rotate = {x = 0, y = -1, z = 0}}},
	}
	
	local offset_x = 70
	for k, v in ipairs(config) do
		v.pos.x = 170 + (k - 1)*offset_x
		v.pos.y = 40
	end
	local total_spr = display.newLayer()
	self.m_scene_ui:addChild(total_spr)
	local btn_list = {}
	for k, v in ipairs(config) do
		local icon_spr = display.newSprite("#common_9_tips2.png", v.pos.x, v.pos.y)
		icon_spr:setAnchorPoint(ccp(0.5, 0.5))
		icon_spr:addChild(createBMFont({text = v.name, size = 18, x = icon_spr:getContentSize().width/2, y = icon_spr:getContentSize().height/2}))
		total_spr:addChild(icon_spr)
		
		icon_spr.cfg = v
		btn_list[k] = icon_spr
	end
	
	self.m_click_time = 0
	self.m_click_btn = nil
	total_spr:registerScriptTouchHandler(function(event, x, y)
		if "began" == event then
			self.m_click_btn = nil
			self.m_click_time = 0
			for k, btn in ipairs(btn_list) do
				local pos = btn:convertToNodeSpace(ccp(x,y))
				if pos.x >= 0 and pos.x <= btn:getContentSize().width then
					if pos.y >= 0 and pos.y <= btn:getContentSize().height then
						self.m_click_btn = btn
						self.m_click_time = os.clock()
						doBtnEffect(self.m_camrea, self.m_click_btn, self.m_tips_lab)
						self.m_click_btn:setScale(0.9)
						return true
					end
				end
			end
			return false
		elseif "move" == event then
		else
			self.m_click_time = 0
			if self.m_click_btn then
				self.m_click_btn:setScale(1)
			end
			self.m_click_btn = nil
		end
	end, false, -9999, false)
	total_spr:setTouchEnabled(true)
	
	local act = require("ui/tools/UiCommon"):getRepeatAction(0, function()
			if self.m_click_btn and self.m_click_time > 0 then
				if os.clock() > (self.m_click_time + 0.5) then
					doBtnEffect(self.m_camrea, self.m_click_btn, self.m_tips_lab)
				end
			end
		end)
	total_spr:runAction(act)
end

ClsSelectRole3dUi.onExit = function(self)
	UnLoadPlist(self.plist_table)
	
	self.m_role3d_infos = nil
	self.m_sea = nil
	self.m_camrea = nil
	self.m_mountains_node = nil
	self.m_waiting_effect_info = nil
	self.m_sky_model = nil
	
	if self.m_u3d_scene then
		self.m_u3d_scene:release()
		self.m_u3d_scene = nil
	end
end


loadSelectRoleView = function()
	hideVersionInfo()
	GameUtil.runScene(function()
		local createLayer
		createLayer = function()
			local running_scene = GameUtil.getRunningScene()
			local layer = ClsSelectRole3dUi.new()
			running_scene:addChild(layer, -1)
		end
		local ModulePortLoading = require("gameobj/port/portLoading")
		ModulePortLoading:loading(createLayer, res_tab, "selectRole")
	end )
end

--return ClsSelectRole3dUi
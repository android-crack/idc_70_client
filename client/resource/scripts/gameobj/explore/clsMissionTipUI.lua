local wm_cfg = require("game_config/world_mission/world_mission_info")
local twm_cfg = require("game_config/world_mission/world_mission_team")
local item_info = require("game_config/propItem/item_info")
local cm_cfg = require("game_config/loot/time_plunder_info")
local ui_word = require("game_config/ui_word")
local alert = require("ui/tools/alert")
local music_info = require("game_config/music_info")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
-- local
local scheduler = CCDirector:sharedDirector():getScheduler()
local clsMissionTipUI = class("clsMissionTipUI",require("ui/view/clsBaseTipsView"))
local GUILD_CD = 60000
local SPECIAL_MISSION_ID = 1000

-- override
function clsMissionTipUI:getViewConfig()
	local data = {}
	data.name = "clsMissionTipUI"
	data.is_back_bg = false
	-- data. = UI_TYPE.NOTICE
	data.effect = UI_EFFECT.SCALE
	return self.super.getViewConfig(self, name_str,data)
end

function clsMissionTipUI:onEnter(data)
	self.data = data
	self.is_team_mission = data.is_has_accepted
	self.m_can_fight = false

	self:addBgTouchCloseBg()
	self:resetData()
	self:initData()
	self:initUI()
	self:updateUI()

	ClsGuideMgr:tryGuide("clsMissionTipUI")
end

function clsMissionTipUI:onExit()
	ReleaseTexture(self)
end

function clsMissionTipUI:resetData()
	self.is_init_ui = false
	self.ui_data = {}
	self:resetTimer()
end

function clsMissionTipUI:resetTimer()
	if self.timer then
		scheduler:unscheduleScriptEntry(self.timer)
	end
	self.timer = nil
end

function clsMissionTipUI:initData()
	local type_2_cfg = {
		[EXPLORE_NAV_TYPE_WORLD_MISSION] = wm_cfg,
		[EXPLORE_NAV_TYPE_CONVOY_MISSION] = cm_cfg,
	}
	local id = self.data.id
	local _type = self.data.type

	local cfg = type_2_cfg[_type]
	local item = cfg[id]
	if not item and _type == EXPLORE_NAV_TYPE_WORLD_MISSION then
		item = twm_cfg[id]
	end
	if not item then print("no item") return false end

	local function parseWMData()
		local _module = getGameData():getWorldMissionData()
		local item = _module:getWorldMissionList()[id]
		if not item then return end
		local data = {}
		data.m_type = item.cfg.type
		data.m_status = item.status
		data.name = item.cfg.name
		data.time = {}
		data.time.begin = item.startTime
		data.time.remain = item.remainTime
		data.time._end = item.remainTime + item.startTime
		data.consume_num = item.cfg.star * 10
		data.star = item.cfg.star
		data.content = _module:getParseStrById(id,false)
		data.detail = item.cfg.mission_txt
		data.is_show = (item.cfg.goto_team == 1)
		data.rewards = item.rewards -- 服务器给
		data.navi_data = {}
		data.navi_data.x = item.cfg.position_explore[1]
		data.navi_data.y = item.cfg.position_explore[2]
		data.navi_data.str = data.name
		data.navi_data.area = item.cfg.area
		for i = 1,2 do
			data["icon_data"..i], data["num_data"..i] = getCommonRewardIcon(item.rewards[i])
		end

		local new_table = {}
		local reward_cfg = item.cfg.reward_text
		for k,v in pairs(reward_cfg) do
			local new_item = {}
			new_item.id = k
			new_item.num = v
			new_table[#new_table+1] = new_item
		end

		table.sort(new_table,function ( a,b )
			return a.id > b.id
		end)
		data.new_table = new_table
		return data
	end

	local function parseCMData()
		local _module = getGameData():getConvoyMissionData()
		local time_data = _module:getTimeData()
		local item = _module:getShowList()[id]
		local cur_item = _module:getCurItem()
		local is_accepted
		if cur_item then
			is_accepted = (id == cur_item.id)
		else
			is_accepted = false
		end
		local data = {}
		data.name = is_accepted and cur_item.cfg.name or ui_word.YUNBIAO_TASK_NAME
		data.content = is_accepted and cur_item.cfg.desc[1] or ""
		data.time = {}
		data.time.begin = time_data.begin
		data.time.remain = time_data.duration
		data.time._end = data.time.begin + data.time.remain
		data.star = item.cfg.star
		local function getStr()
			local target_str = ""
			for k,v in pairs(item.cfg.port_desc) do
				target_str = target_str .. v
			end

			target_str = string.gsub(target_str,"#","")

			return target_str
		end
		data.detail = item.cfg.intro
		data.is_show = (item.cfg.goto_team == 1)
		data.navi_data = {}
		data.navi_data.x = item.cfg.position_explore[1]
		data.navi_data.y = item.cfg.position_explore[2]
		data.navi_data.str = ui_word.YUNBIAO_TASK_NPC_NAME

		data.rewards = {}
		local temp = {}
		temp.icon = "#common_icon_diamond.png"
		temp.num = item.cfg.reward
		table.insert(data.rewards, temp)
		return data
	end

	local data = {}
	if _type == EXPLORE_NAV_TYPE_WORLD_MISSION then
		data = parseWMData()
	elseif _type == EXPLORE_NAV_TYPE_CONVOY_MISSION then
		data = parseCMData()
	end
	self.ui_data = data
	return true
end

function clsMissionTipUI:initUI()
	if self.is_init_ui then return end
	local main_ui = GUIReader:shareReader():widgetFromJsonFile("json/worldmap_port_tips.json")
	convertUIType(main_ui)
	main_ui:setPosition(ccp(display.cx*0.5+120,150))
	self:addWidget(main_ui)
	self:setIgnoreClosePanel(main_ui)
	local wgts = {
		["name"] = "event_text",
		["time"] = "time_num",
		["content"] = "mission_text",
		["detail"] = "event_info",
		["tips"] = "advice_text",
		["btn_transfer"] = "btn_transfer",
		["btn_go"] = "btn_go",
		["btn_go_text"] = "btn_go_text",
		["time_text"] = "time_text",

		["icon1"] = "coin_icon",
		["icon2"] = "diamond_icon",
		["num1"] = "coin_num",
		["num2"] = "diamond_num",
	}

	for k,v in pairs(wgts) do
		main_ui[k] = getConvertChildByName(main_ui, v)
	end

	main_ui.tili_panel = getConvertChildByName(main_ui, "tili_panel")
	local tili_icon = getConvertChildByName(main_ui.tili_panel, "tili_icon")
	main_ui.tili_panel.icon = tili_icon
	local tili_num = getConvertChildByName(main_ui.tili_panel, "tili_num")
	main_ui.tili_panel.num = tili_num
	main_ui.tili_panel:setVisible(false)
	local team_tips = getConvertChildByName(main_ui, "team_tips")
	if self.is_team_mission then
		team_tips:setVisible(true)
	end
	if self.data.id == SPECIAL_MISSION_ID then
		main_ui.time:setVisible(false)
	end

	local function navi_callback()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local world_mission_handle = getGameData():getWorldMissionData()
		if not self.is_team_mission then
			local data = self.ui_data
			if data then
				data = data.navi_data
			end
			if not data then return end
			local explore_map = getUIManager():get("ExploreMap") or getUIManager():get("PortMap")
			if not tolua.isnull(explore_map) then
				self:closeUI()
				explore_map:naviToPoint(data.x+2,data.y+2,data.str,{is_world_mission = self.data.id, area_id = data.area})
			end
		else
			if self.m_can_fight then
				if getGameData():getTeamData():isTeamFull() then
					world_mission_handle:askTeamFight(self.data.id)
				else
					alert:warning({msg = ui_word.STR_TEAM_WORLD_MISSION_FIGHT_TIP})
				end
			else
				if getGameData():getGuildInfoData():hasGuild() then
					if CCTime:getmillistimeofCocos2d() - world_mission_handle:getAskGuildTime() > GUILD_CD then
						world_mission_handle:askGuildHelp(1,self.data.id)
						world_mission_handle:setAskGuildTime(CCTime:getmillistimeofCocos2d())
					else
						alert:warning({msg = ui_word.STR_TEAM_WORLD_MISSION_GUILD_CD})
					end
				else
					alert:warning({msg = ui_word.STR_TEAM_WORLD_MISSION_GUILD_TIP})
				end
			end
			self:closeUI()
		end
	end
	main_ui.btn_go:addEventListener(navi_callback,TOUCH_EVENT_ENDED)

	self.main_ui = main_ui
	main_ui.btn_go:setTouchEnabled(false)
	
	if self.data.type == EXPLORE_NAV_TYPE_WORLD_MISSION then
		main_ui.btn_transfer:setPressedActionEnabled(true)
		local last_time = 0
		main_ui.btn_transfer:addEventListener(function()
				if CCTime:getmillistimeofCocos2d() - last_time >= 1000 then
					audioExt.playEffect(music_info.COMMON_BUTTON.res)
					getGameData():getExploreData():askExploreTransfer(EXPLORE_TRANSFER_TYPE.WORDLD_MISSION, self.data.id, function()
							last_time = CCTime:getmillistimeofCocos2d()
							self:close()
						end)
				end
			end, TOUCH_EVENT_ENDED)
		if getGameData():getConvoyMissionData():isDoingMission() then
			main_ui.btn_transfer:disable()
		else
			main_ui.btn_transfer:active()
		end
		getGameData():getExploreData():handleTansferBtn(main_ui.btn_transfer, "clsMissionTipUI", "#common_btn_orange3.png")
	else
		main_ui.btn_transfer:disable()
	end

	self.is_init_ui = true
end

function clsMissionTipUI:updateUI()
	if not self:initData() then return end
	if not self.ui_data then return end
	local data = self.ui_data
	local main_ui = self.main_ui
	main_ui.name:setText(data.name)
	main_ui.detail:setText(data.detail)
	main_ui.name:setText(data.name)
	main_ui.content:setText(data.content)
	main_ui.tips:setVisible(false)
		
	local _type = self.data.type
	if _type == EXPLORE_NAV_TYPE_WORLD_MISSION then
		if self.ui_data.m_type == "teambattle" then
			main_ui.tili_panel:setVisible(false)
		end
		main_ui.tili_panel.num:setText(data.consume_num)
		local new_table = data.new_table
		for i = 1, 2 do
			if new_table[i].id ~= 0 then
				local res_str = item_info[new_table[i].id].res
				res_str = string.gsub(res_str, "#", "")
				main_ui["icon"..i]:changeTexture(res_str, UI_TEX_TYPE_PLIST)
				main_ui["num"..i]:setText(new_table[i].num)
			else
				main_ui["icon"..i]:setVisible(false)
				main_ui["num"..i]:setText(new_table[i].num)
				main_ui["num"..i]:setPosition(ccp(-46-35,-80))
				main_ui["num"..i]:setColor(ccc3(dexToColor3B(COLOR_WHITE_STROKE_RED)))
			end
		end
		if self.is_team_mission then
			main_ui.btn_go_text:setText(ui_word.STR_TEAM_WORLD_MISSION_GUILD_BTN)
			if getGameData():getTeamData():isTeamFull() then
				main_ui.btn_go_text:setText(ui_word.START_FIGHT)
				self.m_can_fight = true
			end
		end
	elseif _type == EXPLORE_NAV_TYPE_CONVOY_MISSION then
		for i = 1, 2 do
			if data.rewards[i] then
				main_ui["icon"..i]:changeTexture(convertResources(data.rewards[i].icon),UI_TEX_TYPE_PLIST)
				main_ui["num"..i]:setText(data.rewards[i].num)
			else
				main_ui["icon"..i]:setVisible(false)
				main_ui["num"..i]:setVisible(false)
			end
		end
	end

	for i = 1, 5 do
		local star = getConvertChildByName(main_ui,string.format("star_%d", i))
		star:setVisible(i <= data.star)
	end

	self:resetTimer()

	local function timer_callback()
		local cur = os.time() + getGameData():getPlayerData():getTimeDelta()
		if not data.time._end then return end
		local _end = data.time._end
		if cur < _end then
			local str = require("module/dataHandle/dataTools"):getTimeStrNormal(_end - cur)
			main_ui.time:setText(str)
		elseif data.m_type == "teambattle" then
			main_ui.time:setVisible(false)
		else
			self:closeUI()
		end
	end
	if data.time and self.data.id ~= SPECIAL_MISSION_ID then
		if data.m_type == "teambattle" and data.m_status == 1 then
			main_ui.time_text:setText(ui_word.WORLD_MISSION_TIP_MISSION_STATUS)
			main_ui.time:setText(ui_word.WORLDMISSION_DEAL_TIPS_ACCEPTED)
		else
			timer_callback()
			self.timer = scheduler:scheduleScriptFunc(timer_callback, 1, false)
		end
	end
	main_ui.btn_go:setTouchEnabled(true)
end

function clsMissionTipUI:preClose()
	self:resetData()
end

function clsMissionTipUI:closeUI()
	self:close()
	self:resetData()
	getUIManager():close("PortMap")
end

return clsMissionTipUI

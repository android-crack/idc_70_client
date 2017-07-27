
local music_info = require("game_config/music_info")
local info_title = require("game_config/title/info_title")
local skill_info = require("game_config/skill/skill_info")
local role_skill_info = require("game_config/role/role_skill_info")
local alert = require("ui/tools/alert")
local ui_word = require("scripts/game_config/ui_word")
local CompositeEffect = require("gameobj/composite_effect")
local base_info = require("game_config/base_info")
local CommonBase = require("gameobj/commonFuns")
local on_off_info = require("game_config/on_off_info")
local missionGuide = require("gameobj/mission/missionGuide")
local port_info = require("game_config/port/port_info")
local nobility_config = require("game_config/nobility_data")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsScrollView = require("ui/view/clsScrollView")
local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsRoleInfoView = class("ClsRoleInfoView",ClsBaseView)

local SKILL_TAB = 3
local LEGEND_ARENA_TITLE_TAG = 5

local TRIANGLE_DOWN = 1 --等级选择列表向下
local TRIANGLE_UP = 2   --等级选择列表向上

local btn_name = {
	{res = "btn_property", lable = "btn_property_text"},
	{res = "btn_details", lable = "btn_details_text"},
	-- {res = "btn_skill", lable = "btn_skill_text"},
}

local view_name = {
	"property_panel",
	"details_panel",
	-- "skill_panel",
}

local widget_name = {
	"btn_rename",
	"btn_set",
	"btn_collect",
	"captain_head",
	"seaman_name",
	-- "sailor_name_icon",
	"guild_name",
	"level_text",
	-- "nobility_text",
	-- "nobility_icon",
	-- "nobility_bg",
	"btn_close",
	-- "btn_arrow",
	-- "btn_text",
	"level_icon",---sab
	"exp_bar",
	"exp_num",
	-- "guild_join",
	-- "btn_select",
	"seaman_title",
	"uid_text",
	"job_text",
	-- "btn_change",
	-- "btn_rename",
	"title_bg",
	"title_text",
	"title_list_btn",
	"btn_arrow",
	"title_droplist",
	"right_bg",
	"btn_vip_qq",
	"qq_vip",
	"vip_icon",
	"qq_icon",
	"vip_start",
	"qq",
	"qq_start",
	"wechat",
	"wechat_start",
	"wechat_no_start",
	"btn_achieve",
}

local TYPE_SAILOR_SKILL = 2

function ClsRoleInfoView:getViewConfig()
	return {
		effect = UI_EFFECT.DOWN,
		is_back_bg = true,
	}
end

function ClsRoleInfoView:onEnter(uid, tab, end_callabck)

	self.plist = {
		["ui/partner.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
		["ui/fleet_ui.plist"] = 1,
		["ui/title_icon.plist"] = 1,
		["ui/guild_ui.plist"] = 1,
		["ui/title_name.plist"] = 1
	}
	LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_role.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)

	audioExt.playEffect(music_info.PAPER_STRETCH.res)
	self.m_end_callback = end_callabck

	if uid then
		self.uid = uid
	end

	for k,v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	for k,v in pairs(btn_name) do
		self[v.res] = getConvertChildByName(self.panel, v.res)
		self[v.lable] = getConvertChildByName(self.panel, v.lable)
	end
	for k,v in pairs(view_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end

	local task_data = getGameData():getTaskData()
	task_data:regTask(self.btn_achieve,  {on_off_info.PORT_BULLY.value,}, KIND_CIRCLE, on_off_info.PORT_BULLY.value, 20, 20, true)

	self.tab = tab
	self.skill_node_list = {}
	self:askData()
end

function ClsRoleInfoView:askData()
	local playerData = getGameData():getPlayerData()
	if self.uid and self.uid ~= playerData:getUid() then
		local captainInfoData = getGameData():getCaptainInfoData()
		captainInfoData:askForCaptainInfo(self.uid)
	else
		local partner_data = getGameData():getPartnerData()
		partner_data:askRoleInfo()
		getGameData():getTitleData():requestAllTitle()
	end
end

function ClsRoleInfoView:mkUI(data)

	self.role_info = data

	self:btnCallBack()
	self:updataView()
	self:clearTips()

	-- self:initDrapView()
	self:updateRenameBtn()
end

function ClsRoleInfoView:updataView()
	self:updataRoleInfo()
	-- self:updataSkillView()
	self:updataAttr()
	self:updataAttrInfo()
	self:updateCurTitleUI()
	self:updateQQVip()
	self:updateQQVipHead()
	self:updateBootStatus()
	local defult_view = self.tab or 1
	self:defultView(defult_view)
end

function ClsRoleInfoView:updateRenameBtn()
	self.btn_rename:setPressedActionEnabled(true)
	self.btn_rename:setTouchEnabled(true)
	self.btn_rename:addEventListener(function()
		local sceneDataHandler = getGameData():getSceneDataHandler()
		if sceneDataHandler:isInExplore() then
			alert:warning({msg = ui_word.TIPS_RENAME_EXPLOER})
		else	
			getGameData():getPlayerData():askReName()
		end
		
	end, TOUCH_EVENT_ENDED)
end


function ClsRoleInfoView:updateQQVip()
	if GTab.IS_VERIFY then
		self.btn_vip_qq:setVisible(false)
		self.btn_vip_qq:setTouchEnabled(false)
		return
	end
	local module_game_sdk = require("module/sdk/gameSdk")
	platform = module_game_sdk.getPlatform()
	--self.vip_qq:setPosition(ccp(display.cx, display.cy))
	if platform == PLATFORM_QQ and device.platform == "android" then
		self.btn_vip_qq:setVisible(true)
		self.btn_vip_qq:setTouchEnabled(true)
	else
		self.btn_vip_qq:setVisible(false)
		self.btn_vip_qq:setTouchEnabled(false)
	end
	self.btn_vip_qq:setPressedActionEnabled(true)
	self.btn_vip_qq:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		local module_game_sdk = require("module/sdk/gameSdk")
		local url = "http://mq.vip.qq.com/m/game/vipembed"
		module_game_sdk.openQQVip(url)
	end, TOUCH_EVENT_ENDED)
end


function ClsRoleInfoView:updateBootStatus()
	if GTab.IS_VERIFY then
		self.vip_start:setVisible(false)
		self.vip_start:setTouchEnabled(false)
		return
	end
	local boot_status = getGameData():getBuffStateData():getBootStatus()
	self.vip_start:setVisible(true)
	if boot_status == BOOT_QQ then --qq启动       
		self.wechat:setVisible(false)
		self.qq:setVisible(true)
	elseif boot_status == BOOT_WX then
		self.wechat:setVisible(true)
		self.qq:setVisible(false)
		self.wechat_no_start:setVisible(true)
		self.wechat_start:setVisible(false)

	else
		local module_game_sdk = require("module/sdk/gameSdk")
		local platform = module_game_sdk.getPlatform()
		if platform == PLATFORM_QQ then
			self.wechat:setVisible(false)
			self.qq:setVisible(true)
			self.qq_start:setGray(true)
		elseif platform == PLATFORM_WEIXIN then
			self.wechat:setVisible(true)
			self.qq:setVisible(false)
			self.wechat_no_start:setVisible(false)
			self.wechat_start:setVisible(true)
		else
			self.vip_start:setVisible(false)
		end
	end
	self.vip_start:setTouchEnabled(true)
	self.vip_start:addEventListener(function ( )
		getUIManager():create("gameobj/tips/clsBootRewardTips")
	end, TOUCH_EVENT_ENDED)
end


function ClsRoleInfoView:updateQQVipHead()
	local vip_status = getGameData():getBuffStateData():getQQVipStatus()
	if vip_status == 0 then
		self.qq_vip:setVisible(false)
	elseif vip_status == 1 then
		self.qq_vip:setVisible(true)
		self.vip_icon:setVisible(false)
		self.qq_icon:setVisible(true)
	elseif vip_status == 2 then
		self.qq_vip:setVisible(true)
		self.vip_icon:setVisible(true)
		self.qq_icon:setVisible(false)
	end
end
function ClsRoleInfoView:updataRoleInfo()
	local res = self.role_info.icon
	local seaman_res = string.format("ui/seaman/seaman_%s.png", res)
	self.captain_head:changeTexture(seaman_res, UI_TEX_TYPE_LOCAL)
	self.seaman_name:setText(self.role_info.name)
	self.captain_head:setVisible(true)

	-- 加载称号纹理资源
	local nobilityMsg =	nobility_config[self.role_info.nobility] or {}
	local file_name = nobilityMsg.peerage_before or "title_name_knight.png"
	file_name = convertResources(file_name)
	local effect
	if file_name ~= "title_name_knight.png" then
		-- 如果称号是骑士，则没有特效
		effect = CompositeEffect.new("tx_0197" ,-64+8 , 1 , self.seaman_title , nil , nil , nil , nil , true)
	end
	self.seaman_title:changeTexture(file_name , UI_TEX_TYPE_PLIST)

	--矫正位置
	local a_width = (self.seaman_title:getContentSize().width)*0.6
	local b_width = self.seaman_name:getContentSize().width
	local offset = a_width -(a_width+b_width)/2
	self.seaman_title:setPosition(ccp(offset,0))
	self.seaman_name:setPosition(ccp(offset,0))

	local level = self.role_info.grade
	self.level_text:setText("Lv."..level.." "..ROLE_OCCUP_NAME[self.role_info.profession])

	--职业图标
	local role_job_pic = JOB_RES[self.role_info.profession]
	-- self.sailor_name_icon:changeTexture(role_job_pic, UI_TEX_TYPE_PLIST)
	-- self.job_text:setText(ROLE_OCCUP_NAME[self.role_info.profession])

	--商会名
	if(self.role_info.group == "")then
		self.guild_name:setText(ui_word.NO_INJION_SHANGHUI)
	else
		self.guild_name:setText(ui_word.STR_GUILD_NAME..":"..self.role_info.group)
	end

	--称号
	local titleName = ""
	local titleMsg = nil
	local titles = self.role_info.titles or {}
	local curTitleId = 0
	if(self.uid)then--别人的
		curTitleId = self.role_info.current_title_id or 0
	else--自己的
		local title_data = getGameData():getTitleData()
		curTitleId = title_data:getCurTitle() or 0
	end

	if(curTitleId > 0)then
		for i=1,#titles do
			if(titles[i].id == curTitleId)then
				titleMsg = titles[i]
				break
			end
		end
	end
	if(titleMsg)then
		local tmp_title = info_title[titleMsg.id].title
		local msgTab = lua_string_split(tmp_title,"%%")
		if(#msgTab > 2)then
			tmp_title = msgTab[1].."%"..msgTab[2]
		end
		titleName = string.format(tmp_title,titleMsg.args[1] or "")
	end
	self:setTitleText(titleName)

	---设置
	local playerData = getGameData():getPlayerData()
	if self.uid and self.uid ~= playerData:getUid() then
		self.btn_set:setVisible(false)
		self.btn_set:setTouchEnabled(false)
	end
	self.btn_set:setPressedActionEnabled(true)
	self.btn_set:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("ui/systemMainUI")
	end, TOUCH_EVENT_ENDED)

	self.btn_achieve:setPressedActionEnabled(true)
	self.btn_achieve:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("ui/ClsAchievement")
	end, TOUCH_EVENT_ENDED)

	---收藏室
	self.btn_collect:setPressedActionEnabled(true)
	self.btn_collect:addEventListener(function (  )
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		if isExplore then
			local portData = getGameData():getPortData()
			local portName = port_info[portData:getPortId()].name
			alert:showAttention(string.format(ui_word.SET_COLLEXCT_TIPS, portName), function()
			---回港
				portData:setEnterPortCallBack(function()
					loadCollectMainUI(function()
						-- local port_layer = getUIManager():get("ClsPortLayer")
						-- port_layer:addItem(collectMain.new(self.uid))
						local data = {}
						data.id = self.uid
						getUIManager():create('gameobj/collectRoom/clsCollectMainUI',nil,data)
					end)
				end)
				portData:askBackEnterPort()
			end, nil, nil, {hide_cancel_btn = true})
			return
		end

		self.btn_collect:setTouchEnabled(false)
		local func = function()
			self.btn_collect:setTouchEnabled(true)
			local playerData = getGameData():getPlayerData()
			local uid = playerData:getUid()
			local plyer_uid  = uid
			if self.uid then
				plyer_uid = self.uid
			end
			-- self:addChild(collectMain.new(plyer_uid))
			local data = {}
			data.id = plyer_uid
			getUIManager():create('gameobj/collectRoom/clsCollectMainUI',nil,data)
		end
		loadCollectMainUI(func)
	end, TOUCH_EVENT_ENDED)


	local playerData = getGameData():getPlayerData()
	self.uid_text:setText(self.uid or playerData:getUid())
end

function ClsRoleInfoView:updateRoleName(new_name)
	if not tolua.isnull(self.seaman_name) then
		self.seaman_name:setText(new_name)
		--矫正位置
		local a_width = (self.seaman_title:getContentSize().width)*0.6
		local b_width = self.seaman_name:getContentSize().width
		local offset = a_width -(a_width+b_width)/2
		print("offset", offset)
		self.seaman_title:setPosition(ccp(offset,0))
		self.seaman_name:setPosition(ccp(offset,0))
	end


end

function ClsRoleInfoView:updateRoleTitle()
end
function ClsRoleInfoView:setTitleText( txt )
	local name = txt or ""
	self.title_text:stopAllActions()
	self.title_text:setPosition(ccp(104,15))
	self.title_text:setText(name)
	local nameLen = CommonBase:utfstrlen(name)
	if(nameLen < 12)then return end

	local actions = CCArray:create()
	local move_x = (self.title_text:getContentSize().width - 200)/2
	self.title_text:setPosition(ccp(104+move_x,15))
	local use_time = move_x / 20
	actions:addObject(CCMoveBy:create(use_time, ccp(-2*move_x, 0)))
	actions:addObject(CCMoveBy:create(use_time, ccp( 2*move_x, 0)))
	self.title_text:runAction(CCRepeatForever:create(CCSequence:create(actions)))
end
function ClsRoleInfoView:showRunEffect(name)
	if not name then return end
	if self.rich_label then
		self.rich_label:removeFromParentAndCleanup(true)
		self.rich_label = nil
	end
	if not tolua.isnull(self.clip_node) then
		self.clip_node:removeFromParentAndCleanup(true)
	end
	local nameLen = CommonBase:utfstrlen(name)
	if nameLen > 11 then
		self.title_text:setVisible(false)
		self.rich_label = createRichLabel(string.format("$(c:COLOR_BROWN)%s", name), self.title_text:getContentSize().width, 21, 16, nil, true)
		self.rich_label:setAnchorPoint(ccp(0, 0.5))
		self.rich_label:setPosition(ccp(227, 162))
		self.clip_node = CCClippingNode:create()
		local draw_node = CCDrawNode:create()
		local color = ccc4f(0, 1, 0, 1)
		local points = CCPointArray:create(4)
		local move_x = self.title_text:getContentSize().width - 176
		points:add(ccp(224, 151))
		points:add(ccp(224, 172))
		points:add(ccp(402, 172))
		points:add(ccp(402, 151))
		draw_node:drawPolygon(points, color, 0, color)
		draw_node:setPosition(ccp(0, 0))
		self.clip_node:setStencil(draw_node)
		self.clip_node:setInverted(false)
		self.clip_node:addChild(self.rich_label)
		self:addChild(self.clip_node)

		local actions = CCArray:create()
		local use_time = 10
		actions:addObject(CCMoveBy:create(use_time, ccp(-move_x, 0)))
		actions:addObject(CCMoveBy:create(0, ccp(move_x, 0)))
		self.rich_label:runAction(CCRepeatForever:create(CCSequence:create(actions)))
	end
end

function ClsRoleInfoView:addRichLabel(performance, title)
	if self.rich_label then
		self.rich_label:removeFromParentAndCleanup(true)
		self.rich_label = nil
	end

	if not tolua.isnull(self.clip_node) then
		self.clip_node:removeFromParentAndCleanup(true)
	end

	local str_performance = performance
	if title.mul_line == 1 then
		str_performance = string.split(str_performance, "$")[2]
		str_performance = "$" .. str_performance
	end

	self.rich_label = createRichLabel(str_performance, 160, 20, 16, nil, true)
	self.rich_label:ignoreAnchorPointForPosition(false)
	self.rich_label:setAnchorPoint(ccp(0.5,0.5))
	self.rich_label:setPosition(0, 0)
	local size_rich = self.rich_label:getContentSize()
	if title.sculpture ~= "" then
		local spr_left = display.newSprite(title.sculpture, 0, 0)
		spr_left:setAnchorPoint(ccp(1, 0))
		spr_left:setPosition(ccp(0, 0))

		self.rich_label:addChild(spr_left)
		local spr_right = display.newSprite(title.sculpture, 0, 0)
		spr_right:setFlipX(true)
		spr_right:setAnchorPoint(ccp(0, 0))
		spr_right:setPosition(ccp(size_rich.width, 0))
		self.rich_label:addChild(spr_right)

		if title.captain_figure_offset and not table.is_empty(title.captain_figure_offset) then
			spr_left:setPosition(ccp(-title.captain_figure_offset[1], title.captain_figure_offset[2]))
			spr_right:setPosition(ccp(self.rich_label:getContentSize().width + title.captain_figure_offset[1], title.captain_figure_offset[2]))
		end
	end

	if title.effect ~= "" then
		local effect_nums = math.ceil(size_rich.width / 25)
		for i = 1, effect_nums do
			CompositeEffect.new(title.effect, (i-1) * 25 + 12.5, -3, self.rich_label)
		end
	end

	--称号过长截屏并带跑马灯效果
	if title.mul_line == 1 then
		local name = string.split(str_performance, ")")[2]
		local nameLen = CommonBase:utfstrlen(name)
		if nameLen >= 8 then
			self.clip_node = CCClippingNode:create()
			local draw_node = CCDrawNode:create()
			local color = ccc4f(0, 1, 0, 1)
			local points = CCPointArray:create(4)
			points:add(ccp(0, 0))
			points:add(ccp(0, 35))
			points:add(ccp(140, 35))
			points:add(ccp(140, 0))
			draw_node:drawPolygon(points, color, 0, color)
			draw_node:setPosition(ccp(0, 0))
			self.clip_node:setStencil(draw_node)
			self.clip_node:setInverted(false)
			local title_layer = display.newLayer()
			self.clip_node:addChild(title_layer)
			title_layer:addChild(self.rich_label)
			-- self.btn_text:addCCNode(self.clip_node)
			self.clip_node:setPosition(ccp(-62, -17.5))
			self.rich_label:setAnchorPoint(ccp(0, 0.5))
			local start_x = 25
			self.rich_label:setPosition(ccp(start_x, 17.5))
			local width_title = 68 + self.rich_label:getContentSize().width
			local actions = CCArray:create()
			local use_time = 10
			for i = 1, 2 do
				local move = CCMoveTo:create(use_time, ccp(- width_title, 17.5))
				actions:addObject(move)
				actions:addObject(CCCallFunc:create(function()
					self.rich_label:setPosition(ccp(140, 17.5))
				end))
			end
			actions:addObject(CCMoveTo:create((140 - 25) / ((140 + width_title) / use_time), ccp(25, 17.5))) --是为了和前面两次速度相同
			self.rich_label:runAction(CCSequence:create(actions))
		else
			-- self.btn_text:addRenderer(self.rich_label, 11)
		end
	else
		-- self.btn_text:addRenderer(self.rich_label, 11)
	end
end

---详情
function ClsRoleInfoView:updataAttrInfo()

	local hit_percent = self.role_info.hitPro/10 + 95
	if hit_percent > 100 then
		hit_percent = 100
	end
	local crit_percent = self.role_info.critsPro/10
	local dodge_percent = self.role_info.dodgePro/10
	local confront_crit_percent = self.role_info.antiCritsPro/10
	local hurt_add_percent = self.role_info.damageIncrease/10
	local hurt_reduce_percent = self.role_info.damageReduction/10

	local attrs_info_name = {
		[ATTR_KEY_REMOTE] = {res = "far", text = ui_word.ROLE_ATTRS_REMOTE},		---远程攻击
		[ATTR_KEY_MELEE] = {res = "near", text = ui_word.ROLE_ATTRS_MELEE},			--近战攻击
		[ATTR_KEY_DEFENSE] = {res = "defense", text = ui_word.ROLE_ATTRS_DEFENSE},	--防御
		[ATTR_KEY_DURABLE] = {res = "long", text = ui_word.ROLE_ATTRS_DURABLE},		--耐久
		[ATTR_KEY_HIT] = {res = "hit_rate", text = string.format(ui_word.ROLE_ATTRS_HIT, hit_percent)},			--命中等级
		[ATTR_KEY_CRITS] = {res = "crit", text = string.format(ui_word.ROLE_ATTRS_CRITS, crit_percent)},			--暴击等级
		[ATTR_KEY_DODGE] = {res = "dodge", text = string.format(ui_word.ROLE_ATTRS_DODGE, dodge_percent)},		--闪避等级
		[ATTR_KEY_SPEED] = {res = "speed", text = ui_word.ROLE_ATTRS_SPEED},		--速度
		[ATTR_KEY_RANGE] = {res = "range", text = ui_word.ROLE_ATTRS_RANGE},		--射程
		[ATTR_KEY_DAMAGE_INCREASE] = {res = "hurt_add", text = string.format(ui_word.ROLE_ATTRS_DAMAGE_INCREASE, hurt_add_percent)},		--伤害幅增
		[ATTR_KEY_DAMAGE_REDUCTION] = {res = "hurt_reduce", text = string.format(ui_word.ROLE_ATTRS_DAMAGE_REDUCTION, hurt_reduce_percent)},	--伤害减免
		[ATTR_KEY_ANTI_CRITS] = {res = "confront_crit", text = string.format(ui_word.ROLE_ATTRS_ANTI_CRITS, confront_crit_percent)},	--抗暴击等级
	}

	for k,v in pairs(attrs_info_name) do
		self[v.res.."_num"] = getConvertChildByName(self.details_panel, v.res.."_num")
		self[v.res.."_text"] = getConvertChildByName(self.details_panel, v.res.."_text")
		self[v.res.."_text"]:setTouchEnabled(true)
		self[v.res.."_text"]:addEventListener(function ()
			self[v.res.."_num"]:executeEvent(TOUCH_EVENT_ENDED)
		end, TOUCH_EVENT_ENDED)

		self[v.res.."_num"]:setTouchEnabled(true)
		self[v.res.."_num"]:setText(self.role_info[k])

		local attr_text = getConvertChildByName(self.details_panel, v.res.."_text")
		local btn_pos 	= self[v.res.."_text"]:getPosition()
		local data 		= 
		{
			name 		= attr_text:getStringValue(),
			tips_txt 	= v.text,
			pos 		= ccp(btn_pos.x, btn_pos.y)
		}

		self[v.res.."_num"]:addEventListener(function ()

			getUIManager():create("gameobj/playerRole/clsRoleAttrDetailsTip", nil, data)

		end, TOUCH_EVENT_ENDED)
	end
end

function ClsRoleInfoView:updataAttr()
	local attr_name = {
		"circle",
		"power_num",
		"attr_far_num",
		"attr_near_num",
		"attr_defense_num",
		"attr_long_num",
	}
	for k,v in pairs(attr_name) do
		self[v] = getConvertChildByName(self.property_panel, v)
	end
	--战力
	self.power_num:setText(self.role_info.power)

	local exp = self.role_info.exp

	local total_exp = base_info[self.role_info.grade].exp
	local percent = exp/total_exp*100

	self.exp_num:setText(exp.."/"..total_exp)
	self.exp_bar:setPercent(percent)

	--远程，近程，防御，耐久
	self.attr_far_num:setText(self.role_info.remote)
	self.attr_near_num:setText(self.role_info.melee)
	self.attr_defense_num:setText(self.role_info.defense)
	self.attr_long_num:setText(self.role_info.durable)
	--self:drawLine(self.circle)

	if not tolua.isnull(self.line_layer) then
		self.line_layer:removeFromParentAndCleanup(true)
	end
	local line_layer = self:drawLine()
	self.circle:addCCNode(line_layer)
	self.line_layer = line_layer
end

function ClsRoleInfoView:drawLine()
	local radius = 77
	local attr_list = {self.role_info.remote, self.role_info.melee, self.role_info.defense, self.role_info.durable/10}
	local max = self:getMaxNum(attr_list)
	local far = self.role_info.remote*(radius / max)
	local naer = self.role_info.melee*(radius / max)
	local defense = 0 - self.role_info.defense*(radius / max)
	local long = 0 - self.role_info.durable/10*(radius / max)

	local layer = UILayer:create()
	local draw_node = CCDrawNode:create()
	local color = ccc4f(1, 0, 0, 0.2)
	local border_color = ccc4f(1, 0, 0, 0.2)
	local points = CCPointArray:create(4)

	points:add(ccp(0, far))
	points:add(ccp(long, 0))
	points:add(ccp(0, defense))
	points:add(ccp(naer, 0))
	draw_node:drawPolygon(points, color, 1, border_color)
	layer:addChild(draw_node)
	--node:addCCNode(layer)
	return layer
end

function ClsRoleInfoView:getMaxNum(attr)
	local max_num = 0
	for i = 1, #attr do
		if max_num < attr[i] then
			max_num = attr[i]
		end
	end
	return max_num
end

function ClsRoleInfoView:mkItem(tab, data)
	local node = display.newNode()
	node.ui_layer = UILayer:create()
	local skill_panel = GUIReader:shareReader():widgetFromJsonFile("json/partner_role_list.json")
	convertUIType(skill_panel)
	node.ui_layer:addWidget(skill_panel)
	node:addChild(node.ui_layer)

	local skill_data = skill_info[data.skillId]

	local skill_widget_name  = {
		"skill_icon",
		"skill_name",
		"skill_level",
		"skill_passivity_bg",
		"skill_bg",
		"btn_add",
		"black_bg", ---锁
	}

	for k,v in pairs(skill_widget_name) do
		node[v] = getConvertChildByName(skill_panel, v)
	end

	node.skill_icon:changeTexture(convertResources(skill_data.res), UI_TEX_TYPE_PLIST)--UI_TEX_TYPE_PLIST

	node.skill_icon:setTouchEnabled(true)
	node.skill_icon:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local pos = node.skill_icon:convertToWorldSpace(ccp(-500, -100))
		local temp = {}
		temp.pos = pos
		temp.skill = data.skillId
		temp.skill_level = data.level
		node.skill_tips = getUIManager():create("gameobj/playerRole/clsRoleSkillTips",{},self, temp)
	end, TOUCH_EVENT_ENDED)

	---主动 1 被动 0  背景
	local active_skill_status = 1
	local auto_skill_status = 0
	node.skill_passivity_bg:setVisible(skill_data.initiative == active_skill_status)
	node.skill_bg:setVisible(skill_data.initiative == auto_skill_status)
	missionGuide:disableAllGuide()
	missionGuide:pushGuideBtn(on_off_info.SKILL_PAGE.value, {rect = CCRect(697, 420, 86, 36), guideLayer = self})
	missionGuide:pushGuideBtn(on_off_info.SKILL_BUTTON.value, {rect = CCRect(545, 305, 25, 25), guideLayer = self})
	node.skill_name:setText(skill_data.name)

	node.btn_add:setPressedActionEnabled(true)
	node.btn_add:addEventListener(function ()
		if isExplore then
			self:gotoPort(ui_word.SET_ADD_SKILL_TIPS, function()
				if data.level and data.limit <= data.level then
					node.btn_add:disable()
					node.btn_add:setTouchEnabled(true)
				end
			end)
			return
		end

		if data.level and data.limit <= data.level then
			node.btn_add:disable()
		end
	end, TOUCH_EVENT_BEGAN)

	node.btn_add:addEventListener(function ()
		if isExplore then return end
		if data.level and data.limit <= data.level then
			node.btn_add:disable()
			node.btn_add:setTouchEnabled(true)
		end

	end, TOUCH_EVENT_CANCELED)

	node.btn_add:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		if isExplore then return end

		local partner_data = getGameData():getPartnerData()
		partner_data:upgradeRoleSkill(data.skillId)
		self.tab = 	SKILL_TAB
		if data.level and data.limit <= data.level then
			node.btn_add:disable()
			node.btn_add:setTouchEnabled(true)
		end

	end, TOUCH_EVENT_ENDED)

	if data.level then
		local level = data.level
		local max_level = skill_data.max_lv
		-- if tonumber(level) >= tonumber(max_level) then
		-- 	level = "MAX"
		-- end

		local str = tonumber(level) >= tonumber(max_level) and "Lv.MAX" or string.format("Lv.%s/%s", level, max_level)

		node.skill_level:setText(str)

		node.skill_icon:setTouchEnabled(true)

		if data.limit > data.level then
			node.btn_add:active()
		else
			node.btn_add:disable()
		end
		node.btn_add:setTouchEnabled(true)
		node.black_bg:setVisible(false)
		setUILabelColor(node.skill_name, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))
	else
		local open_level = skill_data.open_level
		node.skill_level:setText(string.format(ui_word.ROLE_SKILL_OPRN_LEVEL, open_level))
		node.skill_icon:setTouchEnabled(false)
		setUILabelColor(node.skill_name, ccc3(dexToColor3B(COLOR_CAMEL)))
		node.black_bg:setVisible(true)
		node.btn_add:setVisible(false)
	end

	if self.uid then
		node.btn_add:setTouchEnabled(false)
	end
	return node
end

function ClsRoleInfoView:clearTips()
	for k,v in pairs(self.skill_node_list) do
		if v.skill_tips then
			v.skill_tips:close()
		end
	end

	if not tolua.isnull(self.skill_tips) then
		self.skill_tips:close()
	end

	self:setTouch(true)
end

function ClsRoleInfoView:updataSkillView()
	local skill_name = {
		"skill_bg_frame",
		"skill_lock",
		"skill_lock_bg",
		"skill_icon",
		"skill_name",
		"skill_level",
		"btn_refresh",
		"surplus_num",
		"btn_add",
	}

	for k,v in pairs(skill_name) do
		self[v]= getConvertChildByName(self.skill_panel, v)
	end

	self.btn_refresh:setPressedActionEnabled(true)
	self.btn_refresh:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		if isExplore then
			self:gotoPort(ui_word.SET_REFRESH_TIPS)
			return
		end

		alert:showAttention(ui_word.SKILL_IS_RESET, function()
			self.tab = SKILL_TAB
			local partner_data = getGameData():getPartnerData()
			partner_data:resetSkillPoint()
		end)

	end, TOUCH_EVENT_ENDED)

	if isExplore or self.uid then
		self.btn_refresh:setVisible(false)
		self.btn_refresh:setTouchEnabled(false)
	end

	if not self.uid then
		self.btn_refresh:setVisible(true)
		self.btn_refresh:setTouchEnabled(true)
	end

	self.surplus_num:setText(self.role_info.skillPoint)

	---组装skill列表
	local skill_list = {}
	local role_skill_list = role_skill_info[self.role_info.roleId]["Skills"]
	for k,v in pairs(role_skill_list) do
		local is_open ,skill_info = self:getNoOpenSkill(v)

		if not is_open then
			skill_list[#skill_list + 1] = {["skillId"] = v}
		else
			skill_list[#skill_list + 1] = skill_info
		end
	end

	local skill_list_re = {}
	local skill_light = {}
	for k,v in pairs(skill_list) do
		local skill_is_string = tostring(v.skillId)
		if string.sub(skill_is_string,2) ~= "401" then
			skill_list_re[#skill_list_re + 1] = v
		else
			skill_light[#skill_light + 1] = v
		end
	end

	local skill_list_info = skill_list_re
	local x ,y = 495,245
	local space_x = 90
	local space_y = 90 --105
	local skill_num = 12
	local raw = 4
	local total_cell = math.ceil(skill_num/raw)
	local node_tag = 1

	if self.skill_node_list then
		for k,v in pairs(self.skill_node_list) do
			v:removeFromParentAndCleanup(true)
			v = nil
		end
		self.skill_node_list ={}
	end

	for i = 1,total_cell do
		for j=1,raw do
			if node_tag > skill_num then return end
			local node = self:mkItem(node_tag, skill_list_info[node_tag])
			node:setPosition(ccp(x+(j-1)*space_x, y-(i-1)*space_y))
			node:setVisible(false)
			self.skill_node_list[#self.skill_node_list + 1] = node
			self:addChild(node)
			node_tag = node_tag	+ 1
		end
	end


	local data = skill_light[1]
	local skill_data = skill_info[data.skillId]
	self.skill_icon:changeTexture(convertResources(skill_data.res), UI_TEX_TYPE_PLIST)
	self.skill_name:setText(skill_data.name)

	self.skill_icon:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)

		local pos = self.skill_icon:convertToWorldSpace(ccp(-500, -100))
		local temp = {}
		temp.pos = pos
		temp.skill = data.skillId
		temp.skill_level = data.level
		self.skill_tips = getUIManager():create("gameobj/playerRole/clsRoleSkillTips",{},self, temp)

	end, TOUCH_EVENT_ENDED)


	self.btn_add:setTouchEnabled(true)
	self.btn_add:addEventListener(function ()
		if isExplore then
			self:gotoPort(ui_word.SET_ADD_SKILL_TIPS, function()
				if data.level and data.limit <= data.level then
					self.btn_add:disable()
				end
			end)
			return
		end

		if data.level and data.limit <= data.level then
			self.btn_add:disable()
		end
	end, TOUCH_EVENT_BEGAN)


	self.btn_add:addEventListener(function ()
		if isExplore then return end
		if data.level and data.limit <= data.level then
			self.btn_add:disable()
			self.btn_add:setTouchEnabled(true)
		end
	end, TOUCH_EVENT_CANCELED)

	self.btn_add:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		if isExplore then return end
		local partner_data = getGameData():getPartnerData()
		partner_data:upgradeRoleSkill(data.skillId)
		self.tab = 	SKILL_TAB

		if data.level and data.limit <= data.level then
			self.btn_add:disable()
			self.btn_add:setTouchEnabled(true)
		end
	end, TOUCH_EVENT_ENDED)


	if data.level then
		local level = data.level
		local max_level = skill_data.max_lv
		if tonumber(level) >= tonumber(max_level) then
			level = "MAX"
		end
		if data.limit > data.level then
			self.btn_add:active()
		else
			self.btn_add:disable()
		end
		self.btn_add:setTouchEnabled(true)
		self.skill_lock_bg:setVisible(false)
		setUILabelColor(self.skill_name, ccc3(dexToColor3B(COLOR_YELLOW_STROKE)))
		self.skill_icon:setTouchEnabled(true)
		self.skill_level:setText(string.format("Lv.%s/Lv.%s", level, max_level))
	else
		self.skill_lock_bg:setVisible(true)
		setUILabelColor(self.skill_name, ccc3(dexToColor3B(COLOR_CAMEL)))
		self.skill_icon:setTouchEnabled(false)
		local open_level = skill_data.open_level
		self.skill_level:setText(string.format(ui_word.ROLE_SKILL_OPRN_LEVEL, open_level))
		self.btn_add:setVisible(false)
	end

	if self.uid then
		self.btn_add:setTouchEnabled(false)
	end
end

function ClsRoleInfoView:gotoPort(str, close_func)
	local portData = getGameData():getPortData()
	local portName = port_info[portData:getPortId()].name
	alert:showAttention(string.format(str, portName), function()
	---回港
		portData:setEnterPortCallBack(function()
			local missionSkipLayer = require("gameobj/mission/missionSkipLayer")
			local port_layer = getUIManager():get("ClsPortLayer")
			local layer = missionSkipLayer:skipLayerByName("character")
			port_layer:addItem(layer)
		end)
		portData:askBackEnterPort()
	end, close_func, nil, {hide_cancel_btn = true})
end

---未开放skill
function ClsRoleInfoView:getNoOpenSkill(skill_id)
	for k,v in pairs(self.role_info.skills) do
		if v.skillId == skill_id then
			return true, v
		end
	end
	return false, skill_id
end

function ClsRoleInfoView:defultView(tab)
	self:selectView(tab)
end

function ClsRoleInfoView:btnCallBack()
	for k,v in pairs(btn_name) do
		self[v.res]:addEventListener(function ()
			setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		end, TOUCH_EVENT_BEGAN)

		self[v.res]:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)

			getUIManager():close("ClsRoleAttrDetailsTip")

			self:selectView(k)
		end, TOUCH_EVENT_ENDED)

		self[v.res]:addEventListener(function ()
			setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end, TOUCH_EVENT_CANCELED)
	end

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		
		getUIManager():close("ClsRoleAttrDetailsTip")

		if self.m_end_callback then
			self.m_end_callback()
			return
		end
		self:close()
	end,TOUCH_EVENT_ENDED)

	--称号下拉
	self.title_bg:addEventListener(function()

		-- 测试弹出获得的物品信息界面
		package.loaded["gameobj/playerRole/clsRoleTitleUI"] = nil
		local data = {}
		getUIManager():create("gameobj/playerRole/clsRoleTitleUI", nil, data,{is_back_bg = true})

		-- self:showOrHideLevelItem()
		-- if(not self.title_list)then return end
		-- require("framework.scheduler").performWithDelayGlobal(function()
		-- 	if(self.title_list.m_cells[self.title_index])then
		-- 		self.title_list.m_cells[self.title_index]:onTap(0, 0)
		-- 	end
		-- end, 0.25)
	end, TOUCH_EVENT_ENDED)
end

function ClsRoleInfoView:selectView(tab)
	for k,v in pairs(btn_name) do
		self[v.res]:setFocused(tab == k)
		self[v.res]:setTouchEnabled(tab ~= k)
		if tab == k then
			setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_SELECTED)))
		else
			setUILabelColor(self[v.lable], ccc3(dexToColor3B(COLOR_TAB_UNSELECTED)))
		end
	end

	for k,v in pairs(view_name) do
		self[v]:setVisible(tab == k)
	end

	if not self.skill_node_list then return end
	for k,v in pairs(self.skill_node_list) do
		v:setVisible(tab == SKILL_TAB)
		v.ui_layer:setTouchEnabled(tab == SKILL_TAB)
	end
end

function ClsRoleInfoView:onExit()
	missionGuide:enableAllGuide()
	UnLoadPlist(self.plist)
end

function ClsRoleInfoView:setTouch(enable)
	-- self.layer:setTouchEnabled(enable)
	if self.skill_node_list then
		for k,v in pairs(self.skill_node_list) do
			v.ui_layer:setTouchEnabled(enable)
		end
	end
	if(self.title_list)then self.title_list:setTouchEnabled(enable)end
end

-------------------------称号cell-------------------------
local ClsTitleCell = class("ClsTitleCell", ClsScrollViewItem)

function ClsTitleCell:updateUI(cell_date, cell_ui)
	self:setNormal()
	cell_ui.title_text:setText(cell_date.title)
end
function ClsTitleCell:onTap(x, y)
	self:updateView()
end
function ClsTitleCell:setNormal()
	self:getCellUI().title_bg:setVisible(false)
end
function ClsTitleCell:setForcus()
	self:getCellUI().title_bg:setVisible(true)
end
function ClsTitleCell:updateView()
	local role_ui = getUIManager():get("ClsRoleInfoView")
	if not tolua.isnull(role_ui.select_cell) then
		role_ui.select_cell:setNormal()
	end
	role_ui.select_cell = self
	self:setForcus()
	role_ui:updateDataAndViewBySelectTitle(self.m_cell_date.index)
end
---------------------------end----------------------------------

function ClsRoleInfoView:initDrapView(  )
	--只有本人能操作
	local playerData = getGameData():getPlayerData()
	local my_uid = playerData:getUid()
	local cur_uid = self.uid or my_uid

	--数据
	self.level_title_status = TRIANGLE_DOWN
	local allTitle = self.role_info.titles
	self.title_bg:setTouchEnabled(my_uid == cur_uid)
	self.title_list_btn:setVisible(my_uid == cur_uid)
	if(my_uid ~= cur_uid or #allTitle < 1)then return end

	--下拉框
	if(not tolua.isnull(self.title_list))then
		self.title_list:removeFromParentAndCleanup(true)
	end

	self.title_list = ClsScrollView.new(240, 196, true, function()
			local cell_ui = GUIReader:shareReader():widgetFromJsonFile("json/partner_title_list.json")
			cell_ui.title_text = getConvertChildByName(cell_ui, "title_text")
			cell_ui.title_bg = getConvertChildByName(cell_ui, "title_bg")
			return cell_ui
		end, {is_fit_bottom = true})
	self.title_list:setPosition(ccp(-120, -198))
	self.title_droplist:addChild(self.title_list)

	local title_data = getGameData():getTitleData()
	local cur_title = title_data:getCurTitle()
	self.title_droplist.select_items = {}
	self.title_infos = {}
	local first_cell = nil
	local cells = {}
	for i = 1,#allTitle do
		local tmp_title = info_title[allTitle[i].id].title
		local msgTab = lua_string_split(tmp_title,"%%")
		if(#msgTab > 2)then
			tmp_title = msgTab[1].."%"..msgTab[2]
		end
		local info = {}
		info.index = i
		info.title = string.format(tmp_title,allTitle[i].args[1] or "")
		info.title_id = allTitle[i].id
		local cell = ClsTitleCell.new(CCSize(236, 36), info)

		if cur_title == allTitle[i].id then
			first_cell = cell
		end
		table.insert(self.title_infos, info)
		table.insert(cells,cell)
	end

	self.title_list:addCells(cells)
	if(first_cell)then first_cell:onTap(0,0)end
end

function ClsRoleInfoView:updateCurTitleUI()

	-- print('------- updateCurTitleUI')
	local id = getGameData():getTitleData():getCurTitle()
	local item = getGameData():getTitleData():getTitleDataById(id)
	local cfg = info_title[id]
	local str = cfg.title
	local msgTab = lua_string_split(str,"%%")

	-- print('-------- cur_title_id',id)
	-- print('---------- cfg ------- ')
	-- table.print(cfg)
	-- print('--------- net data')
	-- table.print(item)

	if(#msgTab > 2)then
		str = msgTab[1].."%"..msgTab[2]
	end

	local to_roman = {T("Ⅰ"),T("Ⅱ"),T("Ⅲ"),T("Ⅳ"),T("Ⅴ"),T("Ⅵ"),T("Ⅶ"),T("Ⅷ"),T("Ⅸ"),T("Ⅹ"),T("Ⅺ"),T("Ⅻ")}
	if cfg.class and cfg.class ~= -1 and math.floor(cfg.class/10) ~= LEGEND_ARENA_TITLE_TAG then
		-- print('-------- test cfg class')
		-- print(cfg.class)
		local lv = (cfg.class)%10
		-- print(lv)
		-- print(to_roman[cfg.class],lv)
		str = str ..to_roman[lv]
	end

	if item then
		str = string.format(str,item.args[1] or "")
	end
	if self.title_text then
		self.title_text:setText(str)
	end
end

function ClsRoleInfoView:updateDataAndViewBySelectTitle(title_index, goal_id)
	local current_item = self.title_infos[title_index]
	self:setTitleText(current_item.title)

	--改称号处
	local title_data = getGameData():getTitleData()
	local cur_title = title_data:getCurTitle()
	if(cur_title ~= current_item.title_id)then
		GameUtil.callRpc("rpc_server_title_current", {current_item.title_id}, "rpc_client_title_current")
	end
end

function ClsRoleInfoView:showOrHideLevelItem()
	local icon = self.btn_arrow
	local level_frame = self.title_droplist
	if icon.is_actioning or level_frame.is_actioning then return end
	icon.is_actioning = true
	level_frame.is_actioning = true
	--三角图标动画
	local rotate_action = CCRotateBy:create(0.25, 180)
	local triangle_arr = CCArray:create()
	triangle_arr:addObject(rotate_action)
	triangle_arr:addObject(CCCallFuncN:create(function()
		icon.is_actioning = false
	end))
	icon:runAction(CCSequence:create(triangle_arr))

	--选项动画
	local item_arr = CCArray:create()
	local scale_action = nil
	if self.level_title_status == TRIANGLE_DOWN then
		scale_action = CCScaleTo:create(0.25, 1, 1)
	else
		scale_action = CCScaleTo:create(0.25, 1, 0)
	end
	item_arr:addObject(scale_action)
	item_arr:addObject(CCCallFuncN:create(function()
		level_frame.is_actioning = false
		self.level_title_status = self.level_title_status == TRIANGLE_DOWN and TRIANGLE_UP or TRIANGLE_DOWN
	end))
	level_frame:runAction(CCSequence:create(item_arr))
end

function ClsRoleInfoView:onTouchEnded(x, y)
	if self.drag.is_tap then--是点击
		if self.level_title_status == TRIANGLE_UP then
			self:showOrHideLevelItem()
		end
	end
end

return ClsRoleInfoView

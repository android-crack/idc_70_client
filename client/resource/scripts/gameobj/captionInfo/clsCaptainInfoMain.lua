--船长信息界面
local sailor_info = require("game_config/sailor/sailor_info")
local info_title = require("game_config/title/info_title")
local skill_info = require("game_config/skill/skill_info")
local baozang_info = require("game_config/collect/baozang_info")
local role_config = require("game_config/role/role_info")
local boat_info = require("game_config/boat/boat_info")
local arena_stage = require("game_config/arena/arena_stage")
local nobility_config = require("game_config/nobility_data")
local CompositeEffect = require("gameobj/composite_effect")
local music_info = require("game_config/music_info")
local ui_word = require("game_config/ui_word")
local ClsDataTools = require("module/dataHandle/dataTools")
local armature_manager = CCArmatureDataManager:sharedArmatureDataManager()

local ClsCaptainInfoMain = class("ClsCaptainInfoMain",require("ui/view/clsBaseView"))

local num_luoma = {"i","ii","iii","v","vi"}
local star_total = 4

local widget_name = {
	"level_num",
	"role_head_pic",
	"prestige_icon",
	"total_prestige_num",
	"role_name_txt",
	"job_icon",
	"role_pic",
	"guild_name",
	"title",      
	"staff_letter",   
	"role_info",      
	"arena_rank", 
	"arena_rank_icon",    
	"arena_rank_num",
	"skill_panel",
	"prestige_num",
	"btn_exclamation",
	"remote_num",  
	"melee_num",
	"durable_num",
	"defense_num",
	"btn_close",
	"star_panel",
	"role_head",
	"ship_panel",
	"role_title"
}
ClsCaptainInfoMain.getViewConfig = function(self)
	return {
		effect = UI_EFFECT.FADE,
		is_swallow = true,
	}
end

ClsCaptainInfoMain.onEnter = function(self, uid,data) 
	self.uid = uid

	if(self.uid and self.uid > 0 and not data)then
		local captainInfoData = getGameData():getCaptainInfoData()
		captainInfoData:askForCaptainInfo(self.uid)
	end

	self.m_role_index = 0
	
	self.plist = {
		["ui/title_name.plist"] = 1,
		["ui/title_icon.plist"] = 1,
		["ui/skill_icon.plist"] = 1,
		["ui/ship_skill.plist"] = 1,
		["ui/backpack.plist"] = 1, 
		["ui/arena_rank.plist"] = 1, 
		["ui/equip_icon.plist"] = 1,
		["ui/item_box.plist"] = 1,
	}
	LoadPlist(self.plist)

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/captain_info.json")
	convertUIType(self.panel)
	self:addWidget(self.panel)
	
	self:initUI()
	self:btnCallBack()
	if(data)then self:setData(data)end
end

ClsCaptainInfoMain.initUI = function(self)
	--头像
	self.m_head = {}
	for i=1,4 do
		local head_bg = getConvertChildByName(self.panel,"head_bg_"..i)
		local select_bg = getConvertChildByName(self.panel,"select_bg_"..i)
		local head_icon = getConvertChildByName(self.panel,"head_icon_"..i)
		local letter = getConvertChildByName(self.panel,"letter_"..i)
		self.m_head[i] = {head_bg = head_bg,select_bg = select_bg,head_icon = head_icon,letter = letter}
	end

	--宝物
	self.m_baowu = {}
	for i=1,3 do
		local baowu_bg = getConvertChildByName(self.panel,"baowu_"..i)
		local baowu_icon = getConvertChildByName(self.panel,"baowu_icon_"..i)
		local baowu_star = {}
		for star_index=1, star_total do
			baowu_star[star_index] = getConvertChildByName(self.panel, string.format("star_%d_%d", i, star_index))
		end
		self.m_baowu[i] = {baowu_bg = baowu_bg,baowu_icon = baowu_icon, baowu_star = baowu_star}
	end

	--星星
	self.m_star = {}
	for i=1,7 do
		local star_gold = getConvertChildByName(self.panel,"star_gold_"..i)
		self.m_star[i] = {star_gold = star_gold}
	end

	--技能
	self.m_skill = {}
	for i=1,5 do
		local skill = getConvertChildByName(self.panel,"skill_"..i)
		local skill_text_bg = getConvertChildByName(self.panel,"skill_text_bg_"..i)
		local skill_selected = getConvertChildByName(self.panel,"skill_selected_"..i)
		local skill_icon = getConvertChildByName(self.panel,"skill_icon_"..i)
		self.m_skill[i] = {skill = skill,skill_text_bg = skill_text_bg,skill_selected = skill_selected,skill_icon = skill_icon}
	end

	for k, v in pairs(widget_name) do
		self["m_"..v] = getConvertChildByName(self.panel, v)
	end

	self.uid_num = getConvertChildByName(self.panel, "uid_num")
	self.uid_num:setText(self.uid)
end 

ClsCaptainInfoMain.btnCallBack = function(self)
	--伙伴
	for i=1,#self.m_head do
		self.m_head[i].head_bg:setTouchEnabled(false)
		self.m_head[i].head_bg:addEventListener(function()
			if(self.m_role_index == i)then return end
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.m_role_index = i
			self:updateView()
		end,TOUCH_EVENT_ENDED)
	end

	--宝物
	for i=1,#self.m_baowu do
		self.m_baowu[i].baowu_bg:addEventListener(function()
			local baowu_data = self:getBaowaData(i)
			if(not baowu_data)then return end
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			getUIManager():create("gameobj/captionInfo/captainInfoTips", nil, "CaptainInfoTips", {effect = false}, baowu_data, true)
		end,TOUCH_EVENT_ENDED)
	end

	--技能
	for i=1,#self.m_skill do
		self.m_skill[i].skill:addEventListener(function()
			local temp = self:getSkillData(i)
			if(not temp)then return end
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self.m_att_tip = getUIManager():create("gameobj/playerRole/clsRoleSkillTips", nil ,self, temp, true)
		end,TOUCH_EVENT_ENDED)
	end

	--主角头像
	self.m_role_head:addEventListener(function()
		if(not self.m_data or self.m_role_index == 0)then return end
		self.m_role_index = 0
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self:updateView()
	end,TOUCH_EVENT_ENDED)

	--属性
	self.m_btn_exclamation:addEventListener(function()
		local attData,power = self:getRoleAttData()
		if(not attData)then return end
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		self.m_att_tip = getUIManager():create("gameobj/fleet/clsPartnerAttrTips",nil,self,ccp(280, 30),attData,power)
	end,TOUCH_EVENT_ENDED)

	--船
	self.m_ship_panel:addEventListener(function()
		if(tolua.isnull(self.ship_model))then return end
		if(not self.m_cur_data or not self.m_cur_data.boat_info)then return end 
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		getUIManager():create("gameobj/captionInfo/captainInfoTips", nil, "CaptainInfoTips", {effect = false}, self.m_cur_data.boat_info)
	end,TOUCH_EVENT_ENDED)

	--关闭
	self.m_btn_close:addEventListener(function()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		self:effectClose()
	end,TOUCH_EVENT_ENDED)
end

ClsCaptainInfoMain.setData = function(self, data)
	self.m_data = data
	self:updateHead()
	self:updateView()
end

ClsCaptainInfoMain.updateHead = function(self)
	--主角头像
	local role_info = self.m_data.role_info
	local res_pic = string.format("ui/seaman/seaman_%s.png",role_info.icon)
	self.m_role_head_pic:changeTexture(res_pic, UI_TEX_TYPE_LOCAL)
	self.m_role_head_pic:setVisible(true)
	self.m_total_prestige_num:setText(role_info.all_power)
	self.m_guild_name:setText(#role_info.group > 1 and ui_word.STR_GUILD_NAME..":"..role_info.group or "") 

	--称号
	local titleMsg = ""
	if(role_info.current_title_id > 0)then
		for i=1,#role_info.titles do
			local title_tab = role_info.titles[i]
			if(title_tab.id == role_info.current_title_id)then
				local tmp_title = info_title[title_tab.id].title
				titleMsg = string.format(tmp_title,title_tab.args[1] or "",title_tab.args[2] or "")
				break
			end
		end
	end
	self.m_title:setText(titleMsg)

	--爵位
	local nobilityMsg = nobility_config[role_info.nobility] or {}
	local file_name = nobilityMsg.peerage_before or "title_name_knight.png"
	file_name = convertResources(file_name)
	if file_name ~= "title_name_knight.png" then
		CompositeEffect.new("tx_0197" ,-64+8 , 1 , self.m_role_title , nil , nil , nil , nil , true)
	end
	self.m_role_title:changeTexture(file_name , UI_TEX_TYPE_PLIST)

	--伙伴头像
	local partner_info = self.m_data.partner_info
	for i=1,4 do
		local tmp = partner_info[i]
		local is_role = tmp ~= nil and tmp.id ~= 0
		self.m_head[i].head_icon:setVisible(is_role)
		self.m_head[i].letter:setVisible(is_role)
		self.m_head[i].head_bg:setTouchEnabled(is_role)
		if(is_role)then
			local sailor_config = sailor_info[tmp.id]
			self.m_head[i].head_icon:changeTexture(sailor_config.res, UI_TEX_TYPE_LOCAL) 
			self.m_head[i].letter:changeTexture(STAR_SPRITE_RES[tmp.quality].big, UI_TEX_TYPE_PLIST)
		end
	end
end

ClsCaptainInfoMain.updateView = function(self)
	self.m_cur_data = nil
	--选中主角
	if(self.m_role_index == 0)then
		self.m_cur_data = self.m_data.role_info
		self.m_cur_data.big_pic_path = role_config[self.m_cur_data.roleId].bigicon
		local arena_cofig = arena_stage[self.m_cur_data.arena_level] or {bottom = 'arena_rank_1.png',num = 'arena_rank_v.png'}
		self.m_arena_rank_icon:changeTexture(arena_cofig.bottom, UI_TEX_TYPE_PLIST)
		self.m_arena_rank_num:changeTexture(arena_cofig.num, UI_TEX_TYPE_PLIST)
		self.m_role_name_txt:setPosition(ccp(-24,0))
	else
		self.m_cur_data = self.m_data.partner_info[self.m_role_index]
		local sailor_config = sailor_info[self.m_cur_data.id]
		self.m_cur_data.name = sailor_config.name
		self.m_cur_data.profession = sailor_config.job[1]
		self.m_cur_data.big_pic_path = sailor_config.res
		self.m_staff_letter:changeTexture(STAR_SPRITE_RES[self.m_cur_data.quality].big, UI_TEX_TYPE_PLIST)
		self.m_role_name_txt:setPosition(ccp(-60,0))
	end
	
	for i=1,#self.m_head do
		self.m_head[i].select_bg:setVisible(self.m_role_index == i)
	end

	self.m_level_num:setText("Lv"..self.m_cur_data.level)

	--宝物
	for i=1,3 do
		local tmp = self:getBaowaData(i)
		self.m_baowu[i].baowu_icon:setVisible(tmp ~= nil)
		local item_bg_res ="item_treasure_1.png"
		local baozang_config
		local refine_attr
		if(tmp)then
			item_bg_res = string.format("item_treasure_%s.png",tmp.color)
			baozang_config = baozang_info[tmp.baowuId]
			self.m_baowu[i].baowu_icon:changeTexture(convertResources(baozang_config.res) , UI_TEX_TYPE_PLIST)
			refine_attr = tmp.refine_attrs
		end
		local baowu_star = self.m_baowu[i].baowu_star
		local star_level = 0
		if refine_attr then
			star_level = ClsDataTools:calBaowuStarLevel(refine_attr, baozang_config)
		end

		for star_index = 1, star_total do
			local star_icon = baowu_star[star_index]
			if star_level > (star_index - 1) * 2 then
				star_icon:setVisible(true)
				local star_res = "common_star3.png"
				if (star_level - (star_index * 2)) >= 0 then
					star_res = "common_star1.png"
				end
				star_icon:changeTexture(star_res, UI_TEX_TYPE_PLIST)
			else
				star_icon:setVisible(false)
			end
		end
		self.m_baowu[i].baowu_bg:changeTexture(item_bg_res, UI_TEX_TYPE_PLIST)
	end

	--星星
	self.m_star_panel:setVisible(self.m_cur_data.star ~= nil)
	if(self.m_cur_data.star)then
		for i=1,#self.m_star do
			self.m_star[i].star_gold:setVisible(i <= self.m_cur_data.star)
		end
	end

	self.uid_num:setText(self.m_cur_data.uid)
	self.m_role_name_txt:setText(self.m_cur_data.name)
	self.m_job_icon:changeTexture(JOB_RES[self.m_cur_data.profession], UI_TEX_TYPE_PLIST)
	self.m_role_pic:changeTexture(self.m_cur_data.big_pic_path, UI_TEX_TYPE_LOCAL)
	self.m_role_pic:setVisible(true)
	self.m_guild_name:setVisible(self.m_role_index == 0)
	self.m_title:setVisible(self.m_role_index == 0)
	self.m_staff_letter:setVisible(self.m_role_index ~= 0)
	self.m_arena_rank:setVisible(self.m_role_index == 0)
	self.m_skill_panel:setVisible(self.m_role_index ~= 0)
	self.m_role_head:setVisible(self.m_role_index ~= 0)
	self.m_role_title:setVisible(self.m_role_index == 0)

	--技能
	if(self.m_cur_data.skill_info)then
		table.sort(self.m_cur_data.skill_info,function ( a,b )
			return a.pos < b.pos
		end)
		for i=1,#self.m_skill do
			local tmp = self.m_cur_data.skill_info[i]
			self.m_skill[i].skill:setVisible(tmp ~= nil)
			if(tmp)then
				local skill_config = skill_info[tmp.skillId]
				self.m_skill[i].skill_icon:changeTexture(string.sub(skill_config.res, 2, string.len(skill_config.res)), UI_TEX_TYPE_PLIST)
				self.m_skill[i].skill_text_bg:setVisible(skill_config.initiative == 1)
				self.m_skill[i].skill:changeTexture(SAILOR_SKILL_BG[skill_config.quality], UI_TEX_TYPE_PLIST)
			end
		end
	end

	self.m_prestige_num:setText(self.m_cur_data.power)

	--基础属性
	self.m_defense_num:setText("")
	self.m_remote_num:setText("")
	self.m_durable_num:setText("")
	self.m_melee_num:setText("")
	for i=1,4 do
		local tmp = self.m_cur_data.base_attrs[i]
		if(tmp and self["m_"..tmp.name.."_num"])then
			self["m_"..tmp.name.."_num"]:setText(tmp.value)
		end
	end

	--船
	self.m_ship_panel:removeAllChildren()
	if not tolua.isnull(self.ship_model) then 
		self.ship_model:removeFromParentAndCleanup(true)
	end
	local boat_id = self.m_cur_data.boat_info.boatId
	if(not boat_id)then return end
	local boat = boat_info[boat_id]
	if(not boat)then return end

	local res_id = boat.armature
	local res_armature = string.format("armature/ship/%s/%s.ExportJson", res_id, res_id)
	armature_manager:addArmatureFileInfo(res_armature)
	self.ship_model = CCArmature:create(res_id)
	self.ship_model:setPosition(ccp(220,160))
	self.ship_model:setScale(.9)
	self.ship_model:getAnimation():playByIndex(0)
	self.m_ship_panel:addCCNode(self.ship_model)
end

ClsCaptainInfoMain.getBaowaData = function(self, index)
	if(not self.m_cur_data or not self.m_cur_data.sailor_baowu_info)then return nil end
	for i,v in ipairs(self.m_cur_data.sailor_baowu_info) do
		if(v.boxId == index)then return v end
	end
	return nil
end

ClsCaptainInfoMain.getSkillData = function(self, index)
	if(not self.m_data or not self.m_data.partner_info or self.m_role_index == 0)then return nil end

	local select_skill = self.m_data.partner_info[self.m_role_index].skill_info[index]
	if(not select_skill)then return nil end

	local pos = self:convertToWorldSpace(ccp(280,100))
	local temp = {}
	temp.pos = pos
	temp.skill = select_skill.skillId
	temp.skill_level = select_skill.level
	temp.sailor_id = self.m_data.partner_info[self.m_role_index].id
	return temp
end

ClsCaptainInfoMain.getRoleAttData = function(self)
	if(not self.m_cur_data)then return nil end
	
	local power = self.m_cur_data.power or 0
	local base_attrs = self.m_cur_data.base_attrs or {}
	local elite_attrs = self.m_cur_data.elite_attrs or {}

	local attData = {}
	for i=1,#base_attrs do
		table.insert(attData,base_attrs[i])
	end
	for i=1,#elite_attrs do
		table.insert(attData,elite_attrs[i])
	end

	return attData,power
end

ClsCaptainInfoMain.clearTips = function(self)
	self.m_att_tip:close()
end

ClsCaptainInfoMain.onExit = function(self)
	UnLoadPlist(self.plist)
	ReleaseTexture()
end

return ClsCaptainInfoMain
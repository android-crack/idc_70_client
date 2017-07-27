

local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local ui_word = require("game_config/ui_word")
local Alert = require("ui/tools/alert")


local guild_skill_study_speed = require("game_config/guild/guild_skill_study_speed")
local guild_skill_study_remote = require("game_config/guild/guild_skill_study_remote")
local guild_skill_study_defense = require("game_config/guild/guild_skill_study_defense")
local guild_skill_study_durable = require("game_config/guild/guild_skill_study_durable")
local guild_skill_study_melee = require("game_config/guild/guild_skill_study_melee")
local guild_skill_study_load = require("game_config/guild/guild_skill_study_load")

local guild_skill_info = require("game_config/guild/guild_skill_info")
local guild_skill_lv_control = require("game_config/guild/guild_skill_lv_control")

local goods_info = require("game_config/port/goods_info")

local ClsGuildSkillResearchTab = class("ClsGuildSkillResearchTab",ClsBaseView)

local SKILL_NUM = 6
local GOODS_NUM = 4

---技能的层数8
local SKILL_MAX_LEVEL = 40
local RESEARCH_LEVEL_MAX = 8
---每层技能学习5级
local STUDY_SKILL_MAX_LEVEL = 5

local skill_key_goods = {
	["remote"] = guild_skill_study_remote,
	["melee"] = guild_skill_study_melee,
	["durable"] = guild_skill_study_durable,
	["defense"] = guild_skill_study_defense,
	["load"] = guild_skill_study_load,
	["speed"] = guild_skill_study_speed,	
}

local research_name = {
	"level_num",
	"limit_num",
	"next_name",
	"next_limit_num",
	"progress_skill",
	"next_need_lv_num",
	"tips_txt",
	"bar",

	"skill_name",
	"skill_intro",
	"skill_lv_now",
	"skill_lv_next",
	"skill_effect_now",
	"skill_effect_next",
}

function ClsGuildSkillResearchTab:getViewConfig()
	local effect_type = UI_EFFECT.DOWN
	local ClsGuildSkillResearchMain = getUIManager():get("ClsGuildSkillResearchMain")

	if not tolua.isnull(ClsGuildSkillResearchMain) then
		local effect_status = ClsGuildSkillResearchMain:getDownEffectStatus()
		if effect_status then
			effect_type = 0
		end
	end
	
    return {
        is_swallow = false,
        effect = effect_type,
    }
end

function ClsGuildSkillResearchTab:onEnter(tab)
	self.res_plist ={
		-- ["ui/guild_badge.plist"] = 1,
		-- ["ui/guild_ui.plist"] = 1,
		-- ["ui/skill_icon.plist"] = 1,
		-- ["ui/item_box.plist"] = 1,
		-- ["ui/port_cargo.plist"] = 1,
	}
	LoadPlist(self.res_plist)

	self.default = tab or 1 
	self:initUI()
	self:askData()
end

function ClsGuildSkillResearchTab:initUI(  )
	self.research_panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_institute_study.json")
	self:addWidget(self.research_panel)
	self.research_panel:setVisible(false)
end

function ClsGuildSkillResearchTab:askData()
	local guild_research_data = getGameData():getGuildResearchData()
	guild_research_data:askResearchData()
end

function ClsGuildSkillResearchTab:isAllSkillComplate()
	for k,v in pairs(self.research_data) do
		if v["level"] ~= v["limit"] then
			return false
		end
	end
	return true
end

function ClsGuildSkillResearchTab:getSkillInfoByKay(key,data)
	for k,v in pairs(data) do
		if v.key == key then
			return v 
		end
	end
end

function ClsGuildSkillResearchTab:initResearchView()  
	self.research_panel:setVisible(true) 
	local guild_research_data = getGameData():getGuildResearchData()
	self.research_data = guild_research_data:getResearchData()

	for k,v in pairs(research_name) do
		self[v] = getConvertChildByName(self.research_panel, v)
	end

	local guild_research_data = getGameData():getGuildResearchData()

	local skill_complate_num, research_level = guild_research_data:getSkillComplateNumAndLimit()
	if not skill_complate_num then
		skill_complate_num, research_level = 0,0
	end
	---研究所等级
	self.level_num:setText("Lv."..research_level)
	self.research_level = research_level
	---研究技能等级上限
	local limit_skill_level = guild_skill_lv_control[research_level].skill_lv_limit ---skill_lv_limit
	self.limit_num:setText("Lv."..limit_skill_level)

	local next_level = research_level + 1
	---下级研究所
	if next_level > RESEARCH_LEVEL_MAX then
		next_level = RESEARCH_LEVEL_MAX
	end
	self.next_name:setText("Lv."..next_level)

	---下级技能等级限制
	local next_limit_skill_lv = guild_skill_lv_control[next_level].skill_lv_limit ---skill_lv_limit
	self.next_limit_num:setText("Lv."..next_limit_skill_lv)

	---下级所需商会等级

	local guild_level = getGameData():getGuildInfoData():getGuildGrade()
	local next_limit_guild_level = guild_skill_lv_control[next_level].guild_lv
	self.next_need_lv_num:setText("Lv."..next_limit_guild_level)
	if guild_level >= next_limit_guild_level then
		setUILabelColor(self.next_need_lv_num, ccc3(dexToColor3B(COLOR_BROWN)))
	else
		setUILabelColor(self.next_need_lv_num, ccc3(dexToColor3B(COLOR_RED)))
	end
	---完成度
	self.progress_skill:setText(string.format("%s/%s", skill_complate_num, SKILL_NUM))
	---进度条
	self.bar:setPercent(skill_complate_num/SKILL_NUM*100)
	self.tips_txt:setText(string.format(ui_word.GUILD_RESEARCH_SKILL_COMPLATE_NUM, limit_skill_level))

	--技能
	self.skill_btn = {}
	for i=1,SKILL_NUM do
		local skill_btn = getConvertChildByName(self.research_panel, "skill_"..i)
		self.skill_btn[i] = skill_btn

		local skill_icon = getConvertChildByName(self.research_panel, "skill_icon_"..i)
		self.skill_btn[i].skill_icon = skill_icon

		local skill_selected = getConvertChildByName(self.research_panel, "skill_selected_"..i)
		self.skill_btn[i].skill_selected = skill_selected

		local skill_level_num = getConvertChildByName(self.research_panel, "skill_level_num_"..i)
		self.skill_btn[i].skill_level_num = skill_level_num
	end

	--商品
	self.goods_list = {}
	for i=1,GOODS_NUM do
		local goods_bg = getConvertChildByName(self.research_panel, "goods_bg_"..i)
		self.goods_list[i] = goods_bg	

		local goods_bg_selected = getConvertChildByName(self.research_panel, "goods_bg_selected_"..i)
		self.goods_list[i].goods_bg_selected = goods_bg_selected

		local goods_name = getConvertChildByName(self.research_panel, "goods_name_"..i)
		self.goods_list[i].goods_name = goods_name

		local goods_icon = getConvertChildByName(self.research_panel, "goods_icon_"..i)
		self.goods_list[i].goods_icon = goods_icon

		local goods_num = getConvertChildByName(self.research_panel, "goods_num_"..i)
		self.goods_list[i].goods_num = goods_num	
	end

	self:updateResearchView(self.default_select_skill)
end

function ClsGuildSkillResearchTab:updateResearchView(tab)

	for k,v in pairs(guild_skill_info) do
		local btn = self.skill_btn[k]
		btn.skill_icon:changeTexture(v.guild_skill_icon, UI_TEX_TYPE_PLIST)
		btn.skill_selected:setVisible(false)

		local skill_key = v.name
		local skill_info = self:getSkillInfoByKay(skill_key,self.research_data)
		local skill_level = skill_info.level
		if skill_level == skill_info.limit then
			btn.skill_level_num:setText(ui_word.REWARD_FINISH)
		else
			btn.skill_level_num:setText(ui_word.GUILD_RESEARCH_DOING_GOODS)
		end
		
		btn:addEventListener(function ()
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:updateResearchSkillInfo(k)
		end, TOUCH_EVENT_ENDED)
	end

	self.default_select_skill = tab or 1
	self:updateResearchSkillInfo(self.default_select_skill, self.default_goods)
end


function ClsGuildSkillResearchTab:updateResearchSkillInfo(skill_tag,tab)
	self.default_select_skill = skill_tag 

	for k,v in pairs(self.skill_btn) do
		v.skill_selected:setVisible(k == skill_tag)
	end

	local skill_info = guild_skill_info[skill_tag]

	self.skill_name:setText(skill_info.guild_skill_name)
	self.skill_intro:setText(skill_info.guild_skill_desc)

	local skill_key = skill_info.name
	local skill_data = self:getSkillInfoByKay(skill_key,self.research_data)
	local skill_data_goods = skill_data.list

	self.skill_data_goods = skill_data_goods

	local skill_level = skill_data.level
	self.skill_level = skill_level 
	local skill_level_next = skill_level + 1

	if skill_level_next > SKILL_MAX_LEVEL then
		skill_level_next = SKILL_MAX_LEVEL
	end 

	self.skill_lv_now:setText("Lv."..skill_level)
	self.skill_lv_next:setText("Lv."..skill_level_next)

	local skill_desc = "0"
	if skill_level ~= 0 then
		skill_desc = skill_key_goods[skill_key][skill_level].skill_add
	end
	
	local next_skill_desc = skill_key_goods[skill_key][skill_level_next].skill_add

	self.skill_effect_now:setText(skill_info.guild_skill_txt.."+"..skill_desc)
	self.skill_effect_next:setText(skill_info.guild_skill_txt.."+"..next_skill_desc)

	---研究技能的商品消耗的金币
	local cost_cash = skill_key_goods[skill_key][skill_level_next].skill_gold
	---研究技能的商品获得的贡献
	local get_exp = skill_key_goods[skill_key][skill_level_next].skill_get_contribution
	---上缴技能的商品消耗的钻石
	local skill_diamonds = skill_key_goods[skill_key][skill_level_next].skill_diamonds

    ---研究技能的商品
	local skill_goods = skill_data_goods

	for k,v in ipairs(skill_goods) do
		
		local goods_btn = self.goods_list[k]
		goods_btn.tag = k
		goods_btn.goods_bg_selected:setVisible(false)

		local goods_id = v.mate_id
		local goods_data = goods_info[goods_id]
		goods_btn.goods_name:setText(goods_data.name)
		goods_btn.goods_icon:changeTexture(convertResources(goods_data.res), UI_TEX_TYPE_PLIST)

		local have_goods_num = v.mate_curr
		local need_goods_num = v.mate_need
		goods_btn.goods_num:setText(string.format("%s/%s",have_goods_num,need_goods_num))
		local new_goods_data = {
			name = goods_data.name,
			res = goods_data.res,
			have_amount = have_goods_num,
			need_amount = need_goods_num,
			id = goods_id,
			skill_key = skill_key,
			cost_cash = self:getConsumeCash(cost_cash),
			get_exp = get_exp,
			cost_diamound = skill_diamonds[goods_id] or 0,
		}

		goods_btn.data = new_goods_data
		goods_btn:setTouchEnabled(true)
		goods_btn:addEventListener(function (  )
			audioExt.playEffect(music_info.COMMON_BUTTON.res)
			self:selectGoods(goods_btn.tag)
		end, TOUCH_EVENT_ENDED)
	end

	self.default_goods = tab or 1
	self:updateSelectGoods(self.default_goods)
end

function ClsGuildSkillResearchTab:getConsumeCash(key)
	local playerData = getGameData():getPlayerData()
	local level = playerData:getLevel()
	local num = key*Math.round(1.5^(math.floor(level/10))*660/100) *100 * 2
	return num 
end

function ClsGuildSkillResearchTab:updateSelectGoods(tab)
	self.default_goods = tab
	local goods_data = {}
	for k,v in pairs(self.goods_list) do
		v.goods_bg_selected:setVisible(k == tab)
		if k == tab  then
			goods_data = v.data
		end
	end
	local ClsGuildResearchGoodsTips = getUIManager():get("ClsGuildResearchGoodsTips")
	if not tolua.isnull(ClsGuildResearchGoodsTips) then
		ClsGuildResearchGoodsTips:updateUI(goods_data)
		--getGameData():getGuildResearchData():setResearchSelectSkillInfo(data)

	end

end

function ClsGuildSkillResearchTab:selectGoods(tab)
	self.default_goods = tab 

	for k,v in pairs(self.goods_list) do
		v.goods_bg_selected:setVisible(k == tab)
		if k == tab  then
			self.goods_data = v.data
		end
	end

	local data = self.goods_data

	local skill_level = self.skill_level
	if skill_level > 0 and skill_level == self.research_level*5 then
		Alert:warning({msg = ui_word.GUILD_RESEARCH_SKILL_GOODS_FULL, size = 26})
		return 
	end

	if data.have_amount >= data.need_amount then
		Alert:warning({msg = ui_word.GUILD_RESEARCH_GOODS_FULL, size = 26})
	else
		local type_pos = 1
		getUIManager():create("gameobj/guild/clsGuildResearchGoodsTips",{}, data,type_pos)		
	end

	--self.tips_goods_info = data

	--getGameData():getGuildResearchData():setResearchSelectSkillInfo(data)
end

function ClsGuildSkillResearchTab:getGoodsInfo(  )
	return self.tips_goods_info
end

function ClsGuildSkillResearchTab:onExit( )
	UnLoadPlist(self.res_plist)
end

return ClsGuildSkillResearchTab
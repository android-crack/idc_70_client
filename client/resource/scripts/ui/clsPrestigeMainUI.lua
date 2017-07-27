
---fmy0570
---声望提升界面
local ClsUiTools = require("gameobj/uiTools")
local music_info = require("game_config/music_info")
local ClsPrestigeViewTab = require("ui/clsPrestigeViewTab")
local base_info = require("game_config/base_info")
local Dialog = require("ui/dialogLayer")
local ClsBaseView = require("ui/view/clsBaseView")


local ClsPrestigeMainUI = class("ClsPrestigeMainUI", ClsBaseView)


function ClsPrestigeMainUI:getViewConfig()
    return {
        is_back_bg = true        
       -- effect = UI_EFFECT.FADE,   
    }
end
local widget_name = {
	"prestige_now_num",
	"evaluation_level",
	"btn_close",
}

local btn_name = {
 	{res="btn_player",lab = "btn_player_text"}, 	
 	{res="btn_sailor",lab = "btn_sailor_text"},
	{res="btn_boat",lab = "btn_boat_text"},
 	{res="btn_resource",lab = "btn_resource_text"},	
}

function ClsPrestigeMainUI:onEnter(tab_id)
	self.plist = {

    }
    LoadPlist(self.plist)

	self.default_tab = tab_id or 1

	local nobility_data = getGameData():getNobilityData()
	nobility_data:sendPrestigeInfo()
end

function ClsPrestigeMainUI:mkUI()

	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/main_prestige.json")
	self:addWidget(self.panel)

	for k, v in pairs(widget_name) do
		self[v] = getConvertChildByName(self.panel, v)
	end
	audioExt.playEffect(music_info.PAPER_STRETCH.res)

	self:initUI()
	self:defaultSelect()
end

function ClsPrestigeMainUI:initUI()
	local player_level = getGameData():getPlayerData():getLevel()
	local target_prestige = base_info[player_level].target_prestige
	--总声望		
	local total_prestige = getGameData():getPlayerData():getBattlePower()
	self.prestige_now_num:setText(total_prestige)

	local percent = total_prestige/target_prestige *100
	local prestige_grade = self:getPrestigeGrade(percent)
	
	self.evaluation_level:changeTexture(STAR_SPRITE_RES[prestige_grade].big, UI_TEX_TYPE_PLIST)
	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_CLOSE.res)
		audioExt.playEffect(music_info.PAPER_STRETCH.res)

		self:close()
	end, TOUCH_EVENT_ENDED)


	self.btns = {}
    for k, v in pairs(btn_name) do
        self[v.res] = getConvertChildByName(self.panel, v.res)
        self.btns[#self.btns + 1] = self[v.res]
        self[v.lab] = getConvertChildByName(self.panel, v.lab)
        self[v.res]:addEventListener(function ()
            setUILabelColor(self[v.lab], ccc3(dexToColor3B(COLOR_BTN_SELECTED)))
        end,TOUCH_EVENT_BEGAN)

        self[v.res]:addEventListener(function ()
            setUILabelColor(self[v.lab], ccc3(dexToColor3B(COLOR_BTN_UNSELECTED)))
        end,TOUCH_EVENT_CANCELED)        
        
        self[v.res]:addEventListener(function ()
            audioExt.playEffect(music_info.COMMON_BUTTON.res)
            self:selectBtnTab(k)
        end,TOUCH_EVENT_ENDED)
    end
end

function ClsPrestigeMainUI:getPrestigeGrade(percent)
	local prestige_grade = 1
	if percent < 40 then
		prestige_grade = 2
	elseif percent >= 40 and percent < 60 then
		prestige_grade = 3
	elseif percent >= 60 and percent < 80 then
		prestige_grade = 4
	elseif percent >= 80 and percent < 90 then
		prestige_grade = 5
	elseif percent >= 90 then
		prestige_grade = 6
	end
	return prestige_grade
end

function ClsPrestigeMainUI:defaultSelect()
	self:selectBtnTab(self.default_tab)
end

function ClsPrestigeMainUI:selectBtnTab(tab)
    for k,v in pairs(btn_name) do
        self[v.res]:setFocused(tab == k)
        self[v.res]:setTouchEnabled(tab ~= k)

        local color = COLOR_BTN_UNSELECTED
        if tab == k then
            color = COLOR_BTN_SELECTED
        end
        setUILabelColor(self[v.lab], ccc3(dexToColor3B(color)))   
    end


	if not tolua.isnull(self.guild_mine_ui) then
		self.guild_mine_ui:removeFromParentAndCleanup(true)
		self.guild_mine_ui = nil 
	end

	self.guild_mine_ui = ClsPrestigeViewTab.new(tab)
	self.panel:addChild(self.guild_mine_ui)
end

function ClsPrestigeMainUI:onFinish()

end

function ClsPrestigeMainUI:onExit()
	UnLoadPlist(self.plist)
end

return ClsPrestigeMainUI

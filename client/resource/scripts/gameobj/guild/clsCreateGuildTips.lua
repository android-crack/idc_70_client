local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")
local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word") 
local ClsGuideMgr = require("gameobj/guide/clsGuideMgr")
local guild_badge = require("game_config/guild/guild_badge")

local ClsCreateGuildTips = class("ClsCreateGuildTips",ClsBaseView)

local tips_name = {
	"btn_close",
	"btn_set",
	"group_name",
	"text_1",
	"group_icon",

	"title_join",
	"title",
	"btn_join",
	"group_level",
	"text_3",
}

function ClsCreateGuildTips:getViewConfig()
    return {
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

---is_call :
function ClsCreateGuildTips:onEnter(data,call_back,is_call)
	self.res_plist ={
		["ui/guild_badge.plist"] = 1,
	}
	LoadPlist(self.res_plist)

	self.data = data
	self.call_back = call_back
	self.is_call = is_call 

	self:initUI()
end

function ClsCreateGuildTips:initUI(  )
	self.ui_layer = UIWidget:create()
	self.tips_panel = GUIReader:shareReader():widgetFromJsonFile("json/tips_set_group.json")
	convertUIType(self.tips_panel)
	self.ui_layer:addChild(self.tips_panel)
	self:addWidget(self.ui_layer)

    local bg_size = self.tips_panel:getContentSize()
    self:setPosition(ccp(display.cx - bg_size.width/2 , display.cy - bg_size.height/2))

	for k,v in pairs(tips_name) do
		self[v] = getConvertChildByName(self.tips_panel, v)
	end

	self.btn_close:setPressedActionEnabled(true)
	self.btn_close:addEventListener(function ()
	    audioExt.playEffect(music_info.COMMON_CLOSE.res)
	    self:close()
	end,TOUCH_EVENT_ENDED)

	self.btn_join:setVisible(self.is_call)
	self.title_join:setVisible(self.is_call)
	self.group_level:setVisible(self.is_call)
	self.text_3:setVisible(self.is_call)

	self.title:setVisible(not self.is_call)
	self.text_1:setVisible(not self.is_call)
	self.btn_set:setVisible(not self.is_call)

	self:updateUI()		
end


function ClsCreateGuildTips:updateUI( )
	local res = guild_badge[self.data.res].res
	self.group_icon:changeTexture(convertResources(res), UI_TEX_TYPE_PLIST)

	if self.data.level then
		self.group_level:setText("Lv."..self.data.level)
	end
	
	self.group_name:setText(self.data.name)
	self:btnCallBack()
end

function ClsCreateGuildTips:btnCallBack(  )

	self.btn_set:setPressedActionEnabled(true)
	self.btn_set:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		---钻石不足
		local cost = 500 
		local playerData = getGameData():getPlayerData()
		if playerData:getGold() >= cost then
			if self.call_back then
				self.call_back()
			end
			
			self:close()
		else
			Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, self)
		end

	end,TOUCH_EVENT_ENDED)

	self.btn_join:setPressedActionEnabled(true)
	self.btn_join:addEventListener(function ()
		audioExt.playEffect(music_info.COMMON_BUTTON.res)
		print("-------------self.data.guild_id------",self.data.id)


		local guild_info_data = getGameData():getGuildInfoData()
		local is_has_guild = guild_info_data:hasGuild()

		if is_has_guild then
			local show_txt = ui_word.STR_GUILD_EXIT_TIPS_LAB
			Alert:showAttention(show_txt, function()
				local guildInfoData = getGameData():getGuildInfoData()
				guildInfoData:askExitGuildTimesTips()
        	end)

		else
			local guild_search_data = getGameData():getGuildSearchData()
			guild_search_data:askApplyGuild(self.data.id)
			self:close()
			local clsOtherGuildMainUI = getUIManager():get("clsOtherGuildMainUI")
			if not tolua.isnull(clsOtherGuildMainUI) then
				clsOtherGuildMainUI:close()
			end		
		end



	end,TOUCH_EVENT_ENDED)


end

function ClsCreateGuildTips:onExit( )
	UnLoadPlist(self.res_plist)
end


return ClsCreateGuildTips
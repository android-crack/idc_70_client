local ui_word = require("game_config/ui_word")
local commonFunc = require("gameobj/commonFuns")
local Alert = require("ui/tools/alert")
local ClsMusicInfo = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")

local GuildCreateDlg = class("GuildCreateDlg", ClsBaseView)

local COST_DIAMOUND_NUM = 500

function GuildCreateDlg:getViewConfig(...)
    return {
    	is_back_bg = true,
    	effect = UI_EFFECT.SCALE,
    }
end

function GuildCreateDlg:onEnter()
	self:configUI()
	self:configEvent()
end

function GuildCreateDlg:onTouchChange(is_touch)
	self.editBox:setTouchEnabled(is_touch)
end

function GuildCreateDlg:configUI()

	self.ui_layer = UIWidget:create()
	self.panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_creat.json")
	convertUIType(self.panel)
	self.ui_layer:addChild(self.panel)
	self:addWidget(self.ui_layer)

	self.ui_layer:setPosition(ccp(279, 145))

	--用于抖动需给予ContentSize，会从中间缩放
	local bg_size = self.panel:getContentSize()
	self:setContentSize(CCSizeMake(bg_size.width, bg_size.height))

	local frame = display.newSpriteFrame("common_9_block3.png")
	local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
	self.editBox = CCEditBox:create(CCSize(244, 42), sprite)
	self.editBox:setPosition(195, 136)
	self.editBox:setPlaceholderFont(font_tab[FONT_COMMON], 16)
	self.editBox:setFont(font_tab[FONT_COMMON], 16)
	self.editBox:setPlaceHolder(ui_word.STR_GUILD_CREATE_INPUT)
	self.editBox:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.editBox:setFontColor(ccc3(dexToColor3B(COLOR_LIGHT_BLUE)))
	self.editBox:setInputFlag(kEditBoxInputFlagSensitive)
	self.editBox:setMaxLength(20)
	self.editBox:setTouchPriority(0)
	self.ui_layer:addCCNode(self.editBox)

	local lastName = ""
	self.editBox:registerScriptEditBoxHandler(function(eventType)
		if eventType == "ended" then
			local name = self.editBox:getText()
			if commonFunc:utfstrlen(name) <= 7 then
				lastName = name
				self.editBox:setText(lastName)
				if not checkNameTextValid(name) or not checkChatTextValid(name) then

					lastName = ""
					self.editBox:setText(lastName)
				end
			else
				Alert:warning({msg = ui_word.STR_GUILD_CREATE_NAME_LIMIT, size = 26})
				self.editBox:setText(lastName)
			end
			
		end
	end)

	self.cash = COST_DIAMOUND_NUM
	self.creat_cost = getConvertChildByName(self.panel, "creat_cost")
	self.creat_cost:setText(COST_DIAMOUND_NUM)
	self.btn_creat = getConvertChildByName(self.panel, "btn_creat")
	--关闭按钮
	self.btn_close = getConvertChildByName(self.panel, "btn_close")
	self.input_box = getConvertChildByName(self.panel, "input_box")
	self.input_box:setVisible(false)

	local playerData = getGameData():getPlayerData()
	if playerData:getGold() < tonumber(self.cash) then
		setUILabelColor(self.creat_cost, ccc3(dexToColor3B(COLOR_RED_STROKE)))
    end
end

-- function GuildCreateDlg:touch_priority_cb( priority )
-- 	self.editBox:setTouchPriority(priority)
-- end

function GuildCreateDlg:configEvent()
	self.btn_creat:setPressedActionEnabled(true) 
	self.btn_creat:addEventListener(function()			
			local playerData = getGameData():getPlayerData()
			if playerData:getGold() < tonumber(self.cash) then
				--require("ui/dialogLayer").hideDialog()
				local element = getUIManager():get("GuildSearchPanel")
				Alert:showJumpWindow(DIAMOND_NOT_ENOUGH, element, {need_cash = self.cash})
				return
		    end

			local name = self.editBox:getText()

			if commonFunc:utfstrlen(name) < 1 then
				Alert:warning({msg = ui_word.STR_GUILD_CREATE_NAME_NULL, size = 26})
				return 
			end
			
		    name = commonFunc:returnUTF_8CharValid(name)

		    getUIManager():create("gameobj/guild/clsGuildBadgePanel.lua",nil, function(badge_key)

				local data = {
					name = name,
					res = badge_key,
				}
				getUIManager():create("gameobj/guild/clsCreateGuildTips.lua",nil,data,function (  )
					local guildSearchData = getGameData():getGuildSearchData()
					guildSearchData:askCreateGuild(name, badge_key)		    	 	
				end)
		    end)

		    self:close()
    	end,TOUCH_EVENT_ENDED)

	self.btn_close:setPressedActionEnabled(true) 
	self.btn_close:addEventListener(function()
			self:close()
    		audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
    end,TOUCH_EVENT_ENDED)
end

return GuildCreateDlg



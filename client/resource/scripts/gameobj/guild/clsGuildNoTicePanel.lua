local ClsBaseView = require("ui/view/clsBaseView")
local ClsMusicInfo =require("scripts/game_config/music_info")
local ClsAlert = require("ui/tools/alert")
local ClsUiWord = require("game_config/ui_word")
local commonFunc = require("gameobj/commonFuns")
local clsGuildNoTicePanel = class("ClsGuildNoTicePanel",ClsBaseView)

local notice_mail_type = "mail"
local mail_times_all = 5

function clsGuildNoTicePanel:getViewConfig(...)
    return {
        is_back_bg = true,
        effect = UI_EFFECT.SCALE,
    }
end

---iscall:
function clsGuildNoTicePanel:onEnter(notice_type,is_call)
	local guild_info_data = getGameData():getGuildInfoData()
    local layer = CCLayerColor:create(ccc4(0,0,0,0))
    self.ui_layer = UILayer:create()
    local panel = GUIReader:shareReader():widgetFromJsonFile("json/guild_hall_notice.json")
    convertUIType(panel)
    self.ui_layer:addWidget(panel)
    layer:addChild(self.ui_layer)
    self:addChild(layer)


    
    local notice_bg = getConvertChildByName(panel, "notice_bg")
    local call_bg = getConvertChildByName(panel, "call_bg")

    if is_call then
        call_bg:setVisible(true)
        notice_bg:setVisible(false)
        
    else
        call_bg:setVisible(false)
        notice_bg:setVisible(true)   
         
    end
    self.is_call = is_call

    local frame = display.newSpriteFrame("guild_9_20.png")
    local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
    self.edit_box = CCEditBox:create(CCSize(356, 95), sprite)
    self.edit_box:setPosition(480, 285)
    self.edit_box:setPlaceholderFont(font_tab[FONT_MICROHEI_BOLD], 14)
    self.edit_box:setFont(font_tab[FONT_MICROHEI_BOLD], 14)
    self.edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    self.edit_box:setFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    self.edit_box:setInputFlag(kEditBoxInputFlagSensitive)
    self.edit_box:setMaxLength(200)
    self.edit_box:setTouchPriority(-129)
    self.ui_layer:addChild(self.edit_box)


    self:initCallView(call_bg)    
    self:initMailView(notice_bg,notice_type) 



    local btn_close = getConvertChildByName(panel, "btn_close")
    btn_close:setPressedActionEnabled(true) 
    btn_close:addEventListener(function()
            audioExt.playEffect(ClsMusicInfo.COMMON_CLOSE.res)
            self:close()
        end,TOUCH_EVENT_ENDED)
end

function clsGuildNoTicePanel:initCallView( panel )
    local notice_num_bg = getConvertChildByName(panel, "notice_num_bg")
    notice_num_bg:setVisible(false)

    local call_notice_num = getConvertChildByName(panel, "call_notice_num")
    call_notice_num:setVisible(true)
    self.call_tips = getConvertChildByName(panel, "call_tips")
    local btn_notice = getConvertChildByName(panel, "btn_notice")

    -- local frame = display.newSpriteFrame("guild_9_20.png")
    -- local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
    -- local edit_box = CCEditBox:create(CCSize(356, 95), sprite)
    -- edit_box:setPosition(480, 285)
    -- edit_box:setPlaceholderFont(font_tab[FONT_MICROHEI_BOLD], 14)
    -- edit_box:setFont(font_tab[FONT_MICROHEI_BOLD], 14)
    -- edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    -- edit_box:setFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    -- edit_box:setInputFlag(kEditBoxInputFlagSensitive)
    -- edit_box:setMaxLength(200)
    -- edit_box:setTouchPriority(-129)
    -- self.ui_layer:addChild(edit_box)



    if self.is_call then
        local guild_name = getGameData():getGuildInfoData():getGuildName()
        local last_notice = guild_name..ClsUiWord.GUILD_CALL_JOIN
        self.edit_box:setText("")
        call_notice_num:setText(last_notice)

        self.edit_box:registerScriptEditBoxHandler(function(eventType)
            if eventType == "began" then
                call_notice_num:setText("")
                self.edit_box:setText(last_notice)
            elseif eventType == "ended" then
                local name = self.edit_box:getText()

                if not checkChatTextValid(name) then
                    self.edit_box:setText("")
                    call_notice_num:setText(last_notice)
                    return 
                end

                if commonFunc:utfstrlen(name) <= 30 then
                    self.edit_box:setText("")
                    call_notice_num:setText(name)
                    last_notice = name
                else
                    self.edit_box:setText(last_notice)
                    ClsAlert:warning({msg = ClsUiWord.STR_GUILD_CALL_MEMBER_LIMIT, size = 26})
                end

            end
        end)
    end

    btn_notice:setPressedActionEnabled(true) 
    btn_notice:addEventListener(function()
            btn_notice:setTouchEnabled(false)
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:close()
            local text = call_notice_num:getStringValue()
            local commonBase  = require("gameobj/commonFuns")
            text = commonBase:returnUTF_8CharValid(text)
            local has = check_string_has_invisible_char(text)
            if has or commonBase:checkAllCharacterIsNul(text) then
                ClsAlert:warning({msg = ClsUiWord.PLEASE_INPUT_MSG, color = ccc3(dexToColor3B(COLOR_RED))})
                return
            end
            local guild_info_data = getGameData():getGuildInfoData()
            guild_info_data:askGroupCall(text)
            -- local resume_times = getGameData():getGuildInfoData():getCallTimes()
            -- if resume_times < mail_times_all then
            --     local guildInfoData = getGameData():getGuildInfoData()
            --     guildInfoData:askGuildInfo()
            -- end


        end,TOUCH_EVENT_ENDED)  

    self:updataCallTimes()
end


function clsGuildNoTicePanel:updataCallTimes(  )
    local resume_times = getGameData():getGuildInfoData():getCallTimes()
    local str =  string.format(ClsUiWord.STR_GUILD_CALL_TIMES_TAB, mail_times_all - resume_times)
    self.call_tips:setText(str) 
end


function clsGuildNoTicePanel:initMailView( panel,notice_type)
    local guild_info_data = getGameData():getGuildInfoData()
    local notice_num_bg = getConvertChildByName(panel, "notice_num_bg")
    notice_num_bg:setVisible(false)
    local notice_num_info = getConvertChildByName(panel, "notice_num_info")
    notice_num_info:setVisible(true)
    local btn_notice = getConvertChildByName(panel, "btn_notice")
    local title_text = getConvertChildByName(panel, "title_text")
    local title_mail_text = getConvertChildByName(panel, "title_mail_text")
    local btn_mail_txt = getConvertChildByName(panel, "btn_mail_txt")
    local btn_notice_txt = getConvertChildByName(panel, "btn_notice_txt")


    self.mail_tips = getConvertChildByName(panel, "mail_tips")


    -- local frame = display.newSpriteFrame("guild_9_20.png")
    -- local sprite = CCScale9Sprite:createWithSpriteFrame(frame)
    -- local edit_box = CCEditBox:create(CCSize(356, 95), sprite)
    -- edit_box:setPosition(480, 285)
    -- edit_box:setPlaceholderFont(font_tab[FONT_MICROHEI_BOLD], 14)
    -- edit_box:setFont(font_tab[FONT_MICROHEI_BOLD], 14)
    -- edit_box:setPlaceholderFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    -- edit_box:setFontColor(ccc3(dexToColor3B(COLOR_BROWN)))
    -- edit_box:setInputFlag(kEditBoxInputFlagSensitive)
    -- edit_box:setMaxLength(200)
    -- edit_box:setTouchPriority(-129)
    -- self.ui_layer:addChild(edit_box)




    if not self.is_call then
        local last_notice = ""
        if notice_type == notice_mail_type then
            title_text:setVisible(false)
            title_mail_text:setVisible(true)
            btn_mail_txt:setVisible(true)
            btn_notice_txt:setVisible(false)
            self.mail_tips:setVisible(true)
        else
            last_notice = guild_info_data:getGuildNotice()
            title_text:setVisible(true)
            title_mail_text:setVisible(false)
            btn_mail_txt:setVisible(false)
            btn_notice_txt:setVisible(true)
            self.mail_tips:setVisible(false)
        end
        self.edit_box:setText("")
        notice_num_info:setText(last_notice)


        self.edit_box:registerScriptEditBoxHandler(function(eventType)
            if eventType == "began" then
                notice_num_info:setText("")
                self.edit_box:setText(last_notice)
            elseif eventType == "ended" then
                local name = self.edit_box:getText()

                if not checkChatTextValid(name) then
                    self.edit_box:setText("")
                    notice_num_info:setText(last_notice)
                    return 
                end
                self.edit_box:setText("")
                notice_num_info:setText(name)
                last_notice = name
            end
        end)
    end

    btn_notice:setPressedActionEnabled(true) 
    btn_notice:addEventListener(function()
            btn_notice:setTouchEnabled(false)
            audioExt.playEffect(ClsMusicInfo.COMMON_BUTTON.res)
            self:close()
            local text = notice_num_info:getStringValue()
            local commonBase  = require("gameobj/commonFuns")
            text = commonBase:returnUTF_8CharValid(text)
            local has = check_string_has_invisible_char(text)
            if has or commonBase:checkAllCharacterIsNul(text) then
                ClsAlert:warning({msg = ClsUiWord.PLEASE_INPUT_MSG, color = ccc3(dexToColor3B(COLOR_RED))})
                return
            end
            if notice_type == notice_mail_type then
                guild_info_data:askGroupMail(text)
                local resume_times = getGameData():getGuildInfoData():getMailTimes()
                if resume_times < mail_times_all then
                    local guildInfoData = getGameData():getGuildInfoData()
                    guildInfoData:askGuildInfo()
                end
            else
                guild_info_data:updateNotice(text)
            end

        end,TOUCH_EVENT_ENDED)
    self:updataMailTimes()    
end

function clsGuildNoTicePanel:updataMailTimes()
    local resume_times = getGameData():getGuildInfoData():getMailTimes()
    local str =  string.format(ClsUiWord.STR_GUILD_MAIL_TIMES_TAB, mail_times_all - resume_times)
    self.mail_tips:setText(str)
end

return clsGuildNoTicePanel
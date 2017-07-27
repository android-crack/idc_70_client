local ui_word = require("scripts/game_config/ui_word")
local ClsRichLabel = require("ui/tools/richlabel/richlabel")
local touch_event_for_chat_message = require("gameobj/chat/touchEventForChatMessage")
local offset = 5
local show_info = {
	[KIND_WORLD] = {lable = ui_word.CHAT_WORLD_KIND, img = "#chat_box_world.png", color = COLOR_WHITE},
	[KIND_GUILD] = {lable = ui_word.CHAT_GUILD_KIND, img = "#chat_box_guild.png", color = COLOR_CREAM},
	[KIND_PRIVATE] = {lable = ui_word.CHAT_FRIEND_KIND, img = "#chat_box_friends.png", color = COLOR_PURPLE},
	[KIND_SYSTEM] = {lable = ui_word.CHAT_SYSTEM_KIND, img = "#chat_box_system.png", color = COLOR_ORANGE},
	[KIND_NOW] = {lable = ui_word.CHAT_CURRENT_KIND, img = "#chat_box_now.png", color = COLOR_GREEN},
	[KIND_TEAM] = {lable = ui_word.CHAT_TEAM_KIND, img = "#chat_box_team.png", color = COLOR_BLUE},
}

local ClsScrollViewItem = require("ui/view/clsScrollViewItem")
local ClsChatListViewCell = class("ClsChatListViewCell", ClsScrollViewItem)
function ClsChatListViewCell:updateUI(cell_date, panel)
	local data = cell_date
	local show_info = show_info[data.type]

	--创建最左边的频道图片以及图片上的文本
	local kind_pic = display.newSprite(show_info.img)
	if tolua.isnull(kind_pic) then
		kind_pic = display.newSprite()
	end

	local pic_size = kind_pic:getContentSize()
	local label = createBMFont({text = show_info.lable, size = 14, fontFile = FONT_COMMON, color = ccc3(dexToColor3B(COLOR_WHITE))})
	label:setPosition(ccp(pic_size.width / 2, pic_size.height / 2))
	kind_pic:addChild(label)

    local chat_data = getGameData():getChatData()

    --得到要显示的内容(文本或者图片)
	local show_str = nil
	if chat_data:isAudio(data.message) then
		local user_chat_set = CCUserDefault:sharedUserDefault()
		local not_show_audio = user_chat_set:getBoolForKey("NO_SHOW_AUDIO")
		if not_show_audio then
			show_str = chat_data:getAudioBtn(data.message)
		else
			show_str = data.message
		end
	else
		show_str = data.message
	end

	--将显示的消息的发送者姓名以及颜色组装起来
	local player_data = getGameData():getPlayerData()
	local sender_name = nil
	if data.sender == player_data:getUid() then
		sender_name = player_data:getName()
	else
		if data.sender ~= GAME_SYSTEM_ID then
			sender_name = data.senderName
		end
	end

	if sender_name then
		sender_name = string.format("$(c:0x%x)【%s】", COLOR_WHITE, sender_name)
		show_str = string.format("%s$(c:0x%x)%s", sender_name, show_info.color, show_str)
	else
		show_str = string.format("$(c:0x%x)%s", show_info.color, show_str)
	end

	show_str = string.gsub(show_str, "MOREN_COLOR", string.format("0x%x", show_info.color))

	local offset_top = 2
	local offset_left = 5
    local cell_width = self:getWidth()
    local rich_label_width = cell_width - pic_size.width - 3 * offset_left

	local height = 34
	local font_size = 14
	local vertical_space = 0
	local rich_label = createRichLabelParams(show_str, rich_label_width - 10, height, font_size, {vertical_space = vertical_space, max_line = 2})

	if chat_data:isAudio(data.message) then --语音富文本单独处理
		rich_label:setButtonElementCallback(function(vid)
            require("ui/tools/QSpeechMgr")
            local speech = getSpeechInstance()
            speech:playAudio(vid)
        end)

        local speek_btn = rich_label:getButtonElement()
        if speek_btn and not tolua.isnull(speek_btn) then
            local f = "@@%d+@@"
            local x, y  = string.find(data.message, f)
            local time = 1
            if x and y then
                time = string.sub(data.message, x + 2, y - 2)
            end
            
            local labelName = createBMFont({text = time .."s", size = 16, color = ccc3(dexToColor3B(COLOR_BROWN))})
            labelName:setAnchorPoint(ccp(0, 0.5))
            labelName:setPosition(25, 14)
            speek_btn:addChild(labelName)
            local voice_pic = display.newSprite("#chat_play_wave.png")
            voice_pic:setPosition(12, 14)
            speek_btn:addChild(voice_pic)
        end
	end

	local rich_size = rich_label:getSize()

	local cell_height = math.max(pic_size.height, rich_size.height)
    self:setHeight(cell_height + 2 * offset_top)

    local pic_width = pic_size.width
    local pic_height = pic_size.height

    local pic_pos = ccp((offset_left + pic_width / 2), (cell_height - offset_top - pic_height / 2))
    kind_pic:setPosition(pic_pos)

    rich_label:ignoreAnchorPointForPosition(false)
    rich_label:setAnchorPoint(ccp(0, 1))
    local rich_pos = ccp((2 * offset_left + pic_width), (cell_height - offset))
    rich_label:setPosition(rich_pos)
    rich_label:regTouchFromView(getUIManager():get("ClsChatComponent"), 1)

    rich_label:judgeIsCanTouch(function(x, y)
    	if not self.m_scroll_view:isInViewByPos(x, y) then 
    		return false
    	end
    	return true
    end)

	self:addCCNode(kind_pic)
	self:addCCNode(rich_label)
    self:updateListPos()
end

function ClsChatListViewCell:updateListPos()
    if tolua.isnull(self.m_scroll_view) then return end
    self.m_scroll_view:updateScoreViewSize()
    self.m_scroll_view:openUpdateTimer()
end

function ClsChatListViewCell:onTap(x, y)
	local component_ui = getUIManager():get("ClsChatComponent")
    local panel_ui = component_ui:getPanelByName("ClsChatSystemPanel")
    if self.m_cell_date.type == KIND_PRIVATE then
    	local main_ui = component_ui:getPanelByName("ClsChatSystemMainUI")
    	local chat_data = getGameData():getChatData()
    	local info = chat_data:getPlayerInfo(self.m_cell_date)
    	main_ui:setPlayerBtnInfo(PLAYER_STATUS_PRIVATE, {uid = info.uid, name = info.name})
    	panel_ui:toMainUI({["kind"] = INDEX_PLAYER})
    else
    	panel_ui:toMainUI({["kind"] = get_index_by_type[self.m_cell_date.type]})
    end
end

return ClsChatListViewCell
--聊天界面语音管理类

local element_mgr = require("base/element_mgr")

local ClsChatAudioMessageBase = class("ClsChatAudioMessageBase")
function ClsChatAudioMessageBase:ctor()
    self.audio_queue = {}
    self.next_index = 1
    self.is_playing = false
    self.is_pause = false
    self.current_sender = nil
    element_mgr:add_element("ClsChatAudioMessageBase", self)
end

--聊天类型对应的audio_key
local audio_keys = {
    [KIND_WORLD] = "NO_PLAY_WORLD",
    [KIND_GUILD] = "NO_PLAY_GUILD",
    [KIND_PRIVATE] = "NO_PLAY_PRIVATE",
    [KIND_TEAM] = "NO_PLAY_TEAM",
    [KIND_NOW] = "NO_PLAY_NOW",
}

--语音筛选器
function ClsChatAudioMessageBase:isCanPlay(msg)
    --判断该信息是否是音频信息
    local is_audio = (string.sub(msg.message, 3, 8) == "button") and true or false
    if not is_audio then return end
    local player_data = getGameData():getPlayerData()
    local player_uid = player_data:getUid()
    if player_uid == msg.sender then return end
    
    --然后看该音频信息是否该播放
    local audio_key = audio_keys[msg.type]
    local user_set = CCUserDefault:sharedUserDefault()
    local no_play = user_set:getBoolForKey(audio_key)
    user_set:flush()
    if no_play then return end

    --在战斗中屏蔽非组队语音
    local battle_data = getGameData():getBattleDataMt()
    if battle_data:GetBattleSwitch() then
        if audio_key ~= "NO_PLAY_TEAM" then return end
    end
    
    --插入播放队列
    return true
end

function ClsChatAudioMessageBase:insertPlayQueue(msg)
    local is_can_play = self:isCanPlay(msg)
    if not is_can_play then return end
    self.audio_queue[#self.audio_queue + 1] = msg
    if self.is_pause then return end
    if not self.is_playing then
        self.is_playing = true
        self:playNextAudio()
    end
end

function ClsChatAudioMessageBase:pausePlayAudio()
    self.is_pause = true
    self.is_playing = false
    --暂停当前播放的语音
end

function ClsChatAudioMessageBase:resumePlayAudio()
    self.is_pause = false
    self.is_playing = true
    self:playNextAudio()
end

function ClsChatAudioMessageBase:playEndCallBack()
    self.next_index = self.next_index + 1
    if not self.audio_queue[self.next_index] then self.is_playing = false return false end
    return true
end

--播放音频
function ClsChatAudioMessageBase:playNextAudio()
    local chat = self.audio_queue[self.next_index]
    if chat then
        local str = chat.message
        --解析播放，播放完毕后将它移除出队列，再递归调用该函数播放下一个音频self:playNextAudio()
        local start_index = string.find(str, ',')
        local end_index = string.find(str, ')')
        if start_index and end_index then
            local str = string.sub(str, start_index + 1, end_index - 1)
            local str = string.trim(str)
            require("ui/tools/QSpeechMgr")
            local speech = getSpeechInstance()
            speech:playAudio(str, function()
                local next_chat = self.audio_queue[self.next_index + 1]
                if next_chat then
                    if next_chat.sender ~= self.current_sender then
                        --下一次要播放的语音跟上一个播放的语音发送者不是同一人
                        --先将上一个派发出去的语音停止
                        EventTrigger(AUDIO_STOP_EVENT, self.current_chat)
                    end
                end

                local result = self:playEndCallBack()
                if not result then
                    EventTrigger(AUDIO_STOP_EVENT, self.current_chat)
                    self.current_sender = nil
                else
                    self:playNextAudio()
                end
            end)
            --派发语音播放事件
            if self.current_sender ~= chat.sender then
                self.current_sender = sender
                self.current_chat = chat
                EventTrigger(AUDIO_PLAY_EVENT, chat)
            end
        end
    else
        self.is_playing = false
        self.next_index = self.next_index - 1
    end
end

return ClsChatAudioMessageBase
--
-- Author: Ltian
-- Date: 2015-12-14 19:05:24
--
--语音识别 播放管理器
local ui_word = require("game_config/ui_word")
local ClsAlert = require("ui/tools/alert")


local android_recogn_class_name = "com/dhh/xfyun/XfyunRecognizer"
local android_recogn_start_func_name = "start"
local android_recogn_start_func_param_sign = "(IIIII)V"
local android_recogn_stop_func_name = "stop"
local android_recogn_stop_func_param_sign = "()V"
local android_recogn_cancel_func_name = "cancel"
local android_recogn_cancel_func_param_sign = "()V"

local android_play_class_name = "com/dhh/xfyun/QSpeechPlayer"
local android_play_start_func_name = "play"
local android_play_start_func_param_sign = "(Ljava/lang/String;I)V"

local android_play_native_func_name = "playLocal"
local android_play_native_func_param_sign = "(Ljava/lang/String)V"

local android_play_stop_func_name = "stop"
local android_play_stop_func_param_sign = "()V"

local RECOGN_STATUS_NONE = 0
local RECOGN_STATUS_WAIT = 1
local RECOGN_STATUS_START = 2
local RECOGN_STATUS_STOP = 3
local RECOGN_STATUS_CANCEL = 4
local RECOGN_STATUS_NEED_CANCEL = 5

local QSpeechMgr = class("QSpeechMgr")
local single_instance = nil
--local URL = "client.beta.q3.175game.com" --语音服务器地址

function QSpeechMgr:ctor()
    self.voice_list = {} --存放临时语音数据
    self.recogn_audio_text = ""
    self.recogn_audio_data_base64 = nil
    self.recogn_touch_layer = nil
    self.recogn_config = nil
    self.recogn_status = RECOGN_STATUS_NONE

    self.recogn_ui = nil
    self.recogn_ui_touch_begin_pos = ccp(0, 0)
    self.recogn_ui_cancel_dis = 100
	
	self.current_music_volume = audioExt.getMusicVolume()
	self.current_effect_volume = audioExt.getEffectVolume()
	self.chat_music_volume = 0.1   -- 播语音的时候，背影音乐的音量
	self.chat_effect_volume = 0.1

    self.recogn_ui_plist_res = {
        ["ui/chat_ui.plist"] = 1,
    }
end 

function QSpeechMgr.getUrl()
    local module_game_sdk = require("module/sdk/gameSdk")
    local auth = module_game_sdk.getAuthChn()
    local speed_svr = GTab.SPEED_URL[1]
    for i,v in ipairs(GTab.SPEED_URL) do
        if v.name == auth then
            speed_svr = v
        end
    end
    if speed_svr.port == nil or speed_svr.port == "" then
        speed_svr.port = "80"
    end
    local url = speed_svr.url..":"..speed_svr.port
    print("语音服url：",url)
    return url
end

function QSpeechMgr:showSpeechView(callBack)
    self.call_back = callBack
    print("==QSpeechMgr:showSpeechView=============")
    self:startRecogn(self.callback)
    self:showRecognUi()
end


--清除语音识别（外部调用
function QSpeechMgr:clearRecogn()
    --self:cancelRecogn()
    --self.recogn_config = nil
    if not tolua.isnull(self.recogn_touch_layer) then
        self.recogn_touch_layer:removeFromParentAndCleanup(true)
    end
end

--上行数据
function QSpeechMgr:upload(data , vid, cb)
    local callback = function(event)
        -- 暂时屏蔽 测试
        self:clearRecogn()
        local ok = (event.name == "completed")
        local request = event.request
        if not ok then
            return
        end

        local code = request:getResponseStatusCode()
        if code ~= 200 then
            -- code is HTTP response code
            print("code#########################", code)
            return
        end

        print("upload success")
        if type(self.call_back) == "function" then
            self.call_back(self.recogn_audio_text, vid)
        end
    end

    url = string.format("%s/fileservice/v1/store", self.getUrl())

    print("url#########################", url)
    print("url#########################", url)
    local request = network.createHTTPRequest(callback, url, "POST")
    request:addPOSTValue("content_type", "audio/vnd.qtz.q2.chat" )
    request:addPOSTValue("filename", vid)
    request:addPOSTValue("content", data )
    request:start()
end


--开始语音识别：声音--->文本 and 音频数据
function QSpeechMgr:startRecogn(call_back)
    audioExt.pauseMusic()
    audioExt.pauseAllEffects()
    local ok = false
    
        local args = {
            --开始
            function(result)
                if not tolua.isnull(self.recogn_ui) then
                    self.recogn_audio_text = nil
                    self.recogn_audio_data_base64 = nil
                    self.recogn_ui.status_lb:setString(ui_word.QSPEECH_STATUS_RECOGN_WAIT)
                end
            end, 
            --完成的语音
            function(audioDataBase64)
                self.recogn_audio_data_base64 = audioDataBase64
                --print("================完成的语音===audioDataBase64")
            end, 
            --完成的文字
            function(audioText)
                self.recogn_audio_text = audioText
                --print("======self.recogn_audio_text", self.recogn_audio_text)
            end, 

            --结束
            function(result)
                --print("================结束===audioDataBase64")
                if self.recogn_audio_data_base64 then
                    local uid = getGameData():getPlayerData():getUid()
                    local time = math.ceil(string.len(self.recogn_audio_data_base64)/ 2000)
                    local module_game_sdk = require("module/sdk/gameSdk")
                    local auth = module_game_sdk.getAuthChn()
                    vid = "@@"..time.."@@"..uid..os.time()..auth
                    self:upload(self.recogn_audio_data_base64, vid)
                end
            end,
            --错误
            function (error)
                ClsAlert:warning({msg = ui_word.QSPEECH_ERROR, size = 26})
                self:hideUI()
            end
        }
    if device.platform == "android" then
        -- 调用 Java 方法
        ok = luaj.callStaticMethod(android_recogn_class_name, android_recogn_start_func_name, args, android_recogn_start_func_param_sign)
    elseif device.platform == "ios" then
        print("=============开始语音识别")
        QMSCSDK:getInstance():startRecogn(unpack(args))
        ok = true
    end
    return ok
end

--结束语音识别
function QSpeechMgr:stopRecogn()
    self.recogn_status = RECOGN_STATUS_STOP
    
    local ok = false
    if device.platform == "android" then
        -- 调用 Java 方法
        local args = {}
        ok = luaj.callStaticMethod(android_recogn_class_name, android_recogn_stop_func_name, args, android_recogn_stop_func_param_sign)
    elseif device.platform == "ios" then
        QMSCSDK:getInstance():stopRecogn()
        ok = true
    end
    self:hideUI()
    return ok
end

--取消语音识别
function QSpeechMgr:cancelRecogn()
    self.recogn_status = RECOGN_STATUS_CANCEL
    
    local ok = false
    if device.platform == "android" then
        -- 调用 Java 方法
        local args = {}
        ok = luaj.callStaticMethod(android_recogn_class_name, android_recogn_cancel_func_name, args, android_recogn_cancel_func_param_sign)
    elseif device.platform == "ios" then
        QMSCSDK:getInstance():cancelRecogn()
        ok = true
    end
    self:hideUI()
    return ok
end

function QSpeechMgr:hideUI()
    self:clearRecogn()
    self:hideRecognUi()
	audioExt.resumeMusic()
	audioExt.resumeAllEffects()
    if self.call_back then
        self.call_back()
    end
end

function QSpeechMgr:download(vid, call_back)
    local callback = function(event)
        local ok = (event.name == "completed")
        local request = event.request

        if not ok then
            print("该语音未能正常播放，请稍后再试")
            return
        end

        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("该语音未能正常播放，请稍后再试")
            return
        end
        print("dowload_ok")
        local data = request:getResponseString()
        self.voice_list[vid] = data
        local info = {
            vid = vid,
            data = data
        }
        self:insertVoiceData(info)
        if not type(call_back) == "function" then
            call_back = function ()
                print("play________end")
            end
        end
        if device.platform == "android" then
            local args = {data, call_back}
            ok = luaj.callStaticMethod(android_play_class_name, android_play_start_func_name, args, android_play_start_func_param_sign)
        elseif device.platform == "ios" then
            QMSCSDK:getInstance():playVoice(data, call_back)
        end
    end
    url = string.format("%s/fileservice/v1/obtain?filename=%s", self.getUrl(), vid)
    local request = network.createHTTPRequest(callback, url, "GET")
    request:start()
end
function QSpeechMgr:insertVoiceData(data)
    table.insert(self.voice_list, 1 , data)
    if #self.voice_list > 10 then
        table.remove(self.voice_list, 9)
    end
end

function QSpeechMgr:getVoiceData(vid)
    local data = nil
    for k,v in pairs(self.voice_list) do
        if v.vid == vid then
            data = v.data
            break
        end
    end
    return data
end

--播放音频
function QSpeechMgr:playAudio(vid, call_back)
    if device.platform == "android" or device.platform == "ios" then
        self:getVoice(vid, call_back)
    end
end

--获取语音数据 1 保存在内存中的 2不在内存中的去语音服务器下载
function QSpeechMgr:getVoice(vid, call_back)
    local voice = self:getVoiceData(vid)

	local function callBack()
		if call_back then 
			call_back()
		end 
		-- 恢复音量
		audioExt.setMusicVolume(self.current_music_volume)
		audioExt.setEffectVolume(self.current_effect_volume)
	end 
	-- 降低背景音量
	audioExt.setMusicVolume(self.chat_music_volume)
	audioExt.setEffectVolume(self.chat_effect_volume)	
    if voice then
        if device.platform == "android" then
            local args = {voice, callBack}
            ok = luaj.callStaticMethod(android_play_class_name, android_play_start_func_name, args, android_play_start_func_param_sign)
        elseif device.platform == "ios" then
            QMSCSDK:getInstance():playVoice(voice, callBack)
        end
    else
        self:download(vid, callBack)
    end
end

function QSpeechMgr:stopPlay()
    if device.platform == "android" then
        local args = {}
        ok = luaj.callStaticMethod(android_play_class_name, android_play_stop_func_name, args, android_play_stop_func_param_sign)
    elseif device.platform == "ios" then
        QMSCSDK:getInstance():stopVoice()
    end
end

function QSpeechMgr:showRecognUi()
    if tolua.isnull(self.recogn_ui) then
        LoadPlist(self.recogn_ui_plist_res)
        self.recogn_ui = CCLayerColor:create(ccc4(0,0,0,125))

        local bg = CCLayerColor:create(ccc4(0,0,0,125))
        bg:setContentSize(CCSizeMake(150, 150))
        bg:setPosition((display.width - 150) / 2, (display.height - 150) / 2)
        self.recogn_ui:addChild(bg)

        local mic_icon = display.newSprite("#chat_recording.png")
        mic_icon:setScale(0.7)
        mic_icon:setPosition(display.cx - 3, display.cy + 15)
        self.recogn_ui.mic_icon = mic_icon
        self.recogn_ui:addChild(mic_icon)
        local status_lb = createBMFont({text = ui_word.QSPEECH_STATUS_RECOGN_WAIT, fontFile = FONT_TITLE, size = 16, x = display.cx, y = display.cy-50})
        self.recogn_ui.status_lb = status_lb
        self.recogn_ui:addChild(status_lb)

        local running_scene = GameUtil.getRunningScene()
        running_scene:addChild(self.recogn_ui, QSPEECH_LAYER_ZORDER)
    end
end

function QSpeechMgr:hideRecognUi()
    if not tolua.isnull(self.recogn_ui) then
        self.recogn_ui:removeFromParentAndCleanup(true)
    end
end

function getSpeechInstance()
    if not single_instance then
        single_instance = QSpeechMgr.new()
    end
    return single_instance
end 

function pureSpeechInstance()
    if single_instance then
        single_instance:clearRecogn()
    end
    single_instance = nil
end

return QSpeechMgr
------ 剧情语音相关

local voice_info=getLangVoiceInfo()
local music_info=require("game_config/music_info")

local plotVoiceAudio = {}

local voiceInfo = nil
local delayTimer = nil
--------------语音音效相关--------------
function plotVoiceAudio.playVoiceEffect(voiceKey,isLoop)
	if isLoop==nil then
		isLoop = false
	end
	if voiceKey~=nil then
		voiceInfo = voice_info[voiceKey]
		if voiceInfo == nil then
			voiceInfo = music_info[voiceKey]
		end
		if voiceInfo == nil then
           return 
		end
		--plotVoiceAudio.stopVoiceEffect()
		plotVoiceAudio.voice_handler = audioExt.playEffect(voiceInfo.res,isLoop)
      return plotVoiceAudio.voice_handler
	end
end

function plotVoiceAudio.stopVoiceEffect()
	if plotVoiceAudio.voice_handler~=nil and type(plotVoiceAudio.voice_handler)=="number" then
		audioExt.stopEffect(plotVoiceAudio.voice_handler)
	end
	plotVoiceAudio.voice_handler = nil
end

function plotVoiceAudio.playVoiceBgMusice(voiceKey,isLoop)
   if isLoop == nil then 
      isLoop = false
   end
   if voiceKey ~= nil then
      voiceInfo = voice_info[voiceKey]
      if voiceInfo == nil then
         voiceInfo = music_info[voiceKey]
      end
      if voiceInfo == nil then
         return
      end
      plotVoiceAudio.voice_handler = audioExt.playMusic(voiceInfo.res,isLoop)
   end
end

function plotVoiceAudio.stopVoiceBgMusic()
   if plotVoiceAudio.voice_handler ~= nil and type(plotVoiceAudio.voice_handler) == "number" then
      audioExt.stopMusic(plotVoiceAudio.voice_handler)
   end
   plotVoiceAudio.voice_handler = nil
end

return plotVoiceAudio
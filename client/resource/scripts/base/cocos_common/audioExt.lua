local music_info = require("game_config/music_info")
local voice_info = getLangVoiceInfo()
local music_effect_config = require("game_config/music_effect_info")
--audioExt.lua
audioExt = {} -- 全局变量

local formatName=nil   --平台格式音效
local effectEnabled = true --设置音效
local musicEnabled = true --设置音乐
local playedEffectTable = {}  --播放过的音效

local playOnceHash = {} -- 这个游戏只播放一次


-- 音效淘汰算法
local effect_tab = {}
local effect_count = 0
local priority = 0
local function effectLru(filename)
	if effect_tab[filename] == nil then 
		if effect_count < 1 then 
			effect_count = effect_count + 1
		else 
			-- 淘汰优先级最低
			local min_priority = priority + 1
			local min_k
			for k, v in pairs(effect_tab) do
				if v < min_priority then 
					min_priority = v
					min_k = k
				end 
			end 
			
			audioExt.unloadEffect(min_k)
			effect_tab[min_k] = nil
		end 
	end 
	
	priority = priority + 1
	effect_tab[filename] = priority
end 

function audioExt.isEffectEnabled()
	return effectEnabled
end

function audioExt.isMusicEnabled()
	return musicEnabled
end

function audioExt.setEffectEnabled(isEnabled)
	effectEnabled = isEnabled
end

function audioExt.setMusicEnabled(isEnabled)
	musicEnabled = isEnabled
end

function audioExt.preloadMusic(filename)
	if not musicEnabled then return end 
	audio.preloadMusic(filename)
end

function audioExt.playMusic(filename, isLoop)	
	if not musicEnabled then return end 
	if not formatName then audioExt.getFormatName() end
	local name = string.format(formatName,filename)
	
	if audioExt.lastMusic == name then 
		return 
	end 
	audioExt.stopMusic()
	audioExt.lastMusic = filename
	return audio.playMusic(name, isLoop)
end

function audioExt.stopMusic(isReleaseData)
	if not musicEnabled then return end 
	audioExt.lastMusic = nil 
	audio.stopMusic(isReleaseData)
end

function audioExt.pauseMusic()
	if not musicEnabled then return end 
	audio.pauseMusic()
end

function audioExt.getLastMusic()
	return audioExt.lastMusic
end

function audioExt.getFormatName()
	if device.platform=="ios" then
		formatName="sound/m4a/%s.m4a"
	elseif device.platform=="android" then
		formatName="sound/ogg/%s.ogg"
	else
		formatName="sound/mp3/%s.mp3"
	end
end

--音量设置的暂时不支持
function audioExt.setMusicVolume(value)
	if not musicEnabled then return end 
	audio.setMusicVolume(value)
end

function audioExt.getMusicVolume()
	if not musicEnabled or not audioExt.isMusicPlaying() then return 0 end
	return audio.getMusicVolume()
end

function audioExt.setEffectVolume(value)
	if not effectEnabled then return false end
	audio.setSoundsVolume(value)
end

function audioExt.getEffectVolume()
	if not effectEnabled then return 0 end
	return audio.getSoundsVolume()
end

function audioExt.resumeMusic()
	if not musicEnabled then return end 
	audio.resumeMusic()
end

function audioExt.rewindMusic()
	if not musicEnabled then return end 
	audio.rewindMusic()
end

function audioExt.willPlayMusic()
	if not musicEnabled then return false end 
	return audio.willPlayMusic()
end

function audioExt.isMusicPlaying()
	if not musicEnabled then return false end 
	return audio.isMusicPlaying()
end

local MAX_PLAY_EFFECT_COUNT = 4

local OnLineOnePlayAudio = {
	VOICE_EXPLORE_1002 = true,
	VOICE_EXPLORE_1003 = true,
	VOICE_EXPLORE_1022 = true,
	VOICE_EXPLORE_1023 = true,
	VOICE_EXPLORE_1021 = true,
	VOICE_EXPLORE_1001 = true
}

function audioExt.playEffectOneTime(voiceKey, filename, isLoop, isForce)
	local hander = nil
	if OnLineOnePlayAudio[voiceKey] then
		hander = audioExt.playEffectOnce(filename, isLoop, isForce)
	else
		hander = audioExt.playEffect(filename, isLoop, isForce)
	end
	return hander
end

function audioExt.playEffect(filename, isLoop, isForce)
	if not filename or filename == "" then return end
	if not effectEnabled then return false end 
	if not formatName then audioExt.getFormatName() end

	filename=string.format(formatName,filename)

	--not battle effect
	if not music_effect_config[filename] then
		return audio.playEffect(filename, isLoop)
	end

	local cur_time = os.clock()
	--remove effect record
	local need_remove_t = {}
	for name, time in pairs(playedEffectTable) do
		if music_effect_config[name] then
			if time < (cur_time - music_effect_config[name].time) then
				need_remove_t[name] = true
			end
		end
	end

	for name, v in pairs(need_remove_t) do
		playedEffectTable[name] = nil
	end


	--fileter effect
	local cur_count = 0
	for k, v in pairs(playedEffectTable) do
		cur_count = cur_count + 1
	end

	if (cur_count >= MAX_PLAY_EFFECT_COUNT) and ( not isForce) then
		return false
	end

	local filename = music_info[filename].res
	if music_effect_config[filename] then
		playedEffectTable[filename] = os.clock()
	end
	return audio.playEffect(filename, isLoop)
end

function audioExt.isPlayEffect(hander)
	if hander then
		return SimpleAudioEngine:sharedEngine():getEffectIsPlaying(hander)
	end
	return false
end

local sequeueTimeDic = {}

function audioExt.playEffectBySequeue(configKey, isLoop)
	if not effectEnabled then return false end

	local config = music_info[configKey]
	if not config then
		config = voice_info[configKey]
	end

	if not config then
		return
	end

	if not formatName then audioExt.getFormatName() end

	local fileName = string.format(formatName, config.res)

	if isLoop then
		return audio.playEffect(fileName, isLoop)
	end
	
	local lastTime = config.time or 0
	local curTime = os.clock()

	if sequeueTimeDic[configKey] and (curTime - sequeueTimeDic[configKey]) <= lastTime then
		return
	end

	sequeueTimeDic[configKey] = curTime

	return audio.playEffect(fileName, isLoop)
end

function audioExt.pauseEffect()
	if not effectEnabled then return end 
	audio.pauseEffect()
end

function audioExt.pauseAllEffects()
	if not effectEnabled then return end 
	audio.pauseAllEffects()
end

function audioExt.resumeEffect()
	if not effectEnabled then return end 
	audio.resumeEffect()
end

function audioExt.resumeAllEffects()
	if not effectEnabled then return end 
	audio.resumeAllEffects()
end

function audioExt.stopEffect(handle)
	if not effectEnabled then return end 
	audio.stopEffect(handle)
end

function audioExt.stopAllEffects()
	if not effectEnabled then return end 
	audio.stopAllEffects()
end

function audioExt.preloadEffect(filename)
	if not effectEnabled then return end 
	audio.preloadEffect(filename)
end

function audioExt.unloadEffect(filename)
	if not effectEnabled then return end 
	audio.unloadEffect(filename)
end

function audioExt.getEffectsVolume()
    if not effectEnabled then return 0 end
    return audio.getEffectsVolume()
end

function audioExt.setEffectsVolume(volume)
    if not effectEnabled then return end
    return audio.setEffectsVolume(volume)
end

function audioExt.playEffectOnce(filename, isLoop, isForce)
	local hander
	if playOnceHash[filename] then return end 
	playOnceHash[filename] = true
	hander = audioExt.playEffect(filename, isLoop, isForce)
	return hander
end 

return audioExt
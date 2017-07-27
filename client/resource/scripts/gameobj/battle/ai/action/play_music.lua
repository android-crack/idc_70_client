local music_info = require("scripts/game_config/music_info")

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionPlayMusic = class("ClsAIActionPlayMusic", ClsAIActionBase)

function ClsAIActionPlayMusic:getId()
	return "play_music"
end

function ClsAIActionPlayMusic:initAction(music)
	self.music = music
end

function ClsAIActionPlayMusic:__dealAction(target_id, delta_time)
	if not self.music then return end

	if not music_info[self.music] then return end

	audioExt.playEffect(music_info[self.music].res)
end

return ClsAIActionPlayMusic

local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionDialog = class("ClsAIActionAddSkill", ClsAIActionBase) 

local plotVoiceAudio = require("gameobj/plotVoiceAudio")

require( "module/dataManager" )

function ClsAIActionDialog:getId()
	return "dialog"
end

function ClsAIActionDialog:initAction( name, txt_dialog, audio_dialog )
	self.name = name 							-- 名字
	self.txt_dialog = txt_dialog 				-- 文本对话内容
	self.audio_dialog = audio_dialog 			-- 音频对话内容
end

function ClsAIActionDialog:__dealAction( target_id, delta_time )
	if not self.name then return end
	if not self.txt_dialog then return end

	local ai_obj = self:getOwnerAI()
	if not ai_obj then return end

	local owner_obj = ai_obj:getOwner()
	if owner_obj then

		if owner_obj.isDeaded then return end
		
		if owner_obj.body.dialogBox and not tolua.isnull( onwer_obj.body.dialogBox ) then
			owner_obj.body.dialogBox:removeFromParentAndCleanup(true)
			owner_obj.body.dialogBox = nil
		end

		local x = 90
		local y = -80

		local dialog = require( "gameobj/battle/battleDialog" )

		local msg = {}
		msg.txt = self.txt_dialog
		if owner_obj:is_player_team() then
			local playerData = getGameData():getPlayerData()
			msg.name = playerData:getName()
		else
			msg.name = args.name
		end
		msg.isTouchRemove = true  --不能通过点击取消播放
		msg.seaman_id = owner_obj:getSailorID()
		msg.x, msg.y = x, y
		msg.parent = owner_obj.body.dialog
		owner_obj.body.dialogBox = dialog:showBox( msg )

		-- 音频对话内容
		if self.audio_dialog then
			plotVoiceAudio.playVoiceEffect( self.audio_dialog )
		end
	end
end

return ClsAIActionDialog

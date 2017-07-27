local ClsQuestionPaperDataHandler = class("ClsQuestionPaperDataHandler")
local question_data = require("game_config/question/question_data")

function ClsQuestionPaperDataHandler:ctor()
	self.current_id = nil
end
	
function ClsQuestionPaperDataHandler:setQuestionInfo(current_id)
	self.current_id = current_id
end

function ClsQuestionPaperDataHandler:getUrl()
	if self.current_id and self.current_id ~= 0 then
		local module_game_sdk = require("module/sdk/gameSdk")
		local platform = module_game_sdk.getPlatform()
		local question_info = question_data[self.current_id]

		if platform == PLATFORM_WEIXIN then
			url = question_info.wx_url
		elseif platform == PLATFORM_QQ then
			url = question_info.qq_url	
		end
		
		if url then
			url = string.gsub(url, "[ \t\n\r]+", "")
		end
		
		return url
	end
end

function ClsQuestionPaperDataHandler:getQuesitonPaperInfo()
	return {current_id = self.current_id}
end

return ClsQuestionPaperDataHandler


module("regx", package.seeall)

name_regx_list = nil
chat_regx_list = nil

function createRegxList(  path_str )
	local regx_list = {}
	local fileContent = require( path_str )
	
	for i, pattern in ipairs(fileContent) do
		local Regx = require("module/regx/regx_class")
		local regx = Regx.new()
		regx:compile( pattern )
		regx_list[i] = regx
	end
	
	
	return regx_list
end

function is_valid_str( regx_list, match_str )
	for _, regx in ipairs( regx_list ) do
		local isMatch = regx:match(match_str)
		if isMatch then return false end
	end
	return true
end

function replace_valid_str(regx_list, match_str, replace_str)
	for _, regx in ipairs( regx_list ) do
		match_str = regx:replace(match_str, replace_str)
	end
	return match_str
end 


--名字是否合法
function is_valid_name( name_str )
	if not name_regx_list then
		name_regx_list = createRegxList("game_config/shielded_info")
	end
	
	return is_valid_str( name_regx_list, name_str )
end

function is_valid_user_name(name_str)
	local user_name_regx_list = "^[·A-Za-z0-9一-龥]+$"
	local Regx = require("module/regx/regx_class")
	local regx = Regx.new()
	regx:compile(user_name_regx_list)
	
	if regx:match(name_str) then return true end

	return false
end

--聊天内容是否合法
function is_valid_chat_str( chat_str )
	if not chat_regx_list then
		chat_regx_list = createRegxList("game_config/shielded_info")
	end
	
	return is_valid_str( chat_regx_list, chat_str)
end

--用**替换非法字符串
function replace_valid_chat_str( chat_str )
	if not chat_regx_list then
		chat_regx_list = createRegxList("game_config/shielded_info")
	end
	return replace_valid_str(chat_regx_list, chat_str, "**")
end 




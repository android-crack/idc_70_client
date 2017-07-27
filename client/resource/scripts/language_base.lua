local string_format = string.format

local strings_table = nil
local language = nil

local lang_save_key = "language_key"
local pre_game_update_status = false

local function get_stringtable()
    local lang_str = string.gsub(DEFAULT_LANGUAGE, "-", "_")
	if GTab.IS_UPDATEING then 
		return require("scripts/root/language/language_"..lang_str)
	else
		return require("scripts/game_config/language/language_"..lang_str)
	end
end

local function LocalizedString(text)
    if DEFAULT_LANGUAGE == "zh-CN" then
        return text
    end
	if (pre_game_update_status ~= GTab.IS_UPDATEING) or (not strings_table) then -- load strings_table once
        pre_game_update_status = GTab.IS_UPDATEING
		strings_table = get_stringtable()
		if not strings_table then
			--logger.info("strings_table is nil")
			return text
		end
	end
    return strings_table[text] or text
end

function T(text, ...)
    if not text then return end -- 
    local text = LocalizedString(text, ...)
    local n = select("#", ...)
    return (n==0) and text or string_format(text, ...) 
end
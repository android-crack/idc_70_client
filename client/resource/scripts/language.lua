-------------------------------------------------------------------------------
-- LocalizedString for language
--
-- @author
--
-- @copyright
--
-------------------------------------------------------------------------------
--config
require("language_base")
local lang_sound_cfg = {
    ["zh-CN"] = "zh-CN",
    ["zh-HK"] = "zh-CN",
    ["zh-TW"] = "zh-CN",
    ["en-ESA"] = "zh-CN",
    ["ko-KR"] = "zh-CN",
    ["ja-JP"] = "zh-CN",
}

local lang_save_key = "language_key"
local LanguageModule = {}

function LanguageModule:setLanguage(name, is_flush)
    assert(name)
    DEFAULT_LANGUAGE = name
	local user_default = CCUserDefault:sharedUserDefault()
    user_default:setStringForKey(lang_save_key, DEFAULT_LANGUAGE)
    if is_flush then
        user_default:flush()
    end
end

function LanguageModule:getLanguage()
    return DEFAULT_LANGUAGE
end

function LanguageModule:getLanguageInCfg()
    local defaultLanguage = nil -- 默认的配置（没有保存到UserDefault.xml情况下）

    if not DEFAULT_LANGUAGE then -- DEFAULT_LANGUAGE 没有配置
        defaultLanguage = "zh-CN" -- 给默认中文
    else
        defaultLanguage = DEFAULT_LANGUAGE    
    end
    return defaultLanguage
end

LanguageModule:setLanguage(LanguageModule:getLanguageInCfg())

--获取配音表的接口
local voice_info = nil
function getLangVoiceInfo()
    if voice_info then
        return voice_info
    end
    local lang_str = LanguageModule:getLanguage()
    local sound_index = lang_sound_cfg[lang_str] or lang_str
    sound_index = string.gsub(sound_index, "-", "_")
    voice_info =  require("game_config/language/voice_info_"..sound_index)
    return voice_info
end

return LanguageModule


local default_lang = GTab.LANGUAGE
--[[
local lang_voice_dir_cfg = {
    ["zh-CN"] = "voice",
    ["zh-HK"] = "voice",
    ["zh-TW"] = "voice",
    ["en-ESA"] = "voice",
}
-]]

local lang_resource_cfg = {
    ["zh-CN"] = "resource",
    ["zh-HK"] = "resource_tw",
    ["zh-TW"] = "resource_tw",
    ["en-ESA"] = "resource_en",
    ["ja-JP"] = "resource",
}

local utils = {}
function utils.getLangName()
	local user_default = CCUserDefault:sharedUserDefault()
	local lang_save_key = "language_key"
	local lang_str = user_default:getStringForKey(lang_save_key) or GTab.LANGUAGE
	if string.len(lang_str) <= 0 then
		return GTab.LANGUAGE
	end
	return lang_str
end

function utils.getLangResourceDirName()
	local lang_str = utils.getLangName()
	if lang_resource_cfg[lang_str] then
		return lang_resource_cfg[lang_str]
	end

	print("cannot get language resource name:", lang_str)
	return lang_resource_cfg["zh-CN"]
end

function utils.getFormatName(name_str)
	local formatName = ""
	if device.platform=="ios" then
		formatName="res/sound/m4a/bg/%s.m4a"
	elseif device.platform=="android" then
		formatName="res/sound/ogg/bg/%s.ogg"
	else
		formatName="res/sound/mp3/bg/%s.mp3"
	end
	formatName = string.format(formatName, name_str)
	return formatName
end

function utils.playBgMusic()
	local userDefault = CCUserDefault:sharedUserDefault()
	local is_no_bg_music = userDefault:getBoolForKey("noMusic")
	if not is_no_bg_music then
		local name_str = "bg_login"
		local path_str = utils.getFormatName(name_str)
		audio.playMusic(path_str, true)
	end
end

function utils.getDefaultLanguageName()
	local user_default = CCUserDefault:sharedUserDefault()
	local lang_save_key = "language_key"
	DEFAULT_LANGUAGE = user_default:getStringForKey(lang_save_key)
	if (not DEFAULT_LANGUAGE) or (DEFAULT_LANGUAGE == "") then
		DEFAULT_LANGUAGE = GTab.LANGUAGE
	end


	local has_found_b = false
	for k, v in pairs(lang_resource_cfg) do
		if k == DEFAULT_LANGUAGE then
			has_found_b = true
			break
		end
	end

	if not has_found_b then
		DEFAULT_LANGUAGE = "zh-CN"
	end

	return DEFAULT_LANGUAGE
end

function utils.makeOutSideEdge(file_path)
    --增加上下黑边
    local glview = CCDirector:sharedDirector():getOpenGLView()
    local framesize = glview:getFrameSize()
    local scaleX = framesize.width / CONFIG_SCREEN_WIDTH
    local scaleY = framesize.height / CONFIG_SCREEN_HEIGHT

    local parent = getNotification()
    --只有上下显示花边
    if scaleY > scaleX then
        local viewportsprite_down = ViewPortSprite:create(file_path, CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT);
        parent:addChild(viewportsprite_down)

        --X轴的缩放比例来缩放的
        local need_width = framesize.width
        local contentsize = viewportsprite_down:getContentSize()
        local sp_width = contentsize.width*scaleX
        viewportsprite_down:setScaleX(need_width/sp_width)
        local offsetX = ((sp_width - need_width)/2)/scaleX

        --只显示上下黑边，游戏主窗口Y轴的缩放也是按X轴的缩放比例来缩放的
        local need_height = (framesize.height - (CONFIG_SCREEN_HEIGHT*scaleX))/2
        local contentsize = viewportsprite_down:getContentSize()
        local sp_height = contentsize.height*scaleY
        viewportsprite_down:setScaleY(need_height/sp_height)

        local offsetY = ((sp_height - need_height)/2)/scaleY
        viewportsprite_down:setPosition(-offsetX, -offsetY )

        local viewportsprite_up = ViewPortSprite:create(file_path, CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT);
        parent:addChild(viewportsprite_up)
        viewportsprite_up:setFlipY(true)
        viewportsprite_up:setScaleX(need_width/sp_width)

        viewportsprite_up:setScaleY(need_height/sp_height)
        local up_position_y = (framesize.height - sp_height)/scaleY
        viewportsprite_up:setPosition( -offsetX, up_position_y + offsetY )
    end
end

return utils
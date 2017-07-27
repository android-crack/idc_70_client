require("base/cocos_common/json")

-- Base dump function
local tbDeep = 0
function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = tostring(k) end
			--s = s .. '['..k..'] = ' .. dump(v) .. ','
            s = string.format("%s['%s']=%s,",s, k, dump(v))
		end


		return s .. '} '
	else
		return tostring(o)
	end
end


function lua_string_split(str, split_char)
	local sub_str_tab = {}
	local spc_len = string.len(split_char)
	while (true) do
		local pos = string.find(str, split_char)
		if (not pos) then
			sub_str_tab[#sub_str_tab + 1] = str
		break
	end
	local sub_str = string.sub(str, 1, pos - 1)
	sub_str_tab[#sub_str_tab + 1] = sub_str
	str = string.sub(str, pos + 1, #str)
    end

    return sub_str_tab
end

-------------------------------------------------------------
-- res 
-- 压缩格式
TextureFormat ={
	["A8"] = kCCTexture2DPixelFormat_A8,
	["RGB565"] = kCCTexture2DPixelFormat_RGB565,
	["RGBA5551"] = kCCTexture2DPixelFormat_RGB5A1,
	["RGBA4444"] = kCCTexture2DPixelFormat_RGBA4444,
	["RGBA8888"] = kCCTexture2DPixelFormat_RGBA8888,
	["default"] = kCCTexture2DPixelFormat_RGBA8888,
	
}

local res_load_format_cfg = require("game_config/res_load_format_cfg")
function SetResFormat(res_str)
	local cfg_item = res_load_format_cfg[res_str]
	if cfg_item then
		if TextureFormat[cfg_item.res_format] then
			CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat[cfg_item.res_format])
		end
	end
end
function ResetResFormat(res_str)
	local cfg_item = res_load_format_cfg[res_str]
	if cfg_item then
		if TextureFormat[cfg_item.res_format] then
			CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
		end
	end
end

function getChangeFormatSprite(res_str, ...)
	SetResFormat(res_str)
	local spr = display.newSprite(res_str, ...)
	ResetResFormat(res_str)
	return spr
end

local resCount = {} -- 引用计数

function LoadPlist(plistPaths, isIgnore)
	for path, _format in pairs(plistPaths) do
		resCount[path] = resCount[path] or 0
		if resCount[path] == 0 and not isIgnore then
			if TextureFormat[_format] then 
				CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat[_format])
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(path)
				CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
			else
				SetResFormat(path)
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(path)
				ResetResFormat(path)
			end 
		end	
		resCount[path] = resCount[path] + 1
		print("loadPlist:",_format, path,resCount[path])
	end
end

function UnLoadPlist(plistPaths)
	for path, _format in pairs(plistPaths) do
	
		resCount[path ] = resCount[path] - 1
		if resCount[path] <= 0 then
			resCount[path] = 0
		end
		if resCount[path] == 0 then
			local png = string.gsub(path, ".plist", ".png")
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(path)
			CCTextureCache:sharedTextureCache():removeTextureForKey(png)
			-- pvr
			local pvr = string.gsub(path, ".plist", ".pvr.ccz")
			CCTextureCache:sharedTextureCache():removeTextureForKey(pvr)
		end
		
		print("UnLoadPlist:",_format, path, resCount[path])
	end
end

-- load 单张plist
function AddPlist(path)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(path)
end 

function RemovePlist(path)
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(path)
	-- png
	local png = string.gsub(path, ".plist", ".png")
	CCTextureCache:sharedTextureCache():removeTextureForKey(png)
	-- pvr
	local pvr = string.gsub(path, ".plist", ".pvr.ccz")
	CCTextureCache:sharedTextureCache():removeTextureForKey(pvr)
end 

function LoadArmature(armaturePaths)
	if type(armaturePaths) == "table" then 
		for k, v in pairs(armaturePaths) do
			SetResFormat(v)
			CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(v)
			ResetResFormat(v)
		end
	elseif  armaturePaths then
		SetResFormat(armaturePaths)
		CCArmatureDataManager:sharedArmatureDataManager():addArmatureFileInfo(armaturePaths)
		ResetResFormat(armaturePaths)
	end 
end

function UnLoadArmature(armaturePaths)
	if type(armaturePaths) == "table" then
		for k, v in pairs(armaturePaths) do
			CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(v)
		end
	elseif armaturePaths then
		CCArmatureDataManager:sharedArmatureDataManager():removeArmatureFileInfo(armaturePaths)
	end
end

function LoadImages(imagePaths)
	for path, _format in pairs(imagePaths) do
		print("loadImage:",_format, path)
		if TextureFormat[_format] then 
			CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat[_format])
			CCTextureCache:sharedTextureCache():addImage(path)
			CCTexture2D:setDefaultAlphaPixelFormat(TextureFormat["default"])
		else
			SetResFormat(path)
			CCTextureCache:sharedTextureCache():addImage(path)
			ResetResFormat(path)
		end 	
	end
end  

function UnLoadImages(imagePaths)
	for path, _format in pairs(imagePaths) do
		print("UnLoadImage:",_format, path)
		CCTextureCache:sharedTextureCache():removeTextureForKey(path)
	end
end 

function RemoveTextureForKey(key)
	CCTextureCache:sharedTextureCache():removeTextureForKey(key)
end

-- 释放没用的单张图片问题
function ReleaseTexture()
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	CCAnimationCache:purgeSharedAnimationCache()
	--collectgarbage("collect")
end 

function TextureGC()
	do return end
	print("collectgarbage::TextureGC\n")
	--print("TextureGC================", debug.traceback())
	CCTextureCache:sharedTextureCache():removeUnusedTextures()
	--CCSpriteFrameCache:sharedSpriteFrameCache():removeUnusedSpriteFrames()
	CCAnimationCache:purgeSharedAnimationCache()
	-- 字体cache
	--CCFontAtlasCache:purgeCachedData()
	collectgarbage("collect")
end

-- 接受ios内存警告时调用
function ReceiveMemoryWarning()
	print("lua ReceiveMemoryWarning!!!!!!!!!!!!!!!!!!")
end

----------------------------------------------------------
-- json
-- example
-- local jstr = "{'keyPoint':{'x':146.6,'y':283},'bodyPoint':{'x':145.6,'y':228.64999999999998},'attackPoint':{'x':260.15,'y':244.64999999999998},'headPoint':{'x':146.6,'y':184.95},'hitFrames':[5,12]}"
-- local tb_catch = json.decode(jstr)
function LoadJson(jstr)
	return json.decode(jstr)
end


function LoadJsonFromFile(file_path)
	local full_path = CCFileUtils:sharedFileUtils():fullPathForFilename(file_path)	
	if (full_path == nil) then
		cclog("No such file : "..file_path)
		return
	end
	local jstr = CCString:createWithContentsOfFileExt(file_path)
	return LoadJson(jstr:getCString())
end



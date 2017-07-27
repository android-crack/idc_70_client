-- ！！！
--更新模块用到此块，不要加任何逻辑有关的内容，和require 其他文件进了！！！

require("scripts/base/ui/tools")
local font_config = require("game_config/font_config")

--字体大小
SIZE_TITLE = 20
SIZE_NUMBER = 16
SIZE_BUTTON = 16

local font_config_hash = {}

--字体颜色保存在全局表中
for k, v in pairs(font_config) do
	_G[k] = tonumber(v.color)
	font_config_hash[tonumber(v.color)] = v
end 


--字体路径类型
FONT_COMMON = "FONT_COMMON"
FONT_TITLE = "FONT_TITLE"
FONT_BUTTON = "FONT_BUTTON"
FONT_MICROHEI_BOLD = "FONT_MICROHEI_BOLD"
FONT_CFG_1 = "FONT_CFG_1"
FONT_NUM_COMBAT = "FONT_NUM_COMBAT"
FONT_AVA_BEBI = "FONT_AVA_BEBI"

FONT_RES = "ui/font/font_cn.ttf"

-- 美术字文件
font_tab = {
	[FONT_MICROHEI_BOLD] = "",
	[FONT_COMMON] = "Arial",
	[FONT_NUM_COMBAT] = "ui/font/num_combat.fnt",
	[FONT_AVA_BEBI] = "ui/font/AVA_BEBI.TTF",
}

local function getFontConfig(color)
	local key = color3BToDex(color)
	if font_config_hash[key] then 
		return font_config_hash[key]
	end 
	--print("字体颜色没在font_config上配置！！！", color.r, color.g, color.b)
end 

-- 描边、发光特效
local function effectByColor(label, color)
	label:disableEffect()
	label:setAdditionalKerning(-1)  
	label:setTextColor(ccc4(color.r,color.g,color.b, 255))
	
	local font_data = getFontConfig(color)
	if font_data then
		if font_data.is_glow > 0 then 
			-- 发光
			local glow_color = ccc3(dexToColor3B(tonumber(font_data.glow_color)))
			label:enableGlow(ccc4(glow_color.r, glow_color.g, glow_color.b, 255))
		else 
			local line_width = font_data.stroke_size
			-- 描边
			if line_width > 0 then   
				local line_color = ccc3(dexToColor3B(tonumber(font_data.stroke_color)))
				label:enableOutline(ccc4(line_color.r, line_color.g,line_color.b, 255), 2)
				label.lab_stroke_size = 2
			end 
		end 
		
		-- 阴影
		local shadow_opacity = font_data.shadow_opacity * 255
		if shadow_opacity > 0 then 
			local shadow_color = ccc3(dexToColor3B(tonumber(font_data.shadow_color)))
			label:enableShadow(ccc4(shadow_color.r, shadow_color.g,shadow_color.b, shadow_opacity),CCSize(0, -1))
		end
	end 
end 

function newTTFLabel(params)
    assert(type(params) == "table", "newTTFLabel() invalid params")
    local text       = tostring(params.text)
    local font       = params.font_res or FONT_RES
    local size       = params.size or ui.DEFAULT_TTF_FONT_SIZE
    local color      = params.color or ccc3(dexToColor3B(COLOR_WHITE_STROKE))
    local textAlign  = params.align or ui.TEXT_ALIGN_LEFT
    local textValign = params.valign or ui.TEXT_VALIGN_CENTER
    local dimensions = params.dimensions
	local glow       = false
	
	local font_data = getFontConfig(color)
	if font_data and font_data.is_glow > 0 then 
		glow = true
	end 
	
    local label
    if dimensions then
        label = CCLabel:create(text, font, size, glow, dimensions, textAlign, textValign)
    else
        label = CCLabel:create(text, font, size, glow)
		label:setHorizontalAlignment(textAlign)
    end
	
	effectByColor(label, color)
	
    return label
end

	
--既添加描边又添加阴影 （通用） 
function newLabelOutlineAndShadow(params) 
	local label = newTTFLabel(params)
	local x, y = params.x, params.y	
	
	local node = CCNodeRGBA:create() 
	node:setCascadeOpacityEnabled(true)	
	node.label = label 
	node:addChild(label)
	
	if x and y then node:setPosition(x, y) end
	
	-- 用CCNode 封装 CCLabel
	function node:setString(text)  
        label:setString(text)  
    end  
  
	function node:getString()
		return label:getString()		
	end
	
    function node:getContentSize()  
        return label:getContentSize()  
    end  
    function node:getStrokeSize()  
        return label.lab_stroke_size or 0
    end  
  
    function node:setColor(color)  
		effectByColor(label, color)
    end  
	
	function node:setGray(isgray)
		label:setTextColor(ccc4(95,95,95,255))
	end
	
	function node:getScaledContentSize()
		local size = label:getContentSize()
		return size
	end
	
	function node:getTouchRect()
		local x, y = self:getPosition()
		local size = label:getContentSize()
		return CCRect(x-size.width/2, y-size.height/2, size.width, size.height)
	end
	
	function node:setFontSize(size)
		label:setFontSize(size)
	end
	
	function node:setOpacity(opacity)
		label:setOpacity(opacity)
	end
	
	function node:setAnchorPoint(anchor)
		label:setAnchorPoint(anchor)	
	end
	
	function node:getAnchorPoint()
		return label:getAnchorPoint()
	end
	
	function node:setAdditionalKerning(value)
		label:setAdditionalKerning(value)
	end
	
	function node:getLettersSizeList(count)
		if count <= 0 then 
			return {} 
		end
        local result_tab = {}
        local lab_size = label:getContentSize()
		local pre_letter = label:getLetter(0)
		local pre_letter_size = pre_letter:getContentSize()
		local pre_letter_x = pre_letter:getPositionX() - pre_letter_size.width/2
        local now_letter = nil
		local now_letter_x = 0
		local letter_width = 0
        local letter_height = 0
        local letter_length = 0
        local letter_max_height = pre_letter_size.height
        if letter_max_height < pre_letter_size.width then
            letter_max_height = pre_letter_size.width
        end
		local letter_size = nil
		for i = 1, count do
            local letter_width = pre_letter_size.width
            if letter_max_height < pre_letter_size.height then
                letter_max_height = pre_letter_size.height
            end
            if i == count then
                result_tab[#result_tab + 1] = { width = lab_size.width - letter_length}
                break
			end
            now_letter = label:getLetter(i)
            if now_letter then
                now_letter_size = now_letter:getContentSize()
				now_letter_x = now_letter:getPositionX() - now_letter_size.width/2
				letter_width = (now_letter_x - pre_letter_x)/2
				result_tab[#result_tab + 1] = { width = letter_width}
                letter_length = letter_length + letter_width
			end
            pre_letter = now_letter
            pre_letter_x = now_letter_x
            pre_letter_size = now_letter_size
		end
        letter_max_height = letter_max_height/2
        for k, v in ipairs(result_tab) do
            v.height = letter_max_height
        end
		return result_tab
	end
	
    return node
end

function createNormalFont(params)
	params.color = params.color or ccc3(dexToColor3B(COLOR_WHITE_STROKE))
	return newLabelOutlineAndShadow(params)
end

function createAvaBebiFont(params)
	params.font_res = font_tab[params.fontFile]
	return createNormalFont(params)
end

function createNumberFont(item)
	local defaultSize = 20
	local trueSize = 22
	local default_color = ccc3(255,255,255)
	local text = item.text or ""
	local size = item.size or defaultSize
	local x = item.x or 0
	local y = item.y or 0
	local color = item.color or default_color
	local opacity = item.opacity or 255
	local width =  item.width or -1
	local anchor = item.anchor or ccp(0.5,0.5)
	local align = item.align or kCCTextAlignmentLeft
	local _label
	local _scale = 1
	_label = CCLabelBMFont:create(text, font_tab[item.fontFile], width, align)
	_label:setLineBreakWithoutSpace(true)
	_scale = tonumber(string.format("%0.01f", size/trueSize))
	_label.scale=_scale
	_label.trueSize = trueSize
	_label:setScale(_scale)
	_label.lab_type = "CCLabelBMFont"


	_label:setAnchorPoint(anchor)
	_label:setPosition(x,y)

	_label:setColor(color)
	_label:setOpacity(opacity)
	--字体大小
	_label.setFontSize=function(self,size_)
		local scale = tonumber(string.format("%0.01f", size_/self.trueSize))
        self.scale=scale
		self:setScale(scale)
	end
	_label.getScaledContentSize = function(self)
		local size = _label:getContentSize()
		local _scale = _label:getScale()

		size = CCSize(size.width*_scale, size.height*_scale)
		return size
	end

	_label.getTouchRect = function(self)
		local x, y = self:getPosition()
		local size = self:getScaledContentSize()
		return CCRect(x-size.width/2, y-size.height/2, size.width, size.height)
	end

	return _label
end

local font_func_t = 
{
	[FONT_COMMON] = createNormalFont,
	[FONT_TITLE] = createNormalFont,
	[FONT_BUTTON] = createNormalFont,
	[FONT_CFG_1] = createNormalFont,
	[FONT_MICROHEI_BOLD] = createNormalFont,
	[FONT_NUM_COMBAT] = createNumberFont,
	[FONT_AVA_BEBI] = createAvaBebiFont,
}

function createBMFont(item)
	local fontFile = item.fontFile or FONT_COMMON
	item.opacity = item.opacity or 255
	item.anchor = item.anchor or ccp(0.5,0.5)
	
	local width =  item.width or -1
	
	if width ~= -1 then 
		local height = 0
		item.dimensions = CCSize(width, height)
	end

	local label = font_func_t[fontFile](item)

	if item.parent then
		item.parent:addChild(label)
	end
	
	label:setAnchorPoint(item.anchor)
	if item.opacity then
		label:setOpacity(item.opacity)
	end
	
	return label
end

function getCharSize(char, fontSize)
	return CCLabel:getCharSize(char, FONT_RES, fontSize)
end 

-- 修改编辑器uilabel color
function setUILabelColor(UILabel, color)
	if type(color) == "number" then
		color = ccc3(dexToColor3B(color))
	end
	local label = UILabel:getVirtualRenderer()
    tolua.cast(label, "CCLabel")
	effectByColor(label, color)
end 

function getUILabelColor(UILabel)
	local label = UILabel:getVirtualRenderer()
	return label:getTextColor()
end

-- 给C++调用 
function InitCCLabel(label, text, fontSize, color)
	local str = T(text)
	local color = color or ccc3(dexToColor3B(COLOR_WHITE_STROKE))
	local glow = false
	local font_data = getFontConfig(color)
	if font_data and font_data.is_glow > 0 then 
		glow = true
	end 
	label:initWithTTF(str, FONT_RES, fontSize, glow)
	effectByColor(label, color)
end



--[[
utf8 对应unicode最多可以用到6个字节
1字节 0xxxxxxx 
2字节 110xxxxx 10xxxxxx 
3字节 1110xxxx 10xxxxxx 10xxxxxx 
4字节 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx 
5字节 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 
6字节 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 

转换成对应的16进制如下
// 00110001 
{(byte)0x31}, 
// 11000000 10110001 
{(byte)0xC0,(byte)0xB1}, 
// 11100000 10000000 10110001 
{(byte)0xE0,(byte)0x80,(byte)0xB1}, 
// 11110000 10000000 10000000 10110001 
{(byte)0xF0,(byte)0x80,(byte)0x80,(byte)0xB1}, 
// 11111000 10000000 10000000 10000000 10110001 
{(byte)0xF8,(byte)0x80,(byte)0x80,(byte)0x80,(byte)0xB1}, 
// 11111100 10000000 10000000 10000000 10000000 10110001 
{(byte)0xFC,(byte)0x80,(byte)0x80,(byte)0x80,(byte)0x80,(byte)0xB1}, 
--]]
function checkFontByteLimit(input,limit_byte_count)
	limit_byte_count = limit_byte_count or 3
	local len = string.len(input)
	local left = len
	local is_out_limit = false
	local arr = {0,0xc0,0xe0,0xf0,0xf8,0xfc} --看上面注释

	while left ~= 0 do
		local tmp = string.byte(input,-left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - 1
				break
			end
			i = i - 1
		end
		if i > (limit_byte_count ) then --byte个数超出
			is_out_limit = true
		end
	end
	return is_out_limit
end

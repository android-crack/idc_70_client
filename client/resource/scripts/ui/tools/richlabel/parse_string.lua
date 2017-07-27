-----------------------------------------------------------------------------
-- 解析富文本字符串的处理
-- @author Prophet
-----------------------------------------------------------------------------
local DEF = require("ui/tools/richlabel/richlabeldef")
local richlabel_info = require("game_config/richlabel_info")
----------------------------- 外部会使用到的常量Begin -----------------------

-- 从字符串中获取对应的id
local function getFontNumFromStr(font_str)
	if _G[font_str] then
		return _G[font_str]
	end
	echoInfo(T("ERROR: 不存在有名为 "..font_str.." 的字体！！！！！！！！！！！！！"))
	return DEF.DEFAULT_TEXT_FONT
end

-- 从字符串中获取对应的颜色
local function getColorNumFromStr(color_str)
    if not color_str then
        return DEF.DEFAULT_TEXT_COLOR
    end
    if string.len(color_str) >= 2 then
        local title_text_clr = string.sub( color_str, 1 , 2)
        if "0x" == title_text_clr then
            return tonumber(color_str)
        end
    end
	if _G[color_str] then
		return _G[color_str]
	end
	echoInfo(T("ERROR: 不存在颜色为 "..color_str.." 的字！！！！！！！！！！！！！"))
	return DEF.DEFAULT_TEXT_COLOR
end

local function getColorNum(color_str)
	if not color_str then
        return DEF.DEFAULT_TEXT_COLOR
    end
	if type(color_str) == "number" then
		return color_str
	end
	return getColorNumFromStr(color_str)
end

--获取字符串中的普通，点击，disEnable的三张图片，并且获取其缩放系数
local function getImgConfig(res_str)
    local is_image = function(check_str)
            if string.len(check_str) >= 2 then
                if string.byte(check_str, 1) == string.byte('#') then
                    return true
                end
            end
            return false
        end
    local img_tab = {}
    local scale_n = 1
    for i = 1, 4 do
        local res_cut_n = string.find(res_str, '|')
        local res_item_str = nil
        if res_cut_n then
            res_item_str = string.sub(res_str, 1, res_cut_n - 1) 
            res_str = string.sub(res_str, res_cut_n + 1)
        else
            res_item_str = res_str
        end
        if res_item_str and (string.len(res_item_str) > 0) then
            if is_image(res_item_str) then
                img_tab[#img_tab + 1] = res_item_str
            else
                scale_n = tonumber(res_item_str)
            end
        end
        if nil == res_cut_n then
            break
        end
    end
    return img_tab[1], img_tab[2], img_tab[3], scale_n
end

-- 某些定制部分只需在本文件中处理完毕，
-- 例如:$(c:0xFF0000), $(c:COLOR_GREEN)
-- $(c:end)
-- 也写到这里，保证外部扩展本文件时，只需要关心这部分
local function customTextColor( customType, customParam, parse_param)
	if (customParam == "end") then 
		parse_param.text_clr = DEF.DEFAULT_TEXT_COLOR 
		return
	end

	if (customParam == "END") then 
		parse_param.text_clr = DEF.DEFAULT_TEXT_COLOR 
		return
	end

	local clr = getColorNumFromStr(customParam)

	parse_param.text_clr = clr
end

-- 某些定制部分只需在本文件中处理完毕，
-- 例如:$(font:0xFF0000, )
-- $(font:end)
local function customTextFont( customType, customParam, parse_param )
	if (customParam == "end") then 
		parse_param.font_clr = DEF.DEFAULT_TEXT_FONT 
		return
	end
	if (customParam == "END") then 
		parse_param.font_clr = DEF.DEFAULT_TEXT_FONT 
		return
	end
	index_n = string.find(customParam, ",")
	if index_n then
		text_clr = string.sub( customParam, index_n + 1 )
		customParam = string.sub( customParam, 1, index_n - 1 ) 
		text_clr = string.gsub(text_clr, " ", "")
        parse_param.text_clr = getColorNumFromStr(text_clr)
	end
	local clr = getFontNumFromStr(customParam)
	parse_param.font_clr = clr
end

-- 某些定制部分只需在本文件中处理完毕，
-- 例如:$(font:[1,2,3,"10086"])
-- $(font:end)
local function customTextTouch( customType, customParam, parse_param, tb_custom )
    tb_custom.is_touch_b = true
    tb_custom.params = {}
    if string.len(customParam) > 0 then
        tb_custom.params = json.decode(customParam)
    end
end

--一般情况使用
local function customCall(customType, customParam, parse_param, tb_custom)
	local index_n = string.find(customParam, ",")
	local key_str = ""
	local text_str = customParam
	if index_n then
		text_str = string.sub( customParam, index_n + 1 )
		key_str = string.sub( customParam, 1, index_n - 1 )
		key_str = string.gsub(key_str, " ", "")
	end
    tb_custom.param = customParam
    tb_custom.text = text_str
    tb_custom.key = key_str
    tb_custom.color = parse_param.text_clr
    tb_custom.font = parse_param.font_clr
end

--给聊天用
local function customMsgCall(customType, customParam, parse_param, tb_custom)
	local index_n = string.find(customParam, "|")
	local key_str = "[]"
	local text_str = customParam
	if index_n then
		text_str = string.sub(customParam, index_n + 1 )   --显示文本
		key_str = string.sub(customParam, 1, index_n - 1 ) --参数
	end
    tb_custom.param = customParam
    tb_custom.text = text_str
    tb_custom.key = key_str
    tb_custom.color = parse_param.text_clr
    tb_custom.font = parse_param.font_clr
end

--给任务用
local function customMisCall(customType, customParam, parse_param, tb_custom)
	local index_n = string.find(customParam, "|")
	local key_str = "[]"
	local text_str = customParam
	if index_n then
		text_str = string.sub(customParam, index_n + 1 )
		key_str = string.sub(customParam, 1, index_n - 1 )
	end
    tb_custom.param = customParam
    tb_custom.text = text_str
    tb_custom.key = json.decode(key_str)
    tb_custom.color = parse_param.text_clr
    tb_custom.font = parse_param.font_clr
end

local custom_parse = {
	[DEF.PARSE_TYPE.TEXT_COLOR] = customTextColor,
	[DEF.PARSE_TYPE.TEXT_FONT] = customTextFont,
	[DEF.PARSE_TYPE.TEXT_TOUCH] = customTextTouch,
	[DEF.PARSE_TYPE.CALL] = customCall,
	[DEF.PARSE_TYPE.MSGCALL] = customMsgCall,
	[DEF.PARSE_TYPE.MISCALL] = customMisCall,
}


----------------------------- 外部会使用到的常量End   -----------------------

----------------------------- 用到的外部函数Begin -----------------------
if not string.trim then
	function string.trim(str)
		str = string.gsub(str, "^[ \t\n\r]+", "")
		return string.gsub(str, "[ \t\n\r]+$", "")
	end
end
----------------------------- 用到的外部函数End   -----------------------

local PARSE_STATUS = {
	INIT = 1,
	TEXT = 2,
	CUSTOM = 3,
}

-- 判断是否$(开头
local function isCustomBegin(str, idx)
	str = string.sub(str, idx, -1)
	local start_index, end_index, match = string.find(str, "(%$%([^%$]-:[^%$]-%))")
	if start_index ~= 1 then
		return false 
	end
	return true
end

local function getCustomEnd(str, idx)
	local len = string.len(str)
	for i = idx, len do 
		if ( string.byte(str, i) == string.byte(')')) then return i end
	end
	return -1
end

local function parseInit(str, idx)
	if isCustomBegin( str, idx ) then
		return PARSE_STATUS.CUSTOM
	end
	return PARSE_STATUS.TEXT
end

local function parseText(str, idx)
	local len = string.len(str)
	local parseLength = 0

	for i = idx, len do 
		if isCustomBegin(str, i) then
			-- 如果是定制开始,直接返回解析长度
			return parseLength - 1
		end
		-- 如果不是定制开始
		parseLength = parseLength + 1
	end
	return parseLength 
end

local function parseCustom(str, idx)
	local endIdx = getCustomEnd( str, idx + 2 )
	if endIdx == -1 then
		echoInfo("ERROR: parse error can't find ')' char")
		local strEnd = string.len(str)
		return strEnd - idx
	end
	return endIdx - idx 
end

local query_parse_type = {}
for k,v in pairs(DEF.PARSE_TYPE) do
	query_parse_type[v] = k
end

-- 定制构建函数
-- $()框起一个定制类型
-- 定制类型内部格式如下:
-- $(type:param1,param2,param3)
local function ctorCustom(str, parse_param)
	local tb_custom = {}

	-- 校验custom的正确性
	if ( string.sub(str, -1) ~= ")") then
		--print("WARNING: ", string.sub(str, -1), str);
		return nil 
	end

	str = string.sub(str, 3, -2 )
	str = string.trim(str)
	--此时str去掉了$(和)部分
	local maohao_start = string.find(str, ":")

	local parse_type
	local params

	if ( maohao_start ) then
		parse_type = string.sub( str, 1, maohao_start - 1 )--类型
		params = string.sub( str, maohao_start + 1 )--参数
	else
		parse_type = str
		params = ""
	end

	-- print( "ctorCustom:", parse_type, params)
	tb_custom.type = parse_type
	tb_custom.params = params
	
	-- 如果错误的类型，返回nil
	if not query_parse_type[parse_type] then 
		echoInfo(T("ERROR: 不明类型"), parse_type, params, str)
		return nil 
	end

	-- 修改解析上下文的函数定义和执行
	if custom_parse[parse_type] then
		if type(custom_parse[parse_type]) == "function" then
			custom_parse[parse_type](parse_type, params, parse_param, tb_custom)
		end
	end

	return tb_custom
end

-- 文本最简单，只要定制下字体
-- 文本构建函数 
local function ctorText(str, parse_param )
	local tb_text = {}
	tb_text.type = DEF.PARSE_TYPE.TEXT 
	tb_text.color = parse_param.text_clr 
	tb_text.text = str
	tb_text.font = parse_param.font_clr
	-- 暂时没有字体
	return tb_text
end


local parse_function = {
	[PARSE_STATUS.TEXT] = parseText,
	[PARSE_STATUS.CUSTOM] = parseCustom,
}

local ctor_function = {
	[PARSE_STATUS.TEXT] = ctorText,
	[PARSE_STATUS.CUSTOM] = ctorCustom,
}


-- 字符串解析函数
function parseStr(str)
	local st = PARSE_STATUS.INIT
	local len = string.len(str)
	-- 对字符串遍历
	local i = 1
	local parse_param = {}

	-- 结果
	local tb_result = {}
	-- 目前有文本默认颜色和默认字体
	-- $(c:0x00CCFF)修改文本当前颜色   $(c:end)恢复之后文本为默认颜色
	-- $(font:FONT_CFG_1)修改文本当前颜色   $(font:end)恢复之后文本为默认颜色
	parse_param.text_clr = DEF.DEFAULT_TEXT_COLOR
	parse_param.font_clr = DEF.DEFAULT_TEXT_FONT
	while i <= len do
		if st == PARSE_STATUS.INIT then --判断是否有自定义标签头
			st = parseInit( str, i )
		end

		local parseEnd
		local parseLength = parse_function[st]( str, i )

		if parseLength <= 0 then
			echoInfo("ERROR:parseLength <= 0", parseLength)
			parseEnd = i 
		else
			parseEnd = i + parseLength
		end

		local sub_str = string.sub(str, i, parseEnd)
		--sub_str就是单个自定义标签
		-- print("GOT ", st,  ":", i, parseEnd, "|" .. sub_str .."|" )
		-- 将结果append到tb_result
		local tmp = ctor_function[st]( sub_str, parse_param )
		
		if tmp then 
			--如果是定制标签，则需要读表获取字体，颜色信息
			if tmp.type and richlabel_info[tmp.type] then
				local tmp_item = richlabel_info[tmp.type]
				tmp.font = getFontNumFromStr(tmp_item.font)
				tmp.color = getColorNumFromStr(tmp_item.color)
			end
			table.insert(tb_result, tmp)
		else
			-- 
			echoInfo("Is not append to result:", sub_str)
		end

		i = parseEnd + 1
		st = PARSE_STATUS.INIT
	end
	return tb_result
end

-------------------------- 以下为测试代码 -------------------------
--[[
-- require("./pp")
local str = "ab中文$(img:#abcd)中文二$(abc:dddd)zhongwen2"
--local str = "红字$(c:0xFF0000)ab中文$(img:#abcd)$(url:全世界,http://abcd.afsdf.com/abc.html?a=b,c=d)世界大团$()结万岁$(c:0x00FF00)zhong$(c:end)wen2$(imt:"

print( str )

--local tb = string.gmatch(str, "%(#(.*):(.*)%)")
--print(string.find(str, "%$%((.*)%)"))
--print(string.find(str, "%$%((.*)%)"))

local tb_result = parseStr( str )
table.print( tb_result )
--]]
return {
    ["getFontNumFromStr"] = getFontNumFromStr,
    ["getColorNumFromStr"] = getColorNumFromStr,
    ["getColorNum"] = getColorNum,
    ["getImgConfig"] = getImgConfig,
}
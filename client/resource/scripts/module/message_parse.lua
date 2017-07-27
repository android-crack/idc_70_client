local dataTool = require("module/dataHandle/dataTools")
local ui_word = require("game_config/ui_word")

local main = {}

local unknow_msg = "(unknow)"

local function decodeAscii(str)
    str = string.gsub(str, '%%(%x%x)', function(char_code) return string.char(tonumber(char_code, 16)) end)
    return str
end

local function split(str, pat)
	if type(str) ~= 'string' then return {} end

    local pattern = string.format("([^%s]+)", pat)
    local fields = {}
    string.gsub(str, pattern, function(c) fields[#fields+1] = c end)
    return fields
end

local parseHandle = {}

function parseHandle.port(content)
	local id = tonumber(content) or 0
	local port_info = require("game_config/port/port_info")

	if port_info[id] then
		return port_info[id].name
	end
	
	return ui_word.CHAT_UNKNOWN_AREA_STR
end

function parseHandle.area(content)
	local id = tonumber(content) or 0
	local area_info = require("game_config/port/area_info")

	if area_info[id] then
		return area_info[id].name
	end
	
	return ui_word.CHAT_UNKNOWN_AREA_STR
end

function parseHandle.error(content)
	local id = tonumber(content) or 0
	local error_info = require("game_config/error_info")
	local error_message = unknow_msg

	if error_info[id] then
		error_message = error_info[id].message
	end

	return error_message
end

function parseHandle.item(content)
	local id = tonumber(content) or 0

	local data = dataTool:getItem(ITEM_INDEX_PROP, id)
	if data == nil then return unknow_msg end

	return data["name"]
end

function parseHandle.baowu(content)
	local id = tonumber(content) or 0

	local data = dataTool:getItem(ITEM_INDEX_BAOWU, id)
	if data == nil then return unknow_msg end

	return data["name"]
end

function parseHandle.skill(content)
	local skillId = tonumber(content) or 0
	local skill = dataTool:getSkill(skillId)
	if not skill then return unknow_msg end

	return skill.name
end

local achievement_info = require("game_config/collect/achievement_info")
function parseHandle.achieve(content)
	local achieveId = tonumber(content) or 0
	local data = achievement_info[achieveId]
	if not data then return unknow_msg end

	return data.name
end

local function parseMessageArgs( content )
    local args = {}
    content = content or ""

    -- 参数深度，本函数不解析参数，只将参数整理出来
    local lv = 1
    local argsIdx = 1
    local len = string.len(content)

    local curArgs = ""
    -- @(reward_str|@(honour:200),@(cash:10000)),@(message:30)
    for strIdx = 1, len do
        local curChar = string.sub(content, strIdx, strIdx)
        local nextChar = string.sub(content, strIdx+1, strIdx+1)
        if curChar == "@" and
           nextChar == "(" then
            -- lv + 1
            -- 参数层数+1
            lv = lv + 1
            curArgs = curArgs .. curChar
        elseif string.sub(content, strIdx, strIdx) == ")" then
            lv = lv - 1
            curArgs = curArgs .. curChar
        elseif string.sub(content, strIdx, strIdx) == ","  then
            if ( lv == 1 ) then
                args[argsIdx] = decodeAscii(curArgs)
                curArgs = ""
                argsIdx = argsIdx + 1
            else
                curArgs = curArgs .. curChar
            end
        else
            curArgs = curArgs .. curChar
        end
    end

    -- 没有等到, 补一个参数
    if string.len(curArgs) > 0 then
    	args[argsIdx] = decodeAscii(curArgs)
	end
    return args 
end

--tip类型
-- T('恭喜你获得%s$(msgcall:["TIP","%s"])'),
--'恭喜你获得$(c:COLOR_GREEN)$(msgcall:|【%s】)'
--'{"id":1}'

local function getTips(kind, content)
	local info = json.decode(content)
    local show_str = string.format("[%s,%s]|【%s】", kind, content, info.name)
    return show_str
end

function parseHandle.name(content)
	content = decodeAscii(content)
	return content
end

function parseHandle.color(content)
	return RICHTEXT_COLOR_STROKE[tonumber(content)]
end

function parseHandle.boatTips(content)
	return getTips('boatTips', content)
end

function parseHandle.boatBaowuTips(content)
	return getTips('boatBaowuTips', content)
end

function parseHandle.baowuTips(content)
    return getTips('baowuTips', content)
end

function parseHandle.itemTips(content)
	return getTips('itemTips', content)
end

function parseHandle.sailorTips(content)
	return getTips('sailorTips', content)
end

-- 多个奖励内容文本 如@(reward_str:@(honour:200),@(cash:10000))
function parseHandle.reward_str(content)
	local args = parseMessageArgs(content)
	local show_str = ""
	for idx, arg in ipairs(args) do
        -- print(string.format("ARGS[%d] = %s", idx, arg ))
        if string.len(show_str) > 1 then
        	show_str = show_str .. ", "
        end
        show_str = show_str .. main.parse(arg)
    end
    return show_str
end

local rpc_down_info = require("game_config/rpc_down_info")
function parseHandle.message(content)
	local str_start, str_end = string.find(content, "|")
    local ret = {}
    if str_start  then
        ret[1] = string.sub(content, 1, str_start - 1)
        ret[2] = string.sub(content, str_end + 1)
    else
    	ret[1] = content
    end

	local id = tonumber(ret[1]) or 0

	if id < 1 then return unknow_msg end

	local showStr = rpc_down_info[id].msg

    local args = parseMessageArgs(ret[2])
    if #args < 1 then return showStr end
    for idx, arg in ipairs(args) do
        args[idx] = main.parse(arg)
        -- print(string.format("ARGS[%d] = %s", idx, arg ))
    end
    return string.format(showStr, unpack(args))
end

function parseHandle.item_cnt(content)
	local args = split(content, ",")
	local id = tonumber(args[1]) or 0
	local cnt = tonumber(args[2]) or 0

	local data = dataTool:getItem(ITEM_INDEX_PROP, id)
	if data == nil then return unknow_msg end
	local show_str = "%s*%s"
	return string.format(show_str, data["name"], cnt)
end

function parseHandle.material_cnt(content)
	local args = split(content, ",")
	local id = tonumber(args[1]) or 0
	local cnt = tonumber(args[2]) or 0

	local data = dataTool:getItem(ITEM_INDEX_MATERIAL, id)
	if data == nil then return unknow_msg end
	local show_str = "%s*%s"
	return string.format(show_str, data["name"], cnt)
end

function parseHandle.cash(content)
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.MAIN_CASH, cnt) 
end

function parseHandle.gold(content)
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.MAIN_GOLD, cnt) 
end

function parseHandle.exp(content)
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.MAIN_EXP, cnt) 
end

function parseHandle.honour(content)
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.MAIN_HONOUR, cnt) 
end

function parseHandle.group_exp(content)--商会经验
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.STR_GUILD_EXP, cnt) 
end

function parseHandle.group_contribute(content)--商会贡献
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.STR_GUILD_CONTRIBUTE, cnt) 
end

function parseHandle.group_prestige(content)--商会声望
	local cnt = tonumber(content) or 0
	local show_str = "%s*%s"
	return string.format(show_str, ui_word.STR_GUILD_PRESTIGE, cnt) 
end

local daily_mission = require("game_config/mission/daily_mission")
function parseHandle.daily_mission(content)--对应id以及等级
	local args = split(content, ",")
	local id = tonumber(args[1]) or 0
	local level = tonumber(args[2]) or 0

	local data = daily_mission[id].mission_name
	if data == nil then return unknow_msg end

	return string.format(ui_word.MESSAGE_DAILY_REWARD_STR, starNumberToString(level + 1), data[1]) 
end

local explore_event = require("game_config/explore/explore_event")
function parseHandle.explore_event(content)
	local id = tonumber(content) or 0

	local data = explore_event[id]
	if data == nil then return unknow_msg end
	return data["name"]
end

local sailor_info = require("game_config/sailor/sailor_info")
function parseHandle.sailor(content)
	local id = tonumber(content) or 0

	local data = sailor_info[id]
	if data == nil then return unknow_msg end
	return data["name"]
end

local team_config = require("game_config/team/team_config")
function parseHandle.team(content)
	local id = tonumber(content) or 0

	local data = team_config[id]
	if data == nil then return unknow_msg end
	return data.name
end

local explore_objects_config = require("game_config/explore/explore_objects_config")
function parseHandle.explore_obj(content)
    local id = tonumber(content) or 0
    local data = explore_objects_config[id]
    if data == nil then return unknow_msg end
    return data.name
end

local function parseMessage(content)
	local str_start, str_end = string.find(content, ":")
	local id_type = ""
	local body = ""
	if str_start == nil then
		id_type = content
	else
		id_type = string.sub(content, 1, str_start-1) or ""
		body = string.sub(content, str_end+1, string.len(content)) or ""
	end

	if not id_type or id_type == "" then return content end

	if type(parseHandle[id_type]) == "function" then
		return parseHandle[id_type](body)
	end

	return content
end

--[[
有多个参数,参数中又有多个参数,会出错,因为"," 被分割了
比如 @(message:1|user:1001,@(item:10,10))
多奖励写法：@(message:98|@(reward_str:@(honour:200),@(cash:10000)),@(message:80),@(item:80),@(reward_str:@(item:80)))
]]--
function main.parse(message)
	local ret = string.gsub(message, "@%((.+)%)", parseMessage)
    return ret
end

return main
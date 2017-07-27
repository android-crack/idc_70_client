require("module/font_util")
--TODO
local DEF = {}
DEF.PARSE_TYPE = {
	-- 文本
	TEXT = "text",
	-- 文本颜色
	TEXT_COLOR = "c",
    --是否点击
	TEXT_TOUCH = "touch",
	-- 字体
	TEXT_FONT = "font",
	-- 图片
	IMAGE = "img",
	IMGBTN = "button",
	-- url
	URL = "url",
	PORT = "port",
	NAME = "name",
	VIEW = "view",
	FORCE = "force",
	MISSIONC = "missioncolor",
	CHAT_PLAYERC = "chat_playerc",
	CHAT_REWARDC = "chat_rewardc",
	CALL = "call",
	MSGCALL = "msgcall",
	MISCALL = "miscall"
}

DEF.ELEMENT_CREATOR = 
{
	[DEF.PARSE_TYPE.TEXT] = require("ui/tools/richlabel/richlabelelementtext"),
	[DEF.PARSE_TYPE.IMAGE] = require("ui/tools/richlabel/richlabelelementimage"),
    [DEF.PARSE_TYPE.IMGBTN] = require("ui/tools/richlabel/richlabelelementimagebtn"),
	[DEF.PARSE_TYPE.URL] = require("ui/tools/richlabel/richlabelelementurl"),
	[DEF.PARSE_TYPE.PORT] = require("ui/tools/richlabel/richlabelelementcustomtext"),
	[DEF.PARSE_TYPE.NAME] = require("ui/tools/richlabel/richlabelelementtext"),
	[DEF.PARSE_TYPE.VIEW] = require("ui/tools/richlabel/richlabelelementcustomtext"),
	[DEF.PARSE_TYPE.FORCE] = require("ui/tools/richlabel/richlabelelementcustomtext"),
	[DEF.PARSE_TYPE.MISSIONC] = require("ui/tools/richlabel/richlabelelementtext"),
	[DEF.PARSE_TYPE.CHAT_PLAYERC] = require("ui/tools/richlabel/richlabelelementtext"),
	[DEF.PARSE_TYPE.CHAT_REWARDC] = require("ui/tools/richlabel/richlabelelementtext"),
	[DEF.PARSE_TYPE.CALL] = require("ui/tools/richlabel/richlabelelementcallbacktext"),
	[DEF.PARSE_TYPE.MSGCALL] = require("ui/tools/richlabel/richlabelelementcallbackmsg"),
	[DEF.PARSE_TYPE.MISCALL] = require("ui/tools/richlabel/richlabelelementcallbackmis"),
}

DEF.SIZECFG_PATH = "ui/tools/richlabel/sizecfg"

-- 默认的文本颜色
DEF.DEFAULT_TEXT_COLOR = COLOR_WHITE
DEF.DEFAULT_TEXT_FONT = FONT_COMMON
return DEF

require("base/net/rpc")
json = require('json')

function dump(o)
    if type(o) == 'table' then
        local s = '{ '
        for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. dump(v) .. ','
        end
        return s .. '} '
    else
        return tostring(o)
    end
end


function gameStart()
	SERVER_FUNC["rpc_server_version"]("cocos2d", "b", "c");
end

function onRead(luaSock, data)
	rpc._input = rpc._input .. data
	rpc:rpc_parse()
end

function onError(luaSock)
	print("onError")
end

function onConnected(luaSock)
	print("onConnected!!!")
	rpc._luaSocket = luaSock
	gameStart()
end

function connect(ip, port)
	local sock = LuaSocket:create()
	sock:setScriptReadCB(onRead)
	sock:setScriptErrorCB(onError)
	sock:setScriptConnectedCB(onConnected)
	sock:connect(ip, port)
end

function libevent_dispatch(x, y)
    LuaSocket:dispatch()
end


wrapServerFunc()
CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(libevent_dispatch, 0, false)
connect("192.168.12.62", 2251);
print("after connect")

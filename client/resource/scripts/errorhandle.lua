local errorMsgTab = {}

--debug报错汇总发给服务端
local function saveErrorToServer(errorMessage, traceback)
	--"%W"：字母数字以外的符号转成"."，以便匹配检查是否是同一条bug报错
	local subError = string.gsub(errorMessage, "%W",".")
	local isHave = false
	for k,v in pairs(errorMsgTab) do
		local subMsg = string.gsub(v["key"], "%W",".")
		local matchMsg = string.match(subError, subMsg)
		if matchMsg ~= nil and matchMsg ~= "" then
			isHave = true
		end
	end
   
    if isHave then return end
	
	table.insert(errorMsgTab, {key = errorMessage, value = traceback})
	
	local uid = getGameData():getPlayerData():getUid() or 0
	local zone = require("language"):getLanguage()

    local url = "http://sentry.sre.rd.175game.com/api/72/store/"
    local event = {
        ["tags"] = {
            ["type"]    = "client_error",
            ["uid"]     = uid,
            ["zone"]    = zone,
        },
        ["culprit"]     = errorMessage,
        ["level"]       = "debug",
        ["message"]     = string.format("LUA ERROR: %s%s", tostring(errorMessage), traceback),
    }
	
    local request = network.createHTTPRequest(function(event)
        local ok = ( event.name == "completed" )
        local request = event.request
        if not ok then
			request:release()
            return
        end

        local code = request:getResponseStatusCode()
        if code ~= 200 then
            print("上传失败！！！", code)
        end
		request:release()
    end, url, "POST")
	
    request:addRequestHeader("Connection: Keep-Alive")
    request:addRequestHeader("User-Agent: raven-python/1.0")
    request:addRequestHeader("Content-Type: application/json")
    request:addRequestHeader("X-Sentry-Auth: Sentry sentry_version=7, sentry_key=b8a19bdaa8b24f379c136df9ac502761, sentry_secret=7bc98d908e2640d499bb104cf5a28c82, sentry_client=raven-python/1.0")
    request:setPOSTData(json.encode(event))
    request:setTimeout(30)
    request:start()
end

function sendErrorToServer(errorMessage, traceback)
	if DEBUG > 0 then --发布版本不显示，内服测试版本均要显示
		require("ui.game_error_info").new(errorMessage, traceback)
    else
        saveErrorToServer(errorMessage, traceback)
	end	
end

function sendMsgToServer(msg)
	sendErrorToServer(msg, msg)
end 


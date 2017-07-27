local ModuleGameRpc = require("module/gameRpc")
local ModuleDataHandle = require("module/dataManager")

getOpenUDID = function()
    if device.platform == "windows" then
        local userDefault = CCUserDefault:sharedUserDefault()
        local uuid = userDefault:getStringForKey("uuid")
        if uuid ~= "" then 
            return uuid 
        end

        local uuid_data = CCNative:getOpenUDID()
        uuid =  CCCrypto:MD5Lua(uuid_data, false)

        userDefault:setStringForKey("uuid", uuid)
        userDefault:flush()

        return uuid
    end
    return CCNative:getOpenUDID()
end

ModuleStartGame = {}

--开始游戏的方式定议
START_TYPE_LOGIN        = 1             --直接拉起登录流程开始游戏,目前内部使用
START_TYPE_CHECK_UUID     = 2           --向服务器请求uuid状态，根据udid的绑定状态决定是直接进新手，还是拉起登录
START_TYPE_TENCENT          = 3         --腾讯安卓登录，根据udid的绑定状态决定是直接进新手，还是拉起登录
START_TYPE_TENCENT_IOS        = 4       --腾讯ios登录，根据udid的绑定状态决定是直接进新手，还是拉起登

-------------------几种开始游戏方式对应的函数----------------------------------
local default_tencent_auth_chn = "qq"
local default_tencent_ios_auth_chn = "qq_ios"

local function startLoginByChannel(auth_chn, login_fun)
    updateVersonInfo(LOG_1004)
    if login_fun then
        login_fun()
    else
        require("gameobj/login/LoginScene").startLoginScene()
    end
end

startGameFuncs = {}
startGameFuncs[START_TYPE_LOGIN] = function()
    startLoginByChannel("", function()
        require("gameobj/login/LoginScene").startServerListScene()
    end)
end

startGameFuncs[START_TYPE_CHECK_UUID] = function()
    local server_list = ModuleStartGame.getLoginServer()
    ----just test data ----------------
    --[[
    server_list = {
        [1] = {
            name = "prophet",
            ip = "192.168.30.44",
            port = 3540,
        }
    }
    --]]
    ----test data ----------------
    if #server_list > 1 then
        --进入选服界面
        startGameFuncs[START_TYPE_LOGIN]()
    else
        --直接check uuid
        local server_cfg = server_list[1]
        local start_and_login_data = getGameData():getStartAndLoginData()
        start_and_login_data:setLoginIpPort(server_cfg)
        ModuleGameRpc.connectGame()
    end
end

STOP_SVR_ANNOUNCE = false

startGameFuncs[START_TYPE_TENCENT] = function()
    startLoginByChannel(default_tencent_auth_chn)
end

startGameFuncs[START_TYPE_TENCENT_IOS] = function()
    startLoginByChannel(default_tencent_ios_auth_chn)

    local function iosTsscallBack(code, msg)
        safeSDKDataBack(msg)
    end
    QTssSDK:getInstance():setHandler(iosTsscallBack)
end

-------------------几种开始游戏方式对应的函数----------------------------------

-------------------根据channel id来选择登录方式-------------------------------
start_type_by_channel = {
    ["online"] = START_TYPE_CHECK_UUID,             --online服，
    ["moni"] = START_TYPE_CHECK_UUID,               --moni服，
    ["tencent"] = START_TYPE_TENCENT,            --tencent服，
    ["debug"]= START_TYPE_CHECK_UUID,             --内部开发服,
    ["alicloud"]= START_TYPE_CHECK_UUID,             --aliyun服,
    ["qtz"]= START_TYPE_CHECK_UUID,                    --qtz服,
    ["efun"] = START_TYPE_CHECK_UUID,
    ["ce_test"] = START_TYPE_CHECK_UUID,
    ["tencent_ios"] = START_TYPE_TENCENT_IOS,
}
-------------------根据channel id来选择登录方式-------------------------------

ModuleStartGame.getChannelId = function()
    return GTab.CHANNEL_ID
end

--获取登录的服务器
ModuleStartGame.getLoginServer = function()
    return  GTab.SERVER_LIST
end


local NEED_FREE_TESTIN = nil
ModuleStartGame.startGame = function()
    hideVersionInfo(true)
    --如果需要test in免费测试兼容性的话，直接进一场战斗
    if NEED_FREE_TESTIN then
        package.loaded["test/testBattle"] = nil
        require("test/begin")
        return
    end

    local channel_id = GTab.CHANNEL_ID
    local start_game_type = start_type_by_channel[channel_id]
    if not start_game_type then
        print(string.format("错误的渠道类型!!!!!!!-->%s",channel_id ))
        start_game_type = start_type_by_channel["moni"]
        --return
    end

    --记录启动模式
    local start_and_login_data = getGameData():getStartAndLoginData()
    start_and_login_data:setStartGameType(start_game_type)

    local start_func = startGameFuncs[start_game_type]
    if not start_func then
        print(string.format("找不到对应的开始函数!!!!!!!-->%s", start_game_type))
        return
    end

    if STOP_SVR_ANNOUNCE then
        require("gameobj/login/LoginScene").startLoginScene()
        return
    end
    start_func()
end

return ModuleStartGame





local StartAndLoginData=class("StartAndLoginData")

function StartAndLoginData:ctor()
    local userDefault = CCUserDefault:sharedUserDefault()
    _G.login_wait_need_time = userDefault:getStringForKey(WAIT_LOGIN_TIMES)
    _G.login_wait_os_time = userDefault:getStringForKey(WAIT_LOGIN_OS_TIME)
    _G.connect_count = 0
    _G.connect_click_count = 0

    self:clearData()
end

function StartAndLoginData:clearData()
    self.start_game_type = nil  --启动模式

    self.login_finish = nil

    self.kick_out_uid = nil


    self.is_login_again = nil

    self.kick_out_login_use = nil

    self.start_game = nil
end


function StartAndLoginData:setLoginIpPort(server_config)
    _G.login_server = server_config
end

function StartAndLoginData:getLoginIpPort()
    return _G.login_server
end

function StartAndLoginData:setStartGameType( type)
    self.start_game_type = type
end

function StartAndLoginData:getStartGameType()
    return self.start_game_type
end

function StartAndLoginData:setLoginKey(ln, lkw)

    local login_str = ln.."|"..lkw

    _G.login_use = ln
    _G.login_pwd = lkw
    _G.login_key = login_str
end


function StartAndLoginData:getLoginKey()
    return _G.login_key
end

function StartAndLoginData:getLoginUse()
    return _G.login_use
end

function StartAndLoginData:getLoginPwd()
    return _G.login_pwd
end

function StartAndLoginData:setLoginFinish( finish_flag )
    self.login_finish = finish_flag
    _G.LOGIN_FINISH_ONCE = true
    self:clearWaitingLoginTimes()
end

function StartAndLoginData:getLoginFinish()
    return self.login_finish
end

function StartAndLoginData:getLoginFinishOnce()
    return _G.LOGIN_FINISH_ONCE
end

function StartAndLoginData:setKickOutUid( kick_out_uid )
    self.kick_out_uid = kick_out_uid
end

function StartAndLoginData:getKickOutUid()
    return self.kick_out_uid
end

function StartAndLoginData:setKickOutLoginUse( login_use )
    self.kick_out_login_use = login_use
end

function StartAndLoginData:getKickOutLoginUse( )
    return self.kick_out_login_use
end

function StartAndLoginData:setLoginAgain( is_login_again )
    self.is_login_again = is_login_again
end

function StartAndLoginData:getLoginAgain( )
    return self.is_login_again
end

function StartAndLoginData:setStartGameState(state)
    self.start_game = state
end

function StartAndLoginData:getStartGameState()
    return self.start_game
end

function StartAndLoginData:setStartupVipState( platform )
    _G.start_up_vip_plat = platform
end

function StartAndLoginData:getStartupVipPlat()
    local plat = _G.start_up_vip_plat
    _G.start_up_vip_plat = nil
    return plat
end

function StartAndLoginData:setWaitingLoginTimes()
    local fail_times = _G.login_fail_time
    if not fail_times then
        fail_times = 0
    end
    fail_times = fail_times + 1
    if fail_times % 3 == 0 then--三次
        local level = math.ceil(fail_times/3)
        local need_time = WAIT_LOGIN_DELAY[math.min(level, 3)]
        local cur_time = os.time()
        _G.login_wait_need_time = need_time
        _G.login_wait_os_time = cur_time

        local userDefault = CCUserDefault:sharedUserDefault()
        userDefault:setStringForKey(WAIT_LOGIN_TIMES, need_time)
        userDefault:setStringForKey(WAIT_LOGIN_OS_TIME, cur_time)
        userDefault:flush()
    end
    _G.login_fail_time = fail_times
end

function StartAndLoginData:getWaitingLoginLeftTime()
    local wait_os_time = _G.login_wait_os_time
    local wait_need_time = _G.login_wait_need_time
    if wait_os_time and wait_need_time and tonumber(wait_need_time) > 0 then
        local left_time = tonumber(wait_need_time) + tonumber(wait_os_time) - os.time() 
        if left_time <= 0 then
            _G.login_wait_need_time = nil
            _G.login_wait_os_time = nil
            return nil
        end
        return left_time
    end
    return nil
end

function StartAndLoginData:clearWaitingLoginTimes()
    _G.login_fail_time = nil
    _G.login_wait_need_time = nil
    _G.login_wait_os_time = nil
    local userDefault = CCUserDefault:sharedUserDefault()
    userDefault:setStringForKey(WAIT_LOGIN_TIMES, "")
    userDefault:setStringForKey(WAIT_LOGIN_OS_TIME, "")
    userDefault:flush()
end

function StartAndLoginData:getLoginNoticeTime()
    local userDefault = CCUserDefault:sharedUserDefault()
    local notice_time = userDefault:getIntegerForKey(LOGIN_LAST_NOTICE_TIME)
    return notice_time
end

function StartAndLoginData:setLoginNoticeTime()
    local userDefault = CCUserDefault:sharedUserDefault()
    userDefault:setIntegerForKey(LOGIN_LAST_NOTICE_TIME, os.time())
end

function StartAndLoginData:setConnectDelayCount(is_clear)
    if is_clear then
        _G.connect_count = 0
        _G.connect_click_count = 0
        return
    end
    -- local delay_time = 0.2 * math.pow(2, _G.connect_count)
    _G.connect_count = _G.connect_count + 1
    local delay_time = 0.2 * tonumber(_G.connect_count)
    --print("===================setConnectDelayCount", delay_time , _G.connect_count)
    local need_tip_time = 0
    if _G.connect_count >= 20 or _G.connect_click_count > 5 then
        need_tip_time = CONNECT_FAIL_DELAY_TIME
        local userDefault = CCUserDefault:sharedUserDefault()
        userDefault:setIntegerForKey(CONNECT_FAIL_OS_TIME, os.time())
    end
    return need_tip_time, math.min(delay_time, 15)
end

function StartAndLoginData:setConnectClickCount()
    _G.connect_click_count = _G.connect_click_count + 1
end

function StartAndLoginData:getConnectDelayTime()
    local userDefault = CCUserDefault:sharedUserDefault()
    local need_delay_os_time = userDefault:getIntegerForKey(CONNECT_FAIL_OS_TIME)

    local left_time = need_delay_os_time + CONNECT_FAIL_DELAY_TIME - os.time()
    --print("===================left_time", left_time, os.time(), _G.connect_count)
    if left_time <= 0 and (_G.connect_count >= 20 or _G.connect_click_count > 5) then
        _G.connect_count = 0
        _G.connect_click_count = 0
        userDefault:setIntegerForKey(CONNECT_FAIL_OS_TIME, 0)
    end
    return left_time
end

return StartAndLoginData



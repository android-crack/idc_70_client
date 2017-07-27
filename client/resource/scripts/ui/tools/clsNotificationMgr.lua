--本地推送类
ClsNotificationMgr = {}

local pNotificationManager = NotificationManager:getNotificationManager()
local pCCUserData = CCUserDefault:sharedUserDefault()
local tNotifications = {}
local NOTIFICATION_KEY = "notifications"
local notificationList = require("game_config/notification")
local filterKeys = { "J", "SE" }

function ClsNotificationMgr.registerNotification( uid )
    if uid == 0 then
        return
    end
    pNotificationManager:registerNotification( tostring( uid ) )
end

--[[ key:
N01:    Soldiers training finished
J*:     Building building and upgrading finished, * is building id
S01:    Shield will be disabled in half an hour
S02:    Didn't login in past 48h if they didn't have shield
X01:    12:00 every day
X02:    18:00 every day
SE*:    Search event complete, * is eid+id
--]]
function ClsNotificationMgr.addNotification( key, msg, delay, repeats )
    local mNotificationInfo = {
        time    = os.time(),
        msg     = msg,
        delay   = delay,
        repeats = repeats
    }
    tNotifications[ key ] = mNotificationInfo
end

function ClsNotificationMgr.removeNotification( key )
    tNotifications[ key ] = nil
end

function ClsNotificationMgr.removeAllNotifications( )
    pNotificationManager:removeNotification()
    local jsonData = pCCUserData:getStringForKey( NOTIFICATION_KEY, "")
    if jsonData == "" then
        return
    end
    tNotifications = json.decode( jsonData )
end

local function isInFilterKey(key)
    for _, filterKey in ipairs(filterKeys) do
        local length = string.len(filterKey)
        if string.sub( key, 1, length ) == filterKey then
            return true
        end
    end
    return false
end

-- param: 8/29/2015 12:00:00
-- return: 1440820800
function timestr2time(str, noTimeZone)
    local noTimeZone = noTimeZone or false
    local date, time = unpack(string.split(str, " ")) 
    local month, day, year = unpack(string.split(date, "/"))
    local hour, min, sec = unpack(string.split(time, ":"))
    local ts = os.time({year=year, month=month, day=day, hour=hour, min=min, sec=sec})
    if noTimeZone then
        return ts
    end

    local now = os.time()
    return ts + os.difftime(now, os.time(os.date("!*t", now))) - 28800
end

function ClsNotificationMgr.pushAllNotifications( )
    pNotificationManager:removeNotification()
    local mTime = os.time()
    local expiredNotifications = {}

    -- filter expired notification
    for k, v in pairs( tNotifications ) do
        local mDelta = mTime - v.time
        if mDelta >= v.delay then
            table.insert( expiredNotifications, k )
        end
    end

    -- delete expired notification
    for k, v in ipairs( expiredNotifications ) do
        tNotifications[ v ] = nil
    end

    for _, key in ipairs(filterKeys) do
        local minKey, minDelta = ClsNotificationMgr.filterNotifications(key)
        if minKey ~= "" and minDelta ~= 0 then
            print(v.msg, minDelta, os.date("%c", minDelta + os.time()))
            local v = tNotifications[ minKey ]
            pNotificationManager:notification( v.msg, minDelta, v.repeats, "q3" )
        end
    end

    for k, v in pairs(tNotifications) do
        if not isInFilterKey(k) then
            print(v.msg, v.delay, os.date("%c", v.delay + os.time()))
            pNotificationManager:notification( v.msg, v.delay, v.repeats, "q3" )
        end
    end

    local jsonData = json.encode( tNotifications )
    pCCUserData:setStringForKey( NOTIFICATION_KEY, jsonData )
    tNotifications = {}

    -- push tax notification
    local h = os.date( "%H" )
    local m = os.date( "%M" )
    local s = os.date( "%S" )
    -- local msg = T("尊敬的船长")


    local function timeNotification(msg, time)
        local delta = ( time - h - 1 ) * 3600 + ( 14 - m ) * 60 + ( 60 - s )
        -- print("=====================delta", delta)
        if delta <= 0 then      -- means it's after 12:00 or 18:00 or 21:00
            delta = delta + 24 * 3600
        end
        print(msg, delta, os.date("%c", delta + os.time()))
        pNotificationManager:notification( msg, delta, 1, "q3" )
    end

    local function timeNotificationWithTimezone(msg, time)
        local now = os.time()
        local real = (os.difftime(now, os.time(os.date("!*t", now))) - 28800) / 3600 + time
        timeNotification(msg, real)
    end

    -- timeNotification(msg,23)
    -- timeNotification(msg,22)
    -- timeNotification(msg,22)

    -- push qunxiong notification
    -- local qunxiongmsg = T("尊敬的船长，享利王子的补给已经送到港口了！")
    -- timeNotificationWithTimezone(qunxiongmsg,23.5)

    for _, notify in ipairs(notificationList) do
        local delta = timestr2time(notify.time) - os.time()

        if delta < 0 and notify.repeats then
            local date, time = unpack(string.split(notify.time, " "))
            local dd = os.date("%w", timestr2time(notify.time, true)) - os.date("%w")
            if dd < 0 then
                dd = dd + math.floor(math.abs(dd)/notify.repeats) * notify.repeats
            end
            date = os.date("%m/%d/%Y", dd * 86400 + os.time())
            local realTime = string.format("%s %s", date, time)
            delta = timestr2time(realTime) - os.time()
            if delta < 0 then
                delta = delta + notify.repeats * 86400 
            end
            -- print(delta, os.date("%c", delta + os.time()))
        end

        if delta > 0 then
            print(notify.msg, delta, os.date("%c", delta + os.time()))
            pNotificationManager:notification(notify.msg, delta, 0, "q3")
        end
    end
end

function ClsNotificationMgr.filterNotifications( key )
    local mTime = os.time()
    local notifications = {}

    local keyLength = string.len(key)

    for k, v in pairs( tNotifications ) do
        if string.sub( k, 1, keyLength ) == key then
            notifications[ k ] = v
        end
    end

    local minDelta = 999999999 
    local minKey   = ""

    for k, v in pairs( notifications ) do
        local mDelta = v.delay - mTime + v.time
        if minDelta > mDelta then
            minDelta    = mDelta
            minKey      = k
        end
    end

    return minKey, minDelta
end

return ClsNotificationMgr
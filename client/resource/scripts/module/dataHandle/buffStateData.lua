
local ClsAlert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")

local ClsBuffStateData = class("BuffStateData")

local EXP_UP_BUFF_ID = "port_battle_exp_buff"
local LOCK_OUT_PORT = "contend_ban_explore"

function ClsBuffStateData:ctor()
	self.m_buff_info = {}
end

function ClsBuffStateData:addBuffState(info)
    self.m_buff_info[info.status_id] = info
    if LOCK_OUT_PORT == info.status_id then
        local port_layer = getUIManager():get("ClsPortLayer")
        if not tolua.isnull(port_layer) then
            port_layer:updateLockExploreTimer()
        end
    end
end

function ClsBuffStateData:removeBuffState(status_id)
	if self.m_buff_info[status_id] then
		self.m_buff_info[status_id] = nil
	end
end

function ClsBuffStateData:getBuffStateByStatusId(status_id)
    return self.m_buff_info[status_id]
end

function ClsBuffStateData:getLockGoExploreTime()
    local info = self.m_buff_info[LOCK_OUT_PORT]
    if info then
        local time_n = math.ceil(info.timeout + info.clock_time - os.clock())
        if time_n > 0 then
            return time_n
        end
    end
    return 0
end

function ClsBuffStateData:IsCanGoExplore(is_show_tip)
    if self:getLockGoExploreTime() > 0 then
        if is_show_tip then
            ClsAlert:warning({msg = string.format(ui_word.EXPLORE_LOCK_TIPS, self:getLockGoExploreTime())})
        end
        return false
    end
    return true
end

function ClsBuffStateData:getExpUpLeftTime()
	local status_id = EXP_UP_BUFF_ID
	local info = self.m_buff_info[status_id]
	if info then
		local time_n = math.ceil(info.timeout + info.clock_time - os.clock())
		if time_n > 0 then
			return time_n
		end
	end
	return 0
end

function ClsBuffStateData:getExpUpResult(org_exp_n)
	if self:getExpUpLeftTime() > 0 then
		return math.ceil(org_exp_n*(1 + self.m_buff_info[EXP_UP_BUFF_ID].status_data.RoleExpRaise/100))
	end
	return org_exp_n
end


function ClsBuffStateData:getQQVipStatus()
    local vip_status = 0
    if self.m_buff_info["qq_vip"] then -- vip
        vip_status = 1
    elseif self.m_buff_info["qq_svip"] then --super_vip
        vip_status = 2
    end
    print("------------vip-----------------", vip_status)
    return vip_status
end

function ClsBuffStateData:getBootStatus()
    local boot_status = 0
    if self.m_buff_info[BOOT_QQ] then --QQ启动
        boot_status = BOOT_QQ
    elseif self.m_buff_info[BOOT_WX] then --微信启动
        boot_status = BOOT_WX
    end
    return boot_status
end

return ClsBuffStateData
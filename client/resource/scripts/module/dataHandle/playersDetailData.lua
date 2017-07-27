require("lfs")
local ClsPlayersDetailData = class("explorePlayerShipsData")
local dataTools = require("module/dataHandle/dataTools")

local BAK_VERSION = 10
local MAX_SAVE_ITEM_COUNT = 1000

local INFO_ID = {
	NAME = 1,
	NAME_ENCODE = 2,
	LV = 3,
	ROLE_ID = 4,
	ICON = 5,
	SHIP_ID = 6,
	NOBILITY = 7,
	TITLE = 8,
	GUILD_NAME = 9,
	GUILD_NAME_ENCODE = 10,
	GUILD_JOB = 11,
	GUILD_ICON = 12,
	VERSION = 13,
	STACK_ID = 14,
}

local FILE_INFO_ID = {
	UID = 1,
	NAME_ENCODE = 2,
	LV = 3,
	ROLE_ID = 4,
	ICON = 5,
	SHIP_ID = 6,
	NOBILITY = 7,
	TITLE = 8,
	GUILD_NAME_ENCODE = 9,
	GUILD_JOB = 10,
	GUILD_ICON = 11,
	VERSION = 12,
}

function ClsPlayersDetailData:ctor()
    self.m_player_info = {}
    self.m_stack = {}
    self.m_stack.array = {}
    self.m_stack.top = 1
    self.m_stack.is_load_file = false
    self.m_is_go_explore = false

    self:initFileName()

    self:makeWritePathOk()
end

function ClsPlayersDetailData:initFileName()
    self.m_my_uid = getGameData():getPlayerData():getUid() or 0
    self.m_lua_file_name = string.format("player_detail_info_bak_%d_v%d", self.m_my_uid, BAK_VERSION)
    local write_path = CCFileUtils:sharedFileUtils():getWritablePath()
    self.m_write_path = string.format("%sdhh.game.qtz.com", write_path)
    self.m_lua_file_path = string.format("%s/%s.lua", self.m_write_path, self.m_lua_file_name)
end

function ClsPlayersDetailData:setIsGoExplore(is_go)
    self.m_is_go_explore = is_go
end

function ClsPlayersDetailData:clearStackById(stack_id)
    if stack_id then
        if self.m_stack.top > stack_id then
             self.m_stack.array[stack_id] = 0
        end
    end
end

function ClsPlayersDetailData:putStack(uid)
    local top = self.m_stack.top
    self.m_stack.array[top] = uid
    self.m_stack.top = top + 1
    return top
end

function ClsPlayersDetailData:makeWritePathOk()
    local file_info = lfs.attributes(self.m_write_path)
    if not file_info then
        lfs.mkdir(self.m_write_path)
    end
end

function ClsPlayersDetailData:removeBakFile()
    if CCFileUtils:sharedFileUtils():isFileExist(self.m_lua_file_path) then
        os.remove(self.m_lua_file_path)
    end
end

function ClsPlayersDetailData:getEncodeStr(raw_str)
	if type(raw_str) == "string" then
		if string.len(raw_str) > 0 then
			return string.gsub(raw_str, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
		end
	end
	return ""
end

function ClsPlayersDetailData:getDecodeStr(raw_str)
	if type(raw_str) == "string" then
		if string.len(raw_str) > 0 then
			return string.gsub(raw_str, '%%(%x%x)', function(c) return string.char(tonumber(c, 16)) end)
		end
	end
	return ""
end

function ClsPlayersDetailData:tryToLoadLoaclPlayersInfo()
	if self.m_stack.is_load_file then
		return
	end
	self.m_is_go_explore = false
	self.m_stack.is_load_file = true
	self:initFileName()
	if CCFileUtils:sharedFileUtils():isFileExist(self.m_lua_file_path) then
		xpcall(function()
				local bak_info = require(self.m_lua_file_name)
				if type(bak_info) ~= "table" then
					self:removeBakFile()
					return
				end
				if bak_info.version == BAK_VERSION then
					local data_array = bak_info.data
					local uid = 0
					local stack_id = 0
					len_n = #data_array
					for i = len_n, 1, -1 do
						local v = data_array[i]
						uid = v[1]
						if self.m_player_info[uid] then
							self:clearStackById(self.m_player_info[uid][INFO_ID.STACK_ID])
						end
						stack_id = self:putStack(uid)
						self.m_player_info[uid] = {
							[INFO_ID.NAME] = self:getDecodeStr(v[FILE_INFO_ID.NAME_ENCODE]),
							[INFO_ID.NAME_ENCODE] = v[FILE_INFO_ID.NAME_ENCODE],
							[INFO_ID.LV] = v[FILE_INFO_ID.LV],
							[INFO_ID.ROLE_ID] = v[FILE_INFO_ID.ROLE_ID],
							[INFO_ID.ICON] = v[FILE_INFO_ID.ICON],
							[INFO_ID.SHIP_ID] = v[FILE_INFO_ID.SHIP_ID],
							[INFO_ID.NOBILITY] = v[FILE_INFO_ID.NOBILITY],
							[INFO_ID.TITLE] = v[FILE_INFO_ID.TITLE],
							[INFO_ID.GUILD_NAME] = self:getDecodeStr(v[FILE_INFO_ID.GUILD_NAME_ENCODE]),
							[INFO_ID.GUILD_NAME_ENCODE] = v[FILE_INFO_ID.GUILD_NAME_ENCODE],
							[INFO_ID.GUILD_JOB] = v[FILE_INFO_ID.GUILD_JOB],
							[INFO_ID.GUILD_ICON] = v[FILE_INFO_ID.GUILD_ICON],
							[INFO_ID.VERSION] = v[FILE_INFO_ID.VERSION],
							[INFO_ID.STACK_ID] = stack_id ,
						}
					end
				else
					self:removeBakFile()
				end
			end, function(error_msg)
				self:removeBakFile()
				__G__TRACKBACK__(error_msg)
			end)
	end
end

local head_str = "local infos = {version = %d, \ndata = {"
local item_str = "[%d] = {%d,     '%s',%d,%d,%d,%d,%d,'%s','%s',%d, '%s' ,%d},\n"
local tail_str = "}}\n    return infos"
function ClsPlayersDetailData:tryToSaveBakPlayerInfo()
    if not self.m_is_go_explore or GTab.IS_VERIFY then
        return
    end
    self.m_is_go_explore = false
    self:initFileName()
    self:removeBakFile()
    local bak_file = nil
    xpcall(function()
            bak_file = io.open(self.m_lua_file_path, "w")
            if not bak_file then
                return
            end
            local string_format = string.format
            local string_gsub = string.gsub
            bak_file:write(string_format(head_str, BAK_VERSION))
            local array = self.m_stack.array
            local len_n = self.m_stack.top - 1
            if len_n >= 1 then
                local count_n = 0
                local uid = 0
                for i = len_n, 1, -1 do
                    uid = array[i]
                    if uid and uid > 0 then
                        local player_info  = self.m_player_info[uid]
                        if player_info then
                            count_n = count_n + 1
                            bak_file:write(
                                string_format(
                                    item_str,
                                    count_n,
                                    uid,
                                    player_info[INFO_ID.NAME_ENCODE],
                                    player_info[INFO_ID.LV],
                                    player_info[INFO_ID.ROLE_ID],
                                    player_info[INFO_ID.ICON],
                                    player_info[INFO_ID.SHIP_ID],
                                    player_info[INFO_ID.NOBILITY],
                                    player_info[INFO_ID.TITLE],
                                    player_info[INFO_ID.GUILD_NAME_ENCODE],
                                    player_info[INFO_ID.GUILD_JOB],
                                    player_info[INFO_ID.GUILD_ICON],
                                    player_info[INFO_ID.VERSION])
                                )
                        end
                    end
                    if count_n >= MAX_SAVE_ITEM_COUNT then
                        break
                    end
                end
            end
            bak_file:write(tail_str)
            bak_file:close()
            bak_file = nil
        end, function(error_msg)
            if bak_file then
                bak_file:close()
            end
            self:removeBakFile()
            __G__TRACKBACK__(error_msg)
        end)
end

function ClsPlayersDetailData:getPlayerInfo(uid)
	return self.m_player_info[uid]
end

function ClsPlayersDetailData:addPlayerInfo(uid, info)
	local player_info = self.m_player_info[uid]
	if player_info then
		self:clearStackById(player_info[INFO_ID.STACK_ID])
	end
	local stack_id = self:putStack(uid)
	self.m_player_info[uid] = {
		[INFO_ID.NAME] = info.name,
		[INFO_ID.NAME_ENCODE] = self:getEncodeStr(info.name),
		[INFO_ID.LV] = info.level,
		[INFO_ID.ROLE_ID] = info.roleId,
		[INFO_ID.ICON] = info.icon,
		[INFO_ID.SHIP_ID] = info.boatT,
		[INFO_ID.NOBILITY] = info.nobility,
		[INFO_ID.TITLE] = info.title,
		[INFO_ID.GUILD_NAME] = info.group_name,
		[INFO_ID.GUILD_NAME_ENCODE] = self:getEncodeStr(info.group_name),
		[INFO_ID.GUILD_JOB] = info.group_job,
		[INFO_ID.GUILD_ICON] = tostring(info.group_icon),
		[INFO_ID.VERSION] = info.version,
		[INFO_ID.STACK_ID] = stack_id,
	}
	getGameData():getExplorePlayerShipsData():updatePlayerDetailInfo(uid)
	
end

function ClsPlayersDetailData:getPlayerInfoWithKey(uid, key)
	local info = self.m_player_info[uid]
	if info then
		return info[key]
	end
end

function ClsPlayersDetailData:getPlayerLv(uid)
	return self:getPlayerInfoWithKey(uid, INFO_ID.LV)
end

function ClsPlayersDetailData:getPlayerRoleId(uid)
	return self:getPlayerInfoWithKey(uid, INFO_ID.ROLE_ID)
end

function ClsPlayersDetailData:getPlayerIcon(uid)
	return self:getPlayerInfoWithKey(uid, INFO_ID.ICON)
end

function ClsPlayersDetailData:getPlayerName(uid)
	return self:getPlayerInfoWithKey(uid, INFO_ID.NAME)
end

function ClsPlayersDetailData:getPlayerShipId(uid)
    return self:getPlayerInfoWithKey(uid, INFO_ID.SHIP_ID)
end

function ClsPlayersDetailData:getPlayerGuildName(uid)
    return self:getPlayerInfoWithKey( uid, INFO_ID.GUILD_NAME )
    -- return T("测试商会名")
end

function ClsPlayersDetailData:getPlayerGuildJob(uid)
    return self:getPlayerInfoWithKey( uid, INFO_ID.GUILD_JOB )
    -- return T("测试商会职位")
end

function ClsPlayersDetailData:getPlayerGuildIcon(uid)
    return self:getPlayerInfoWithKey( uid, INFO_ID.GUILD_ICON )
end

function ClsPlayersDetailData:getPlayerTitle(uid)
    local title_str = self:getPlayerInfoWithKey(uid, INFO_ID.TITLE)
    if not title_str then
        return
    end
    local index = string.find(title_str, ":")
    local title_id = nil
    local arg_number = 0
    local args = {}
    if index then
        title_id = tonumber(string.sub(title_str, 1, index - 1))
        local title_param_str = string.sub(title_str, index + 1)
        arg_number = 1
        index = string.find(title_param_str, ",")
        if index then
            arg_number = 2
            args[1] = string.sub(title_param_str, 1, index - 1)
            args[2] = string.sub(title_param_str, index + 1)
        else
            args[1] = title_param_str
        end
    else
        title_id = tonumber(title_str)
    end
    local title_info = dataTools:getTitle(title_id)
    
    if title_info then
        title_info.title_id = title_id
        local t_performance = string.split(title_info.performance, "|")
        if arg_number >= 1 then
            title_info.performance = ""
            for i = 1, arg_number do
                title_info.performance = title_info.performance .. string.format(t_performance[i], args[i])
            end
        end
        return title_info
    end
end

function ClsPlayersDetailData:getPlayerInfoVersion(uid)
	return self:getPlayerInfoWithKey(uid, INFO_ID.VERSION) or -1
end

function ClsPlayersDetailData:getPlayerInfoNobility(uid)
	return self:getPlayerInfoWithKey(uid, INFO_ID.NOBILITY)
end

return ClsPlayersDetailData

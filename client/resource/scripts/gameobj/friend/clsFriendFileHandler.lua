
local ClsFriendFileHandler = class("ClsFriendFileHandler")

function ClsFriendFileHandler:ctor(platform)
    self.platform = platform
	--用来存储指定图片下载的时间
	--[10010] = 123445555
	self.time_list = {}
	self.m_dir = nil
	self.m_time_list_path = nil

	self:initFileInfo()
end

function ClsFriendFileHandler:initFileInfo()
    local write_path = CCFileUtils:sharedFileUtils():getWritablePath()
   	self.m_dir = string.format("%sdhh.game.qtz.com", write_path)
    local folder = "qq"
    if self.platform == PLATFORM_WEIXIN then
        folder = "wechat"
    end
   	self.m_time_list_path = string.format("%s/%s/%s.lua", self.m_dir, folder, "loadtime")
end

function ClsFriendFileHandler:isExistFile(file_name)
	return CCFileUtils:sharedFileUtils():isFileExist(file_name)
end

function ClsFriendFileHandler:removeTimeList()
	if self:isExistFile(self.m_time_list_path) then
        os.remove(self.m_time_list_path)
    end
end

function ClsFriendFileHandler:loadTimeList()
    if GTab.IS_VERIFY then return end
	if self.loading_list then return cclog("正在载入") end
	self.loading_list = true

    self:initFileInfo()

    if self:isExistFile(self.m_time_list_path) then
        xpcall(function()
        	local file = io.open(self.m_time_list_path, "r")
        	if not file then
        		return
        	end

            local str = string.format("return {%s}", file:read("*a"))
            self.time_list = {}
            for k, v in pairs(loadstring(str)()) do
            	self.time_list[k] = v
            end

        end, function(error_msg)
        	self:removeTimeList()
            __G__TRACKBACK__(error_msg)
        end)
    end
end

local base_format = "[%d] = %d,\n"
function ClsFriendFileHandler:writeTimeToList()
    if GTab.IS_VERIFY then return end
	self:initFileInfo()

    local time_file = nil
    xpcall(function()
        time_file = io.open(self.m_time_list_path, "w")
        if not time_file then
        	cclog("打开文件失败")
            return
        end

        cclog("打开文件成功")
        for k, v in pairs(self.time_list) do
       		time_file:write(string.format(base_format, k, v))
       	end

        time_file:close()
        time_file = nil
    end, function(error_msg)
        if time_file then
            time_file:close()
        end

        self:removeTimeList()
        __G__TRACKBACK__(error_msg)
    end)
end

function ClsFriendFileHandler:setTimeToFile(uid, value)
	self.time_list[uid] = value
end

function ClsFriendFileHandler:getTimeFromFile(uid)
	return self.time_list[uid]
end

return ClsFriendFileHandler
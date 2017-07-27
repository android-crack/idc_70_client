-- 更新 版本信息、服务器列表等

local URLMgr = require("update/updateURLMgr")

local UserData = CCUserDefault:sharedUserDefault()


local UpdateInfo = {}


-- change string version to numbers version
-- eg: "1.0.0" => {1, 0, 0}
local function str2Tab(str)
	assert(type(str) == "string")
    local tab = {}
    for k, v in ipairs( string.split( str, "." ) ) do
        tab[k] = tonumber(v)
    end
    return tab
end 


local function compareVersion( v1, v2 )
    assert( type( v1 ) == "table" and type( v2 ) == "table" )
    local result = 0
    for i = 1, 3 do
        if v1[i] > v2[i] then
            result = i
        end
        if v1[i] < v2[i] then
            result = -i
        end
        
        if result ~= 0 then
            break
        end
    end
    return result
end

-- ios launch 功能
local function initLaunchForIos()
	local url = CCConfiguration:sharedConfiguration():getCString("update_info_url", "")
	if url ~= "" then 
		device.showAlert("updateInfo", url)
		GTab.BASE_UPDATE_RUL = url
	end 
end

-- 读android 本地配置
local function initAndroidFromLocal()
	local path = CCFileUtils:sharedFileUtils():getSDcardPath()
	local file = string.format("%s/dhh.json", path)
	if fileExist(file) then 
		local data = loadJsonFromFile(file)
		if data and data.update_info_url then
			GTab.BASE_UPDATE_RUL = data.update_info_url	
		end 
	end
end 

function UpdateInfo:start(checkVersionHandler, stepHandler, finishHandler, errHandler)
	if self.is_start then 
		return 
	end 

	if device.platform == "ios" then 
		initLaunchForIos()
	elseif device.platform == "android" then
		initAndroidFromLocal()
	end 
	
	self._checkVersionHandler = checkVersionHandler
	self._stepHandler = stepHandler
	self._finishHandler = finishHandler
	self._errHandler = errHandler
	
	self.is_start = true
	self.info_file = GTab.BASE_UPDATE_INFO
	
	
	self:checkVersionBetweenPackageAndUpdate()
	self:updateInfoFile()
end 

function UpdateInfo:finsh()
	self.is_start = false
end 

function UpdateInfo:checkVersionHandler(num)
	self._checkVersionHandler(num)
end 

function UpdateInfo:stepHandler()
	self._stepHandler()
end 

function UpdateInfo:finishHandler()
	self._finishHandler()
	GTab.VERSION_UPDATE = GTab.VERSION_SERVER
    UserData:setStringForKey( "version", GTab.VERSION_UPDATE)
	self:finsh()
end 

function UpdateInfo:errHandler()
	self._errHandler()
	self:finsh()
end 

function UpdateInfo:checkVersionBetweenPackageAndUpdate()
    local package_version   = str2Tab(GTab.VERSION_PACK)
    local update_version    = str2Tab(GTab.VERSION_UPDATE)
    if compareVersion( package_version, update_version ) > 0 then
        removeDir( GTab.UPDATE_RES_PATH )
		GTab.VERSION_UPDATE = GTab.VERSION_PACK
        UserData:setStringForKey( "version", GTab.VERSION_PACK )
    end
end

-- todo 返回码是否确定下载完整？
function UpdateInfo:updateInfoFile()
	local info_url = URLMgr:getUpdateInfoURL()
	local function callback(success, response)
		if success then 
			local data = json.decode( response )
			-- 数据解析错误
			if data == nil then 
				return self:errHandler()
			end 
			self:loadInfoFile(data)
		
			return self:checkVersion()
		end 
		self:errHandler()
	end 
	
	http.download(info_url, nil, callback)
end

-- TODO 腾讯测试工具
function UpdateInfo:reloadUpdateInfoFromLocal()
	local path = ""
	if device.platform == "android" then
		path = CCFileUtils:sharedFileUtils():getSDcardPath()
	else
		path = CCFileUtils:sharedFileUtils():getWritablePath()
	end
	local file = string.format("%s/updateInfo.json", path)
	
	if fileExist(file) then 
		print("读取本地json")
		local info_data = loadJsonFromFile(file)
		if info_data == nil then 
			print("UpdateInfo:reloadUpdateInfoFromLocal info_data is nil！！！")
			return 
		end 
		
		if info_data.game_server then 
			GTab.SERVER_LIST = info_data.game_server
		end 
		
		if info_data.resource_url then 
			GTab.RESOURCE_URL = info_data.resource_url
		end 
		self.tencent_test = true
		--self:loadInfoFile(data)
	end 
end 

function UpdateInfo:loadInfoFile(data)
	if data == nil then
		print("UpdateInfo:loadInfoFile(data) data is nil！！！")
		return 
	end 
	
	local info_data = data
	-- 全局变量
	GTab.VERSION_SERVER = info_data.version 
	GTab.SERVER_LIST = info_data.game_server
	GTab.RESOURCE_URL = info_data.resource_url
	GTab.SPEED_URL = info_data.speed_url
	
	-- 审核服相关
	GTab.VERIFY_APP_VERSION = info_data.verify_app_version
	GTab.VERIFY_VERSION = info_data.verify_version
	GTab.VERIFY_RESOURCE_URL = info_data.verify_resource_url
	GTab.VERIFY_SERVER_LIST = info_data.verify_game_server
	
	-- 允许最小app版本更新
	GTab.MIN_APP_VERSION = info_data.min_app_version
	GTab.APP_URL = info_data.app_url
	
	-- filelist md5
	GTab.FILELIST_MD5 = info_data.filelist_md5
	
	-- 当前版本处于审核版本
	if GTab.VERIFY_APP_VERSION and GTab.VERIFY_APP_VERSION == GTab.APP_VERSION then 
		GTab.IS_VERIFY = true 
		GTab.VERSION_SERVER = GTab.VERIFY_VERSION 
		GTab.SERVER_LIST = GTab.VERIFY_SERVER_LIST
		GTab.RESOURCE_URL = GTab.VERIFY_RESOURCE_URL
		GTab.FILELIST_MD5 = info_data.verify_filelist_md5
	end 
end

function UpdateInfo:checkVersion()
	-- 低于最低版本，必须更新app
	if GTab.MIN_APP_VERSION and compareVersion(str2Tab(GTab.MIN_APP_VERSION), str2Tab(GTab.APP_VERSION)) > 0 then
		local alert = require("update/updateAlert")
		return alert:updateApp()
	end

	local local_version =  str2Tab(GTab.VERSION_UPDATE) 
	local server_version = str2Tab(GTab.VERSION_SERVER) 
	local ret = compareVersion( local_version, server_version )
	
	-- 没有更新地址
	if GTab.RESOURCE_URL == nil or GTab.RESOURCE_URL == "" then
		return self:finishHandler()
	end 
	
	-- 内部开发不走版本号更新
	if GTab.CHANNEL_ID == "debug" or self.tencent_test then
		return self:updatePatch()
	end

	-- 版本相同, 不需要更新
	if ret == 0 then
		return self:finishHandler()
	end
	
	-- 本地版本大于服务器版本
	if ret > 0 then
		removeDir( GTab.UPDATE_RES_PATH )
	end
	
	self:updatePatch()

end

function UpdateInfo:updatePatch()
	require("update/updatePatch"):start(UpdateInfo)
end 

return UpdateInfo

-- 更新patch

local URLMgr = require("update/updateURLMgr")
local UpdatePatch = {}

function UpdatePatch:start(UpdateInfo)
	if self.is_start then 
		return 
	end 

	self._UpdateInfo = UpdateInfo
	self.is_start = true
	self:updateFileList()
end 

function UpdatePatch:checkVersionHandler(num)
	self._UpdateInfo:checkVersionHandler(num)
end 

function UpdatePatch:stepHandler()
	self._UpdateInfo:stepHandler()
end 

function UpdatePatch:finishHandler()
	self.is_start = false
	local new_name = string.format("%s/%s",  GTab.UPDATE_RES_PATH, GTab.FILELIST)
	local old_name = string.format("%s/%s",  GTab.UPDATE_TMP_PATH, GTab.FILELIST)
	renameDir(old_name, new_name)
	self._UpdateInfo:finishHandler()
end 

function UpdatePatch:errHandler()
	self.is_start = false
	self._UpdateInfo:errHandler()
end 

function UpdatePatch:updateFileList()
	removeDir( GTab.UPDATE_TMP_PATH )
	
	local file_name = GTab.FILELIST
	local md5 = GTab.FILELIST_MD5
	
	local full_path = string.format("%s/%s",  GTab.UPDATE_TMP_PATH, file_name)
	local url = URLMgr:getPatchURLByMd5(file_name, md5)
	
	self.need_update_files = {}
	
	local function callback(success) 
		if not success or GTab.FILELIST_MD5 ~= calMd5ByPath(full_path) then 
			return self:errHandler() 
		end 
		
		local local_file = string.gsub(file_name, ".lua", "")
		local server_file = string.format("%s/%s", GTab.TMP_PATH, local_file)
		local local_list = require(local_file)
		local server_list = require(server_file)
		local download_size = 0
		
		for k, v in pairs(server_list) do
			if local_list[k] == nil or v.md5 ~= local_list[k].md5 then 
				local need_udpate = true
				-- 过滤平台音乐
				if device.platform == "ios" then
					if string.sub(k, -4, -1) == ".mp3" or string.sub(k, -4, -1) == ".ogg" then
						need_udpate = false
					end
				end

				if device.platform == "android" then
					if string.sub(k, -4, -1) == ".mp3" or string.sub(k, -4, -1)== ".m4a" then
						need_udpate = false
					end
				end
			
				if need_udpate then 
					download_size = download_size + v.size
					local value = {path = k, md5 = v.md5, file_size = v.size}
					table.insert(self.need_update_files, value)
				end 
				
			end 
		end 
		
		local num = #self.need_update_files
		if num <= 0 then 
			return self:finishHandler()
		else
			local function start()
				self:checkVersionHandler(num)
				self:updateFiles()
			end 	
			local alert = require("update/updateAlert")
			alert:updatePatch(start, download_size)
		end 
	end 
	
	http.download(url, full_path, callback)
end 

function UpdatePatch:updateFiles()
	local file = table.remove(self.need_update_files, 1 )
	if file == nil then 
		return self:finishHandler()
	end 
	
	self:stepHandler()
	local full_path = string.format("%s/%s", GTab.UPDATE_RES_PATH, file.path)
	-- 过滤已下载的
	if calMd5ByPath(full_path) == file.md5 then 
		return self:updateFiles()
	end 
	 
	local url = URLMgr:getPatchURLByMd5(file.path, file.md5)
	
	local function callback(success)
		if not success or calMd5ByPath(full_path) ~= file.md5 then 
			return self:errHandler() 
		end 
		
		self:updateFiles()
	end 
	
	http.download(url, full_path, callback)
end 


return UpdatePatch

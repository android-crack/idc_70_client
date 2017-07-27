-- 更新 fixs，用于后门修复，一般情况不会用到
local hotfix = {}


function hotfix:start(callback)
	if self.is_start then 
		return 
	end 
	self.callback = callback
	self.is_start = true
	self:updateFixsInfo()
end 

-- 下载fix失败都是直接跳到更新
function hotfix:finsh()
	self.is_start = false
	
	if self.callback then 
		self.callback()
	end 
end 

-- 下载fixinfo 并require
function hotfix:updateFixsInfo()
	if GTab.BASE_FIX_URL == nil or GTab.BASE_FIX_INFO == nil then 
		return self:finsh()
	end 
	
	local full_path = string.format("%s/%s", GTab.UPDATE_RES_PATH, GTab.BASE_FIX_INFO)
	local url =  string.format("%s/%s?v=%s", GTab.BASE_FIX_URL, GTab.BASE_FIX_INFO, os.time())
	
	local function callback(success)
		if success then 
			local fix_file = string.gsub(GTab.BASE_FIX_INFO, ".lua", "")
			-- 判断是否下载完整
			if pcall( function() require(fix_file) end) then 
				local fix_info = require(fix_file)
				
				if type(fix_info) == "table" and fix_info.filelist then 
					self.need_fix_files = {}
					for k, v in pairs(fix_info.filelist) do
						table.insert(self.need_fix_files, {path = k, md5 = v})
					end 
					return self:updateFiles()
				end 
			end 
		end 
		self:finsh()
	end 
	
	http.download(url, full_path, callback)
end 

function hotfix:getFileUrl(file)
	local url = string.format("%s/%s.%s?v=%s", GTab.BASE_FIX_URL, file.path, file.md5, os.time())
	return url
end 

-- 下载 fixlist
function hotfix:updateFiles()
	local file = table.remove(self.need_fix_files, 1 )
	if file == nil then 
		return self:finsh()
	end 

	local full_path = string.format("%s/%s", GTab.UPDATE_RES_PATH, file.path)	
	local url = self:getFileUrl(file)
	
	if file.md5 and calMd5ByPath(full_path) == file.md5 then 
		return self:updateFiles()
	end 
	
	local function callback(success)
		if success then 
			self:updateFiles()
		else 
			self:finsh()
		end 
	end 
	
	http.download(url, full_path, callback)
end 


return hotfix

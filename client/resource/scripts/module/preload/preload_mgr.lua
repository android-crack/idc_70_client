local preload_mgr = { }

--------------
--[[
loadTable = {
	[plist] = {
		["path"] = true,
		["path"] = true,
		...,
	},
	[armature] = {
		["path"] = true,
		["path"] = true,
		...,
	},
	["particle"] = {
		["path"] = true,
		["path"] = true,
		...,	
	}
	
}
--]]
--------------
preload_mgr.particle_plist_buff = {
	--["plist_path"] = plist_dict,
	--["plist_path"] = plist_dict,
	--...
}
--------------


--获取文件名
local function strippath(filename)
	return string.match(filename, ".+/([^/]*%.%w+)$")
end


preload_mgr.load3dRes = function(loadTable)
	if loadTable.model_3d then
		for path, _ in pairs(loadTable.model_3d) do
			--print("model_3d:",path)
			local node_ext_name = strippath(path)
			local node_name = string.gsub(node_ext_name, GPB_EXT, "")		
			ResourceManager:CacheModel(path, node_name)
		end
		
		for path, _ in pairs(loadTable.propertiesfile_3d) do
			--print("propertiesfile_3d:",path)
			ResourceManager:CachePropertiesFile(path)			
		end
		
		for path, value in pairs(loadTable.particleemitter_3d) do
			--print("particleemitter_3d:",path)
			ResourceManager:CacheParticleEmitter(path, value)			
		end
		
		for path, _ in pairs(loadTable.texture_3d) do
			--print("texture_3d:",path)
			ResourceManager:CacheTexute3d(path)
		end
	end
end


preload_mgr.asyncLoadRes = function(loadTable, callBack)

	--2d
	local resourceMgr = QResourceManager:sharedResourceManager()
	local current = 0
	local count = 0
	local function asyncLoadResCallback()
		current = current + 1
		-- if current == count and loadTable.plist then 
		-- 	LoadPlist(loadTable.plist, true)
		-- end 
		if callBack then
			callBack(current, count)
		end
	end

	--统计下载文件总数
	for preload_type, preload_list in pairs(loadTable) do
		if	preload_type ~= "propertiesfile_3d" and
			preload_type ~= "model_3d" and
            preload_type ~= "particleemitter_3d" and
			preload_type ~= "texture_3d" 
		then
			for idx,  path in pairs(preload_list) do
				count = count + 1
			end
		end
	end
	
	if count < 1 then 
		if callBack then
			callBack(1, 1)
		end
		return
	end 
	
	if callBack then
		callBack(current, count)
	end
	--先加载3d资源
	preload_mgr.load3dRes(loadTable)

	--预加载plist
	--[[
	if loadTable.plist then
		for path, v in pairs(loadTable.plist) do
			local texture_format = TextureFormat[v] or -1
			resourceMgr:loadPlistFileAsync( path, asyncLoadResCallback, texture_format)
		end
	end

	if loadTable.armature then
		for path, V in pairs(loadTable.armature) do
			local texture_format = TextureFormat[v] or -1
			resourceMgr:loadArmatureFileAsync( path, asyncLoadResCallback, texture_format)
		end
	end

	if loadTable.image then 
		for path, v in pairs(loadTable.image) do
			texture_format = TextureFormat[v] or -1
			resourceMgr:loadImageFileAsync(path, asyncLoadResCallback, texture_format)
		end
	end 
	--]]
	
	-- 同步
	local res_tab = {}
	if loadTable.plist then
		for path, v in pairs(loadTable.plist) do
			local texture_format = TextureFormat[v] or -1
			table.insert(res_tab, {path = path, texture_format = texture_format, type = "plist"})
			--resourceMgr:loadPlistFileAsync( path, asyncLoadResCallback, texture_format)
		end
	end

	if loadTable.armature then
		for path, V in pairs(loadTable.armature) do
			local texture_format = TextureFormat[v] or -1
			table.insert(res_tab, {path = path, texture_format = texture_format, type = "armature"})
			--resourceMgr:loadArmatureFileAsync( path, asyncLoadResCallback, texture_format)
		end
	end

	if loadTable.image then 
		for path, v in pairs(loadTable.image) do
			texture_format = TextureFormat[v] or -1
			table.insert(res_tab, {path = path, texture_format = texture_format, type = "image"})
			--resourceMgr:loadImageFileAsync(path, asyncLoadResCallback, texture_format)
		end
	end 
	
	local function step()
		local v = table.remove(res_tab)
		if v == nil then return end 
		
		if v.type == "plist" then 
			LoadPlist({[v.path] = v.texture_format})
		elseif v.type == "armature" then 
			LoadArmature({v.path})
		elseif v.type == "image" then 
			LoadImages({[v.path] = v.texture_format})
		end 
		asyncLoadResCallback()
		require("framework.scheduler").performWithDelayGlobal(step, 0)
	end 
	step()
end


preload_mgr.clearPreLoad = function (loadTable)
	
	if loadTable.armature then 
		for path, _ in pairs(loadTable.armature) do
			UnLoadArmature(path)
		end
	end
	
	if loadTable.plist then
		UnLoadPlist(loadTable.plist)
	end
	
	if loadTable.image then 
		UnLoadImages(loadTable.image)
	end 
	
	ReleaseTexture()
end


return preload_mgr


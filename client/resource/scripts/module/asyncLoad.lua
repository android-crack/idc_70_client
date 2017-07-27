local handle = { }

--------------
--[[
loadTable = {
	[plist] = {
		[1] = "path",
		[2] = "path",
		...,
	},
	[armature] = {
		[1] = "path",
		[2] = "path",
		...,
	},

}
--]]
--------------
handle.asyncLoadRes = function(loadTable, callBack)
	local resourceMgr = QResourceManager:sharedResourceManager()
	local current = 0
	local count = 0
	function asyncLoadResCallback()
		current = current + 1
		if current == count then
			resourceMgr:stop()
		end
		if callBack then
			callBack(current, count)
		end
	end

	--统计下载文件总数
	for preload_type, preload_list in pairs(loadTable) do
		for idx,  path in pairs(preload_list) do
			count = count + 1
		end
	end
	resourceMgr:stop()
	resourceMgr:start()


	--预加载plist
	if loadTable.plist then
		for key,path in pairs(loadTable.plist) do
			resourceMgr:loadPlistFileAsync( path, TEXTURE_FORMAT.default, TEXTURE_FORMAT.default, asyncLoadResCallback)
		end
	end


	if loadTable.armature then
		for key,value in pairs(loadTable.armature) do
			resourceMgr:loadArmatureFileAsync( value, TEXTURE_FORMAT.default, TEXTURE_FORMAT.default, asyncLoadResCallback)
		end
	end
end
return handle


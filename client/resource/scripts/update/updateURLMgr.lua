-- 更新 url

local UpdateURLMgr = {}


function UpdateURLMgr:getUpdateInfoURL()
	return string.format("%s/%s?v=%s", GTab.BASE_UPDATE_RUL, GTab.BASE_UPDATE_INFO, os.time())
end 

function UpdateURLMgr:getPatchURLByMd5(path, md5)
	return string.format("%s/%s.%s?v=%s", GTab.RESOURCE_URL[1].url,path, md5, GTab.VERSION_SERVER)	
end

return UpdateURLMgr
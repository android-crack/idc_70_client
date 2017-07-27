-- 最基础的函数，和任何玩法无法


-- 删除文件目录
function removeDir( dir )
    local fileInfo = lfs.attributes( dir )

    if not fileInfo then
        return
    end

    if fileInfo["mode"] == "directory" then
        for file in lfs.dir( dir ) do
            if file ~= "." and file ~= ".." then
                local file = string.format( "%s/%s", dir, file ) 
                local info = lfs.attributes( file ) 
                if info["mode"] == "directory" then
                    removeDir( file )
                elseif info["mode"]  == "file" then
                    os.remove( file ) 
                end
            end
        end
        lfs.rmdir( dir )
    elseif fileInfo["mode"] == "file" then
        os.remove( dir )
    end
end

-- 判断文件是否存在
function fileExist(path)
	return CCFileUtils:sharedFileUtils():isFileExist(path)
end

function renameDir(oldName, newName)
	if fileExist(newName) then 
		os.remove(newName)
	end 
	os.rename(oldName, newName)
end 

-- 根据文件目录计算md5
function calMd5ByPath(path)
	if not fileExist(path) then return false end 
	return CCCrypto:MD5LuaWithFile(path, false)
end 


-- 通告栏
function getNotification()
	local notification_node = CCDirector:sharedDirector():getNotificationNode()
    if tolua.isnull(notification_node) then 
        notification_node = CCNode:create()
        CCDirector:sharedDirector():setNotificationNode(notification_node)
    end 
    return notification_node
end


function loadJsonFromFile(file_path)
	local full_path = CCFileUtils:sharedFileUtils():fullPathForFilename(file_path)	
	if (full_path == nil) then
		cclog("No such file : "..file_path)
		return
	end
	local jstr = CCString:createWithContentsOfFileExt(file_path)
	return json.decode(jstr:getCString())
end





function rpc_client_release_error(ret, err)

end

function rpc_client_patch_code(luaCode)
	local tb=assert(loadstring(luaCode))() 
end
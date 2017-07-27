function rpc_client_update_pto_str(bytes)
	pto = json.decode(bytes)
	CLASS_CFG = pto["class_cfg"]
	FUNCTION_CFG = pto["function_cfg"]
	wrapServerFunc()
end

function rpc_client_uid_list(uidList, _type)
	uid = uidList[1]["uid"]
	print("login to uid:", uid)
	SERVER_FUNC["rpc_server_login"](uid);
end

function rpc_client_use_login_key_return(obj)
	if obj["result"] ~= 0 then
		print("use login key error:", dump(obj))
	end
end



-- void rpc_client_user_status_info(int uid, string statusId, int timeout, string status_data);
function rpc_client_user_status_info(status_id, timeout, status_data)
	local info = {}
	info.status_id = status_id
	info.timeout = timeout
	info.status_data = json.decode(status_data)
	info.clock_time = os.clock()
	getGameData():getBuffStateData():addBuffState(info)
end

-- void rpc_client_user_status_del(int uid, string statusId);
function rpc_client_user_status_del(status_id)
	getGameData():getBuffStateData():removeBuffState(status_id)
end
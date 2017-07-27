function rpc_client_lose_found_list(list)
	if not list then return end
	getGameData():getGainBackData():setGainList(list)

	local gain_back_ui = getUIManager():get("ClsGainBackTab")
	if not tolua.isnull(gain_back_ui) then
		gain_back_ui:updateView()
	end
end
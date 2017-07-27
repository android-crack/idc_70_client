local element_mgr = require("base/element_mgr")
local music_info = require("game_config/music_info")
local error_info = require("game_config/error_info")
local port_info = require("game_config/port/port_info")
local Alert = require("ui/tools/alert")
local expbuff_data = require("game_config/exp_buff/expbuff_data")
require("gameobj/mainScene")
local ModuleDataHandle = require("module/dataManager")

--服务器下发协议弹出选择角色
function rpc_client_show_select_role(account)
	local playerData = getGameData():getPlayerData()
	playerData:setAccount(account)
	require("gameobj/selectRole3d/clsSelectRole3dUi")
	loadSelectRoleView()
end

function rpc_client_show_role_list(account, role_list)
	local playerData = getGameData():getPlayerData()
	playerData:setAccount(account)
	playerData:setRoleList(role_list)
	require("gameobj/selectRole3d/clsSelectRole3dUi")
	loadSelectRoleView()
end

function rpc_client_user_point(kind, value, max)
	local playerData = getGameData():getPlayerData()
	-- if kind == TYPE_PROSPERITY then
	--  服务端完全没有这个，但是遗迹有调用的地方，这里遗迹的代码待整理
	-- 	local captainInfoData = getGameData():getCaptainInfoData()
	-- 	captainInfoData:setProsperity(value)
	if kind == TYPE_BATTLE_POWER then
		playerData:setBattlePower(value)
	else
		playerData:receivePlayerAttribute(kind, value, max)
	end
end

function rpc_client_login_result(result, errno)
	if errno ~= 0 then
		local _msg = error_info[errno].message
		if result == 1 then
			local login = require("module/login/loginBase")
			login.showReLink(_msg, true)
		else
			Alert:warning({msg = _msg})
		end
	else
		local element_mgr = require("base/element_mgr")
		local select_role_view = element_mgr:get_element("SelectRole")
		if not tolua.isnull(select_role_view) then
			select_role_view:shipRunning()
		end
	end
end

--[[ class user_info_t {icon; name;  int uid;}]]
function rpc_client_user_info(userInfo)
	--设置当前装备的称号
	local title_data = getGameData():getTitleData()
	title_data:setCurTitle(userInfo.title)

	if userInfo.boating then
		local partner_data = getGameData():getPartnerData()
		partner_data:receiveBoat(userInfo.boating, userInfo.boatId)
	end
	local playerData = getGameData():getPlayerData()
	-- 活动数据改为登陆的时候请求，而不是每次进港的时候请求
	local activityData = getGameData():getActivityData()
	activityData:requestActivityInfo()

	playerData:receivePlayerInfo(userInfo)
	playerData:askHuoDongLoginRewardInfo()
	playerData:askFriendList()
	playerData:askAchieveList()
	playerData:askPortExploreConsume()
	playerData:askMailInfo() --邮件信息
	playerData:askCollectRelicList() --遗迹信息
	playerData:askCheckPointOccupiedPorts()--请求被抢的港口信息
	local mapAttrs = getGameData():getWorldMapAttrsData()
	mapAttrs:getPortList()--已开放港口
	getGameData():getTeamData():askMyTeamInfo()
	local loot_data_handler = getGameData():getLootData()
	loot_data_handler:askRedNameInfo()

	local chat_date = getGameData():getChatData()
	chat_date:loadBlackFile() --加载黑名单
	chat_date:loadMsgFile()   --加载私聊信息

	local friend_data = getGameData():getFriendDataHandler()
	friend_data:loadUserInfo()

	local port_data = getGameData():getPortData()
	local market_data = getGameData():getMarketData()
	market_data:askStoreGoods(port_data:getPortId())
	market_data:askBoatGoodsInfo()
end

function rpc_client_user_set_role(result, err, role_id, name)  --设置角色
	if result == 1 then
		local playerData = getGameData():getPlayerData()
		playerData:setName(name)
		EventTrigger(EVENT_ROLE_SELECT, role_id)
	else
		local selectRoleUI = element_mgr:get_element("SelectRole")
		if not tolua.isnull(selectRoleUI) then
			selectRoleUI:rpcBack(err, role_id)
		end
	end
end

function rpc_client_user_add_ability(kind)  --系统开关
	local onOffData = getGameData():getOnOffData()
	onOffData:receiveOpen(kind)
	getGameData():getActivityData():setNewOpenListItem(kind)
end

function rpc_client_user_ability_list(list)
	local onOffData = getGameData():getOnOffData()
	onOffData:receiveOpens(list)
end

function rpc_client_sync_server_time(server_time) --设置前后端的时间差
	local client_time = os.time()
	local dx = server_time - client_time
	local playerData = getGameData():getPlayerData()
	playerData:setTimeDelta(dx, server_time)
end

--玩家名字更改
function rpc_client_modify_role_name(new_name, error)
	if error == 0 then
		local playerData = getGameData():getPlayerData()
		playerData:setName(new_name)
		local port_layer = getUIManager():get("ClsPortLayer")
		if not tolua.isnull(port_layer) then
			port_layer:setName(new_name)
		end
		local clsRoleInfoView = getUIManager():get("ClsRoleInfoView")
		if not tolua.isnull(clsRoleInfoView) then
			clsRoleInfoView:updateRoleName(new_name)
		end
		local ClsWeeklyRace = getUIManager():get("ClsWeeklyRace")
		if not tolua.isnull(ClsWeeklyRace) then
			local daily_activity_data = getGameData():getDailyActivityData()
			daily_activity_data:askWeeklyRaceRankList()   --排名
		end

	else
		local _msg = error_info[error].message
		Alert:warning({msg = _msg})
	end
end

function rpc_client_modify_name_time(remain_time)
	local clsRoleInfoView = getUIManager():get("ClsRoleInfoView")
	if not tolua.isnull(clsRoleInfoView) then
		if remain_time > 0 then
			getUIManager():create("gameobj/playerRole/clsNotRenameTips", nil, remain_time)
		else
			getUIManager():create("gameobj/playerRole/clsRenameTips")
		end
	end
end

-- 升级声望
function rpc_client_upgrade_effect( lv,new_value,old_value)
	lv = lv or 4
	local running_scene = GameUtil.getRunningScene()
	if tolua.isnull(running_scene) then return end
	local upgrade_alert = require("gameobj/quene/clsUpgradeAlert")
	local ClsUpgradeAlert = require("gameobj/quene/clsUpgradeAlert")
	local ClsDialogSequence = require("gameobj/quene/clsDialogQuene")
	ClsDialogSequence:insertTaskToQuene(ClsUpgradeAlert.new(lv,old_value - new_value))
end

--海神buff
function rpc_client_expbuff_info(buff_id)
	if buff_id and buff_id <= #expbuff_data then 
		getGameData():getPlayerData():setExpBuffStatus(buff_id)
	end
end

function rpc_client_boat_effects( effects )
	local player_data = getGameData():getPlayerData()
	player_data:setShipEffects(effects)
end

function rpc_client_user_raw_data( target, pystr)
	local write_path = CCFileUtils:sharedFileUtils():getWritablePath()
	local black_path = string.format("%sdhh.game.qtz.com", write_path)
	local name = string.format("%s/copy_user_%s.txt", black_path, target)
	local file, file_error = io.open(name, "w+")
	if file_error then
		file = io.output(name)
	end

	file:write(pystr)
	file:flush()
	file:close()
end

function rpc_client_user_raw_data_push_req(target)
	local write_path = CCFileUtils:sharedFileUtils():getWritablePath()
	local black_path = string.format("%sdhh.game.qtz.com", write_path)
	local name = string.format("%s/copy_user_%s.txt", black_path, target)
	local file, file_error = io.open(name, "r+")
	if file_error then
		Alert:showAttention(file_error)
		return
	end
	local pystr = file:read()
	file:flush()
	file:close()
	GameUtil.callRpc("rpc_server_user_raw_data_push", {pystr})
end
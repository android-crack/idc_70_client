local Alert = require("ui/tools/alert")
local ui_word = require("game_config/ui_word")
local error_info = require("game_config/error_info")
local news = require("game_config/news")

local function showAlert(error)
	local _msg = error_info[error].message
	Alert:warning({msg = _msg})
end

--访问好友的船信息
function rpc_client_friend_visit_boat_info(list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setTempFriendShip(list)
end

--请求加别人为好友的返回协议
function rpc_client_friend_add_request_result(uid, result, error)
	if result == 0 then
		local _msg = error_info[error].message
		Alert:warning({msg = _msg})
	else--请求加别人为好友成功
		Alert:warning({msg = ui_word.FRIEND_ADD_SUCCESSED})
		local main_ui = getUIManager():get("ClsFriendMainUI")
		if not tolua.isnull(main_ui) then 
			local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
			if not tolua.isnull(add_ui) then
				add_ui:updateAddBtnStatus(uid, 1)
			end
		end
	end
end

-- 点击通过后的结果
function rpc_client_friend_add_reply_result(uid, result, error)
	if result == 0 then
 		-- 移除数据
		local friend_data_handler = getGameData():getFriendDataHandler()
		friend_data_handler:deleteObj(DATA_APPLY, uid)

		-- 移除ui 上的 item
		local main_ui = getUIManager():get("ClsFriendMainUI")
		if not tolua.isnull(main_ui) then 
			local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
			if not tolua.isnull(add_ui) then
				add_ui:removeApplyCellByUid(uid)               
			end
		end

		local _msg = error_info[error].message
		Alert:warning({msg = _msg})
	end
end

--请求某人的信息下发协议
function rpc_client_friend_info(info)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:assembUserInfo(info)
end

--好友列表
function rpc_client_friend_list(list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:initFriendUidListByKey(list)
end

--申请列表
function rpc_client_friend_add_request_list(list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:initOtherUidListByKey(DATA_APPLY, list)
end

--别人的申请
function rpc_client_friend_add_request(friend_id)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:insertOneToUidList(DATA_APPLY, friend_id)
end

--首次推荐好友列表
function rpc_client_friend_recommend_user(list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:initSystemCommandList(list)
end

--接着请求推荐
function rpc_client_friend_recommend_user_next(list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:insertSystemCommandList(list)
end

--获取我是否对该玩家提交过好友申请的请求
function rpc_client_friend_request_status(uid, status)
	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end
	local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
	if tolua.isnull(add_ui) then return end
	add_ui:updateAddBtnStatus(uid, status)
end

--搜索玩家下行的协议
function rpc_client_friend_search(result, error, list)
	if result == 0 then
		Alert:warning({msg = error_info[error].message, size = 16})
		return
	end
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:initSearchListByUidAsKeyList(list)
end

function rpc_client_friend_relation(list)
	-- list = {
	-- 	[1] = {
	-- 	      ["is_yvip"] = 0,
	-- 	      ["icon"] ="http://q.qlogo.cn/qqapp/1104681464/F2923582AE2C8D42ACE66D0E1F86CD96/40",
	-- 	      ["vip_level"] = 0,
	-- 	      ["is_vip"] = 0,
	-- 	      ["name"] = "龟苓膏911",
	-- 	      ["gameRole"] = 2,
	-- 	      ["gamePrestige"] = 174,
	-- 	      ["gameName"] = "邹芷蕊",
	-- 	      ["uid"] = 10010,
	-- 	      ["gameLevel"] = 3,
	-- 	      ["openid"] = "F2923582AE2C8D42ACE66D0E1F86CD96",
	-- 	      ["gender"] = "女",
	-- 	      ["is_svip"] = 0,
	-- 	      ["lastLoginTime"] = ONLINE,
	-- 	    },
	--     [2] = {
	-- 	      ["is_yvip"] = 1,
	-- 	      ["icon"] = "http://q.qlogo.cn/qqapp/1104681464/D603F4B2363828F3362828828BA424F3/40",
	-- 	      ["vip_level"] = 7,
	-- 	      ["is_vip"] = 1,
	-- 	      ["name"] = "天灾",
	-- 	      ["gameRole"] = 2,
	-- 	      ["gamePrestige"] = 148,
	-- 	      ["gameName"] = "戚蕾",
	-- 	      ["uid"] = 10267,
	-- 	      ["gameLevel"] = 1,
	-- 	      ["openid"] = "D603F4B2363828F3362828828BA424F3",
	-- 	      ["gender"] = "男",
	-- 	      ["is_svip"] = 1,
	-- 	      ["lastLoginTime"] = os.time()
	--     	},
	-- }
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:assembRelationInfo(list)
end

--赠送
function rpc_client_friend_praise_send(friend_id, result, error)
	if result == 0 then
		showAlert(error)
	else
		Alert:warning({msg = ui_word.FRIEND_SEND_TILI_SUCCESS})
	end
end

function rpc_client_friend_praise_recv(friend_id, result, err)
	if err ~= 0 then
		showAlert(err)
	end
end

--接收并回赠
function rpc_client_friend_praise_recv_and_send(friend_id, result, error)
	if result == 0 then
		showAlert(error)
	else
		Alert:warning({msg = ui_word.FRIEND_EXECUTE_SUCCESS})
	end
end

--交互过程中状态的改变
function rpc_client_friend_praise_status_list(status_list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setInteractiveInfo(status_list)
end

--交互过程中状态的改变
function rpc_client_friend_praise_status(friend_id, rank_status, gift_status, intimacy)
	local status_list = {
		{
			friendId = friend_id,
			rank_status = rank_status,
			gift_status = gift_status,
			intimacy = intimacy
		}
	}
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setInteractiveInfo(status_list)
end

--赠送的次数和接收的次数
function rpc_client_friend_praise_times(send_times, recv_times)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setSendAcceptTimes(send_times, recv_times)
end

--增减好友会下发的协议
function rpc_client_friend_change(uid, status)
	local friend_data = getGameData():getFriendDataHandler()
	if status == FRIEND_STATUS_ADD then--添加好友
		friend_data:addFriend(uid)                                                                                                                                                                                                      
	else--删除好友
		friend_data:deleteFriend(uid)
	end

	local main_ui = getUIManager():get("ClsFriendMainUI")
	if tolua.isnull(main_ui) then return end

	local friend_panel = main_ui:getPanelByName("ClsFriendPanelUI")
	local add_ui = main_ui:getPanelByName("ClsAddPanelUI")
	if not tolua.isnull(friend_panel) then
		friend_panel:updateAllTimes()
	elseif not tolua.isnull(add_ui) then
		add_ui:updateFriendNum()
	end
end

function rpc_client_friend_visit_sailor_info(list, uid)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setTempFriendSailor(list)

	local collect_data = getGameData():getCollectData()
	collect_data:visitSailorCollect()
end

function rpc_client_friend_visit_baowu_info(list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setTempFriendBaowu(list)
	EventTrigger(EVENT_FRIEND_BAOWU_INFO)
end

--访问好友的遗迹信息
function rpc_client_friend_visit_relic_info(list)
	local collect_data = getGameData():getCollectData()
	collect_data:initFriendRelicData(list)
	EventTrigger(EVENT_FRIEND_RELIC_INFO)
end

function rpc_client_friend_visit_equip_info(equip_list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setTempFriendEquip(equip_list)
	EventTrigger(EVENT_FRIEND_EQUIP_INFO)
end

--赠送体力的返回协议
function rpc_client_friend_praise_return(friend_id, result, error)
	if result == 0 then
		showAlert(error)
	else
		Alert:warning({msg = ui_word.FRIEND_SEND_TILI_SUCCESS})
	end
end

--主动切磋者上行切磋的返回协议
function rpc_client_fight_qiecuo(err, end_time)
	if err == 0 then
		Alert:showFriendPk(INITIATIVE_PK_TIP, nil, nil, end_time)
	else
		showAlert(err)
	end
end

--通知被切磋者
function rpc_client_qiecuo_target(attacker, name, end_time)
	local prizon_ui = getUIManager():get("ClsPrizonUI")
	if not tolua.isnull(prizon_ui) then--处于紧闭中
		local friend_data_handler = getGameData():getFriendDataHandler()
		friend_data_handler:askAgreePk(3, attacker)
		return
	end
	Alert:showFriendPk(PASSIVITY_PK_TIP, name, attacker, end_time)
end

function rpc_client_qiecuo_result(err)
	local friend_pk_ui = getUIManager():get("ClsFriendPkTip")
	if not tolua.isnull(friend_pk_ui) then
		friend_pk_ui:closeScheduler()
		friend_pk_ui:close()
	end
	showAlert(err)
end

function rpc_client_update_friend_info(info)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:assembUserInfo(info, true)
end

function rpc_client_friend_ban_request_status(status)
	local friend_data_handler = getGameData():getFriendDataHandler()
	friend_data_handler:setRefuseApply(status == 1)
end

function rpc_client_relation_friend_level_sum(num, max_num)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setCurFriendLevel(num)
	friend_data:setHistoryFriendLevel(max_num)
end

function rpc_client_relation_friend_count(count, max_count)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:setCurFriendNum(count)
	friend_data:setHistoryFriendNum(max_count)
end

-- info = {
-- 	name = "杰克逊",
-- 	icon = "101",
-- 	intimacy = 3,
-- 	rewards = {
-- 		[1] = {
--          ['type'] = ITEM_INDEX_TILI,
--          ['amount'] = 20,
--            },
-- 	}
function rpc_client_friend_praise(info)
	getUIManager():create("gameobj/friend/clsFriendRedpackUI", nil, info)
end


function rpc_client_friend_relation_user_info(friend_list)
	local friend_data = getGameData():getFriendDataHandler()
	friend_data:updateNeatFriend(friend_list)
end

function rpc_client_friend_relation_recall(error_id, friend_uid)
	if error_id == 0 then --成功
		if GTab.IS_VERIFY then
            return
        end
		local friend_data_handle = getGameData():getFriendDataHandler()
        local open_id = friend_data_handle:getOpenId(friend_uid)
        if open_id then
            getGameData():getShareData():shareToFriend(open_id, "friend_recall")
        end
    else
    	local _msg = error_info[error_id].message
		Alert:warning({msg = _msg})
	end
	
end
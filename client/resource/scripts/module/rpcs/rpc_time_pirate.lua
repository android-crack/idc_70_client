--[[
世界BOSS剩余时间
ctime 服务器当前时间,stime 活动开始时间， lasting 活动持续时间
void rpc_client_area_boss_left(int uid,int ctime,int stime,int lasting); --]]
function rpc_client_area_boss_left(ctime, stime, lasting)
    getGameData():getExplorePirateEventData():setPirateEventInfo(ctime, stime, lasting)
end

--[[
// 活动结束
void rpc_client_area_boss_over(int uid);    --]]
function rpc_client_area_boss_over()
    getGameData():getExplorePirateEventData():overEvent()
end

--[[
// op == 1 查个人，其它值 查 商会                                                
void rpc_server_area_boss_rank(object user, int op);                             
void rpc_client_area_boss_person_rank(int uid, area_rank *personal,area_rank self);   
void rpc_client_area_boss_group_rank(int uid,area_rank *group);     --]]
function rpc_client_area_boss_person_rank(ranks, my_rank, region)
    local info = {}
    info.ranks = ranks
    info.my_rank = my_rank
    info.region = region
    getGameData():getExplorePirateEventData():setPersonRankList(info)
end
function rpc_client_area_boss_group_rank(ranks, my_rank)
    local info = {}
    info.ranks = ranks
    info.my_rank = my_rank
    getGameData():getExplorePirateEventData():setGroupRankList(info)
end

function rpc_client_area_boss_final_show(ranks, my_rank, rewards, region)
	local info = {}
	info.ranks = ranks
	info.my_rank = my_rank
	info.rewards = rewards
    info.region = region
	local DialogQuene = require("gameobj/quene/clsDialogQuene")
	local ClsAutoPopTimePrivate = require("gameobj/quene/clsAutoPopTimePrivate")
	DialogQuene:insertTaskToQuene(ClsAutoPopTimePrivate.new(info))
end
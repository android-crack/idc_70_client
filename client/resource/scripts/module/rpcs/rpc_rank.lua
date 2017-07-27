--[[
	TYPE:
	声望总榜      1
	财富榜        2
	海盗榜        3
	冒险家声望榜  4
	海军声望榜    5
	雇佣军声望榜  6
	商会榜        7

	rank_info {
  	    int uid;        //玩家ID
  	    string name;    //玩家名字
  	    int value;      //排行榜数值
  	    int role;       //职业
  	    int nobility;   //爵位
  	    int grade;      //等级
  	    int title;      //称号
  	}
]]
local function getUserRankData(data)
	local user_uid = getGameData():getPlayerData():getUid()
	for k,v in ipairs(data) do
		if v.uid == user_uid then
			return true, k, v.value
		end
	end
end

local function isPerfessionRank(_type)
	if _type >= ADV_RANK_TYPE and _type <= PIRP_RANK_TYPE then
		return true
	end
end

function rpc_client_rank_detail(type, gradeKey, error, rank_info)
	if error == 0 then
		-- print('type ============:',type)
		-- print("gradeKey ========:",gradeKey)
		-- print("rank_info =======:",rank_info)
		-- table.print(rank_info)
		-- print("----------------------------")
		local data = {}
		data.rank_list = rank_info
		data.is_in_rank, data.user_pos, data.user_value = getUserRankData(rank_info)
		getGameData():getRankData():setListByType(type, data)

		if getUIManager():isLive("ClsRankMainUI") then
			local select_tab_ui = getUIManager():get("ClsRankMainUI"):getListView(type)
			if isPerfessionRank(type) then
				select_tab_ui = getUIManager():get("ClsRankMainUI"):getListView(PRESTIGE_RANK_TYPE)
			end
			if not tolua.isnull(select_tab_ui) then
				select_tab_ui:updateView()
			end
		end
	end
end

--[[ 商会排行榜
   ranks = {
       [1] = {
            guildId = , 
            name = ,
            prestige = , --声望
            amount = , 商会人数
            icon = , 商会图标
            size = , 商会的最大人数
            man_name = , 商会会长名字
       },
   } 
]]
local function getUserGuildRank(data)
	local my_guild_id = getGameData():getGuildInfoData():getGuildId()
	for k, v in ipairs(data) do
        if v.groupId == my_guild_id then
            return true, k, v.prestige
        end
    end
end

function rpc_client_group_chart(rank_info)
	local data = {}
	data.rank_list = rank_info
	data.is_in_rank, data.user_pos, data.user_value = getUserGuildRank(rank_info)
	getGameData():getRankData():setListByType(GUILD_RANK_TYPE, data)

	if getUIManager():isLive("ClsRankMainUI") then
		local select_tab_ui = getUIManager():get("ClsRankMainUI"):getListView(GUILD_RANK_TYPE)
		if not tolua.isnull(select_tab_ui) then
			select_tab_ui:updateView()
		end
	end
end
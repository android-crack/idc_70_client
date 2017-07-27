--称号系统协议

local ignore_ids = {20029,20030,20031}

--获取所有称号
function rpc_client_title_list(list)
    for k,v in pairs(list) do
        if ignore_ids[v.id] then
            list[k] = nil
        end
    end
	local title_data = getGameData():getTitleData()
	title_data:receiveAllTitles(list)
	title_data:setAllTitleList(list)

	local ClsRoleInfoView = getUIManager():get("ClsRoleInfoView")
	if not tolua.isnull(ClsRoleInfoView) then
		ClsRoleInfoView:updateCurTitleUI()
	end

end

--添加称号
function rpc_client_title_add(title)

    if ignore_ids[title.id] then
        return
    end

	local title_data = getGameData():getTitleData()
	title_data:addTitle(title)
	title_data:addItemOfAllTitleList(title)

	-- require("gameobj/quene/clsDialogQuene"):insertTaskToQuene(require("gameobj/quene/clsObtainNewTitleQueue").new({}))

	-- 播放队列后修改状态值
	local function play_effect()
		require("gameobj/quene/clsDialogQuene"):insertTaskToQuene(require("gameobj/quene/clsObtainNewTitleQueue").new({}))
		getGameData():getTitleData():setIsToPlayEffect(false)
	end

	-- 设置状态值
	getGameData():getTitleData():setIsToPlayEffect(true)

	-- if getGameData():getSceneDataHandler():isInCopyScene() then
	-- 	getGameData():getTitleData():setIsToPlayEffect(true)
	-- else
	-- 	play_effect()
	-- end


	-- 如果在港口则直接播放 否则 增加一个 进入港口回调
	local ui = getUIManager():get("ClsPortLayer")
	if not tolua.isnull(ui) then
		play_effect()
	else
		getGameData():getPortData():setEnterPortCallBack(function()
			if getGameData():getTitleData():getIsToPlayEffect() then
				-- getGameData():getTitleData():setIsToPlayEffect(false)
				play_effect()
			end
		end)
	end

	-- 进入探索地图的回调
	local function callback()
		if getGameData():getTitleData():getIsToPlayEffect() then
			-- getGameData():getTitleData():setIsToPlayEffect(false)
			play_effect()
		end
	end
	local data = {}
	data.call = callback
	getGameData():getExploreData():addEnterExploreCallBack(data)

end

--删除称号协议
function rpc_client_title_remove(title_id)

    if ignore_ids[title_id] then
        return
    end

	local title_data = getGameData():getTitleData()
	title_data:delTitle(title_id)
	title_data:delItemOfAllTitleList(title_id)
end

--设置当前称号
function rpc_client_title_current(title_id,error_code)

	if ignore_ids[title_id] then
		return
	end

	if error_code and error_code ~= 0 then
		require("ui/tools/alert"):warning({msg = require("game_config/error_info")[error_code].message})
	else
		local title_data = getGameData():getTitleData()
		title_data:setCurTitle(title_id)
		if isExplore then
			getGameData():getExplorePlayerShipsData():askMyShipInfo()
		end
		-- 如果打开称号界面 刷新称号界面
		local target = getUIManager():get("ClsRoleInfoView")
		if not tolua.isnull(target) then
			target:updateCurTitleUI()
		end
		local target = getUIManager():get("clsRoleTitleUI")
		if not tolua.isnull(target) then
			target:showChangeTitleTips()
		end
	end

end

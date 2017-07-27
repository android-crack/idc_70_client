--船长系统数据管理
local ErrorInfo = require("game_config/error_info")
local Alert = require("ui/tools/alert")
local prosper_info = require("game_config/prosper/prosper_info")

local handler = class("CaptainInfoData")

function handler:ctor()
	self.infos = {}

	self.prosperityAdd = 0  --繁荣度增加量
	self.curProsperity = -1  --当前的繁荣度

	self.nextMaxProsperityInfo = {}  --下节点的繁荣度
	self.nextMaxProsperityInfo.prosper = -1
	self.nextMaxProsperityInfo.investLevel = 0
	self.nextMaxProsperityInfo.boatId = 0

	self.curMaxProsperityInfo = {}  --当前节点的繁荣度
	self.curMaxProsperityInfo.prosper = -1
	self.curMaxProsperityInfo.investLevel = 0
	self.curMaxProsperityInfo.boatId = 0

	self.maxProsperInfo = {}  --最大繁荣度
	self.maxProsperInfo.prosper = prosper_info[#prosper_info].prosper
	self.maxProsperInfo.boatId = prosper_info[#prosper_info].boat_id
	self.maxProsperInfo.investLevel = #prosper_info

	self.oldProsperInfo = nil
end

function handler:askForCaptainInfo(uid)
	GameUtil.callRpc("rpc_server_captain_info", {uid}, "rpc_client_captain_info")
end

function handler:askChangeHeadIcon(res)	
	GameUtil.callRpc("rpc_server_user_set_icon", {res})
end

--船长信息数据
function handler:receiveCaptainInfo(datas)
	-- if not datas or not datas.base or not datas.base.uid then return end
	--self.infos[datas.base.uid] = datas

	local ClsCaptainInfoMain = getUIManager():get("ClsCaptainInfoMain")
	if not tolua.isnull(ClsCaptainInfoMain) then
		ClsCaptainInfoMain:setData(datas)
	end
end

function handler:getInfoByUid(uid)
	if not uid then return end
	return self.infos[uid]
end

function handler:getBuildBoatProsperInfo(boatId)  --获取船舶的建造势力等级需求
	local prosperInfo = {}
	prosperInfo.prosper = -1
	prosperInfo.boatId = 0
	prosperInfo.investLevel = 0

	if not boatId then return prosperInfo end

	for k,v in pairs(prosper_info) do
		local t = {}
		t = split(v.boat_id, ",")
		for k1,v1 in pairs(t) do
			if tonumber(v1) == boatId then
				prosperInfo.prosper = v.prosper
				prosperInfo.boatId = boatId
				prosperInfo.investLevel = k
				return prosperInfo
			end
		end
	end
	return self.maxProsperInfo
end

function handler:getCurMaxProsper()  --获取当前级别繁荣度
	local curProsper = self:getProsperity()
	return self:getCurLevelProsper(curProsper)
end

function handler:getNextMaxProsper()  --获取下一级别繁荣度
	local curProsper = self:getProsperity()
	return self:getNextLevelProsper(curProsper)
end

function handler:setProsperity(value)
	self.prosperityAdd = 0
	if self.curProsperity ~= -1 then
		self.prosperityAdd = value - self.curProsperity
		self.curProsperity = value
	end
	self.curProsperity = value
	self.curMaxProsperityInfo.prosper, self.curMaxProsperityInfo.boatId, self.curMaxProsperityInfo.investLevel = self:getCurMaxProsper()
	self.nextMaxProsperityInfo.prosper, self.nextMaxProsperityInfo.boatId, self.nextMaxProsperityInfo.investLevel = self:getNextMaxProsper()
end

function handler:getProsperityAdd()
	local prosperityAdd = self.prosperityAdd
	self.prosperityAdd = 0
	return prosperityAdd
end

function handler:getCurSailorLevel()  --水手等级限制
	local playerData = getGameData():getPlayerData()
	return playerData:getLevel()
end

function handler:getCurInvestLevel()  --繁荣度等级
	return self.curMaxProsperityInfo.investLevel
end

function handler:getCurMaxProsperityInfo()  --当前
	return self.curMaxProsperityInfo
end

function handler:getNextMaxProsperityInfo()  --下一级
	return self.nextMaxProsperityInfo
end

function handler:getMaxProsperInfo()
	return self.maxProsperInfo
end

function handler:getProsperity()
	return self.curProsperity
end

function handler:getCurLevelProsper(curProsper)
	local index
	local minProsperDistance = nil
	local tab = prosper_info
    for k, v in ipairs(tab) do
        prosperDistance = curProsper - v.prosper
        if prosperDistance >= 0 then
            if not minProsperDistance or prosperDistance <= minProsperDistance then
            	index = k
                minProsperDistance = prosperDistance
            end
        else
        	break
        end
    end
    return tab[index].prosper, tab[index].boat_id, index
end

function handler:getNextLevelProsper(curProsper)
    local index
    local tab = prosper_info
    for k, v in ipairs(tab) do
		if curProsper >= tab[#tab].prosper then --最大值
            index = #tab
            break
		end
        prosperDistance = v.prosper - curProsper
        if prosperDistance > 0 then
        	index = k
        	break
        end
    end
    return tab[index].prosper, tab[index].boat_id, index
end

function handler:getCurStepProsper()
	local curStepProsper = 0
	local curStepMaxProsper = 0

	local curProsper = self:getProsperity()
	local maxProsperInfo = self:getMaxProsperInfo()
	local curMaxProsperInfo = self:getCurMaxProsperityInfo()
	local nextMaxProsperInfo = self:getNextMaxProsperityInfo()

	if curProsper >= maxProsperInfo.prosper then
        curStepProsper = maxProsperInfo.prosper
        curStepMaxProsper = maxProsperInfo.prosper
    else
        curStepProsper = curProsper - curMaxProsperInfo.prosper
        curStepMaxProsper = nextMaxProsperInfo.prosper - curMaxProsperInfo.prosper
    end

	return curStepProsper, curStepMaxProsper
end

function handler:getNextLevelInfo(prosperLevel) --根据繁荣等级来取数据
	if not prosperLevel then return prosper_info[1].prosper, prosper_info[1].boat_id, 1 end
	if prosperLevel > #prosper_info then
		prosperLevel = #prosper_info
	end
	return prosper_info[prosperLevel].prosper, prosper_info[prosperLevel].boat_id, prosperLevel
end

function handler:setOldProsperInfo(params) --{level, prosper, maxProsper}
	self.oldProsperInfo = params
end

function handler:getOldProsperInfo()
	return self.oldProsperInfo 
end

return handler
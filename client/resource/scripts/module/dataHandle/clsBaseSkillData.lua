local alert = require("ui/tools/alert")
local error_info = require("game_config/error_info")
local attrs_role = require("game_config/role/attrs_role")
local base_skill_gen = require("game_config/role/base_skill_gen")

local SKILL_TYPE_COUNT = 4
local CONSUME_COIN, CONSUME_EXP = 1, 2

local MIN_LEVEL, MAX_LEVEL = 1, 60

local ClsBaseSkillData = class("ClsBaseSkillData")

function ClsBaseSkillData:ctor()
	self.base_info = {}
	self.modify_info = {}

	self.average_lv = 1

	self.is_consume_coin = true
end

function ClsBaseSkillData:isConsumeCoin()
	return self.is_consume_coin
end

function ClsBaseSkillData:setConsumeCoin(value)
	self.is_consume_coin = value
end

function ClsBaseSkillData:getAverageLV()
	return self.average_lv
end

function ClsBaseSkillData:resetAverageLV()
	local level = 0
	for k, v in pairs(self.base_info) do
		level = level + v.level
	end

	level = math.floor(level/SKILL_TYPE_COUNT) + 1

	self.average_lv = Math.clamp(MIN_LEVEL, MAX_LEVEL, level)
end

function ClsBaseSkillData:receiveData(info)
	local tmp = {}
	tmp.exp = info.exp
	tmp.level = info.level
	tmp.attr = info.attr

	self.base_info[info.type] = tmp
end

function ClsBaseSkillData:getBaseData()
	return self.base_info
end

----主角技能四个属性达到的最低等级
function ClsBaseSkillData:getBaseSkillLimitLevel(  )
	local level_list = {}
	for k,v in pairs(self.base_info) do
		level_list[#level_list + 1] = v.level
	end
	table.sort(level_list, function (a,b)
		return a < b
	end)
	return level_list[1]
end

---主角技能额外属性info
function ClsBaseSkillData:getRoleSkillAttrs(  )
	local role_id = getGameData():getPlayerData():getRoleId()
	local role_lock_attrs = {}
	for k,v in ipairs(attrs_role) do
		if v.role_id == role_id then
			role_lock_attrs[#role_lock_attrs + 1] = v
		end
	end
	return role_lock_attrs		
end

---下一个未解锁额外属性
function ClsBaseSkillData:getUnlockSkillAttrInfo(level)
	local skill_attr_list = self:getRoleSkillAttrs()
	for k,v in ipairs(skill_attr_list) do
		if v.level_limit > level then
			return v 
		end
	end
	return skill_attr_list[#skill_attr_list]
end

function ClsBaseSkillData:getLevelByType(attr_type)
	return self.base_info[attr_type].level
end

function ClsBaseSkillData:receiveModifyData(info, index)
	local tmp = {}
	tmp.baoji = info.baoji > 1
	tmp.exp = info.expAdd
	tmp.attr = info.attrAdd

	self.modify_info[index] = tmp
end

function ClsBaseSkillData:getModifyData()
	return self.modify_info
end

function ClsBaseSkillData:askBaseInfo()
	GameUtil.callRpcVarArgs("rpc_server_role_base_skill_info")
end

function ClsBaseSkillData:askUpgrade()
	GameUtil.callRpcVarArgs("rpc_server_role_base_skill_upgrade", self:isConsumeCoin() and CONSUME_COIN or CONSUME_EXP)
end

-------------------------------------------------------------------------------------------------------

function rpc_client_role_base_skill_upgrade(err_no)
	if err_no > 0 then
		local msg = error_info[err_no].message
        alert:warning({msg = msg})
	end
end

--class base_skill_info {int type; int exp; int level; int attr;}
function rpc_client_role_base_skill_info(info)
	local base_skill_data = getGameData():getBaseSkillData()
	
	for k, v in pairs(info) do
		base_skill_data:receiveData(v)
	end
	base_skill_data:resetAverageLV()

	local ui = getUIManager():get("clsRoleAttrSkillView")
	if not tolua.isnull(ui) then
		ui:initUI()
	end
end

-- class base_skill_modify{int baoji; int expAdd; int attrAdd; base_skill_info info;}
function rpc_client_role_base_skill_modify(modify)
	local base_skill_data = getGameData():getBaseSkillData()

	base_skill_data.modify_info = {}

	base_skill_data:receiveData(modify.info)
	base_skill_data:resetAverageLV()
	base_skill_data:receiveModifyData(modify, modify.info.type)

	local ui = getUIManager():get("clsRoleAttrSkillView")
	if not tolua.isnull(ui) then
		ui:upgradeEffect(modify.info.type)
	end
end

-------------------------------------------------------------------------------------------------------

return ClsBaseSkillData
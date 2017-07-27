local ClsCopySceneEventObject = require("gameobj/copyScene/copyEventObject")
local SceneEffect = require("gameobj/battle/sceneEffect")
local propEntity = require("gameobj/copyScene/copySceneProp")
local music_info = require("game_config/music_info")
local ClsSceneConfig = require("game_config/copyScene/copy_scene_prototype")
local copySceneConfig = require("gameobj/copyScene/copySceneConfig")
local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
local ui_word = require("game_config/ui_word")

local ClsCopyBoxEventObject = class("ClsCopyBoxEventObject", ClsCopySceneEventObject);

function ClsCopyBoxEventObject:initEvent(prop_data)
	self.event_data = prop_data
	self.event_create_time = prop_data.create_time
	self.event_id = prop_data.id
	self.event_type = prop_data.type

	local config = ClsSceneConfig[prop_data.type]
	local item = ClsSceneManage.model_objects:getModel(self.event_type)
	item.id = prop_data.id
	item.node:setTag("scene_event_id", tostring(self.event_id))
	item:setPos(prop_data.sea_pos.x, prop_data.sea_pos.y)
	self.item_model = item
	self.action_radius =  300
	--
	--[[69 海面漂来一只宝箱，看样子装了不少值钱的东西，可惜…我还不懂怎么打捞…

	70 一只酒桶？如果有人会打捞的话，也许我们就有酒喝了。

	71 下次出海，记得带上一位会打捞的航海士，说不定能从沉船中找到宝物。]]
	if config.event_type == "fat" then
		self.tips_id = 181
	elseif config.event_type == "box" then
		self.tips_id = 69
	elseif config.event_type == "werck" or config.event_type == "melee_werck" then
		self.tips_id = 71
		self.boat_3d_effect = SceneEffect.createEffect({file = EFFECT_3D_PATH .. "tx_0113" .. PARTICLE_3D_EXT, parent = item.node, isStart = true})
		local targetTran = self.boat_3d_effect:GetNode():getTranslation()
		local targetPos = Vector3.new()
		targetPos:set(0, 20, 0)
		Vector3.add(targetTran, targetPos, targetPos)
		--Vector3.add(targetTran, Vector3.new(0, 20, 0), targetPos)
		self.boat_3d_effect:GetNode():setTranslation(targetPos)
	end
	--技能图标
	self.skill_id = 1070
	self.m_is_need_salvage = true
	self.m_stop_reason = string.format("ClsCopyBoxEventObject_id_%d", self.event_id)
	self.m_ships_layer = ClsSceneManage:getSceneLayer():getShipsLayer()
	self:createSkillIcon()
end

function ClsCopyBoxEventObject:initUI()
	ClsSceneManage:doLogic("tryToShowGuildArrow", self, ui_word.STR_COPY_SCENE_BOX_EVENT_TIP)
end

function ClsCopyBoxEventObject:__endEvent()
	ClsCopyBoxEventObject.super.__endEvent(self)
	if self.boat_3d_effect then
		SceneEffect.ReleaseParticle(self.boat_3d_effect)
		self.boat_3d_effect = nil
	end
	if self.item_model then
		ClsSceneManage.model_objects:removeModel(self.item_model)
		self.item_model = nil
	end
	self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
end

function ClsCopyBoxEventObject:update(dt)
end

function ClsCopyBoxEventObject:release()
	self:__endEvent()
end

function ClsCopyBoxEventObject:updataAttr(key, value)
	self.m_attr[key] = value
	if "is_operation" == key then
		if value > 0 then
			self:setSalvage(true)
		end
	end
end

function ClsCopyBoxEventObject:updataInteractiveResult(interactive_type, result)
	if result > 0 then return end
	if copySceneConfig.INTERACTIVE_TYPE.START == interactive_type then
		if self:getAttr("is_operation") == self.m_my_uid then
			self:showSalvageEffect()
		end
	end
end

function ClsCopyBoxEventObject:showSalvageEffect()

	local function tipCallBack()
	end

	local function endCallBack()
		self.m_ships_layer:releaseStopShipReason(self.m_stop_reason)
		self:sendSalvageMessage()
	end

	local scene_layer = ClsSceneManage:getSceneLayer()
	self.m_ships_layer:setStopShipReason(self.m_stop_reason)

	local ExploreSalvageSkill = require("gameobj/explore/exploreSalvageSkill")
	local target = {spItem = self.item_model}
	local params = {
		ship_id = scene_layer.player_ship.id,
		anim_call = "scripts/gameobj/gameplayFunc.lua#animationClipPlayEnd",
		targetNode = target.spItem.node,
		targetData = target,
		ship = scene_layer.player_ship,
		num = 1,
		modelFile = "ex_salvage",
		animationFile = "ex_salvage",
		targetCallBack = endCallBack,
		tipCallBack = tipCallBack,
	}

	ExploreSalvageSkill.new(params)
	audioExt.playEffect(music_info.EX_SALVAGE.res)
end

function ClsCopyBoxEventObject:showEventEffect()
	self:sendInteractiveMessage()
end

function ClsCopyBoxEventObject:touch(node)
	if not node then return end
	local event_id = node:getTag("scene_event_id")
	if not event_id then
		return
	end
	--print("点击宝箱------------------------", event_id, self:getEventId())
	event_id = tonumber(event_id)
	if event_id ~= self:getEventId() then
		return
	end
	audioExt.playEffect(music_info.UI_CLICK_BOX.res)
	local ClsSceneManage = require("gameobj/copyScene/copySceneManage")
	local scene_layer = ClsSceneManage:getSceneLayer()

	local x, y = self.item_model:getPos()
	local px, py = scene_layer.player_ship:getPos()
	local dis = Math.distance(px, py, x, y)
	if dis < self.action_radius / 2 then
		self:showEventEffect()
	else
		local news = require("game_config/news")
		local Alert = require("ui/tools/alert")
		Alert:warning({msg = news.COPY_TREASURE_BOX_EVENT_TIP.msg})
	end
	return true
end


return ClsCopyBoxEventObject

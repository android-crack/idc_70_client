----玩家等级升级界面
local gamePlot = require("gameobj/mission/gamePlot")
local CompositeEffect = require("gameobj/composite_effect")
local upgradeInfo = require("game_config/reward/upgrade_info")
local ui_word = require("game_config/ui_word")
local music_info = require("game_config/music_info")
local ClsBaseView = require("ui/view/clsBaseView")

local Upgrade = class("upgradeLayer", ClsBaseView)

function Upgrade:getViewConfig(...)
	return {
		type =  UI_TYPE.TOP
	}
end


function Upgrade:onEnter(level,value,callback)
	self.resPlist = {["ui/mission.plist"] = 1}
	LoadPlist(self.resPlist)
	if not level or not value or not callback then return end
	-- if level == nil or level < 1 then level = 1 end
	-- value = value or 100
	self.level = level
	self.value = value
	self.isClicked = false
	self.callback = callback
	--添加的特效层
	self.effectLayer = CCLayer:create()
	self:addChild(self.effectLayer)

	--奖励层
	self.rewardLayer = CCLayer:create()
	self:addChild(self.rewardLayer, 1)

	local function showReward()
		local lineX = display.cx - 28
		local lineY = display.cy - 2
		self.rewardLayer:addChild(display.newSprite("#mission_list_line.png", display.cx, lineY + 24))

		local lx, ly = display.cx + 100, display.cy + 50

		local frontLevelLabel = createBMFont({text = tostring(self.level - 1), color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), size = 24,
				x = lx - 147, y = ly - 5})
		self.rewardLayer:addChild(frontLevelLabel)

		local levelLabel = createBMFont({text = tostring(self.level), color = ccc3(dexToColor3B(COLOR_GREEN)), size = 30,
				x = lx - 10, y = ly - 5})
		self.rewardLayer:addChild(levelLabel)

		local off_X1, off_X2 = -90, 100
		local line_num = -1
		--银币数量
		-- line_num = line_num + 1
		-- local label = createBMFont({text = ui_word.MAIN_CASH, fontFile = FONT_CFG_1, anchor = ccp(0, 0.5),
		-- 	color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), size = 18, x = lineX + off_X1, y = lineY - line_num*32})
		-- self.rewardLayer:addChild(label)
		-- label = createBMFont({text = "+" .. tostring(upgradeInfo[self.level].silver),
		-- 	color = ccc3(dexToColor3B(COLOR_GREEN)), size = 18, x = lineX + off_X2, y = lineY - line_num*32,
		-- 	anchor = ccp(0, 0.5)})
		-- self.rewardLayer:addChild(label)

		--船只强化等级强化限制提示
		-- line_num = line_num + 1
		-- label = createBMFont({text = ui_word.UPGRADE_EQUIP_ENHANCE, fontFile = FONT_CFG_1, anchor = ccp(0, 0.5),
		-- 	color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), size = 18, x = lineX + off_X1, y = lineY - line_num*32})
		-- self.rewardLayer:addChild(label)
		-- label = createBMFont({text = "Lv." .. tostring(self.level), anchor = ccp(0, 0.5),
		-- 	color = ccc3(dexToColor3B(COLOR_GREEN)), size = 18, x = lineX + off_X2, y = lineY - line_num*32})
		-- self.rewardLayer:addChild(label)
		--航海士等级强化限制提示
		line_num = line_num + 1
		local label = createBMFont({text = ui_word.UPGRADE_SAILOR_LEVEL, fontFile = FONT_CFG_1, size = 18, x = lineX + off_X1,
			color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), y = lineY - line_num*32, anchor = ccp(0, 0.5)})
		self.rewardLayer:addChild(label)
		-- 新等级
		label = createBMFont({text = "Lv." .. tostring(self.level), size = 18,
			color = ccc3(dexToColor3B(COLOR_GREEN)), x = lineX + off_X2 + 19, y = lineY - line_num*32, anchor = ccp(0, 0.5)})
		self.rewardLayer:addChild(label)

		-- 字: 技能点
		local data = {}
		data.text = ui_word.LEVEL_UPGRADE_TEXT
		data.color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))
		data.x = lineX + off_X1 + 65
		data.y = lineY - line_num*32 - 32
		data.anchor = ccp(0, 0.5)
		data.size = 18
		local tar_ui
		tar_ui = createBMFont(data)

		self.rewardLayer:addChild(tar_ui)
		data.text = '+1'
		data.color = ccc3(dexToColor3B(COLOR_GREEN))
		data.x = lineX + off_X1 + 80 + 65
		data.y = lineY - line_num*32 - 32
		data.anchor = ccp(0, 0.5)
		data.size = 18
		tar_ui = createBMFont(data)
		self.rewardLayer:addChild(tar_ui)

		-- 总声望
		data.text = ui_word.FITHT_INFO_FIGHTGING
		data.color = ccc3(dexToColor3B(COLOR_CREAM_STROKE))
		data.x = lineX + off_X1 + 65
		data.y = lineY - line_num*32 - 32*2
		data.anchor = ccp(0, 0.5)
		data.size = 18
		tar_ui = createBMFont(data)
		self.rewardLayer:addChild(tar_ui)

		-- + N
		data.text = ' + '..self.value
		data.color = ccc3(dexToColor3B(COLOR_GREEN))
		data.x = lineX + off_X1 + 80 + 65
		data.y = lineY - line_num*32 - 32*2
		data.anchor = ccp(0, 0.5)
		data.size = 18
		tar_ui = createBMFont(data)
		self.rewardLayer:addChild(tar_ui)


		--银币上限提示
		local base_info = require("game_config/base_info")
		if base_info[self.level].silver_limit ~= base_info[self.level - 1].silver_limit then
			line_num = line_num + 1
			label = createBMFont({text = ui_word.UPGRADE_SILVER_LIMIT, fontFile = FONT_CFG_1, size = 18,
				color = ccc3(dexToColor3B(COLOR_CREAM_STROKE)), x = lineX + off_X1, y = lineY - line_num*32,
				 anchor = ccp(0, 0.5)})
			self.rewardLayer:addChild(label)
			label = createBMFont({text = tostring(base_info[self.level].silver_limit),
				color = ccc3(dexToColor3B(COLOR_GREEN)), size = 18, x = lineX + off_X2, y = lineY - line_num*32,
				anchor = ccp(0, 0.5)})
			self.rewardLayer:addChild(label)
		end
	end

	local function endEffect()
		audioExt.resumeMusic()
		self.rewardLayer:setScale(0)
		if self.midEffect then
			self.midEffect:clearAll()
			self.midEffect = nil
		end
		self.endEffect = CompositeEffect.bollow("tx_2027", display.cx, display.cy, self.effectLayer, 0.3, function()

				local array = CCArray:create()
				array:addObject(CCCallFunc:create(function ()
					self.rewardLayer:setVisible(false)
				end))
				local partner_data = getGameData():getPartnerData()
				local skill_id_list = partner_data:getRoleOpenSkillId()

				if skill_id_list then
					for k,v in pairs(skill_id_list) do
						if v > 0 then
							array:addObject(CCCallFunc:create(function ()
								self:createOpenRoleSkill(v)
							end))
							array:addObject(CCDelayTime:create(5))
						end
					end

				end

				array:addObject(CCCallFunc:create(function ()

					self:hideDialog()
					partner_data:clearRoleOpenSkillId(nil)
				end))
				self:runAction(CCSequence:create(array))
		end)
	end

	local act = CCCallFunc:create(function()
		CompositeEffect.bollow("tx_2025gs", display.cx, display.cy, self.effectLayer)
		CompositeEffect.bollow("tx_2025", display.cx, display.cy, self.effectLayer, 1.4, function()
			self.midEffect = CompositeEffect.bollow("tx_2026", display.cx, display.cy, self.effectLayer)
			self.isClicked = true
		end)
		audioExt.pauseMusic()
		audioExt.playEffect(music_info.LEVEL_UP.res)

		self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCCallFunc:create(function()
			showReward()

			self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.5), CCCallFunc:create(function()
				if self.endEffect == nil then
					endEffect()
				end
			end)))
		end)))
	end)
	self:runAction(CCSequence:createWithTwoActions(CCFadeTo:create(0.3, 155), act))

end

function Upgrade:createOpenRoleSkill(skill_id)
	getUIManager():create("gameobj/clsUnlockRoleSkill", nil, skill_id)--创建
end

function Upgrade:preClose()
	-- self:stopAllActions()

	-- UnLoadPlist(self.resPlist)
	-- audioExt.resumeMusic()
end

--关闭界面
function Upgrade:hideDialog()

	self:close()
	-- self:stopAllActions()
	if type(self.callback) == "function" then
		self.callback()
	end
	UnLoadPlist(self.resPlist)
	audioExt.resumeMusic()
end

--创建升级界面(参数：父类、等级、回调函数)
-- function createUpgradeLayer(parent, level, callback)
-- 	audioExt.pauseMusic()
-- 	getUIManager():create("gameobj/upgradeLayer", nil, level, callback)--创建

-- end
return Upgrade

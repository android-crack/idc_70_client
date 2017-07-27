local sailor_exp_info=require("game_config/sailor/sailor_exp_info")
local SailorUpLevelData = class("SailorUpLevelData")

function SailorUpLevelData:ctor()
	self.txts={}
	self.labelEffects = {}
	self.nameLabel=nil --最后的那个名字文本只要是要获取最低的位置
	self.levelLabel=nil
	
end

local sailor_star_exp = {
    "d_exp",
    "d_exp",
    "c_exp",  
    "b_exp",  
    "a_exp",
    "s_exp",
}
--水手经验
function SailorUpLevelData:addSailorExp(exp)
	--print("全体---------------------------------------获取经验>",exp)
	if not exp then return end
	--print("本次要加的经验exp =====================  ", exp)
	for k,v in pairs(self.labelEffects) do
		if not tolua.isnull(v) then
			v:removeFromParentAndCleanup(true)
		end
	end
	self.labelEffects = {}
	local playerData = getGameData():getPlayerData()
	local captainInfoData = getGameData():getCaptainInfoData()
	local level=playerData:getLevel()
	local playerMaxLevel = playerData.maxPlayerLevel
	local maxLevel = captainInfoData:getCurSailorLevel()
	
	local sailorData = getGameData():getSailorData()
	local ownSailors=sailorData:getOwnSailors()

	local function addExpEffect(sailorInfo)
		-- print("水手当前的经验======  ", sailorInfo.exp)
		-- print("水手的名字 ======  ", sailorInfo.name)
		-- print("水手ID ======  ", sailorInfo.id)
		-- print("水手升到下个等级需要的经验 ======  ", sailor_exp_info[sailorInfo.level].exp)
		if sailorInfo.level < playerMaxLevel and sailorInfo.level< maxLevel then
			sailorInfo.exp = sailorInfo.exp + exp
			local sailor_star = sailorInfo.star 
			local sailor_exp = sailor_star_exp[sailor_star]
			local expMax = sailor_exp_info[sailorInfo.level][sailor_exp]
			if expMax <= sailorInfo.exp then
				sailorInfo.exp = sailorInfo.exp - expMax
				sailorInfo.level = sailorInfo.level + 1
				for k,v in pairs(sailorInfo.skills) do
					if v.id == 1001 then
						v.level = math.floor(getSailLevel(sailorInfo)/(sailorInfo.level - 1)*sailorInfo.level)
						sailorInfo.sail = v.level + sailorData:getSkillImprove(sailorInfo.id, 1001)	
						break 
					end
				end
				self:showLabel({level="LEVEL UP!", name = sailorInfo.name})
			end
		end
	end

	-- local ship_data = getGameData():getShipData()
	-- for k,v in pairs(boats) do
 --   		local data = boat_data:getBoatDataByKey(v)
 --   		if data == nil or type(data) ~= "table" then
 --   			return
 --   		end
 --   		for k,v in pairs(data.sailors) do
 --   			if v == 0 then return end
 --   			local sailor = ownSailors[v]
 --   			if sailor then
 --   				addExpEffect(sailor)
 --   			end
 --   		end
	-- end	
end

function SailorUpLevelData:stopShow()  --大地图
	self.txts={}
	if not tolua.isnull(self.nameLabel) then
		self.nameLabel:removeFromParentAndCleanup(true)
		self.nameLabel=nil
	end
	if not tolua.isnull(self.levelLabel) then
		self.levelLabel:removeFromParentAndCleanup(true)
	end

end

function SailorUpLevelData:showLabel(txt_)
	if txt_ then table.insert(self.txts,txt_) end
	if not tolua.isnull(self.nameLabel) then return end

	local txt=self.txts[1]
	if txt then

		local scene=GameUtil.getRunningScene()
		if tolua.isnull(scene) then return end

		self.levelLabel=createBMFont({text=txt.level,color=ccc3(dexToColor3B(COLOR_GREEN)),size = 18,x=display.cx,y=380})
		scene:addChild(self.levelLabel,ZORDER_SAILOR_EXP_UP)
		local arr=CCArray:create()
		arr:addObject(CCMoveBy:create(1,ccp(0,50)))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.5,ccp(0,25)),CCFadeOut:create(0.5)))
		self.levelLabel:runAction(CCSequence:create(arr))


		self.nameLabel=createBMFont({text=txt.name,fontFile = FONT_CFG_1,color=ccc3(dexToColor3B(COLOR_CREAM_STROKE)),size = 16,x=display.cx,y=380-23})
		self:addLabelEffect(scene)
		scene:addChild(self.nameLabel,ZORDER_SAILOR_EXP_UP)
		arr=CCArray:create()
		arr:addObject(CCMoveBy:create(1,ccp(0,50)))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.5,ccp(0,25)),CCFadeOut:create(0.5)))
		arr:addObject(CCCallFunc:create(function()
			self.nameLabel:removeFromParentAndCleanup(true)
			self.levelLabel:removeFromParentAndCleanup(true)
			self.nameLabel=nil
			self:showLabel()
		end))
		self.nameLabel:runAction(CCSequence:create(arr))
		table.remove(self.txts,1)
	end
end

function  SailorUpLevelData:addLabelEffect(parent)
	self.armatureTab = {
        "effects/tx_0047.ExportJson",
	}
	LoadArmature(self.armatureTab)
	local efffect = CCArmature:create("tx_0047")
	local armatureAnimation = efffect:getAnimation()
	armatureAnimation:addMovementCallback(function(eventType)
		if eventType == 1 then
			if #self.labelEffects > 0 then
				local efffectTmp = table.remove(self.labelEffects, 1)
				if not tolua.isnull(efffectTmp) then
					efffectTmp:removeFromParentAndCleanup(true)
				end
			end	
			UnLoadArmature(self.armatureTab)
		end
	end)
	armatureAnimation:playByIndex(0,-1,-1,0)
	self.labelEffects[#self.labelEffects + 1] = efffect
	local pos = ccp(display.cx, display.cy + 100)
	efffect:setPosition(pos)
	parent:addChild(efffect, ZORDER_SAILOR_EXP_UP + 5)
end

return SailorUpLevelData

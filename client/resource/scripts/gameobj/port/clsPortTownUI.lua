-- @author: mid
-- @date: 2016年11月15日11:06:13
-- @desc: 市政厅界面

-- include 引用
local clsPortInvestTabUI = require("gameobj/port/clsPortInvestTabUI")
local clsMunicipalWorkUI = require("gameobj/port/clsMunicipalWorkUI")
-- local clsPortBattleUI = require("gameobj/port/clsPortBattleUI")
local music_info = require("game_config/music_info")
local on_off_info=require("game_config/on_off_info")
local uiTools = require("gameobj/uiTools")
local voice_info = getLangVoiceInfo()

-- const define
-- 投资页签类型
local tab_type = {
	TAB_TYPE_INVEST = 1, --投资
	TAB_TYPE_MUNICIPAL_WORK = 2, --市政工作
	TAB_TYPE_PORT_BATTLE = 3, --港口争夺战
}

-- main logic 主逻辑
local clsPortTownUI = class("clsPortTownUI", require('ui/view/clsBaseView'))

function clsPortTownUI:getViewConfig()
    return {
        hide_before_view = true,
        effect = UI_EFFECT.FADE,
    }
end

-- 数据重置
function clsPortTownUI:resetData()
	self.tab_index = tab_type.TAB_TYPE_INVEST
	self.main_ui = nil
	self.tab_view = {}
end

-- 界面逻辑入口 参数入口
function clsPortTownUI:onEnter(tab_index)
	audioExt.playEffect(voice_info["VOICE_PLOT_1025"].res, false)
	self.is_finish_effect = false
	self:resetData()
	self:initConstData(tab_index)
	self:initUI()
	self:requestServerData()
end

-- 请求服务器数据
function clsPortTownUI:requestServerData()
	local port_id = getGameData():getPortData():getPortId()
	getGameData():getInvestData():sendPortInvest(port_id)
end

-- 初始化数据: 页签初始值,绑定控件列表,图片资源
function clsPortTownUI:initConstData(tab_index)
	self.tab_index = tab_index or tab_type.TAB_TYPE_INVEST
	self.res_img = {
		["ui/bg/bg_cityhall.jpg"] = "RGB565",
	}
	self.bind_wgts = {
		["btn_invest"] = {name = "tab_invest", on_off_key = on_off_info.TOWN_TAB_INVEST.value, btn_lbl = "tab_invest_text", task_keys = {
			on_off_info.PORT_TOWN.value,
		}},
		["btn_muninipal_work"] = {name = "tab_municipal", on_off_key = on_off_info.TOWN_WORK.value, btn_lbl = "tab_municipal_text", task_keys = {
			on_off_info.TOWN_WORK.value,
		}},
		-- ["btn_port_battle"] = {name = "tab_townwar", on_off_key = on_off_info.PORT_FIGHT.value, btn_lbl = "tab_townwar_text", task_keys = {
		-- 	on_off_info.PORT_FIGHT.value,
		-- }},
 	}
	LoadImages(self.res_img)
end

-- 初始化UI,包括两个子页签view
function clsPortTownUI:initUI()
	-- 主面板
	self.main_ui = GUIReader:shareReader():widgetFromJsonFile("json/cityhall.json")
	convertUIType(self.main_ui)
	self:addWidget(self.main_ui)

	self.tab_view = {
		[tab_type.TAB_TYPE_INVEST] = clsPortInvestTabUI.new(),
		[tab_type.TAB_TYPE_MUNICIPAL_WORK] = clsMunicipalWorkUI.new(),
	}
		
	-- --根据港口开放来决定是否显示争夺战页签
	-- local port_battle_data = getGameData():getPortBattleData()
	-- local port_data = getGameData():getPortData()
	-- local on_off_data = getGameData():getOnOffData()
	-- local is_open_port = port_battle_data:isOpenPort(port_data:getPortId()) 
	-- if is_open_port and on_off_data:isOpen(on_off_info.PORT_FIGHT.value) then
	-- 	self.tab_view[tab_type.TAB_TYPE_PORT_BATTLE] = clsPortBattleUI.new()
	-- end

	-- 初始化所有tab页签
	for k,v in pairs(self.tab_view) do
		self:addWidget(v)
	end

	-- 初始化需要绑定的控件
	local function init_bind_wgts()
		local task_data = getGameData():getTaskData()
		local on_off_data = getGameData():getOnOffData()
		for k, v in pairs(self.bind_wgts) do
			self[k] = getConvertChildByName(self.main_ui, v.name)
			if v.btn_lbl then
				self[k].btn_lbl = getConvertChildByName(self.main_ui, v.btn_lbl)
			end
			if v.task_keys then
				task_data:regTask(self[k], v.task_keys, KIND_RECTANGLE, v.on_off_key, 74, 33, true)
			end

			self[k]:setVisible(on_off_data:isOpen(v.on_off_key))
		end
	end
	-- 执行
	init_bind_wgts()
	-- 构建 按钮数组
	self.tab_btn = {
		[tab_type.TAB_TYPE_INVEST] = self.btn_invest,
		[tab_type.TAB_TYPE_MUNICIPAL_WORK] = self.btn_muninipal_work,
 	}

	-- --根据港口开放来决定是否显示争夺战页签
	-- self.btn_port_battle:setVisible(is_open_port and on_off_data:isOpen(on_off_info.PORT_FIGHT.value))
	-- if is_open_port and on_off_data:isOpen(on_off_info.PORT_FIGHT.value) then
	-- 	self.tab_btn[tab_type.TAB_TYPE_PORT_BATTLE] = self.btn_port_battle
	-- end

	-- 初始化按钮事件
	local function initTabBtnEvent()
		for k,v in pairs(self.tab_btn) do
			local function began_callback()
				-- 需要处理所有按钮的状态
				for kk,vv in pairs(self.tab_btn) do
					local state = (kk == self.tab_index)
					if state then
						local color = state and ccc3(dexToColor3B(COLOR_BTN_SELECTED)) or ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
						vv:setFocused(state)
						vv:setTouchEnabled(not state)
						setUILabelColor(vv.btn_lbl, color)
					end
				end
			end
			local function end_callback()
				-- 播放音效
				audioExt.playEffect(music_info.COMMON_BUTTON.res)
				-- self.tab_index = k
				self:showTabUI(k)
			end
			local function cancel_callback()
				-- 只处理当前按钮
				local color = ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
				v:setFocused(false)
				v:setTouchEnabled(true)
				setUILabelColor(v.btn_lbl, color)
			end

			v:addEventListener(began_callback,TOUCH_EVENT_BEGAN)
			v:addEventListener(end_callback,TOUCH_EVENT_ENDED)
			v:addEventListener(cancel_callback,TOUCH_EVENT_CANCELED)
		end
	end
	-- 执行
	initTabBtnEvent()
	self:showTabUI(self.tab_index)
end

function clsPortTownUI:open(key)
	local on_off_data = getGameData():getOnOffData()
	for k, v in pairs(self.bind_wgts) do
		self[k]:setVisible(on_off_data:isOpen(v.on_off_key))
	end
end

-- 外部接口,修改tab类型,随后执行刷新
function clsPortTownUI:showTabUI(tab_type)
	self.tab_index = tab_type
	for k,v in pairs(self.tab_btn) do
		local state = (k == tab_type)
		v:setFocused(state)
		v:setTouchEnabled(not state)
		local color = state and ccc3(dexToColor3B(COLOR_BTN_SELECTED)) or ccc3(dexToColor3B(COLOR_BTN_UNSELECTED))
		setUILabelColor(v.btn_lbl,color)
	end
	
	for k,v in pairs(self.tab_view) do
		local is_show = (tab_type == k)
		v:setVisible(is_show and self.is_finish_effect)
		v:setEnabled(is_show and self.is_finish_effect)
		v:setTouchEnabled(is_show and self.is_finish_effect)
	end
	-- 刷新界面
	self:updateUI()
end

--界面关闭特效的调用
function clsPortTownUI:showEffectClose()
	self:effectClose()
end

--过场动画已完成的回调
function clsPortTownUI:onFadeFinish()
	self.is_finish_effect = true
	self:showTabUI(self.tab_index)
end

-- 外部接口,如果指定页签,则刷新指定页签,如果没有刷新当前页签
function clsPortTownUI:updateUI(index, ...)

	local tab

	if index then
		tab = self.tab_view[index]
	else
		tab = self.tab_view[self.tab_index]
	end

	if tolua.isnull(tab) then
		return 
	end

	if not tab:isVisible() then return end

	tab:updateUI(...)
end

-- 获取tab对象,用于执行其中的方法
function clsPortTownUI:getTab(tabIndx)
	local tab = self.tab_view[tabIndx]
	return tab
end

-- 获取当前界面的tab类型
function clsPortTownUI:getTabType()
	return tab_type
end

-- 旧接口 保留...其实看着就好想干掉它 这哪像接口
function clsPortTownUI:updateLabelCallBack()
	if type(self.old_node.updateLabelCallBack) == "function" then
		self.old_node:updateLabelCallBack()
	end
end

-- 退出界面时候的资源清理
function clsPortTownUI:onExit()
	UnLoadImages(self.res_img)
	ReleaseTexture(self)
end

return clsPortTownUI

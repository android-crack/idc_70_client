--************************************--
-- author: hal
-- data: 2015-08-11
-- descript: 显示图片
--
-- modify:
-- who         data            reason
--
--
--************************************--

-- 操作动作，要做啥由func完成
-- 这个函数写下的时候，我啥也不知道，导表代码会生成这个函数
local ClsAIActionBase = require("gameobj/battle/ai/ai_action")
local ClsAIActionShowImages = class("ClsAIActionShowImages", ClsAIActionBase) 

function ClsAIActionShowImages:getId()
	return "show_images"
end

-- 
function ClsAIActionShowImages:initAction( filename, position, tag, scale, parent_tag, is_fadein, duraction, format, audio_delay, audio_filename )
	-- body
	local images_config = {};

	images_config[ 1 ] = filename;							-- 资源路径
	images_config[ 2 ] = { position[1], position[2] };		-- 位置
	images_config[ 3 ] = tag;								-- 是否主动技能
	images_config[ 4 ] = scale;								-- 缩放比例，默认不缩放
	images_config[ 5 ] = parent_tag;						-- 放哪一层，默认第一层
	images_config[ 6 ] = is_fadein;							-- 是否淡入，默认不淡入
	images_config[ 7 ] = duraction;							-- 淡入时间，不填默认1
	images_config[ 8 ] = format;							-- 压缩格式，不填默认 RGBA8888
	if audio_filename ~= nil then
		images_config[ 9 ] = { audio_delay, audio_filename };	-- { 音频延迟, 音频文件 }
	end

	self.images_config = images_config;

end

local battlePlot = require("gameobj/battle/battlePlot")
function ClsAIActionShowImages:__dealAction( target_id, delta_time )
	-- body
	local ai_obj = self:getOwnerAI();
	if not ai_obj then return end

	battlePlot:add_sprite( self.images_config );

end

return ClsAIActionShowImages

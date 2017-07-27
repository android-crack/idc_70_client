local config = require("root/baseConfig")

GTab = {}

GTab.OPEN_ANIMATION_RES = "res/movie/tencent.mp4"
GTab.FILELIST = "filelist.lua"
GTab.TMP_PATH      = "dhh_update_tmp"
GTab.RES_PATH      = "dhh.game.qtz.com"
GTab.DEFAULT_PATH  = CCFileUtils:sharedFileUtils():getWritablePath()
GTab.UPDATE_TMP_PATH   = GTab.DEFAULT_PATH .. GTab.TMP_PATH
GTab.UPDATE_RES_PATH   = GTab.DEFAULT_PATH .. GTab.RES_PATH

GTab.BASE_FIX_URL = config.fix_info_url
GTab.BASE_FIX_INFO = config.fix_info_name

GTab.BASE_UPDATE_RUL = config.update_info_url
GTab.BASE_UPDATE_INFO = config.update_info_name

GTab.LANGUAGE = config.language
GTab.CHANNEL_ID = config.channel_id
GTab.AREA = config.area or "dev"

-- dev 有打印，其他一律关打印
DEBUG = 1
if GTab.AREA ~= "dev" then 
	print = function() end
	DEBUG = 0
end 

-- 米大师支付环境
GTab.MIDAS_IAP_ENV = config.midas or "test"

GTab.APP_URL = nil
GTab.APP_VERSION = QtzGetAppVersion()

-- 服务器资源版本、打包时的版本、 更新后包内的版本（每次更新会变）
GTab.VERSION_SERVER = config.version 
GTab.VERSION_PACK = config.version
GTab.VERSION_UPDATE = config.versoin 

	
-- 审核相关
GTab.VERIFY_APP_VERSION = nil
GTab.VERIFY_VERSION = nil
GTab.VERIFY_SERVER_LIST = nil
GTab.IS_VERIFY = false
	
-- 允许最小app版本更新
GTab.MIN_APP_VERSION = nil
	
	
-- filelist md5
GTab.FILELIST_MD5 = nil

GTab.RESOURCE_URL = nil 
GTab.SPEED_URL = nil
GTab.SERVER_LIST = nil

GTab.SKIP_UPDATE = (config.skip_update == "true")
GTab.IS_UPDATEING = nil




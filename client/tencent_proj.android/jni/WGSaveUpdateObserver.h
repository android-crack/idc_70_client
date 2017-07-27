/*
 *
 */
#ifndef WGSaveUpdateObserver_h
#define WGSaveUpdateObserver_h

#include <string>

class WGSaveUpdateObserver
{
public:
	/**
	 * 检查应用宝后台是否有更新包的回调, 如果有更新包，则返回新包大小、增量包大小, 游戏结合此接口返回结果和自身业务场景确定是否弹窗提示用户更新
	 * @param newApkSize apk文件大小(全量包)
	 * @param newFeature 新特性说明
	 * @param patchSize 省流量升级包大小
	 * @param status 值为TMSelfUpdateSDKUpdateInfo(WGPublicDefine.h中有定义), 游戏根据此值来确定是否弹窗提示用户更新
	 * @param updateDownloadUrl 更新包的下载链接
	 * @param updateMethod
	 */
	virtual void OnCheckNeedUpdateInfo(long newApkSize, std::string newFeature,
			long patchSize, int status, std::string updateDownloadUrl, int updateMethod) = 0;

	/**
	 * 此回调分为两种情况, 省流量更新(WGStartSaveUpdate)和普通更新(WGStartCommonUpdate)
	 * 	 1. 省流量更新时, 此回调表示应用在应用宝下载页面的的下载进度
	 * 	 2. 普通更新时, 此回调表示下载调用方新包或者patch包的进度
 	 * @param receiveDataLen 已经接收的数据长度
 	 * @param totalDataLen 全部需要接收的数据长度（如果无法获取目标文件的总长度，此参数返回 －1）
	 */
	virtual void OnDownloadAppProgressChanged(long receiveDataLen, long totalDataLen)= 0;

	/**
	 * 此回调分为两种情况, 省流量更新(WGStartSaveUpdate)和普通更新(WGStartCommonUpdate)
	 * 	 1. 省流量更新时, 此回调表示应用在应用宝下载页面的的下载状态
	 * 	 2. 普通更新时, 此回调表示下载调用方新包或者patch包的状态
	 * @param state 下载状态 TMAssistantDownloadSDKTaskState(WGPublicDefine.h中有定义)(省流量更新，跳应用宝进行自更新) 或 TMSelfUpdateSDKTaskState(WGPublicDefine.h中有定义)(使用sdk自更新)
	 * @param errorCode TMAssistantDownloadSDKErrorCode(WGPublicDefine.h中有定义)(省流量更新，跳应用宝进行自更新) 或 TMSelfUpdateSDKErrorCode(WGPublicDefine.h中有定义)(使用sdk自更新) 错误码
	 * @param errorMsg 错误信息
	 */
	virtual void OnDownloadAppStateChanged(int state, int errorCode, std::string errorMsg) = 0;


	/**
	 * 省流量更新(WGStartSaveUpdate)，当没有安装应用宝时，会先下载应用宝, 此为下载应用宝包的进度回调
	 * (可选, 游戏可以自行确定是否需要显示下载应用宝的进度, 应用宝下载完成以后会自动拉起系统安装界面)
	 * @param url 当前任务的url
	 * @param receiveDataLen 已经接收的数据长度
	 * @param totalDataLen 全部需要接收的数据长度（如果无法获取目标文件的总长度，此参数返回 －1）
	 */
	virtual void OnDownloadYYBProgressChanged(std::string url, long receiveDataLen, long totalDataLen) = 0;

	/**
	 * 省流量更新(WGStartSaveUpdate)，当没有安装应用宝时，会先下载应用宝, 此为下载应用宝包的状态太变化回调
	 * (可选, 游戏可以自行确定是否需要显示下载应用宝的状态, 应用宝下载完成以后会自动拉起系统安装界面)
	 * @param url 指定任务的url
	 * @param state 下载状态: 取自 TMAssistantDownloadSDKTaskState.DownloadSDKTaskState_*
	 * @param errorCode 错误码
	 * @param errorMsg 错误描述，有可能为null
	 */
	virtual void OnDownloadYYBStateChanged(std::string url, int state, int errorCode, std::string errorMsg)= 0;
	virtual ~WGSaveUpdateObserver() {};
};

#endif

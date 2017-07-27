/*
 * tss_sdk.h
 *
 *  Created on: 2013-3-14
 *      Author: gavin gu
 */

#ifndef TSS_SDK_H
#define TSS_SDK_H

#include <stdio.h>
#include <stdint.h>

#pragma pack(push, 1)

/* anti数据信息 */
/* anti data info*/
struct TssSdkAntiDataInfo
{
    unsigned short anti_data_len_;   /* [in] length of anti data */
    const unsigned char *anti_data_; /* [in] anti data buffer */
};

/* 发送Anti数据，需由游戏实现 */
/* send anti data, need to be implement by game */
typedef bool (*tss_sdk_send_data_to_svr)(const struct TssSdkAntiDataInfo *anti_data);

struct TssSdkInitInfo
{
	unsigned int size_;                           // struct size
	unsigned int game_id_;                        // game id
	tss_sdk_send_data_to_svr send_data_to_svr_;   // callback interface,implement by game
};

enum TssSdkEntryId
{
	ENTRY_ID_QZONE		= 1,       	// QZone
	ENTRY_ID_MM			= 2,       	// wechat
	ENTRT_ID_FACEBOOK	= 3,		// facebook
	ENTRY_ID_TWITTER	= 4,		// twitter
	ENTRY_ID_LINE		= 5,		// line
	ENTRY_ID_WHATSAPP	= 6,		// whatsapp
	ENTRY_ID_OTHERS		= 99,       // other platform
};

enum TssSdkUinType
{
	UIN_TYPE_INT = 1, // integer format
	UIN_TYPE_STR = 2, // string format
};

enum TssSdkAppIdType
{
    APP_ID_TYPE_INT = 1, // integer format
	APP_ID_TYPE_STR = 2, // string format
};

struct TssSdkUserInfo
{
	unsigned int size_;      // struct size
	unsigned int entry_id_;  // entrance id, wechat/open platform and so on.
	struct
	{
		unsigned int type_;  // type of uin, refer to TssSdkUinType
		union
		{
			unsigned int uin_int_;   // for integer format uin
			char uin_str_[64];       // for string format uin
		};
	}uin_;

    struct
    {
        unsigned int type_;
        union
        {
            unsigned int app_id_int_;   // for integer format appid
			char app_id_str_[64];       // for string format appid
        };
    }app_id_;
};

struct TssSdkUserInfoEx
{
    unsigned int size_;      // struct size
    unsigned int entry_id_;  // entrance id, wechat/open platform and so on.
    struct
    {
        unsigned int type_;  // type of uin, refer to TssSdkUinType
        union
        {
            unsigned int uin_int_;   // for integer format uin
            char uin_str_[64];       // for string format uin
        };
    }uin_;

    struct
    {
        unsigned int type_;
        union
        {
            unsigned int app_id_int_;   // for integer format appid
            char app_id_str_[64];       // for string format appid
        };
    }app_id_;

    unsigned int world_id_;
    char role_id_[64];
};

enum TssSdkGameStatus
{
    GAME_STATUS_FRONTEND = 1,  // runing in front-end
    GAME_STATUS_BACKEND  = 2,  // runing in back-end
};

struct TssSdkGameStatusInfo
{
	unsigned int size_;        // struct size
	unsigned int game_status_; // running in front-end or back-end
};

struct TssSdkEncryptPkgInfo
{
    unsigned int cmd_id_;                     /* [in] game pkg cmd */
    const unsigned char *game_pkg_;           /* [in] game pkg */
    unsigned int game_pkg_len;                /* [in] the length of game data packets, maximum length less than 65,000 */
    unsigned char *encrypt_data_;             /* [in/out] assembling encrypted game data package into anti data, memory allocated by the caller, 64k at the maximum */
    unsigned int encrypt_data_len_;           /* [in/out] length of anti_data when input, actual length of anti_data when output */
};

struct TssSdkDecryptPkgInfo
{
    const unsigned char *encrypt_data_;     /* [in] anti data received by game client */
    unsigned int encrypt_data_len;          /* [in] length of anti data received by game client */
    unsigned char *game_pkg_;               /* [out] buffer used to store the decrypted game package, space allocated by the caller */
    unsigned int game_pkg_len_;             /* [out] input is size of game_pkg_, output is the actual length of decrypted game package */
};

enum TssSdkAntiEncryptResult
{
    ANTI_ENCRYPT_OK = 0,
    ANTI_NOT_NEED_ENCRYPT = 1,
};

enum TssSdkAntiDecryptResult
{
    ANTI_DECRYPT_OK = 0,
    ANTI_DECRYPT_FAIL = 1,
};

#pragma pack(pop)

#ifdef __cplusplus
extern "C"{
#endif

/**
 * @brief game client calls this interface to set initialization information when game starts
 *
 * @param[in] init_info pointing to data of initialization information, defined in TssSdkInitInfo
 *
 */

void __attribute__((visibility("default"))) tss_sdk_init(const struct TssSdkInitInfo* init_info);

/**
 * @brief game client calls this interface to set user information when login in game
 *
 * @param[in] user_info pointing to data of initialization information, defined in TssSdkUserInfo
 *
 * @warning: this interface is expired, call tss_sdk_setuserinfo_ex instead
 *
 */
void __attribute__((visibility("default"))) tss_sdk_setuserinfo(const struct TssSdkUserInfo* user_info);


/**
 * @brief game client calls this interface to set user information when login in game
 *
 * @param[in] user_info pointing to data of initialization information, defined in TssSdkUserInfo
 *
 */
void __attribute__((visibility("default"))) tss_sdk_setuserinfo_ex(const struct TssSdkUserInfoEx* user_info);


/**
 * @brief game client calls this interface to notify the security component game's current status
 *
 * @param[in] game_status if game running in front-end, set it to GAME_STATUS_FRONTEND, if game running in back-end, set it to GAME_STATUS_BACKEND
 */

void __attribute__((visibility("default"))) tss_sdk_setgamestatus(const struct TssSdkGameStatusInfo* game_status);

/**
* @brief Game client calls this interface to encrypt game's packets
*
* @param[in] anti_data Pointing to anti data, defined in TssSdkAntiDataInfo
*
*/
void __attribute__((visibility("default"))) tss_sdk_rcv_anti_data(const struct TssSdkAntiDataInfo *anti_data);

/**
* @brief Game client calls this interface to encrypt game's packets
*
* @param[in] encrypt_pkg_info Pointing to game's packets need encrypting, defined in ENCRYPTPKGINFO
*
* @return refer to the definition of TssSdkAntiEncryptResult.
*/
enum TssSdkAntiEncryptResult __attribute__((visibility("default"))) tss_sdk_encryptpacket(struct TssSdkEncryptPkgInfo *encrypt_pkg_info);

/**
* @brief Game client calls this interface as soon as receives anti packets from game server
*
* @param[in] decrypt_pkg_info Pointing to game's packets need decrypting, defined in DECRYPTPKGINFO
*
* @return refer to the definition of TssSdkAntiDecryptResult
*/
enum TssSdkAntiDecryptResult __attribute__((visibility("default"))) tss_sdk_decryptpacket(struct TssSdkDecryptPkgInfo *decrypt_pkg_info);

/**
* @brief Game client calls this interface as soon as receives game packets from game server
*
* @param[in] cmd_id Pointing to game's packets cmd
*
* @return If return 0, game client does nothing, if return 1, game client needs to discard this packet.
*/
bool __attribute__((visibility("default"))) tss_sdk_ischeatpacket(const unsigned int cmd_id);

/**
 * @brief Game client calls this interface to retrieve a TssSdkAntiDataInfo struct data 
 * [support arm64]
 */
intptr_t __attribute__((visibility("default"))) tss_get_report_data();

/**
 * @brief Game client calls this interface to release a TssSdkAntiDataInfo struct data which return by tss_get_report_data interface
 */
void __attribute__((visibility("default"))) tss_del_report_data(struct TssSdkAntiDataInfo *data);


void __attribute__((visibility("default"))) tss_enable_get_report_data();


void __attribute__((visibility("default"))) tss_log_str(const char *str);
    



#ifdef __cplusplus
}
#endif


#endif /* TSS_SDK_H */

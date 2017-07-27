#ifndef AFX_CRYPT_H__A05365F3_110F_4771_A093_37F147F3CB94__INCLUDED_
#define AFX_CRYPT_H__A05365F3_110F_4771_A093_37F147F3CB94__INCLUDED_

#include "QQTypeDefine.h"
#include "QQGlobeVariable.h"

#define	SESSION_KEY_SIZE  16

QQINT QQBFindEncryptSize(QQINT nLen);
QQVOID	QQBEncryptNew(QQBYTE* pInBuf, QQUINT nInBufLen, QQBYTE* pOutBuf, QQUINT* pOutBufLen);
QQBOOL	QQBDecryptNew(QQBYTE* pInBuf, QQUINT nInBufLen, QQBYTE* pOutBuf, QQUINT* pOutBufLen);

QQVOID	QQBEncryptNewWithKey(QQBYTE* pInBuf, QQUINT nInBufLen, QQBYTE* pOutBuf, QQUINT* pOutBufLen, QQCHAR* key);
QQBOOL	QQBDecryptNewWithKey(QQBYTE* pInBuf, QQUINT nInBufLen, QQBYTE* pOutBuf, QQUINT* pOutBufLen, QQCHAR* key);

/*pKey为16byte*/
/*
 输入:nInBufLen为需加密的明文部分(Body)长度;
 输出:返回为加密后的长度(是8byte的倍数);
 */
/*TEA加密算法,CBC模式*/
/*密文格式:PadLen(1byte)+Padding(var,0-7byte)+Salt(2byte)+Body(var byte)+Zero(7byte)*/
int oi_symmetry_encrypt2_len(int nInBufLen);

/*pKey为16byte*/
/*
 输入:pInBuf为需加密的明文部分(Body),nInBufLen为pInBuf长度;
 输出:pOutBuf为密文格式,pOutBufLen为pOutBuf的长度是8byte的倍数,至少应预留nInBufLen+17;
 */
/*TEA加密算法,CBC模式*/
/*密文格式:PadLen(1byte)+Padding(var,0-7byte)+Salt(2byte)+Body(var byte)+Zero(7byte)*/
void oi_symmetry_encrypt2(const QQBYTE* pInBuf, long nInBufLen, QQBYTE* pKey, QQBYTE* pOutBuf, long *pOutBufLen);
/*默认密钥*/
void QQB_symmetry_encrypt2(const QQBYTE* pInBuf, long nInBufLen,QQBYTE* pOutBuf, long *pOutBufLen);

/*pKey为16byte*/
/*
 输入:pInBuf为密文格式,nInBufLen为pInBuf的长度是8byte的倍数; *pOutBufLen为接收缓冲区的长度
 特别注意*pOutBufLen应预置接收缓冲区的长度!
 输出:pOutBuf为明文(Body),pOutBufLen为pOutBuf的长度,至少应预留nInBufLen-10;
 返回值:如果格式正确返回TRUE;
 */
/*TEA解密算法,CBC模式*/
/*密文格式:PadLen(1byte)+Padding(var,0-7byte)+Salt(2byte)+Body(var byte)+Zero(7byte)*/
QQBOOL oi_symmetry_decrypt2(QQBYTE* pInBuf, int nInBufLen, QQBYTE* pKey, QQBYTE* pOutBuf, int *pOutBufLen);
/*默认密钥*/
QQBOOL QQB_symmetry_decrypt2(QQBYTE* pInBuf, int nInBufLen, QQBYTE* pOutBuf, int *pOutBufLen);

#endif 
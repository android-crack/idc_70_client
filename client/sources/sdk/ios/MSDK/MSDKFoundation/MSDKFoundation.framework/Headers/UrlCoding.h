#ifndef URL_H
#define URL_H

#ifdef __cplusplus
extern "C" {
#endif
    
//    int php_url_decode(const char *str, int len, char *out, int *outLen);
    long php_url_decode(const char *str, int len, char *out, long *outLen);
//    char *php_url_encode(char const *s, int len, long *new_length);
    char *php_url_encode(char const *s, int len, long *new_length);
//    int php_url_decode_special(const char *str, int len, char *out, int *outLen);
    long php_url_decode_special(const char *str,unsigned long len, char *out, long *outLen);
#ifdef __cplusplus
}
#endif

#endif /* URL_H */

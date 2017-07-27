
package com.dhh.xfyun;

public class Speex  {

	/* quality
	 * 1 : 4kbps (very noticeable artifacts, usually intelligible)
	 * 2 : 6kbps (very noticeable artifacts, good intelligibility)
	 * 4 : 8kbps (noticeable artifacts sometimes)
	 * 6 : 11kpbs (artifacts usually only noticeable with headphones)
	 * 8 : 15kbps (artifacts not usually noticeable)
	 */
	//private static final int DEFAULT_COMPRESSION = 4;

	public static native int decode(byte encoded[], byte lin[], int size, short rate[]);
	public static native int encode(byte lin[], byte encoded[], int size, int compress);
	
}

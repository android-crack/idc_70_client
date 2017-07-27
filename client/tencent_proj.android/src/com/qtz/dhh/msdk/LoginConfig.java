package com.qtz.dhh.msdk;

public class LoginConfig {
	
	public static String openId = "";
	public static String qqPayToken = "";
	public static String qqAccessToken = "";
	
	public static String userId   	= "";    
	public static String userKey 		= "";  
	public static String sessionId 	= "";   
	public static String sessionType	= "";  
	public static String zoneId  		= "";   
	public static String saveValue 	= "";   
	public static String pf 			= "";   
	public static String pfKey		= "";  
	public static String acctType     = "";
	public static boolean isCanChange = false;
	
    
    public static String toStr() {
    	
    	return "{openId:"  + openId  + ", qqAccessToken:" + qqAccessToken + "}";
    }
    
}

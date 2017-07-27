package com.qtz.dhh;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.pm.PackageManager.NameNotFoundException;
import android.util.Log;

import java.io.DataOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.InputStream; 
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.lang.Thread.UncaughtExceptionHandler;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.ProtocolException;
import java.net.URL;
import java.util.ArrayList;
import java.security.MessageDigest;
import org.apache.http.Header;

import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;

public class QCrashHandler implements UncaughtExceptionHandler {
	public static final String TAG = "QCrashHandler";
	private static String mPackageName;
	private static Context mContext;
	private static PackageManager mPackageManager;
	private static PackageInfo mPackageInfo;
	private static UncaughtExceptionHandler mDefaultHandler;
	
	public QCrashHandler(Context context) {
		QCrashHandler.mContext 			= context;
		QCrashHandler.mPackageManager	= QCrashHandler.mContext.getPackageManager();
		QCrashHandler.mPackageName		= QCrashHandler.mContext.getPackageName();
		QCrashHandler.mDefaultHandler	= Thread.getDefaultUncaughtExceptionHandler();
		Thread.setDefaultUncaughtExceptionHandler( this );
		QCrashHandler.sendCrashFilesToServer();
	}
	
	public static String getAppName(){
		String appName = "dhh";
		return appName;
	}
	
	public static String getVersionName(){
		String versionName = "";
		try {
			versionName = QCrashHandler.mPackageManager.getPackageInfo(QCrashHandler.mPackageName, 0).versionName;
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}
		return versionName;
	}
	
	public static String getTags(){
		return "android";
	}
	
	public static String getCrashPath(){
		String crashPath = QCrashHandler.mContext.getFilesDir().getAbsolutePath() + File.separator + "crashes";
		File path = new File( crashPath );
		path.mkdirs();
		return crashPath;
	}
	
	public static String[] getCrashFiles(){
		File path = new File(QCrashHandler.getCrashPath());
		File[] crashes = path.listFiles(new FileFilter(){
			@Override
			public boolean accept(File file) {
				if(file.getName().endsWith(".crash")){
					return true;
				}
				return false;
			}
			
		});
		
		ArrayList<String> crashFilesList = new ArrayList<String>();
		for(File file : crashes){
			crashFilesList.add( file.getAbsolutePath() );
		}
		
		String[] crashFilesArray = new String[ crashFilesList.size() ];
		crashFilesList.toArray( crashFilesArray );
		return crashFilesArray;
	}
	
	public static String getCrashFileName(){
		return QCrashHandler.getAppName() + "-" + System.currentTimeMillis() + ".crash";
	}
	
	public static void sendCrashFileToServer(String crashFile){
		String sUrl = "http://test.api.q3.175game.com/reports/api/v1/reports";
		final String end = "\r\n";
		final String twoHyphens = "--";
		final String boundary = "*****++++++************++++++++++++";

		URL url;
		try {
			url = new URL(sUrl);
		} catch (MalformedURLException e) {
			e.printStackTrace();
			return;
		}
		HttpURLConnection conn;
		try {
			conn = (HttpURLConnection)url.openConnection();
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}

		conn.setDoInput(true);
		conn.setDoOutput(true);
		conn.setUseCaches(false);
		try {
			conn.setRequestMethod("POST");
		} catch (ProtocolException e) {
			e.printStackTrace();
			return;
		}

		/* setRequestProperty */
		conn.setRequestProperty("Connection", "Keep-Alive");
		conn.setRequestProperty("Charset", "UTF-8");
		conn.setRequestProperty("Content-Type", "multipart/form-data;boundary="+ boundary);
		
		String filename = crashFile;
		int start	= crashFile.lastIndexOf("/");
        if(start!=-1){  
        	filename = crashFile.substring(start+1,crashFile.length());
        }
		
		DataOutputStream ds;
		try {
			ds = new DataOutputStream(conn.getOutputStream());
			ds.writeBytes(twoHyphens + boundary + end);
			ds.writeBytes("Content-Disposition: form-data; name=\"app\""+end+end+QCrashHandler.getAppName()+end);
			ds.writeBytes(twoHyphens + boundary + end);
			ds.writeBytes("Content-Disposition: form-data; name=\"version\""+end+end+QCrashHandler.getVersionName()+end);
			ds.writeBytes(twoHyphens + boundary + end);
			ds.writeBytes("Content-Disposition: form-data; name=\"tags\""+end+end+QCrashHandler.getTags()+end);
			ds.writeBytes(twoHyphens + boundary + end);
			ds.writeBytes("Content-Disposition: form-data; name=\"file\";filename=\"" + filename +"\"" + end);
			ds.writeBytes("Content-Type: text/plain"+end+end);
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
		

		FileInputStream fStream;
		try {
			fStream = new FileInputStream(crashFile);
		} catch (FileNotFoundException e) {
			e.printStackTrace();
			return;
		}
		int bufferSize = 1024;
		byte[] buffer = new byte[bufferSize];
		int length = -1;

		try {
			while((length = fStream.read(buffer)) != -1) {
			  ds.write(buffer, 0, length);
			}
			ds.writeBytes(end);
			ds.writeBytes(twoHyphens + boundary + twoHyphens + end);
			fStream.close();
			ds.flush();
			ds.close();
			if(conn.getResponseCode() == HttpURLConnection.HTTP_OK){
				File fCrashFile = new File(crashFile);
				if (fCrashFile.delete() == false){
					Log.e(TAG, "delete crash file error");
				}
			}
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
		/*
		StringBuffer b = new StringBuffer();
		InputStream is;
		try {
			is = conn.getInputStream();
			byte[] data = new byte[bufferSize];
			int leng = -1;
			while((leng = is.read(data)) != -1) {
			  b.append(new String(data, 0, leng));
			}
			String result = b.toString();
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}
		*/
	}
	
	public static String fileMD5(String filename){
		InputStream fis;
		byte[] buffer = new byte[1024];
		int numRead = 0;
		MessageDigest md5;
		try{
			fis = new FileInputStream(filename);
			md5 = MessageDigest.getInstance("MD5");
			while((numRead=fis.read(buffer)) > 0) {
				md5.update(buffer,0,numRead);
			}
			fis.close();
			
			return getString(md5.digest());
		} catch (Exception e) {
				System.out.println("error");
				return null;
		}
	}
	
	private static String getString(byte[] b){
		StringBuffer buf = new StringBuffer();
		for(int i = 0; i < b.length; i ++){
			int v = b[i];
			if (v < 0)
				v += 256;
			if (v < 16)
				buf.append("0");
			buf.append(Integer.toHexString(v));
			//buf.append(b[i]);
		}
		return buf.toString();
	}

	
	public static void uploadToServer( final String filepath ){
		String url = "http://test.api.q3.175game.com/reports/api/v1/reports";
		RequestParams params = new RequestParams();
		params.put("Connection", "Keep-Alive");
		params.put("Charset", "UTF-8");
		params.put("Content-Type", "multipart/form-data");
		
		String md5Str = fileMD5(filepath);
		if(md5Str != null)
		{
			params.put("checksum", md5Str);
		}
		
		params.put("app", getAppName());
		params.put("tags", getTags());
		params.put("version", getVersionName());
		
		String filename = filepath;
		int start = filepath.lastIndexOf("/");
		if(start!=-1){
			filename = filepath.substring(start+1, filepath.length());
		}
		
		File f = new File(filepath);
		try{
			params.put("file", f, filename);
		}catch(FileNotFoundException e){
			Log.e(TAG, "File not existed:" + filepath);
			return;
		}
		AsyncHttpClient client = new AsyncHttpClient();
		Log.i(TAG, "START TO UPLOAD CRASH FILE: " + filepath );
		client.post(url, params, new AsyncHttpResponseHandler(){
			@Override
			public void onFailure(int arg0, Header[] arg1, byte[] arg2,
					Throwable arg3) {
				Log.e( TAG, "Upload file error: " + filepath);	
			}

			@Override
			public void onSuccess(int arg0, Header[] arg1, byte[] arg2) {
				if( arg0 == 200 ){
					File file = new File( filepath );
					if( file.delete() == false ){
						Log.e(TAG, "Delete file error: " + filepath );
					}
				}
			}
	
		});
	}
	
	public static void sendCrashFilesToServer(){
		for( String crashFile : QCrashHandler.getCrashFiles() ){
			Log.e(TAG, crashFile);
			uploadToServer(crashFile);
			//QCrashHandler.sendCrashFileToServer(crashFile);
		}
	}

	@Override
	public void uncaughtException(Thread arg0, Throwable exception) {
		QCrashHandler.saveExceptionMsgToFile( exception.getLocalizedMessage() );
	}
	
	public static String getHandSetInfo(){ 
		String handSetInfo= 
		"手机型号:" + android.os.Build.MODEL + 
		"\nSDK版本:" + android.os.Build.VERSION.SDK + 
		"\n系统版本:" + android.os.Build.VERSION.RELEASE+ 
		"\n软件版本:" + getVersionName() + "\n"; 
		return handSetInfo; 
	} 

	
	public static void saveExceptionMsgToFile(String exceptionMsg){
		try {
			FileWriter out = new FileWriter(new File( QCrashHandler.getCrashPath(), 
													  QCrashHandler.getCrashFileName()), true);
			out.write(getHandSetInfo());
			out.write(exceptionMsg);
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
			Log.e(TAG, "Save crash file Error!");
		}
	}
	
	public static void onNativeCrashed(String exceptionMsg){
		QCrashHandler.saveExceptionMsgToFile( exceptionMsg );
	}
}

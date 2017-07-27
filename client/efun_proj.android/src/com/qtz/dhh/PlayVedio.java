package com.qtz.dhh;


import com.aseugame.ahh.sm.Dhh;

import android.content.Intent;


public class PlayVedio {

	public static Dhh context = null;
	public static Intent intent = null;
	
	public static void playVideo(String videoFileName){
		intent.addFlags( Intent.FLAG_ACTIVITY_NO_ANIMATION );
		intent.putExtra("videoFileName", videoFileName);
		context.startActivity(intent);
	}
}

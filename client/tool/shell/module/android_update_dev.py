import os

projects =  [
    "../../../proj.android",
    "../../../tencent_proj.android",
    "../../../android_sdk/DhhLibrary",
    "../../../android_sdk/E-PD-V2-OS-EPD-SDK-2.6.8.1",
    "../../../android_sdk/Efun-smhy-Google-561171",
    "../../../android_sdk/FacebookSDK-4.5.1",
    "../../../android_sdk/MSDKLibrary",
    "../../../android_sdk/MidasLibrary",
    "../../../android_sdk/SafeSDKLibrary",
    "../../../android_sdk/XFYunLibrary",
    "../../../../gameplay3d/lib/cocos2d-x/cocos2dx/platform/android/java"
]

def update_project( path ):
    os.system( "android update project -p %s -t android-21" % path )


if __name__ == "__main__":
    map( update_project, projects )

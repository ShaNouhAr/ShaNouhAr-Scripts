@echo off

REM ADB Patch
cd "c:\adb\"

REM Device Information (optional)
REM adb -s 68ae062d shell wm density
REM adb -s 68ae062d shell wm size 
REM adb -s 68ae062d shell getprop ro.product.model
REM adb -s 68ae062d shell getprop ro.build.version.release
REM adb -s 68ae062d shell getprop ro.product.board
REM adb -s 68ae062d shell dumpsys battery

REM Screen
adb -s 68ae062d shell wm size 1920x1080
adb -s 68ae062d shell wm density 215
adb -s 68ae062d shell settings put system font_scale  1.20

REM Launcher
adb -s 68ae062d shell settings put global policy_control immersive.full=*
adb -s 68ae062d shell pm enable com.farmerbb.taskbar
adb -s 68ae062d shell pm disable-user bitpit.launcher
adb -s 68ae062d shell cmd package set-home-activity com.farmerbb.taskbar/.activity.HomeActivity
adb -s 68ae062d shell cmd notification allow_listener com.farmerbb.taskbar/com.farmerbb.taskbar.service.NotificationCountService
adb -s 68ae062d shell settings put secure enabled_accessibility_services com.farmerbb.taskbar/.a.i
adb -s 68ae062d shell pm grant com.farmerbb.taskbar android.permission.WRITE_SECURE_SETTINGS
adb -s 68ae062d shell settings put global enable_freeform_support 1
adb -s 68ae062d shell am start -W -c android.intent.category.HOME -a android.intent.action.MAIN

REM Rotation
adb -s 68ae062d shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:0

REM Keyboard
adb -s 68ae062d shell ime set com.wparam.nullkeyboard/.NullKeyboard

REM Stuff
adb -s 68ae062d shell cmd vibrator vibrate 100
adb -s 68ae062d shell cmd vibrator vibrate 100
adb -s 68ae062d shell cmd vibrator vibrate 100
adb -s 68ae062d shell cmd vibrator vibrate 100
timeout /t 1 /nobreak >nul

REM Scrcpy
scrcpy -s 68ae062d --render-driver=direct3d --rotation 0 -m1920 -b60M --max-fps 60 -f -Sw --disable-screensaver --window-title 'ANDROID-DESKTOP'


REM Screen
adb -s 68ae062d shell wm size reset
adb -s 68ae062d shell wm density reset
adb -s 68ae062d shell settings put system font_scale  1.0
timeout /t 1 /nobreak >nul

REM Rotation
adb -s 68ae062d shell content insert --uri content://settings/system --bind name:s:accelerometer_rotation --bind value:i:1

REM Keyboard
adb -s 68ae062d shell ime set com.google.android.inputmethod.latin/com.android.inputmethod.latin.LatinIME

REM Launcher
adb -s 68ae062d shell settings put global policy_control null*
adb -s 68ae062d shell pm enable bitpit.launcher
adb -s 68ae062d shell pm disable-user com.farmerbb.taskbar
adb -s 68ae062d shell cmd package set-home-activity bitpit.launcher/.ui.HomeActivity
adb -s 68ae062d shell am start -W -c android.intent.category.HOME -a android.intent.action.MAIN

REM Stuff
adb -s 68ae062d shell cmd vibrator vibrate 100

timeout /t 10 /nobreak >nul
# BLE Arduino Car Controller

## Brief

It is a remote controller of an Arduino car with a BLE board.

## Boards
- Arduino Board: Arduino Uno
- Bluetooth Board: BT05

### lib/widgets/connection_page.dart
- Create channel
    ```
    static const flutterChannel = MethodChannel("com.eecamp.app/flutter");
    ```
- Invoke method
    ```
    await flutterChannel.invokeMethod("openCamera");
    ```
### android/app/src/main/kotlin/com/example/connection_page/MainActivity.kt
See the code in this file

### android/app/src/main/res/AndroidManifest.xml
在```<manifest>```中加入
```xml
<uses-feature
    android:name="android.hardware.camera"
    android:required="false" />
<uses-permission android:name="android.permission.CAMERA" />
```


## Reference

- [參考影片](https://youtu.be/j0cy_Z6IG_c?si=LLh3FA0g92_BXzKT)

# android_tool

作为一个Android开发者，在开发过程中经常会用到ADB命令，每次进行手敲都觉得麻烦得很，尤其是有些命令忘记了，还得去查，浪费时间，影响效率，于是用Flutter把一些常用的ADB命令封装成一个应用。

## 简介
通过执行ADB命令来操控Android设备，实现一些常用的功能，方便在进行Android开发时进行调试，目前在Windows和Mac OS可以运行，Linux上待验证，支持一些常用ADB命令以及文件管理，并且支持拖拽文件进行文件传输和安装APK，以及支持查看Log功能。

[下载试用](https://github.com/EaniaHuui/android_tool/releases)

### 演示
![alt screenshot1](https://github.com/EaniaHuui/android_tool/blob/main/screenshot/screenshot1.gif)
![alt screenshot2](https://github.com/EaniaHuui/android_tool/blob/main/screenshot/screenshot2.gif)
![alt screenshot2](https://github.com/EaniaHuui/android_tool/blob/main/screenshot/screenshot3.png)

## 实现

Flutter开发桌面端应用需要开启相关平台的配置，如下：
```
// 开启支持Windows平台开发（Flutter 2.10版本以上已经默认启用）
flutter config --enable-windows-desktop
// 开启支持Mac平台开发
flutter config --enable-macos-desktop
// 开启支持Linux平台开发
flutter config --enable-linux-desktop
```

### 使用的插件

1. ``provider``：实现状态管理
2. ``process_run``：用于执行ADB命令
3. ``desktop_drop``：实现拖动文件到应用，并且支持多个文件，在此项目中用于从电脑中传输文件到Android设备中，以及进行安装APK
4. ``file_selector``：用于管理文件和与文件对话框的交互，可以方便快捷的弹出文件或文件夹选择对话框
5. ``shared_preferences``：数据的持久化存储
6. ``path_provider``：用于获取系统中的一些目录的路径
7. ``dio``：网络请求，当前项目中主要用来下载ADB工具包
8. ``archive``：解压缩插件，当前项目中主要用来在Windows平台上解压zip文件
9. ``event_bus``：消息传递，主要用于传递一些数据，更新其他Widget
10. ``substring_highlight``：用于实现搜索关键字高亮显示
11. ``flutter_list_view``：用于实现ListView的滚动到指定Item的位置  



感兴趣的小伙伴可以点击下方链接下载试用。  
对于代码逻辑感兴趣也可直接看源码。



## 上链接
GitHub地址：[android_tool](https://github.com/EaniaHuui/android_tool)  
下载试用：[release](https://github.com/EaniaHuui/android_tool/releases)


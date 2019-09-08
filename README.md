# auto_localization

Flutter package to dynamically translate your app.

This plugin will AUTOMATICALLY detect the app Localization and translate the text.



## HOW TO USE

Wrap your Text widget with this:
```dart
// Binary data
TextAutoLocal(Text("Plugin example app"))
```



Wrap your String with this (Need to be async):
```dart
// Binary data
String x=translateText("hello")
```
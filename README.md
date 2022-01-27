# auto_localization

A new Flutter plugin.
Flutter package to dynamically translate your app.

This plugin will AUTOMATICALLY detect the app Localization and translate the text.


## HOW IT WORKS

So the point was to find a way to convincely translate text in all the languages.
To do that we create this system who seam to works really well.
It Uses Google Translate

## Getting Started
There is even a cache system to make it faster.
Add the dependency in `pubspec.yaml`:
```yaml
dependencies:
  ...
  auto_localization: ^1.1.9
```


## HOW TO USE

init the plugin
```dart
await AutoLocalization.init(
  appLanguage: 'en',
  userLanguage: 'it'
);
```

Translate something
```dart
await AutoLocalization.translate("hello");
```

Use the builder to translate widgets smoothly
```dart
AutoLocalBuilder(
  text: const ["ciao", "come stai?"],
  builder: (TranslationWorker tw) {
    print(tw.get('ciao'));
    print(tw.get('come stai?'));
    return Text(tw.get('ciao'),);
  }, 
);
```

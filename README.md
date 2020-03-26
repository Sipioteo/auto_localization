# auto_localization

Flutter package to dynamically translate your app.

This plugin will AUTOMATICALLY detect the app Localization and translate the text.


## HOW IT WORKS

So the point was to find a way to convincely translate text in all the languages.
To do that we create this system who seam to works really well.
It Uses Google Translate

There is even a cache system to make it faster.


Normally our translation is composed by three part
text | The text to translate

language | The end language of the text (if null will be taken the default of the device)

target | The argument of the translation (We added this because in certain circumstances translation were not accurate, 
i.e. 
```dart
translateText("Bailey's irish cream", language: "it", alwaysTranslate: true) //--> Result in "La crema irlandese di Bailey" which is wrong
translateText("Bailey's irish cream", language: "it", target: "cocktail", alwaysTranslate: true) //--> Result in "Bailey's irish cream" which is correct
```
)


## HOW TO USE

Set base language into your main to not translate the text when the language is the same to which you write your app:
```dart
BaseLanguage().setBaseLanguage("en")
```

When you create an element you can set alwaysTranslate = TRUE and it will be translated event if the app language and device language matches, it's used to translate dynamic text, like something written by a user.
```dart
translateText("Bailey's irish cream", language: "it", target: "cocktail", alwaysTranslate: true)
```




The old version is replaced by this. You have to use our TranslateBuilder to make a translation, it gives you the translated String through a builder, it works with List so you can translate TextSpan.


```dart
TranslateBuilder(["Plugin example app"],(stringList, isTranslated){
            return Text(stringList[0]);
},)
```


```dart
TranslateBuilder(['hello auto', 'localization is','Running on: $_platformVersion\n'],(stringList, isTranslated){
            return Text.rich(TextSpan(
              children: [
                TextSpan(text: stringList[0]+' '),
                TextSpan(text: stringList[1]+' '),
                TextSpan(text: stringList[2]),

              ]
            ));
})
```



Convert your String with this (Need to be async):
```dart
String x= await translateText("hello");
```
# auto_localization

Flutter package to dynamically translate your app.

This plugin will AUTOMATICALLY detect the app Localization and translate the text.


## HOW IT WORKS

So the point was to find a way to convincely translate text in all the languages.
To do that we create this system who seam to works really well.

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




Wrap your Text widget with this:
```dart
TextLocal(Text("Plugin example app"))
AutoSizeTextLocal(AutoSizeTextLocal("Plugin example app"))
```


If you need to create your own Translated widget you could act like this
```dart

class TextLocal extends StatefulWidget {
  final Text text;
  final String target;
  final String lang;
  final bool alwaysTranslate;

  TextLocal(this.text,{this.lang,this.target, this.alwaysTranslate=false});

  @override
  _TextLocalState createState() => _TextLocalState();
}

class _TextLocalState extends State<TextLocal> {

  String trans;

  @override
  void initState() {
    super.initState();
  }

  String cachedString="";
  translate() async {
    cachedString=widget.text.data;
    trans=await translateText(widget.text.data, language: widget.lang, target: widget.target, alwaysTranslate: widget.alwaysTranslate);
    if(mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(cachedString!=widget.text.data){
      translate();
    }
    return Text(
      trans??widget.text.data,
      strutStyle: widget.text.strutStyle,
      style: widget.text.style,
      softWrap: widget.text.softWrap,
      semanticsLabel: widget.text.semanticsLabel,
      textScaleFactor: widget.text.textScaleFactor,
      maxLines: widget.text.maxLines,
      textWidthBasis: widget.text.textWidthBasis,
      textDirection: widget.text.textDirection,
      overflow: widget.text.overflow,
      locale: widget.text.locale,
      textAlign: widget.text.textAlign,
      key: widget.text.key,
    );
  }

}
```

Convert your String with this (Need to be async):
```dart
String x= await translateText("hello");
```
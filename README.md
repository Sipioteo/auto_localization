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
translateText("Bailey's irish cream", language: "it"); //--> Result in "La crema irlandese di Bailey" which is wrong
translateText("Bailey's irish cream", language: "it", target: "cocktail"); //--> Result in "Bailey's irish cream" which is correct
```
)


## HOW TO USE

Wrap your Text widget with this:
```dart
TextAutoLocal(Text("Plugin example app"))
```


If you need to create your own Translated widget you could act like this
```dart
class TextAutoLocal extends StatefulWidget {

  final Text text; //This is the widget to wrap
  final String target;  //this is the target
  final String lang; //this is the translation

  TextAutoLocal(this.text,{this.lang,this.target});


  @override
  _TextAutoLocalState createState() => _TextAutoLocalState();
}

class _TextAutoLocalState extends State<TextAutoLocal> {

  String trans; //this is the translation variable

  @override
  void initState() {
    super.initState();
    translate();
  }

  translate() async {
    trans=await translateText(widget.text.data, language: widget.lang, target: widget.target); //call this to create the translation
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
    
    //Rebuild all the widget with a new one but with different text
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
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:auto_localization/auto_localization.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.


    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: TranslateBuilder(["Plugin example app"],(stringList, isTranslated){
            return Text(stringList[0]);
          },),
        ),
        body: Center(
          child: TranslateBuilder(['hello auto', 'localization is','Running on: $_platformVersion\n'],(stringList, isTranslated){
            return Text.rich(TextSpan(
                children: [
                  TextSpan(text: stringList[0]+' '),
                  TextSpan(text: stringList[1]+' '),
                  TextSpan(text: stringList[2]),

                ]
            ));
          }),
        ),
      ),
    );
  }
}

library auto_localization;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:translator/translator.dart';




class AutoLocalization{
  static String boxName='auto_translation_box';
  static final _translator = GoogleTranslator();
  static String _appLanguage="en";
  static String _userLanguage="it";
  static List<Future> futures=[];

  ///INIT AUTOLOCALIZATION
  static init({String? appLanguage, String? userLanguage}) async {
    setAppLanguage(appLanguage??_appLanguage);
    setUserLanguage(userLanguage??_userLanguage);
    try{
      await Hive.initFlutter();
    }catch(_){
      Hive.init('../');
    }
    Hive.registerAdapter(_SaveTranslationObjectAdapter());
    await Hive.openBox<_SaveTranslationObject>(boxName);
  }

  ///SET APP LANGUAGE
  static setAppLanguage(String languageId){
    _userLanguage=languageId;
  }

  ///SET USER LANGUAGE
  static setUserLanguage(String languageId){
    _userLanguage=languageId;
  }

  static Future<String> _executeTranslate(String text, {bool cache=true, String? targetLanguage}) async {
    //CACHE CHECK
    Box<_SaveTranslationObject> dbHive=Hive.box(boxName);
    _SaveTranslationObject result=_SaveTranslationObject(
        appLanguage: _appLanguage,
        userLanguage: targetLanguage??_userLanguage,
        startText: text
    );
    List<_SaveTranslationObject> search=dbHive.values.where((element) => element==result).toList();

    //CACHE NOT FOUND
    if(search.isEmpty&&cache){
      await _awaitTheWork();
      result.resultText=(await _translator.translate(text, from: _appLanguage, to: targetLanguage??_userLanguage)).text;
      dbHive.add(result);
      return result.resultText!;
    }

    //CACHE FOUND
    return search.first.resultText!;
  }

  ///Execute an async translation
  static Future<String> translate(String text, {bool cache=true, String? targetLanguage}) async {
    Future ft=_executeTranslate(text, cache: cache, targetLanguage: targetLanguage);
    futures.add(ft);
    return await ft;
  }

  static Future<bool> _awaitTheWork() async {
    List<Future> futureToWork=futures.toList();
    if(futureToWork.isEmpty){
      return true;
    }
    await Future.wait(futureToWork);
    return true;
  }

}



class AutoLocalBuilder extends StatefulWidget {
  final Widget Function(List<String> text, double percentage) builder;
  final List<String> text;
  final cache;


  const AutoLocalBuilder({Key? key, required this.builder, this.text=const [], this.cache=true}) : super(key: key);

  @override
  _AutoLocalBuilderState createState() => _AutoLocalBuilderState();
}

class _AutoLocalBuilderState extends State<AutoLocalBuilder> {

  List<String>? translation;
  double percentage=0.0;

  @override
  void initState() {
    translation=widget.text;
    super.initState();
    start();
  }

  void start() async {
    for(int i=0; i<translation!.length;i++){
      translation![i] = await AutoLocalization.translate(translation!.elementAt(i), cache: widget.cache);
      setState(() {
        percentage=i/translation!.length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(translation!, percentage);
  }
}




@HiveType(typeId: 6)
class _SaveTranslationObject{
  @HiveField(0)
  final String appLanguage;
  @HiveField(1)
  final String userLanguage;
  @HiveField(2)
  final String startText;
  @HiveField(3)
  String? resultText;


  _SaveTranslationObject({required this.appLanguage,required this.userLanguage,required this.startText, this.resultText});

  @override
  bool operator ==(Object other) {
    if(other is _SaveTranslationObject){
      return other.appLanguage==appLanguage&&
          other.userLanguage==userLanguage&&
          other.startText==startText;
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;

}



// Can be generated automatically
class _SaveTranslationObjectAdapter extends TypeAdapter<_SaveTranslationObject> {
  @override
  final typeId = 0;

  @override
  _SaveTranslationObject read(BinaryReader reader) {
    var data=reader.read();
    return _SaveTranslationObject(
        appLanguage: data[0],
        userLanguage: data[1],
        startText: data[2],
        resultText: data[3]
    );
  }

  @override
  void write(BinaryWriter writer, _SaveTranslationObject obj) {
    writer.write([
      obj.appLanguage,
      obj.userLanguage,
      obj.startText,
      obj.resultText,
    ]);
  }
}
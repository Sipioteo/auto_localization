library auto_localization;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:synchronized/synchronized.dart';
import 'package:translator/translator.dart';


class AutoLocalizationException implements Exception {
  String cause;
  AutoLocalizationException(this.cause);
}


class AutoLocalization{
  static final String _boxName='auto_translation_box';
  static final _translator = GoogleTranslator();
  static String _appLanguage="en";
  static String _userLanguage="it";
  static bool _isInitialized=false;
  static bool _clearCache=false;

  ///This parameter control the time between every request so you don't exceed the maximum amount of request. If you don't know what you are doing don't change it!
  static int _delayTime=300;

  static String get appLanguage => _appLanguage;
  static String get userLanguage => _userLanguage;
  static int get delayTime => _delayTime;

  static Lock _lock = new Lock();

  ///INIT AUTOLOCALIZATION
  static init({String? appLanguage, String? userLanguage, int? delayTime}) async {
    _appLanguage=appLanguage??_appLanguage;
    _userLanguage=userLanguage??_userLanguage;
    _delayTime=delayTime??_delayTime;

    await _doInit();
  }

  ///SET APP LANGUAGE
  static set setDelayTime(int delayTime){
    _delayTime=delayTime;
    if(_delayTime<100){
      throw new AutoLocalizationException("Delay time is too low.");
    }else if(_delayTime<300){
      String text="WARNING: The provided delay time ($_delayTime ms) is lower than recommended time. It could cause a request block.";
      print('\x1B[33m$text\x1B[0m');
    }
  }

  ///SET APP LANGUAGE
  static set setAppLanguage(String languageId){
    _appLanguage=languageId;
  }

  ///SET USER LANGUAGE
  static set setUserLanguage(String languageId){
    _userLanguage=languageId;
  }

  static _doInit() async {
    if(_delayTime<100){
      throw new AutoLocalizationException("Delay time is too low.");
    }else if(_delayTime<300){
      String text="WARNING: The provided delay time ($_delayTime ms) is lower than recommended time. It could cause a request block.";
      print('\x1B[33m$text\x1B[0m');
    }
    if(_isInitialized){
      return true;
    }
    try{
      await Hive.initFlutter();
    }catch(_){
      Hive.init('../');
    }
    if(!Hive.isAdapterRegistered(6)){
      Hive.registerAdapter(_SaveTranslationObjectAdapter());
    }
    if(!Hive.isBoxOpen(_boxName)){
      await Hive.openBox<_SaveTranslationObject>(_boxName);
    }
    _isInitialized=true;
    return true;
  }

  static lazyClearCache(){
    _clearCache=true;
  }

  static Future<bool> clearCache() async {
    try{
      await _doInit();
      Box<_SaveTranslationObject> dbHive=Hive.box(_boxName);
      await dbHive.deleteAll(dbHive.keys);
      return true;
    }catch(e){
      return false;
    }
  }

  static Future<String> _executeTranslate(String text, {bool cache=true, String? startingLanguage, String? targetLanguage, bool returnJSON=false}) async {
    //CACHE CHECK
    await _doInit();
    Box<_SaveTranslationObject> dbHive=Hive.box(_boxName);
    if(_clearCache){
      await dbHive.deleteAll(dbHive.keys);
      _clearCache=false;
    }
    _SaveTranslationObject result=_SaveTranslationObject(
        appLanguage: startingLanguage??_appLanguage,
        userLanguage: targetLanguage??_userLanguage,
        startText: text
    );
    List<_SaveTranslationObject> search=dbHive.values.where((element) => element==result).toList();

    //CACHE NOT FOUND
    if(search==null||search.isEmpty||!cache){
      result.resultText=(await _translator.translate(text, from: startingLanguage??_appLanguage, to: targetLanguage??_userLanguage)).text;
      dbHive.add(result);
      await Future.delayed(Duration(milliseconds: _delayTime));
      if(returnJSON){
        return jsonEncode({
          "text": text,
          "translation": result.resultText!,
          "cache": false,
          "reverse_cache": false,
          "lang_start": startingLanguage??_appLanguage,
          "lang_end": targetLanguage??_userLanguage,
          "time": DateTime.now().toIso8601String()
        });
      }
      return result.resultText!;
    }

    //CACHE FOUND
    if(returnJSON){
      return jsonEncode({
        "text": text,
        "translation": (search.first.appLanguage==(targetLanguage??_userLanguage)&&search.first.userLanguage==(startingLanguage??_appLanguage))?(search.first.startText):(search.first.resultText!),
        "cache": true,
        "reverse_cache": search.first.appLanguage==(targetLanguage??_userLanguage)&&search.first.userLanguage==(startingLanguage??_appLanguage),
        "lang_start": startingLanguage??_appLanguage,
        "lang_end": targetLanguage??_userLanguage,
        "time": DateTime.now().toIso8601String()
      });
    }
    if(search.first.appLanguage==(targetLanguage??_userLanguage)&&search.first.userLanguage==(startingLanguage??_appLanguage)){
      return search.first.startText;
    }
    return search.first.resultText!;
  }

  ///Execute an async translation
  static Future<String> translate(String text, {bool cache=true, String? startingLanguage, String? targetLanguage, bool returnJSON=false}) async {
    return await _lock.synchronized(() async {
      return await _executeTranslate(text, cache: cache, startingLanguage: startingLanguage, targetLanguage: targetLanguage, returnJSON: returnJSON);
    });
  }
}



class AutoLocalBuilder extends StatefulWidget {
  final Widget Function(TranslationWorker) builder;
  final List<String> text;
  final bool cache;
  final TranslationWorker two;
  final bool _extInit;


  AutoLocalBuilder({Key? key, required this.builder, this.text=const [], this.cache=true, TranslationWorker? translationWorker}) :
        _extInit=translationWorker==null?false:true,
        two=translationWorker??TranslationWorker(),

  super(key: key);


  @override
  _AutoLocalBuilderState createState() => _AutoLocalBuilderState();
}

class _AutoLocalBuilderState extends State<AutoLocalBuilder> {

  @override
  void initState() {
    super.initState();
    widget.two.set(widget.text);
    WidgetsBinding.instance?.addPostFrameCallback((_){
          if(!widget._extInit) {
            widget.two.run(useCache: widget.cache);
          }
      });
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: widget.two,
        builder: (context, child) {
          return widget.builder(widget.two);
        }
    );
  }
}

class TranslationWorker extends ChangeNotifier{
  List<String>? _translation=[];
  Map<String, String> _translated = {};
  double _percentage=0.0;

  double get percentage=>_percentage;
  List<String> get startingTexts=>_translation??[];

  String get(String key)=>_translated[key]!;
  String getById(int id)=>_translated[_translated.keys.elementAt(id)]!;


  void set(List<String> translation){
    this._translation?.addAll(translation);
    _translated.addEntries(translation.where((element) => !_translated.keys.contains(translation)).map((e) => MapEntry(e, e)));
  }

  run({useCache=false}) async {
    if(_translated!=null&&_translated.isNotEmpty){
      for(int i=0; i<_translated.length; i++){
        _translated[_translated.keys.elementAt(i)] = await AutoLocalization.translate(_translated[_translated.keys.elementAt(i)]!, cache: useCache);
        _percentage=i/_translated.length;
        notifyListeners();
      }
    }
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
      return (other.appLanguage==appLanguage&&
          other.userLanguage==userLanguage&&
          other.startText.toLowerCase().trim()==startText.toLowerCase().trim()) || (
          other.appLanguage==userLanguage&&
          other.userLanguage==appLanguage&&
          other.startText.toLowerCase().trim()==resultText?.toLowerCase().trim());
    }
    return false;
  }

  @override
  int get hashCode => super.hashCode;

}

class _SaveTranslationObjectAdapter extends TypeAdapter<_SaveTranslationObject> {
  @override
  final typeId = 6;

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
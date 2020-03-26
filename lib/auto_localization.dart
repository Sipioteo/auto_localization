import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:translator/translator.dart';

import 'dart:ui' as ui;

class BaseLanguage{

  static final BaseLanguage _singleton = new BaseLanguage._internal();


  factory BaseLanguage() {
    return _singleton;
  }

  BaseLanguage._internal();

  String _base="";

  void setBaseLanguage(String lang){
    _base=lang;
  }


  String get lang =>_base;



}




Future<String> translateText(String a,{String language, String target, bool alwaysTranslate=false}) async {
  await _DatabaseManager().initDatabase();

  String locale = language!=null ? language : ui.window.locale.languageCode;

  if(locale!=BaseLanguage().lang||alwaysTranslate){
    return _DatabaseManager().getTranslation(a, locale, target: target);
  }else{
    return a;
  }


}



// ignore: must_be_immutable
class TranslateBuilder extends StatefulWidget {

  final List<String> text;
  final String target;
  final String lang;
  final bool alwaysTranslate;
  Widget Function(List<String>, bool) builder;
  List<String> _cache;
  List<String> _trans;

  TranslateBuilder(this.text,this.builder,{this.lang,this.target, this.alwaysTranslate=false}){
    if(_cache==null||_trans.length!=text.length){
      _cache=List.generate(text.length, (index) => "");
    }
    if(_trans==null||_trans.length!=text.length){
      _trans=List.generate(text.length, (index) => "");
    }

  }

  @override
  _TranslateBuilderState createState() => _TranslateBuilderState();
}

class _TranslateBuilderState extends State<TranslateBuilder> {


  @override
  void initState() {
    super.initState();
  }


  int isTranslated=-1;  //0 false, 1 true, -1 start

  translate() async {
    isTranslated=0;
    for(int i=0;i<widget.text.length;i++) {
      widget._cache[i]=widget.text[i];
      widget._trans[i] = await translateText(
          widget.text[i], language: widget.lang,
          target: widget.target,
          alwaysTranslate: widget.alwaysTranslate);
    }
    isTranslated=1;
    if(mounted){
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if(isTranslated==-1||checkCache()){
      widget._cache=List.generate(widget.text.length, (index) => "");
      translate();
    }



    print(isTranslated);
    if(isTranslated==1){
      return widget.builder(widget._trans,true);
    }else{
      return widget.builder(widget.text,false);
    }

  }

  bool checkCache(){
    for(int i=0;i<widget.text.length;i++){
      if(widget._cache[i]!=widget.text[i]){
        return true;
      }
    }
    return false;
  }

}



class _DatabaseManager {


  static final _DatabaseManager _singleton = new _DatabaseManager._internal();


  Database db;

  factory _DatabaseManager() {
    return _singleton;
  }

  _DatabaseManager._internal();


  initDatabase() async {
    translator = new GoogleTranslator();

    if(await databaseExists('translation.db')){
      await deleteDatabase('translation.db');
    }
    if(await databaseExists('translation_01.db')){
      await deleteDatabase('translation_01.db');
    }

    db = await openDatabase('translation_02.db', version: 1,
      onCreate: (Database db, int version) async {
        await db.execute(
            'CREATE TABLE `Translation` (`idTranslate` integer,`Lang` text,`Trans` text,  PRIMARY KEY (Trans))');
      }, readOnly: false,
    );
  }


  GoogleTranslator translator;

  var lock = new Lock();


  Future<String> getTranslation(String from, String locale, {String target}) async {


    var test = (await db.rawQuery("SELECT Trans FROM Translation WHERE idTranslate=(SELECT idTranslate FROM Translation WHERE Trans=? LIMIT 1) AND Lang=?",[from, locale]).catchError((Object error){

    }));
    String toSendOut = test.isNotEmpty ? test[0]["Trans"] : null;
    if (toSendOut == null) {
      toSendOut= await lock.synchronized(() async {


        var test1 = (await db.rawQuery("SELECT Trans FROM Translation WHERE idTranslate=(SELECT idTranslate FROM Translation WHERE Trans=? LIMIT 1) AND Lang=?",[from, locale]).catchError((Object error){

        }));
        String to= test1.isNotEmpty ? test1[0]["Trans"] : null;



        if (to == null) {
          if (target != null) {
            to =
            (await translator.translate(from + "(" + target + ")", to: locale));
            if (to == null) {
              to = await translator.translate(from, to: locale);
            } else {
              to = to.replaceAll(RegExp(r'\([^)]*\)'), "").replaceAll(
                  RegExp(r'/^\s+|\s+$/g'), "");
            }
          } else {
            to = await translator.translate(from, to: locale);
          }


          if (to == null || to == "") {
            return from;
          }


          try {
            await db.insert("Translation", {
              "idTranslate": (await db.rawQuery(
                  "SELECT ifnull(MAX(idTranslate),0)+1 as Conto FROM Translation"))[0]["Conto"],
              "Lang": "NAN",
              "Trans": from,
            }).catchError((Object error) {

            });
          } catch (e) {

          }


          try {
            await db.insert("Translation", {
              "idTranslate": (await db.rawQuery(
                  "SELECT idTranslate FROM Translation WHERE Trans=? AND Lang='NAN'",
                  [from]))[0]["idTranslate"],
              "Lang": locale,
              "Trans": to,
            }).catchError((Object error) {

            });
          } catch (e) {

          }


          try {
            await db.update("Translation", {
              "Lang": locale,
            }, where: "Trans=? AND Lang='NAN'", whereArgs: [to]
            ).catchError((Object error) {

            });
          } catch (e) {

          }
        }
        return to;
      });
    }

    return toSendOut;

  }
}
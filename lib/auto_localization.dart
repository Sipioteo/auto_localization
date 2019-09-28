import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
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





class AutoSizeTextLocal extends StatefulWidget {

  final AutoSizeText text;
  final String lang;
  final String target;
  final bool alwaysTranslate;

  AutoSizeTextLocal(this.text,{this.lang,this.target, this.alwaysTranslate=false});

  @override
  _AutoSizeTextLocalState createState() => _AutoSizeTextLocalState();
}

class _AutoSizeTextLocalState extends State<AutoSizeTextLocal> {

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
    return AutoSizeText(
      trans??widget.text.data,
      strutStyle: widget.text.strutStyle,
      style: widget.text.style,
      softWrap: widget.text.softWrap,
      semanticsLabel: widget.text.semanticsLabel,
      textScaleFactor: widget.text.textScaleFactor,
      maxLines: widget.text.maxLines,
      textDirection: widget.text.textDirection,
      overflow: widget.text.overflow,
      locale: widget.text.locale,
      textAlign: widget.text.textAlign,
      key: widget.text.key,
      textKey: widget.text.key,
      stepGranularity: widget.text.stepGranularity,
      minFontSize: widget.text.minFontSize,
      maxFontSize: widget.text.maxFontSize,
      wrapWords: widget.text.wrapWords,
      presetFontSizes: widget.text.presetFontSizes,
      group: widget.text.group,
      overflowReplacement: widget.text.overflowReplacement,
    );
  }
}




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


Future<String> translateText(String a,{String language, String target, bool alwaysTranslate=false}) async {
  await _DatabaseManager().initDatabase();

  String locale = ui.window.locale.languageCode;

  if(locale!=BaseLanguage().lang||alwaysTranslate){
    return _DatabaseManager().getTranslation(a, locale, target: target);
  }else{
    return a;
  }


}

import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:translator/translator.dart';



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
        }, readOnly: false
    );
  }


  GoogleTranslator translator;

  var lock = new Lock();


  Future<String> getTranslation(String from, String locale, {String target}) async {
    return await lock.synchronized(() async {

      var test = (await db.rawQuery("SELECT Trans FROM Translation WHERE idTranslate=(SELECT idTranslate FROM Translation WHERE Trans=? LIMIT 1) AND Lang=?",[from, locale]));
      String to = test.isNotEmpty ? test[0]["Trans"] : null;
      if (to == null) {



        if(target!=null){
          to = (await translator.translate(from+"("+target+")", to: locale)).replaceAll(RegExp(r'\([^)]*\)'), "").replaceAll(RegExp(r'/^\s+|\s+$/g'), "");
        }else{
          to = await translator.translate(from, to: locale);
        }

        try {
          db.insert("Translation", {
            "idTranslate": (await db.rawQuery(
                "SELECT ifnull(MAX(idTranslate),0)+1 as Conto FROM Translation"))[0]["Conto"],
            "Lang": "NAN",
            "Trans": from,
          });
        } on DatabaseException catch (e){

        }
        try {
          db.insert("Translation", {
            "idTranslate": (await db.rawQuery(
                "SELECT idTranslate FROM Translation WHERE Trans=? AND Lang='NAN'",[from]))[0]["idTranslate"],
            "Lang": locale,
            "Trans": to,
          });
        } on DatabaseException catch (e){

        }
        try {
          db.update("Translation", {
            "Lang": locale,
          }, where: "Trans=? AND Lang='NAN'", whereArgs: [to]);
        } on DatabaseException catch (e){

        }
      }

      return to;
    });

  }
}


class TextAutoLocal extends StatefulWidget {

  final Text text;
  final String target;
  final String lang;

  TextAutoLocal(this.text,{this.lang,this.target});


  @override
  _TextAutoLocalState createState() => _TextAutoLocalState();
}

class _TextAutoLocalState extends State<TextAutoLocal> {

  String trans;

  @override
  void initState() {
    super.initState();
    translate();
  }

  translate() async {
    trans=await translateText(widget.text.data, language: widget.lang, target: widget.target);
    setState(() {
    });
  }

  @override
  Widget build(BuildContext context) {
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



Future<String> translateText(String a,{String language, String target}) async {
  await _DatabaseManager().initDatabase();
  String locale = await Devicelocale.currentLocale;
  return _DatabaseManager().getTranslation(a, language??locale.split("_")[1].toLowerCase(), target: target);


}

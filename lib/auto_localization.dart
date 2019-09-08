import 'dart:async';

import 'package:devicelocale/devicelocale.dart';
import 'package:flutter/widgets.dart';
import 'package:sqflite/sqflite.dart';
import 'package:translator/translator.dart';


class _DatabaseManager{


  static final _DatabaseManager _singleton = new _DatabaseManager._internal();


  Database db;

  factory _DatabaseManager() {
    return _singleton;
  }

  _DatabaseManager._internal();


  initDatabase() async {

    translator = new GoogleTranslator();
    db = await openDatabase('translation.db', version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('CREATE TABLE `Translation` (`idTranslate` integer,`Lang` text,`Trans` text,  PRIMARY KEY (Trans))');
        }, readOnly: false
    );
  }

  GoogleTranslator translator;
  Future<String> getTranslation(String from, String locale) async {
    var test=(await db.rawQuery("SELECT Trans FROM Translation WHERE idTranslate=(SELECT idTranslate FROM Translation WHERE Trans='"+from+"' LIMIT 1) AND Lang='"+locale+"'"));

    String to= test.isNotEmpty?test[0]["Trans"]:null;
    if(to==null){
      to=await translator.translate(from, to: locale);
      try{
        db.insert("Translation", {
          "idTranslate":(await db.rawQuery("SELECT COUNT(*) as Conto FROM Translation"))[0]["Conto"],
          "Lang":"NAN",
          "Trans":from,
        });
      }catch(e){

      }
      try{
        db.insert("Translation", {
          "idTranslate":(await db.rawQuery("SELECT idTranslate FROM Translation WHERE Trans='"+from+"' AND Lang='NAN'"))[0]["idTranslate"],
          "Lang":locale,
          "Trans":to,
        });
      }catch(e){

      }
      try{
        db.update("Translation", {
          "Lang":locale,
        }, where: "Trans='"+to+"' AND Lang='NAN'");
      }catch(e){

      }

    }
    return to;

  }

}





class TextAutoLocal extends StatefulWidget {

  Text text;


  TextAutoLocal(this.text);


  @override
  _TextAutoLocalState createState() => _TextAutoLocalState();
}

class _TextAutoLocalState extends State<TextAutoLocal> {

  String trans;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    translate();
  }


  translate() async {
    trans=await translateText(widget.text.data);
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



Future<String> translateText(String a,{String language=null}) async {
  await _DatabaseManager().initDatabase();
  String locale = await Devicelocale.currentLocale;
  return _DatabaseManager().getTranslation(a, language??locale.split("_")[1].toLowerCase());

}

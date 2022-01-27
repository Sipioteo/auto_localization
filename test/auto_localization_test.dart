import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:auto_localization/auto_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Matcher replyjson(Map? expected) => _ReplyJson(expected);

class _ReplyJson extends Matcher {
  final Map? _expected;

  const _ReplyJson(this._expected);

  @override
  bool matches(Object? item, Map matchState) {
    bool returnData=true;
    if(_expected!=null&&item!=null){
      Map elab={};
      if(item is String){
        elab=jsonDecode(item);
      }else if(item is Map){
        elab=item;
      }else{
        return _expected==item;
      }
      _expected?.forEach((key, value) {
        returnData = returnData && (elab[key]==value);
      });
    }else{
      returnData = _expected==item;
    }
    return returnData;
  }

  @override
  Description describe(Description description) => description.add('in json');
}


void main(){

  setUpAll(() async {
    HttpOverrides.global = null;
    AutoLocalization.lazyClearCache();
  });
  group('Basic functionality', (){
    group('Test basic translation (NOCACHE)', () {
      test('English to Italian', (){
        AutoLocalization.lazyClearCache();
        expect(basicTranslation('hello', 'en', 'it', false), completion(replyjson({'translation': 'ciao', 'cache': false})));
        expect(basicTranslation('how are you?', 'en', 'it', false), completion(replyjson({'translation': 'come va?', 'cache': false})));
      });
      test('Italian to english', (){
        AutoLocalization.lazyClearCache();
        expect(basicTranslation('ciao', 'it', 'en', false), completion(replyjson({'translation': 'hello', 'cache': false})));
        expect(basicTranslation('come va?', 'it', 'en', false), completion(replyjson({'translation': 'how is it going?', 'cache': false})));
      });
    });
    group('Test basic translation (CACHE)', () {
      test('English to Italian', (){
        AutoLocalization.lazyClearCache();
        expect(basicTranslation('hello', 'en', 'it', false), completion(replyjson({'translation': 'ciao', 'cache': false})));
        expect(basicTranslation('hello', 'en', 'it', true), completion(replyjson({'translation': 'ciao', 'cache': true})));
        expect(basicTranslation('how are you?', 'en', 'it', false), completion(replyjson({'translation': 'come va?', 'cache': false})));
        expect(basicTranslation('how are you?', 'en', 'it', true), completion(replyjson({'translation': 'come va?', 'cache': true})));
      });
      test('Italian to English', (){
        AutoLocalization.lazyClearCache();
        expect(basicTranslation('ciao', 'it', 'en', false), completion(replyjson({'translation': 'hello', 'cache': false})));
        expect(basicTranslation('ciao', 'it', 'en', true), completion(replyjson({'translation': 'hello', 'cache': true})));
        expect(basicTranslation('come va?', 'it', 'en', false), completion(replyjson({'translation': 'how is it going?', 'cache': false})));
        expect(basicTranslation('come va?', 'it', 'en', true), completion(replyjson({'translation': 'how is it going?', 'cache': true})));
      });
    });
    test('Clear the cache', (){
      expect(AutoLocalization.clearCache(), completion(equals(true)));
    });
    group('Test init translation (NOCACHE)', () {

      group('English to Italian', () {
        test('Initialize Translation', (){
          AutoLocalization.init(
              appLanguage: 'en',
              userLanguage: 'it',
              delayTime: 300
          );
          expect(AutoLocalization.appLanguage, equals('en'));
          expect(AutoLocalization.userLanguage, equals('it'));
          expect(AutoLocalization.delayTime, equals(300));
        });
        test('Translation', (){
          expect(initTranslation('hello', false), completion(replyjson({'translation': 'ciao', 'cache': false})));
          expect(initTranslation('how are you?', false), completion(replyjson({'translation': 'come va?', 'cache': false})));
        });
      });
      group('Italian to English', () {
        test('Initialize Translation', (){
          AutoLocalization.lazyClearCache();
          AutoLocalization.init(
              appLanguage: 'it',
              userLanguage: 'en',
              delayTime: 300
          );
          expect(AutoLocalization.appLanguage, equals('it'));
          expect(AutoLocalization.userLanguage, equals('en'));
          expect(AutoLocalization.delayTime, equals(300));
        });
        test('Translation', (){
          expect(initTranslation('ciao', false), completion(replyjson({'translation': 'hello', 'cache': false})));
          expect(initTranslation('come va?', false), completion(replyjson({'translation': 'how is it going?', 'cache': false})));
        });
      });
    });
    group('Test init translation (CACHE)', () {
      group('English to Italian', () {
        test('Initialize Translation', (){
          AutoLocalization.lazyClearCache();
          AutoLocalization.init(
              appLanguage: 'en',
              userLanguage: 'it',
              delayTime: 300
          );
          expect(AutoLocalization.appLanguage, equals('en'));
          expect(AutoLocalization.userLanguage, equals('it'));
          expect(AutoLocalization.delayTime, equals(300));
        });
        test('Translation', (){
          initTranslation('hello', false);
          expect(initTranslation('hello', true), completion(replyjson({'translation': 'ciao'})));
          initTranslation('how are you?', false);
          expect(initTranslation('how are you?', true), completion(replyjson({'translation': 'come va?'})));
        });
      });
      group('Italian to English', () {
        test('Initialize Translation', (){
          AutoLocalization.lazyClearCache();
          AutoLocalization.init(
              appLanguage: 'it',
              userLanguage: 'en',
              delayTime: 300
          );
          expect(AutoLocalization.appLanguage, equals('it'));
          expect(AutoLocalization.userLanguage, equals('en'));
          expect(AutoLocalization.delayTime, equals(300));
        });
        test('Translation', (){
          initTranslation('ciao', false);
          expect(initTranslation('ciao', true), completion(replyjson({'translation': 'hello'})));
          initTranslation('come va?', false);
          expect(initTranslation('come va?', true), completion(replyjson({'translation': 'how is it going?'})));
        });
      });
    });
  });
  group('Advanced functionality', (){
    group('Auto cache reverse', () {
      test('English to Italian and Reverse', (){
        AutoLocalization.lazyClearCache();
        expect(basicTranslation('hello', 'en', 'it', true), completion(replyjson({'translation': 'ciao', 'cache': false})));
        expect(basicTranslation('Ciao', 'it', 'en', true), completion(replyjson({'translation': 'hello', 'cache': true})));
      });
    });
    group("Change delay time", (){
      test("Change normal values", (){
        expect(AutoLocalization.setDelayTime=500, 500);
        expect(AutoLocalization.setDelayTime=600, 600);
        expect(AutoLocalization.setDelayTime=800, 800);
        expect(AutoLocalization.setDelayTime=300, 300);
      });
      test("Change strange values", (){
        expect(AutoLocalization.setDelayTime=120, 120);
        expect(AutoLocalization.setDelayTime=100, 100);
        expect(AutoLocalization.setDelayTime=140, 140);
        expect(AutoLocalization.setDelayTime=170, 170);
      });
      test("Change error values", (){
        expect((){AutoLocalization.setDelayTime=50;}, throwsA(isA<AutoLocalizationException>()));
        expect((){AutoLocalization.setDelayTime=50;}, throwsA(isA<AutoLocalizationException>()));
        expect((){AutoLocalization.setDelayTime=50;}, throwsA(isA<AutoLocalizationException>()));
        expect((){AutoLocalization.setDelayTime=50;}, throwsA(isA<AutoLocalizationException>()));
      });
    });
  });
}


Future<Map> basicTranslation(String text, String? startingLanguage, String? targetLanguage, [bool cache=true]) async {
  String result= (await AutoLocalization.translate(text, cache: cache, startingLanguage: startingLanguage, targetLanguage: targetLanguage, returnJSON: true)).toLowerCase();
  debugPrint(result);
  return jsonDecode(result);
}

Future<Map> initTranslation(String text, [bool cache=true]) async {
  String result= (await AutoLocalization.translate(text, cache: cache, returnJSON: true)).toLowerCase();
  debugPrint(result);
  return jsonDecode(result);
}



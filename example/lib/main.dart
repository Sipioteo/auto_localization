

import 'package:auto_localization/auto_localization.dart';
import 'package:flutter/material.dart';

class TranslateATextExample extends StatefulWidget {
  const TranslateATextExample({Key? key}) : super(key: key);

  @override
  State<TranslateATextExample> createState() => _TranslateATextExampleState();
}

class _TranslateATextExampleState extends State<TranslateATextExample> {
  @override
  Widget build(BuildContext context) {
    return AutoLocalBuilder(
      text: const ["ciao", "come stai?"], // Set the list of text you need to translate
      builder: (TranslationWorker tw) {
        print(tw.get('ciao')); //Use the same text to get its translation
        print(tw.get('come stai?'));
        return Text(tw.get('ciao'),); //Retrieve it and show with a Text or whatever you need
      },
    );
  }
}

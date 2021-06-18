import 'package:auto_localization/auto_localization.dart';

void main() async {
  print("TEST: started");
  await AutoLocalization.init(
    appLanguage: 'en',
    userLanguage: 'it'
  );
  print(await AutoLocalization.translate("hello"));
  print("TEST: completed");
}

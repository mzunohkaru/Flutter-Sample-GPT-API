import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:gpt_chat_app/view/chat_view.dart';
import 'package:gpt_chat_app/view/home_view.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: FlexThemeData.light(scheme: FlexScheme.greenM3),
        darkTheme: FlexThemeData.dark(scheme: FlexScheme.greenM3),
        themeMode: ThemeMode.system,
        home: HomeView());
  }
}

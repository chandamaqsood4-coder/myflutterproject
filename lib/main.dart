import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:thinkcodes/diseRollerApp/homescreen.dart';
import 'package:thinkcodes/diseRollerApp/splashscreen.dart';
import 'package:thinkcodes/screens/WidgetShowcaseApp.dart';
import 'package:thinkcodes/screens/homescreen.dart';
import 'package:thinkcodes/whatsapp/whatsapp.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'To-Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: WidgetShowcaseScreen(),
    );
  }
}

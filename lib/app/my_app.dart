import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wetube/screens/home.dart';
import 'package:wetube/theme/theme.dart';
import 'package:wetube/theme/util.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final brightness = View.of(context).platformDispatcher.platformBrightness;

    // Retrieves the default theme for the platform
    //TextTheme textTheme = Theme.of(context).textTheme;

    // Use with Google Fonts package to use downloadable fonts
    TextTheme textTheme = createTextTheme(context, "Poppins", "Open Sans");

    MaterialTheme theme = MaterialTheme(textTheme);
    return GetMaterialApp(
      title: 'WeTube',
      theme: brightness == Brightness.light ? theme.light() : theme.dark(),
      debugShowCheckedModeBanner: false,
      home: Home(),
    );
  }
}

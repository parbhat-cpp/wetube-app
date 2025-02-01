import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:wetube/app/my_app.dart';
import 'package:wetube/services/user_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] as String,
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] as String,
  );

  Get.lazyPut<UserService>(() => UserService());

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

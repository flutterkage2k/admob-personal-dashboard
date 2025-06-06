// 📁 lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'presentation/screens/admob_home_page.dart';

Future<void> main() async {
  // ✅ 반드시 이 순서로 초기화
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    print('✅ .env 파일 로드 성공');
  } catch (e) {
    print('❌ .env 파일 로드 실패: $e');
    // .env 파일이 없어도 앱은 실행되도록 함
  }

  runApp(const ProviderScope(child: AdmobApp()));
}

class AdmobApp extends StatelessWidget {
  const AdmobApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AdMob Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const AdmobHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

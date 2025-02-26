import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ai_app/screens/home_screen.dart';
import 'package:ai_app/theme/app_theme.dart';
import 'package:ai_app/providers/theme_provider.dart';
import 'package:ai_app/services/config_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ConfigService().init();
  await initializeDateFormatting('zh_CN', null);
  
  // 配置Google Fonts，添加错误处理
  GoogleFonts.config.allowRuntimeFetching = false;
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        colorScheme: lightColorScheme,
        useMaterial3: true,
        // 使用自定义文本主题
        textTheme: createTextTheme(Typography.material2018().black),
      ),
      darkTheme: ThemeData(
        colorScheme: darkColorScheme,
        useMaterial3: true,
        // 使用自定义文本主题
        textTheme: createTextTheme(Typography.material2018().white),
      ),
      themeMode: themeMode,
      home: const HomeScreen(),
    );
  }
}

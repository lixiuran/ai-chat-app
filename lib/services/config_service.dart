import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static final ConfigService _instance = ConfigService._internal();
  late SharedPreferences _prefs;
  bool _initialized = false;

  factory ConfigService() {
    return _instance;
  }

  ConfigService._internal();

  Future<void> init() async {
    if (!_initialized) {
      await dotenv.load();
      _prefs = await SharedPreferences.getInstance();
      _initialized = true;
    }
  }

  String? getApiKey(String provider) {
    switch (provider.toLowerCase()) {
      case 'openai':
        return dotenv.env['OPENAI_API_KEY'];
      case 'anthropic':
        return dotenv.env['ANTHROPIC_API_KEY'];
      case 'deepseek':
        return dotenv.env['DEEPSEEK_API_KEY'];
      default:
        return null;
    }
  }

  Future<void> saveApiKey(String provider, String apiKey) async {
    await _prefs.setString('${provider.toLowerCase()}_api_key', apiKey);
  }

  // 主题设置
  bool isDarkMode() {
    return _prefs.getBool('dark_mode') ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('dark_mode', value);
  }

  // 聊天历史
  Future<void> saveChatHistory(String history) async {
    await _prefs.setString('chat_history', history);
  }

  String? getChatHistory() {
    return _prefs.getString('chat_history');
  }

  // 对话管理
  Future<void> saveConversations(String conversations) async {
    await _prefs.setString('conversations', conversations);
  }

  String? getConversations() {
    return _prefs.getString('conversations');
  }
} 
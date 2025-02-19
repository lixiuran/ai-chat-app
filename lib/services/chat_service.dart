import 'package:dio/dio.dart';
import 'package:ai_app/models/ai_model.dart';

class ChatService {
  final Dio _dio = Dio();
  
  Future<String> sendMessage(String message, AIModel model) async {
    try {
      // TODO: 实现实际的API调用
      // 这里是一个模拟的响应
      await Future.delayed(const Duration(seconds: 1));
      return "这是来自 ${model.name} 的响应：\n\n$message 的回复将在实际API集成后显示。";
    } catch (e) {
      return "发生错误：$e";
    }
  }

  // 根据不同的模型实现不同的API调用
  Future<String> _callOpenAI(String message, AIModel model) async {
    // TODO: 实现OpenAI API调用
    throw UnimplementedError();
  }

  Future<String> _callAnthropic(String message, AIModel model) async {
    // TODO: 实现Anthropic API调用
    throw UnimplementedError();
  }

  Future<String> _callDeepSeek(String message, AIModel model) async {
    // TODO: 实现DeepSeek API调用
    throw UnimplementedError();
  }
} 
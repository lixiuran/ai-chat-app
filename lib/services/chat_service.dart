import 'package:dio/dio.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:ai_app/services/config_service.dart';
import 'dart:developer' as developer;

class ChatService {
  final Dio _dio = Dio();
  final ConfigService _config = ConfigService();
  
  Future<String> sendMessage(String message, AIModel model) async {
    try {
      final apiKey = _config.getApiKey(model.provider);
      developer.log('Using provider: ${model.provider}, API Key: ${apiKey?.substring(0, 10)}...');
      
      if (apiKey == null) {
        return "错误：未设置${model.provider}的API密钥";
      }

      String response;
      switch (model.provider.toLowerCase()) {
        case 'openai':
          response = await _callOpenAI(message, model, apiKey);
          break;
        case 'anthropic':
          response = await _callAnthropic(message, model, apiKey);
          break;
        case 'deepseek':
          response = await _callDeepSeek(message, model, apiKey);
          break;
        default:
          return "错误：不支持的AI提供商";
      }
      return response;
    } catch (e, stackTrace) {
      developer.log('Error in sendMessage:', error: e, stackTrace: stackTrace);
      return "发生错误：$e";
    }
  }

  Future<String> _callOpenAI(String message, AIModel model, String apiKey) async {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model.id,
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': model.temperature,
          'max_tokens': model.maxTokens,
          'top_p': model.topP,
        },
      );

      return response.data['choices'][0]['message']['content'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _callAnthropic(String message, AIModel model, String apiKey) async {
    try {
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': model.id,
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'max_tokens': model.maxTokens,
        },
      );

      return response.data['content'][0]['text'];
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _callDeepSeek(String message, AIModel model, String apiKey) async {
    try {
      developer.log('Calling DeepSeek API...');
      final response = await _dio.post(
        'https://api.deepseek.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
        ),
        data: {
          'model': 'deepseek-chat',
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': model.temperature,
          'max_tokens': model.maxTokens,
          'top_p': model.topP,
        },
      );
      
      developer.log('DeepSeek API Response: ${response.data}');
      return response.data['choices'][0]['message']['content'];
    } catch (e, stackTrace) {
      developer.log('Error in _callDeepSeek:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 
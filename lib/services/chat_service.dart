import 'package:dio/dio.dart';
import 'package:ai_app/models/ai_model.dart';
import 'package:ai_app/services/config_service.dart';
import 'dart:developer' as developer;
import 'dart:convert';

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

  Stream<String> sendMessageStream(String message, AIModel model) async* {
    try {
      final apiKey = _config.getApiKey(model.provider);
      developer.log('Using provider: ${model.provider}, API Key: ${apiKey?.substring(0, 10)}...');
      
      if (apiKey == null) {
        yield "错误：未设置${model.provider}的API密钥";
        return;
      }

      switch (model.provider.toLowerCase()) {
        case 'openai':
          yield* _callOpenAIStream(message, model, apiKey);
          break;
        case 'anthropic':
          yield* _callAnthropicStream(message, model, apiKey);
          break;
        case 'deepseek':
          yield* _callDeepSeekStream(message, model, apiKey);
          break;
        default:
          yield "错误：不支持的AI提供商";
      }
    } catch (e, stackTrace) {
      developer.log('Error in sendMessageStream:', error: e, stackTrace: stackTrace);
      yield "发生错误：$e";
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

  Stream<String> _callOpenAIStream(String message, AIModel model, String apiKey) async* {
    try {
      final response = await _dio.post(
        'https://api.openai.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': model.id,
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'temperature': model.temperature,
          'max_tokens': model.maxTokens,
          'top_p': model.topP,
          'stream': true,
        },
      );

      await for (final chunk in response.data.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final jsonStr = line.substring(6);
            try {
              final Map<String, dynamic> data = jsonDecode(jsonStr);
              final content = data['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              developer.log('Error parsing JSON: $jsonStr', error: e);
              continue;
            }
          }
        }
      }
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

  Stream<String> _callAnthropicStream(String message, AIModel model, String apiKey) async* {
    try {
      final response = await _dio.post(
        'https://api.anthropic.com/v1/messages',
        options: Options(
          headers: {
            'x-api-key': apiKey,
            'anthropic-version': '2023-06-01',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
        ),
        data: {
          'model': model.id,
          'messages': [
            {'role': 'user', 'content': message}
          ],
          'max_tokens': model.maxTokens,
          'stream': true,
        },
      );

      await for (final chunk in response.data.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final jsonStr = line.substring(6);
            try {
              final Map<String, dynamic> data = jsonDecode(jsonStr);
              final content = data['delta']['text'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              developer.log('Error parsing JSON: $jsonStr', error: e);
              continue;
            }
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _callDeepSeek(String message, AIModel model, String apiKey) async {
    try {
      developer.log('Calling DeepSeek API...');
      
      // 检查消息是否包含图片提示
      if (message.contains('我发送了一张图片')) {
        return "抱歉，DeepSeek 模型目前不支持直接的图片分析功能。您可以尝试描述图片内容，我会基于您的描述进行回答。";
      }

      // 构建请求数据
      final data = {
        'model': model.id,
        'messages': [
          {'role': 'system', 'content': '你是一个有帮助的AI助手。'},
          {'role': 'user', 'content': message}
        ],
        'temperature': model.temperature,
        'max_tokens': model.maxTokens,
        'top_p': model.topP,
      };

      // 如果是 R1 模型，添加特殊功能配置
      if (model.id == 'deepseek-r1') {
        data['functions'] = [
          if (model.enableSearch)
            {
              'name': 'search',
              'description': '搜索互联网获取信息',
              'parameters': {
                'type': 'object',
                'properties': {
                  'query': {
                    'type': 'string',
                    'description': '搜索查询词',
                  }
                },
                'required': ['query']
              }
            },
          if (model.enableDeepThinking)
            {
              'name': 'think',
              'description': '进行深度思考和分析',
              'parameters': {
                'type': 'object',
                'properties': {
                  'thought': {
                    'type': 'string',
                    'description': '思考过程'
                  }
                },
                'required': ['thought']
              }
            }
        ];
        
        // 添加工具调用设置
        data['function_call'] = 'auto';
      }

      final response = await _dio.post(
        'https://api.deepseek.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => true, // 允许任何状态码
        ),
        data: data,
      );
      
      developer.log('DeepSeek API Response: ${response.data}');
      
      // 检查响应状态
      if (response.statusCode != 200) {
        return "API 调用失败：${response.statusCode} - ${response.data['error']?.toString() ?? '未知错误'}";
      }
      
      return response.data['choices'][0]['message']['content'];
    } catch (e, stackTrace) {
      developer.log('Error in _callDeepSeek:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Stream<String> _callDeepSeekStream(String message, AIModel model, String apiKey) async* {
    try {
      developer.log('Calling DeepSeek API with streaming...');
      
      // 检查消息是否包含图片提示
      if (message.contains('我发送了一张图片')) {
        yield "抱歉，DeepSeek 模型目前不支持直接的图片分析功能。您可以尝试描述图片内容，我会基于您的描述进行回答。";
        return;
      }

      // 构建请求数据
      final data = {
        'model': model.id,
        'messages': [
          {'role': 'system', 'content': '你是一个有帮助的AI助手。'},
          {'role': 'user', 'content': message}
        ],
        'temperature': model.temperature,
        'max_tokens': model.maxTokens,
        'top_p': model.topP,
        'stream': true,
      };

      // 如果是 R1 模型，添加特殊功能配置
      if (model.id == 'deepseek-r1') {
        data['functions'] = [
          if (model.enableSearch)
            {
              'name': 'search',
              'description': '搜索互联网获取信息',
              'parameters': {
                'type': 'object',
                'properties': {
                  'query': {
                    'type': 'string',
                    'description': '搜索查询词',
                  }
                },
                'required': ['query']
              }
            },
          if (model.enableDeepThinking)
            {
              'name': 'think',
              'description': '进行深度思考和分析',
              'parameters': {
                'type': 'object',
                'properties': {
                  'thought': {
                    'type': 'string',
                    'description': '思考过程'
                  }
                },
                'required': ['thought']
              }
            }
        ];
        
        // 添加工具调用设置
        data['function_call'] = 'auto';
      }

      final response = await _dio.post(
        'https://api.deepseek.com/v1/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          responseType: ResponseType.stream,
          validateStatus: (status) => true, // 允许任何状态码
        ),
        data: data,
      );

      // 检查响应状态
      if (response.statusCode != 200) {
        yield "API 调用失败：${response.statusCode}";
        return;
      }

      await for (final chunk in response.data.stream) {
        final lines = utf8.decode(chunk).split('\n');
        for (var line in lines) {
          if (line.startsWith('data: ') && line != 'data: [DONE]') {
            final jsonStr = line.substring(6);
            try {
              final Map<String, dynamic> data = jsonDecode(jsonStr);
              final content = data['choices'][0]['delta']['content'];
              if (content != null) {
                yield content;
              }
            } catch (e) {
              developer.log('Error parsing JSON: $jsonStr', error: e);
              continue;
            }
          }
        }
      }
    } catch (e, stackTrace) {
      developer.log('Error in _callDeepSeekStream:', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
} 
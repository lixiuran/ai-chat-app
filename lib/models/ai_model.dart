import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_model.freezed.dart';
part 'ai_model.g.dart';

@freezed
class AIModel with _$AIModel {
  const factory AIModel({
    required String id,
    required String name,
    required String provider,
    @Default(0) int maxTokens,
    @Default(0.7) double temperature,
    @Default(1.0) double topP,
    @Default(0) int topK,
  }) = _AIModel;

  factory AIModel.fromJson(Map<String, dynamic> json) => _$AIModelFromJson(json);
}

// 预定义的模型列表
final defaultModels = [
  const AIModel(
    id: 'deepseek-chat',
    name: 'DeepSeek Chat',
    provider: 'DeepSeek',
    maxTokens: 8192,
  ),
  const AIModel(
    id: 'deepseek-coder',
    name: 'DeepSeek Coder',
    provider: 'DeepSeek',
    maxTokens: 8192,
  ),
  const AIModel(
    id: 'gpt-4',
    name: 'GPT-4',
    provider: 'OpenAI',
    maxTokens: 8192,
  ),
  const AIModel(
    id: 'gpt-3.5-turbo',
    name: 'GPT-3.5 Turbo',
    provider: 'OpenAI',
    maxTokens: 4096,
  ),
  const AIModel(
    id: 'claude-3-opus',
    name: 'Claude 3 Opus',
    provider: 'Anthropic',
    maxTokens: 200000,
  ),
  const AIModel(
    id: 'claude-3-sonnet',
    name: 'Claude 3 Sonnet',
    provider: 'Anthropic',
    maxTokens: 200000,
  ),
]; 
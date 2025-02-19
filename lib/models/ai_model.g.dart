// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AIModelImpl _$$AIModelImplFromJson(Map<String, dynamic> json) =>
    _$AIModelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      maxTokens: (json['maxTokens'] as num?)?.toInt() ?? 0,
      temperature: (json['temperature'] as num?)?.toDouble() ?? 0.7,
      topP: (json['topP'] as num?)?.toDouble() ?? 1.0,
      topK: (json['topK'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$AIModelImplToJson(_$AIModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'provider': instance.provider,
      'maxTokens': instance.maxTokens,
      'temperature': instance.temperature,
      'topP': instance.topP,
      'topK': instance.topK,
    };

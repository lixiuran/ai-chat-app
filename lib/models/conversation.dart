import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required String id,
    required String title,
    required DateTime createdAt,
    @Default([]) List<Map<String, dynamic>> messages,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

extension ConversationX on Conversation {
  List<types.Message> get messagesList {
    return messages.map((m) {
      final type = m['type'] as String;
      final authorId = (m['author'] as Map<String, dynamic>)['id'] as String;
      final id = m['id'] as String;
      final createdAt = m['createdAt'] as int;

      switch (type) {
        case 'text':
          return types.TextMessage(
            author: types.User(id: authorId),
            id: id,
            text: m['text'] as String,
            createdAt: createdAt,
          );
        case 'image':
          return types.ImageMessage(
            author: types.User(id: authorId),
            id: id,
            uri: m['uri'] as String,
            name: m['name'] as String,
            size: m['size'] as int,
            createdAt: createdAt,
          );
        case 'file':
          return types.FileMessage(
            author: types.User(id: authorId),
            id: id,
            uri: m['uri'] as String,
            name: m['name'] as String,
            size: m['size'] as int,
            createdAt: createdAt,
          );
        default:
          throw UnimplementedError('Message type not supported');
      }
    }).toList();
  }
} 
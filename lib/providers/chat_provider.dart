import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/services/chat_service.dart';
import 'package:ai_app/providers/model_provider.dart';
import 'package:ai_app/services/config_service.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'dart:developer' as developer;

final isLoadingProvider = StateProvider<bool>((ref) => false);

class ChatMessagesNotifier extends StateNotifier<List<types.Message>> {
  final ChatService _chatService;
  final ConfigService _configService;
  final StateNotifierProviderRef ref;

  ChatMessagesNotifier(this.ref, this._chatService)
      : _configService = ConfigService(),
        super([]) {
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final history = _configService.getChatHistory();
    if (history != null) {
      final List<dynamic> messages = jsonDecode(history);
      state = messages.map((m) => _messageFromJson(m)).toList();
    }
  }

  Future<void> _saveMessages() async {
    final messages = state.map((m) => _messageToJson(m)).toList();
    await _configService.saveChatHistory(jsonEncode(messages));
  }

  Map<String, dynamic> _messageToJson(types.Message message) {
    if (message is types.TextMessage) {
      return {
        'type': 'text',
        'author': {'id': message.author.id},
        'id': message.id,
        'text': message.text,
        'createdAt': message.createdAt,
      };
    } else if (message is types.ImageMessage) {
      return {
        'type': 'image',
        'author': {'id': message.author.id},
        'id': message.id,
        'uri': message.uri,
        'name': message.name,
        'size': message.size,
        'createdAt': message.createdAt,
      };
    } else if (message is types.FileMessage) {
      return {
        'type': 'file',
        'author': {'id': message.author.id},
        'id': message.id,
        'uri': message.uri,
        'name': message.name,
        'size': message.size,
        'createdAt': message.createdAt,
      };
    }
    throw UnimplementedError('Message type not supported');
  }

  types.Message _messageFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'text':
        return types.TextMessage(
          author: types.User(id: json['author']['id']),
          id: json['id'],
          text: json['text'],
          createdAt: json['createdAt'],
        );
      case 'image':
        return types.ImageMessage(
          author: types.User(id: json['author']['id']),
          id: json['id'],
          uri: json['uri'],
          name: json['name'],
          size: json['size'],
          createdAt: json['createdAt'],
        );
      case 'file':
        return types.FileMessage(
          author: types.User(id: json['author']['id']),
          id: json['id'],
          uri: json['uri'],
          name: json['name'],
          size: json['size'],
          createdAt: json['createdAt'],
        );
      default:
        throw UnimplementedError('Message type not supported');
    }
  }

  Future<void> sendMessage(types.TextMessage message) async {
    state = [...state, message];
    await _saveMessages();

    ref.read(isLoadingProvider.notifier).state = true;
    try {
      final selectedModel = ref.read(selectedModelProvider);
      developer.log('Sending message with model: ${selectedModel.name}');
      
      final response = await _chatService.sendMessage(
        message.text,
        selectedModel,
      );

      final botMessage = types.TextMessage(
        author: const types.User(id: 'bot'),
        id: const Uuid().v4(),
        text: response,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      state = [...state, botMessage];
      await _saveMessages();
    } catch (e, stackTrace) {
      developer.log('Error sending message:', error: e, stackTrace: stackTrace);
    } finally {
      ref.read(isLoadingProvider.notifier).state = false;
    }
  }

  Future<void> addMessage(types.Message message) async {
    state = [...state, message];
    await _saveMessages();
  }

  Future<void> clearMessages() async {
    state = [];
    await _saveMessages();
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  return ChatService();
});

final chatMessagesProvider =
    StateNotifierProvider<ChatMessagesNotifier, List<types.Message>>((ref) {
  final chatService = ref.watch(chatServiceProvider);
  return ChatMessagesNotifier(ref, chatService);
}); 
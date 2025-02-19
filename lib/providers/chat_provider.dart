import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:ai_app/services/chat_service.dart';
import 'package:ai_app/providers/model_provider.dart';

class ChatMessagesNotifier extends StateNotifier<List<types.Message>> {
  final ChatService _chatService;
  final StateNotifierProviderRef ref;

  ChatMessagesNotifier(this.ref, this._chatService) : super([]);

  Future<void> sendMessage(types.TextMessage message) async {
    state = [...state, message];

    final selectedModel = ref.read(selectedModelProvider);
    final response = await _chatService.sendMessage(
      message.text,
      selectedModel,
    );

    final botMessage = types.TextMessage(
      author: const types.User(id: 'bot'),
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: response,
    );

    state = [...state, botMessage];
  }

  void clearMessages() {
    state = [];
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
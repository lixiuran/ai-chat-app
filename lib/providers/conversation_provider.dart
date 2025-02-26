import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/models/conversation.dart';
import 'package:ai_app/services/config_service.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, List<Conversation>>((ref) {
  return ConversationsNotifier();
});

final currentConversationProvider =
    StateNotifierProvider<CurrentConversationNotifier, String?>((ref) {
  return CurrentConversationNotifier(ref);
});

class ConversationsNotifier extends StateNotifier<List<Conversation>> {
  final _configService = ConfigService();
  
  ConversationsNotifier() : super([]) {
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    final data = _configService.getConversations();
    if (data != null) {
      final List<dynamic> jsonList = jsonDecode(data);
      state = jsonList.map((json) => Conversation.fromJson(json)).toList();
    }
  }

  Future<void> _saveConversations() async {
    final jsonList = state.map((conv) => conv.toJson()).toList();
    await _configService.saveConversations(jsonEncode(jsonList));
  }

  Future<String> createConversation(String title) async {
    final id = const Uuid().v4();
    final conversation = Conversation(
      id: id,
      title: title,
      createdAt: DateTime.now(),
    );
    state = [...state, conversation];
    await _saveConversations();
    return id;
  }

  Future<void> updateConversation(Conversation conversation) async {
    state = [
      for (final conv in state)
        if (conv.id == conversation.id) conversation else conv
    ];
    await _saveConversations();
  }

  Future<void> deleteConversation(String id) async {
    state = state.where((conv) => conv.id != id).toList();
    await _saveConversations();
  }

  /// 清空所有会话
  Future<void> clearConversations() async {
    state = [];
    await _saveConversations();
  }

  Conversation? getConversation(String id) {
    return state.firstWhere((conv) => conv.id == id);
  }
}

class CurrentConversationNotifier extends StateNotifier<String?> {
  final Ref ref;

  CurrentConversationNotifier(this.ref) : super(null);

  Future<void> setCurrentConversation(String? id) async {
    state = id;
  }

  Future<String> createAndSetNewConversation(String title) async {
    final id = await ref
        .read(conversationsProvider.notifier)
        .createConversation(title);
    state = id;
    return id;
  }
} 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/models/ai_model.dart';

final availableModelsProvider = Provider<List<AIModel>>((ref) {
  return defaultModels;
});

final selectedModelProvider = StateProvider<AIModel>((ref) {
  return defaultModels.first;
}); 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ai_app/providers/model_provider.dart';
import 'package:ai_app/models/ai_model.dart';

class ModelSelector extends ConsumerWidget {
  const ModelSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedModel = ref.watch(selectedModelProvider);
    final models = ref.watch(availableModelsProvider);

    return PopupMenuButton<AIModel>(
      initialValue: selectedModel,
      onSelected: (AIModel model) {
        ref.read(selectedModelProvider.notifier).state = model;
      },
      itemBuilder: (BuildContext context) {
        return models.map((AIModel model) {
          return PopupMenuItem<AIModel>(
            value: model,
            child: Row(
              children: [
                if (model == selectedModel)
                  const Icon(Icons.check, size: 16)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(model.name),
              ],
            ),
          );
        }).toList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedModel.name),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
} 
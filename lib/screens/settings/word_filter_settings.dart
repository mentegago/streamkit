import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/word_filter_rule.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/inner_screen.dart';
import 'package:streamkit_tts/widgets/radio_settings.dart';
import 'package:streamkit_tts/utils/theme_extensions.dart';

class WordFilterSettingsScreen extends StatelessWidget {
  const WordFilterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const InnerScreen(
        title: "Word Filter",
        children: [
          _FilterModeConfigGroup(),
          _WordListConfigGroup(),
        ],
      );
}

class _FilterModeConfigGroup extends StatelessWidget {
  const _FilterModeConfigGroup();

  @override
  Widget build(BuildContext context) {
    final isWhitelist = context.select(
      (Config config) => config.chatToSpeechConfiguration.isWordlistWhitelist,
    );

    return ConfigContainer(
      title: "How should the word filter work?",
      children: [
        RadioSettings<bool>(
          options: [
            RadioOption(
              value: false,
              title: "Block Mode",
              subtitle: "Skip messages containing words in the list",
              icon: Icons.block,
              selectedColor: context.customColors.failure,
            ),
            RadioOption(
              value: true,
              title: "Allowlist Mode",
              subtitle: "Only read messages containing words in the list",
              icon: Icons.check_circle_outline,
              selectedColor: context.customColors.success,
            ),
          ],
          selectedValue: isWhitelist,
          onChanged: (value) {
            final config = context.read<Config>();
            config.setWordFilter(
              rules: config.chatToSpeechConfiguration.wordFilterRules,
              isWhitelistingFilter: value,
            );
          },
        ),
      ],
    );
  }
}

class _WordListConfigGroup extends StatelessWidget {
  const _WordListConfigGroup();

  @override
  Widget build(BuildContext context) {
    final rules = context.select(
      (Config config) => config.chatToSpeechConfiguration.wordFilterRules,
    );

    final isWhitelist = context.select(
      (Config config) => config.chatToSpeechConfiguration.isWordlistWhitelist,
    );

    final theme = Theme.of(context);

    return ConfigContainer(
      title: "Word List",
      subtitle: Row(
        children: [
          Text(
            isWhitelist
                ? "Only messages containing these words will be read"
                : "Messages containing these words will not be read",
            style: theme.textTheme.bodySmall?.copyWith(
              color: isWhitelist
                  ? context.customColors.success
                  : context.customColors.failure,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      right: const _AddWordButton(),
      children: [
        if (rules.isNotEmpty) ...[
          for (int i = 0; i < rules.length; i++) ...[
            _WordListItem(rule: rules[i], index: i),
            if (i < rules.length - 1) const Divider(height: 1, indent: 48),
          ],
        ],
        if (rules.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWhitelist ? "No words allowed yet" : "No words blocked yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Click the + button above to add words",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.4),
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _AddWordButton extends StatelessWidget {
  const _AddWordButton();

  @override
  Widget build(BuildContext context) {
    final isWhitelist = context.select(
      (Config config) => config.chatToSpeechConfiguration.isWordlistWhitelist,
    );

    return FilledButton.icon(
      onPressed: () => _showWordDialog(context, existingRule: null, index: null),
      icon: const Icon(Icons.add, size: 18),
      label: Text(isWhitelist ? "Allow Word" : "Block Word"),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        backgroundColor: isWhitelist
            ? context.customColors.success
            : context.customColors.failure,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}

void _showWordDialog(
  BuildContext context, {
  required WordFilterRule? existingRule,
  required int? index,
}) {
  final wordController = TextEditingController(text: existingRule?.word ?? '');
  final formKey = GlobalKey<FormState>();
  bool caseSensitive = existingRule?.caseSensitive ?? false;
  bool wholeWord = existingRule?.wholeWord ?? false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existingRule != null ? 'Edit Word' : 'Add Word'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: wordController,
                decoration: const InputDecoration(
                  labelText: 'Word or phrase',
                  hintText: 'Text to filter',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Word cannot be empty';
                  }
                  return null;
                },
                autofocus: true,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    _saveRule(context, wordController, caseSensitive, wholeWord,
                        index, existingRule?.id);
                    Navigator.of(context).pop();
                  }
                },
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Case sensitive'),
                value: caseSensitive,
                onChanged: (value) => setState(() => caseSensitive = value),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
              SwitchListTile(
                title: const Text('Whole word only'),
                value: wholeWord,
                onChanged: (value) => setState(() => wholeWord = value),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                _saveRule(context, wordController, caseSensitive, wholeWord,
                    index, existingRule?.id);
                Navigator.of(context).pop();
              }
            },
            child: Text(existingRule != null ? 'Save' : 'Add'),
          ),
        ],
      ),
    ),
  );
}

void _saveRule(
  BuildContext context,
  TextEditingController wordController,
  bool caseSensitive,
  bool wholeWord,
  int? index,
  String? existingId,
) {
  final config = context.read<Config>();
  final rules = List<WordFilterRule>.from(
      config.chatToSpeechConfiguration.wordFilterRules);
  final newRule = WordFilterRule(
    id: existingId,
    word: wordController.text,
    caseSensitive: caseSensitive,
    wholeWord: wholeWord,
  );

  if (index != null) {
    rules[index] = newRule;
  } else {
    rules.add(newRule);
  }

  config.setWordFilter(
    rules: rules,
    isWhitelistingFilter:
        config.chatToSpeechConfiguration.isWordlistWhitelist,
  );
}

class _WordListItem extends StatelessWidget {
  final WordFilterRule rule;
  final int index;

  const _WordListItem({required this.rule, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(rule.word, style: Theme.of(context).textTheme.bodyMedium),
                if (rule.caseSensitive || rule.wholeWord) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      if (rule.caseSensitive)
                        const _Badge(label: 'Case sensitive'),
                      if (rule.caseSensitive && rule.wholeWord)
                        const SizedBox(width: 4),
                      if (rule.wholeWord) const _Badge(label: 'Whole word'),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                _showWordDialog(context, existingRule: rule, index: index),
            icon: const Icon(Icons.edit),
            tooltip: 'Edit word',
            style: IconButton.styleFrom(
                minimumSize: const Size(32, 32), iconSize: 18),
          ),
          IconButton(
            onPressed: () => _removeRule(context),
            icon: const Icon(Icons.delete),
            tooltip: 'Delete word',
            style: IconButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(32, 32),
              iconSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  void _removeRule(BuildContext context) {
    final config = context.read<Config>();
    final rules = List<WordFilterRule>.from(
        config.chatToSpeechConfiguration.wordFilterRules);
    rules.removeAt(index);
    config.setWordFilter(
      rules: rules,
      isWhitelistingFilter:
          config.chatToSpeechConfiguration.isWordlistWhitelist,
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;

  const _Badge({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

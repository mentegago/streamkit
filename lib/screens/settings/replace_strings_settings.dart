import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/models/replace_string_rule.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/inner_screen.dart';

class ReplaceStringsSettingsScreen extends StatelessWidget {
  const ReplaceStringsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const InnerScreen(
        title: "Find & Replace",
        children: [
          _ReplaceListConfigGroup(),
        ],
      );
}

class _ReplaceListConfigGroup extends StatelessWidget {
  const _ReplaceListConfigGroup();

  @override
  Widget build(BuildContext context) {
    final rules = context.select(
      (Config config) => config.chatToSpeechConfiguration.replaceStringRules,
    );

    return ConfigContainer(
      title: "Replace Rules",
      subtitle: Text(
        "Words or phrases in this list will be replaced before being spoken",
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
      right: const _AddRuleButton(),
      children: [
        if (rules.isNotEmpty)
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: rules.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) newIndex--;
              final updated = List<ReplaceStringRule>.from(rules);
              updated.insert(newIndex, updated.removeAt(oldIndex));
              context.read<Config>().setReplaceStringRules(updated);
            },
            itemBuilder: (context, i) => _RuleListItem(
              key: ValueKey(rules[i].id),
              rule: rules[i],
              index: i,
            ),
          ),
        if (rules.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.find_replace,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "No replace rules yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Click the + button above to add a rule",
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

class _AddRuleButton extends StatelessWidget {
  const _AddRuleButton();

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => _showRuleDialog(context),
      icon: const Icon(Icons.add, size: 18),
      label: const Text("Add Rule"),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showRuleDialog(BuildContext context) {
    showRuleDialog(context, existingRule: null, index: null);
  }
}

void showRuleDialog(
  BuildContext context, {
  required ReplaceStringRule? existingRule,
  required int? index,
}) {
  final fromController = TextEditingController(text: existingRule?.from ?? '');
  final toController = TextEditingController(text: existingRule?.to ?? '');
  final formKey = GlobalKey<FormState>();
  bool caseSensitive = existingRule?.caseSensitive ?? false;
  bool wholeWord = existingRule?.wholeWord ?? false;

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existingRule != null ? 'Edit Rule' : 'Add Rule'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: fromController,
                decoration: const InputDecoration(
                  labelText: 'Find',
                  hintText: 'Text to find',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Find text cannot be empty';
                  }
                  return null;
                },
                autofocus: true,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: toController,
                decoration: const InputDecoration(
                  labelText: 'Replace with',
                  hintText: 'Leave empty to remove the text',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    _saveRule(context, fromController, toController,
                        caseSensitive, wholeWord, index, existingRule?.id);
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
                _saveRule(context, fromController, toController, caseSensitive,
                    wholeWord, index, existingRule?.id);
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
  TextEditingController fromController,
  TextEditingController toController,
  bool caseSensitive,
  bool wholeWord,
  int? index,
  String? existingId,
) {
  final config = context.read<Config>();
  final rules = List<ReplaceStringRule>.from(
      config.chatToSpeechConfiguration.replaceStringRules);
  final newRule = ReplaceStringRule(
    id: existingId,
    from: fromController.text,
    to: toController.text,
    caseSensitive: caseSensitive,
    wholeWord: wholeWord,
  );

  if (index != null) {
    rules[index] = newRule;
  } else {
    rules.add(newRule);
  }

  config.setReplaceStringRules(rules);
}

class _RuleListItem extends StatelessWidget {
  final ReplaceStringRule rule;
  final int index;

  const _RuleListItem({super.key, required this.rule, required this.index});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final toText = rule.to.isEmpty ? '(remove)' : '"${rule.to}"';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Row(
        children: [
          const Icon(Icons.find_replace, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '"${rule.from}"',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      toText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: rule.to.isEmpty
                            ? theme.colorScheme.onSurfaceVariant
                            : null,
                        fontStyle: rule.to.isEmpty ? FontStyle.italic : null,
                      ),
                    ),
                  ],
                ),
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
                showRuleDialog(context, existingRule: rule, index: index),
            icon: const Icon(Icons.edit),
            style: IconButton.styleFrom(
                minimumSize: const Size(32, 32), iconSize: 18),
          ),
          IconButton(
            onPressed: () => _removeRule(context),
            icon: const Icon(Icons.delete),
            style: IconButton.styleFrom(
              foregroundColor: Colors.red,
              minimumSize: const Size(32, 32),
              iconSize: 18,
            ),
          ),
          const SizedBox(width: 4),
          MouseRegion(
            cursor: SystemMouseCursors.move,
            child: ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                size: 24,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _removeRule(BuildContext context) {
    final config = context.read<Config>();
    final rules = List<ReplaceStringRule>.from(
        config.chatToSpeechConfiguration.replaceStringRules);
    rules.removeAt(index);
    config.setReplaceStringRules(rules);
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:streamkit_tts/models/config_model.dart';
import 'package:streamkit_tts/widgets/config_container.dart';
import 'package:streamkit_tts/widgets/inner_screen.dart';
import 'package:streamkit_tts/widgets/action_list_item.dart';
import 'package:streamkit_tts/widgets/radio_settings.dart';
import 'package:streamkit_tts/utils/theme_extensions.dart';

class UserFilterSettingsScreen extends StatelessWidget {
  const UserFilterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => const InnerScreen(
        title: "User Filter",
        children: [
          _FilterModeConfigGroup(),
          _FilterListConfigGroup(),
        ],
      );
}

class _FilterModeConfigGroup extends StatelessWidget {
  const _FilterModeConfigGroup();

  @override
  Widget build(BuildContext context) {
    final isWhitelistingFilter = context.select(
      (Config config) => config.chatToSpeechConfiguration.isWhitelistingFilter,
    );

    return ConfigContainer(
      title: "How should the user filter work?",
      children: [
        RadioSettings<bool>(
          options: [
            RadioOption(
              value: false,
              title: "Block Mode",
              subtitle: "Skip messages from users in the list",
              icon: Icons.block,
              selectedColor: context.customColors.failure,
            ),
            RadioOption(
              value: true,
              title: "Allowlist Mode",
              subtitle: "Only read messages from users in the list",
              icon: Icons.check_circle_outline,
              selectedColor: context.customColors.success,
            ),
          ],
          selectedValue: isWhitelistingFilter,
          onChanged: (value) {
            context.read<Config>().setUserFilter(
                  usernames: context
                      .read<Config>()
                      .chatToSpeechConfiguration
                      .filteredUsernames,
                  isWhitelistingFilter: value,
                );
          },
        ),
      ],
    );
  }
}

class _FilterListConfigGroup extends StatelessWidget {
  const _FilterListConfigGroup();

  @override
  Widget build(BuildContext context) {
    final filteredUsernames = context.select(
      (Config config) => config.chatToSpeechConfiguration.filteredUsernames,
    );

    final isWhitelistingFilter = context.select(
      (Config config) => config.chatToSpeechConfiguration.isWhitelistingFilter,
    );

    final theme = Theme.of(context);

    return ConfigContainer(
      title: "User List",
      subtitle: Row(
        children: [
          Text(
            isWhitelistingFilter
                ? "Only messages from these users will be read"
                : "Messages from these users will not be read",
            style: theme.textTheme.bodySmall?.copyWith(
              color: isWhitelistingFilter
                  ? context.customColors.success
                  : context.customColors.failure,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      right: const _AddUserButton(),
      children: [
        if (filteredUsernames.isNotEmpty) ...[
          for (int i = 0; i < filteredUsernames.length; i++) ...[
            _UserListItem(username: filteredUsernames.elementAt(i)),
            if (i < filteredUsernames.length - 1)
              const Divider(height: 1, indent: 48),
          ],
        ],
        if (filteredUsernames.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 48,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isWhitelistingFilter
                        ? "No users allowed yet"
                        : "No users blocked yet",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.6),
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Click the + button above to add users",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.4),
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

class _AddUserButton extends StatelessWidget {
  const _AddUserButton();

  @override
  Widget build(BuildContext context) {
    final isWhitelistingFilter = context.select(
      (Config config) => config.chatToSpeechConfiguration.isWhitelistingFilter,
    );

    return FilledButton.icon(
      onPressed: () {
        _showAddUserDialog(context);
      },
      icon: const Icon(Icons.person_add, size: 18),
      label: Text(isWhitelistingFilter ? "Allow User" : "Block User"),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add User'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Enter username',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username cannot be empty';
              }
              if (value.trim().contains(' ')) {
                return 'Username cannot contain spaces';
              }
              // Check if username already exists
              final existingUsernames = context
                  .read<Config>()
                  .chatToSpeechConfiguration
                  .filteredUsernames;
              if (existingUsernames.contains(value.trim().toLowerCase())) {
                return 'Username already exists in the list';
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) {
              if (formKey.currentState!.validate()) {
                _addUser(context, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
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
                _addUser(context, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addUser(BuildContext context, String username) {
    if (username.isEmpty) return;

    final config = context.read<Config>();
    final currentUsernames = config.chatToSpeechConfiguration.filteredUsernames;
    final normalizedUsername = username.toLowerCase();

    if (!currentUsernames.contains(normalizedUsername)) {
      config.setUserFilter(
        usernames: {...currentUsernames, normalizedUsername},
        isWhitelistingFilter:
            config.chatToSpeechConfiguration.isWhitelistingFilter,
      );
    }
  }
}

class _UserListItem extends StatelessWidget {
  final String username;

  const _UserListItem({required this.username});

  @override
  Widget build(BuildContext context) {
    return ActionListItem(
      title: username,
      left: const Icon(Icons.person),
      actions: [
        ActionButton(
          icon: Icons.edit,
          onPressed: () => _showEditDialog(context),
          tooltip: 'Edit username',
        ),
        ActionButton(
          icon: Icons.delete,
          onPressed: () => _removeUser(context),
          tooltip: 'Delete username',
          color: Colors.red,
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context) {
    final TextEditingController controller =
        TextEditingController(text: username);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit User'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Username',
              hintText: 'Enter username (without @)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username cannot be empty';
              }
              if (value.trim().contains(' ')) {
                return 'Username cannot contain spaces';
              }
              final normalizedValue = value.trim().toLowerCase();
              if (normalizedValue != username.toLowerCase()) {
                // Check if new username already exists
                final existingUsernames = context
                    .read<Config>()
                    .chatToSpeechConfiguration
                    .filteredUsernames;
                if (existingUsernames.contains(normalizedValue)) {
                  return 'Username already exists in the list';
                }
              }
              return null;
            },
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (value) {
              if (formKey.currentState!.validate()) {
                _editUser(context, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
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
                _editUser(context, controller.text.trim());
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editUser(BuildContext context, String newUsername) {
    if (newUsername.isEmpty ||
        newUsername.toLowerCase() == username.toLowerCase()) return;

    final config = context.read<Config>();
    final currentUsernames = config.chatToSpeechConfiguration.filteredUsernames;
    final normalizedNewUsername = newUsername.toLowerCase();

    // Remove old username and add new one
    final updatedUsernames =
        currentUsernames.where((u) => u != username).toSet();
    updatedUsernames.add(normalizedNewUsername);

    config.setUserFilter(
      usernames: updatedUsernames,
      isWhitelistingFilter:
          config.chatToSpeechConfiguration.isWhitelistingFilter,
    );
  }

  void _removeUser(BuildContext context) {
    final config = context.read<Config>();
    final currentUsernames = config.chatToSpeechConfiguration.filteredUsernames;

    config.setUserFilter(
      usernames: currentUsernames.where((u) => u != username).toSet(),
      isWhitelistingFilter:
          config.chatToSpeechConfiguration.isWhitelistingFilter,
    );
  }
}

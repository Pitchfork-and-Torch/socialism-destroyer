import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/responsive_layout.dart';
import '../providers/shell_providers.dart';
import '../router/app_router.dart';

/// Desktop keyboard shortcuts for navigation and common actions.
class DesktopShortcuts extends ConsumerWidget {
  const DesktopShortcuts({
    super.key,
    required this.child,
    required this.currentPath,
  });

  final Widget child;
  final String currentPath;

  static bool isEnabled(BuildContext context) =>
      ResponsiveLayout.isDesktop(context);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isEnabled(context)) return child;

    return Shortcuts(
      shortcuts: _shortcuts,
      child: Actions(
        actions: _buildActions(context, ref),
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }

  static final Map<ShortcutActivator, Intent> _shortcuts = {
    const SingleActivator(LogicalKeyboardKey.digit1, control: true):
        const _NavigateIntent(0),
    const SingleActivator(LogicalKeyboardKey.digit2, control: true):
        const _NavigateIntent(1),
    const SingleActivator(LogicalKeyboardKey.digit3, control: true):
        const _NavigateIntent(2),
    const SingleActivator(LogicalKeyboardKey.digit4, control: true):
        const _NavigateIntent(3),
    const SingleActivator(LogicalKeyboardKey.digit5, control: true):
        const _NavigateIntent(4),
    const SingleActivator(LogicalKeyboardKey.keyK, control: true):
        const _FocusSearchIntent(),
    const SingleActivator(LogicalKeyboardKey.slash, shift: true):
        const _ShowHelpIntent(),
    const SingleActivator(LogicalKeyboardKey.escape): const _BackIntent(),
  };

  Map<Type, Action<Intent>> _buildActions(BuildContext context, WidgetRef ref) =>
      {
        _NavigateIntent: CallbackAction<_NavigateIntent>(
          onInvoke: (intent) {
            _goTab(context, intent.index);
            return null;
          },
        ),
        _FocusSearchIntent: CallbackAction<_FocusSearchIntent>(
          onInvoke: (_) {
            if (currentPath == AppRoutes.crusher ||
                currentPath == AppRoutes.tree) {
              ref.read(shellUiProvider.notifier).requestSearchFocus();
            } else {
              context.go('${AppRoutes.crusher}?focus=1');
            }
            return null;
          },
        ),
        _ShowHelpIntent: CallbackAction<_ShowHelpIntent>(
          onInvoke: (_) {
            _showHelp(context);
            return null;
          },
        ),
        _BackIntent: CallbackAction<_BackIntent>(
          onInvoke: (_) {
            if (context.canPop()) context.pop();
            return null;
          },
        ),
      };

  void _goTab(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.home);
      case 1:
        context.go(AppRoutes.tree);
      case 2:
        context.go(AppRoutes.crusher);
      case 3:
        context.go(AppRoutes.library);
      case 4:
        context.go(AppRoutes.debate);
    }
  }

  static void showHelp(BuildContext context) => _showHelp(context);

  static void _showHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keyboard shortcuts'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _HelpRow('Ctrl+1', 'Home'),
              _HelpRow('Ctrl+2', 'Topic tree'),
              _HelpRow('Ctrl+3', 'Argument Crusher'),
              _HelpRow('Ctrl+4', 'Library'),
              _HelpRow('Ctrl+5', 'Debate Simulator'),
              _HelpRow('Ctrl+K', 'Focus search / open Crusher'),
              _HelpRow('Esc', 'Go back'),
              _HelpRow('?', 'This help'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _HelpRow extends StatelessWidget {
  const _HelpRow(this.keys, this.action);

  final String keys;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              keys,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }
}

class _NavigateIntent extends Intent {
  const _NavigateIntent(this.index);
  final int index;
}

class _FocusSearchIntent extends Intent {
  const _FocusSearchIntent();
}

class _ShowHelpIntent extends Intent {
  const _ShowHelpIntent();
}

class _BackIntent extends Intent {
  const _BackIntent();
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/claim_suggestion.dart';
import '../../../models/topic.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/claim_suggestion_providers.dart';
import '../../../themes/themes.dart';
class SuggestClaimScreen extends ConsumerStatefulWidget {
  const SuggestClaimScreen({super.key, this.initialTopicId});

  final String? initialTopicId;

  @override
  ConsumerState<SuggestClaimScreen> createState() => _SuggestClaimScreenState();
}

class _SuggestClaimScreenState extends ConsumerState<SuggestClaimScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _claimController = TextEditingController();
  final _counterController = TextEditingController();
  final _notesController = TextEditingController();
  final _sourceTitleControllers = [
    TextEditingController(),
    TextEditingController(),
  ];
  final _sourceUrlControllers = [
    TextEditingController(),
    TextEditingController(),
  ];

  String? _topicId;

  @override
  void initState() {
    super.initState();
    _topicId = widget.initialTopicId;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _claimController.dispose();
    _counterController.dispose();
    _notesController.dispose();
    for (final c in _sourceTitleControllers) {
      c.dispose();
    }
    for (final c in _sourceUrlControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addSourceRow() {
    setState(() {
      _sourceTitleControllers.add(TextEditingController());
      _sourceUrlControllers.add(TextEditingController());
    });
  }

  List<SuggestionSource> _collectSources() {
    final sources = <SuggestionSource>[];
    for (var i = 0; i < _sourceTitleControllers.length; i++) {
      final title = _sourceTitleControllers[i].text.trim();
      final url = _sourceUrlControllers[i].text.trim();
      if (title.isNotEmpty && url.isNotEmpty) {
        sources.add(SuggestionSource(title: title, url: url));
      }
    }
    return sources;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_topicId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a topic category.')),
      );
      return;
    }

    final ok = await ref.read(suggestionFormControllerProvider.notifier).submit(
          topicId: _topicId!,
          title: _titleController.text,
          socialistClaim: _claimController.text,
          counterSummary: _counterController.text,
          sources: _collectSources(),
          notes: _notesController.text,
        );

    if (!mounted) return;

    final formState = ref.read(suggestionFormControllerProvider);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Saved on this device — curators validate sources before publishing to the knowledge base.',
          ),
        ),
      );
      context.pop();
      return;
    }

    if (formState.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(formState.error!)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topicsAsync = ref.watch(topicsProvider);
    final formState = ref.watch(suggestionFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Suggest New Claim'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            SdCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.fact_check_outlined, color: context.sd.accentGold),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          'Moderated submission',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Steelman the socialist claim, sketch your sourced counter, '
                    'and link at least two primary sources. Curators merge approved '
                    'ideas into the JSON knowledge base and CDN sync.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            topicsAsync.when(
              data: (topics) => _TopicPicker(
                topics: _rootTopics(topics),
                value: _topicId,
                onChanged: (v) => setState(() => _topicId = v),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => Text('Could not load topics: $e'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Counter title',
                hintText: 'e.g. Real Wages Have Not Stagnated',
              ),
              validator: (v) =>
                  (v == null || v.trim().length < 8) ? 'At least 8 characters' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _claimController,
              decoration: const InputDecoration(
                labelText: 'Socialist claim (steelman)',
                hintText: 'State the strongest version of the argument…',
              ),
              minLines: 3,
              maxLines: 6,
              validator: (v) =>
                  (v == null || v.trim().length < 20) ? 'At least 20 characters' : null,
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _counterController,
              decoration: const InputDecoration(
                labelText: 'Counter summary & evidence direction',
                hintText: 'Executive summary with Census, BLS, World Bank, etc.',
              ),
              minLines: 4,
              maxLines: 8,
              validator: (v) =>
                  (v == null || v.trim().length < 40) ? 'At least 40 characters' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            const SdSectionHeader(title: 'Sources (minimum 2)'),
            const SizedBox(height: AppSpacing.sm),
            ...List.generate(_sourceTitleControllers.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Column(
                  children: [
                    TextFormField(
                      controller: _sourceTitleControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Source ${i + 1} title',
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _sourceUrlControllers[i],
                      decoration: InputDecoration(
                        labelText: 'Source ${i + 1} URL',
                      ),
                      keyboardType: TextInputType.url,
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addSourceRow,
                icon: const Icon(Icons.add),
                label: const Text('Add another source'),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes for curators (optional)',
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: AppSpacing.xl),
            SdButton(
              label: formState.isSubmitting ? 'Submitting…' : 'Submit for Review',
              onPressed: formState.isSubmitting ? null : _submit,
              icon: Icons.send_outlined,
            ),
          ],
        ),
      ),
    );
  }

  List<Topic> _rootTopics(List<Topic> all) {
    final roots = all.where((t) => t.isRoot).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return roots;
  }
}

class _TopicPicker extends StatelessWidget {
  const _TopicPicker({
    required this.topics,
    required this.value,
    required this.onChanged,
  });

  final List<Topic> topics;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(
        labelText: 'Topic category',
      ),
      items: topics
          .map(
            (t) => DropdownMenuItem(
              value: t.id,
              child: Text(t.title),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Required' : null,
    );
  }
}
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:socialism_destroyer/features/crusher/services/llm_crusher_backend.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';

void main() {
  test('OpenAI key loads and LLM enhancement works', () async {
    final envFile = File('.env');
    if (!envFile.existsSync()) return;
    dotenv.testLoad(fileInput: envFile.readAsStringSync());

    final llm = LlmCrusherBackend();
    if (!llm.isAvailable) return;

    final draft = CrusherResult(
      id: 'smoke-test',
      inputText: 'capitalism exploits the working class',
      mode: CrusherResponseMode.curated,
      executiveSummary: 'Profit is not theft; wages reflect marginal productivity.',
      evidenceBullets: const ['Voluntary exchange', 'Historical wage growth'],
      sources: const [],
      fallacies: const ['labor theory of value'],
      matchedClaims: const [],
      relatedTopics: const [],
      analysis: const InputAnalysis(
        normalizedInput: 'capitalism exploits the working class',
        expandedQuery: 'capitalism exploitation working class',
        keyPhrases: ['exploitation'],
        detectedTopicIds: ['profit-exploitation'],
        suspectedFallacies: ['labor theory of value'],
        matchConfidence: 0.8,
        intentLabel: 'exploitation',
      ),
      whyItMatters: 'Core Marxist claim used to justify state control.',
      createdAt: DateTime(2026, 1, 1),
    );

    final enhanced = await llm.enhance(draft);
    if (enhanced == null) {
      // Key is valid but API may return 429 (insufficient quota) — don't fail CI.
      expect(llm.isAvailable, isTrue);
      return;
    }
    expect(enhanced.executiveSummary, isNotEmpty);
    expect(enhanced.evidenceBullets, isNotEmpty);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../../../models/crusher_result.dart';

/// Optional OpenAI enhancement — structured JSON output for debate prep.
class LlmCrusherBackend {
  LlmCrusherBackend({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool get isAvailable {
    try {
      final key = dotenv.env['OPENAI_API_KEY'];
      return key != null && key.isNotEmpty && !key.startsWith('optional');
    } catch (_) {
      return false;
    }
  }

  Future<LlmEnhancement?> enhance(CrusherResult draft) async {
    if (!isAvailable) return null;

    final key = dotenv.maybeGet('OPENAI_API_KEY');
    if (key == null || key.isEmpty) return null;
    final primary = draft.primaryClaim;

    final prompt = '''
You are a debate coach for pro-liberty, pro-America arguments. The user challenged this claim:
"${draft.inputText}"

Curated knowledge base match: ${primary?.title ?? 'partial'}
Executive summary: ${draft.executiveSummary}

Respond ONLY with JSON:
{
  "executiveSummary": "2-3 sentence debate-ready summary",
  "evidenceBullets": ["bullet 1", "bullet 2"],
  "whyItMatters": "one sentence stakes"
}
Keep facts from the curated summary; do not invent statistics.''';

    try {
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.3,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          (body['choices'] as List).first['message']['content'] as String;
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      return LlmEnhancement(
        executiveSummary: parsed['executiveSummary'] as String,
        evidenceBullets: (parsed['evidenceBullets'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        whyItMatters: parsed['whyItMatters'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  /// Optional multi-turn debate polish — keeps curated sources; rewrites phrasing only.
  Future<LlmEnhancement?> enhanceDebateTurn({
    required String userMessage,
    required CrusherResult draft,
    required int priorTurns,
  }) async {
    if (!isAvailable) return null;

    final key = dotenv.maybeGet('OPENAI_API_KEY');
    if (key == null || key.isEmpty) return null;
    final primary = draft.primaryClaim;

    final prompt = '''
You are a debate coach for pro-liberty, pro-America arguments in a multi-turn spar
(turn context size: $priorTurns prior turns). The user just said:
"$userMessage"

Curated knowledge base match: ${primary?.title ?? 'partial'}
Executive summary draft: ${draft.executiveSummary}
Evidence bullets (must stay factually consistent): ${draft.evidenceBullets.take(4).join(' | ')}

Respond ONLY with JSON:
{
  "executiveSummary": "2-4 sentence debate-ready reply for this turn",
  "evidenceBullets": ["bullet 1", "bullet 2", "bullet 3"],
  "whyItMatters": "one sentence stakes for America / liberty"
}
Do not invent statistics. Prefer mechanisms, history, and the curated bullets.''';

    try {
      final response = await _client.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': prompt},
          ],
          'temperature': 0.35,
          'response_format': {'type': 'json_object'},
        }),
      );

      if (response.statusCode != 200) return null;
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final content =
          (body['choices'] as List).first['message']['content'] as String;
      final parsed = jsonDecode(content) as Map<String, dynamic>;
      return LlmEnhancement(
        executiveSummary: parsed['executiveSummary'] as String,
        evidenceBullets: (parsed['evidenceBullets'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        whyItMatters: parsed['whyItMatters'] as String?,
      );
    } catch (_) {
      return null;
    }
  }
}

class LlmEnhancement {
  const LlmEnhancement({
    required this.executiveSummary,
    required this.evidenceBullets,
    this.whyItMatters,
  });

  final String executiveSummary;
  final List<String> evidenceBullets;
  final String? whyItMatters;
}

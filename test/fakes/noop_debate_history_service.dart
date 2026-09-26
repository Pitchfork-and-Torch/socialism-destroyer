import 'package:socialism_destroyer/features/crusher/services/debate_history_service.dart';
import 'package:socialism_destroyer/models/crusher_result.dart';
import 'package:socialism_destroyer/models/user_interaction.dart';

/// Skips Hive writes — avoids fake-async stalls in widget journey tests.
class NoOpDebateHistoryService extends DebateHistoryService {
  NoOpDebateHistoryService() : super();

  @override
  Future<DebateHistoryEntry> save(CrusherResult result) async {
    return DebateHistoryEntry(
      id: result.id,
      inputText: result.inputText,
      summary: result.executiveSummary,
      matchedClaimIds: result.matchedClaimIds,
      createdAt: result.createdAt,
    );
  }
}
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/claim.dart';

/// SQLite FTS5 index for instant full-text claim search on native/desktop.
/// Web falls back to in-memory fuzzy search in [SearchService].
class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;
  List<Claim> _webFallback = const [];

  bool get isFtsAvailable => !kIsWeb && _db != null;

  Future<void> init(List<Claim> claims) async {
    _webFallback = claims;
    if (kIsWeb) return;

    final dbPath = p.join(await getDatabasesPath(), 'socialism_destroyer.db');
    _db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async => _createFtsTable(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS claims_fts');
          await _createFtsTable(db);
        }
      },
    );

    await _reindex(claims);
  }

  Future<void> _createFtsTable(Database db) async {
    await db.execute('''
      CREATE VIRTUAL TABLE claims_fts USING fts5(
        claim_id UNINDEXED,
        title,
        socialist_claim,
        executive_summary,
        search_text,
        embedding_text,
        tags,
        tokenize = 'porter'
      );
    ''');
  }

  /// Rebuild FTS index after knowledge-base sync or reload.
  Future<void> reindex(List<Claim> claims) async {
    _webFallback = claims;
    await _reindex(claims);
  }

  Future<void> _reindex(List<Claim> claims) async {
    if (_db == null) return;
    final db = _db!;
    await db.transaction((txn) async {
      await txn.delete('claims_fts');
      for (final c in claims) {
        await txn.insert('claims_fts', {
          'claim_id': c.id,
          'title': c.title,
          'socialist_claim': c.socialistClaimText,
          'executive_summary': c.executiveSummary,
          'search_text': c.searchText,
          'embedding_text': c.ragText,
          'tags': c.tags.join(' '),
        });
      }
    });
  }

  Future<List<String>> searchClaimIds(String query, {int limit = 50}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    if (kIsWeb || _db == null) {
      return _webFallback
          .where((c) => c.searchText.toLowerCase().contains(trimmed.toLowerCase()))
          .take(limit)
          .map((c) => c.id)
          .toList();
    }

    final ftsQuery = _buildFtsMatchQuery(trimmed);
    if (ftsQuery == null) return [];

    try {
      final rows = await _db!.rawQuery('''
      SELECT claim_id FROM claims_fts
      WHERE claims_fts MATCH ?
      ORDER BY rank
      LIMIT ?
    ''', [ftsQuery, limit]);

      return rows.map((r) => r['claim_id'] as String).toList();
    } catch (_) {
      // Malformed FTS token — fall through to empty (SearchService fuzzy path).
      return [];
    }
  }

  /// Strips FTS5 metacharacters and caps term count for synonym-expanded queries.
  static String? _buildFtsMatchQuery(String raw) {
    final tokens = <String>[];
    for (final part in raw.split(RegExp(r'\s+'))) {
      final cleaned = part
          .toLowerCase()
          .replaceAll(RegExp(r"[^\w]"), '')
          .trim();
      if (cleaned.length < 2) continue;
      if (tokens.contains(cleaned)) continue;
      tokens.add(cleaned);
      if (tokens.length >= 10) break;
    }
    if (tokens.isEmpty) return null;
    return tokens.map((t) => '$t*').join(' ');
  }
}
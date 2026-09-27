import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/book.dart';
import '../models/claim.dart';
import '../models/knowledge_manifest.dart';
import '../models/topic.dart';
import '../utils/app_constants.dart';
import 'knowledge_overlay_store.dart';

/// Loads and caches the versioned knowledge base from bundled assets.
///
/// Reads [KnowledgeManifest] to resolve topic and claim bundle paths.
/// Higher-priority claim bundles override lower-priority entries with the
/// same [Claim.id] — enabling curated v2 seeds to supersede legacy data.
/// Synced overlay files in app documents take precedence when present.
class KnowledgeService {
  KnowledgeService({KnowledgeOverlayStore? overlayStore})
      : _overlay = overlayStore ?? KnowledgeOverlayStore();

  final KnowledgeOverlayStore _overlay;

  KnowledgeManifest? _manifest;
  TopicDocument? _topicDocument;
  List<Claim>? _claims;
  BookDocument? _bookDocument;

  KnowledgeOverlayStore get overlayStore => _overlay;

  Future<KnowledgeManifest> getManifest() async {
    _manifest ??= await _loadManifest();
    return _manifest!;
  }

  /// Bundled ship manifest (ignores overlay) — used for delta comparison.
  Future<KnowledgeManifest> getBundledManifest() async {
    final raw =
        await rootBundle.loadString(AppConstants.knowledgeManifestAsset);
    return KnowledgeManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<List<Topic>> getTopics() async {
    final doc = await _getTopicDocument();
    return doc.topics;
  }

  Future<TopicDocument> getTopicDocument() async => _getTopicDocument();

  Future<List<Claim>> getClaims() async {
    _claims ??= await _loadClaims();
    return _claims!;
  }

  Future<List<Book>> getBooks() async {
    final doc = await _getBookDocument();
    return doc?.books ?? [];
  }

  Future<Claim?> getClaimById(String id) async {
    final claims = await getClaims();
    try {
      return claims.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Claim>> getClaimsByTopic(String topicId) async {
    final claims = await getClaims();
    final doc = await _getTopicDocument();
    final topic = _findTopic(doc.topics, topicId);
    final ids = topic != null
        ? topic.descendantIds.toSet()
        : {topicId};
    return claims.where((c) => ids.contains(c.topicId)).toList();
  }

  Topic? _findTopic(List<Topic> roots, String id) {
    for (final root in roots) {
      if (root.id == id) return root;
      final found = _findTopic(root.children, id);
      if (found != null) return found;
    }
    return null;
  }

  Future<void> reload() async {
    _manifest = null;
    _topicDocument = null;
    _claims = null;
    _bookDocument = null;
  }

  Future<KnowledgeManifest> _loadManifest() async {
    final overlay = await _overlay.loadOverlayManifest();
    if (overlay != null) return overlay;

    final raw =
        await rootBundle.loadString(AppConstants.knowledgeManifestAsset);
    return KnowledgeManifest.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<String> _loadAssetJson(String assetPath) async {
    final overlayRaw = await _overlay.readOverlayAsset(assetPath);
    if (overlayRaw != null) return overlayRaw;
    return rootBundle.loadString(assetPath);
  }

  Future<TopicDocument> _getTopicDocument() async {
    if (_topicDocument != null) return _topicDocument!;
    final manifest = await getManifest();
    final raw = await _loadAssetJson(manifest.topicsAsset);
    _topicDocument =
        TopicDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _topicDocument!;
  }

  Future<BookDocument?> _getBookDocument() async {
    if (_bookDocument != null) return _bookDocument;
    final manifest = await getManifest();
    final booksAsset = manifest.booksAsset;
    if (booksAsset == null) return null;
    final raw = await _loadAssetJson(booksAsset);
    _bookDocument =
        BookDocument.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return _bookDocument;
  }

  Future<List<Claim>> _loadClaims() async {
    final manifest = await getManifest();
    final bundles = [...manifest.claimBundles]
      ..sort((a, b) => a.priority.compareTo(b.priority));

    final byId = <String, Claim>{};
    for (final ref in bundles) {
      final raw = await _loadAssetJson(ref.asset);
      final bundle =
          ClaimBundle.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      for (final claim in bundle.claims) {
        byId[claim.id] = claim;
      }
    }
    return byId.values.toList();
  }
}
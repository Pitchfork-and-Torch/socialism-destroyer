import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/claim_reading_link.dart';
/// Loads claim → book reading links from bundled JSON.
class ClaimReadingService {
  ClaimReadingService();

  List<ClaimReadingLink>? _cache;

  Future<List<ClaimReadingLink>> getAllLinks() async {
    if (_cache != null) return _cache!;
    const path = 'assets/data/v2/claim_reading_links.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['links'] as List<dynamic>)
        .map((e) => ClaimReadingLink.fromJson(e as Map<String, dynamic>))
        .toList();
    return _cache!;
  }

  Future<List<ClaimReadingLink>> linksForClaim(String claimId) async {
    final all = await getAllLinks();
    return all.where((l) => l.claimId == claimId).toList()
      ..sort((a, b) => a.priority.compareTo(b.priority));
  }
}
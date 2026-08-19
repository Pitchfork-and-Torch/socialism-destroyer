import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/debate_playlist.dart';

/// Loads curated timed-drill playlists from bundled JSON.
class DebatePlaylistService {
  List<DebatePlaylist>? _cache;

  Future<List<DebatePlaylist>> getPlaylists() async {
    if (_cache != null) return _cache!;
    const path = 'assets/data/v2/debate_playlists.json';
    final raw = await rootBundle.loadString(path);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = (json['playlists'] as List<dynamic>)
        .map(
          (e) => DebatePlaylist.fromJson(Map<String, dynamic>.from(e as Map)),
        )
        .toList();
    return _cache!;
  }

  Future<DebatePlaylist?> byId(String id) async {
    final all = await getPlaylists();
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}

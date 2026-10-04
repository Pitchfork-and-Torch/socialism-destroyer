import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/study_tool.dart';

class StudyToolsService {
  StudyToolsService({this.assetPath = 'assets/data/study_tools.json'});

  final String assetPath;
  StudyToolsDocument? _cache;

  Future<StudyToolsDocument> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _cache = StudyToolsDocument.fromJson(json);
    return _cache!;
  }
}
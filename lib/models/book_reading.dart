import 'package:equatable/equatable.dart';

/// Reading progress for an in-app book (offline-first, synced via profiles).
class BookReadingProgress extends Equatable {
  const BookReadingProgress({
    required this.bookId,
    required this.scrollFraction,
    required this.scrollOffset,
    this.chapterId,
    required this.updatedAt,
  });

  final String bookId;
  final double scrollFraction;
  final double scrollOffset;
  final String? chapterId;
  final DateTime updatedAt;

  factory BookReadingProgress.fromJson(Map<String, dynamic> json) =>
      BookReadingProgress(
        bookId: json['bookId'] as String,
        scrollFraction: (json['scrollFraction'] as num?)?.toDouble() ?? 0,
        scrollOffset: (json['scrollOffset'] as num?)?.toDouble() ?? 0,
        chapterId: json['chapterId'] as String?,
        updatedAt: DateTime.parse(
          json['updatedAt'] as String? ?? DateTime.now().toIso8601String(),
        ),
      );

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'scrollFraction': scrollFraction,
        'scrollOffset': scrollOffset,
        if (chapterId != null) 'chapterId': chapterId,
        'updatedAt': updatedAt.toIso8601String(),
      };

  BookReadingProgress copyWith({
    double? scrollFraction,
    double? scrollOffset,
    String? chapterId,
    DateTime? updatedAt,
  }) =>
      BookReadingProgress(
        bookId: bookId,
        scrollFraction: scrollFraction ?? this.scrollFraction,
        scrollOffset: scrollOffset ?? this.scrollOffset,
        chapterId: chapterId ?? this.chapterId,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  int get percentComplete => (scrollFraction.clamp(0, 1) * 100).round();

  @override
  List<Object?> get props => [bookId, scrollFraction, updatedAt];
}

/// User highlight with optional attached note.
class BookHighlight extends Equatable {
  const BookHighlight({
    required this.id,
    required this.start,
    required this.end,
    this.note,
    this.colorKey = 'gold',
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int start;
  final int end;
  final String? note;
  final String colorKey;
  final DateTime createdAt;
  final DateTime? updatedAt;

  factory BookHighlight.fromJson(Map<String, dynamic> json) => BookHighlight(
        id: json['id'] as String,
        start: json['start'] as int,
        end: json['end'] as int,
        note: json['note'] as String?,
        colorKey: json['colorKey'] as String? ?? 'gold',
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'start': start,
        'end': end,
        if (note != null && note!.isNotEmpty) 'note': note,
        'colorKey': colorKey,
        'createdAt': createdAt.toIso8601String(),
        if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      };

  BookHighlight copyWith({
    String? note,
    String? colorKey,
    DateTime? updatedAt,
  }) =>
      BookHighlight(
        id: id,
        start: start,
        end: end,
        note: note ?? this.note,
        colorKey: colorKey ?? this.colorKey,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  String get excerpt => '';

  @override
  List<Object?> get props => [id, start, end];
}

/// Aggregated per-book reading state stored in Hive.
class BookReadingState extends Equatable {
  const BookReadingState({
    required this.bookId,
    this.progress,
    this.highlights = const [],
    this.userNote,
  });

  final String bookId;
  final BookReadingProgress? progress;
  final List<BookHighlight> highlights;
  final String? userNote;

  factory BookReadingState.empty(String bookId) =>
      BookReadingState(bookId: bookId);

  factory BookReadingState.fromMaps({
    required String bookId,
    Map<String, dynamic>? progressMap,
    Map<String, dynamic>? annotationsMap,
  }) {
    final highlights = (annotationsMap?['highlights'] as List<dynamic>? ?? [])
        .map((e) => BookHighlight.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    return BookReadingState(
      bookId: bookId,
      progress: progressMap != null
          ? BookReadingProgress.fromJson(
              Map<String, dynamic>.from(progressMap)..['bookId'] = bookId,
            )
          : null,
      highlights: highlights,
      userNote: annotationsMap?['userNote'] as String?,
    );
  }

  @override
  List<Object?> get props => [bookId, progress, highlights.length];
}

/// A single in-book search hit.
class BookSearchMatch extends Equatable {
  const BookSearchMatch({
    required this.index,
    required this.start,
    required this.end,
    required this.preview,
  });

  final int index;
  final int start;
  final int end;
  final String preview;

  @override
  List<Object?> get props => [start];
}
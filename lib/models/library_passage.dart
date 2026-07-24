import 'package:equatable/equatable.dart';

/// A ranked passage from the public-domain library for debate RAG.
class LibraryPassageHit extends Equatable {
  const LibraryPassageHit({
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.snippet,
    required this.score,
    this.chapterId,
    this.chapterTitle,
    this.reason,
    this.claimId,
  });

  final String bookId;
  final String bookTitle;
  final String author;
  final String snippet;
  final double score;
  final String? chapterId;
  final String? chapterTitle;
  final String? reason;
  final String? claimId;

  Map<String, dynamic> toJson() => {
        'bookId': bookId,
        'bookTitle': bookTitle,
        'author': author,
        'snippet': snippet,
        'score': score,
        if (chapterId != null) 'chapterId': chapterId,
        if (chapterTitle != null) 'chapterTitle': chapterTitle,
        if (reason != null) 'reason': reason,
        if (claimId != null) 'claimId': claimId,
      };

  factory LibraryPassageHit.fromJson(Map<String, dynamic> json) =>
      LibraryPassageHit(
        bookId: json['bookId'] as String,
        bookTitle: json['bookTitle'] as String? ?? '',
        author: json['author'] as String? ?? '',
        snippet: json['snippet'] as String? ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0,
        chapterId: json['chapterId'] as String?,
        chapterTitle: json['chapterTitle'] as String?,
        reason: json['reason'] as String?,
        claimId: json['claimId'] as String?,
      );

  @override
  List<Object?> get props => [bookId, chapterId, snippet, score];
}

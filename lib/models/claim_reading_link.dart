import 'package:equatable/equatable.dart';

/// Curated link from a claim to a library book (and optional chapter).
class ClaimReadingLink extends Equatable {
  const ClaimReadingLink({
    required this.claimId,
    required this.bookId,
    required this.reason,
    this.chapterId,
    this.priority = 0,
  });

  final String claimId;
  final String bookId;
  final String? chapterId;
  final String reason;
  final int priority;

  factory ClaimReadingLink.fromJson(Map<String, dynamic> json) =>
      ClaimReadingLink(
        claimId: json['claimId'] as String,
        bookId: json['bookId'] as String,
        chapterId: json['chapterId'] as String?,
        reason: json['reason'] as String,
        priority: json['priority'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [claimId, bookId, priority];
}
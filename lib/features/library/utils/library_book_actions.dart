import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/book.dart';
import '../../shared/router/app_router.dart';

/// Opens an in-app reader or an external borrow/buy page for copyrighted works.
Future<void> openLibraryBook(
  BuildContext context, {
  required Book book,
  String? chapterId,
  String? claimId,
  String? topicId,
}) async {
  if (book.isExternal && book.externalUrl != null) {
    final uri = Uri.tryParse(book.externalUrl!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open ${book.title}')),
      );
    }
    return;
  }

  final path = AppRoutes.libraryReaderPath(
    book.id,
    chapterId: chapterId,
    claimId: claimId,
    topicId: topicId,
  );
  final current = GoRouterState.of(context).uri.path;
  if (AppRoutes.isOutsideShell(current)) {
    context.go(path);
  } else {
    context.push(path);
  }
}
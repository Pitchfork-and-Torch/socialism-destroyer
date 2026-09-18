import '../../../models/book.dart';

class BookContentBlock {
  const BookContentBlock({
    required this.text,
    required this.globalStart,
    required this.isHeader,
    this.chapterId,
    this.level = 0,
  });

  final String text;
  final int globalStart;
  final bool isHeader;
  final String? chapterId;
  final int level;
}

/// Parses bundled book text into offset-addressable blocks.
class BookContentParser {
  static List<BookContentBlock> parse(String content, List<BookChapter> chapters) {
    final blocks = <BookContentBlock>[];
    var offset = 0;

    void addBlock(String text, {bool isHeader = false, String? chapterId, int level = 0}) {
      if (text.trim().isEmpty) return;
      blocks.add(
        BookContentBlock(
          text: text.trim(),
          globalStart: offset,
          isHeader: isHeader,
          chapterId: chapterId,
          level: level,
        ),
      );
      offset += text.length;
    }

    final lines = content.split('\n');
    final buf = StringBuffer();
    var chapterIdx = 0;

    BookChapter? chapterForOffset(int off) {
      if (chapters.isEmpty) return null;
      BookChapter active = chapters.first;
      for (final ch in chapters) {
        if (ch.startOffset <= off) {
          active = ch;
        } else {
          break;
        }
      }
      return active;
    }

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      if (trimmed.startsWith('## ')) {
        if (buf.isNotEmpty) {
          addBlock('$buf\n', chapterId: chapterForOffset(offset)?.id);
          buf.clear();
        }
        final title = trimmed.substring(3).trim();
        final ch = chapterIdx < chapters.length ? chapters[chapterIdx] : null;
        if (ch != null && ch.title == title) chapterIdx++;
        addBlock('$title\n', isHeader: true, chapterId: ch?.id, level: 2);
        continue;
      }

      if (trimmed.startsWith('# ')) {
        if (buf.isNotEmpty) {
          addBlock('$buf\n');
          buf.clear();
        }
        addBlock('${trimmed.substring(2).trim()}\n', isHeader: true, level: 1);
        continue;
      }

      if (trimmed.startsWith('> ')) {
        if (buf.isNotEmpty) {
          addBlock('$buf\n');
          buf.clear();
        }
        addBlock('${trimmed.substring(2).trim()}\n', level: 0);
        continue;
      }

      if (trimmed.startsWith('*') && trimmed.endsWith('*') && !trimmed.startsWith('**')) {
        if (buf.isNotEmpty) {
          addBlock('$buf\n');
          buf.clear();
        }
        addBlock('${trimmed.replaceAll('*', '').trim()}\n', isHeader: true, level: 0);
        continue;
      }

      if (trimmed.isEmpty) {
        if (buf.isNotEmpty) {
          buf.writeln();
        }
        continue;
      }

      buf.writeln(line);
    }

    if (buf.isNotEmpty) {
      addBlock(buf.toString(), chapterId: chapterForOffset(offset)?.id);
    }

    return blocks;
  }

  static String fullTextLengthKey(List<BookContentBlock> blocks) {
    if (blocks.isEmpty) return '';
    final last = blocks.last;
    return '${last.globalStart + last.text.length}';
  }
}
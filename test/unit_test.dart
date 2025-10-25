import 'package:flutter_test/flutter_test.dart';
import 'package:kitaab/models/book.dart';
import 'package:kitaab/models/bookmark.dart';
import 'package:kitaab/models/highlight.dart';
import 'package:flutter/material.dart';

void main() {
  group('Book Model Tests', () {
    test('Book can be created with required fields', () {
      final book = Book(
        id: '123',
        title: 'Test Book',
        author: 'Test Author',
        filePath: '/path/to/book.epub',
        addedDate: DateTime.now(),
      );

      expect(book.id, '123');
      expect(book.title, 'Test Book');
      expect(book.author, 'Test Author');
      expect(book.progress, 0.0);
      expect(book.lastSpineIndex, 0);
    });

    test('Book progress can be updated', () {
      final book = Book(
        id: '123',
        title: 'Test Book',
        author: 'Test Author',
        filePath: '/path/to/book.epub',
        addedDate: DateTime.now(),
      );

      book.progress = 0.5;
      expect(book.progress, 0.5);
    });

    test('Book copyWith creates new instance with updated values', () {
      final original = Book(
        id: '123',
        title: 'Test Book',
        author: 'Test Author',
        filePath: '/path/to/book.epub',
        addedDate: DateTime.now(),
      );

      final updated = original.copyWith(progress: 0.75, lastSpineIndex: 5);

      expect(updated.progress, 0.75);
      expect(updated.lastSpineIndex, 5);
      expect(updated.title, original.title);
      expect(original.progress, 0.0); // Original unchanged
    });
  });

  group('Bookmark Model Tests', () {
    test('Bookmark can be created', () {
      final bookmark = Bookmark(
        id: 'bm1',
        bookId: 'book1',
        spineIndex: 5,
        chapterTitle: 'Chapter 5',
        createdDate: DateTime.now(),
        position: 0.5,
      );

      expect(bookmark.id, 'bm1');
      expect(bookmark.bookId, 'book1');
      expect(bookmark.spineIndex, 5);
      expect(bookmark.position, 0.5);
    });

    test('Bookmark stores correct position', () {
      final bookmark = Bookmark(
        id: 'bm1',
        bookId: 'book1',
        spineIndex: 10,
        chapterTitle: 'Chapter 10',
        createdDate: DateTime.now(),
        position: 0.75,
      );

      expect(bookmark.position, 0.75);
      expect(bookmark.spineIndex, 10);
    });
  });

  group('Highlight Model Tests', () {
    test('Highlight can be created with color', () {
      final highlight = Highlight(
        id: 'h1',
        bookId: 'book1',
        spineIndex: 3,
        selectedText: 'This is highlighted text',
        colorValue: Colors.yellow.value,
        createdDate: DateTime.now(),
        chapterTitle: 'Chapter 3',
      );

      expect(highlight.selectedText, 'This is highlighted text');
      expect(highlight.colorValue, Colors.yellow.value);
      expect(highlight.color, Colors.yellow);
    });

    test('Highlight copyWith updates note', () {
      final original = Highlight(
        id: 'h1',
        bookId: 'book1',
        spineIndex: 3,
        selectedText: 'Text',
        colorValue: Colors.yellow.value,
        createdDate: DateTime.now(),
        chapterTitle: 'Chapter 3',
      );

      final updated = original.copyWith(note: 'My new note');

      expect(updated.note, 'My new note');
      expect(updated.selectedText, original.selectedText);
      expect(original.note, null); // Original unchanged
    });

    test('Highlight supports multiple colors', () {
      final colors = [
        Colors.yellow.value,
        Colors.green.value,
        Colors.blue.value,
        Colors.pink.value,
      ];

      for (var colorValue in colors) {
        final highlight = Highlight(
          id: 'h1',
          bookId: 'book1',
          spineIndex: 1,
          selectedText: 'Text',
          colorValue: colorValue,
          createdDate: DateTime.now(),
          chapterTitle: 'Chapter 1',
        );

        expect(highlight.colorValue, colorValue);
        expect(highlight.color.value, colorValue);
      }
    });
  });
}

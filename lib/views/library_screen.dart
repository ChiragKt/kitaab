import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../providers/library_provider.dart';
import '../widgets/book_card.dart';
import 'reader_screen.dart';
import 'settings_screen.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState {
  bool _isGridView = true;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final books = ref.watch(libraryProvider);
    final recentBooks =
        books.where((b) => b.lastReadDate != null).take(3).toList();
    final filteredBooks =
        _searchQuery.isEmpty
            ? books
            : books
                .where(
                  (b) =>
                      b.title.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      b.author.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Library'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => setState(() => _isGridView = !_isGridView),
            tooltip: 'Toggle view',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search books...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),

          // Recent books section
          if (recentBooks.isNotEmpty && _searchQuery.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Text(
                    'Continue Reading',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(16),
                itemCount: recentBooks.length,
                itemBuilder: (context, index) {
                  return BookCard(
                    book: recentBooks[index],
                    isCompact: true,
                    onTap: () => _openBook(recentBooks[index]),
                  );
                },
              ),
            ),
            const Divider(),
          ],

          // All books
          Expanded(
            child:
                filteredBooks.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.book_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchQuery.isEmpty
                                ? 'No books yet'
                                : 'No books found',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text('Tap + to import an EPUB'),
                        ],
                      ),
                    )
                    : _isGridView
                    ? GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.65,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          book: filteredBooks[index],
                          onTap: () => _openBook(filteredBooks[index]),
                        );
                      },
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredBooks.length,
                      itemBuilder: (context, index) {
                        return BookCard(
                          book: filteredBooks[index],
                          isListView: true,
                          onTap: () => _openBook(filteredBooks[index]),
                        );
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _importBook,
        icon: const Icon(Icons.add),
        label: const Text('Import EPUB'),
      ),
    );
  }

  Future _importBook() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['epub'],
      );

      if (result != null && result.files.single.path != null) {
        final path = result.files.single.path!;
        if (!mounted) return;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()),
        );

        await ref.read(libraryProvider.notifier).importBook(path);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book imported successfully')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error importing book: $e')));
    }
  }

  void _openBook(book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderScreen(book: book)),
    );
  }
}

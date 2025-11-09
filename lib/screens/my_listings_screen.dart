import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../models/book.dart';
import '../widgets/cross_platform_image.dart';
import 'add_book_screen.dart';
import 'edit_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

  void _showDeleteDialog(BuildContext context, BookProvider bookProvider, Book book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Book'),
        content: Text('Are you sure you want to delete "${book.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bookProvider.deleteBook(book.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Book deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddBookScreen()),
            ),
          ),
        ],
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
          final books = bookProvider.userBooks;
          
          return books.isEmpty
              ? const Center(child: Text('No books listed'))
              : ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: book.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: CrossPlatformImage(
                                  imageSource: book.imageUrl,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Icon(Icons.book),
                        title: Text(book.title),
                        subtitle: Text('${book.author} - ${book.condition}'),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditBookScreen(book: book),
                                ),
                              );
                            } else if (value == 'delete') {
                              _showDeleteDialog(context, bookProvider, book);
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
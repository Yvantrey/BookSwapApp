import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../providers/book_provider.dart';
import '../models/book.dart';
import 'add_book_screen.dart';

class MyListingsScreen extends StatelessWidget {
  const MyListingsScreen({super.key});

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
          final offers = bookProvider.userOffers;
          
          return Column(
            children: [
              if (offers.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text('My Offers', style: Theme.of(context).textTheme.headlineSmall),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: offers.length,
                  itemBuilder: (context, index) {
                    final offer = offers[index];
                    return Card(
                      child: ListTile(
                        title: const Text('Swap Offer'),
                        subtitle: Text('Status: ${offer.status}'),
                        trailing: Chip(label: Text(offer.status)),
                      ),
                    );
                  },
                ),
              ],
              Expanded(
                child: books.isEmpty
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
                                      child: book.imageUrl.startsWith('http')
                                          ? Image.network(book.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                          : Image.file(File(book.imageUrl), width: 50, height: 50, fit: BoxFit.cover),
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
                                  if (value == 'delete') {
                                    bookProvider.deleteBook(book.id);
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
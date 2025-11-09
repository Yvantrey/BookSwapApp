import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/swap.dart';
import '../models/book.dart';
import 'dart:io';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Textbooks', 'Fiction', 'Non-Fiction', 'Science', 'Mystery and Thriller', 'Literature', 'Technology', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Books'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search books by title or author...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _categories.map((category) {
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCategory = category;
                            });
                          },
                          backgroundColor: const Color(0xFF0F163A),
                          selectedColor: const Color(0xFFF9C73D),
                          labelStyle: TextStyle(
                            color: isSelected ? const Color(0xFF0D1232) : const Color(0xFFFFFFFF),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          // Books List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                // Force refresh by rebuilding the widget
                setState(() {});
              },
              child: Consumer<BookProvider>(
                builder: (context, bookProvider, _) {
                final allBooks = bookProvider.books;
                final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
                
                print('Books in explore: ${allBooks.length}');
                for (var book in allBooks) {
                  print('Book: ${book.title} by ${book.author}');
                }
                
                // Filter books based on search and category
                final filteredBooks = allBooks.where((book) {
                  final matchesSearch = _searchController.text.isEmpty ||
                      book.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                      book.author.toLowerCase().contains(_searchController.text.toLowerCase());
                  
                  final matchesCategory = _selectedCategory == 'All' || book.category == _selectedCategory;
                  
                  return matchesSearch && matchesCategory;
                }).toList();
                
                print('Filtered books: ${filteredBooks.length}');
                
                if (filteredBooks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          _searchController.text.isNotEmpty || _selectedCategory != 'All'
                              ? 'No books found matching your criteria'
                              : 'No books available',
                          style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Total books in database: ${allBooks.length}',
                          style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.builder(
                  itemCount: filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = filteredBooks[index];
                    final isOwner = book.ownerId == currentUserId;
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: book.imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: book.imageUrl.startsWith('http')
                                    ? Image.network(book.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                                    : Image.file(File(book.imageUrl), width: 50, height: 50, fit: BoxFit.cover),
                              )
                            : const Icon(Icons.book, size: 50),
                        title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('by ${book.author}'),
                            Text('${book.condition} • ${book.category}', style: TextStyle(color: Colors.grey[600])),
                            if (isOwner) const Text('Your book', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        trailing: isOwner 
                            ? const Icon(Icons.person, color: Colors.blue)
                            : ElevatedButton(
                                onPressed: () => _initiateSwap(context, book),
                                child: const Text('Swap'),
                              ),
                        isThreeLine: true,
                      ),
                    );
                  },
                );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initiateSwap(BuildContext context, Book book) async {
    final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
    
    // Create swap offer
    final offer = SwapOffer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: book.id,
      requesterId: currentUserId,
      ownerId: book.ownerId,
      createdAt: DateTime.now(),
    );
    
    context.read<BookProvider>().createSwapOffer(offer);
    
    // Create or get chat
    final chatId = await context.read<BookProvider>().createChat(book.ownerId, book.id, currentUserId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Swap offer sent! You can now chat with the owner.')),
    );
  }
}
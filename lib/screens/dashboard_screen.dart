import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/swap.dart';
import '../models/book.dart';
import '../widgets/cross_platform_image.dart';
import 'add_book_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  final List<String> _categories = ['All', 'General', 'Textbooks', 'Fiction', 'Non-Fiction', 'Science', 'Mystery and Thriller', 'Literature', 'Technology', 'Other'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
      
          final userProfile = bookProvider.userProfile;
          final totalBooks = bookProvider.books.length;
          final myBooks = bookProvider.userBooks.length;
          final myOffers = bookProvider.userOffers.length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Stats Section
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back, ${userProfile?.name ?? 'User'}!',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.book, size: 32),
                                    Text('$totalBooks', style: Theme.of(context).textTheme.headlineMedium),
                                    const Text('Available Books'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    const Icon(Icons.library_books, size: 32),
                                    Text('$myBooks', style: Theme.of(context).textTheme.headlineMedium),
                                    const Text('My Books'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              const Icon(Icons.swap_horiz, size: 32),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$myOffers', style: Theme.of(context).textTheme.headlineMedium),
                                  const Text('Active Swap Offers'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Explore Books Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                const SizedBox(height: 16),
                // Books List
                _buildBooksList(bookProvider),
                const SizedBox(height: 80), // Add bottom padding for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddBookScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBooksList(BookProvider bookProvider) {
    final allBooks = bookProvider.books;
    final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
    
    // Debug info

    
    final filteredBooks = allBooks.where((book) {
      final matchesSearch = _searchController.text.isEmpty ||
          book.title.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          book.author.toLowerCase().contains(_searchController.text.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'All' || book.category == _selectedCategory;
      
      // Show ALL books including user's own books for now
      // final isNotOwner = book.ownerId != currentUserId;
      
      return matchesSearch && matchesCategory; // Removed isNotOwner filter
    }).toList();
    

    
    if (filteredBooks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              allBooks.isEmpty 
                  ? 'No books available. Add some books to get started!'
                  : _searchController.text.isNotEmpty || _selectedCategory != 'All'
                      ? 'No books found matching your criteria'
                      : 'No books available',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: filteredBooks.map((book) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                : const Icon(Icons.book, size: 50),
            title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('by ${book.author}'),
                Text('${book.condition} • ${book.category}', style: TextStyle(color: Colors.grey[600])),
                if (book.swapFor.isNotEmpty) Text('Wants: ${book.swapFor}', style: TextStyle(color: Colors.blue[600], fontStyle: FontStyle.italic)),
              ],
            ),
            trailing: book.ownerId == currentUserId 
                ? const Chip(label: Text('Your Book'))
                : ElevatedButton(
                    onPressed: () => _initiateSwap(context, book),
                    child: const Text('Swap'),
                  ),
            isThreeLine: true,
          ),
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initiateSwap(BuildContext context, Book book) async {
    final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final bookProvider = context.read<BookProvider>();
    
    if (book.ownerId == currentUserId) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('You cannot swap your own book!')),
      );
      return;
    }
    
    final offer = SwapOffer(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      bookId: book.id,
      requesterId: currentUserId,
      ownerId: book.ownerId,
      createdAt: DateTime.now(),
    );
    
    bookProvider.createSwapOffer(offer);
    
    await bookProvider.createChat(book.ownerId, book.id, currentUserId);
    
    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Swap offer sent! You can now chat with the owner.')),
      );
    }
  }
}
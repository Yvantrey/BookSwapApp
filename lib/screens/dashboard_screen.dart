import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import 'add_book_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
          final user = context.read<AuthProvider>().user;
          final userProfile = bookProvider.userProfile;
          final totalBooks = bookProvider.books.length;
          final myBooks = bookProvider.userBooks.length;
          final myOffers = bookProvider.userOffers.length;

          return Padding(
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
}
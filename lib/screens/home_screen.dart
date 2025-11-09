import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import 'dashboard_screen.dart';
import 'my_listings_screen.dart';
import 'my_offers_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _screens = [
      const DashboardScreen(),
      const MyListingsScreen(),
      const MyOffersScreen(),
      const ChatsScreen(),
      const ProfileScreen(),
    ];
  }

  void _initializeProviders(String userId) {
    if (!_initialized && userId.isNotEmpty) {
      context.read<BookProvider>().listenToBooks();
      context.read<BookProvider>().listenToUserBooks(userId);
      context.read<BookProvider>().listenToUserOffers(userId);
      context.read<BookProvider>().listenToUserChats(userId);
      context.read<BookProvider>().loadUserProfile(userId);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final userId = authProvider.user?.uid ?? '';
        _initializeProviders(userId);
        
        return Scaffold(
          body: _screens[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
              BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Listings'),
              BottomNavigationBarItem(icon: Icon(Icons.swap_horiz), label: 'My Offers'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
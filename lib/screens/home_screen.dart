import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/book_provider.dart';
import 'dashboard_screen.dart';
import 'explore_screen.dart';
import 'my_listings_screen.dart';
import 'chats_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user?.uid ?? '';
    context.read<BookProvider>().listenToBooks();
    context.read<BookProvider>().listenToUserBooks(userId);
    context.read<BookProvider>().listenToUserOffers(userId);
    context.read<BookProvider>().listenToUserChats(userId);
    context.read<BookProvider>().loadUserProfile(userId);
    
    _screens = [
      const DashboardScreen(),
      const ExploreScreen(),
      const MyListingsScreen(),
      const ChatsScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'My Listings'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
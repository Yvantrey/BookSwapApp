import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_detail_screen.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  ChatsScreenState createState() => ChatsScreenState();
}

class ChatsScreenState extends State<ChatsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
          if (currentUserId.isNotEmpty) {
            context.read<BookProvider>().listenToUserChats(currentUserId);
          }
        },
        child: Consumer<BookProvider>(builder: (context, bookProvider, _) {
        final chats = bookProvider.userChats;
        final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
        
        if (chats.isEmpty) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9C73D).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Color(0xFFF9C73D),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No conversations yet',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Start swapping books to begin chatting\nwith other book lovers!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[400],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to dashboard page
                        DefaultTabController.of(context).animateTo(0);
                      },
                      icon: const Icon(Icons.dashboard),
                      label: const Text('Explore Books'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildFeatureChip('📚', 'Browse'),
                        const SizedBox(width: 12),
                        _buildFeatureChip('🔄', 'Swap'),
                        const SizedBox(width: 12),
                        _buildFeatureChip('💬', 'Chat'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: chats.length,
          itemBuilder: (context, index) {
            final chat = chats[index];
            final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
            
            return AnimatedContainer(
              duration: Duration(milliseconds: 300 + (index * 100)),
              curve: Curves.easeOutBack,
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFF9C73D),
                        child: const Icon(Icons.person, color: Color(0xFF0D1232)),
                      ),
                      if (chat.lastMessage.isNotEmpty)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: const Text(
                    'Book Exchange Chat',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.lastMessage.isEmpty ? 'Tap to start chatting!' : chat.lastMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: chat.lastMessage.isEmpty ? Colors.grey[400] : Colors.grey[300],
                          fontStyle: chat.lastMessage.isEmpty ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule, size: 12, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            _formatTime(chat.lastMessageTime),
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  isThreeLine: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(
                        chatId: chat.id,
                        otherUserId: otherUserId,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      }),
      ),
    );
  }

  Widget _buildFeatureChip(String emoji, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0F163A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF9C73D).withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white)),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
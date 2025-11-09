import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../providers/auth_provider.dart';
import '../models/swap.dart';
import '../widgets/cross_platform_image.dart';

class MyOffersScreen extends StatelessWidget {
  const MyOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Offers'),
        centerTitle: true,
      ),
      body: Consumer<BookProvider>(
        builder: (context, bookProvider, _) {
          final currentUserId = context.read<AuthProvider>().user?.uid ?? '';
          final allOffers = bookProvider.userOffers;
          
          // Show offers where current user is the owner (incoming requests)
          final incomingOffers = allOffers.where((offer) {
            final book = bookProvider.books.where((b) => b.id == offer.bookId).firstOrNull;
            return book != null && offer.ownerId == currentUserId;
          }).toList();
          
          // Show offers where current user is the requester (outgoing requests)
          final outgoingOffers = allOffers.where((offer) {
            final book = bookProvider.books.where((b) => b.id == offer.bookId).firstOrNull;
            return book != null && offer.requesterId == currentUserId;
          }).toList();
          
          if (incomingOffers.isEmpty && outgoingOffers.isEmpty) {
            return Center(
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
                      Icons.swap_horiz,
                      size: 80,
                      color: Color(0xFFF9C73D),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No swap offers yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start exploring books and make\nswap offers to see them here!',
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
                      DefaultTabController.of(context).animateTo(0);
                    },
                    icon: const Icon(Icons.explore),
                    label: const Text('Explore Books'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (incomingOffers.isNotEmpty) ...[
                  const Text(
                    'Incoming Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...incomingOffers.map((offer) => _buildOfferCard(
                    context, offer, bookProvider, currentUserId, true
                  )),
                  const SizedBox(height: 24),
                ],
                if (outgoingOffers.isNotEmpty) ...[
                  const Text(
                    'My Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...outgoingOffers.map((offer) => _buildOfferCard(
                    context, offer, bookProvider, currentUserId, false
                  )),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, SwapOffer offer, BookProvider bookProvider, String currentUserId, bool isIncoming) {
    final book = bookProvider.books.firstWhere((b) => b.id == offer.bookId);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                book.imageUrl.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CrossPlatformImage(
                          imageSource: book.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.book, size: 30),
                      ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text('by ${book.author}'),
                      const SizedBox(height: 4),
                      Text(
                        isIncoming ? 'Someone wants your book' : 'You requested this book',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(offer.status),
              ],
            ),
            const SizedBox(height: 16),
            if (isIncoming && offer.status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleOfferResponse(context, offer, 'accepted'),
                      icon: const Icon(Icons.check),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleOfferResponse(context, offer, 'rejected'),
                      icon: const Icon(Icons.close),
                      label: const Text('Reject'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            Text(
              'Created: ${_formatDate(offer.createdAt)}',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.schedule;
        break;
      case 'accepted':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleOfferResponse(BuildContext context, SwapOffer offer, String newStatus) {
    context.read<BookProvider>().updateSwapOfferStatus(offer.id, newStatus);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Offer $newStatus!'),
        backgroundColor: newStatus == 'accepted' ? Colors.green : Colors.red,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
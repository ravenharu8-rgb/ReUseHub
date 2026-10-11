import 'dart:io';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'chat_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
class ItemDetailScreen extends StatefulWidget {
  final ReuseItem item;

  const ItemDetailScreen({super.key, required this.item});

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF0F3811);
    final item = widget.item;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image Display
            SizedBox(
              height: 250,
              child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                  ? Image.file(
                File(item.imagePath),
                fit: BoxFit.cover,
              )
                  : Container(
                color: const Color(0xFFE8F5E9),
                child: const Icon(Icons.recycling, size: 80, color: primaryColor),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '₱${item.estimatedValue.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(item.condition),
                    backgroundColor: const Color(0xFFE8F5E9),
                    labelStyle: const TextStyle(color: primaryColor),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description.isNotEmpty ? item.description : 'No description provided.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        item.isClaimed = !item.isClaimed;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(item.isClaimed ? 'Item marked as claimed!' : 'Item marked as available.'),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.isClaimed ? Colors.grey : primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(item.isClaimed ? 'Claimed' : 'Claim Item'),
                  ),
                  // Inside ItemDetailScreen actions / buttons column:
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      // 1. Get the current logged-in user instance
                      final currentUser = FirebaseAuth.instance.currentUser;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatDetailScreen(
                            chatId: '${currentUser?.uid ?? "guest"}_${widget.item.userId}',
                            peerName: widget.item.userName,
                            itemTitle: widget.item.title,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF0F3811)),
                    label: const Text(
                      'Chat with Owner',
                      style: TextStyle(color: Color(0xFF0F3811), fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF0F3811), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
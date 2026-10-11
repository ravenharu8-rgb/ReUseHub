import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final currentUser = FirebaseAuth.instance.currentUser;
  bool _pushNotifications = true;
  bool _emailAlerts = false;

  void _showEditProfileDialog(String currentName, String currentUniversity) {
    final nameController = TextEditingController(text: currentName);
    final universityController = TextEditingController(text: currentUniversity);
    const activeGreen = Color(0xFF0F3811);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: universityController,
                decoration: const InputDecoration(labelText: 'University Name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: activeGreen),
              onPressed: () async {
                final newName = nameController.text.trim();
                final newUniversity = universityController.text.trim();

                if (newName.isNotEmpty && currentUser != null) {
                  await currentUser!.updateDisplayName(newName);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUser!.uid)
                      .set({
                    'fullName': newName,
                    'university': newUniversity,
                  }, SetOptions(merge: true));

                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: activeGreen,
                    ),
                  );
                }
              },
              child: const Text('Save', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const activeGreen = Color(0xFF0F3811);

    return Scaffold(
      backgroundColor: Color(0xFFE8F5E9),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .snapshots(),
        builder: (context, userSnapshot) {
          String displayName = currentUser?.displayName ?? 'Campus Student';
          String universityName = 'UMDC';

          if (userSnapshot.hasData && userSnapshot.data!.exists) {
            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            displayName = userData['fullName'] ?? userData['name'] ?? displayName;
            universityName = userData['university'] ?? userData['universityName'] ?? universityName;
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('items')
                .where('userId', isEqualTo: currentUser?.uid)
                .snapshots(),
            builder: (context, itemSnapshot) {
              int itemsReused = 0;
              double pesosSaved = 0.0;
              double wasteDivertedKg = 0.0; // Spec requirement: waste diverted

              if (itemSnapshot.hasData) {
                final docs = itemSnapshot.data!.docs;
                itemsReused = docs.length;

                for (var doc in docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final priceStr = data['price']?.toString() ?? '150';
                  final price = double.tryParse(priceStr.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 150.0;

                  pesosSaved += price;
                  wasteDivertedKg += 1.2; // Estimate 1.2 kg of landfill waste diverted per item reused
                }
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
                      decoration: const BoxDecoration(
                        color: activeGreen,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Impact & Settings',
                            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(Icons.person, color: activeGreen),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        displayName,
                                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        universityName.toUpperCase(),
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white70, size: 20),
                                  onPressed: () => _showEditProfileDialog(displayName, universityName),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Statistics Grid Cards (Directly matching project spec impact metrics)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.5,
                        children: [
                          _buildStatCard('Items Reused', '$itemsReused', Icons.autorenew, Colors.green),
                          _buildStatCard('Pesos Saved', '₱${pesosSaved.toStringAsFixed(2)}', Icons.wallet, Colors.blue),
                          _buildStatCard('Waste Diverted', '${wasteDivertedKg.toStringAsFixed(1)} kg', Icons.eco, Colors.orange), // Spec requirement[cite: 11]
                          _buildStatCard('Eco Badge', itemsReused > 3 ? 'Eco Champion' : 'New Member', Icons.military_tech, Colors.purple),
                        ],
                      ),
                    ),

                    // Settings Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit_note, color: activeGreen),
                              title: const Text('Edit Profile Information'),
                              subtitle: const Text('Update your name and university'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () => _showEditProfileDialog(displayName, universityName),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.notifications_active, color: activeGreen),
                              title: const Text('Push Notifications'),
                              trailing: Switch(
                                value: _pushNotifications,
                                activeColor: activeGreen,
                                onChanged: (val) => setState(() => _pushNotifications = val),
                              ),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.email, color: activeGreen),
                              title: const Text('Email Alerts'),
                              trailing: Switch(
                                value: _emailAlerts,
                                activeColor: activeGreen,
                                onChanged: (val) => setState(() => _emailAlerts = val),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w500)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2D3142)),
          ),
        ],
      ),
    );
  }
}
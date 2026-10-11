import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/item_model.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // 1. Upload Photo to Firebase Storage
  Future<String?> uploadItemImage(File imageFile, String itemId) async {
    try {
      Reference ref = _storage.ref().child('item_images').child('$itemId.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  // 2. Add New Listing to Firestore ('items' collection)
  Future<void> addItem(ReuseItem item, File? imageFile) async {
    String docId = _db.collection('items').doc().id;

    await _db.collection('items').doc(docId).set({
      'id': docId,
      'title': item.title,
      'category': item.category,
      'condition': item.condition,

      'locationZone': item.locationZone,
      'estimatedValue': item.estimatedValue,
      'isClaimed': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
// 3. Get Realtime Stream of Items for Home Feed
  Stream<List<ReuseItem>> getItemsStream() {
    return _db
        .collection('items')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return ReuseItem(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          category: data['category'] ?? '',
          condition: data['condition'] ?? '',
          imagePath: data['imagePath'] ?? '',
          locationZone: data['locationZone'] ?? 'Main Campus',
          estimatedValue: (data['estimatedValue'] ?? 0.0).toDouble(),
          isClaimed: data['isClaimed'] ?? false,
          userId: data['userId'] ?? '',
          userName: data['userName'] ?? 'Campus Student',
        );
      }).toList();
    });
  }
}
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'firebase_options.dart';
import 'data/mock/mock_data.dart';
import 'app.dart';

Future<void> seedDatabase() async {
  final db = FirebaseFirestore.instance;

  // Seed Products
  final productsSnap = await db.collection('products').limit(1).get();
  if (productsSnap.docs.isEmpty) {
    final batch = db.batch();
    for (final p in MockData.products) {
      batch.set(db.collection('products').doc(p.id), p.toMap());
    }
    await batch.commit();
  }

  // Seed Reviews
  final reviewsSnap = await db.collection('reviews').limit(1).get();
  if (reviewsSnap.docs.isEmpty) {
    final batch = db.batch();
    for (final r in MockData.reviews) {
      batch.set(db.collection('reviews').doc(r.id), r.toMap());
    }
    await batch.commit();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('Error initializing Google Sign-In: $e');
    }
    // Seed the mock DB on Firestore asynchronously in the background so it doesn't block UI mounting
    seedDatabase().catchError((e) {
      debugPrint('Error seeding database: $e');
    });
  } catch (e) {
    debugPrint('Error initializing Firebase: $e');
  }

  runApp(
    const ProviderScope(
      child: ColorCraftApp(),
    ),
  );
}

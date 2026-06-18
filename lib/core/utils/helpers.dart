import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  static String formatCurrency(double amount) {
    if (amount <= 0) return 'N/A';
    final format = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    return format.format(amount);
  }

  static String formatDate(DateTime date) {
    final format = DateFormat('MMM dd, yyyy');
    return format.format(date);
  }

  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  static ImageProvider getAvatarImageProvider(String photoUrl, String fallbackSeed) {
    if (photoUrl.isEmpty) {
      return NetworkImage('https://i.pravatar.cc/150?u=${fallbackSeed.hashCode}');
    }
    if (photoUrl.startsWith('http') || photoUrl.startsWith('blob:') || photoUrl.startsWith('data:')) {
      return NetworkImage(photoUrl);
    }
    try {
      if (!kIsWeb) {
        return FileImage(File(photoUrl));
      }
    } catch (_) {
      // Fallback
    }
    return NetworkImage(photoUrl);
  }
}


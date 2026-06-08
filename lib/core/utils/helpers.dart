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
}

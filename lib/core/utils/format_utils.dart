import 'package:intl/intl.dart';

String formatMoney(double amount, {String currency = '₹'}) {
  if (amount == amount.truncateToDouble()) {
    return '$currency${amount.toInt()}';
  }
  return '$currency${amount.toStringAsFixed(2)}';
}

String formatMoneyExact(double amount, {String currency = '₹'}) {
  return '$currency${amount.toStringAsFixed(2)}';
}

// Backward-compatible aliases
String formatCurrency(double amount) => formatMoney(amount);
String formatCurrencyExact(double amount) => formatMoneyExact(amount);

String formatDate(DateTime? dt) {
  if (dt == null) return '—';
  return DateFormat('dd MMM yyyy').format(dt.toLocal());
}

String formatDateTime(DateTime? dt) {
  if (dt == null) return '—';
  return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
}

String formatDuration(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m}m ${s}s';
}

String timeAgo(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.inSeconds < 60) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return formatDate(dt);
}

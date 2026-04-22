import 'package:intl/intl.dart';

String formatPaise(int paise) {
  final rupees = paise / 100;
  if (paise % 100 == 0) {
    return '₹${rupees.toInt()}';
  }
  return '₹${rupees.toStringAsFixed(2)}';
}

String formatPaiseExact(int paise) {
  final rupees = paise / 100;
  return '₹${rupees.toStringAsFixed(2)}';
}

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

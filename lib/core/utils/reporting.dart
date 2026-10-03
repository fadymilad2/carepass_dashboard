import 'package:cloud_firestore/cloud_firestore.dart';

/// Reports use Ghana time (UTC), independent of the administrator's device.
DateTime? reportDate(dynamic value) {
  if (value is Timestamp) return value.toDate().toUtc();
  if (value is DateTime) return value.toUtc();
  if (value is! String || value.trim().isEmpty) return null;
  var raw = value.trim();
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw)) raw += 'T00:00:00';
  final zoned = RegExp(
    r'(Z|[+-]\d{2}:?\d{2})$',
    caseSensitive: false,
  ).hasMatch(raw);
  return DateTime.tryParse(zoned ? raw : '${raw}Z')?.toUtc();
}

String reportDateString(dynamic value) =>
    reportDate(value)?.toIso8601String() ?? '';
bool inReportRange(dynamic value, DateTime start, DateTime end) {
  final date = reportDate(value);
  return date != null && !date.isBefore(start) && date.isBefore(end);
}

DateTime reportDay(DateTime date) =>
    DateTime.utc(date.year, date.month, date.day);
bool isCurrentMember(Map<String, dynamic> data, DateTime now) =>
    data['subscriptionStatus'] == 'active' &&
    (reportDate(data['cardExpiryDate'])?.isAfter(now.toUtc()) ?? false);
String effectiveStatus(Map<String, dynamic> data, DateTime now) {
  final status = data['subscriptionStatus'] as String? ?? 'none';
  if (status != 'active') return status;
  final expiry = reportDate(data['cardExpiryDate']);
  if (expiry == null) return 'unknown';
  return expiry.isAfter(now.toUtc()) ? 'active' : 'expired';
}

bool isLiveRevenue(Map<String, dynamic> data) =>
    data['status'] == 'success' &&
    data['environment'] == 'live' &&
    data['currency'] == 'GHS';
double receiptAmount(Map<String, dynamic> data) {
  final amount = data['amount'];
  if (amount is! num || !amount.isFinite || amount < 0) {
    throw const FormatException('Receipt contains an invalid amount');
  }
  return amount.toDouble();
}

String resolvePlanLabel(String id, Map<String, String> plans) {
  if (id.isEmpty || id == '—') return 'No plan';
  if (plans.containsKey(id)) return plans[id]!;
  for (final name in plans.values) {
    if (name.toLowerCase() == id.toLowerCase()) return name;
  }
  return 'Unknown plan ($id)';
}

bool isActiveAdminRecord(Map<String, dynamic>? data) =>
    data?['isActive'] == true &&
    const [
      'super_admin',
      'admin',
      'support',
      'finance',
      'marketer',
      'custom',
    ].contains(data?['role']);

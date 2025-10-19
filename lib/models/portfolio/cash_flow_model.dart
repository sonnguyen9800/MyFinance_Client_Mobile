class CashFlowModel {
  const CashFlowModel({
    required this.id,
    required this.assetId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String assetId;
  final String type;
  final double amount;
  final String currency;
  final DateTime occurredAt;
  final String? notes;
  final DateTime? createdAt;

  factory CashFlowModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'];
    return CashFlowModel(
      id: idValue?.toString() ?? '',
      assetId: json['asset_id']?.toString() ?? '',
      type: json['type'] as String? ?? '',
      amount: _parseDouble(json['amount']) ?? 0,
      currency: json['currency'] as String? ?? '',
      occurredAt: _parseDate(json['occurred_at']) ?? DateTime.now(),
      notes: json['notes'] as String?,
      createdAt: _parseDate(json['created_at']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String && value.isNotEmpty) {
      return double.tryParse(value);
    }
    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

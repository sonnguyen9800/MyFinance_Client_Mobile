class PositionLotModel {
  const PositionLotModel({
    required this.id,
    required this.assetId,
    required this.quantity,
    required this.unitCost,
    required this.costCurrency,
    required this.acquiredAt,
    this.userId,
    this.fees,
    this.notes,
    this.fxPair,
    this.fxRateUsed,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String assetId;
  final double quantity;
  final double unitCost;
  final String costCurrency;
  final DateTime acquiredAt;
  final String? userId;
  final double? fees;
  final String? notes;
  final String? fxPair;
  final double? fxRateUsed;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory PositionLotModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'];
    return PositionLotModel(
      id: idValue?.toString() ?? '',
      assetId: json['asset_id']?.toString() ?? '',
      quantity: _parseDouble(json['quantity']) ?? 0,
      unitCost: _parseDouble(json['unit_cost']) ?? 0,
      costCurrency: json['cost_currency'] as String? ?? '',
      acquiredAt: _parseDate(json['acquired_at']) ?? DateTime.now(),
      userId: json['user_id'] as String?,
      fees: _parseDouble(json['fees']),
      notes: json['notes'] as String?,
      fxPair: json['fx_pair'] as String?,
      fxRateUsed: _parseDouble(json['fx_rate_used']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
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

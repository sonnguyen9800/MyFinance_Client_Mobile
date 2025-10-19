class ValuationSnapshotModel {
  const ValuationSnapshotModel({
    required this.id,
    required this.assetId,
    required this.capturedAt,
    required this.nativeCurrencyValue,
    required this.nativeCurrency,
    this.valuationCurrencyMap = const {},
    this.ratesUsed = const {},
    this.source,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String assetId;
  final DateTime capturedAt;
  final double nativeCurrencyValue;
  final String nativeCurrency;
  final Map<String, double> valuationCurrencyMap;
  final Map<String, double> ratesUsed;
  final String? source;
  final String? notes;
  final DateTime? createdAt;

  factory ValuationSnapshotModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'];
    return ValuationSnapshotModel(
      id: idValue?.toString() ?? '',
      assetId: json['asset_id']?.toString() ?? '',
      capturedAt: _parseDate(json['captured_at']) ?? DateTime.now(),
      nativeCurrencyValue: _parseDouble(json['native_currency_value']) ?? 0,
      nativeCurrency: json['native_currency'] as String? ?? '',
      valuationCurrencyMap:
          _parseDoubleMap(json['valuation_currency_map'] as Map?),
      ratesUsed: _parseDoubleMap(json['rates_used'] as Map?),
      source: json['source'] as String?,
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

  static Map<String, double> _parseDoubleMap(Map? source) {
    if (source == null) return const {};
    return source.map((key, value) {
      final parsed = _parseDouble(value) ?? 0;
      return MapEntry(key.toString(), parsed);
    });
  }
}

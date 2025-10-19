class AssetModel {
  const AssetModel({
    required this.id,
    required this.assetClassCode,
    required this.displayName,
    required this.defaultCurrency,
    required this.active,
    this.userId,
    this.metadata,
    this.tags = const [],
    this.expectedReturn,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String assetClassCode;
  final String displayName;
  final String defaultCurrency;
  final bool active;
  final String? userId;
  final Map<String, dynamic>? metadata;
  final List<String> tags;
  final double? expectedReturn;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AssetModel.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'];
    return AssetModel(
      id: idValue?.toString() ?? '',
      assetClassCode: json['asset_class_code'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      defaultCurrency: json['default_currency'] as String? ?? '',
      active: json['active'] as bool? ?? true,
      userId: json['user_id'] as String?,
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>(),
      tags: (json['tags'] as List?)
              ?.map((tag) => tag.toString())
              .toList(growable: false) ??
          const [],
      expectedReturn: _parseDouble(json['expected_return']),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

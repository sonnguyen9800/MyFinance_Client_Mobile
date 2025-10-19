class AssetClassModel {
  const AssetClassModel({
    required this.code,
    required this.name,
    this.defaultValuationMethod,
    this.metadataSchema,
    this.createdAt,
    this.updatedAt,
  });

  final String code;
  final String name;
  final String? defaultValuationMethod;
  final Map<String, dynamic>? metadataSchema;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory AssetClassModel.fromJson(Map<String, dynamic> json) {
    return AssetClassModel(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      defaultValuationMethod: json['default_valuation_method'] as String?,
      metadataSchema: (json['metadata_schema'] as Map?)?.cast<String, dynamic>(),
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

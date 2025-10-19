import 'asset_model.dart';

class PortfolioSummaryModel {
  const PortfolioSummaryModel({
    required this.baseCurrency,
    required this.totalCurrentValue,
    required this.totalCostBasis,
    required this.totalUnrealizedGain,
    required this.positions,
    required this.generatedAt,
  });

  final String baseCurrency;
  final double totalCurrentValue;
  final double totalCostBasis;
  final double totalUnrealizedGain;
  final List<PortfolioPositionModel> positions;
  final DateTime generatedAt;

  double get totalUnrealizedGainPercent {
    if (totalCostBasis == 0) {
      return 0;
    }
    return (totalUnrealizedGain / totalCostBasis) * 100;
  }

  factory PortfolioSummaryModel.fromJson(Map<String, dynamic> json) {
    return PortfolioSummaryModel(
      baseCurrency: json['base_currency'] as String? ?? '',
      totalCurrentValue: _parseDouble(json['total_current_value']) ?? 0,
      totalCostBasis: _parseDouble(json['total_cost_basis']) ?? 0,
      totalUnrealizedGain:
          _parseDouble(json['total_unrealized_gain']) ?? 0,
      positions: (json['positions'] as List?)
              ?.map(
                (item) => PortfolioPositionModel.fromJson(
                    item as Map<String, dynamic>),
              )
              .toList(growable: false) ??
          const [],
      generatedAt:
          _parseDate(json['generated_at']) ?? DateTime.now(),
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

class PortfolioPositionModel {
  const PortfolioPositionModel({
    required this.asset,
    required this.currentValue,
    required this.costBasis,
    required this.unrealizedGain,
    required this.unrealizedGainPercent,
    this.lastValuationAt,
  });

  final AssetModel asset;
  final double currentValue;
  final double costBasis;
  final double unrealizedGain;
  final double unrealizedGainPercent;
  final DateTime? lastValuationAt;

  factory PortfolioPositionModel.fromJson(Map<String, dynamic> json) {
    return PortfolioPositionModel(
      asset:
          AssetModel.fromJson(json['asset'] as Map<String, dynamic>? ?? {}),
      currentValue: PortfolioSummaryModel._parseDouble(
            json['current_value'],
          ) ??
          0,
      costBasis: PortfolioSummaryModel._parseDouble(json['cost_basis']) ?? 0,
      unrealizedGain:
          PortfolioSummaryModel._parseDouble(json['unrealized_gain']) ?? 0,
      unrealizedGainPercent: PortfolioSummaryModel._parseDouble(
            json['unrealized_gain_percent'],
          ) ??
          0,
      lastValuationAt: PortfolioSummaryModel._parseDate(
        json['last_valuation_at'],
      ),
    );
  }
}

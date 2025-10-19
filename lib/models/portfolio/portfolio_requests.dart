class AssetUpsertRequest {
  AssetUpsertRequest({
    required this.displayName,
    required this.assetClassCode,
    required this.defaultCurrency,
    this.metadata = const {},
    this.tags = const [],
    this.expectedReturn,
    this.active = true,
  });

  final String displayName;
  final String assetClassCode;
  final String defaultCurrency;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final double? expectedReturn;
  final bool active;

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'asset_class_code': assetClassCode,
      'default_currency': defaultCurrency,
      if (metadata.isNotEmpty) 'metadata': metadata,
      if (tags.isNotEmpty) 'tags': tags,
      if (expectedReturn != null) 'expected_return': expectedReturn,
      'active': active,
    };
  }
}

class PositionLotRequest {
  PositionLotRequest({
    required this.acquiredAt,
    required this.quantity,
    required this.unitCost,
    required this.costCurrency,
    this.fees,
    this.notes,
    this.fxPair,
    this.fxRateUsed,
  });

  final DateTime acquiredAt;
  final double quantity;
  final double unitCost;
  final String costCurrency;
  final double? fees;
  final String? notes;
  final String? fxPair;
  final double? fxRateUsed;

  Map<String, dynamic> toJson() {
    return {
      'acquired_at': acquiredAt.toIso8601String(),
      'quantity': quantity,
      'unit_cost': unitCost,
      'cost_currency': costCurrency,
      if (fees != null) 'fees': fees,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      if (fxPair != null && fxPair!.isNotEmpty) 'fx_pair': fxPair,
      if (fxRateUsed != null) 'fx_rate_used': fxRateUsed,
    };
  }
}

class CashFlowRequest {
  CashFlowRequest({
    required this.type,
    required this.amount,
    required this.currency,
    required this.occurredAt,
    this.notes,
  });

  final String type;
  final double amount;
  final String currency;
  final DateTime occurredAt;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
      'currency': currency,
      'occurred_at': occurredAt.toIso8601String(),
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

class ValuationSnapshotRequest {
  ValuationSnapshotRequest({
    required this.capturedAt,
    required this.nativeCurrencyValue,
    required this.nativeCurrency,
    this.valuationCurrencyMap = const {},
    this.ratesUsed = const {},
    this.source,
    this.notes,
  });

  final DateTime capturedAt;
  final double nativeCurrencyValue;
  final String nativeCurrency;
  final Map<String, double> valuationCurrencyMap;
  final Map<String, double> ratesUsed;
  final String? source;
  final String? notes;

  Map<String, dynamic> toJson() {
    return {
      'captured_at': capturedAt.toIso8601String(),
      'native_currency_value': nativeCurrencyValue,
      'native_currency': nativeCurrency,
      if (valuationCurrencyMap.isNotEmpty)
        'valuation_currency_map': valuationCurrencyMap,
      if (ratesUsed.isNotEmpty) 'rates_used': ratesUsed,
      if (source != null && source!.isNotEmpty) 'source': source,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

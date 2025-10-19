import 'dart:developer' as developer;

import '../models/portfolio/asset_class_model.dart';
import '../models/portfolio/asset_model.dart';
import '../models/portfolio/cash_flow_model.dart';
import '../models/portfolio/portfolio_requests.dart';
import '../models/portfolio/portfolio_summary_model.dart';
import '../models/portfolio/position_lot_model.dart';
import '../models/portfolio/valuation_snapshot_model.dart';
import 'base_api_service.dart';

class PortfolioApiService extends BaseApiService {
  PortfolioApiService({
    required super.baseUrl,
    required super.dio,
    required super.storage,
  });

  Future<List<AssetClassModel>> getAssetClasses() async {
    try {
      final response = await dio.get('$baseUrl/asset_classes');
      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              AssetClassModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      developer.log('getAssetClasses error: $e');
      throw Exception('Failed to load asset classes: $e');
    }
  }

  Future<List<AssetModel>> getAssets({bool includeInactive = false}) async {
    try {
      final response = await dio.get(
        '$baseUrl/assets',
        queryParameters: {
          if (includeInactive) 'include_inactive': includeInactive,
        },
      );
      final data = response.data as List<dynamic>;
      return data
          .map((item) => AssetModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      developer.log('getAssets error: $e');
      throw Exception('Failed to load assets: $e');
    }
  }

  Future<AssetModel> getAsset(String id) async {
    try {
      final response = await dio.get('$baseUrl/assets/$id');
      return AssetModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('getAsset error: $e');
      throw Exception('Failed to load asset: $e');
    }
  }

  Future<AssetModel> createAsset(AssetUpsertRequest request) async {
    try {
      final response = await dio.post(
        '$baseUrl/assets',
        data: request.toJson(),
      );
      return AssetModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('createAsset error: $e');
      throw Exception('Failed to create asset: $e');
    }
  }

  Future<AssetModel> updateAsset(String id, AssetUpsertRequest request) async {
    try {
      final response = await dio.patch(
        '$baseUrl/assets/$id',
        data: request.toJson(),
      );
      return AssetModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('updateAsset error: $e');
      throw Exception('Failed to update asset: $e');
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      await dio.delete('$baseUrl/assets/$id');
    } catch (e) {
      developer.log('deleteAsset error: $e');
      throw Exception('Failed to delete asset: $e');
    }
  }

  Future<List<PositionLotModel>> getPositionLots(String assetId) async {
    try {
      final response = await dio.get('$baseUrl/assets/$assetId/lots');
      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              PositionLotModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      developer.log('getPositionLots error: $e');
      throw Exception('Failed to load position lots: $e');
    }
  }

  Future<PositionLotModel> createPositionLot(
    String assetId,
    PositionLotRequest request,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/assets/$assetId/lots',
        data: request.toJson(),
      );
      return PositionLotModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('createPositionLot error: $e');
      throw Exception('Failed to create position lot: $e');
    }
  }

  Future<PositionLotModel> updatePositionLot(
    String assetId,
    String lotId,
    PositionLotRequest request,
  ) async {
    try {
      final response = await dio.patch(
        '$baseUrl/assets/$assetId/lots/$lotId',
        data: request.toJson(),
      );
      return PositionLotModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('updatePositionLot error: $e');
      throw Exception('Failed to update position lot: $e');
    }
  }

  Future<void> deletePositionLot(String assetId, String lotId) async {
    try {
      await dio.delete('$baseUrl/assets/$assetId/lots/$lotId');
    } catch (e) {
      developer.log('deletePositionLot error: $e');
      throw Exception('Failed to delete position lot: $e');
    }
  }

  Future<List<CashFlowModel>> getCashFlows(String assetId) async {
    try {
      final response = await dio.get('$baseUrl/assets/$assetId/cashflows');
      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              CashFlowModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      developer.log('getCashFlows error: $e');
      throw Exception('Failed to load cash flows: $e');
    }
  }

  Future<CashFlowModel> createCashFlow(
    String assetId,
    CashFlowRequest request,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/assets/$assetId/cashflows',
        data: request.toJson(),
      );
      return CashFlowModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      developer.log('createCashFlow error: $e');
      throw Exception('Failed to create cash flow: $e');
    }
  }

  Future<void> deleteCashFlow(String assetId, String cashFlowId) async {
    try {
      await dio.delete('$baseUrl/assets/$assetId/cashflows/$cashFlowId');
    } catch (e) {
      developer.log('deleteCashFlow error: $e');
      throw Exception('Failed to delete cash flow: $e');
    }
  }

  Future<List<ValuationSnapshotModel>> getValuations(
    String assetId, {
    int limit = 50,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/assets/$assetId/valuations',
        queryParameters: {'limit': limit},
      );
      final data = response.data as List<dynamic>;
      return data
          .map((item) =>
              ValuationSnapshotModel.fromJson(item as Map<String, dynamic>))
          .toList(growable: false);
    } catch (e) {
      developer.log('getValuations error: $e');
      throw Exception('Failed to load valuations: $e');
    }
  }

  Future<ValuationSnapshotModel> createValuation(
    String assetId,
    ValuationSnapshotRequest request,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/assets/$assetId/valuations',
        data: request.toJson(),
      );
      return ValuationSnapshotModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log('createValuation error: $e');
      throw Exception('Failed to create valuation: $e');
    }
  }

  Future<void> deleteValuation(String assetId, String valuationId) async {
    try {
      await dio.delete('$baseUrl/assets/$assetId/valuations/$valuationId');
    } catch (e) {
      developer.log('deleteValuation error: $e');
      throw Exception('Failed to delete valuation: $e');
    }
  }

  Future<PortfolioSummaryModel> getPortfolioSummary({
    String? baseCurrency,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/portfolio/summary',
        queryParameters: {
          if (baseCurrency != null && baseCurrency.isNotEmpty)
            'base': baseCurrency,
        },
      );
      return PortfolioSummaryModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } catch (e) {
      developer.log('getPortfolioSummary error: $e');
      throw Exception('Failed to load portfolio summary: $e');
    }
  }
}

import 'package:get/get.dart';

import '../models/portfolio/asset_class_model.dart';
import '../models/portfolio/asset_model.dart';
import '../models/portfolio/cash_flow_model.dart';
import '../models/portfolio/portfolio_requests.dart';
import '../models/portfolio/portfolio_summary_model.dart';
import '../models/portfolio/position_lot_model.dart';
import '../models/portfolio/valuation_snapshot_model.dart';
import '../services/api_service.dart';

class PortfolioController extends GetxController {
  PortfolioController(this._apiService);

  final ApiService _apiService;

  final RxBool isLoading = false.obs;
  final RxBool isDetailsLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxString baseCurrency = 'USD'.obs;
  final RxBool includeInactive = false.obs;

  final RxList<AssetClassModel> assetClasses = <AssetClassModel>[].obs;
  final RxList<AssetModel> assets = <AssetModel>[].obs;
  final Rxn<AssetModel> selectedAsset = Rxn<AssetModel>();
  final Rx<PortfolioSummaryModel?> summary = Rx<PortfolioSummaryModel?>(null);

  final RxList<PositionLotModel> positionLots = <PositionLotModel>[].obs;
  final RxList<CashFlowModel> cashFlows = <CashFlowModel>[].obs;
  final RxList<ValuationSnapshotModel> valuations =
      <ValuationSnapshotModel>[].obs;

  bool _isInitialized = false;

  Future<void> initialize({bool force = false}) async {
    if (isLoading.value) return;
    if (_isInitialized && !force) return;

    await loadPortfolio(force: force);
    _isInitialized = true;
  }

  Future<void> loadPortfolio({bool force = false}) async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = null;
    try {
      final results = await Future.wait([
        _apiService.getAssetClasses(),
        _apiService.getAssets(includeInactive: includeInactive.value),
        _apiService.getPortfolioSummary(baseCurrency: baseCurrency.value),
      ]);

      assetClasses.assignAll(results[0] as List<AssetClassModel>);
      assets.assignAll(results[1] as List<AssetModel>);
      summary.value = results[2] as PortfolioSummaryModel;

      if (assets.isNotEmpty) {
        AssetModel? selected;
        if (selectedAsset.value != null && !force) {
          final index = assets.indexWhere(
            (asset) => asset.id == selectedAsset.value!.id,
          );
          if (index != -1) {
            selected = assets[index];
          }
        }
        selected ??= assets.first;
        await selectAsset(selected, skipSummary: true);
      } else {
        selectedAsset.value = null;
        positionLots.clear();
        cashFlows.clear();
        valuations.clear();
      }
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar('Error', 'Failed to load portfolio: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshSummary() async {
    try {
      summary.value = await _apiService.getPortfolioSummary(
        baseCurrency: baseCurrency.value,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to refresh summary: $e');
    }
  }

  Future<void> changeBaseCurrency(String newBase) async {
    if (newBase.isEmpty || baseCurrency.value == newBase) return;
    baseCurrency.value = newBase.toUpperCase();
    await refreshSummary();
  }

  Future<void> toggleIncludeInactive(bool value) async {
    includeInactive.value = value;
    await loadPortfolio(force: true);
  }

  Future<void> selectAsset(
    AssetModel asset, {
    bool skipSummary = false,
  }) async {
    selectedAsset.value = asset;
    await loadAssetDetails(asset.id);
    if (!skipSummary) {
      await refreshSummary();
    }
  }

  Future<void> loadAssetDetails(String assetId) async {
    if (isDetailsLoading.value) return;

    isDetailsLoading.value = true;
    try {
      final results = await Future.wait([
        _apiService.getPositionLots(assetId),
        _apiService.getCashFlows(assetId),
        _apiService.getValuations(assetId),
      ]);

      positionLots.assignAll(results[0] as List<PositionLotModel>);
      cashFlows.assignAll(results[1] as List<CashFlowModel>);
      valuations.assignAll(results[2] as List<ValuationSnapshotModel>);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load asset details: $e');
    } finally {
      isDetailsLoading.value = false;
    }
  }

  Future<void> createAsset(AssetUpsertRequest request) async {
    try {
      final asset = await _apiService.createAsset(request);
      assets.insert(0, asset);
      await selectAsset(asset);
      Get.snackbar('Success', 'Asset created');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create asset: $e');
    }
  }

  Future<void> updateAsset(
    String id,
    AssetUpsertRequest request,
  ) async {
    try {
      final asset = await _apiService.updateAsset(id, request);
      final index = assets.indexWhere((item) => item.id == id);
      if (index != -1) {
        assets[index] = asset;
        assets.refresh();
      }
      if (selectedAsset.value?.id == id) {
        selectedAsset.value = asset;
      }
      await refreshSummary();
      Get.snackbar('Success', 'Asset updated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update asset: $e');
    }
  }

  Future<void> deleteAsset(String id) async {
    try {
      await _apiService.deleteAsset(id);
      final wasSelected = selectedAsset.value?.id == id;
      assets.removeWhere((asset) => asset.id == id);
      if (wasSelected) {
        selectedAsset.value = null;
        positionLots.clear();
        cashFlows.clear();
        valuations.clear();
        if (assets.isNotEmpty) {
          await selectAsset(assets.first);
        } else {
          await refreshSummary();
        }
      } else {
        await refreshSummary();
      }
      Get.snackbar('Success', 'Asset deleted');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete asset: $e');
    }
  }

  Future<void> createPositionLot(PositionLotRequest request) async {
    final asset = selectedAsset.value;
    if (asset == null) return;

    try {
      final lot = await _apiService.createPositionLot(asset.id, request);
      positionLots.insert(0, lot);
      await refreshSummary();
      Get.snackbar('Success', 'Position lot recorded');
    } catch (e) {
      Get.snackbar('Error', 'Failed to record position lot: $e');
    }
  }

  Future<void> deletePositionLot(String lotId) async {
    final asset = selectedAsset.value;
    if (asset == null) return;

    try {
      await _apiService.deletePositionLot(asset.id, lotId);
      positionLots.removeWhere((lot) => lot.id == lotId);
      await refreshSummary();
      Get.snackbar('Success', 'Position lot removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove position lot: $e');
    }
  }

  Future<void> createCashFlow(CashFlowRequest request) async {
    final asset = selectedAsset.value;
    if (asset == null) return;

    try {
      final cashFlow = await _apiService.createCashFlow(asset.id, request);
      cashFlows.insert(0, cashFlow);
      await refreshSummary();
      Get.snackbar('Success', 'Cash flow recorded');
    } catch (e) {
      Get.snackbar('Error', 'Failed to record cash flow: $e');
    }
  }

  Future<void> deleteCashFlow(String cashFlowId) async {
    final asset = selectedAsset.value;
    if (asset == null) return;

    try {
      await _apiService.deleteCashFlow(asset.id, cashFlowId);
      cashFlows.removeWhere((flow) => flow.id == cashFlowId);
      await refreshSummary();
      Get.snackbar('Success', 'Cash flow removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove cash flow: $e');
    }
  }

  Future<void> createValuation(ValuationSnapshotRequest request) async {
    final asset = selectedAsset.value;
    if (asset == null) return;

    try {
      final valuation = await _apiService.createValuation(asset.id, request);
      valuations.insert(0, valuation);
      await refreshSummary();
      Get.snackbar('Success', 'Valuation snapshot captured');
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture valuation: $e');
    }
  }

  Future<void> deleteValuation(String valuationId) async {
    final asset = selectedAsset.value;
    if (asset == null) return;

    try {
      await _apiService.deleteValuation(asset.id, valuationId);
      valuations.removeWhere((snapshot) => snapshot.id == valuationId);
      await refreshSummary();
      Get.snackbar('Success', 'Valuation removed');
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove valuation: $e');
    }
  }
}

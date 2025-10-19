import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/portfolio_controller.dart';
import '../../models/portfolio/asset_model.dart';
import '../../models/portfolio/portfolio_requests.dart';
import '../../models/portfolio/portfolio_summary_model.dart';

class PortfolioSection extends StatefulWidget {
  const PortfolioSection({super.key});

  @override
  State<PortfolioSection> createState() => _PortfolioSectionState();
}

class _PortfolioSectionState extends State<PortfolioSection> {
  final PortfolioController _controller = Get.find<PortfolioController>();
  final TextEditingController _baseCurrencyController =
      TextEditingController();

  final List<String> _quickBaseCurrencies = const [
    'USD',
    'VND',
    'EUR',
    'BTC',
    'GOLD:OUNCE',
  ];

  @override
  void initState() {
    super.initState();
    _controller.initialize();
    _baseCurrencyController.text = _controller.baseCurrency.value;
  }

  @override
  void dispose() {
    _baseCurrencyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (_controller.errorMessage.value != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_controller.errorMessage.value!),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _controller.loadPortfolio(force: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => _controller.loadPortfolio(force: true),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 1000;
            return ListView(
              padding: const EdgeInsets.all(16),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                _buildSummaryCard(context),
                const SizedBox(height: 16),
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildAssetsCard(context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildAssetDetailsCard(context)),
                    ],
                  )
                else ...[
                  _buildAssetsCard(context),
                  const SizedBox(height: 16),
                  _buildAssetDetailsCard(context),
                ],
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildSummaryCard(BuildContext context) {
    final summary = _controller.summary.value;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Portfolio Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh summary',
                  icon: const Icon(Icons.refresh),
                  onPressed: _controller.refreshSummary,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _baseCurrencyController,
                    decoration: const InputDecoration(
                      labelText: 'Base currency',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) =>
                        _controller.changeBaseCurrency(value),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _controller
                      .changeBaseCurrency(_baseCurrencyController.text),
                  child: const Text('Apply'),
                ),
                for (final quick in _quickBaseCurrencies)
                  ChoiceChip(
                    label: Text(quick),
                    selected:
                        _controller.baseCurrency.value.toUpperCase() == quick,
                    onSelected: (_) {
                      _baseCurrencyController.text = quick;
                      _controller.changeBaseCurrency(quick);
                    },
                  ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Include inactive'),
                    Switch(
                      value: _controller.includeInactive.value,
                      onChanged: (value) =>
                          _controller.toggleIncludeInactive(value),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (summary == null)
              const Text('No summary data available')
            else
              _buildSummaryMetrics(context, summary),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryMetrics(
    BuildContext context,
    PortfolioSummaryModel summary,
  ) {
    final formatter = _buildCurrencyFormatter(summary.baseCurrency);
    final gainColor =
        summary.totalUnrealizedGain >= 0 ? Colors.green : Colors.red;

    return Wrap(
      spacing: 24,
      runSpacing: 16,
      children: [
        _SummaryMetric(
          label: 'Current Value',
          value:
              '${summary.baseCurrency} ${formatter.format(summary.totalCurrentValue)}',
        ),
        _SummaryMetric(
          label: 'Cost Basis',
          value:
              '${summary.baseCurrency} ${formatter.format(summary.totalCostBasis)}',
        ),
        _SummaryMetric(
          label: 'Unrealized Gain',
          value:
              '${summary.baseCurrency} ${formatter.format(summary.totalUnrealizedGain)}',
          valueStyle:
              Theme.of(context).textTheme.titleLarge?.copyWith(color: gainColor),
        ),
        _SummaryMetric(
          label: 'Gain %',
          value: summary.totalUnrealizedGainPercent.toStringAsFixed(2),
          valueSuffix: '%',
          valueStyle:
              Theme.of(context).textTheme.titleLarge?.copyWith(color: gainColor),
        ),
        _SummaryMetric(
          label: 'Positions',
          value: summary.positions.length.toString(),
        ),
        _SummaryMetric(
          label: 'Generated',
          value: DateFormat('yyyy-MM-dd HH:mm').format(summary.generatedAt),
        ),
      ],
    );
  }

  Widget _buildAssetsCard(BuildContext context) {
    final assets = _controller.assets;
    final summary = _controller.summary.value;
    final Map<String, PortfolioPositionModel> positionByAssetId = {
      if (summary != null)
        for (final position in summary.positions)
          position.asset.id: position,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Assets',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAssetDialog(context),
                  icon: const Icon(Icons.add),
                  label: const Text('New Asset'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (assets.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No assets yet. Create one to start.')),
              )
            else
              ListView.builder(
                itemCount: assets.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final asset = assets[index];
                  final position = positionByAssetId[asset.id];
                  return _buildAssetTile(context, asset, position);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetTile(
    BuildContext context,
    AssetModel asset,
    PortfolioPositionModel? position,
  ) {
    final selected = _controller.selectedAsset.value?.id == asset.id;
    final summary = _controller.summary.value;
    final formatter = _buildCurrencyFormatter(summary?.baseCurrency);

    final valueText = position != null
        ? '${summary?.baseCurrency ?? ''} ${formatter.format(position.currentValue)}'
        : '--';
    final gainText = position != null
        ? '${formatter.format(position.unrealizedGain)} (${position.unrealizedGainPercent.toStringAsFixed(2)}%)'
        : '--';

    return Card(
      color: selected
          ? Theme.of(context)
              .colorScheme
              .primary
              .withValues(alpha: 0.12)
          : null,
      child: ListTile(
        title: Text(asset.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${asset.assetClassCode} • ${asset.defaultCurrency}'),
            if (position != null)
              Text('Value: $valueText • Gain: $gainText'),
            if (!asset.active)
              const Text(
                'Inactive',
                style: TextStyle(color: Colors.orange),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showAssetDialog(context, existing: asset);
            } else if (value == 'delete') {
              _confirmDeleteAsset(asset);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete'),
              ),
            ),
          ],
        ),
        onTap: () => _controller.selectAsset(asset),
      ),
    );
  }

  Widget _buildAssetDetailsCard(BuildContext context) {
    final asset = _controller.selectedAsset.value;

    if (asset == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Asset Details',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('Select an asset to view details.'),
            ],
          ),
        ),
      );
    }

    final metadata = asset.metadata ?? {};

    return Obx(() {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    asset.displayName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  if (_controller.isDetailsLoading.value)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    avatar: const Icon(Icons.category, size: 18),
                    label: Text(asset.assetClassCode),
                  ),
                  Chip(
                    avatar: const Icon(Icons.currency_exchange, size: 18),
                    label: Text('Default currency: ${asset.defaultCurrency}'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.flag, size: 18),
                    label: Text(asset.active ? 'Active' : 'Inactive'),
                    backgroundColor: asset.active
                        ? Colors.green.withValues(alpha: 0.15)
                        : Colors.red.withValues(alpha: 0.15),
                  ),
                  if (asset.expectedReturn != null)
                    Chip(
                      avatar: const Icon(Icons.trending_up, size: 18),
                      label: Text(
                          'Expected return: ${(asset.expectedReturn! * 100).toStringAsFixed(2)}%'),
                    ),
                ],
              ),
              if (asset.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final tag in asset.tags)
                      Chip(
                        label: Text(tag),
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                      ),
                  ],
                ),
              ],
              if (metadata.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Metadata',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...metadata.entries.map(
                  (entry) => Text('${entry.key}: ${entry.value}'),
                ),
              ],
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Position Lots'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add position lot',
                  onPressed: () => _showPositionLotDialog(context),
                ),
                children: _buildPositionLots(context),
              ),
              ExpansionTile(
                title: const Text('Cash Flows'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Record cash flow',
                  onPressed: () => _showCashFlowDialog(context),
                ),
                children: _buildCashFlows(context),
              ),
              ExpansionTile(
                title: const Text('Valuations'),
                trailing: IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Add valuation snapshot',
                  onPressed: () => _showValuationDialog(context),
                ),
                children: _buildValuations(context),
              ),
            ],
          ),
        ),
      );
    });
  }

  List<Widget> _buildPositionLots(BuildContext context) {
    final lots = _controller.positionLots;
    if (lots.isEmpty) {
      return const [
        ListTile(
          title: Text('No lots recorded yet'),
        ),
      ];
    }

    return lots.map((lot) {
      return ListTile(
        title: Text(
            '${lot.quantity.toStringAsFixed(4)} @ ${lot.unitCost.toStringAsFixed(2)} ${lot.costCurrency}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Acquired: ${DateFormat('yyyy-MM-dd').format(lot.acquiredAt)}'),
            if (lot.fees != null)
              Text('Fees: ${lot.fees} ${lot.costCurrency}'),
            if (lot.fxPair != null && lot.fxRateUsed != null)
              Text('FX: ${lot.fxPair} @ ${lot.fxRateUsed}'),
            if (lot.notes != null && lot.notes!.isNotEmpty)
              Text(lot.notes!),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _controller.deletePositionLot(lot.id),
          tooltip: 'Remove lot',
        ),
      );
    }).toList();
  }

  List<Widget> _buildCashFlows(BuildContext context) {
    final flows = _controller.cashFlows;
    if (flows.isEmpty) {
      return const [
        ListTile(
          title: Text('No cash flows recorded'),
        ),
      ];
    }

    return flows.map((flow) {
      return ListTile(
        title: Text(
            '${flow.type} ${flow.amount.toStringAsFixed(2)} ${flow.currency}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Occurred: ${DateFormat('yyyy-MM-dd HH:mm').format(flow.occurredAt)}'),
            if (flow.notes != null && flow.notes!.isNotEmpty)
              Text(flow.notes!),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _controller.deleteCashFlow(flow.id),
          tooltip: 'Delete cash flow',
        ),
      );
    }).toList();
  }

  List<Widget> _buildValuations(BuildContext context) {
    final valuations = _controller.valuations;
    if (valuations.isEmpty) {
      return const [
        ListTile(
          title: Text('No valuations captured'),
        ),
      ];
    }

    return valuations.map((valuation) {
      final entries = valuation.valuationCurrencyMap.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));

      return ListTile(
        title: Text(
            'Captured ${DateFormat('yyyy-MM-dd HH:mm').format(valuation.capturedAt)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                'Native: ${valuation.nativeCurrencyValue.toStringAsFixed(2)} ${valuation.nativeCurrency}'),
            if (entries.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final entry in entries)
                    Chip(
                      label: Text(
                          '${entry.key}: ${entry.value.toStringAsFixed(2)}'),
                    ),
                ],
              ),
            if (valuation.notes != null && valuation.notes!.isNotEmpty)
              Text(valuation.notes!),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => _controller.deleteValuation(valuation.id),
          tooltip: 'Delete valuation',
        ),
      );
    }).toList();
  }

  NumberFormat _buildCurrencyFormatter(String? currency) {
    if (currency == null || currency.isEmpty || currency.contains(':')) {
      return NumberFormat('#,##0.00');
    }
    try {
      return NumberFormat.simpleCurrency(name: currency);
    } catch (_) {
      return NumberFormat('#,##0.00');
    }
  }

  Future<void> _showAssetDialog(
    BuildContext context, {
    AssetModel? existing,
  }) async {
    final formKey = GlobalKey<FormState>();
    final displayNameController =
        TextEditingController(text: existing?.displayName ?? '');
    String? assetClassCode = existing?.assetClassCode;
    final currencyController =
        TextEditingController(text: existing?.defaultCurrency ?? 'USD');
    final expectedReturnController = TextEditingController(
      text: existing?.expectedReturn?.toString() ?? '',
    );
    final tagsController = TextEditingController(
      text: existing?.tags.join(', ') ?? '',
    );
    final metadataController = TextEditingController(
      text: existing?.metadata == null || existing!.metadata!.isEmpty
          ? ''
          : const JsonEncoder.withIndent('  ').convert(existing.metadata),
    );
    bool active = existing?.active ?? true;

    if (assetClassCode == null && _controller.assetClasses.isNotEmpty) {
      assetClassCode = _controller.assetClasses.first.code;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(existing == null ? 'Create Asset' : 'Edit Asset'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter a name'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: assetClassCode,
                    decoration: const InputDecoration(
                      labelText: 'Asset class',
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.assetClasses
                        .map(
                          (cls) => DropdownMenuItem<String>(
                            value: cls.code,
                            child: Text('${cls.name} (${cls.code})'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => assetClassCode = value,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Default currency',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter currency'
                            : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: expectedReturnController,
                    decoration: const InputDecoration(
                      labelText: 'Expected annual return (0.05 = 5%)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: metadataController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Metadata (JSON)',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return SwitchListTile(
                        title: const Text('Active'),
                        value: active,
                        onChanged: (value) {
                          setStateDialog(() {
                            active = value;
                          });
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: Text(existing == null ? 'Create' : 'Update'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      displayNameController.dispose();
      currencyController.dispose();
      expectedReturnController.dispose();
      tagsController.dispose();
      metadataController.dispose();
      return;
    }

    Map<String, dynamic> metadata = {};
    final metadataText = metadataController.text.trim();
    if (metadataText.isNotEmpty) {
      try {
        final decoded = jsonDecode(metadataText);
        if (decoded is Map<String, dynamic>) {
          metadata = decoded;
        } else {
          Get.snackbar('Warning', 'Metadata must be a JSON object');
        }
      } catch (e) {
        Get.snackbar('Warning', 'Failed to parse metadata JSON: $e');
      }
    }

    final expectedReturn =
        double.tryParse(expectedReturnController.text.trim());

    final tags = tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    final request = AssetUpsertRequest(
      displayName: displayNameController.text.trim(),
      assetClassCode: assetClassCode ?? '',
      defaultCurrency: currencyController.text.trim().toUpperCase(),
      metadata: metadata,
      tags: tags,
      expectedReturn: expectedReturn,
      active: active,
    );

    if (existing == null) {
      await _controller.createAsset(request);
    } else {
      await _controller.updateAsset(existing.id, request);
    }

    displayNameController.dispose();
    currencyController.dispose();
    expectedReturnController.dispose();
    tagsController.dispose();
    metadataController.dispose();
  }

  Future<void> _showPositionLotDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final quantityController = TextEditingController();
    final unitCostController = TextEditingController();
    final currencyController = TextEditingController(text: 'USD');
    final feesController = TextEditingController();
    final notesController = TextEditingController();
    final fxRateController = TextEditingController();
    final fxPairController = TextEditingController(text: 'USD/VND');
    DateTime selectedDate = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Position Lot'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _validateNumber(value, positive: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: unitCostController,
                    decoration: const InputDecoration(
                      labelText: 'Unit cost',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _validateNumber(value, positive: true),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: currencyController,
                          decoration: const InputDecoration(
                            labelText: 'Cost currency',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null ||
                                  value.trim().isEmpty
                              ? 'Enter currency'
                              : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        if (!mounted) return;
                        setState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                                  date.day,
                                  selectedDate.hour,
                                  selectedDate.minute,
                                );
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_today),
                          label: Text(
                            DateFormat('yyyy-MM-dd').format(selectedDate),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: feesController,
                    decoration: const InputDecoration(
                      labelText: 'Fees (optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fxPairController,
                    decoration: const InputDecoration(
                      labelText: 'FX pair (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: fxRateController,
                    decoration: const InputDecoration(
                      labelText: 'FX rate used (optional)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final request = PositionLotRequest(
        acquiredAt: selectedDate,
        quantity: double.parse(quantityController.text),
        unitCost: double.parse(unitCostController.text),
        costCurrency: currencyController.text.trim().toUpperCase(),
        fees: double.tryParse(feesController.text),
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
        fxPair: fxPairController.text.trim().isEmpty
            ? null
            : fxPairController.text.trim(),
        fxRateUsed: double.tryParse(fxRateController.text),
      );
      await _controller.createPositionLot(request);
    }

    quantityController.dispose();
    unitCostController.dispose();
    currencyController.dispose();
    feesController.dispose();
    notesController.dispose();
    fxRateController.dispose();
    fxPairController.dispose();
  }

  Future<void> _showCashFlowDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final amountController = TextEditingController();
    final currencyController = TextEditingController(text: 'USD');
    final notesController = TextEditingController();
    String type = 'DEPOSIT';
    DateTime occurredAt = DateTime.now();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Record Cash Flow'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    decoration: const InputDecoration(
                      labelText: 'Type',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'DEPOSIT',
                        child: Text('Deposit'),
                      ),
                      DropdownMenuItem(
                        value: 'WITHDRAWAL',
                        child: Text('Withdrawal'),
                      ),
                      DropdownMenuItem(
                        value: 'DIVIDEND',
                        child: Text('Dividend'),
                      ),
                      DropdownMenuItem(
                        value: 'INTEREST',
                        child: Text('Interest'),
                      ),
                    ],
                    onChanged: (value) => type = value ?? type,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _validateNumber(value, positive: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null ||
                            value.trim().isEmpty
                        ? 'Enter currency'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: occurredAt,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (!context.mounted) return;
                      if (date != null) {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.fromDateTime(occurredAt),
                        );
                        if (!context.mounted) return;
                        if (!mounted) return;
                        setState(() {
                          occurredAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time?.hour ?? occurredAt.hour,
                            time?.minute ?? occurredAt.minute,
                          );
                        });
                      }
                    },
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(occurredAt),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final request = CashFlowRequest(
        type: type,
        amount: double.parse(amountController.text),
        currency: currencyController.text.trim().toUpperCase(),
        occurredAt: occurredAt,
        notes:
            notesController.text.trim().isEmpty ? null : notesController.text.trim(),
      );
      await _controller.createCashFlow(request);
    }

    amountController.dispose();
    currencyController.dispose();
    notesController.dispose();
  }

  Future<void> _confirmDeleteAsset(AssetModel asset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Asset'),
          content: Text(
              'Delete "${asset.displayName}"? All related lots, cash flows, and valuations will be removed.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _controller.deleteAsset(asset.id);
    }
  }

  String? _validateNumber(String? value, {bool positive = false}) {
    if (value == null || value.trim().isEmpty) {
      return 'Enter a value';
    }
    final parsed = double.tryParse(value.trim());
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (positive && parsed <= 0) {
      return 'Value must be positive';
    }
    return null;
  }

  Future<void> _showValuationDialog(BuildContext context) async {
    final formKey = GlobalKey<FormState>();
    final nativeValueController = TextEditingController();
    final nativeCurrencyController =
        TextEditingController(text: _controller.selectedAsset.value?.defaultCurrency ?? 'USD');
    final valuationMapController = TextEditingController();
    final ratesController = TextEditingController();
    final notesController = TextEditingController();
    DateTime capturedAt = DateTime.now();

    Map<String, double> parseDoubleMap(String text) {
      if (text.trim().isEmpty) return {};
      try {
        final decoded = jsonDecode(text);
        if (decoded is Map) {
          return decoded.map((key, value) {
            final parsed = value is num ? value.toDouble() : double.tryParse(value.toString()) ?? 0;
            return MapEntry(key.toString().toUpperCase(), parsed);
          });
        }
        Get.snackbar('Warning', 'Please provide a JSON object for valuations and rates');
      } catch (e) {
        Get.snackbar('Warning', 'Failed to parse JSON map: $e');
      }
      return {};
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Capture Valuation'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nativeValueController,
                    decoration: const InputDecoration(
                      labelText: 'Native currency value',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) => _validateNumber(value, positive: true),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nativeCurrencyController,
                    decoration: const InputDecoration(
                      labelText: 'Native currency',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter currency'
                            : null,
                  ),
                  const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: capturedAt,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (!context.mounted) return;
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(capturedAt),
                      );
                      if (!context.mounted) return;
                      if (!mounted) return;
                      setState(() {
                        capturedAt = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          time?.hour ?? capturedAt.hour,
                          time?.minute ?? capturedAt.minute,
                        );
                      });
                    }
                  },
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      DateFormat('yyyy-MM-dd HH:mm').format(capturedAt),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: valuationMapController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Valuation currency map (JSON)',
                      border: OutlineInputBorder(),
                      hintText: '{"USD": 10215.40, "VND": 250000000}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ratesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Rates used (JSON)',
                      border: OutlineInputBorder(),
                      hintText: '{"USD/VND": 24470.0}',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                Navigator.of(context).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final valuationMap = parseDoubleMap(valuationMapController.text);
      final ratesMap = parseDoubleMap(ratesController.text);
      final request = ValuationSnapshotRequest(
        capturedAt: capturedAt,
        nativeCurrencyValue: double.parse(nativeValueController.text),
        nativeCurrency: nativeCurrencyController.text.trim().toUpperCase(),
        valuationCurrencyMap: valuationMap,
        ratesUsed: ratesMap,
        notes: notesController.text.trim().isEmpty
            ? null
            : notesController.text.trim(),
      );
      await _controller.createValuation(request);
    }

    nativeValueController.dispose();
    nativeCurrencyController.dispose();
    valuationMapController.dispose();
    ratesController.dispose();
    notesController.dispose();
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.label,
    required this.value,
    this.valueSuffix,
    this.valueStyle,
  });

  final String label;
  final String value;
  final String? valueSuffix;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: valueStyle ?? Theme.of(context).textTheme.titleLarge,
              ),
              if (valueSuffix != null) ...[
                const SizedBox(width: 2),
                Text(
                  valueSuffix!,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

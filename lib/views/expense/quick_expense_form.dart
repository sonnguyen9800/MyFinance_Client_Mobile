import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/category_controller.dart';
import '../../controllers/expense_controller.dart';
import '../../models/expense/expense_model.dart';

class QuickExpenseForm extends StatefulWidget {
  const QuickExpenseForm({super.key, this.onCreated});

  final VoidCallback? onCreated;

  @override
  State<QuickExpenseForm> createState() => _QuickExpenseFormState();
}

class _QuickExpenseFormState extends State<QuickExpenseForm> {
  final _expenseController = Get.find<ExpenseController>();
  final _categoryController = Get.find<CategoryController>();

  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (_categoryController.categories.isEmpty) {
      _categoryController.loadCategories();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _scheduleCategorySelection(List categories) {
    if (_selectedCategoryId != null || categories.isEmpty) return;

    String? resolvedId;
    try {
      resolvedId = _categoryController.defaultCategory.id;
    } catch (_) {
      resolvedId = categories.first.id;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _selectedCategoryId = resolvedId);
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('Error', 'Please enter a valid amount');
      return;
    }

    if (_categoryController.categories.isEmpty) {
      Get.snackbar('Error', 'Please create a category first');
      return;
    }

    setState(() => _isSubmitting = true);

    final expense = Expense(
      name: _nameController.text.trim(),
      amount: amount,
      date: _selectedDate,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      categoryId: _selectedCategoryId,
    );

    try {
      await _expenseController.addExpense(expense);
      if (!mounted) {
        widget.onCreated?.call();
        return;
      }

      setState(() {
        _nameController.clear();
        _amountController.clear();
        _descriptionController.clear();
        _selectedDate = DateTime.now();
        _isSubmitting = false;
      });

      widget.onCreated?.call();
      Get.snackbar('Success', 'Expense created');
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
      Get.snackbar('Error', 'Failed to create expense: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final categories = _categoryController.categories;
      _scheduleCategorySelection(categories);
      final dateLabel = DateFormat('yyyy-MM-dd').format(_selectedDate);

      if (categories.isEmpty) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Quick Add Expense',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Create a category first to add expenses from here.'),
              ],
            ),
          ),
        );
      }

      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Add Expense',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value == null || int.tryParse(value.trim()) == null
                          ? 'Enter a valid amount'
                          : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _pickDate,
                        icon: const Icon(Icons.calendar_today),
                        label: Text(dateLabel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: categories
                            .map(
                              (category) => DropdownMenuItem<String>(
                                value: category.id,
                                child: Text(category.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          setState(() => _selectedCategoryId = value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Add Expense'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

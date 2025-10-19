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

  Future<void> _pickDateTime() async {
    DateTime tempDate = _selectedDate;
    int tempHour = _selectedDate.hour;
    int tempMinute = _selectedDate.minute;

    final selected = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Select date & time'),
              content: SizedBox(
                width: 360,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CalendarDatePicker(
                      initialDate: tempDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      onDateChanged: (value) {
                        setDialogState(() {
                          tempDate = DateTime(
                            value.year,
                            value.month,
                            value.day,
                            tempHour,
                            tempMinute,
                          );
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: tempHour,
                            decoration: const InputDecoration(
                              labelText: 'Hour',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(
                                24,
                                (index) => DropdownMenuItem(
                                      value: index,
                                      child: Text(
                                          index.toString().padLeft(2, '0')),
                                    )),
                            onChanged: (value) {
                              if (value == null) return;
                              setDialogState(() {
                                tempHour = value;
                                tempDate = DateTime(
                                  tempDate.year,
                                  tempDate.month,
                                  tempDate.day,
                                  tempHour,
                                  tempMinute,
                                );
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            initialValue: tempMinute - tempMinute % 5,
                            decoration: const InputDecoration(
                              labelText: 'Minute',
                              border: OutlineInputBorder(),
                            ),
                            items: List.generate(12, (index) => index * 5)
                                .map((minute) => DropdownMenuItem(
                                      value: minute,
                                      child: Text(
                                          minute.toString().padLeft(2, '0')),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value == null) return;
                              setDialogState(() {
                                tempMinute = value;
                                tempDate = DateTime(
                                  tempDate.year,
                                  tempDate.month,
                                  tempDate.day,
                                  tempHour,
                                  tempMinute,
                                );
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(dialogContext).pop(tempDate),
                  child: const Text('Done'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      setState(() => _selectedDate = selected);
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
      final dateLabel = DateFormat('yyyy-MM-dd – HH:mm').format(_selectedDate);

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
                Row(children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Enter a name'
                              : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
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
                  ),
                ]),
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
                      child: InputDatePickerFormField(
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      fieldLabelText: 'Date',
                      onDateSubmitted: (value) {
                        _selectedDate = value;
                      })
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

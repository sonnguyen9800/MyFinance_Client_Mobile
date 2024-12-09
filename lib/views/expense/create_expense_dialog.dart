import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myfinance_client_flutter/config/theme/app_typography.dart';
import 'package:myfinance_client_flutter/views/categories/category_card.dart';
import '../../controllers/expense_controller.dart';
import '../../controllers/category_controller.dart';
import '../../models/expense/expense_model.dart';
import '../../models/category/category_model.dart';
import 'package:intl/intl.dart';

class UpdateExpenseDialog extends StatefulWidget {
  final Expense? expense;
  final ExpenseController expenseController;

  const UpdateExpenseDialog({
    Key? key,
    this.expense,
    required this.expenseController,
  }) : super(key: key);

  @override
  State<UpdateExpenseDialog> createState() => _UpdateExpenseDialogState();
}

class _UpdateExpenseDialogState extends State<UpdateExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = Get.find<CategoryController>();
  DateTime _selectedDate = DateTime.now();
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    if (widget.expense != null) {
      _nameController.text = widget.expense!.name;
      _amountController.text = widget.expense!.amount.toString();
      _descriptionController.text = widget.expense!.description ?? "";
      _selectedDate = widget.expense!.date;
      _selectedCategoryId = widget.expense!.categoryId;
    }
    if (_selectedCategoryId == null || _selectedCategoryId!.isEmpty) {
      _selectedCategoryId = _categoryController.defaultCategory.id;
    }
    // Ensure categories are loaded
    _categoryController.loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final lengthCategory = _categoryController.categories.length;
    print("All category IDs:");
    for (var category in _categoryController.categories) {
      print(category.id);
    }

    return AlertDialog(
      title: Text(widget.expense == null ? 'Create Expense' : 'Edit Expense'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              lengthCategory > 1
                  ? Obx(() => DropdownButtonFormField<String>(
                        hint: const Text('Select a category'),
                        decoration: InputDecoration(
                          labelText: _categoryController
                                      .findCategoryById(_selectedCategoryId!) !=
                                  null
                              ? "Category: ${_categoryController.findCategoryById(_selectedCategoryId!)!.name}"
                              : 'Select a category',
                          border: OutlineInputBorder(),
                        ),
                        items: _categoryController.categories
                            .map((Category category) {
                          return DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedCategoryId = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a category';
                          }
                          return null;
                        },
                      ))
                  : const SizedBox(height: 0),
              const SizedBox(height: 16),
              Obx(() {
                Category? category =
                    _categoryController.findCategoryById(_selectedCategoryId!);
                return category == null
                    ? const SizedBox(height: 0)
                    : CategoryCard(
                        category: category,
                        categoryController: _categoryController,
                        isAllowControl: false,
                      );
              }),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                readOnly: true,
                controller: TextEditingController(
                  text: DateFormat('yyyy-MM-dd').format(_selectedDate),
                ),
                onTap: () => _selectDate(context),
                decoration: const InputDecoration(
                  labelText: 'Date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        if (widget.expense != null)
          TextButton(
            onPressed: () {
              Get.back();
              widget.expenseController.deleteExpense(widget.expense!.id!);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final expense = Expense(
                id: widget.expense?.id,
                name: _nameController.text,
                amount: int.parse(_amountController.text),
                date: _selectedDate,
                description: _descriptionController.text,
                categoryId: _selectedCategoryId !=
                        _categoryController.defaultCategory.id
                    ? _selectedCategoryId
                    : null,
              );
              if (widget.expense == null) {
                widget.expenseController.addExpense(expense);
              } else {
                widget.expenseController.updateExpense(expense);
              }
              Get.back();
            }
          },
          child: Text(widget.expense == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }
}

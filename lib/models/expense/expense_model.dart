import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class Expense {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  @JsonKey(name: 'payment_method')
  final String? paymentMethod;
  @JsonKey(name: 'currency_code')
  final String currencyCode;
  @JsonKey(name: 'category_id')
  final String? categoryId;

  final String name;
  final DateTime date;
  final double amount;
  final String? description;

  Expense({
    this.id,
    this.userId,
    this.description,
    this.paymentMethod = "No Payment Method",
    this.currencyCode = 'VND',
    this.categoryId = "No Category",
    required this.amount,
    required this.name,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    try {
      return _$ExpenseFromJson(json);
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

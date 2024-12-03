import 'package:json_annotation/json_annotation.dart';

part 'expense_model.g.dart';

@JsonSerializable()
class Expense {
  final String? id;
  @JsonKey(name: 'user_id')
  final String? userId;
  final String name;
  final String? description;
  final DateTime date;
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  final double amount;
  @JsonKey(name: 'currency_code')
  final String currencyCode;
  final String category;

  Expense({
    this.id,
    this.userId,
    required this.name,
    this.description,
    required this.date,
    required this.paymentMethod,
    required this.amount,
    this.currencyCode = 'VND',
    required this.category,
  });

  factory Expense.fromJson(Map<String, dynamic> json) => _$ExpenseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

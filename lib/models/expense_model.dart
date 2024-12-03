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

  final String name;
  final DateTime date;
  final double amount;

  final String? category;
  final String? description;

  Expense({
    this.id,
    this.userId,
    this.description,

    this.paymentMethod = "No Payment Method",
    this.currencyCode = 'VND',
    this.category = "No Category",

    required this.amount,
    required this.name,
    required this.date,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    try {
      print('Parsing Expense from JSON: $json');
      
      // Log each field separately
      print('id: ${json['id']}');
      print('user_id: ${json['user_id']}');
      print('name: ${json['name']}');
      print('description: ${json['description']}');
      print('date: ${json['date']}');
      print('payment_method: ${json['payment_method']}');
      print('amount: ${json['amount']}');
      print('currency_code: ${json['currency_code']}');
      print('category: ${json['category']}');
      
      return _$ExpenseFromJson(json);
    } catch (e, stackTrace) {
      print('Error parsing Expense from JSON:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => _$ExpenseToJson(this);
}

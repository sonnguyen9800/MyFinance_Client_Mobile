// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Expense _$ExpenseFromJson(Map<String, dynamic> json) => Expense(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      description: json['description'] as String?,
      paymentMethod: json['payment_method'] as String? ?? "No Payment Method",
      currencyCode: json['currency_code'] as String? ?? 'VND',
      category: json['category'] as String? ?? "No Category",
      amount: (json['amount'] as num).toDouble(),
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
    );

Map<String, dynamic> _$ExpenseToJson(Expense instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'payment_method': instance.paymentMethod,
      'currency_code': instance.currencyCode,
      'name': instance.name,
      'date': instance.date.toIso8601String(),
      'amount': instance.amount,
      'category': instance.category,
      'description': instance.description,
    };
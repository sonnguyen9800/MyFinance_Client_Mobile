// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_api_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ExpensesResponse _$ExpensesResponseFromJson(Map<String, dynamic> json) =>
    ExpensesResponse(
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['current_page'] as num).toInt(),
      totalPages: (json['total_pages'] as num).toInt(),
      totalCount: (json['total_count'] as num).toInt(),
      limit: (json['limit'] as num).toInt(),
    );

Map<String, dynamic> _$ExpensesResponseToJson(ExpensesResponse instance) =>
    <String, dynamic>{
      'expenses': instance.expenses,
      'total_count': instance.totalCount,
      'current_page': instance.currentPage,
      'total_pages': instance.totalPages,
      'limit': instance.limit,
    };

LastExpensesModel _$LastExpensesModelFromJson(Map<String, dynamic> json) =>
    LastExpensesModel(
      expensesLast7Days: (json['total_expenses_last_7_days'] as num).toInt(),
      expensesLast30Days: (json['total_expenses_last_30_days'] as num).toInt(),
    );

Map<String, dynamic> _$LastExpensesModelToJson(LastExpensesModel instance) =>
    <String, dynamic>{
      'total_expenses_last_7_days': instance.expensesLast7Days,
      'total_expenses_last_30_days': instance.expensesLast30Days,
    };

MontlyExpensesModel _$MontlyExpensesModelFromJson(Map<String, dynamic> json) =>
    MontlyExpensesModel(
      expenses: (json['expenses'] as List<dynamic>)
          .map((e) => Expense.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalAmount: (json['total_amount'] as num).toInt(),
    );

Map<String, dynamic> _$MontlyExpensesModelToJson(
        MontlyExpensesModel instance) =>
    <String, dynamic>{
      'expenses': instance.expenses,
      'total_amount': instance.totalAmount,
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_response_model.dart';

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

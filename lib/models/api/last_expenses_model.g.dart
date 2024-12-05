// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../expense/api/last_expenses_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

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

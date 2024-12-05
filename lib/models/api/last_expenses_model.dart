import 'dart:ffi';

import 'package:json_annotation/json_annotation.dart';
part 'last_expenses_model.g.dart';

@JsonSerializable()
class LastExpensesModel {
  @JsonKey(name: 'total_expenses_last_7_days')
  final int expensesLast7Days;

  @JsonKey(name: 'total_expenses_last_30_days')
  final int expensesLast30Days;

  LastExpensesModel({
    required this.expensesLast7Days,
    required this.expensesLast30Days,
  });

  factory LastExpensesModel.fromJson(Map<String, dynamic> json) =>
      _$LastExpensesModelFromJson(json);
  Map<String, dynamic> toJson() => _$LastExpensesModelToJson(this);
}

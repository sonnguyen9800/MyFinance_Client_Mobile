import 'package:json_annotation/json_annotation.dart';
import 'package:myfinance_client_flutter/models/expense/expense_model.dart';
part 'expense_api_model.g.dart';

@JsonSerializable()
class ExpensesResponse {
  @JsonKey(name: 'expenses')
  final List<Expense> expenses;

  @JsonKey(name: 'total_count')
  final int totalCount;
  @JsonKey(name: 'current_page')
  final int currentPage;
  @JsonKey(name: 'total_pages')
  final int totalPages;
  @JsonKey(name: 'limit')
  final int limit;

  ExpensesResponse({
    required this.expenses,
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
  });

  factory ExpensesResponse.fromJson(Map<String, dynamic> json) =>
      _$ExpensesResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ExpensesResponseToJson(this);
}

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

@JsonSerializable()
class MontlyExpensesModel {
  @JsonKey(name: 'expenses')
  final List<Expense> expenses;

  @JsonKey(name: 'total_amount')
  final int totalAmount;

  MontlyExpensesModel({
    required this.expenses,
    required this.totalAmount,
  });

  factory MontlyExpensesModel.fromJson(Map<String, dynamic> json) =>
      _$MontlyExpensesModelFromJson(json);
  Map<String, dynamic> toJson() => _$MontlyExpensesModelToJson(this);
}

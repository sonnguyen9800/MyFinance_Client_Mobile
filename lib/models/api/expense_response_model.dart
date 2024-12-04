import 'package:json_annotation/json_annotation.dart';
import 'package:myfinance_client_flutter/models/expense_model.dart';
part 'expense_response_model.g.dart';

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

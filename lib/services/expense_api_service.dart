import 'package:myfinance_client_flutter/models/expense/api/expense_api_model.dart';
import '../models/expense/expense_model.dart';
import 'dart:developer' as developer;

import 'base_api_service.dart';

class ExpenseApiService extends BaseApiService {
  Future<ExpensesResponse> getExpenses({
    required int page,
    required int limit,
    String? search,
    String? sortBy,
    bool? ascending,
  }) async {
    try {
      developer.log('Getting expenses');
      final Map<String, dynamic> queryParameters = {
        'page': page,
        'limit': limit,
        if (search != null && search.isNotEmpty) 'search': search,
        if (sortBy != null) 'sort_by': sortBy,
        if (ascending != null) 'ascending': ascending,
      };

      final response = await dio.get(
        '$baseUrl/expenses',
        queryParameters: queryParameters,
      );

      return ExpensesResponse.fromJson(response.data);
    } catch (e) {
      developer.log('getExpenses error: $e');
      throw Exception('Failed to get expenses: $e');
    }
  }

  Future<Expense> createExpense(Expense expense) async {
    try {
      final response = await dio.post(
        '$baseUrl/expenses',
        data: expense.toJson(),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      developer.log('createExpense error: $e');
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<Expense> updateExpense(String id, Expense expense) async {
    try {
      final response = await dio.put(
        '$baseUrl/expenses/$id',
        data: expense.toJson(),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      developer.log('updateExpense error: $e');
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await dio.delete('$baseUrl/expenses/$id');
    } catch (e) {
      developer.log('deleteExpense error: $e');
      throw Exception('Failed to delete expense: $e');
    }
  }

  Future<List<Expense>> getExpensesByDateRange(
      DateTime startDate, DateTime endDate) async {
    try {
      final response = await dio.get(
        '$baseUrl/expenses/range',
        queryParameters: {
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
      return (response.data as List)
          .map((expense) => Expense.fromJson(expense))
          .toList();
    } catch (e) {
      developer.log('getExpensesByDateRange error: $e');
      throw Exception('Failed to get expenses by date range: $e');
    }
  }

  Future<LastExpensesModel> getTotalSpendLastExpenses() async {
    try {
      final response = await dio.get('$baseUrl/expenses_last');
      return LastExpensesModel.fromJson(response.data);
    } catch (e) {
      throw Exception('Failed to load last expenses: $e');
    }
  }
}

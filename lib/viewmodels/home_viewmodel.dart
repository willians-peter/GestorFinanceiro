import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class HomeViewModel {
  final ValueNotifier<List<TransactionModel>> transactionsNotifier =
      ValueNotifier<List<TransactionModel>>([]);
      List<TransactionModel> get transactions => transactionsNotifier.value;

Future<void> loadTransactions() async {
    final list = await DatabaseService.instance.getAllTransactions();
    transactionsNotifier.value = list;
  }


Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseService.instance.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> removeTransaction(String id) async {
    await DatabaseService.instance.deleteTransaction(id);
    await loadTransactions();
  }

  


  List<TransactionModel> getTransactionsByMonth(int month, int year) {
    return transactions.where((t) {
      return t.date.month == month && t.date.year == year;
    }).toList();
  }

 
  double getTotalByMonth(int month, int year) {
    final monthList = getTransactionsByMonth(month, year);
    return monthList.fold(0.0, (sum, item) => sum + item.amount);
  }


  Map<String, double> getExpensesByCategory(int month, int year) {
    final monthList = getTransactionsByMonth(month, year);
    final Map<String, double> report = {};

    for (var transaction in monthList) {
      final currentTotal = report[transaction.category] ?? 0.0;
      report[transaction.category] = currentTotal + transaction.amount;
    }

    return report;
  }

  
  Map<String, double> getExpensesByEstablishment(int month, int year) {
    final monthList = getTransactionsByMonth(month, year);
    final Map<String, double> report = {};

    for (var transaction in monthList) {
      final currentTotal = report[transaction.establishment] ?? 0.0;
      report[transaction.establishment] = currentTotal + transaction.amount;
    }

    return report;
  }

  void dispose() {
    transactionsNotifier.dispose();
  }
}
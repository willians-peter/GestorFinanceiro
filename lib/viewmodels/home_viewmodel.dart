import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class HomeViewModel {
  final ValueNotifier<List<TransactionModel>> transactionsNotifier =
      ValueNotifier<List<TransactionModel>>([]);

  List<TransactionModel> get transactions => transactionsNotifier.value;

  /// Libera o ValueNotifier da memória
  void dispose() {
    transactionsNotifier.dispose();
  }

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

  /// Retorna apenas as transações do mês vigente até a data atual
  List<TransactionModel> get currentMonthTransactionsToDate {
    final now = DateTime.now();
    return transactionsNotifier.value.where((t) {
      final isSameYear = t.date.year == now.year;
      final isSameMonth = t.date.month == now.month;
      
      // Considera transações até o final do dia de hoje
      final isUpToToday = !t.date.isAfter(DateTime(now.year, now.month, now.day, 23, 59, 59));

      return isSameYear && isSameMonth && isUpToToday;
    }).toList();
  }

  /// Subtotal do mês vigente até o dia atual
  double get subtotalCurrentMonth {
    return currentMonthTransactionsToDate.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );
  }

  /// Retorna apenas as N últimas transações (ex: 5 mais recentes)
  List<TransactionModel> recentTransactions({int limit = 5}) {
    final list = List<TransactionModel>.from(transactionsNotifier.value);
    list.sort((a, b) => b.date.compareTo(a.date)); // Mais recente primeiro
    return list.take(limit).toList();
  }
}
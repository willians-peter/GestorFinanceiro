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
// --- AÇÕES ---

Future<void> addTransaction(TransactionModel transaction) async {
    await DatabaseService.instance.insertTransaction(transaction);
    await loadTransactions();
  }

  Future<void> removeTransaction(String id) async {
    await DatabaseService.instance.deleteTransaction(id);
    await loadTransactions();
  }

  // --- RELATÓRIOS E CÁLCULOS ---

  /// 1. Filtra todas as despesas de um mês e ano específicos
  List<TransactionModel> getTransactionsByMonth(int month, int year) {
    return transactions.where((t) {
      return t.date.month == month && t.date.year == year;
    }).toList();
  }

  /// 2. Total de gastos em um determinado mês
  double getTotalByMonth(int month, int year) {
    final monthList = getTransactionsByMonth(month, year);
    return monthList.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// 3. Relatório: Gastos agrupados POR CATEGORIA em um determinado mês
  /// Retorna um Map onde a CHAVE é o nome da Categoria e o VALOR é a soma gasta.
  /// Ex: {'Alimentação': 450.00, 'Lazer': 120.00}
  Map<String, double> getExpensesByCategory(int month, int year) {
    final monthList = getTransactionsByMonth(month, year);
    final Map<String, double> report = {};

    for (var transaction in monthList) {
      final currentTotal = report[transaction.category] ?? 0.0;
      report[transaction.category] = currentTotal + transaction.amount;
    }

    return report;
  }

  /// 4. Relatório: Gastos agrupados POR ESTABELECIMENTO em um determinado mês
  /// Ex: {'Supermercado X': 320.00, 'Posto Y': 150.00}
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
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

class EditDespesasViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _displayedTransactions = [];
  List<TransactionModel> get displayedTransactions => _displayedTransactions;

  DateTime? _selectedDate;
  DateTime? get selectedDate => _selectedDate;

  EditDespesasViewModel() {
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allTransactions = await _dbService.getAllTransactions();
      _applyFilter();
    } catch (e) {
      debugPrint('Erro ao carregar transações: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void filterByDate(DateTime? date) {
    _selectedDate = date;
    _applyFilter();
    notifyListeners();
  }

  void clearDateFilter() {
    _selectedDate = null;
    _applyFilter();
    notifyListeners();
  }

  void _applyFilter() {
    if (_selectedDate != null) {
      // Filtra transações que batem com Dia, Mês e Ano selecionados
      _displayedTransactions = _allTransactions.where((t) {
        return t.date.year == _selectedDate!.year &&
            t.date.month == _selectedDate!.month &&
            t.date.day == _selectedDate!.day;
      }).toList();
    } else {
      // Exibe apenas as últimas 7 despesas cadastradas
      _displayedTransactions = _allTransactions.take(7).toList();
    }
  }

  Future<void> deleteTransaction(String id) async {
    await _dbService.deleteTransaction(id);
    await loadTransactions();
  }
}
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../models/transaction_model.dart';
import '../services/database_service.dart';

enum DateFilterType { month, customRange }

class FilterViewModel extends ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Filtros de Data
  DateFilterType _dateFilterType = DateFilterType.month;
  DateFilterType get dateFilterType => _dateFilterType;

  DateTime _selectedMonth = DateTime.now();
  DateTime get selectedMonth => _selectedMonth;

  DateTimeRange? _customDateRange;
  DateTimeRange? get customDateRange => _customDateRange;

  // Listas de Opções para Dropdowns
  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<SubCategoryModel> _subCategories = [];
  List<SubCategoryModel> get subCategories => _subCategories;

  // Filtros de Categoria Selecionados
  String? _selectedCategoryId;
  String? get selectedCategoryId => _selectedCategoryId;

  String? _selectedSubCategoryId;
  String? get selectedSubCategoryId => _selectedSubCategoryId;

  // Resultado do Relatório
  List<TransactionModel> _filteredTransactions = [];
  List<TransactionModel> get filteredTransactions => _filteredTransactions;

  double get totalAmount =>
      _filteredTransactions.fold(0.0, (sum, t) => sum + t.amount);

  FilterViewModel() {
    _init();
  }

  Future<void> _init() async {
    _isLoading = true;
    notifyListeners();

    await loadCategories();
    await applyFilters();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCategories() async {
    _categories = await _dbService.getAllCategories();
    notifyListeners();
  }

  // --- Ações de Alteração de Filtro ---

  void setDateFilterType(DateFilterType type) {
    _dateFilterType = type;
    applyFilters();
  }

  void setSelectedMonth(DateTime month) {
    _selectedMonth = month;
    applyFilters();
  }

  void setCustomDateRange(DateTimeRange range) {
    _customDateRange = range;
    applyFilters();
  }

  Future<void> setSelectedCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;
    _selectedSubCategoryId = null; // Reseta subcategoria ao trocar de categoria

    if (categoryId != null) {
      _subCategories =
          await _dbService.getSubCategoriesByCategoryId(categoryId);
    } else {
      _subCategories = [];
    }

    applyFilters();
  }

  void setSelectedSubCategory(String? subCategoryId) {
    _selectedSubCategoryId = subCategoryId;
    applyFilters();
  }

  void clearFilters() {
    _dateFilterType = DateFilterType.month;
    _selectedMonth = DateTime.now();
    _customDateRange = null;
    _selectedCategoryId = null;
    _selectedSubCategoryId = null;
    _subCategories = [];
    applyFilters();
  }

  // --- Lógica de Filtragem ---

  Future<void> applyFilters() async {
    _isLoading = true;
    notifyListeners();

    final allTransactions = await _dbService.getAllTransactions();

    _filteredTransactions = allTransactions.where((t) {
      // 1. Filtro de Data
      bool matchesDate = true;
      if (_dateFilterType == DateFilterType.month) {
        matchesDate = t.date.year == _selectedMonth.year &&
            t.date.month == _selectedMonth.month;
      } else if (_dateFilterType == DateFilterType.customRange &&
          _customDateRange != null) {
        final start = DateTime(
          _customDateRange!.start.year,
          _customDateRange!.start.month,
          _customDateRange!.start.day,
        );
        final end = DateTime(
          _customDateRange!.end.year,
          _customDateRange!.end.month,
          _customDateRange!.end.day,
          23,
          59,
          59,
        );
        matchesDate = t.date.isAfter(start.subtract(const Duration(seconds: 1))) &&
            t.date.isBefore(end.add(const Duration(seconds: 1)));
      }

      // 2. Filtro de Categoria
      bool matchesCategory = true;
      if (_selectedCategoryId != null) {
        matchesCategory = t.idCategory == _selectedCategoryId;
      }

      // 3. Filtro de Subcategoria
      bool matchesSubCategory = true;
      if (_selectedSubCategoryId != null) {
        matchesSubCategory = t.idSubCategory == _selectedSubCategoryId;
      }

      return matchesDate && matchesCategory && matchesSubCategory;
    }).toList();

    _isLoading = false;
    notifyListeners();
  }
}
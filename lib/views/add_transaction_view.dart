import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../services/database_service.dart';
import '../shared/navigation_app_bar.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();

  final _establishmentController = TextEditingController();
  final _amountController = TextEditingController();

  // Guardam os IDs selecionados
  String? _selectedCategoryId;
  String? _selectedSubCategoryId;

  DateTime _selectedDate = DateTime.now();

  // Listas vindas do SQLite
  List<CategoryModel> _categories = [];
  List<SubCategoryModel> _subCategories = [];

  bool _isLoadingCategories = true;
  bool _isLoadingSubCategories = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _establishmentController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  /// Carrega as categorias principais do SQLite
  Future<void> _loadCategories() async {
    try {
      final categories = await DatabaseService.instance.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  /// Carrega as subcategorias filtradas pelo ID da Categoria selecionada
  Future<void> _loadSubCategories(String categoryId) async {
    setState(() {
      _isLoadingSubCategories = true;
      _selectedSubCategoryId = null; // Limpa a subcategoria anterior
      _subCategories = [];
    });

    try {
      final subCategories = await DatabaseService.instance
          .getSubCategoriesByCategoryId(categoryId);
      setState(() {
        _subCategories = subCategories;
        _isLoadingSubCategories = false;
      });
    } catch (e) {
      setState(() => _isLoadingSubCategories = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar subcategorias: $e')),
        );
      }
    }
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final amountText = _amountController.text.replaceAll(',', '.');
      final amount = double.tryParse(amountText) ?? 0.0;

      // Trata texto do estabelecimento (opcional)
      final establishmentText = _establishmentController.text.trim();

      final newTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        idCategory: _selectedCategoryId!,
        idSubCategory: _selectedSubCategoryId!,
        establishment: establishmentText.isEmpty ? null : establishmentText,
        amount: amount,
        date: _selectedDate,
        description: null,
      );

      // Salva no banco de dados SQLite
      await DatabaseService.instance.insertTransaction(newTransaction);

     if (mounted) {
      // 🟢 TRATAMENTO DO ERRO AQUI:
      if (context.canPop()) {
        context.pop(newTransaction); // Volta para a tela anterior enviando o objeto
      } else {
        context.go('/'); // Se não houver tela anterior, redireciona para a Home
      }
     }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationAppBar(title: 'Nova Transação'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Campo Valor
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  hintText: '0,00',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe o valor da despesa';
                  }
                  final parsed = double.tryParse(value.replaceAll(',', '.'));
                  if (parsed == null || parsed <= 0) {
                    return 'Digite um valor válido maior que zero';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // 2. Dropdown Categoria
              _isLoadingCategories
                  ? const Center(child: CircularProgressIndicator())
                  : DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Categoria',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category.idCategory,
                          child: Text(category.categoryName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategoryId = value;
                          });
                          _loadSubCategories(value);
                        }
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Selecione uma categoria';
                        }
                        return null;
                      },
                    ),
              const SizedBox(height: 16),

              // 3. Dropdown Subcategoria
              if (_selectedCategoryId != null) ...[
                _isLoadingSubCategories
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<String>(
                        value: _selectedSubCategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Subcategoria',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.subdirectory_arrow_right),
                        ),
                        items: _subCategories.map((subCategory) {
                          return DropdownMenuItem(
                            value: subCategory.idSubCategory,
                            child: Text(subCategory.subCategoryName),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSubCategoryId = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Selecione uma subcategoria';
                          }
                          return null;
                        },
                      ),
                const SizedBox(height: 16),
              ],

              // 4. Seletor de Data
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data da Despesa',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 5. Campo Estabelecimento (Agora por último e OPCIONAL)
              TextFormField(
                controller: _establishmentController,
                decoration: const InputDecoration(
                  labelText: 'Estabelecimento (Opcional)',
                  hintText: 'Ex: Supermercado Silva, Posto Shell',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                // Sem o validator para permitir salvar vazio
              ),
              const SizedBox(height: 24),

              // 6. Botão Salvar
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Despesa'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/transaction_model.dart';
import '../../shared/navigation_app_bar.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {

  final _formKey = GlobalKey<FormState>();

 
  final _establishmentController = TextEditingController();
  final _amountController = TextEditingController();

  
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();

  
  final List<String> _categories = [
    'Alimentação',
    'Mercado',
    'Transporte / Combustível',
    'Moradia',
    'Lazer',
    'Saúde',
    'Outros',
  ];

  @override
  void dispose() {
    _establishmentController.dispose();
    _amountController.dispose();
    super.dispose();
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

  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      
      final amountText = _amountController.text.replaceAll(',', '.');
      final amount = double.tryParse(amountText) ?? 0.0;

      final newTransaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID único baseado no timestamp
        establishment: _establishmentController.text.trim(),
        category: _selectedCategory!,
        amount: amount,
        date: _selectedDate,
        description: null, // Campo opcional, pode ser adicionado futuramente 
      );

      
      context.pop(newTransaction);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      
      appBar: const NavigationAppBar(title: 'Minhas Transações'), 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Campo Estabelecimento
              TextFormField(
                controller: _establishmentController,
                decoration: const InputDecoration(
                  labelText: 'Estabelecimento',
                  hintText: 'Ex: Supermercado Silva, Posto Shell',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.store),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Informe onde foi realizado o gasto';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Valor
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

              // Dropdown Categoria
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Categoria',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Selecione uma categoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seletor de Data
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
              const SizedBox(height: 24),

              // Botão Salvar
              ElevatedButton.icon(
                onPressed: _submitForm,
                icon: const Icon(Icons.save),
                label: const Text('Salvar Despesa'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
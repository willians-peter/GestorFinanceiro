import 'package:flutter/material.dart';
import 'package:gestorfinanceiro/views/filter_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../app_routes.dart';
import '../models/transaction_model.dart';
import '../shared/navigation_app_bar.dart';
import '../viewmodels/editDespesas_viewmodel.dart';

class EditDespesasView extends StatefulWidget {
  const EditDespesasView({super.key});

  @override
  State<EditDespesasView> createState() => _EditDespesasViewState();
}

class _EditDespesasViewState extends State<EditDespesasView> {
  final EditDespesasViewModel viewModel = EditDespesasViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationAppBar(title: 'Minhas Transações'),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Barra de Filtro de Data
                _buildFilterHeader(),
                const Divider(height: 1),

                // Lista de Transações
                Expanded(
                  child: viewModel.displayedTransactions.isEmpty
                      ? Center(
                          child: Text(
                            viewModel.selectedDate == null
                                ? 'Nenhuma despesa cadastrada.'
                                : 'Nenhuma despesa encontrada para esta data.',
                            style: const TextStyle(fontSize: 16),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: viewModel.displayedTransactions.length,
                          itemBuilder: (context, index) {
                            final transaction =
                                viewModel.displayedTransactions[index];
                            return _buildTransactionCard(transaction);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Cabeçalho de Seleção de Data
  Widget _buildFilterHeader() {
    final hasFilter = viewModel.selectedDate != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAlignment.start,
              children: [
                Text(
                  hasFilter ? 'Filtrado por Data:' : 'Exibindo:',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                Text(
                  hasFilter
                      ? DateFormat('dd/MM/yyyy').format(viewModel.selectedDate!)
                      : 'Últimas 7 despesas',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (hasFilter)
                IconButton(
                  tooltip: 'Limpar Filtro',
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: viewModel.clearDateFilter,
                ),
              ElevatedButton.icon(
                onPressed: _selectDate,
                icon: const Icon(Icons.calendar_month, size: 18),
                label: Text(hasFilter ? 'Mudar' : 'Filtrar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Card para cada Item da Lista
  Widget _buildTransactionCard(TransactionModel transaction) {
    final categoryName = transaction.categoryName ?? transaction.idCategory;
    final subCategoryName =
        transaction.subCategoryName ?? transaction.idSubCategory;

    var column2 = Column(
      crossAxisAlignment: CrossAlignment.start,
      children: [
        if (transaction.establishment != null &&
            transaction.establishment!.isNotEmpty)
          Text('$categoryName - $subCategoryName'),
        const SizedBox(height: 4),
        Text(
          DateFormat('dd/MM/yyyy').format(transaction.date),
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
    var column = column2;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            Icons.receipt_long,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          transaction.establishment != null &&
                  transaction.establishment!.isNotEmpty
              ? transaction.establishment!
              : '$categoryName - $subCategoryName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: column,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'R\$ ${transaction.amount.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 8),
            // Botão de Editar
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              tooltip: 'Editar Despesa',
              onPressed: () => _editTransaction(transaction),
            ),
            // Botão de Excluir
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: 'Excluir Despesa',
              onPressed: () => _confirmDelete(transaction),
            ),
          ],
        ),
      ),
    );
  }

  // Seletor de Data
  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      viewModel.filterByDate(picked);
    }
  }

  // Ação ao Clicar em Editar (Navega enviando o objeto da transação)
  void _editTransaction(TransactionModel transaction) {
    // Caso utilize go_router passando o objeto como extra:
    // context.push(AppRoutes.addDespesa, extra: transaction);

    // Ou navegando para a rota de edição informando o id:
    context.push(AppRoutes.addTransaction, extra: transaction);
  }

  // Confirmação de Exclusão
  void _confirmDelete(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Excluir Despesa'),
        content: Text(
          'Deseja realmente excluir a despesa de R\$ ${transaction.amount.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await viewModel.deleteTransaction(transaction.id);
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

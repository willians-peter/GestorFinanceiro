import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';
import '../shared/navigation_app_bar.dart';
import '../viewmodels/filter_viewmodel.dart';

class FilterView extends StatefulWidget {
  const FilterView({super.key});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  final FilterViewModel viewModel = FilterViewModel();

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
      appBar: const NavigationAppBar(title: 'Para onde foi meu dinheiro'),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Painel de Filtros
                ExpansionTile(
                  title: const Text(
                    'Opções de Filtro',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  leading: const Icon(Icons.filter_list),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        children: [
                          _buildDateSection(),
                          const SizedBox(height: 12),
                          _buildCategorySection(),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: viewModel.clearFilters,
                              icon: const Icon(Icons.clear_all),
                              label: const Text('Limpar Filtros'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(),

                // Header com o Totalizador do Período
                Card(
                  margin: const EdgeInsets.all(16),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total no Período:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'R\$ ${viewModel.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Lista de Resultados
                Expanded(
                  child: viewModel.filteredTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'Nenhuma despesa encontrada para os filtros.',
                          ),
                        )
                      : ListView.builder(
                          itemCount: viewModel.filteredTransactions.length,
                          itemBuilder: (context, index) {
                            final item = viewModel.filteredTransactions[index];
                            return _buildTransactionItem(item);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  // Widget para seleção do tipo de data
  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAlignment.stretch,
      children: [
        SegmentedButton<DateFilterType>(
          segments: const [
            ButtonSegment(
              value: DateFilterType.month,
              label: Text('Por Mês'),
              icon: Icon(Icons.calendar_month),
            ),
            ButtonSegment(
              value: DateFilterType.customRange,
              label: Text('Período'),
              icon: Icon(Icons.date_range),
            ),
          ],
          selected: {viewModel.dateFilterType},
          onSelectionChanged: (Set<DateFilterType> selection) {
            viewModel.setDateFilterType(selection.first);
          },
        ),
        const SizedBox(height: 12),
        if (viewModel.dateFilterType == DateFilterType.month)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mês: ${DateFormat('MM/yyyy').format(viewModel.selectedMonth)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              ElevatedButton.icon(
                onPressed: _pickMonth,
                icon: const Icon(Icons.edit_calendar),
                label: const Text('Alterar Mês'),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  viewModel.customDateRange == null
                      ? 'Nenhum período selecionado'
                      : '${DateFormat('dd/MM/yy').format(viewModel.customDateRange!.start)} até ${DateFormat('dd/MM/yy').format(viewModel.customDateRange!.end)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range),
                label: const Text('Selecionar Datas'),
              ),
            ],
          ),
      ],
    );
  }

  // Widget para seleção de Categorias e Subcategorias
  Widget _buildCategorySection() {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: viewModel.selectedCategoryId,
          decoration: const InputDecoration(labelText: 'Categoria'),
          items: [
            const DropdownMenuItem(
              value: null,
              child: Text('Todas as Categorias'),
            ),
            ...viewModel.categories.map(
              (cat) => DropdownMenuItem(
                value: cat.idCategory,
                child: Text(cat.categoryName),
              ),
            ),
          ],
          onChanged: (val) => viewModel.setSelectedCategory(val),
        ),
        if (viewModel.selectedCategoryId != null) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: viewModel.selectedSubCategoryId,
            decoration: const InputDecoration(labelText: 'Subcategoria'),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('Todas as Subcategorias'),
              ),
              ...viewModel.subCategories.map(
                (sub) => DropdownMenuItem(
                  value: sub.idSubCategory,
                  child: Text(sub.subCategoryName),
                ),
              ),
            ],
            onChanged: (val) => viewModel.setSelectedSubCategory(val),
          ),
        ],
      ],
    );
  }

  // Item da Lista de Transações
  Widget _buildTransactionItem(TransactionModel transaction) {
    final catName = transaction.categoryName ?? transaction.idCategory;
    final subName = transaction.subCategoryName ?? transaction.idSubCategory;

    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.money_off)),
      title: Text('$catName - $subName'),
      subtitle: Text(DateFormat('dd/MM/yyyy').format(transaction.date)),
      trailing: Text(
        'R\$ ${transaction.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }

  // Seletores de Data Nativo
  Future<void> _pickMonth() async {
    final date = await showDatePicker(
      context: context,
      initialDate: viewModel.selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Selecione um dia do mês desejado',
    );
    if (date != null) {
      viewModel.setSelectedMonth(date);
    }
  }

  Future<void> _pickDateRange() async {
    final range = await showDateRangePicker(
      context: context,
      initialDateRange: viewModel.customDateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (range != null) {
      viewModel.setCustomDateRange(range);
    }
  }
}

class CrossAlignment {
  static CrossAxisAlignment stretch = CrossAxisAlignment.stretch;

  static Null get start => null;

 
}

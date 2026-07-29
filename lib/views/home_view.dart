import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_routes.dart';
import '../models/transaction_model.dart';
import '../viewmodels/home_viewmodel.dart';
import '../shared/navigation_app_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final viewModel = HomeViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.loadTransactions();
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationAppBar(title: 'Início'),
      body: ValueListenableBuilder<List<TransactionModel>>(
        valueListenable: viewModel.transactionsNotifier,
        builder: (context, transactions, child) {
          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma transação cadastrada.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Busca apenas as 5 mais recentes e o subtotal do mês
          final recentList = viewModel.recentTransactions(limit: 5);
          final subtotal = viewModel.subtotalCurrentMonth;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- CARD DE SUBTOTAL DO MÊS VIGENTE ATÉ HOJE ---
              Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 2,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Subtotal do Mês',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Até a data atual',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- TÍTULO DA SEÇÃO ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Últimos Lançamentos',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // --- LISTA RECENTE ---
              Expanded(
                child: ListView.builder(
                  itemCount: recentList.length,
                  itemBuilder: (context, index) {
                    final transaction = recentList[index];
                    final formattedDate =
                        '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';

                    // Define o nome de exibição (se establishment for null, usa o id da subcategoria ou um texto padrão)
                  final titleText = '${transaction.categoryName} - ${transaction.subCategoryName}';// Ou um rótulo genérico se preferir

                    return Dismissible(
                      key: Key(transaction.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.redAccent,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        viewModel.removeTransaction(transaction.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('$titleText removido.'),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.receipt_long),
                          ),
                          title: Text(
                            titleText,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(formattedDate),
                              if (transaction.description != null &&
                                  transaction.description!.isNotEmpty)
                                Text(
                                  transaction.description!,
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.grey[700],
                                  ),
                                ),
                            ],
                          ),
                          trailing: Text(
                            'R\$ ${transaction.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTransaction =
              await context.push<TransactionModel>(AppRoutes.addTransaction);

          if (newTransaction != null) {
            viewModel.addTransaction(newTransaction);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
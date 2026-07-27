import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_routes.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../shared/navigation_app_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

@override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // 👈 2. Instancie a ViewModel AQUI, no topo da classe de estado:
  final viewModel = HomeViewModel();

@override
void initState() {
  super.initState();
  viewModel.loadTransactions(); // 👈 Carrega do SQLite ao abrir a tela
}
  @override
  void dispose() {
    viewModel.dispose(); // Libera o Notifier da memória quando a tela for fechada
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      
      appBar: const NavigationAppBar(title: 'Minhas Transações'), 
  
      body: ValueListenableBuilder<List<TransactionModel>>(
        valueListenable: viewModel.transactionsNotifier,
        builder: (context, transactions, child) {
          // Estado vazio
          if (transactions.isEmpty) {
            return const Center(
              child: Text(
                'Nenhuma transação cadastrada.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          // Cálculo do valor total exibido
          final total = transactions.fold(
            0.0,
            (sum, item) => sum + item.amount,
          );

          return Column(
            children: [
              
              Card(
                margin: const EdgeInsets.all(16.0),
                elevation: 2,
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total do Período:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
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

              // --- LISTA DE TRANSAÇÕES ---
              Expanded(
                child: ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    final formattedDate =
                        '${transaction.date.day.toString().padLeft(2, '0')}/${transaction.date.month.toString().padLeft(2, '0')}/${transaction.date.year}';

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
                            content: Text('${transaction.establishment} removido.'),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Icon(_getCategoryIcon(transaction.category)),
                          ),
                          title: Text(
                            transaction.establishment,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${transaction.category} • $formattedDate'),
                              // Se houver descrição opcional, exibe abaixo:
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

  // Mapeamento de ícones das categorias
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Alimentação':
        return Icons.restaurant;
      case 'Mercado':
        return Icons.shopping_cart;
      case 'Transporte / Combustível':
        return Icons.directions_car;
      case 'Moradia':
        return Icons.home;
      case 'Lazer':
        return Icons.sports_esports;
      case 'Saúde':
        return Icons.medical_services;
      default:
        return Icons.attach_money;
    }
  }
}
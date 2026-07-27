import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../app_routes.dart';
import '../../models/transaction_model.dart';
import '../../viewmodels/editDespesas_viewmodel.dart';
import '../../shared/navigation_app_bar.dart';

class EditDespesasView extends StatefulWidget {
  const EditDespesasView({super.key});



@override
  State<EditDespesasView> createState() => _EditDespesasViewState();
}

class _EditDespesasViewState extends State<EditDespesasView> {
  // 👈 2. Instancie a ViewModel AQUI, no topo da classe de estado:
  final viewModel = EditDespesasViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      // 2. Chame o widget passando o título desejado para a Home
      appBar: const NavigationAppBar(title: 'Minhas Transações'), 
      body: Text('Tela de edição de transações'),
    );    
          }
}
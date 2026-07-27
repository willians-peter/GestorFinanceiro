import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_routes.dart'; // Ajuste o caminho de acordo com o seu projeto

class NavigationAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const NavigationAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.menu),
          tooltip: 'Navegar para...',
          onSelected: (route) {
            // Se o usuário já estiver na rota selecionada, não faz nada
            if (GoRouterState.of(context).matchedLocation == route) return;

            // Navega para a página escolhida
            context.go(route);
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: AppRoutes.home,
              child: ListTile(leading: Icon(Icons.home), title: Text('Início')),
            ),
            const PopupMenuItem<String>(
              value: AppRoutes.addTransaction,
              child: ListTile(
                leading: Icon(Icons.add_circle),
                title: Text('Nova Transação'),
              ),
            ),
            const PopupMenuItem<String>(
              value: AppRoutes.editDespesas,
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar Despesas'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Define a altura padrão da AppBar exigida pelo Flutter
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

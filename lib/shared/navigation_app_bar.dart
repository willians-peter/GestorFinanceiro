import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../app_routes.dart';

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
            if (GoRouterState.of(context).matchedLocation == route) return;

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
              value: AppRoutes.filterTela,
              child: ListTile(
                leading: Icon(Icons.filter),
                title: Text('Relatórios'),
              ),
            ),
            const PopupMenuItem<String>(
              value: AppRoutes.editDespesas,
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar Despesas'),
              ),
            ),
            const PopupMenuItem<String>(
              value: AppRoutes.categoryAjust,
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Ajustar Categorias'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

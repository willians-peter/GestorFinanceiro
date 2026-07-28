import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/home_view.dart';
import 'views/add_transaction_view.dart';
import 'views/editDespesas_view.dart';
import 'views/categoryAjust_view.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String addTransaction = '/add-transaction';
  static const String editDespesas = '/edit-despesas';
  static const String categoryAjust = '/category-ajust';

  static final GoRouter router = GoRouter(
    initialLocation: home,
    routes: [
      GoRoute(path: home, builder: (context, state) => const HomeView()),
      GoRoute(
        path: addTransaction,
        builder: (context, state) => const AddTransactionView(),
      ),
       GoRoute(
        path: editDespesas,
        builder: (context, state) => const EditDespesasView(),
      ),
      
       GoRoute(
        path: categoryAjust,
        builder: (context, state) => const CategoryAjustView(),
      ),
    ],
    
  );
}

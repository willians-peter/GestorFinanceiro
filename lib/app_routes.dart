import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'views/home/home_view.dart';
import 'views/add_transaction/add_transaction_view.dart';
import 'views/edit/editDespesas_view.dart';

abstract class AppRoutes {
  static const String home = '/';
  static const String addTransaction = '/add-transaction';
static const String editDespesas = '/edit-despesas';

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
    ],
    
  );
}

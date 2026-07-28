import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/database_service.dart';
import '../shared/navigation_app_bar.dart';

class CategoryAjustView extends StatefulWidget {
  const CategoryAjustView({super.key});

  @override
  State<CategoryAjustView> createState() => _CategoryAjustViewState();
}

class _CategoryAjustViewState extends State<CategoryAjustView> {
  List<CategoryModel> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  /// Carrega as categorias salvas do banco de dados
  Future<void> _loadCategories() async {
    setState(() => _isLoading = true);
    try {
      final categories = await DatabaseService.instance.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  /// Abre o modal para Criar ou Editar uma Categoria
  void _showCategoryDialog({CategoryModel? category}) {
    final controller = TextEditingController(
      text: category != null ? category.categoryName : '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(category == null ? 'Nova Categoria' : 'Editar Categoria'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome da Categoria',
                hintText: 'Ex: Alimentação, Lazer...',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o nome da categoria';
                }
                return null;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final name = controller.text.trim();

                  if (category == null) {
                    // Nova Categoria
                    final newCategory = CategoryModel(
                      idCategory: DateTime.now().millisecondsSinceEpoch.toString(),
                      categoryName: name,
                    );
                    await DatabaseService.instance.insertCategory(newCategory);
                  } else {
                    // Atualiza Categoria existente
                    final updatedCategory = CategoryModel(
                      idCategory: category.idCategory,
                      categoryName: name,
                    );
                    await DatabaseService.instance.updateCategory(updatedCategory);
                  }

                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadCategories(); // Recarrega a lista
                  }
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  /// Exibe confirmação antes de excluir
  void _confirmDelete(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Categoria'),
          content: Text(
            'Tem certeza que deseja excluir "${category.categoryName}"? '
            'Isso também afetará as subcategorias e despesas vinculadas a ela.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseService.instance.deleteCategory(category.idCategory);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadCategories();
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationAppBar(title: 'Minhas categorias'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _categories.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.category_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Nenhuma categoria cadastrada',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _showCategoryDialog(),
                        icon: const Icon(Icons.add),
                        label: const Text('Criar primeira categoria'),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          category.categoryName.isNotEmpty
                              ? category.categoryName[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(
                        category.categoryName,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Editar',
                            onPressed: () => _showCategoryDialog(category: category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'Excluir',
                            onPressed: () => _confirmDelete(category),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        tooltip: 'Adicionar Categoria',
        child: const Icon(Icons.add),
      ),
    );
  }
}
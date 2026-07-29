import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../services/database_service.dart';
import '../shared/navigation_app_bar.dart';

class CategoryAjustView extends StatefulWidget {
  const CategoryAjustView({super.key});

  @override
  State<CategoryAjustView> createState() => _CategoryAjustViewState();
}

class _CategoryAjustViewState extends State<CategoryAjustView> {
  List<CategoryModel> _categories = [];
  // Mapeia o ID da Categoria para sua lista de Subcategorias
  final Map<String, List<SubCategoryModel>> _subCategoriesMap = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// Carrega Categorias e suas respectivas Subcategorias do banco
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await DatabaseService.instance.getAllCategories();
      final Map<String, List<SubCategoryModel>> tempMap = {};

      for (var cat in categories) {
        final subs = await DatabaseService.instance
            .getSubCategoriesByCategoryId(cat.idCategory);
        tempMap[cat.idCategory] = subs;
      }

      setState(() {
        _categories = categories;
        _subCategoriesMap.clear();
        _subCategoriesMap.addAll(tempMap);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  // ==========================================
  // LÓGICA DE CATEGORIAS
  // ==========================================

  void _showCategoryDialog({CategoryModel? category}) {
    final controller = TextEditingController(
      text: category?.categoryName ?? '',
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
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Informe o nome' : null,
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
                    await DatabaseService.instance.insertCategory(
                      CategoryModel(
                        idCategory: DateTime.now().millisecondsSinceEpoch.toString(),
                        categoryName: name,
                      ),
                    );
                  } else {
                    await DatabaseService.instance.updateCategory(
                      CategoryModel(
                        idCategory: category.idCategory,
                        categoryName: name,
                      ),
                    );
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadData();
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

  void _confirmDeleteCategory(CategoryModel category) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Categoria'),
          content: Text(
            'Excluir "${category.categoryName}" também apagará todas as suas subcategorias e despesas associadas. Deseja continuar?',
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
                  _loadData();
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

  // ==========================================
  // LÓGICA DE SUBCATEGORIAS
  // ==========================================

  void _showSubCategoryDialog({
    required String categoryId,
    SubCategoryModel? subCategory,
  }) {
    final controller = TextEditingController(
      text: subCategory?.subCategoryName ?? '',
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(subCategory == null ? 'Nova Subcategoria' : 'Editar Subcategoria'),
          content: Form(
            key: formKey,
            child: TextFormField(
              controller: controller,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nome da Subcategoria',
                border: OutlineInputBorder(),
              ),
              validator: (val) =>
                  (val == null || val.trim().isEmpty) ? 'Informe o nome' : null,
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
                  if (subCategory == null) {
                    await DatabaseService.instance.insertSubCategory(
                      SubCategoryModel(
                        idSubCategory: DateTime.now().millisecondsSinceEpoch.toString(),
                        idCategory: categoryId,
                        subCategoryName: name,
                      ),
                    );
                  } else {
                    await DatabaseService.instance.updateSubCategory(
                      SubCategoryModel(
                        idSubCategory: subCategory.idSubCategory,
                        idCategory: categoryId,
                        subCategoryName: name,
                      ),
                    );
                  }
                  if (mounted) {
                    Navigator.of(context).pop();
                    _loadData();
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

  void _confirmDeleteSubCategory(SubCategoryModel subCategory) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir Subcategoria'),
          content: Text(
            'Tem certeza que deseja excluir "${subCategory.subCategoryName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                await DatabaseService.instance
                    .deleteSubCategory(subCategory.idSubCategory);
                if (mounted) {
                  Navigator.of(context).pop();
                  _loadData();
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

  // ==========================================
  // BUILD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationAppBar(title: 'Minhas Categorias'),
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
                        label: const Text('Criar Categoria'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12.0),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final subCategories =
                        _subCategoriesMap[category.idCategory] ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          child: Text(
                            category.categoryName.isNotEmpty
                                ? category.categoryName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          category.categoryName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Text('${subCategories.length} subcategoria(s)'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              tooltip: 'Editar Categoria',
                              onPressed: () =>
                                  _showCategoryDialog(category: category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Excluir Categoria',
                              onPressed: () =>
                                  _confirmDeleteCategory(category),
                            ),
                          ],
                        ),
                        children: [
                          const Divider(height: 1),
                          // Subcategorias
                          ...subCategories.map((sub) {
                            return ListTile(
                              contentPadding: const EdgeInsets.only(
                                left: 32,
                                right: 16,
                              ),
                              leading: const Icon(
                                Icons.subdirectory_arrow_right,
                                size: 20,
                                color: Colors.grey,
                              ),
                              title: Text(sub.subCategoryName),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 20, color: Colors.blueGrey),
                                    onPressed: () => _showSubCategoryDialog(
                                      categoryId: category.idCategory,
                                      subCategory: sub,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 20, color: Colors.redAccent),
                                    onPressed: () =>
                                        _confirmDeleteSubCategory(sub),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Botão de Adicionar Subcategoria
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                onPressed: () => _showSubCategoryDialog(
                                  categoryId: category.idCategory,
                                ),
                                icon: const Icon(Icons.add, size: 18),
                                label: const Text('Adicionar Subcategoria'),
                              ),
                            ),
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
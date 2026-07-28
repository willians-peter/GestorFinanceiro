import '../models/category_model.dart';
import '../models/sub_category_model.dart';

class DefaultCategories {
  static  List<CategoryModel> categories = [
    CategoryModel(idCategory: 'cat_alimentacao', categoryName: 'Alimentação'),
    CategoryModel(idCategory: 'cat_mercado', categoryName: 'Mercado'),
    CategoryModel(idCategory: 'cat_transporte', categoryName: 'Transporte'),
    CategoryModel(idCategory: 'cat_moradia', categoryName: 'Moradia'),
    CategoryModel(idCategory: 'cat_lazer', categoryName: 'Lazer'),
    CategoryModel(idCategory: 'cat_saude', categoryName: 'Saúde'),
    CategoryModel(idCategory: 'cat_outros', categoryName: 'Outros'),
  ];

  static const List<SubCategoryModel> subCategories = [
    // --- Alimentação ---
    SubCategoryModel(idSubCategory: 'sub_restaurante', categoryId: 'cat_alimentacao', subCategoryName: 'Restaurante'),
    SubCategoryModel(idSubCategory: 'sub_padaria', categoryId: 'cat_alimentacao', subCategoryName: 'Padaria'),

    // --- Mercado ---
    SubCategoryModel(idSubCategory: 'sub_agropecuaria', categoryId: 'cat_mercado', subCategoryName: 'Agropecuária (Pets)'),
    SubCategoryModel(idSubCategory: 'sub_suplementos', categoryId: 'cat_mercado', subCategoryName: 'Suplementos'),
    SubCategoryModel(idSubCategory: 'sub_produtos_naturais', categoryId: 'cat_mercado', subCategoryName: 'Produtos Naturais'),

    // --- Transporte ---
    SubCategoryModel(idSubCategory: 'sub_combustivel', categoryId: 'cat_transporte', subCategoryName: 'Combustível'),
    SubCategoryModel(idSubCategory: 'sub_manutencao_transp', categoryId: 'cat_transporte', subCategoryName: 'Manutenção'),

    // --- Moradia ---
    SubCategoryModel(idSubCategory: 'sub_manutencao_moradia', categoryId: 'cat_moradia', subCategoryName: 'Manutenção'),
    SubCategoryModel(idSubCategory: 'sub_reforma', categoryId: 'cat_moradia', subCategoryName: 'Reforma'),
    SubCategoryModel(idSubCategory: 'sub_benfeitoria', categoryId: 'cat_moradia', subCategoryName: 'Benfeitoria'),

    // --- Lazer ---
    SubCategoryModel(idSubCategory: 'sub_passeio', categoryId: 'cat_lazer', subCategoryName: 'Passeio'),
    SubCategoryModel(idSubCategory: 'sub_viagem', categoryId: 'cat_lazer', subCategoryName: 'Viagem'),
  ];
}
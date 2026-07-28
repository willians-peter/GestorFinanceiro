class SubCategoryModel {
  final String idSubCategory;
  final String categoryId; // ID da Categoria Mãe a qual ela pertence
  final String subCategoryName;

  const SubCategoryModel({
    required this.idSubCategory,
    required this.categoryId,
    required this.subCategoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'idSubCategory': idSubCategory,
      'categoryId': categoryId, // Salva como categoryId
      'subCategoryName': subCategoryName,
    };
  }

  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      idSubCategory: (map['idSubCategory'] as String?) ?? '',
      categoryId: (map['categoryId'] as String?) ?? '', // Lê como categoryId
      subCategoryName: (map['subCategoryName'] as String?) ?? '',
    );
  }

  SubCategoryModel copyWith({
    String? idSubCategory,
    String? categoryId,
    String? subCategoryName,
  }) {
    return SubCategoryModel(
      idSubCategory: idSubCategory ?? this.idSubCategory,
      categoryId: categoryId ?? this.categoryId,
      subCategoryName: subCategoryName ?? this.subCategoryName,
    );
  }

  @override
  String toString() {
    return 'SubCategoryModel(idSubCategory: $idSubCategory, categoryId: $categoryId, subCategoryName: $subCategoryName)';
  }
}

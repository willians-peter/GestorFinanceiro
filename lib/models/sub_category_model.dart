class SubCategoryModel {
  final String idSubCategory;
  final String idCategory; 
  final String subCategoryName;

  const SubCategoryModel({
    required this.idSubCategory,
    required this.idCategory,
    required this.subCategoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'idSubCategory': idSubCategory,
      'idCategory': idCategory, 
      'subCategoryName': subCategoryName,
    };
  }

  factory SubCategoryModel.fromMap(Map<String, dynamic> map) {
    return SubCategoryModel(
      idSubCategory: (map['idSubCategory'] as String?) ?? '',
      idCategory: (map['idCategory'] as String?) ?? '', // Lê como categoryId
      subCategoryName: (map['subCategoryName'] as String?) ?? '',
    );
  }

  SubCategoryModel copyWith({
    String? idSubCategory,
    String? idCategory,
    String? subCategoryName,
  }) {
    return SubCategoryModel(
      idSubCategory: idSubCategory ?? this.idSubCategory,
      idCategory: idCategory ?? this.idCategory,
      subCategoryName: subCategoryName ?? this.subCategoryName,
    );
  }

  @override
  String toString() {
    return 'SubCategoryModel(idSubCategory: $idSubCategory, idCategoryId: $idCategory, subCategoryName: $subCategoryName)';
  }
}

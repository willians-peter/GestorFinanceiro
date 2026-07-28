class CategoryModel {
  final String idCategory;
  final String categoryName;


  CategoryModel({required this.idCategory, required this.categoryName});

  Map<String, dynamic> toMap() {
    return {'idCategory': idCategory, 'categoryName': categoryName};
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      idCategory: map['idCategory'] as String,
      categoryName: map['categoryName'] as String,
    );
  }

  CategoryModel copyWith({String? idCategory, String? categoryName}) {
    return CategoryModel(
      idCategory: idCategory ?? this.idCategory,
      categoryName: categoryName ?? this.categoryName,
    );
  }
}

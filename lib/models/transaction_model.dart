class TransactionModel {
  final String id;
  final String idCategory; // Aponta para a categoria
  final String idSubCategory; // Aponta para a subcategoria
  final String? establishment;
  final double amount;
  final DateTime date;
  final String? description;
  final String? categoryName;
  final String? subCategoryName;

  const TransactionModel({
    required this.id,
    required this.idCategory,
    required this.idSubCategory,
    this.establishment,
    required this.amount,
    required this.date,
    this.description,
    this.categoryName,
    this.subCategoryName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idCategory': idCategory,
      'idSubCategory': idSubCategory,
      'establishment': establishment,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: (map['id'] as String?) ?? '',
      idCategory: (map['idCategory'] as String?) ?? '',
      idSubCategory: (map['idSubCategory'] as String?) ?? '',
      establishment: map['establishment'] as String?,
      amount: ((map['amount'] as num?) ?? 0.0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch((map['date'] as int?) ?? 0),
      description: map['description'] as String?,
      // Mapeia os nomes vindos do JOIN (se existirem)
      categoryName: map['categoryName'] as String,
      subCategoryName: map['subCategoryName'] as String,
    );
  }
}

class TransactionModel {
  final String id;
  final String categoryId;      // Aponta para a categoria
  final String subCategoryId;   // Aponta para a subcategoria
  final String? establishment;
  final double amount;
  final DateTime date;
  final String? description;

  const TransactionModel({
    required this.id,
    required this.categoryId,
    required this.subCategoryId,
    this.establishment,
    required this.amount,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'establishment': establishment,
      'amount': amount,
      'date': date.millisecondsSinceEpoch,
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: (map['id'] as String?) ?? '',
      categoryId: (map['categoryId'] as String?) ?? '',
      subCategoryId: (map['subCategoryId'] as String?) ?? '',
      establishment: map['establishment'] as String?,
      amount: ((map['amount'] as num?) ?? 0.0).toDouble(),
      date: DateTime.fromMillisecondsSinceEpoch((map['date'] as int?) ?? 0),
      description: map['description'] as String?,
    );
  }
}
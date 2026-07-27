

class TransactionModel {
    final String id;
    final String category;
    final String establishment;
    final double amount;
    final DateTime date;
    final String? description; // Campo opcional
  
  
    TransactionModel({
      required this.id,
      required this.category,
      required this.establishment,
      required this.amount,
      required this.date,
      this.description,
    });
Map<String, dynamic> toMap() {
      return {
        'id': id,
        'category': category,
        'establishment': establishment,
        'amount': amount,
        'date': date.millisecondsSinceEpoch,
        'description': description,
      };
    }

    factory TransactionModel.fromMap(Map<String, dynamic> map) {
      return TransactionModel(
        id: map['id'] as String,
        category: map['category'] as String,
        establishment: map['establishment'] as String,
        amount: (map['amount'] as num).toDouble(),
        date: DateTime.fromMillisecondsSinceEpoch(map['date'] as int),
        description: map['description'] as String?,
        );
    }
    TransactionModel copyWith({
      String? id,
      String? category,
      String? establishment,
      double? amount,
      DateTime? date,
      String? description,
    }) {
      return TransactionModel(
        id: id ?? this.id,
        category: category ?? this.category,
        establishment: establishment ?? this.establishment,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        description: description ?? this.description,
      );
    }
}
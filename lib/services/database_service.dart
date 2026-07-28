import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/sub_category_model.dart';
import '../utils/default_categories.dart'; 

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('financial.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path, 
      version: 3, // Subi para a versão 3 para forçar o recarregamento com os dados padrão
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Tabela de Categorias
    await db.execute('''
      CREATE TABLE categories(
        idCategory TEXT PRIMARY KEY,
        categoryName TEXT NOT NULL
      )
    ''');

    // 2. Tabela de Subcategorias
    await db.execute('''
      CREATE TABLE subcategories(
        idSubCategory TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        subCategoryName TEXT NOT NULL,
        FOREIGN KEY (categoryId) REFERENCES categories (idCategory) ON DELETE CASCADE
      )
    ''');

    // 3. Tabela de Transações
    await db.execute('''
      CREATE TABLE transactions(
        id TEXT PRIMARY KEY,
        categoryId TEXT NOT NULL,
        subCategoryId TEXT NOT NULL,
        establishment TEXT,
        amount REAL NOT NULL,
        date INTEGER NOT NULL,
        description TEXT,
        FOREIGN KEY (categoryId) REFERENCES categories (idCategory),
        FOREIGN KEY (subCategoryId) REFERENCES subcategories (idSubCategory)
      )
    ''');

    // ==========================================
    // INSERINDO AS CATEGORIAS PADRÃO
    // ==========================================
    final batch = db.batch();

    for (var category in DefaultCategories.categories) {
      batch.insert('categories', category.toMap());
    }

    for (var subCategory in DefaultCategories.subCategories) {
      batch.insert('subcategories', subCategory.toMap());
    }

    await batch.commit(noResult: true);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS subcategories');
      await db.execute('DROP TABLE IF EXISTS categories');
      await _createDB(db, newVersion);
    }
  }

  // ==========================================
  // OPERAÇÕES DE MÉTODOS CRUD
  // ==========================================

  // --- CATEGORIAS ---
  Future<void> insertCategory(CategoryModel category) async {
    final db = await instance.database;
    await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<CategoryModel>> getAllCategories() async {
    final db = await instance.database;
    final result = await db.query('categories', orderBy: 'categoryName ASC');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<int> updateCategory(CategoryModel category) async {
    final db = await instance.database;
    return await db.update(
      'categories',
      category.toMap(),
      where: 'idCategory = ?',
      whereArgs: [category.idCategory],
    );
  }

  Future<int> deleteCategory(String idCategory) async {
    final db = await instance.database;
    // Graças ao ON DELETE CASCADE, deletar a categoria apaga as subcategorias ligadas a ela
    return await db.delete('categories', where: 'idCategory = ?', whereArgs: [idCategory]);
  }

  // --- SUBCATEGORIAS ---
  Future<void> insertSubCategory(SubCategoryModel subCategory) async {
    final db = await instance.database;
    await db.insert('subcategories', subCategory.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<SubCategoryModel>> getSubCategoriesByCategoryId(String categoryId) async {
    final db = await instance.database;
    final result = await db.query(
      'subcategories',
      where: 'categoryId = ?',
      whereArgs: [categoryId],
      orderBy: 'subCategoryName ASC',
    );
    return result.map((json) => SubCategoryModel.fromMap(json)).toList();
  }

  Future<int> updateSubCategory(SubCategoryModel subCategory) async {
    final db = await instance.database;
    return await db.update(
      'subcategories',
      subCategory.toMap(),
      where: 'idSubCategory = ?',
      whereArgs: [subCategory.idSubCategory],
    );
  }

  Future<int> deleteSubCategory(String idSubCategory) async {
    final db = await instance.database;
    return await db.delete('subcategories', where: 'idSubCategory = ?', whereArgs: [idSubCategory]);
  }

  // --- TRANSAÇÕES ---
  Future<void> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    await db.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((json) => TransactionModel.fromMap(json)).toList();
  }

  Future<int> deleteTransaction(String id) async {
    final db = await instance.database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }
}
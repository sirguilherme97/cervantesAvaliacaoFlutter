import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cadastro.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, fileName);
    print('📁 Caminho do banco de dados: $path'); // Adicione isso aqui

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela cadastro com numero como PRIMARY KEY
    await db.execute('''
      CREATE TABLE cadastro (
        nome TEXT NOT NULL,
        numero INTEGER PRIMARY KEY CHECK(numero > 0)
      );
    ''');

    // Tabela de log
    await db.execute('''
      CREATE TABLE log_operacoes (
        data_hora TEXT NOT NULL,
        operacao TEXT NOT NULL
      );
    ''');
  }

  Future<void> insertCadastro(String nome, int numero) async {
    final db = await database;

    await db.insert('cadastro', {'nome': nome, 'numero': numero});

    await db.insert('log_operacoes', {
      'data_hora': DateTime.now().toIso8601String(),
      'operacao': 'INSERT',
    });
  }

  Future<List<Map<String, dynamic>>> getCadastros() async {
    final db = await database;
    return await db.query('cadastro');
  }

  Future<void> updateCadastro(String nome, int numero) async {
    final db = await database;

    await db.update(
      'cadastro',
      {'nome': nome},
      where: 'numero = ?',
      whereArgs: [numero],
    );

    await db.insert('log_operacoes', {
      'data_hora': DateTime.now().toIso8601String(),
      'operacao': 'UPDATE',
    });
  }

  Future<void> deleteCadastro(int numero) async {
    final db = await database;

    await db.delete('cadastro', where: 'numero = ?', whereArgs: [numero]);

    await db.insert('log_operacoes', {
      'data_hora': DateTime.now().toIso8601String(),
      'operacao': 'DELETE',
    });
  }
}

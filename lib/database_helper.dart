import 'package:proyek_todolist/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper.internal();
  DatabaseHelper.internal();

  factory DatabaseHelper() => _instance;
  static Database? _db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  Future<Database> initDb() async {
    io.Directory docDirectory = await getApplicationDocumentsDirectory();
    String path = join(docDirectory.path, 'todolist.db');
    var localDb = await openDatabase(path, version: 1, onCreate: _onCreate);
    return localDb;
  }

  void _onCreate(Database db, int version) async {
    await db.execute('''
      create table if not exists todos(
        id integer primary key autoincrement,
        nama text not null,
        deskripsi text nit null,
        done integer not null default 0
      )''');
  }

  Future<List<Todo>> getAllTodos() async {
    var dbClient = await db;
    var todos = await dbClient!.query('todos');
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<List<Todo>> searchTodo(String keyword) async {
    var dbClient = await db;
    var todos = await dbClient!
        .query('todos', where: 'nama like ?', whereArgs: ['%$keyword%']);
    return todos.map((todo) => Todo.fromMap(todo)).toList();
  }

  Future<int> addTodo(Todo todo) async {
    var dbClient = await db;
    return await dbClient!.insert('todos', todo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTodo(Todo todo) async {
    var dbClient = await db;
    return await dbClient!
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deteleTodo(int id) async {
    var dbClient = await db;
    return await dbClient!.delete('todos', where: 'id = ?', whereArgs: [id]);
  }
}

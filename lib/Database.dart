import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'ApiService.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'blog_database.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE blogs(
        id TEXT PRIMARY KEY,
        imageUrl TEXT,
        title TEXT
      )
    ''');
  }

  Future<int> insertBlog(BlogItem blog) async {
    Database db = await instance.database;
    return await db.insert('blogs', blog.toMap());
  }

  Future<List<BlogItem>> getAllBlogs() async {
    Database db = await instance.database;

    List<Map<String, dynamic>> maps = await db.query('blogs');

    return List.generate(maps.length, (index) {
      return BlogItem(
        id: maps[index]['id'],
        imageUrl: maps[index]['imageUrl'],
        title: maps[index]['title'],
      );
    });
  }

  Future<int> deleteBlog(String blogId) async {
    Database db = await instance.database;
    return await db.delete(
      'blogs',
      where: 'id = ?',
      whereArgs: [blogId],
    );
  }

}

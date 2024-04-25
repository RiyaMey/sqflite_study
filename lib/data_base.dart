import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_study/word.dart';

class DBprovider {
  DBprovider._();
  static final DBprovider db = DBprovider._();
  bool _isCreate = false;
  static late Database _database;
    Future<Database> get database async {
      if (!_isCreate) {
        _database = await initDB();
        _isCreate = true;
      }

      return _database;
    }


  Future<Database> initDB() async {
      return await openDatabase(
        join(await getDatabasesPath(), 'words_database.db'),
        version: 1,              
        onOpen: (db) {},
        onCreate: (db, version) async {
          await db.execute(
            'CREATE TABLE Words (id INTEGER PRIMARY KEY, name TEXT, value TEXT)'
          );
        },
      );
    }

  Future<int> getNewId() async {
    final db = await database;

    var table = await db.rawQuery("SELECT MAX(id)+1 as id FROM Words");
    return (table.isNotEmpty && table.first['id'] != null) ? table.first['id'] as int : 0;
  }

  Future<void> addWord(Word word) async {
    final db = await database;

    await db.rawInsert(
      'INSERT Into Words (id,name,value) VALUES(?,?,?)',
      [word.id, word.name, word.value]
    );
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;

    var res = await db.query('Words');
    List<Word> list = res.isEmpty ? [] : res.toList().map((w) => Word.fromMap(w)).toList();
    return list;
  }

  Future<void> deleteAllWords() async {
    final db = await database;
    db.rawDelete('Delete from Words');
  }
}
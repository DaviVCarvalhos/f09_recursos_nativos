import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;

class DbUtil {
  static Future<sql.Database> openDatabaseConnection() async {
    final databasePath = await sql.getDatabasesPath();
    final pathToDatabase = path.join(databasePath, 'places.db');

    return sql.openDatabase(
      pathToDatabase,
      onCreate: (db, version) {
        // Criando a tabela com a nova estrutura
        return db.execute('''
        CREATE TABLE places (
          id TEXT PRIMARY KEY, 
          title TEXT, 
          image TEXT, 
          latitude REAL, 
          longitude REAL, 
          address TEXT, 
          phoneNumber TEXT, 
          email TEXT, 
          createdAt TEXT
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) {
        if (oldVersion < 2) {
          // Se a versão do banco for antiga, a tabela será recriada.
          db.execute('DROP TABLE IF EXISTS places');
          // Criando uma nova tabela com a estrutura atualizada
          db.execute('''
          CREATE TABLE places (
            id TEXT PRIMARY KEY, 
            title TEXT, 
            image TEXT, 
            latitude REAL, 
            longitude REAL, 
            address TEXT, 
            phoneNumber TEXT, 
            email TEXT, 
            createdAt TEXT
          )
          ''');
        }
      },
      version: 2, // Alterar a versão para 2
    );
  }

  static Future<void> insert(String table, Map<String, Object> data) async {
    final db = await DbUtil.openDatabaseConnection();
    await db.insert(
      table,
      data,
      conflictAlgorithm:
          sql.ConflictAlgorithm.replace, // Se já existir, substitui
    );
  }

  static Future<List<Map<String, dynamic>>> getData(String table) async {
    final db = await DbUtil.openDatabaseConnection();
    return db.query(table);
  }

  static Future<void> clearTable(String table) async {
    final db = await DbUtil.openDatabaseConnection();
    await db.delete(table);
  }
}

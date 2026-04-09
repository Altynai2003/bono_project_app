import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('orders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE orders (
  id $idType,
  userName $textType,
  modelName $textType,
  cutQuantity $integerType,
  color $textType,
  pieceQuantity $integerType,
  hardwareType $textType,
  shipmentQuantity $integerType,
  cutDate $textType,
  status $textType
  )
''');
  }

  // Жаңы буйрутма кошуу
  Future<int> insertOrder(OrderModel order) async {
    final db = await instance.database;
    return await db.insert('orders', order.toMap());
  }

  // Бардык буйрутмаларды алуу
  Future<List<OrderModel>> getAllOrders() async {
    final db = await instance.database;
    final maps = await db.query('orders', orderBy: 'id DESC');
    return maps.map((map) => OrderModel.fromMap(map)).toList();
  }

  // Буйрутманы жаңыртуу (мисалы статус өзгөрсө)
  Future<int> updateOrder(OrderModel order) async {
    final db = await instance.database;
    return db.update(
      'orders',
      order.toMap(),
      where: 'id = ?',
      whereArgs: [order.id],
    );
  }

  // Буйрутманы өчүрүү
  Future<int> deleteOrder(int id) async {
    final db = await instance.database;
    return await db.delete('orders', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

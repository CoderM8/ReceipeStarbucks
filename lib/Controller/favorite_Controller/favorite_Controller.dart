import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:starbucks/Controller/home_controller.dart';

class DatabaseHelper {
  static const _databaseName = "MyDatabase.db";
  static const _databaseVersion = 1;

  static const table = 'my_table';
  static const myItem = 'my_item';

  static const columnImage = 'image';
  static const columnName = 'name';
  static const columnInstruction = 'instruction';
  static const columnCat = 'category';

  static Database? _database;

  static Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }
    _database = await init();
    return _database;
  }

  static init() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);
    final db = await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
    print('Table create $path');
    return db;
  }

  static _onCreate(Database db, int version) async {
    await db.execute('CREATE TABLE $table (id INTEGER,$columnImage TEXT,$columnName TEXT,$columnInstruction TEXT,PRIMARY KEY(id AUTOINCREMENT))');
    await db.execute('CREATE TABLE $myItem (id INTEGER,$columnImage TEXT,$columnName TEXT,$columnInstruction TEXT,$columnCat TEXT,PRIMARY KEY(id AUTOINCREMENT))');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    final _db = await database;
    return await _db!.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    final _db = await database;
    return await _db!.query(table);
  }

  Future<int> queryRowCount() async {
    final _db = await database;
    final results = await _db!.rawQuery('SELECT COUNT(*) FROM $table');
    return Sqflite.firstIntValue(results) ?? 0;
  }

  Future<int> delete(int id) async {
    final _db = await database;
    return await _db!.delete(table, where: 'id =?', whereArgs: [id]);
  }

  Future<int> addItem(Map<String, dynamic> row) async {
    final _db = await database;
    return await _db!.insert(myItem, row);
  }

  Future<int> removeItem(int id) async {
    final _db = await database;
    return await _db!.delete(myItem, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map>> getAll() async {
    final _db = await database;
    return await _db!.query(myItem);
  }
}

class FavoriteController extends GetxController {
  HomeController _homeController = Get.put(HomeController());
  final RxList<Map<String, dynamic>> favData = <Map<String, dynamic>>[].obs;
  final RxList<int> favListId = <int>[].obs;

  Future<void> getFavListData() async {
    favData.clear();
    await _homeController.databaseHelper.queryAllRows().then(
      (list) {
        for (final value in list) {
          favData.add(value);
          favListId.add(value['id']);
        }
      },
    );
  }

  @override
  void onInit() {
    getFavListData();
    super.onInit();
  }
}

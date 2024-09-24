import 'dart:io';
import 'package:flutter_note_basket/models/category.dart';
import 'package:flutter_note_basket/models/notes.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';


class DatabaseHelper {

  static DatabaseHelper? _databaseHelper;
  static Database? _database;

  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper!;
    } else {
      return _databaseHelper!;
    }
  }
  
  DatabaseHelper._internal();

  Future<Database> _getDatabase() async{
    if(_database == null){
      _database = await _initializeDatabase();
      return _database!;
    } else {
      return _database!;
    }
  }
  
  Future<Database> _initializeDatabase() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "notlar.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notlar.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

    } else {
      print("Opening existing database");
    }
// open the database
    return await openDatabase(path, readOnly: false);
  }

  Future<List<Map<String, dynamic>>> getCategories() async{
    var db = await _getDatabase();
    var result = db.query("kategori");
    
    return result;
  }

  Future<List<Category>> getCategoryList() async{
    var mapListContainingCategories = await getCategories();
    var categoryList = <Category>[];
    for(Map<String, dynamic> map in mapListContainingCategories){
      categoryList.add(Category.fromMap(map));
    }
    return categoryList;
  }

  Future<int> addCategory(Category category) async{

    var db = await _getDatabase();
    var result = await db.insert("kategori", category.toMap());
    return result;

  }

  Future<int> updateCategory(Category category) async{

    var db = await _getDatabase();
    var result = await db.update("kategori", category.toMap(), where: 'kategoriID = ?', whereArgs: [category.kategoriID]);
    return result;

  }

  Future<int> deleteCategory(int categoryID) async{

    var db = await _getDatabase();
    var result = await db.delete("kategori", where: 'kategoriID = ?', whereArgs: [categoryID]);
    return result;

  }






  Future<List<Map<String, dynamic>>> getNotes() async{
    var db = await _getDatabase();
    var result = db.rawQuery('select * from "not" inner join kategori on kategori.kategoriID = "not".kategoriID order by notID Desc');
    
    return result;
  }

  Future<List<Notes>> getNoteList() async{
    var notesMapList = await getNotes();
    var notesList = <Notes>[];
    for(Map<String, dynamic> map in notesMapList){
      notesList.add(Notes.fromMap(map));
    }
    return notesList;
  }

  Future<int> addNote(Notes note) async{

    var db = await _getDatabase();
    var result = await db.insert("not", note.toMap());
    return result;

  }

  Future<int> updateNote(Notes note) async{

    var db = await _getDatabase();
    var result = await db.update("not", note.toMap(), where: 'notID = ?', whereArgs: [note.notID]);
    return result;

  }

  Future<int> deleteNote(int noteID) async{

    var db = await _getDatabase();
    var result = await db.delete("not", where: 'notID = ?', whereArgs: [noteID]);
    return result;

  }

  String dateFormat(DateTime tm){

    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String? month;
    switch (tm.month) {
      case 1:
        month = "Ocak";
        break;
      case 2:
        month = "Şubat";
        break;
      case 3:
        month = "Mart";
        break;
      case 4:
        month = "Nisan";
        break;
      case 5:
        month = "Mayıs";
        break;
      case 6:
        month = "Haziran";
        break;
      case 7:
        month = "Temmuz";
        break;
      case 8:
        month = "Ağustos";
        break;
      case 9:
        month = "Eylük";
        break;
      case 10:
        month = "Ekim";
        break;
      case 11:
        month = "Kasım";
        break;
      case 12:
        month = "Aralık";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Pazartesi";
        case 2:
          return "Salı";
        case 3:
          return "Çarşamba";
        case 4:
          return "Perşembe";
        case 5:
          return "Cuma";
        case 6:
          return "Cumartesi";
        case 7:
          return "Pazar";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";


  

  }


}
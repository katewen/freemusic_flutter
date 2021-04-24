import 'package:freemusic_flutter/musicModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DataManager {
  static final DataManager _manager = new DataManager.internal();

  factory DataManager() => _manager;

  static Database _database;

  DataManager.internal();

  Future<Database> get database async {
    if (_database != null) return _database;
    _database = await initDB();
    return _database;
  }

  initDB() async {
    var dataBasePath = await getDatabasesPath();
    String path = join(dataBasePath, 'xiangle.db');
    var db = await openDatabase(path, version: 1);
    return db;
  }

// @"create table %@(id INTEGER PRIMARY KEY AUTOINCREMENT,musicId TEXT,lyric_id TEXT,name TEXT,pic_id TEXT,url_id TEXT,source TEXT,album TEXT,artist TEXT)"
// @"INSERT INTO %@ (musicId,lyric_id,name,pic_id,url_id,source,album,artist) VALUES ('%@','%@','%@','%@','%@','%@','%@','%@')"
// @"DELETE FROM %@ where musicId='%@'"
// SELECT * FROM %@"
  void createTableWithName(String tablename) async {
    var db = await database;
    await db.execute(
        'create table $tablename(id INTEGER PRIMARY KEY AUTOINCREMENT,musicId TEXT,lyric_id TEXT,name TEXT,pic_id TEXT,url_id TEXT,source TEXT,album TEXT,artist TEXT)');
  }

  void insertModelToTable(MusicModel model, String tablename) async {
    int musicId = model.id;
    int lyricId = model.lyric_id;
    String picId = model.pic_id;
    int urlId = model.url_id;
    String name = model.name;
    String artistStr = '';
    String source = model.source;
    String album = model.album;
    for (var artist in model.artist) {
      artistStr = artistStr + artist + ',';
    }
    artistStr =
        artistStr.replaceRange(artistStr.length - 1, artistStr.length, '');

    var db = await database;
    List<Map> result =
        await db.query(tablename, where: 'musicId = ?', whereArgs: [musicId]);
    if (result.isEmpty) {
      // db.insert(tablename,
      // 'INSERT INTO $tablename (musicId,lyric_id,name,pic_id,url_id,source,album,artist) VALUES ($musicId,$lyricId,$name,$picId,$urlId,$source,$album,$artistStr)');
      db.insert(tablename, {
        'musicId': musicId,
        'lyric_id': lyricId,
        'name': name,
        'pic_id': picId,
        'url_id': urlId,
        'source': source,
        'album': album,
        'artist': artistStr
      });
      // db.rawInsert(
      // 'INSERT INTO $tablename (musicId,lyric_id,name,pic_id,url_id,source,album,artist) VALUES ($musicId,$lyricId,$name,$picId,$urlId,$source,$album,$artistStr)');
    }
  }

  void deleteModelFromTable(MusicModel model, String tableName) async {
    int musicId = model.id;
    var db = await database;
    db.execute('DELETE FROM %@ where musicId=$musicId');
  }

  Future<List> queryAllModelFromTable(String tableName) async {
    var db = await database;
    List resultList;
    List<MusicModel> modelList = [];
    resultList = await db.query(tableName);
    for (var model in resultList) {
      MusicModel musicModel = MusicModel.fromData(model);
      modelList.add(musicModel);
    }
    return modelList;
  }

// FMResultSet *result = [self.musicDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM sqlite_master where type='table' ORDER BY name"]];
  // while ([result next]) {
  //     if (![result.resultDictionary[@"name"] isEqualToString:@"sqlite_sequence"])
  //         [array addObject:result.resultDictionary];
  // }
  Future<List> queryAllTableFromDB() async {
    var db = await database;
    List tableList;
    tableList = await db
        .query('sqlite_master', where: 'type = ?', whereArgs: ['table']);
    for (var map in tableList) {
      if (map['name'] == 'sqlite_sequence') {
        tableList.remove(map);
      }
    }
    return tableList;
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class AppDB {
  static final AppDB _i = AppDB._();
  factory AppDB() => _i;
  AppDB._();
  static Database? _db;

  Future<Database> get db async => _db ??= await _init();

  Future<Database> _init() async {
    final p = join(await getDatabasesPath(), 'smart_transport_v2.db');
    return openDatabase(p, version: 1, onCreate: _create);
  }

  Future<void> _create(Database db, int v) async {
    await db.execute('''CREATE TABLE users(
      id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, email TEXT UNIQUE,
      password TEXT, phone TEXT DEFAULT '', role TEXT DEFAULT 'commuter',
      homeStop TEXT DEFAULT '', workStop TEXT DEFAULT '',
      createdAt TEXT, totalTrips INTEGER DEFAULT 0)''');

    await db.execute('''CREATE TABLE routes(
      id INTEGER PRIMARY KEY AUTOINCREMENT, routeNumber TEXT, routeName TEXT,
      startStop TEXT, endStop TEXT, stops TEXT, distanceKm INTEGER,
      durationMin INTEGER, fare REAL, status TEXT DEFAULT 'active',
      category TEXT DEFAULT 'local', freqPerHour INTEGER DEFAULT 4,
      colorIndex INTEGER DEFAULT 0, operatingHours TEXT DEFAULT '05:00-23:00')''');

    await db.execute('''CREATE TABLE buses(
      id INTEGER PRIMARY KEY AUTOINCREMENT, busNumber TEXT, model TEXT,
      driverName TEXT, driverPhone TEXT, currentStop TEXT, routeId INTEGER,
      capacity INTEGER DEFAULT 50, currentPassengers INTEGER DEFAULT 0,
      year INTEGER, status TEXT DEFAULT 'running', busType TEXT DEFAULT 'AC',
      fuelLevel REAL DEFAULT 80.0, updatedAt TEXT,
      FOREIGN KEY(routeId) REFERENCES routes(id))''');

    await db.execute('''CREATE TABLE schedules(
      id INTEGER PRIMARY KEY AUTOINCREMENT, routeId INTEGER, stopOrder INTEGER,
      stopName TEXT, arrivalTime TEXT, departureTime TEXT,
      dayType TEXT DEFAULT 'weekday', FOREIGN KEY(routeId) REFERENCES routes(id))''');

    await db.execute('''CREATE TABLE ridership(
      id INTEGER PRIMARY KEY AUTOINCREMENT, routeId INTEGER, busId INTEGER,
      boarded INTEGER DEFAULT 0, alighted INTEGER DEFAULT 0,
      stopName TEXT, dayType TEXT, timestamp TEXT)''');

    await db.execute('''CREATE TABLE complaints(
      id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER, routeId INTEGER,
      category TEXT, description TEXT, status TEXT DEFAULT 'pending',
      submittedAt TEXT, adminResponse TEXT,
      FOREIGN KEY(userId) REFERENCES users(id))''');

    await db.execute('''CREATE TABLE chat_history(
      id INTEGER PRIMARY KEY AUTOINCREMENT, userId INTEGER,
      userMsg TEXT, aiMsg TEXT, timestamp TEXT)''');
  }

  // ── USERS ──────────────────────────────────────────────────────────────────
  Future<int> insertUser(AppUser u) async =>
    (await db).insert('users', u.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<AppUser?> getUserByEmail(String email) async {
    final r = await (await db).query('users', where: 'email=?', whereArgs: [email]);
    return r.isEmpty ? null : AppUser.fromMap(r.first);
  }

  Future<AppUser?> getUserById(int id) async {
    final r = await (await db).query('users', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : AppUser.fromMap(r.first);
  }

  Future<void> updateUser(AppUser u) async =>
    (await db).update('users', u.toMap(), where: 'id=?', whereArgs: [u.id]);

  Future<List<AppUser>> getAllUsers() async =>
    ((await db).query('users', orderBy: 'createdAt DESC')).then((r) => r.map(AppUser.fromMap).toList());

  Future<int> commuterCount() async =>
    Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM users WHERE role="commuter"')) ?? 0;

  // ── ROUTES ─────────────────────────────────────────────────────────────────
  Future<int> insertRoute(BusRoute r) async =>
    (await db).insert('routes', r.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<BusRoute>> getAllRoutes() async =>
    ((await db).query('routes', orderBy: 'routeNumber ASC')).then((r) => r.map(BusRoute.fromMap).toList());

  Future<List<BusRoute>> getActiveRoutes() async =>
    ((await db).query('routes', where: 'status=?', whereArgs: ['active'], orderBy: 'routeNumber ASC'))
      .then((r) => r.map(BusRoute.fromMap).toList());

  Future<BusRoute?> getRouteById(int id) async {
    final r = await (await db).query('routes', where: 'id=?', whereArgs: [id]);
    return r.isEmpty ? null : BusRoute.fromMap(r.first);
  }

  Future<List<BusRoute>> searchRoutes(String q) async =>
    ((await db).query('routes', where: 'routeNumber LIKE ? OR routeName LIKE ? OR startStop LIKE ? OR endStop LIKE ? OR stops LIKE ?',
      whereArgs: List.filled(5, '%$q%'))).then((r) => r.map(BusRoute.fromMap).toList());

  Future<List<BusRoute>> findRoutesBetween(String from, String to) async =>
    ((await db).query('routes', where: 'stops LIKE ? AND stops LIKE ? AND status=?',
      whereArgs: ['%$from%', '%$to%', 'active'])).then((r) => r.map(BusRoute.fromMap).toList());

  Future<void> updateRoute(BusRoute r) async =>
    (await db).update('routes', r.toMap(), where: 'id=?', whereArgs: [r.id]);

  Future<void> deleteRoute(int id) async =>
    (await db).delete('routes', where: 'id=?', whereArgs: [id]);

  Future<int> activeRouteCount() async =>
    Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM routes WHERE status="active"')) ?? 0;

  // ── BUSES ──────────────────────────────────────────────────────────────────
  Future<int> insertBus(Bus b) async =>
    (await db).insert('buses', b.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Bus>> getAllBuses() async =>
    ((await db).query('buses', orderBy: 'busNumber ASC')).then((r) => r.map(Bus.fromMap).toList());

  Future<List<Bus>> getBusesByRoute(int routeId) async =>
    ((await db).query('buses', where: 'routeId=?', whereArgs: [routeId]))
      .then((r) => r.map(Bus.fromMap).toList());

  Future<void> updateBus(Bus b) async =>
    (await db).update('buses', b.toMap(), where: 'id=?', whereArgs: [b.id]);

  Future<void> deleteBus(int id) async =>
    (await db).delete('buses', where: 'id=?', whereArgs: [id]);

  Future<int> activeBusCount() async =>
    Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM buses WHERE status="running"')) ?? 0;

  Future<Map<String, int>> busStatusMap() async {
    final r = await (await db).rawQuery('SELECT status, COUNT(*) as c FROM buses GROUP BY status');
    return {for (final x in r) x['status'] as String: x['c'] as int};
  }

  // ── SCHEDULES ──────────────────────────────────────────────────────────────
  Future<int> insertSchedule(Schedule s) async =>
    (await db).insert('schedules', s.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

  Future<List<Schedule>> getSchedule(int routeId, String dayType) async =>
    ((await db).query('schedules', where: 'routeId=? AND dayType=?',
      whereArgs: [routeId, dayType], orderBy: 'stopOrder ASC'))
      .then((r) => r.map(Schedule.fromMap).toList());

  Future<List<Schedule>> getScheduleByStop(String stop) async =>
    ((await db).query('schedules', where: 'stopName LIKE ?', whereArgs: ['%$stop%'],
      orderBy: 'arrivalTime ASC')).then((r) => r.map(Schedule.fromMap).toList());

  // ── RIDERSHIP ──────────────────────────────────────────────────────────────
  Future<void> insertRidership(RidershipLog log) async =>
    (await db).insert('ridership', log.toMap());

  Future<int> totalRiders() async =>
    Sqflite.firstIntValue(await (await db).rawQuery('SELECT COALESCE(SUM(boarded),0) FROM ridership')) ?? 0;

  Future<List<Map<String, dynamic>>> hourlyRidership() async =>
    (await db).rawQuery('''SELECT CAST(substr(timestamp,12,2) AS INTEGER) as hr,
      SUM(boarded) as riders FROM ridership GROUP BY hr ORDER BY hr''');

  Future<List<Map<String, dynamic>>> weeklyRidership() async =>
    (await db).rawQuery('''SELECT substr(timestamp,1,10) as dt,
      SUM(boarded) as riders FROM ridership GROUP BY dt ORDER BY dt DESC LIMIT 7''');

  Future<List<Map<String, dynamic>>> ridershipByRoute() async =>
    (await db).rawQuery('''SELECT r.routeNumber, r.routeName, r.colorIndex,
      COALESCE(SUM(rl.boarded),0) as total FROM routes r
      LEFT JOIN ridership rl ON r.id=rl.routeId GROUP BY r.id ORDER BY total DESC''');

  // ── COMPLAINTS ─────────────────────────────────────────────────────────────
  Future<int> insertComplaint(Complaint c) async =>
    (await db).insert('complaints', c.toMap());

  Future<List<Complaint>> getAllComplaints() async =>
    ((await db).query('complaints', orderBy: 'submittedAt DESC'))
      .then((r) => r.map(Complaint.fromMap).toList());

  Future<List<Complaint>> getUserComplaints(int uid) async =>
    ((await db).query('complaints', where: 'userId=?', whereArgs: [uid],
      orderBy: 'submittedAt DESC')).then((r) => r.map(Complaint.fromMap).toList());

  Future<void> updateComplaint(int id, String status, {String? response}) async =>
    (await db).update('complaints', {'status': status, 'adminResponse': ?response},
      where: 'id=?', whereArgs: [id]);

  Future<int> pendingComplaintCount() async =>
    Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM complaints WHERE status="pending"')) ?? 0;

  Future<Map<String, int>> complaintStats() async {
    final r = await (await db).rawQuery('SELECT status, COUNT(*) as c FROM complaints GROUP BY status');
    return {for (final x in r) x['status'] as String: x['c'] as int};
  }

  // ── CHAT ───────────────────────────────────────────────────────────────────
  Future<void> saveChat(int uid, String userMsg, String aiMsg) async =>
    (await db).insert('chat_history', {
      'userId': uid, 'userMsg': userMsg, 'aiMsg': aiMsg,
      'timestamp': DateTime.now().toIso8601String()
    });

  // ── SEED CHECK ─────────────────────────────────────────────────────────────
  Future<bool> isSeeded() async =>
    (Sqflite.firstIntValue(await (await db).rawQuery('SELECT COUNT(*) FROM routes')) ?? 0) > 0;
}

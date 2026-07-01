import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class AppDB {
  static final AppDB _i = AppDB._();
  factory AppDB() => _i;
  AppDB._();

  static const _usersKey = 'smart_transport_users';
  static const _routesKey = 'smart_transport_routes';
  static const _busesKey = 'smart_transport_buses';
  static const _schedulesKey = 'smart_transport_schedules';
  static const _ridershipKey = 'smart_transport_ridership';
  static const _complaintsKey = 'smart_transport_complaints';
  static const _chatKey = 'smart_transport_chat_history';

  static const _userIdCounterKey = 'smart_transport_user_id_counter';
  static const _routeIdCounterKey = 'smart_transport_route_id_counter';
  static const _busIdCounterKey = 'smart_transport_bus_id_counter';
  static const _scheduleIdCounterKey = 'smart_transport_schedule_id_counter';
  static const _ridershipIdCounterKey = 'smart_transport_ridership_id_counter';
  static const _complaintIdCounterKey = 'smart_transport_complaint_id_counter';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> _load(String key) async {
    final prefs = await _prefs;
    final value = prefs.getString(key);
    if (value == null || value.isEmpty) return [];
    final list = jsonDecode(value);
    if (list is! List) return [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> _save(String key, List<Map<String, dynamic>> value) async {
    final prefs = await _prefs;
    await prefs.setString(key, jsonEncode(value));
  }

  Future<int> _nextId(String key) async {
    final prefs = await _prefs;
    final current = prefs.getInt(key) ?? 1;
    await prefs.setInt(key, current + 1);
    return current;
  }

  Future<List<Map<String, dynamic>>> _mutate(String key, List<Map<String, dynamic>> Function(List<Map<String, dynamic>>) mutate) async {
    final list = await _load(key);
    final updated = mutate(list);
    await _save(key, updated);
    return updated;
  }

  Future<int> insertUser(AppUser u) async {
    final users = await _load(_usersKey);
    final id = await _nextId(_userIdCounterKey);
    final user = {...u.toMap(), 'id': id};
    users.add(user);
    await _save(_usersKey, users);
    return id;
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final users = await _load(_usersKey);
    final found = users.firstWhere(
      (u) => (u['email'] as String).toLowerCase() == email.toLowerCase(),
      orElse: () => {},
    );
    return found.isEmpty ? null : AppUser.fromMap(found);
  }

  Future<AppUser?> getUserById(int id) async {
    final users = await _load(_usersKey);
    final found = users.firstWhere((u) => u['id'] == id, orElse: () => {});
    return found.isEmpty ? null : AppUser.fromMap(found);
  }

  Future<void> updateUser(AppUser u) async {
    final users = await _load(_usersKey);
    final index = users.indexWhere((item) => item['id'] == u.id);
    if (index != -1) {
      users[index] = u.toMap();
      await _save(_usersKey, users);
    }
  }

  Future<List<AppUser>> getAllUsers() async {
    final users = await _load(_usersKey);
    users.sort((a, b) => DateTime.parse(b['createdAt'] as String).compareTo(DateTime.parse(a['createdAt'] as String)));
    return users.map(AppUser.fromMap).toList();
  }

  Future<int> commuterCount() async {
    final users = await _load(_usersKey);
    return users.where((u) => (u['role'] as String) == 'commuter').length;
  }

  Future<int> insertRoute(BusRoute r) async {
    final routes = await _load(_routesKey);
    final id = await _nextId(_routeIdCounterKey);
    final route = {...r.toMap(), 'id': id};
    routes.add(route);
    await _save(_routesKey, routes);
    return id;
  }

  Future<List<BusRoute>> getAllRoutes() async {
    final routes = await _load(_routesKey);
    routes.sort((a, b) => (a['routeNumber'] as String).compareTo(b['routeNumber'] as String));
    return routes.map(BusRoute.fromMap).toList();
  }

  Future<List<BusRoute>> getActiveRoutes() async {
    final routes = await _load(_routesKey);
    return routes.where((r) => (r['status'] as String) == 'active').map(BusRoute.fromMap).toList();
  }

  Future<BusRoute?> getRouteById(int id) async {
    final routes = await _load(_routesKey);
    final found = routes.firstWhere((r) => r['id'] == id, orElse: () => {});
    return found.isEmpty ? null : BusRoute.fromMap(found);
  }

  Future<List<BusRoute>> searchRoutes(String q) async {
    final routes = await _load(_routesKey);
    final lower = q.toLowerCase();
    return routes.where((r) {
      final routeNumber = (r['routeNumber'] as String).toLowerCase();
      final routeName = (r['routeName'] as String).toLowerCase();
      final startStop = (r['startStop'] as String).toLowerCase();
      final endStop = (r['endStop'] as String).toLowerCase();
      final stops = (r['stops'] as String).toLowerCase();
      return routeNumber.contains(lower) || routeName.contains(lower) || startStop.contains(lower) || endStop.contains(lower) || stops.contains(lower);
    }).map(BusRoute.fromMap).toList();
  }

  Future<List<BusRoute>> findRoutesBetween(String from, String to) async {
    final routes = await _load(_routesKey);
    final a = from.toLowerCase();
    final b = to.toLowerCase();
    return routes.where((r) {
      final stops = (r['stops'] as String).toLowerCase();
      return stops.contains(a) && stops.contains(b) && (r['status'] as String) == 'active';
    }).map(BusRoute.fromMap).toList();
  }

  Future<void> updateRoute(BusRoute r) async {
    final routes = await _load(_routesKey);
    final index = routes.indexWhere((item) => item['id'] == r.id);
    if (index != -1) {
      routes[index] = r.toMap();
      await _save(_routesKey, routes);
    }
  }

  Future<void> deleteRoute(int id) async {
    final routes = await _load(_routesKey);
    routes.removeWhere((item) => item['id'] == id);
    await _save(_routesKey, routes);
  }

  Future<int> activeRouteCount() async {
    final routes = await _load(_routesKey);
    return routes.where((r) => (r['status'] as String) == 'active').length;
  }

  Future<int> insertBus(Bus b) async {
    final buses = await _load(_busesKey);
    final id = await _nextId(_busIdCounterKey);
    final bus = {...b.toMap(), 'id': id};
    buses.add(bus);
    await _save(_busesKey, buses);
    return id;
  }

  Future<List<Bus>> getAllBuses() async {
    final buses = await _load(_busesKey);
    buses.sort((a, b) => (a['busNumber'] as String).compareTo(b['busNumber'] as String));
    return buses.map(Bus.fromMap).toList();
  }

  Future<List<Bus>> getBusesByRoute(int routeId) async {
    final buses = await _load(_busesKey);
    return buses.where((b) => b['routeId'] == routeId).map(Bus.fromMap).toList();
  }

  Future<void> updateBus(Bus b) async {
    final buses = await _load(_busesKey);
    final index = buses.indexWhere((item) => item['id'] == b.id);
    if (index != -1) {
      buses[index] = b.toMap();
      await _save(_busesKey, buses);
    }
  }

  Future<void> deleteBus(int id) async {
    final buses = await _load(_busesKey);
    buses.removeWhere((item) => item['id'] == id);
    await _save(_busesKey, buses);
  }

  Future<int> activeBusCount() async {
    final buses = await _load(_busesKey);
    return buses.where((b) => (b['status'] as String) == 'running').length;
  }

  Future<Map<String, int>> busStatusMap() async {
    final buses = await _load(_busesKey);
    final map = <String, int>{};
    for (final b in buses) {
      final status = b['status'] as String;
      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  Future<int> insertSchedule(Schedule s) async {
    final schedules = await _load(_schedulesKey);
    final id = await _nextId(_scheduleIdCounterKey);
    final schedule = {...s.toMap(), 'id': id};
    schedules.add(schedule);
    await _save(_schedulesKey, schedules);
    return id;
  }

  Future<List<Schedule>> getSchedule(int routeId, String dayType) async {
    final schedules = await _load(_schedulesKey);
    final matches = schedules.where((s) => s['routeId'] == routeId && (s['dayType'] as String) == dayType).toList();
    matches.sort((a, b) => (a['stopOrder'] as int).compareTo(b['stopOrder'] as int));
    return matches.map(Schedule.fromMap).toList();
  }

  Future<List<Schedule>> getScheduleByStop(String stop) async {
    final schedules = await _load(_schedulesKey);
    final query = stop.toLowerCase();
    final matches = schedules.where((s) => (s['stopName'] as String).toLowerCase().contains(query)).toList();
    matches.sort((a, b) => (a['arrivalTime'] as String).compareTo(b['arrivalTime'] as String));
    return matches.map(Schedule.fromMap).toList();
  }

  Future<void> insertRidership(RidershipLog log) async {
    final ridership = await _load(_ridershipKey);
    final id = await _nextId(_ridershipIdCounterKey);
    final entry = {...log.toMap(), 'id': id};
    ridership.add(entry);
    await _save(_ridershipKey, ridership);
  }

  Future<int> totalRiders() async {
    final ridership = await _load(_ridershipKey);
    return ridership.fold<int>(0, (int sum, Map<String, dynamic> item) => sum + (item['boarded'] as int));
  }

  Future<List<Map<String, dynamic>>> hourlyRidership() async {
    final ridership = await _load(_ridershipKey);
    final map = <int, int>{};
    for (final r in ridership) {
      final timestamp = DateTime.parse(r['timestamp'] as String);
      final hour = timestamp.hour;
      map[hour] = (map[hour] ?? 0) + (r['boarded'] as int);
    }
    final list = map.entries.map((e) => {'hr': e.key, 'riders': e.value}).toList();
    list.sort((a, b) => (a['hr'] as int).compareTo(b['hr'] as int));
    return list;
  }

  Future<List<Map<String, dynamic>>> weeklyRidership() async {
    final ridership = await _load(_ridershipKey);
    final map = <String, int>{};
    for (final r in ridership) {
      final date = DateTime.parse(r['timestamp'] as String).toIso8601String().substring(0, 10);
      map[date] = (map[date] ?? 0) + (r['boarded'] as int);
    }
    final list = map.entries.map((e) => {'dt': e.key, 'riders': e.value}).toList();
    list.sort((a, b) => (b['dt'] as String).compareTo(a['dt'] as String));
    return list.take(7).toList();
  }

  Future<List<Map<String, dynamic>>> ridershipByRoute() async {
    final ridership = await _load(_ridershipKey);
    final routes = await _load(_routesKey);
    final totals = <int, int>{};
    for (final r in ridership) {
      final routeId = r['routeId'] as int;
      totals[routeId] = (totals[routeId] ?? 0) + (r['boarded'] as int);
    }
    final list = <Map<String, dynamic>>[];
    for (final route in routes) {
      final routeId = route['id'] as int;
      list.add({
        'routeNumber': route['routeNumber'],
        'routeName': route['routeName'],
        'colorIndex': route['colorIndex'] ?? 0,
        'total': totals[routeId] ?? 0,
      });
    }
    list.sort((a, b) => (b['total'] as int).compareTo(a['total'] as int));
    return list;
  }

  Future<int> insertComplaint(Complaint c) async {
    final complaints = await _load(_complaintsKey);
    final id = await _nextId(_complaintIdCounterKey);
    final complaint = {...c.toMap(), 'id': id};
    complaints.add(complaint);
    await _save(_complaintsKey, complaints);
    return id;
  }

  Future<List<Complaint>> getAllComplaints() async {
    final complaints = await _load(_complaintsKey);
    complaints.sort((a, b) => (b['submittedAt'] as String).compareTo(a['submittedAt'] as String));
    return complaints.map(Complaint.fromMap).toList();
  }

  Future<List<Complaint>> getUserComplaints(int uid) async {
    final complaints = await _load(_complaintsKey);
    final filtered = complaints.where((c) => c['userId'] == uid).toList();
    filtered.sort((a, b) => (b['submittedAt'] as String).compareTo(a['submittedAt'] as String));
    return filtered.map(Complaint.fromMap).toList();
  }

  Future<void> updateComplaint(int id, String status, {String? response}) async {
    final complaints = await _load(_complaintsKey);
    final index = complaints.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      final complaint = complaints[index];
      complaints[index] = {
        ...complaint,
        'status': status,
        'adminResponse': response,
      };
      await _save(_complaintsKey, complaints);
    }
  }

  Future<int> pendingComplaintCount() async {
    final complaints = await _load(_complaintsKey);
    return complaints.where((c) => (c['status'] as String) == 'pending').length;
  }

  Future<Map<String, int>> complaintStats() async {
    final complaints = await _load(_complaintsKey);
    final map = <String, int>{};
    for (final c in complaints) {
      final status = c['status'] as String;
      map[status] = (map[status] ?? 0) + 1;
    }
    return map;
  }

  Future<void> saveChat(int uid, String userMsg, String aiMsg) async {
    final chats = await _load(_chatKey);
    chats.add({'id': await _nextId('smart_transport_chat_id_counter'), 'userId': uid, 'userMsg': userMsg, 'aiMsg': aiMsg, 'timestamp': DateTime.now().toIso8601String()});
    await _save(_chatKey, chats);
  }

  Future<bool> isSeeded() async {
    final routes = await _load(_routesKey);
    return routes.isNotEmpty;
  }
}

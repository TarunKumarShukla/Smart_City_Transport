import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_db.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final _db = AppDB();
  AppUser? _user;
  bool _loading = false;
  String? _error;

  AppUser? get user => _user;
  bool get loading => _loading;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.role == 'admin';

  Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    final id = p.getInt('uid');
    if (id != null) { _user = await _db.getUserById(id); notifyListeners(); }
  }

  Future<bool> login(String email, String pw) async {
    _loading = true; _error = null; notifyListeners();
    final u = await _db.getUserByEmail(email.trim());
    if (u == null || u.password != pw) {
      _error = 'Invalid email or password'; _loading = false; notifyListeners(); return false;
    }
    _user = u;
    final p = await SharedPreferences.getInstance();
    await p.setInt('uid', u.id!);
    _loading = false; notifyListeners(); return true;
  }

  Future<bool> register({required String name, required String email,
    required String password, required String phone, required String role}) async {
    _loading = true; _error = null; notifyListeners();
    if (await _db.getUserByEmail(email.trim()) != null) {
      _error = 'Email already registered'; _loading = false; notifyListeners(); return false;
    }
    final id = await _db.insertUser(AppUser(name: name.trim(), email: email.trim(),
      password: password, phone: phone, role: role, createdAt: DateTime.now()));
    _user = await _db.getUserById(id);
    final p = await SharedPreferences.getInstance();
    await p.setInt('uid', id);
    _loading = false; notifyListeners(); return true;
  }

  Future<void> logout() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('uid');
    _user = null; notifyListeners();
  }

  Future<void> update(AppUser updated) async {
    await _db.updateUser(updated);
    _user = updated; notifyListeners();
  }

  void clearError() { _error = null; notifyListeners(); }
}

class TransportProvider extends ChangeNotifier {
  final _db = AppDB();
  List<BusRoute> _routes = [];
  List<Bus> _buses = [];
  List<Complaint> _complaints = [];
  bool _loading = false;
  int _activeRoutes = 0, _activeBuses = 0, _totalRiders = 0, _pendingComplaints = 0;
  List<Map<String, dynamic>> _hourly = [], _weekly = [], _byRoute = [];
  Map<String, int> _busStatus = {};
  String _routeSearch = '';

  List<BusRoute> get routes => _routeSearch.isEmpty
    ? _routes
    : _routes.where((r) =>
        r.routeNumber.toLowerCase().contains(_routeSearch.toLowerCase()) ||
        r.routeName.toLowerCase().contains(_routeSearch.toLowerCase()) ||
        r.startStop.toLowerCase().contains(_routeSearch.toLowerCase()) ||
        r.endStop.toLowerCase().contains(_routeSearch.toLowerCase())).toList();
  List<Bus> get buses => _buses;
  List<Complaint> get complaints => _complaints;
  bool get loading => _loading;
  int get activeRoutes => _activeRoutes;
  int get activeBuses => _activeBuses;
  int get totalRiders => _totalRiders;
  int get pendingComplaints => _pendingComplaints;
  List<Map<String, dynamic>> get hourly => _hourly;
  List<Map<String, dynamic>> get weekly => _weekly;
  List<Map<String, dynamic>> get byRoute => _byRoute;
  Map<String, int> get busStatus => _busStatus;

  void setSearch(String q) { _routeSearch = q; notifyListeners(); }

  Future<void> loadAll() async {
    _loading = true; notifyListeners();
    await Future.wait([_loadRoutes(), _loadBuses(), _loadAnalytics()]);
    _loading = false; notifyListeners();
  }

  Future<void> _loadRoutes() async {
    _routes = await _db.getAllRoutes();
    _activeRoutes = await _db.activeRouteCount();
  }
  Future<void> _loadBuses() async {
    _buses = await _db.getAllBuses();
    _activeBuses = await _db.activeBusCount();
    _busStatus = await _db.busStatusMap();
  }
  Future<void> _loadAnalytics() async {
    _totalRiders = await _db.totalRiders();
    _pendingComplaints = await _db.pendingComplaintCount();
    _hourly = await _db.hourlyRidership();
    _weekly = await _db.weeklyRidership();
    _byRoute = await _db.ridershipByRoute();
  }
  Future<void> loadComplaints() async {
    _complaints = await _db.getAllComplaints();
    _pendingComplaints = _complaints.where((c) => c.status == 'pending').length;
    notifyListeners();
  }

  Future<List<Schedule>> getSchedule(int routeId, String dayType) => _db.getSchedule(routeId, dayType);
  Future<List<BusRoute>> search(String q) => _db.searchRoutes(q);
  Future<List<BusRoute>> findBetween(String a, String b) => _db.findRoutesBetween(a, b);
  Future<List<Bus>> routeBuses(int routeId) => _db.getBusesByRoute(routeId);
  Future<List<Complaint>> userComplaints(int uid) => _db.getUserComplaints(uid);
  Future<List<AppUser>> allUsers() => _db.getAllUsers();
  Future<int> userCount() => _db.commuterCount();

  Future<void> addRoute(BusRoute r) async { await _db.insertRoute(r); await _loadRoutes(); notifyListeners(); }
  Future<void> updateRoute(BusRoute r) async { await _db.updateRoute(r); await _loadRoutes(); notifyListeners(); }
  Future<void> deleteRoute(int id) async { await _db.deleteRoute(id); await _loadRoutes(); notifyListeners(); }

  Future<void> addBus(Bus b) async { await _db.insertBus(b); await _loadBuses(); notifyListeners(); }
  Future<void> updateBus(Bus b) async { await _db.updateBus(b); await _loadBuses(); notifyListeners(); }
  Future<void> deleteBus(int id) async { await _db.deleteBus(id); await _loadBuses(); notifyListeners(); }

  Future<void> addComplaint(Complaint c) async { await _db.insertComplaint(c); await loadComplaints(); }
  Future<void> resolveComplaint(int id, String status, {String? response}) async {
    await _db.updateComplaint(id, status, response: response);
    await loadComplaints();
  }

  Future<void> addSchedule(Schedule s) => _db.insertSchedule(s);
}

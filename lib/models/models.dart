// Models for Smart City Transport

class AppUser {
  final int? id;
  final String name, email, password, phone, role;
  final String homeStop, workStop;
  final DateTime createdAt;
  final int totalTrips;

  AppUser({this.id, required this.name, required this.email,
    required this.password, this.phone = '', required this.role,
    this.homeStop = '', this.workStop = '',
    required this.createdAt, this.totalTrips = 0});

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email, 'password': password,
    'phone': phone, 'role': role, 'homeStop': homeStop, 'workStop': workStop,
    'createdAt': createdAt.toIso8601String(), 'totalTrips': totalTrips,
  };

  factory AppUser.fromMap(Map<String, dynamic> m) => AppUser(
    id: m['id'], name: m['name'], email: m['email'], password: m['password'],
    phone: m['phone'] ?? '', role: m['role'],
    homeStop: m['homeStop'] ?? '', workStop: m['workStop'] ?? '',
    createdAt: DateTime.parse(m['createdAt']), totalTrips: m['totalTrips'] ?? 0,
  );

  AppUser copyWith({String? name, String? email, String? phone,
    String? homeStop, String? workStop, int? totalTrips}) => AppUser(
    id: id, name: name ?? this.name, email: email ?? this.email,
    password: password, phone: phone ?? this.phone, role: role,
    homeStop: homeStop ?? this.homeStop, workStop: workStop ?? this.workStop,
    createdAt: createdAt, totalTrips: totalTrips ?? this.totalTrips,
  );
}

class BusRoute {
  final int? id;
  final String routeNumber, routeName, startStop, endStop;
  final List<String> stops;
  final int distanceKm, durationMin;
  final double fare;
  final String status; // active, inactive, maintenance
  final String category; // local, express, feeder, circular
  final int freqPerHour, colorIndex;
  final String operatingHours;

  BusRoute({this.id, required this.routeNumber, required this.routeName,
    required this.startStop, required this.endStop, required this.stops,
    required this.distanceKm, required this.durationMin, required this.fare,
    required this.status, required this.category, required this.freqPerHour,
    required this.colorIndex, required this.operatingHours});

  Map<String, dynamic> toMap() => {
    'id': id, 'routeNumber': routeNumber, 'routeName': routeName,
    'startStop': startStop, 'endStop': endStop, 'stops': stops.join('||'),
    'distanceKm': distanceKm, 'durationMin': durationMin, 'fare': fare,
    'status': status, 'category': category, 'freqPerHour': freqPerHour,
    'colorIndex': colorIndex, 'operatingHours': operatingHours,
  };

  factory BusRoute.fromMap(Map<String, dynamic> m) => BusRoute(
    id: m['id'], routeNumber: m['routeNumber'], routeName: m['routeName'],
    startStop: m['startStop'], endStop: m['endStop'],
    stops: (m['stops'] as String).split('||'),
    distanceKm: m['distanceKm'], durationMin: m['durationMin'],
    fare: (m['fare'] as num).toDouble(), status: m['status'],
    category: m['category'], freqPerHour: m['freqPerHour'],
    colorIndex: m['colorIndex'] ?? 0, operatingHours: m['operatingHours'],
  );

  BusRoute copyWith({String? routeNumber, String? routeName, String? startStop,
    String? endStop, List<String>? stops, int? distanceKm, int? durationMin,
    double? fare, String? status, String? category, int? freqPerHour,
    int? colorIndex, String? operatingHours}) => BusRoute(
    id: id, routeNumber: routeNumber ?? this.routeNumber,
    routeName: routeName ?? this.routeName, startStop: startStop ?? this.startStop,
    endStop: endStop ?? this.endStop, stops: stops ?? this.stops,
    distanceKm: distanceKm ?? this.distanceKm, durationMin: durationMin ?? this.durationMin,
    fare: fare ?? this.fare, status: status ?? this.status,
    category: category ?? this.category, freqPerHour: freqPerHour ?? this.freqPerHour,
    colorIndex: colorIndex ?? this.colorIndex, operatingHours: operatingHours ?? this.operatingHours,
  );
}

class Bus {
  final int? id;
  final String busNumber, model, driverName, driverPhone, currentStop;
  final int routeId, capacity, currentPassengers, year;
  final String status; // running, parked, maintenance, out_of_service
  final String busType; // AC, Non-AC, Electric, Mini
  final double fuelLevel;
  final DateTime updatedAt;

  Bus({this.id, required this.busNumber, required this.model,
    required this.driverName, required this.driverPhone, required this.currentStop,
    required this.routeId, required this.capacity, this.currentPassengers = 0,
    required this.year, required this.status, required this.busType,
    required this.fuelLevel, required this.updatedAt});

  double get occupancy => capacity > 0 ? (currentPassengers / capacity) * 100 : 0;
  bool get isCrowded => occupancy > 80;

  Map<String, dynamic> toMap() => {
    'id': id, 'busNumber': busNumber, 'model': model, 'driverName': driverName,
    'driverPhone': driverPhone, 'currentStop': currentStop, 'routeId': routeId,
    'capacity': capacity, 'currentPassengers': currentPassengers, 'year': year,
    'status': status, 'busType': busType, 'fuelLevel': fuelLevel,
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Bus.fromMap(Map<String, dynamic> m) => Bus(
    id: m['id'], busNumber: m['busNumber'], model: m['model'],
    driverName: m['driverName'], driverPhone: m['driverPhone'],
    currentStop: m['currentStop'], routeId: m['routeId'],
    capacity: m['capacity'], currentPassengers: m['currentPassengers'] ?? 0,
    year: m['year'], status: m['status'], busType: m['busType'],
    fuelLevel: (m['fuelLevel'] as num).toDouble(),
    updatedAt: DateTime.parse(m['updatedAt']),
  );

  Bus copyWith({String? busNumber, String? model, String? driverName, String? driverPhone,
    String? currentStop, int? routeId, int? capacity, int? currentPassengers,
    int? year, String? status, String? busType, double? fuelLevel}) => Bus(
    id: id, busNumber: busNumber ?? this.busNumber, model: model ?? this.model,
    driverName: driverName ?? this.driverName, driverPhone: driverPhone ?? this.driverPhone,
    currentStop: currentStop ?? this.currentStop, routeId: routeId ?? this.routeId,
    capacity: capacity ?? this.capacity, currentPassengers: currentPassengers ?? this.currentPassengers,
    year: year ?? this.year, status: status ?? this.status, busType: busType ?? this.busType,
    fuelLevel: fuelLevel ?? this.fuelLevel, updatedAt: DateTime.now(),
  );
}

class Schedule {
  final int? id;
  final int routeId, stopOrder;
  final String stopName, arrivalTime, departureTime, dayType;

  Schedule({this.id, required this.routeId, required this.stopOrder,
    required this.stopName, required this.arrivalTime, required this.departureTime,
    required this.dayType});

  Map<String, dynamic> toMap() => {
    'id': id, 'routeId': routeId, 'stopOrder': stopOrder,
    'stopName': stopName, 'arrivalTime': arrivalTime,
    'departureTime': departureTime, 'dayType': dayType,
  };

  factory Schedule.fromMap(Map<String, dynamic> m) => Schedule(
    id: m['id'], routeId: m['routeId'], stopOrder: m['stopOrder'],
    stopName: m['stopName'], arrivalTime: m['arrivalTime'],
    departureTime: m['departureTime'], dayType: m['dayType'],
  );
}

class RidershipLog {
  final int? id;
  final int routeId, busId, boarded, alighted;
  final String stopName, dayType;
  final DateTime timestamp;

  RidershipLog({this.id, required this.routeId, required this.busId,
    required this.boarded, required this.alighted, required this.stopName,
    required this.dayType, required this.timestamp});

  Map<String, dynamic> toMap() => {
    'id': id, 'routeId': routeId, 'busId': busId, 'boarded': boarded,
    'alighted': alighted, 'stopName': stopName, 'dayType': dayType,
    'timestamp': timestamp.toIso8601String(),
  };

  factory RidershipLog.fromMap(Map<String, dynamic> m) => RidershipLog(
    id: m['id'], routeId: m['routeId'], busId: m['busId'],
    boarded: m['boarded'], alighted: m['alighted'], stopName: m['stopName'],
    dayType: m['dayType'], timestamp: DateTime.parse(m['timestamp']),
  );
}

class Complaint {
  final int? id;
  final int userId;
  final int? routeId;
  final String category, description, status;
  final DateTime submittedAt;
  final String? adminResponse;

  Complaint({this.id, required this.userId, this.routeId,
    required this.category, required this.description,
    this.status = 'pending', required this.submittedAt, this.adminResponse});

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'routeId': routeId, 'category': category,
    'description': description, 'status': status,
    'submittedAt': submittedAt.toIso8601String(), 'adminResponse': adminResponse,
  };

  factory Complaint.fromMap(Map<String, dynamic> m) => Complaint(
    id: m['id'], userId: m['userId'], routeId: m['routeId'],
    category: m['category'], description: m['description'], status: m['status'],
    submittedAt: DateTime.parse(m['submittedAt']), adminResponse: m['adminResponse'],
  );
}

class ChatMessage {
  final String id, content;
  final bool isUser, isLoading;
  final DateTime timestamp;

  ChatMessage({required this.id, required this.content, required this.isUser,
    this.isLoading = false, required this.timestamp});
}

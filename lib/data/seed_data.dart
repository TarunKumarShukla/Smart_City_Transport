import '../database/app_db.dart';
import '../models/models.dart';

class SeedData {
  static final _db = AppDB();

  static Future<void> seed() async {
    await _users();
    if (await _db.isSeeded()) return;
    await _routes();
    await _buses();
    await _schedules();
    await _ridership();
    await _complaints();
  }

  static Future<void> _users() async {
    if (await _db.getUserByEmail('admin@transit.gov') == null) {
      await _db.insertUser(
        AppUser(
          name: 'City Transport Admin',
          email: 'admin@transit.gov',
          password: 'admin123',
          phone: '9800000001',
          role: 'admin',
          createdAt: DateTime.now(),
        ),
      );
    }
    if (await _db.getUserByEmail('priya@gmail.com') == null) {
      await _db.insertUser(
        AppUser(
          name: 'Priya Sharma',
          email: 'priya@gmail.com',
          password: 'pass123',
          phone: '9800000002',
          role: 'commuter',
          homeStop: 'Gandhipuram Central',
          workStop: 'Tidel Park IT Zone',
          createdAt: DateTime.now(),
          totalTrips: 47,
        ),
      );
    }
    if (await _db.getUserByEmail('arjun@gmail.com') == null) {
      await _db.insertUser(
        AppUser(
          name: 'Arjun Patel',
          email: 'arjun@gmail.com',
          password: 'pass123',
          phone: '9800000003',
          role: 'commuter',
          homeStop: 'Coimbatore Airport',
          workStop: 'RS Puram Terminal',
          createdAt: DateTime.now(),
          totalTrips: 23,
        ),
      );
    }
  }

  static Future<void> _routes() async {
    final routes = [
      BusRoute(
        routeNumber: '1A',
        routeName: 'Gandhipuram Express',
        startStop: 'Gandhipuram Central',
        endStop: 'RS Puram Terminal',
        stops: [
          'Gandhipuram Central',
          'Town Hall',
          'Clock Tower',
          'Collectorate',
          'Nehru Stadium',
          'Peelamedu',
          'Avinashi Road',
          'RS Puram Terminal',
        ],
        distanceKm: 14,
        durationMin: 40,
        fare: 14,
        status: 'active',
        category: 'express',
        freqPerHour: 6,
        colorIndex: 0,
        operatingHours: '05:00-23:00',
      ),
      BusRoute(
        routeNumber: '2B',
        routeName: 'Airport Shuttle',
        startStop: 'Coimbatore Airport',
        endStop: 'Ukkadam Bus Stand',
        stops: [
          'Coimbatore Airport',
          'Peelamedu',
          'Hopes College',
          'Sai Baba Colony',
          'Gandhipuram Central',
          'DB Road',
          'Town Hall',
          'Ukkadam Bus Stand',
        ],
        distanceKm: 20,
        durationMin: 55,
        fare: 20,
        status: 'active',
        category: 'express',
        freqPerHour: 4,
        colorIndex: 1,
        operatingHours: '04:30-23:30',
      ),
      BusRoute(
        routeNumber: '3C',
        routeName: 'Singanallur–Podanur Local',
        startStop: 'Singanallur',
        endStop: 'Podanur Junction',
        stops: [
          'Singanallur',
          'Saravanampatti',
          'Kalapatti',
          'Kavundampalayam',
          'Ganapathy',
          'Gandhipuram Central',
          'Peelamedu',
          'Vellalore',
          'Podanur Junction',
        ],
        distanceKm: 25,
        durationMin: 70,
        fare: 16,
        status: 'active',
        category: 'local',
        freqPerHour: 3,
        colorIndex: 2,
        operatingHours: '06:00-22:00',
      ),
      BusRoute(
        routeNumber: '4D',
        routeName: 'Tidel Park IT Feeder',
        startStop: 'Tidel Park IT Zone',
        endStop: 'Coimbatore Junction',
        stops: [
          'Tidel Park IT Zone',
          'HPCL Junction',
          'Hopes College',
          'Ganapathy',
          'Cross Cut Road',
          'Town Hall',
          'Oppanakara Street',
          'Coimbatore Junction',
        ],
        distanceKm: 12,
        durationMin: 35,
        fare: 12,
        status: 'active',
        category: 'feeder',
        freqPerHour: 5,
        colorIndex: 3,
        operatingHours: '07:00-22:00',
      ),
      BusRoute(
        routeNumber: '5E',
        routeName: 'Heritage Circular City Loop',
        startStop: 'Gandhipuram Central',
        endStop: 'Gandhipuram Central',
        stops: [
          'Gandhipuram Central',
          'Town Hall',
          'Clock Tower',
          'Katcheri Road',
          'Wheat House',
          'Municipal Office',
          'Cross Cut Road',
          'Gandhipuram Central',
        ],
        distanceKm: 10,
        durationMin: 30,
        fare: 10,
        status: 'active',
        category: 'circular',
        freqPerHour: 8,
        colorIndex: 4,
        operatingHours: '06:00-21:00',
      ),
      BusRoute(
        routeNumber: '6F',
        routeName: 'TNAU–Railway Junction',
        startStop: 'TNAU Campus Gate',
        endStop: 'Coimbatore Junction',
        stops: [
          'TNAU Campus Gate',
          'Agricultural College',
          'SNR Sons College',
          'DB Road',
          'Town Hall',
          'Oppanakara Street',
          'Coimbatore Junction',
        ],
        distanceKm: 9,
        durationMin: 28,
        fare: 10,
        status: 'active',
        category: 'local',
        freqPerHour: 4,
        colorIndex: 5,
        operatingHours: '06:00-22:30',
      ),
      BusRoute(
        routeNumber: '7G',
        routeName: 'Mettupalayam Road Feeder',
        startStop: 'Mettupalayam Road',
        endStop: 'Gandhipuram Central',
        stops: [
          'Mettupalayam Road',
          'Velandipalayam',
          'Kovaipudur',
          'Race Course',
          'Ukkadam Bus Stand',
          'Gandhipuram Central',
        ],
        distanceKm: 18,
        durationMin: 48,
        fare: 18,
        status: 'maintenance',
        category: 'feeder',
        freqPerHour: 3,
        colorIndex: 0,
        operatingHours: '06:00-21:00',
      ),
      BusRoute(
        routeNumber: '8N',
        routeName: 'Saravanampatti Night Express',
        startStop: 'Saravanampatti',
        endStop: 'Ukkadam Bus Stand',
        stops: [
          'Saravanampatti',
          'Kalapatti',
          'Kavundampalayam',
          'Ganapathy',
          'Gandhipuram Central',
          'Town Hall',
          'Ukkadam Bus Stand',
        ],
        distanceKm: 22,
        durationMin: 58,
        fare: 22,
        status: 'active',
        category: 'local',
        freqPerHour: 2,
        colorIndex: 1,
        operatingHours: '21:00-05:00',
      ),
      BusRoute(
        routeNumber: '9X',
        routeName: 'RS Puram–Race Course Express',
        startStop: 'RS Puram Terminal',
        endStop: 'Race Course',
        stops: [
          'RS Puram Terminal',
          'Avinashi Road',
          'Peelamedu',
          'HPCL Junction',
          'Sai Baba Colony',
          'Race Course',
        ],
        distanceKm: 11,
        durationMin: 32,
        fare: 12,
        status: 'active',
        category: 'express',
        freqPerHour: 5,
        colorIndex: 2,
        operatingHours: '05:30-23:00',
      ),
      BusRoute(
        routeNumber: '10M',
        routeName: 'IT Corridor–City Center Mini',
        startStop: 'Saravanampatti',
        endStop: 'Coimbatore Junction',
        stops: [
          'Saravanampatti',
          'Kalapatti',
          'Tidel Park IT Zone',
          'HPCL Junction',
          'Peelamedu',
          'Gandhipuram Central',
          'Coimbatore Junction',
        ],
        distanceKm: 16,
        durationMin: 45,
        fare: 15,
        status: 'active',
        category: 'local',
        freqPerHour: 4,
        colorIndex: 3,
        operatingHours: '06:30-22:30',
      ),
    ];
    for (final r in routes) {
      await _db.insertRoute(r);
    }
  }

  static Future<void> _buses() async {
    final buses = [
      Bus(
        busNumber: 'CBE-001',
        model: 'Volvo 9400',
        driverName: 'Murugan K',
        driverPhone: '9800001001',
        currentStop: 'Town Hall',
        routeId: 1,
        capacity: 45,
        currentPassengers: 38,
        year: 2022,
        status: 'running',
        busType: 'AC',
        fuelLevel: 72,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-002',
        model: 'Ashok Leyland 12M',
        driverName: 'Selvam R',
        driverPhone: '9800001002',
        currentStop: 'Peelamedu',
        routeId: 1,
        capacity: 60,
        currentPassengers: 55,
        year: 2021,
        status: 'running',
        busType: 'Non-AC',
        fuelLevel: 55,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-003',
        model: 'Tata Starbus CNG',
        driverName: 'Suresh P',
        driverPhone: '9800001003',
        currentStop: 'Coimbatore Airport',
        routeId: 2,
        capacity: 50,
        currentPassengers: 20,
        year: 2023,
        status: 'running',
        busType: 'AC',
        fuelLevel: 90,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-004',
        model: 'BYD K9 Electric',
        driverName: 'Ganesh L',
        driverPhone: '9800001004',
        currentStop: 'Ukkadam Bus Stand',
        routeId: 2,
        capacity: 50,
        currentPassengers: 0,
        year: 2024,
        status: 'parked',
        busType: 'Electric',
        fuelLevel: 88,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-005',
        model: 'Tata Starbus',
        driverName: 'Arumugam V',
        driverPhone: '9800001005',
        currentStop: 'Kavundampalayam',
        routeId: 3,
        capacity: 55,
        currentPassengers: 52,
        year: 2020,
        status: 'running',
        busType: 'Non-AC',
        fuelLevel: 48,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-006',
        model: 'Ashok Leyland CNG',
        driverName: 'Ravi T',
        driverPhone: '9800001006',
        currentStop: 'Depot-1',
        routeId: 3,
        capacity: 55,
        currentPassengers: 0,
        year: 2019,
        status: 'maintenance',
        busType: 'Non-AC',
        fuelLevel: 22,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-007',
        model: 'Olectra Electric',
        driverName: 'Pradeep M',
        driverPhone: '9800001007',
        currentStop: 'Hopes College',
        routeId: 4,
        capacity: 50,
        currentPassengers: 35,
        year: 2024,
        status: 'running',
        busType: 'Electric',
        fuelLevel: 80,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-008',
        model: 'BYD K7 Electric',
        driverName: 'Karthi S',
        driverPhone: '9800001008',
        currentStop: 'Ganapathy',
        routeId: 4,
        capacity: 50,
        currentPassengers: 28,
        year: 2024,
        status: 'running',
        busType: 'Electric',
        fuelLevel: 65,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-009',
        model: 'Mini Bus 6M',
        driverName: 'Dinesh B',
        driverPhone: '9800001009',
        currentStop: 'Clock Tower',
        routeId: 5,
        capacity: 30,
        currentPassengers: 24,
        year: 2022,
        status: 'running',
        busType: 'Mini',
        fuelLevel: 60,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-010',
        model: 'Ashok Leyland U',
        driverName: 'Vijay C',
        driverPhone: '9800001010',
        currentStop: 'DB Road',
        routeId: 6,
        capacity: 55,
        currentPassengers: 45,
        year: 2021,
        status: 'running',
        busType: 'Non-AC',
        fuelLevel: 50,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-011',
        model: 'Tata Ultra Electric',
        driverName: 'Srinivasan N',
        driverPhone: '9800001011',
        currentStop: 'Race Course',
        routeId: 9,
        capacity: 50,
        currentPassengers: 32,
        year: 2023,
        status: 'running',
        busType: 'Electric',
        fuelLevel: 77,
        updatedAt: DateTime.now(),
      ),
      Bus(
        busNumber: 'CBE-012',
        model: 'Ashok Leyland Lynx',
        driverName: 'Anbu K',
        driverPhone: '9800001012',
        currentStop: 'Tidel Park IT Zone',
        routeId: 10,
        capacity: 55,
        currentPassengers: 0,
        year: 2022,
        status: 'out_of_service',
        busType: 'AC',
        fuelLevel: 15,
        updatedAt: DateTime.now(),
      ),
    ];
    for (final b in buses) {
      await _db.insertBus(b);
    }
  }

  static Future<void> _schedules() async {
    // Route 1A schedules
    final s1 = [
      ['Gandhipuram Central', '05:00', '05:02'],
      ['Town Hall', '05:08', '05:09'],
      ['Clock Tower', '05:13', '05:14'],
      ['Collectorate', '05:18', '05:19'],
      ['Nehru Stadium', '05:23', '05:24'],
      ['Peelamedu', '05:30', '05:31'],
      ['Avinashi Road', '05:36', '05:37'],
      ['RS Puram Terminal', '05:40', '05:40'],
    ];
    for (int i = 0; i < s1.length; i++) {
      await _db.insertSchedule(
        Schedule(
          routeId: 1,
          stopOrder: i + 1,
          stopName: s1[i][0],
          arrivalTime: s1[i][1],
          departureTime: s1[i][2],
          dayType: 'weekday',
        ),
      );
      // Peak hour
      final arr = _addMinutes(s1[i][1], 180);
      await _db.insertSchedule(
        Schedule(
          routeId: 1,
          stopOrder: i + 1,
          stopName: s1[i][0],
          arrivalTime: arr,
          departureTime: _addMinutes(s1[i][2], 180),
          dayType: 'weekday',
        ),
      );
    }
    // Route 2B schedules
    final s2 = [
      ['Coimbatore Airport', '05:30', '05:32'],
      ['Peelamedu', '05:42', '05:43'],
      ['Hopes College', '05:50', '05:51'],
      ['Sai Baba Colony', '05:58', '05:59'],
      ['Gandhipuram Central', '06:08', '06:10'],
      ['DB Road', '06:18', '06:19'],
      ['Town Hall', '06:24', '06:25'],
      ['Ukkadam Bus Stand', '06:30', '06:30'],
    ];
    for (int i = 0; i < s2.length; i++) {
      await _db.insertSchedule(
        Schedule(
          routeId: 2,
          stopOrder: i + 1,
          stopName: s2[i][0],
          arrivalTime: s2[i][1],
          departureTime: s2[i][2],
          dayType: 'weekday',
        ),
      );
    }
    // Route 5E (circular - frequent)
    final s5 = [
      ['Gandhipuram Central', '06:00', '06:01'],
      ['Town Hall', '06:05', '06:06'],
      ['Clock Tower', '06:10', '06:11'],
      ['Katcheri Road', '06:15', '06:16'],
      ['Wheat House', '06:20', '06:21'],
      ['Municipal Office', '06:25', '06:26'],
      ['Cross Cut Road', '06:30', '06:31'],
      ['Gandhipuram Central', '06:35', '06:35'],
    ];
    for (int i = 0; i < s5.length; i++) {
      await _db.insertSchedule(
        Schedule(
          routeId: 5,
          stopOrder: i + 1,
          stopName: s5[i][0],
          arrivalTime: s5[i][1],
          departureTime: s5[i][2],
          dayType: 'weekday',
        ),
      );
    }
  }

  static String _addMinutes(String time, int mins) {
    final parts = time.split(':');
    int h = int.parse(parts[0]), m = int.parse(parts[1]) + mins;
    h += m ~/ 60;
    m = m % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  static Future<void> _ridership() async {
    final data = [
      42,
      55,
      38,
      60,
      45,
      33,
      50,
      28,
      48,
      35,
      52,
      40,
      38,
      44,
      30,
      56,
      42,
      48,
      35,
      60,
    ];
    int idx = 0;
    final now = DateTime.now();
    for (int d = 7; d >= 0; d--) {
      final date = now.subtract(Duration(days: d));
      for (int r = 1; r <= 10; r++) {
        for (int h = 6; h <= 22; h += 2) {
          final b = data[idx % data.length];
          idx++;
          await _db.insertRidership(
            RidershipLog(
              routeId: r,
              busId: r,
              boarded: b,
              alighted: (b * 0.88).round(),
              stopName: 'Main Stop',
              dayType: date.weekday <= 5 ? 'weekday' : 'weekend',
              timestamp: DateTime(date.year, date.month, date.day, h),
            ),
          );
        }
      }
    }
  }

  static Future<void> _complaints() async {
    await _db.insertComplaint(
      Complaint(
        userId: 2,
        routeId: 1,
        category: 'delay',
        description:
            'Route 1A bus consistently runs 25-30 minutes late at Gandhipuram Central stop during morning peak hours (8-9 AM). This happens almost every day.',
        status: 'in_review',
        submittedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    );
    await _db.insertComplaint(
      Complaint(
        userId: 2,
        routeId: 3,
        category: 'overcrowding',
        description:
            'Route 3C buses are dangerously overcrowded between 7:30-9:30 AM. People hanging from doors. Need extra buses on this route.',
        status: 'pending',
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    );
    await _db.insertComplaint(
      Complaint(
        userId: 3,
        routeId: 2,
        category: 'cleanliness',
        description:
            'AC bus CBE-003 has broken seats and AC not functioning properly. Also the interior is very dirty.',
        status: 'resolved',
        submittedAt: DateTime.now().subtract(const Duration(days: 6)),
        adminResponse:
            'Thank you for reporting. Bus CBE-003 has been sent for maintenance. AC is repaired and seats replaced.',
      ),
    );
    await _db.insertComplaint(
      Complaint(
        userId: 3,
        routeId: null,
        category: 'other',
        description:
            'The stop near Hopes College has no shade. Commuters wait in direct sunlight. Please install bus shelters.',
        status: 'pending',
        submittedAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    );
  }
}

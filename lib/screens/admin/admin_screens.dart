import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

// ── ADMIN NAV ─────────────────────────────────────────────────────────────────
class AdminNav extends StatefulWidget {
  const AdminNav({super.key});
  @override
  State<AdminNav> createState() => _AdminNavState();
}

class _AdminNavState extends State<AdminNav> {
  int _i = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransportProvider>().loadAll();
      context.read<TransportProvider>().loadComplaints();
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    return Scaffold(
      body: IndexedStack(
        index: _i,
        children: const [
          AdminDashboard(),
          AdminRoutes(),
          AdminBuses(),
          AdminAnalytics(),
          AdminComplaints(),
          AdminProfile(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.bgCard,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: BottomNavigationBar(
          currentIndex: _i,
          onTap: (i) => setState(() => _i = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.adminPurple,
          unselectedItemColor: AppColors.textM,
          type: BottomNavigationBarType.fixed,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined, size: 22),
              activeIcon: Icon(Icons.dashboard, size: 22),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.route_outlined, size: 22),
              activeIcon: Icon(Icons.route, size: 22),
              label: 'Routes',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.directions_bus_outlined, size: 22),
              activeIcon: Icon(Icons.directions_bus, size: 22),
              label: 'Fleet',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined, size: 22),
              activeIcon: Icon(Icons.analytics, size: 22),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.report_outlined, size: 22),
                  if (tp.pendingComplaints > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              activeIcon: const Icon(Icons.report, size: 22),
              label: 'Complaints',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined, size: 22),
              activeIcon: Icon(Icons.person, size: 22),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── ADMIN DASHBOARD ───────────────────────────────────────────────────────────
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 52, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF140A22), AppColors.bg],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin Panel',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.adminPurple,
                            letterSpacing: 2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            auth.user?.name ?? 'Admin',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textW,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.adminPurple.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.adminPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'LIVE SYSTEM',
                          style: TextStyle(
                            color: AppColors.green,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'logout') {
                        await auth.logout();
                        if (!context.mounted) return;
                        Navigator.pushReplacementNamed(context, '/login');
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout, color: AppColors.red, size: 18),
                            SizedBox(width: 8),
                            Text('Sign Out'),
                          ],
                        ),
                      ),
                    ],
                    color: AppColors.bgCard,
                    icon: const Icon(
                      Icons.more_vert,
                      color: AppColors.textM,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    StatTile(
                      value: '${tp.activeRoutes}',
                      label: 'Active Routes',
                      icon: Icons.route,
                      color: AppColors.cyan,
                      badge: 'RUNNING',
                    ),
                    StatTile(
                      value: '${tp.activeBuses}',
                      label: 'Buses On Road',
                      icon: Icons.directions_bus,
                      color: AppColors.green,
                      badge: 'LIVE',
                    ),
                    StatTile(
                      value: '${tp.totalRiders}',
                      label: 'Total Riders',
                      icon: Icons.people,
                      color: AppColors.amber,
                      badge: 'TODAY',
                    ),
                    StatTile(
                      value: '${tp.pendingComplaints}',
                      label: 'Pending Issues',
                      icon: Icons.report_problem_outlined,
                      color: tp.pendingComplaints > 0
                          ? AppColors.red
                          : AppColors.textM,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Fleet overview
                SectionHead(
                  title: 'Fleet Status',
                  color: AppColors.adminPurple,
                ),
                const SizedBox(height: 12),
                GCard(
                  accent: AppColors.adminPurple,
                  child: tp.busStatus.isEmpty
                      ? const Center(
                          child: Text(
                            'Loading...',
                            style: TextStyle(color: AppColors.textM),
                          ),
                        )
                      : Column(
                          children: tp.busStatus.entries.map((e) {
                            final total = tp.buses.length;
                            final pct = total > 0 ? e.value / total : 0.0;
                            final c = e.key == 'running'
                                ? AppColors.green
                                : e.key == 'parked'
                                ? AppColors.blue
                                : e.key == 'maintenance'
                                ? AppColors.amber
                                : AppColors.red;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  Container(
                                    width: 9,
                                    height: 9,
                                    decoration: BoxDecoration(
                                      color: c,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    e.key.replaceAll('_', ' ').toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textM,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${e.value}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: c,
                                      fontFamily: 'SpaceGrotesk',
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  SizedBox(
                                    width: 90,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: pct,
                                        minHeight: 5,
                                        backgroundColor: AppColors.bgCard2,
                                        valueColor: AlwaysStoppedAnimation(c),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                ),
                const SizedBox(height: 20),

                // Quick actions
                SectionHead(
                  title: 'Quick Actions',
                  color: AppColors.adminPurple,
                ),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2.8,
                  children: [
                    _action(context, '🗺️ Add Route', AppColors.cyan),
                    _action(context, '🚌 Add Bus', AppColors.green),
                    _action(context, '📊 Analytics', AppColors.amber),
                    _action(
                      context,
                      '🚪 Sign Out',
                      AppColors.red,
                      logout: true,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SectionHead(
                  title: 'Live Fleet Feed',
                  color: AppColors.adminPurple,
                ),
                const SizedBox(height: 10),
                ...tp.buses
                    .take(5)
                    .map(
                      (b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: BusCard(bus: b),
                      ),
                    ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(
    BuildContext ctx,
    String label,
    Color c, {
    bool logout = false,
  }) => GCard(
    accent: c,
    onTap: logout
        ? () async {
            await ctx.read<AuthProvider>().logout();
            if (!ctx.mounted) return;
            Navigator.pushReplacementNamed(ctx, '/login');
          }
        : null,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    child: Row(
      children: [
        Text(label.substring(0, 2), style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(
          label.substring(3),
          style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    ),
  );
}

// ── ADMIN ROUTES ──────────────────────────────────────────────────────────────
class AdminRoutes extends StatefulWidget {
  const AdminRoutes({super.key});
  @override
  State<AdminRoutes> createState() => _AdminRoutesState();
}

class _AdminRoutesState extends State<AdminRoutes> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    final list = _filter == 'all'
        ? tp.routes
        : tp.routes.where((r) => r.status == _filter).toList();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Routes (${list.length})'),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.adminPurple,
            ),
            onPressed: () => _form(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...[
                    ['all', 'All'],
                    ['active', 'Active'],
                    ['maintenance', 'Maintenance'],
                    ['inactive', 'Inactive'],
                  ].map(
                    (f) => GestureDetector(
                      onTap: () => setState(() => _filter = f[0]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _filter == f[0]
                              ? AppColors.adminPurple
                              : AppColors.bgCard2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _filter == f[0]
                                ? AppColors.adminPurple
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          f[1],
                          style: TextStyle(
                            color: _filter == f[0]
                                ? Colors.white
                                : AppColors.textM,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: RouteCard(
                  route: list[i],
                  onTap: () => _detail(context, list[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _detail(BuildContext ctx, BusRoute r) => showModalBottomSheet(
    context: ctx,
    backgroundColor: AppColors.bgCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, sc) => ListView(
        controller: sc,
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textM,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Route ${r.routeNumber}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.routeColor(r.colorIndex),
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.cyan,
                      size: 20,
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _form(ctx, route: r);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline,
                      color: AppColors.red,
                      size: 20,
                    ),
                    onPressed: () async {
                      await ctx.read<TransportProvider>().deleteRoute(r.id!);
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                    },
                  ),
                ],
              ),
            ],
          ),
          Text(
            r.routeName,
            style: const TextStyle(fontSize: 14, color: AppColors.textL),
          ),
          const SizedBox(height: 10),
          StatusPill(status: r.status),
          const SizedBox(height: 14),
          ...[
            ['Category', r.category],
            ['Hours', r.operatingHours],
            ['Frequency', '${r.freqPerHour}/hr'],
            ['Fare', '₹${r.fare}'],
            ['Distance', '${r.distanceKm}km'],
            ['Duration', '${r.durationMin}min'],
          ].map(
            (x) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    x[0],
                    style: const TextStyle(
                      color: AppColors.textM,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    x[1],
                    style: const TextStyle(
                      color: AppColors.textW,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Stops',
            style: TextStyle(
              color: AppColors.textM,
              fontSize: 11,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ...r.stops.asMap().entries.map(
            (e) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppColors.routeColor(
                        r.colorIndex,
                      ).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        '${e.key + 1}',
                        style: TextStyle(
                          color: AppColors.routeColor(r.colorIndex),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    e.value,
                    style: const TextStyle(
                      color: AppColors.textL,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );

  void _form(BuildContext ctx, {BusRoute? route}) {
    final isEdit = route != null;
    final num = TextEditingController(text: route?.routeNumber ?? '');
    final name = TextEditingController(text: route?.routeName ?? '');
    final fare = TextEditingController(text: route?.fare.toString() ?? '');
    String status = route?.status ?? 'active', cat = route?.category ?? 'local';
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (_, sBS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isEdit ? 'Edit' : 'Add'} Route',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textW,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppField(
                      ctrl: num,
                      label: 'Route No.',
                      icon: Icons.tag,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AppField(
                      ctrl: fare,
                      label: 'Fare ₹',
                      icon: Icons.currency_rupee,
                      keyType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppField(ctrl: name, label: 'Route Name', icon: Icons.route),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _drop('Status', status, [
                      'active',
                      'inactive',
                      'maintenance',
                    ], (v) => sBS(() => status = v!)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _drop('Category', cat, [
                      'local',
                      'express',
                      'feeder',
                      'circular',
                    ], (v) => sBS(() => cat = v!)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.adminPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final tp = ctx.read<TransportProvider>();
                    if (isEdit) {
                      await tp.updateRoute(
                        route.copyWith(
                          routeNumber: num.text,
                          routeName: name.text,
                          fare: double.tryParse(fare.text),
                          status: status,
                          category: cat,
                        ),
                      );
                    } else {
                      await tp.addRoute(
                        BusRoute(
                          routeNumber: num.text,
                          routeName: name.text,
                          startStop: 'TBD',
                          endStop: 'TBD',
                          stops: ['TBD'],
                          distanceKm: 10,
                          durationMin: 30,
                          fare: double.tryParse(fare.text) ?? 10,
                          status: status,
                          category: cat,
                          freqPerHour: 4,
                          colorIndex: 0,
                          operatingHours: '06:00-22:00',
                        ),
                      );
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: Text(isEdit ? 'SAVE CHANGES' : 'ADD ROUTE'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drop(
    String label,
    String val,
    List<String> items,
    ValueChanged<String?> onChange,
  ) => DropdownButtonFormField<String>(
    initialValue: val,
    dropdownColor: AppColors.bgCard,
    style: const TextStyle(color: AppColors.textW, fontSize: 13),
    decoration: InputDecoration(
      labelText: label,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    ),
    onChanged: onChange,
    items: items
        .map((i) => DropdownMenuItem(value: i, child: Text(i)))
        .toList(),
  );
}

// ── ADMIN BUSES ───────────────────────────────────────────────────────────────
class AdminBuses extends StatelessWidget {
  const AdminBuses({super.key});
  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Fleet (${tp.buses.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.green),
            onPressed: () => _form(context, tp.routes),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: tp.buses.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: BusCard(
            bus: tp.buses[i],
            onTap: () => _detail(context, tp.buses[i], tp.routes),
          ),
        ),
      ),
    );
  }

  void _detail(BuildContext ctx, Bus bus, List<BusRoute> routes) {
    final route = routes.firstWhere(
      (r) => r.id == bus.routeId,
      orElse: () => routes.first,
    );
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bus.busNumber,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textW,
                    fontFamily: 'SpaceGrotesk',
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: AppColors.cyan,
                        size: 20,
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _form(ctx, routes, bus: bus);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: AppColors.red,
                        size: 20,
                      ),
                      onPressed: () async {
                        await ctx.read<TransportProvider>().deleteBus(bus.id!);
                        if (!ctx.mounted) return;
                        Navigator.pop(ctx);
                      },
                    ),
                  ],
                ),
              ],
            ),
            StatusPill(status: bus.status),
            const SizedBox(height: 14),
            ...[
              ['Model', bus.model],
              ['Type', bus.busType],
              ['Route', 'Route ${route.routeNumber}'],
              ['Driver', bus.driverName],
              ['Contact', bus.driverPhone],
              ['At Stop', bus.currentStop],
              ['Capacity', '${bus.capacity}'],
              ['Year', '${bus.year}'],
            ].map(
              (x) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      x[0],
                      style: const TextStyle(
                        color: AppColors.textM,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      x[1],
                      style: const TextStyle(
                        color: AppColors.textW,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _bar(
                    'Occupancy',
                    bus.occupancy / 100,
                    '${bus.currentPassengers}/${bus.capacity}',
                    bus.isCrowded ? AppColors.red : AppColors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _bar(
                    'Fuel',
                    bus.fuelLevel / 100,
                    '${bus.fuelLevel.toInt()}%',
                    bus.fuelLevel < 25 ? AppColors.red : AppColors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _bar(String label, double val, String text, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textM),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: val,
          minHeight: 7,
          backgroundColor: AppColors.bgCard2,
          valueColor: AlwaysStoppedAnimation(c),
        ),
      ),
    ],
  );

  void _form(BuildContext ctx, List<BusRoute> routes, {Bus? bus}) {
    final isEdit = bus != null;
    final num = TextEditingController(text: bus?.busNumber ?? '');
    final driver = TextEditingController(text: bus?.driverName ?? '');
    final phone = TextEditingController(text: bus?.driverPhone ?? '');
    int routeId = bus?.routeId ?? (routes.isNotEmpty ? routes.first.id! : 1);
    String status = bus?.status ?? 'running', type = bus?.busType ?? 'AC';
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (_, sBS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${isEdit ? 'Edit' : 'Add'} Bus',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textW,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              const SizedBox(height: 14),
              AppField(
                ctrl: num,
                label: 'Bus Number',
                icon: Icons.confirmation_number_outlined,
              ),
              const SizedBox(height: 10),
              AppField(
                ctrl: driver,
                label: 'Driver Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 10),
              AppField(
                ctrl: phone,
                label: 'Driver Phone',
                icon: Icons.phone_outlined,
                keyType: TextInputType.phone,
              ),
              const SizedBox(height: 10),
              if (routes.isNotEmpty)
                DropdownButtonFormField<int>(
                  initialValue: routeId,
                  dropdownColor: AppColors.bgCard,
                  style: const TextStyle(color: AppColors.textW, fontSize: 12),
                  decoration: const InputDecoration(
                    labelText: 'Assign Route',
                    prefixIcon: Icon(Icons.route, size: 18),
                  ),
                  onChanged: (v) => sBS(() => routeId = v!),
                  items: routes
                      .map(
                        (r) => DropdownMenuItem(
                          value: r.id,
                          child: Text(
                            'Route ${r.routeNumber} – ${r.routeName}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      )
                      .toList(),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      dropdownColor: AppColors.bgCard,
                      style: const TextStyle(
                        color: AppColors.textW,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(labelText: 'Status'),
                      onChanged: (v) => sBS(() => status = v!),
                      items:
                          ['running', 'parked', 'maintenance', 'out_of_service']
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: type,
                      dropdownColor: AppColors.bgCard,
                      style: const TextStyle(
                        color: AppColors.textW,
                        fontSize: 13,
                      ),
                      decoration: const InputDecoration(labelText: 'Type'),
                      onChanged: (v) => sBS(() => type = v!),
                      items: ['AC', 'Non-AC', 'Electric', 'Mini']
                          .map(
                            (t) => DropdownMenuItem(value: t, child: Text(t)),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: AppColors.bg,
                  ),
                  onPressed: () async {
                    final tp = ctx.read<TransportProvider>();
                    if (isEdit) {
                      await tp.updateBus(
                        bus.copyWith(
                          busNumber: num.text,
                          driverName: driver.text,
                          driverPhone: phone.text,
                          routeId: routeId,
                          status: status,
                          busType: type,
                        ),
                      );
                    } else {
                      await tp.addBus(
                        Bus(
                          busNumber: num.text,
                          model: 'Tata Starbus',
                          driverName: driver.text,
                          driverPhone: phone.text,
                          currentStop: 'Depot',
                          routeId: routeId,
                          capacity: 50,
                          year: DateTime.now().year,
                          status: status,
                          busType: type,
                          fuelLevel: 80,
                          updatedAt: DateTime.now(),
                        ),
                      );
                    }
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                  },
                  child: Text(isEdit ? 'SAVE CHANGES' : 'ADD BUS'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── ADMIN ANALYTICS ───────────────────────────────────────────────────────────
class AdminAnalytics extends StatelessWidget {
  const AdminAnalytics({super.key});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Ridership Analytics'),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          /// =======================
          /// STATISTICS GRID
          /// =======================
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: [
              StatTile(
                value: '${tp.totalRiders}',
                label: 'Total Riders',
                icon: Icons.people,
                color: AppColors.cyan,
              ),
              StatTile(
                value: '${tp.activeRoutes}',
                label: 'Active Routes',
                icon: Icons.route,
                color: AppColors.green,
              ),
              StatTile(
                value: '${tp.buses.length}',
                label: 'Fleet Size',
                icon: Icons.directions_bus,
                color: AppColors.amber,
              ),
              StatTile(
                value: '${tp.pendingComplaints}',
                label: 'Pending Issues',
                icon: Icons.report,
                color: AppColors.red,
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// =======================
          /// HOURLY CHART
          /// =======================
          SectionHead(title: 'Hourly Ridership', color: AppColors.adminPurple),
          const SizedBox(height: 12),

          GCard(
            accent: AppColors.adminPurple,
            child: SizedBox(
              height: 180,
              child: tp.hourly.isEmpty
                  ? const Center(
                      child: Text(
                        'Loading...',
                        style: TextStyle(color: AppColors.textM),
                      ),
                    )
                  : BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 600,
                        barTouchData: BarTouchData(enabled: true),
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: AppColors.border,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, _) {
                                if (value.toInt() % 4 == 0) {
                                  return Text(
                                    '${value.toInt()}h',
                                    style: const TextStyle(
                                      color: AppColors.textM,
                                      fontSize: 9,
                                    ),
                                  );
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        barGroups: tp.hourly.map((e) {
                          final h = (e['hr'] as int?) ?? 0;
                          final r = ((e['riders'] as num?)?.toDouble()) ?? 0;

                          final isPeak =
                              (h >= 7 && h <= 10) || (h >= 17 && h <= 20);

                          return BarChartGroupData(
                            x: h,
                            barRods: [
                              BarChartRodData(
                                toY: r,
                                width: 10,
                                borderRadius: BorderRadius.circular(3),
                                color: isPeak
                                    ? AppColors.amber
                                    : AppColors.adminPurple,
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          /// =======================
          /// WEEKLY CHART
          /// =======================
          SectionHead(
            title: 'Weekly Ridership Trend',
            color: AppColors.adminPurple,
          ),
          const SizedBox(height: 12),

          GCard(
            accent: AppColors.cyan,
            child: SizedBox(
              height: 160,
              child: tp.weekly.isEmpty
                  ? const Center(
                      child: Text(
                        'No data',
                        style: TextStyle(color: AppColors.textM),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: AppColors.border,
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 20,
                              getTitlesWidget: (value, _) {
                                return Text(
                                  'D${value.toInt() + 1}',
                                  style: const TextStyle(
                                    color: AppColors.textM,
                                    fontSize: 9,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: tp.weekly.reversed
                                .toList()
                                .asMap()
                                .entries
                                .map(
                                  (e) => FlSpot(
                                    e.key.toDouble(),
                                    ((e.value['riders'] as num?)?.toDouble()) ??
                                        0,
                                  ),
                                )
                                .toList(),
                            isCurved: true,
                            color: AppColors.cyan,
                            barWidth: 2.5,
                            dotData: const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.cyan.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 20),

          /// =======================
          /// ROUTE PERFORMANCE
          /// =======================
          SectionHead(title: 'Route Performance', color: AppColors.adminPurple),
          const SizedBox(height: 12),
          ...tp.byRoute.asMap().entries.map((entry) {
            final row = entry.value;

            final total = tp.totalRiders > 0
                ? (row['total'] as num).toDouble() / tp.totalRiders
                : 0.0;

            final c = AppColors.routeColor((row['colorIndex'] as int?) ?? 0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GCard(
                accent: c,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        row['routeNumber'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row['routeName'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textL,
                            ),
                          ),
                          const SizedBox(height: 3),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: total,
                              minHeight: 4,
                              backgroundColor: AppColors.bgCard2,
                              valueColor: AlwaysStoppedAnimation(c),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${row['total']}',
                      style: TextStyle(
                        color: c,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        fontFamily: 'SpaceGrotesk',
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 60),
        ],
      ),
    );
  }
}

// ── ADMIN COMPLAINTS ──────────────────────────────────────────────────────────
class AdminComplaints extends StatefulWidget {
  const AdminComplaints({super.key});
  @override
  State<AdminComplaints> createState() => _AdminComplaintsState();
}

class _AdminComplaintsState extends State<AdminComplaints> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    final list = _filter == 'all'
        ? tp.complaints
        : tp.complaints.where((c) => c.status == _filter).toList();
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Complaints'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...[
                    ['all', 'All'],
                    ['pending', 'Pending'],
                    ['in_review', 'In Review'],
                    ['resolved', 'Resolved'],
                  ].map(
                    (f) => GestureDetector(
                      onTap: () => setState(() => _filter = f[0]),
                      child: Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _filter == f[0]
                              ? AppColors.adminPurple
                              : AppColors.bgCard2,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _filter == f[0]
                                ? AppColors.adminPurple
                                : AppColors.border,
                          ),
                        ),
                        child: Text(
                          f[1],
                          style: TextStyle(
                            color: _filter == f[0]
                                ? Colors.white
                                : AppColors.textM,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: list.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('✅', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'No complaints here',
                          style: TextStyle(color: AppColors.textM),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: list.length,
                    itemBuilder: (_, i) => _card(context, list[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(BuildContext ctx, Complaint c) {
    final catColor = c.category == 'delay'
        ? AppColors.amber
        : c.category == 'overcrowding'
        ? AppColors.red
        : c.category == 'driver_behavior'
        ? AppColors.orange
        : AppColors.cyan;
    return GCard(
      accent: catColor,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: catColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  c.category.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    color: catColor,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              StatusPill(status: c.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            c.description,
            style: const TextStyle(
              color: AppColors.textL,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${c.submittedAt.day}/${c.submittedAt.month}/${c.submittedAt.year}',
            style: const TextStyle(color: AppColors.textM, fontSize: 10),
          ),
          if (c.adminResponse != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.green.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.green.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.green,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      c.adminResponse!,
                      style: const TextStyle(
                        color: AppColors.textL,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (c.status != 'resolved') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _respond(ctx, c),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.adminPurple,
                      side: BorderSide(
                        color: AppColors.adminPurple.withOpacity(0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Respond',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => ctx
                        .read<TransportProvider>()
                        .resolveComplaint(c.id!, 'resolved'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: AppColors.bg,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      'Resolve',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _respond(BuildContext ctx, Complaint c) {
    final ctrl = TextEditingController();
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        title: const Text(
          'Respond',
          style: TextStyle(
            color: AppColors.textW,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: TextField(
          controller: ctrl,
          maxLines: 4,
          style: const TextStyle(color: AppColors.textW, fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Write admin response...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textM),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ctx.read<TransportProvider>().resolveComplaint(
                c.id!,
                'in_review',
                response: ctrl.text,
              );
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.adminPurple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}

// ── ADMIN PROFILE ────────────────────────────────────────────────────────────
class AdminProfile extends StatelessWidget {
  const AdminProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF140A22), AppColors.bg],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.adminPurple.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.adminPurple.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.adminPurple,
                                    fontFamily: 'SpaceGrotesk',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textW,
                                    fontFamily: 'SpaceGrotesk',
                                  ),
                                ),
                                Text(
                                  user.email,
                                  style: const TextStyle(
                                    color: AppColors.textM,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                SectionHead(title: 'Account Information'),
                const SizedBox(height: 10),
                GCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row('Name', user.name),
                      const Divider(height: 20, color: AppColors.border),
                      _row('Email', user.email),
                      const Divider(height: 20, color: AppColors.border),
                      _row(
                        'Phone',
                        user.phone.isEmpty ? 'Not set' : user.phone,
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _row('Role', 'Administrator'),
                      const Divider(height: 20, color: AppColors.border),
                      _row('Status', 'Active'),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                GCard(
                  accent: AppColors.red,
                  padding: const EdgeInsets.all(14),
                  onTap: () async {
                    await auth.logout();
                    if (!context.mounted) return;
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.logout, color: AppColors.red, size: 18),
                      const SizedBox(width: 12),
                      const Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.red,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.chevron_right,
                        color: AppColors.red,
                        size: 18,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String val) => Row(
    children: [
      Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textM)),
      const Spacer(),
      Text(
        val,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textW,
        ),
      ),
    ],
  );
}

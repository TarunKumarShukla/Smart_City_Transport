import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/providers.dart';
import '../../services/gemini_service.dart';
import '../../utils/theme.dart';
import '../../widgets/widgets.dart';
import '../../models/models.dart';

// ── COMMUTER NAV ──────────────────────────────────────────────────────────────
class CommuterNav extends StatefulWidget {
  const CommuterNav({super.key});
  @override
  State<CommuterNav> createState() => _CommuterNavState();
}

class _CommuterNavState extends State<CommuterNav> {
  int _i = 0;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<TransportProvider>().loadAll(),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(
      index: _i,
      children: const [
        CommuterHome(),
        FindRoute(),
        ScheduleView(),
        AiChat(),
        CommuterProfile(),
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
        selectedItemColor: AppColors.cyan,
        unselectedItemColor: AppColors.textM,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined, size: 22),
            activeIcon: Icon(Icons.home, size: 22),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined, size: 22),
            activeIcon: Icon(Icons.map, size: 22),
            label: 'Find Route',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule_outlined, size: 22),
            activeIcon: Icon(Icons.schedule, size: 22),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.psychology_outlined, size: 22),
            activeIcon: Icon(Icons.psychology, size: 22),
            label: 'AI Help',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline, size: 22),
            activeIcon: Icon(Icons.person, size: 22),
            label: 'Profile',
          ),
        ],
      ),
    ),
  );
}

// ── COMMUTER HOME ─────────────────────────────────────────────────────────────
class CommuterHome extends StatelessWidget {
  const CommuterHome({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final tp = context.watch<TransportProvider>();
    final user = auth.user!;
    final hr = DateTime.now().hour;
    final greet = hr < 12
        ? 'Good Morning'
        : hr < 17
        ? 'Good Afternoon'
        : 'Good Evening';
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
                  colors: [AppColors.bgCard2, AppColors.bg],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$greet 👋',
                            style: const TextStyle(
                              color: AppColors.textM,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            user.name.split(' ').first,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textW,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.bgCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppColors.textL,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Quick find
                  GCard(
                    accent: AppColors.cyan,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.cyan.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.search,
                            color: AppColors.cyan,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Where do you want to go?',
                            style: TextStyle(
                              color: AppColors.textM,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: AppColors.cyan,
                          size: 14,
                        ),
                      ],
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
                // Live stats row
                Row(
                  children: [
                    Expanded(
                      child: _miniStat(
                        '🚌',
                        '${tp.activeBuses}',
                        'Buses Live',
                        AppColors.green,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniStat(
                        '🗺️',
                        '${tp.activeRoutes}',
                        'Routes',
                        AppColors.cyan,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _miniStat(
                        '👥',
                        '${tp.totalRiders}',
                        'Riders Today',
                        AppColors.amber,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Commute card
                if (user.homeStop.isNotEmpty && user.workStop.isNotEmpty) ...[
                  SectionHead(title: 'My Commute Route'),
                  const SizedBox(height: 10),
                  GCard(
                    accent: AppColors.amber,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _commuteStop(
                          Icons.home_outlined,
                          'Home',
                          user.homeStop,
                          AppColors.green,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Container(
                            height: 16,
                            width: 1,
                            color: AppColors.border,
                          ),
                        ),
                        _commuteStop(
                          Icons.work_outline,
                          'Office',
                          user.workStop,
                          AppColors.cyan,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                ],

                SectionHead(title: 'Available Routes', action: 'View All'),
                const SizedBox(height: 10),
                if (tp.loading)
                  Column(
                    children: List.generate(
                      3,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 10),
                        child: Shimmer(h: 130),
                      ),
                    ),
                  )
                else
                  ...tp.routes
                      .take(4)
                      .map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: RouteCard(route: r),
                        ),
                      ),
                const SizedBox(height: 70),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String e, String val, String label, Color c) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
    decoration: BoxDecoration(
      color: c.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: c.withOpacity(0.2)),
    ),
    child: Column(
      children: [
        Text(e, style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 4),
        Text(
          val,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: c,
            fontFamily: 'SpaceGrotesk',
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: AppColors.textM),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );

  Widget _commuteStop(IconData icon, String type, String stop, Color c) => Row(
    children: [
      Icon(icon, color: c, size: 18),
      const SizedBox(width: 10),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            type,
            style: const TextStyle(fontSize: 10, color: AppColors.textM),
          ),
          Text(
            stop,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textW,
            ),
          ),
        ],
      ),
    ],
  );
}

// ── FIND ROUTE ────────────────────────────────────────────────────────────────
class FindRoute extends StatefulWidget {
  const FindRoute({super.key});
  @override
  State<FindRoute> createState() => _FindRouteState();
}

class _FindRouteState extends State<FindRoute>
    with SingleTickerProviderStateMixin {
  final _from = TextEditingController(),
      _to = TextEditingController(),
      _search = TextEditingController();
  List<BusRoute>? _results;
  bool _loading = false;
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  Future<void> _find() async {
    if (_from.text.isEmpty || _to.text.isEmpty) return;
    setState(() {
      _loading = true;
    });
    _results = await context.read<TransportProvider>().findBetween(
      _from.text,
      _to.text,
    );
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Route',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textW,
                      fontFamily: 'SpaceGrotesk',
                    ),
                  ),
                  const SizedBox(height: 14),
                  GCard(
                    accent: AppColors.cyan,
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () => showStopPicker(
                            context,
                            _from,
                            onDone: () => setState(() {}),
                          ),
                          child: _stopRow(
                            Icons.trip_origin,
                            'From',
                            _from.text,
                            AppColors.green,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const SizedBox(width: 18),
                              Container(
                                width: 1,
                                height: 16,
                                color: AppColors.border,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  final t = _from.text;
                                  _from.text = _to.text;
                                  _to.text = t;
                                  setState(() {});
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.cyan.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.swap_vert,
                                    color: AppColors.cyan,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => showStopPicker(
                            context,
                            _to,
                            onDone: () => setState(() {}),
                          ),
                          child: _stopRow(
                            Icons.location_on,
                            'To',
                            _to.text,
                            AppColors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 44,
                          child: ElevatedButton.icon(
                            onPressed: _loading ? null : _find,
                            icon: _loading
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.bg,
                                    ),
                                  )
                                : const Icon(Icons.search, size: 16),
                            label: const Text(
                              'FIND ROUTES',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TabBar(
                    controller: _tab,
                    tabs: const [
                      Tab(text: 'Search Results'),
                      Tab(text: 'All Routes'),
                    ],
                    labelColor: AppColors.cyan,
                    unselectedLabelColor: AppColors.textM,
                    indicatorColor: AppColors.cyan,
                    labelStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                    padding: EdgeInsets.zero,
                    dividerColor: AppColors.border,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _search,
                    onChanged: tp.setSearch,
                    style: const TextStyle(
                      color: AppColors.textW,
                      fontSize: 13,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Search routes by name or number...',
                      prefixIcon: Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: [
                  _resultsList(_results, tp),
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: tp.routes.length,
                    itemBuilder: (_, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: RouteCard(route: tp.routes[i]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stopRow(IconData icon, String hint, String val, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.bgCard2,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: val.isEmpty ? AppColors.border : c.withOpacity(0.4),
      ),
    ),
    child: Row(
      children: [
        Icon(icon, color: c, size: 16),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            val.isEmpty ? hint : val,
            style: TextStyle(
              color: val.isEmpty ? AppColors.textM : AppColors.textW,
              fontSize: 13,
            ),
          ),
        ),
        if (val.isNotEmpty)
          const Icon(Icons.check_circle, color: AppColors.green, size: 14),
      ],
    ),
  );

  Widget _resultsList(List<BusRoute>? results, TransportProvider tp) {
    if (results == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 12),
            const Text(
              'Enter From & To stops',
              style: TextStyle(color: AppColors.textM, fontSize: 14),
            ),
          ],
        ),
      );
    }
    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('😕', style: TextStyle(fontSize: 52)),
            SizedBox(height: 12),
            Text(
              'No direct routes found',
              style: TextStyle(color: AppColors.textM),
            ),
            SizedBox(height: 6),
            Text(
              'Try nearby major stops',
              style: TextStyle(color: AppColors.textM, fontSize: 12),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: results.length,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: RouteCard(route: results[i]),
      ),
    );
  }
}

// ── SCHEDULE VIEW ─────────────────────────────────────────────────────────────
class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});
  @override
  State<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends State<ScheduleView> {
  BusRoute? _sel;
  List<Schedule> _schedules = [];
  String _day = 'weekday';

  Future<void> _load(BusRoute r) async {
    final s = await context.read<TransportProvider>().getSchedule(r.id!, _day);
    setState(() {
      _sel = r;
      _schedules = s;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<TransportProvider>();
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bus Schedules',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textW,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap a route to view stop timings',
                style: TextStyle(color: AppColors.textM, fontSize: 13),
              ),
              const SizedBox(height: 14),
              // Day toggle
              GCard(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _dayBtn('Weekday', 'weekday'),
                    _dayBtn('Weekend', 'weekend'),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Route chips
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tp.routes.length,
                  itemBuilder: (_, i) {
                    final r = tp.routes[i];
                    final sel = _sel?.id == r.id;
                    final c = AppColors.routeColor(r.colorIndex);
                    return GestureDetector(
                      onTap: () => _load(r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: sel ? c : c.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel ? c : c.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          r.routeNumber,
                          style: TextStyle(
                            color: sel ? AppColors.bg : c,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _sel == null
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('🕐', style: TextStyle(fontSize: 52)),
                            SizedBox(height: 12),
                            Text(
                              'Select a route above',
                              style: TextStyle(color: AppColors.textM),
                            ),
                          ],
                        ),
                      )
                    : _buildTimeline(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    if (_schedules.isEmpty) {
      return const Center(
        child: Text(
          'No schedule data',
          style: TextStyle(color: AppColors.textM),
        ),
      );
    }
    final c = AppColors.routeColor(_sel!.colorIndex);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Route ${_sel!.routeNumber} – ${_sel!.routeName}',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: _schedules.length,
            itemBuilder: (_, i) {
              final s = _schedules[i];
              final isTerminal = i == 0 || i == _schedules.length - 1;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 13,
                        height: 13,
                        decoration: BoxDecoration(
                          color: isTerminal ? c : AppColors.bgCard2,
                          shape: BoxShape.circle,
                          border: Border.all(color: c, width: 2),
                        ),
                      ),
                      if (i < _schedules.length - 1)
                        Container(
                          width: 2,
                          height: 50,
                          color: c.withOpacity(0.25),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isTerminal
                            ? c.withOpacity(0.08)
                            : AppColors.bgCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isTerminal
                              ? c.withOpacity(0.3)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.stopName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isTerminal ? c : AppColors.textW,
                                ),
                              ),
                              Text(
                                'Stop ${s.stopOrder}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textM,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            s.arrivalTime,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: c,
                              fontFamily: 'SpaceGrotesk',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _dayBtn(String label, String val) {
    final sel = _day == val;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _day = val);
          if (_sel != null) _load(_sel!);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(2),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: sel ? AppColors.amber : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: sel ? AppColors.bg : AppColors.textM,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ── AI CHAT ───────────────────────────────────────────────────────────────────
class AiChat extends StatefulWidget {
  const AiChat({super.key});
  @override
  State<AiChat> createState() => _AiChatState();
}

class _AiChatState extends State<AiChat> {
  final _ai = GeminiService();
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMessage> _msgs = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _msgs.add(
      ChatMessage(
        id: '0',
        isUser: false,
        timestamp: DateTime.now(),
        content:
            '👋 Hello! I\'m your Smart City Transport AI, powered by Gemini!\n\nI can help you:\n🗺️ Find best routes between stops\n⏰ Check schedules and timings\n💰 Get fare information\n🚌 Bus status updates\n\nAsk me anything! Try: *"How do I get from Airport to Town Hall?"*',
      ),
    );
  }

  Future<void> _send([String? preset]) async {
    final text = preset ?? _ctrl.text.trim();
    if (text.isEmpty || _sending) return;
    _ctrl.clear();
    final auth = context.read<AuthProvider>();
    final tp = context.read<TransportProvider>();
    final uid = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _msgs.add(
        ChatMessage(
          id: uid,
          content: text,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _msgs.add(
        ChatMessage(
          id: 'loading',
          content: '',
          isUser: false,
          isLoading: true,
          timestamp: DateTime.now(),
        ),
      );
      _sending = true;
    });
    _scrollBottom();
    final reply = await _ai.chat(text, routes: tp.routes, user: auth.user!);
    setState(() {
      _msgs.removeWhere((m) => m.id == 'loading');
      _msgs.add(
        ChatMessage(
          id: '${uid}r',
          content: reply,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _sending = false;
    });
    _scrollBottom();
  }

  void _scrollBottom() => Future.delayed(const Duration(milliseconds: 150), () {
    if (_scroll.hasClients) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bg,
    appBar: AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.psychology,
              color: AppColors.cyan,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Transport Assistant',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Row(
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Gemini-powered',
                    style: TextStyle(fontSize: 10, color: AppColors.textM),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: AppColors.textM, size: 20),
          onPressed: () {
            _ai.reset();
            setState(() {
              _msgs.clear();
            });
            _msgs.add(
              ChatMessage(
                id: '0',
                content:
                    '🔄 Chat reset! Ask me anything about Coimbatore transport.',
                isUser: false,
                timestamp: DateTime.now(),
              ),
            );
          },
        ),
      ],
    ),
    body: Column(
      children: [
        // Quick prompts
        SizedBox(
          height: 44,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            scrollDirection: Axis.horizontal,
            children:
                [
                      '🗺️ Find route',
                      '⏰ Bus timings',
                      '💰 Fare info',
                      '🚌 Crowded buses',
                      '🌙 Night service',
                    ]
                    .map(
                      (p) => GestureDetector(
                        onTap: () => _send(p.substring(3)),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.bgCard,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.cyan.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            p,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textL,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
          ),
        ),
        Container(height: 1, color: AppColors.border),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length,
            itemBuilder: (_, i) => _bubble(_msgs[i]),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
          decoration: const BoxDecoration(
            color: AppColors.bgCard,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: AppColors.textW, fontSize: 13),
                  maxLines: null,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ask about routes, fares, schedules...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _sending ? null : _send,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _sending ? AppColors.bgCard2 : AppColors.cyan,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _sending ? Icons.hourglass_empty : Icons.send,
                    color: _sending ? AppColors.textM : AppColors.bg,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _bubble(ChatMessage m) {
    if (m.isLoading) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.cyan.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyan,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Thinking...',
                style: TextStyle(color: AppColors.textM, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: m.isUser ? AppColors.cyan : AppColors.bgCard,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(m.isUser ? 14 : 2),
            bottomRight: Radius.circular(m.isUser ? 2 : 14),
          ),
          border: m.isUser
              ? null
              : Border.all(color: AppColors.cyan.withOpacity(0.12)),
        ),
        child: Text(
          m.content,
          style: TextStyle(
            color: m.isUser ? AppColors.bg : AppColors.textL,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

// ── COMMUTER PROFILE ──────────────────────────────────────────────────────────
class CommuterProfile extends StatelessWidget {
  const CommuterProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user!;
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.bg,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.bgCard2, AppColors.bg],
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
                                color: AppColors.cyan.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.cyan.withOpacity(0.3),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  user.name[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.cyan,
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
                                const SizedBox(height: 4),
                                StatusPill(status: 'active'),
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
                Row(
                  children: [
                    Expanded(
                      child: GCard(
                        accent: AppColors.cyan,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            const Text('🚌', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              '${user.totalTrips}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.cyan,
                                fontFamily: 'SpaceGrotesk',
                              ),
                            ),
                            const Text(
                              'Total Trips',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textM,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GCard(
                        accent: AppColors.amber,
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            const Text('⭐', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            const Text(
                              '4.8',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.amber,
                                fontFamily: 'SpaceGrotesk',
                              ),
                            ),
                            const Text(
                              'Rating',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textM,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                SectionHead(title: 'Commute Setup'),
                const SizedBox(height: 10),
                GCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _row(
                        '🏠 Home Stop',
                        user.homeStop.isEmpty ? 'Not set' : user.homeStop,
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _row(
                        '🏢 Work Stop',
                        user.workStop.isEmpty ? 'Not set' : user.workStop,
                      ),
                      const Divider(height: 20, color: AppColors.border),
                      _row(
                        '📞 Phone',
                        user.phone.isEmpty ? 'Not set' : user.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                SectionHead(title: 'My Complaints'),
                const SizedBox(height: 10),
                _UserComplaints(userId: user.id!),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showComplaint(context, user.id!),
                    icon: const Icon(Icons.report_outlined, size: 16),
                    label: const Text('File a Complaint'),
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

  void _showComplaint(BuildContext context, int uid) {
    final desc = TextEditingController();
    String cat = 'delay';
    showModalBottomSheet(
      context: context,
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
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: StatefulBuilder(
          builder: (_, sBS) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'File Complaint',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textW,
                  fontFamily: 'SpaceGrotesk',
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children:
                    [
                          'delay',
                          'overcrowding',
                          'driver_behavior',
                          'cleanliness',
                          'other',
                        ]
                        .map(
                          (c) => GestureDetector(
                            onTap: () => sBS(() => cat = c),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: cat == c
                                    ? AppColors.cyan.withOpacity(0.15)
                                    : AppColors.bgCard2,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: cat == c
                                      ? AppColors.cyan
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                c.replaceAll('_', ' '),
                                style: TextStyle(
                                  color: cat == c
                                      ? AppColors.cyan
                                      : AppColors.textM,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desc,
                maxLines: 4,
                style: const TextStyle(color: AppColors.textW, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Describe the issue in detail...',
                  labelText: 'Description',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    if (desc.text.isEmpty) return;
                    await context.read<TransportProvider>().addComplaint(
                      Complaint(
                        userId: uid,
                        category: cat,
                        description: desc.text,
                        submittedAt: DateTime.now(),
                      ),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ Complaint submitted successfully'),
                      ),
                    );
                  },
                  child: const Text('SUBMIT COMPLAINT'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UserComplaints extends StatelessWidget {
  final int userId;
  const _UserComplaints({required this.userId});

  @override
  Widget build(BuildContext context) => FutureBuilder<List<Complaint>>(
    future: context.read<TransportProvider>().userComplaints(userId),
    builder: (_, snap) {
      if (!snap.hasData) return const Shimmer(h: 60);
      if (snap.data!.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No complaints yet',
            style: TextStyle(color: AppColors.textM),
            textAlign: TextAlign.center,
          ),
        );
      }
      return Column(
        children: snap.data!
            .take(3)
            .map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.category.replaceAll('_', ' ').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textM,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            c.description,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textL,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    StatusPill(status: c.status),
                  ],
                ),
              ),
            )
            .toList(),
      );
    },
  );
}

import 'package:flutter/material.dart';
import '../utils/theme.dart';
import '../models/models.dart';

// ── GLASS CARD ────────────────────────────────────────────────────────────────
class GCard extends StatelessWidget {
  final Widget child;
  final Color? accent;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final double radius;

  const GCard({
    super.key,
    required this.child,
    this.accent,
    this.padding,
    this.onTap,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: (accent ?? AppColors.cyan).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (accent ?? AppColors.cyan).withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    ),
  );
}

// ── STAT TILE ────────────────────────────────────────────────────────────────
class StatTile extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  final String? badge;
  const StatTile({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => GCard(
    accent: color,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 10, color: AppColors.textM),
        ),
      ],
    ),
  );
}

// ── ROUTE CARD ────────────────────────────────────────────────────────────────
class RouteCard extends StatelessWidget {
  final BusRoute route;
  final VoidCallback? onTap;
  final bool compact;
  const RouteCard({
    super.key,
    required this.route,
    this.onTap,
    this.compact = false,
  });

  Color get _c => AppColors.routeColor(route.colorIndex);

  @override
  Widget build(BuildContext context) => GCard(
    accent: _c,
    onTap: onTap,
    padding: EdgeInsets.all(compact ? 12.0 : 16.0),
    child: compact ? _compact() : _full(),
  );

  Widget _full() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          _tag(route.routeNumber, _c),
          const SizedBox(width: 8),
          _statusDot(route.status),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.bgCard2,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              route.category.toUpperCase(),
              style: const TextStyle(
                color: AppColors.textM,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        route.routeName,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textW,
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              route.startStop,
              style: const TextStyle(fontSize: 12, color: AppColors.textL),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Divider(
              color: _c.withOpacity(0.3),
              thickness: 1,
              endIndent: 6,
            ),
          ),
          Icon(Icons.location_on, color: _c, size: 12),
          const SizedBox(width: 3),
          Expanded(
            child: Text(
              route.endStop,
              style: const TextStyle(fontSize: 12, color: AppColors.textL),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          _chip(Icons.schedule, '${route.durationMin}m'),
          const SizedBox(width: 6),
          _chip(Icons.currency_rupee, '${route.fare.toInt()}'),
          const SizedBox(width: 6),
          _chip(Icons.straighten, '${route.distanceKm}km'),
          const Spacer(),
          _chip(Icons.directions_bus, '${route.freqPerHour}/hr'),
        ],
      ),
    ],
  );

  Widget _compact() => Row(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: _c.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            route.routeNumber,
            style: TextStyle(
              color: _c,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              route.routeName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textW,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${route.startStop} → ${route.endStop}',
              style: const TextStyle(fontSize: 11, color: AppColors.textM),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${route.fare.toInt()}',
            style: TextStyle(
              color: _c,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          Text(
            '${route.durationMin}m',
            style: const TextStyle(color: AppColors.textM, fontSize: 11),
          ),
        ],
      ),
    ],
  );

  Widget _tag(String t, Color c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(8)),
    child: Text(
      t,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 12,
      ),
    ),
  );

  Widget _statusDot(String s) {
    final c = s == 'active'
        ? AppColors.green
        : s == 'maintenance'
        ? AppColors.amber
        : AppColors.red;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            s.toUpperCase(),
            style: TextStyle(
              color: c,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(IconData i, String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: AppColors.bgCard2,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(i, size: 10, color: AppColors.textM),
        const SizedBox(width: 3),
        Text(t, style: const TextStyle(fontSize: 10, color: AppColors.textL)),
      ],
    ),
  );
}

// ── BUS CARD ─────────────────────────────────────────────────────────────────
class BusCard extends StatelessWidget {
  final Bus bus;
  final VoidCallback? onTap;
  const BusCard({super.key, required this.bus, this.onTap});

  Color get _statusColor => bus.status == 'running'
      ? AppColors.green
      : bus.status == 'parked'
      ? AppColors.blue
      : bus.status == 'maintenance'
      ? AppColors.amber
      : AppColors.red;

  @override
  Widget build(BuildContext context) => GCard(
    accent: _statusColor,
    onTap: onTap,
    padding: const EdgeInsets.all(14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              bus.busNumber,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textW,
                fontFamily: 'SpaceGrotesk',
              ),
            ),
            StatusPill(status: bus.status),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${bus.model} • ${bus.busType} • ${bus.year}',
          style: const TextStyle(fontSize: 11, color: AppColors.textM),
        ),
        const SizedBox(height: 8),
        Text(
          '📍 ${bus.currentStop}',
          style: const TextStyle(fontSize: 12, color: AppColors.textL),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _meter(
                'Occupancy',
                bus.occupancy / 100,
                '${bus.currentPassengers}/${bus.capacity}',
                bus.isCrowded ? AppColors.red : AppColors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _meter(
                'Fuel',
                bus.fuelLevel / 100,
                '${bus.fuelLevel.toInt()}%',
                bus.fuelLevel < 25 ? AppColors.red : AppColors.green,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _meter(String label, double val, String text, Color c) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, color: AppColors.textM),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 9,
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 3),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: val,
          minHeight: 5,
          backgroundColor: AppColors.bgCard2,
          valueColor: AlwaysStoppedAnimation(c),
        ),
      ),
    ],
  );
}

// ── STATUS PILL ───────────────────────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  final String status;
  const StatusPill({super.key, required this.status});

  Color get _c =>
      status == 'active' || status == 'running' || status == 'resolved'
      ? AppColors.green
      : status == 'parked' || status == 'pending'
      ? AppColors.blue
      : status == 'maintenance' || status == 'in_review'
      ? AppColors.amber
      : AppColors.red;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: _c.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _c.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: BoxDecoration(color: _c, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          status.replaceAll('_', ' ').toUpperCase(),
          style: TextStyle(
            color: _c,
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ],
    ),
  );
}

// ── APP TEXT FIELD ────────────────────────────────────────────────────────────
class AppField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData? icon;
  final bool obscure;
  final String? Function(String?)? validator;
  final TextInputType? keyType;
  final int? maxLines;
  final bool readOnly;
  final VoidCallback? onTap;
  final Widget? suffix;
  final void Function(String)? onChange;
  const AppField({
    super.key,
    required this.ctrl,
    required this.label,
    this.icon,
    this.obscure = false,
    this.validator,
    this.keyType,
    this.maxLines,
    this.readOnly = false,
    this.onTap,
    this.suffix,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: ctrl,
    obscureText: obscure,
    validator: validator,
    keyboardType: keyType,
    maxLines: obscure ? 1 : maxLines ?? 1,
    readOnly: readOnly,
    onTap: onTap,
    onChanged: onChange,
    style: const TextStyle(color: AppColors.textW, fontSize: 14),
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 18) : null,
      suffix: suffix,
    ),
  );
}

// ── SECTION HEADER ────────────────────────────────────────────────────────────
class SectionHead extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  final Color? color;
  const SectionHead({
    super.key,
    required this.title,
    this.action,
    this.onAction,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: color ?? AppColors.cyan,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textW,
              fontFamily: 'SpaceGrotesk',
            ),
          ),
        ],
      ),
      if (action != null)
        GestureDetector(
          onTap: onAction,
          child: Text(
            action!,
            style: TextStyle(
              color: color ?? AppColors.cyan,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
    ],
  );
}

// ── SHIMMER ────────────────────────────────────────────────────────────────────
class Shimmer extends StatefulWidget {
  final double h, w;
  const Shimmer({super.key, this.h = 80, this.w = double.infinity});
  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _a = Tween<double>(
      begin: 0.3,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _a,
    builder: (_, _) => Container(
      height: widget.h,
      width: widget.w,
      decoration: BoxDecoration(
        color: AppColors.bgCard2.withOpacity(_a.value),
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// ── STOP PICKER SHEET ──────────────────────────────────────────────────────────
const kStops = [
  'Gandhipuram Central',
  'Town Hall',
  'Clock Tower',
  'Collectorate',
  'Nehru Stadium',
  'Peelamedu',
  'Avinashi Road',
  'RS Puram Terminal',
  'Coimbatore Airport',
  'Sai Baba Colony',
  'DB Road',
  'Ukkadam Bus Stand',
  'Singanallur',
  'Saravanampatti',
  'Kalapatti',
  'Kavundampalayam',
  'Ganapathy',
  'Podanur Junction',
  'Tidel Park IT Zone',
  'HPCL Junction',
  'Hopes College',
  'Cross Cut Road',
  'Oppanakara Street',
  'Coimbatore Junction',
  'TNAU Campus Gate',
  'Agricultural College',
  'SNR Sons College',
  'Mettupalayam Road',
  'Velandipalayam',
  'Kovaipudur',
  'Race Course',
  'Sowripalayam',
  'Ondipudur',
  'Trichy Road End',
  'Katcheri Road',
  'Wheat House',
  'Municipal Office',
  'Vellalore',
];

void showStopPicker(
  BuildContext ctx,
  TextEditingController ctrl, {
  VoidCallback? onDone,
}) {
  final search = TextEditingController();
  List<String> filtered = List.from(kStops);
  showModalBottomSheet(
    context: ctx,
    backgroundColor: AppColors.bgCard,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => StatefulBuilder(
      builder: (_, sBS) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.72,
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textM,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Stop',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textW,
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: search,
                autofocus: true,
                style: const TextStyle(color: AppColors.textW),
                onChanged: (q) => sBS(
                  () => filtered = kStops
                      .where((s) => s.toLowerCase().contains(q.toLowerCase()))
                      .toList(),
                ),
                decoration: const InputDecoration(
                  hintText: 'Search stop...',
                  prefixIcon: Icon(Icons.search, size: 18),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (_, i) => ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppColors.textM,
                    size: 18,
                  ),
                  title: Text(
                    filtered[i],
                    style: const TextStyle(
                      color: AppColors.textW,
                      fontSize: 13,
                    ),
                  ),
                  onTap: () {
                    ctrl.text = filtered[i];
                    Navigator.pop(ctx);
                    onDone?.call();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/models.dart';

class GeminiService {
  // ⚠️ REPLACE WITH YOUR ACTUAL GEMINI API KEY
  static const _apiKey = "YOUR_API_KEY";

  late final GenerativeModel _model;
  late ChatSession _chat;
  bool _initialized = false;

  void _init() {
    if (_initialized) return;
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',  
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.8,
        maxOutputTokens: 800,
        topP: 0.95,
        topK: 40,
      ),
    );
    _chat = _model.startChat(
      history: [
        Content.text(
          '''You are an intelligent transport assistant for Smart City Transit System in Coimbatore, India.
      You help commuters find bus routes, check schedules, understand fares, and plan journeys.
      Keep responses concise, friendly, and use emojis. Always mention route numbers when relevant.
      Fare info: ₹10-22 based on distance. Peak hours: 7:30-10 AM and 5-8 PM.
      Currency is ₹ (Indian Rupee). All times are IST.''',
        ),
        Content.model([
          TextPart(
            'I\'m your Smart City Transport Assistant! I can help you find routes, check schedules, and plan your journey around Coimbatore. What would you like to know? 🚌',
          ),
        ]),
      ],
    );
    _initialized = true;
  }

  Future<String> chat(
    String msg, {
    required List<BusRoute> routes,
    required AppUser user,
  }) async {
    _init();
    final routeCtx = routes
        .take(8)
        .map(
          (r) =>
              '• Route ${r.routeNumber} (${r.category}): ${r.startStop} → ${r.endStop} | ₹${r.fare} | ${r.durationMin}min | ${r.status}',
        )
        .join('\n');

    final prompt =
        '''Context:
User: ${user.name} | Home: ${user.homeStop.isEmpty ? 'not set' : user.homeStop} | Work: ${user.workStop.isEmpty ? 'not set' : user.workStop}

Active Routes:
$routeCtx

User message: $msg

Respond helpfully based on above context. If asking about a route, provide specific details.''';

    try {
      final res = await _chat.sendMessage(Content.text(prompt));
      return res.text ?? 'Sorry, I couldn\'t process that. Please try again.';
    } catch (e) {
      return _offline(msg, routes);
    }
  }

  Future<String> recommend({
    required String from,
    required String to,
    required List<BusRoute> routes,
  }) async {
    _init();
    final direct = routes
        .where(
          (r) =>
              r.stops.any(
                (s) => s.toLowerCase().contains(from.toLowerCase()),
              ) &&
              r.stops.any((s) => s.toLowerCase().contains(to.toLowerCase())) &&
              r.status == 'active',
        )
        .toList();

    if (direct.isEmpty) {
      return '''🔍 No direct route found from **$from** to **$to**

💡 **Suggestions:**
• Try searching for major nearby stops like Gandhipuram Central or Town Hall
• Consider Route 5E (City Circular) to reach central stops, then transfer
• Check if stop names match exactly

📞 Transport Helpline: **1800-425-1234**
⏰ Available: 6 AM – 10 PM daily''';
    }

    try {
      final ctx = direct
          .map(
            (r) =>
                'Route ${r.routeNumber}: ${r.stops.join(" → ")} | ₹${r.fare} | ${r.durationMin}min | ${r.freqPerHour}/hr',
          )
          .join('\n');

      final res = await _model.generateContent([
        Content.text('''Recommend the best bus route from $from to $to.
Routes found:
$ctx

Give:
1. Best route (bold the route number)
2. Why it's best
3. Travel tips (peak hour advice, wait time)
4. Fare and duration
Keep it concise with emojis.'''),
      ]);
      return res.text ?? _fallbackRec(from, to, direct.first);
    } catch (_) {
      return _fallbackRec(from, to, direct.first);
    }
  }

  Future<String> analyzeRoute(BusRoute r) async {
    _init();
    try {
      final res = await _model.generateContent([
        Content.text(
          '''Analyze Route ${r.routeNumber} (${r.routeName}) for a commuter:
Stops: ${r.stops.join(' → ')}
Frequency: ${r.freqPerHour}/hr | Hours: ${r.operatingHours} | Fare: ₹${r.fare} | ${r.durationMin}min

Provide:
1. Best travel windows
2. Peak hour behavior
3. 2-3 practical tips
Short, bullet format with emojis.''',
        ),
      ]);
      return res.text ?? _fallbackAnalysis(r);
    } catch (_) {
      return _fallbackAnalysis(r);
    }
  }

  void reset() {
    _initialized = false;
    _init();
  }

  String _fallbackRec(String from, String to, BusRoute r) =>
      '''✅ **Recommended: Route ${r.routeNumber}**
📍 ${r.routeName}

🛣️ ${r.stops.join(' → ')}
💰 Fare: ₹${r.fare}
⏱️ Duration: ${r.durationMin} minutes
🚌 Frequency: ${r.freqPerHour} buses/hour
🕐 Operating: ${r.operatingHours}

💡 Tip: Arrive 5 min early. Avoid peak hours (8-10 AM, 5-8 PM) if possible.''';

  String _fallbackAnalysis(BusRoute r) =>
      '''📊 **Route ${r.routeNumber} Analysis**

⏰ Operating: ${r.operatingHours}
🚌 Frequency: ${r.freqPerHour} buses/hour (wait ~${60 ~/ r.freqPerHour} min)
💰 Fare: ₹${r.fare}
📏 Distance: ${r.distanceKm} km | ${r.durationMin} min

🟡 **Peak Hours** (8-10 AM, 5-8 PM): Expect 20-30% more passengers
✅ **Best Time**: 10 AM–4 PM for comfortable travel
💡 Tip: Use City Circular (5E) to connect to this route if needed.''';

  String _offline(String msg, List<BusRoute> routes) {
    final lower = msg.toLowerCase();
    if (lower.contains('route') || lower.contains('bus')) {
      final list = routes
          .take(5)
          .map(
            (r) =>
                '• Route ${r.routeNumber}: ${r.startStop} → ${r.endStop} (₹${r.fare})',
          )
          .join('\n');
      return '🚌 **Available Routes:**\n$list\n\nAsk me about a specific route or destination!';
    }
    if (lower.contains('fare') ||
        lower.contains('cost') ||
        lower.contains('price')) {
      return '💰 **Fares:**\n• City Routes: ₹10–16\n• Express: ₹14–22\n• Circular (5E): ₹10\n• Night Service: ₹22\nChildren under 5: FREE | Students: 50% off';
    }
    if (lower.contains('time') ||
        lower.contains('schedule') ||
        lower.contains('when')) {
      return '⏰ **Service Hours:**\n• Day Routes: 5:00 AM – 11:00 PM\n• Night Express (8N): 9 PM – 5 AM\n• Circular (5E): 6 AM – 9 PM\n\n🔴 Peak: 7:30-10 AM & 5-8 PM (expect delays)\n🟢 Best: 10 AM – 4 PM';
    }
    return '👋 Hi! I can help with:\n🗺️ Finding routes between stops\n⏰ Schedules and timings\n💰 Fare information\n🚌 Bus status\n\nTry: "How to get from Airport to Town Hall?"';
  }
}

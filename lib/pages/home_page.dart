import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/temperature_service.dart';
import '../services/weather_service.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});
  @override State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with SingleTickerProviderStateMixin {
  final _svc = WeatherService();
  WeatherData? _data;
  List<DailyForecast>? _forecast;
  bool    _loading = false;
  String? _error;

  late AnimationController _ac;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    TemperatureService.instance.isCelsius.addListener(_onUnitChanged);
    _ac   = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _load(Config.defaultCity);
  }

  void _onUnitChanged() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    TemperatureService.instance.isCelsius.removeListener(_onUnitChanged);
    _ac.dispose(); super.dispose();
  }

  Future<void> _load(String city) async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _svc.fetch(city),
        _svc.fetchForecast(city),
      ]);
      if (!mounted) return;
      setState(() {
        _data     = results[0] as WeatherData;
        _forecast = results[1] as List<DailyForecast>;
        _loading  = false;
      });
      _ac.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  // Inside _WeatherHomePageState

  // ── Menu drawer function ──────────────────────────────────
  void _openMenu() {
    final isC = TemperatureService.instance.isCelsius.value;
    showModalBottomSheet(
      context: context,
      backgroundColor: C.card2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: C.muted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _menuItem(ctx, Icons.home_rounded,       'Home'),
            SwitchListTile(
              secondary: Icon(isC ? Icons.thermostat_rounded : Icons.thermostat_rounded,
                  color: C.accent),
              title: const Text('°C / °F', style: TextStyle(color: C.white)),
              subtitle: Text(isC ? 'Celsius' : 'Fahrenheit',
                  style: const TextStyle(color: C.grey, fontSize: 12)),
              value: isC,
              activeTrackColor: C.accent.withValues(alpha: 0.4),
              activeThumbColor: C.accent,
              onChanged: (_) {
                Navigator.pop(ctx);
                TemperatureService.instance.toggle();
              },
            ),
            _menuItem(ctx, Icons.info_outline_rounded,'About'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext ctx, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: C.accent),
      title: Text(label, style: const TextStyle(color: C.white)),
      onTap: () => Navigator.pop(ctx),
    );
  }

// ── Calendar function ─────────────────────────────────────
  void _openCalendar() {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 7)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: C.accent,
            surface: C.card2,
          ),
        ),
        child: child!,
      ),
    );
  }

  Future<void> _pickCity() async {
    final ctrl = TextEditingController();
    final city = await showDialog<String>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => AlertDialog(
        backgroundColor: C.card2,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        title: const Text('Change City',
            style: TextStyle(color: C.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: C.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: InputDecoration(
            hintText: 'e.g. Imus, Cavite...',
            hintStyle: const TextStyle(color: C.muted),
            filled: true,
            fillColor: C.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.search, color: C.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: C.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: C.accent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(ctx, ctrl.text),
            child: const Text('Search',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (city != null && city.trim().isNotEmpty) _load(city.trim());
  }

  @override
  Widget build(BuildContext context) {
    final top   = MediaQuery.of(context).padding.top;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: C.bg,
      body: Column(children: [
        SizedBox(height: top),
        // Replace old TopBar(...) with:
        TopBar(
          data        : _data,
          onCityTap   : _pickCity,
          onMenuTap   : _openMenu,
          onCalendarTap: _openCalendar,
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(
              color: C.accent, strokeWidth: 2.5))
              : _error != null
              ? ErrorView(message: _error!,
            onRetry: () => _load(_data?.cityName ?? Config.defaultCity),
          )
              : _data != null
              ? FadeTransition(
              opacity: _fade,
               child: _HomeBody(data: _data!, width: width, forecast: _forecast))
              : const SizedBox(),
        ),
      ]),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final WeatherData data;
  final double width;
  final List<DailyForecast>? forecast;
  const _HomeBody({required this.data, required this.width, this.forecast});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(
                horizontal: Dims.pagePadding),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 8),
                WeatherIcon(iconUrl: data.iconUrl),
                const SizedBox(height: 10),
                _TempDisplay(temp: data.temperature),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Expect ${data.capDesc} today.',
                    style: TextStyle(
                        color: C.grey, fontSize: R.font(context, 14)),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                StatRow(data: data),
                const SizedBox(height: Dims.sectionGap),
                const SectionTitle(title: 'Hourly Forecast'),
                const SizedBox(height: 12),
                HourlyList(hourly: data.hourly),
                const SizedBox(height: Dims.sectionGap),
                if (forecast != null && forecast!.isNotEmpty) ...[
                  const SectionTitle(title: '5-Day Forecast'),
                  const SizedBox(height: 12),
                  DailyForecastWidget(forecast: forecast!),
                  const SizedBox(height: Dims.sectionGap),
                ],
                DetailsCard(data: data),
                const SizedBox(height: 24),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Temp Display ────────────────────────────────────────────────────────────

class _TempDisplay extends StatelessWidget {
  final double temp;
  const _TempDisplay({required this.temp});

  @override
  Widget build(BuildContext context) {
    final t = TemperatureService.instance;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${t.convert(temp).round()}',
            style: TextStyle(
              color: C.white,
              fontSize: R.font(context, 86),
              fontWeight: FontWeight.w200,
              height: 1,
            )),
        Padding(
          padding: EdgeInsets.only(top: R.w(context, 16)),
          child: Text(t.unit(),
              style: TextStyle(
                color: C.white,
                fontSize: R.font(context, 30),
                fontWeight: FontWeight.w300,
              )),
        ),
      ],
    );
  }
}
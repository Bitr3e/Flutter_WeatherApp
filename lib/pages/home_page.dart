import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/location_service.dart';
import '../services/temperature_service.dart';
import '../services/theme_service.dart';
import '../services/weather_service.dart';
import '../utils/utils.dart';
import '../widgets/widgets.dart';

class WeatherHomePage extends StatefulWidget {
  final List<String> cities;
  const WeatherHomePage({super.key, required this.cities});
  @override State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with SingleTickerProviderStateMixin {
  late final PageController _pageCtrl;
  final _svc = WeatherService();
  WeatherData? _data;
  List<DailyForecast>? _forecast;
  bool    _loading = false;
  String? _error;
  int     _cityIdx = 0;

  late AnimationController _ac;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    TemperatureService.instance.isCelsius.addListener(_onUnitChanged);
    _pageCtrl = PageController();
    _ac   = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _initLoad();
  }

  Future<void> _initLoad() async {
    if (widget.cities.length > 1) {
      _load(widget.cities.first);
      return;
    }
    final pos = await LocationService.instance.getCurrentPosition();
    if (pos != null && mounted) {
      _loadByCoords(pos.latitude, pos.longitude);
    } else if (mounted) {
      _load(Config.defaultCity);
    }
  }

  Future<void> _loadByCoords(double lat, double lon) async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await _svc.fetchByCoords(lat, lon);
      if (!mounted) return;
      final f = await _svc.fetchForecast(d.cityName);
      if (!mounted) return;
      setState(() {
        _data     = d;
        _forecast = f;
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

  void _onUnitChanged() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    TemperatureService.instance.isCelsius.removeListener(_onUnitChanged);
    _pageCtrl.dispose(); _ac.dispose(); super.dispose();
  }

  void _onPageChanged(int idx) {
    if (idx == _cityIdx) return;
    setState(() => _cityIdx = idx);
    _load(widget.cities[idx]);
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
              title: Text('°C / °F', style: TextStyle(color: C.white)),
              subtitle: Text(isC ? 'Celsius' : 'Fahrenheit',
                  style: TextStyle(color: C.grey, fontSize: 12)),
              value: isC,
              activeTrackColor: C.accent.withValues(alpha: 0.4),
              activeThumbColor: C.accent,
              onChanged: (_) {
                Navigator.pop(ctx);
                TemperatureService.instance.toggle();
              },
            ),
            SwitchListTile(
              secondary: Icon(
                ThemeService.instance.isDark.value
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                color: C.accent,
              ),
              title: Text(
                ThemeService.instance.isDark.value ? 'Dark Mode' : 'Light Mode',
                style: TextStyle(color: C.white),
              ),
              value: ThemeService.instance.isDark.value,
              activeTrackColor: C.accent.withValues(alpha: 0.4),
              activeThumbColor: C.accent,
              onChanged: (_) {
                Navigator.pop(ctx);
                ThemeService.instance.toggle();
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline_rounded, color: C.accent),
              title: Text('About', style: TextStyle(color: C.white)),
              onTap: () {
                Navigator.pop(ctx);
                _openAbout();
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext ctx, IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: C.accent),
      title: Text(label, style: TextStyle(color: C.white)),
      onTap: () => Navigator.pop(ctx),
    );
  }

// ── About dialog ──────────────────────────────────────────
  void _openAbout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: C.card2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
            Icon(Icons.cloud_rounded, color: C.accent, size: 48),
            const SizedBox(height: 12),
            Text('Weather App',
                style: TextStyle(
                  color: C.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 4),
            Text('Version 1.0.0',
                style: TextStyle(color: C.grey, fontSize: 13)),
            const SizedBox(height: 20),
            Container(height: 1, color: C.divider),
            const SizedBox(height: 20),
            Text('Developed by',
                style: TextStyle(color: C.grey, fontSize: 12)),
            const SizedBox(height: 12),
            _creditTile('John Brence Condesa'),
            _creditTile('Reymart Dela Cruz'),
            _creditTile('Carl Andre De Castro'),
            _creditTile('Scott Franklin Maher'),
          ],
        ),
      ),
    );
  }

  Widget _creditTile(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Icon(Icons.person_rounded, color: C.accent, size: 18),
        const SizedBox(width: 10),
        Text(name,
            style: TextStyle(
                color: C.white, fontSize: 15, fontWeight: FontWeight.w500)),
      ]),
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
          colorScheme: ColorScheme.dark(
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
        title: Text('Change City',
            style: TextStyle(color: C.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: TextStyle(color: C.white),
          textInputAction: TextInputAction.search,
          onSubmitted: (v) => Navigator.pop(ctx, v),
          decoration: InputDecoration(
            hintText: 'e.g. Imus, Cavite...',
            hintStyle: TextStyle(color: C.muted),
            filled: true,
            fillColor: C.bg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(Icons.search, color: C.grey),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
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
    final multi = widget.cities.length > 1;

    Widget body = _loading
        ? Center(child: CircularProgressIndicator(
        color: C.accent, strokeWidth: 2.5))
        : _error != null
        ? ErrorView(message: _error!,
      onRetry: () => _load(_data?.cityName ?? widget.cities[_cityIdx]),
    )
        : _data != null
        ? FadeTransition(
        opacity: _fade,
        child: _HomeBody(
          data: _data!,
          width: width,
          forecast: _forecast,
          onRefresh: () => _load(_data!.cityName),
        ))
        : const SizedBox();

    if (multi) {
      body = Column(children: [
        Expanded(
          child: PageView(
            controller: _pageCtrl,
            onPageChanged: _onPageChanged,
            children: widget.cities.map((_) => body).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.cities.length, (i) =>
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _cityIdx == i ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _cityIdx == i ? C.accent : C.muted,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
      ]);
    }

    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(children: [
        if (_data != null)
          WeatherBackground(iconCode: _data!.icon),
        Column(children: [
          SizedBox(height: top),
          TopBar(
            data        : _data,
            onCityTap   : _pickCity,
            onMenuTap   : _openMenu,
            onCalendarTap: _openCalendar,
          ),
          Expanded(child: body),
        ]),
      ]),
    );
  }
}

// ─── Body ────────────────────────────────────────────────────────────────────

class _HomeBody extends StatelessWidget {
  final WeatherData data;
  final double width;
  final List<DailyForecast>? forecast;
  final Future<void> Function() onRefresh;
  const _HomeBody({
    required this.data,
    required this.width,
    this.forecast,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RefreshIndicator(
        color: C.accent,
        backgroundColor: C.card,
        onRefresh: onRefresh,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
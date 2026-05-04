import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
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
  bool    _loading = false;
  String? _error;

  // Single lightweight fade — safe for Mali-G52 GPU
  late AnimationController _ac;
  late Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ac   = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOut);
    _load(Config.defaultCity);
  }

  @override
  void dispose() { _ac.dispose(); super.dispose(); }

  Future<void> _load(String city) async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await _svc.fetch(city);
      if (!mounted) return;
      setState(() { _data = d; _loading = false; });
      _ac.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
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
        TopBar(data: _data, onCityTap: _pickCity),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator(
              color: C.accent, strokeWidth: 2.5))
              : _error != null
              ? ErrorView(message: _error!)
              : _data != null
              ? FadeTransition(
              opacity: _fade,
              child: _HomeBody(data: _data!, width: width))
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
  const _HomeBody({required this.data, required this.width});

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${temp.round()}',
            style: TextStyle(
              color: C.white,
              fontSize: R.font(context, 86),
              fontWeight: FontWeight.w200,
              height: 1,
            )),
        Padding(
          padding: EdgeInsets.only(top: R.w(context, 16)),
          child: Text('°C',
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
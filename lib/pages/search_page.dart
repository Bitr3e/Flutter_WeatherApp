import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/temperature_service.dart';
import '../services/weather_service.dart';
import '../utils/utils.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _ctrl = TextEditingController();
  final _svc  = WeatherService();
  WeatherData? _result;
  bool    _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    TemperatureService.instance.isCelsius.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  Future<void> _search() async {
    final city = _ctrl.text.trim();
    if (city.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() { _loading = true; _error = null; });
    try {
      final d = await _svc.fetch(city);
      if (!mounted) return;
      setState(() { _result = d; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error   = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: Padding(
        padding: EdgeInsets.fromLTRB(
            Dims.pagePadding, top + 14, Dims.pagePadding, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search',
                style: TextStyle(
                  color: C.white,
                  fontSize: R.font(context, 26),
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(
                      color: C.white, fontSize: R.font(context, 14)),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: const TextStyle(color: C.muted),
                    filled: true,
                    fillColor: C.card,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon:
                    const Icon(Icons.search_rounded, color: C.grey),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _search,
                child: Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: C.accent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                  const Icon(Icons.search, color: Colors.white, size: 22),
                ),
              ),
            ]),
            const SizedBox(height: 22),
            if (_loading)
              const Center(child: CircularProgressIndicator(
                  color: C.accent, strokeWidth: 2.5))
            else if (_error != null)
              Center(
                child: Text(_error!,
                    style: const TextStyle(color: C.grey),
                    textAlign: TextAlign.center),
              )
            else if (_result != null)
                _ResultCard(data: _result!),
          ],
        ),
      ),
    );
  }
}

// ─── Result Card ─────────────────────────────────────────────────────────────

class _ResultCard extends StatelessWidget {
  final WeatherData data;
  const _ResultCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final t = TemperatureService.instance;
    return Container(
      padding: const EdgeInsets.all(Dims.cardPadding),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(Dims.cardRadius),
        border: Border.all(color: C.divider),
      ),
      child: Row(children: [
        Image.network(data.iconUrl, width: 68, height: 68,
            errorBuilder: (_, __, ___) =>
            const Icon(Icons.cloud, color: C.grey, size: 60)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${data.cityName}, ${data.country}',
                  style: TextStyle(
                    color: C.white,
                    fontSize: R.font(context, 16),
                    fontWeight: FontWeight.bold,
                  )),
              Text(data.capDesc,
                  style: TextStyle(
                      color: C.grey, fontSize: R.font(context, 12))),
              const SizedBox(height: 6),
              Row(children: [
                Text('${t.convert(data.temperature).round()}${t.unit()}',
                    style: TextStyle(
                      color: C.white,
                      fontSize: R.font(context, 32),
                      fontWeight: FontWeight.w200,
                    )),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('H: ${t.convert(data.tempMax).round()}°',
                        style: TextStyle(
                            color: C.grey,
                            fontSize: R.font(context, 12))),
                    Text('L: ${t.convert(data.tempMin).round()}°',
                        style: TextStyle(
                            color: C.grey,
                            fontSize: R.font(context, 12))),
                  ],
                ),
              ]),
            ],
          ),
        ),
      ]),
    );
  }
}
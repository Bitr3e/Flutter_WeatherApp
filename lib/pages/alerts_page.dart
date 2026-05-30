import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/weather_service.dart';
import '../utils/utils.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final _svc = WeatherService();
  WeatherData? _data;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final d = await _svc.fetch('Manila');
      if (!mounted) return;
      setState(() { _data = d; _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: C.bg,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
            Dims.pagePadding, top + 14, Dims.pagePadding, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Weather Alerts',
                style: TextStyle(
                  color: C.white,
                  fontSize: R.font(context, 26),
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 22),
            if (_loading)
              Center(child: const CircularProgressIndicator(
                  strokeWidth: 2.5))
            else if (_error != null)
              _buildAlert(context, Icons.cloud_off_rounded, 'Unable to load',
                  _error!, C.grey)
            else if (_data != null)
              ..._generateAlerts(context)
            else
              const SizedBox(),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateAlerts(BuildContext context) {
    final desc = _data!.description.toLowerCase();
    final wind = _data!.windSpeed;
    final humidity = _data!.humidity;
    final temp = _data!.temperature;
    final alerts = <Widget>[];

    if (desc.contains('thunderstorm')) {
      alerts.add(_buildAlert(
        context,
        Icons.thunderstorm_rounded,
        'Thunderstorm Warning',
        'Severe thunderstorms detected. Seek shelter and avoid open areas.',
        Colors.orange,
      ));
    }

    if (desc.contains('rain') || desc.contains('drizzle') || humidity > 85) {
      alerts.add(_buildAlert(
        context,
        Icons.water_rounded,
        'Flood Watch',
        'Heavy rainfall may cause flooding in low-lying areas. Stay cautious.',
        Colors.blue,
      ));
    }

    if (wind > 10) {
      alerts.add(_buildAlert(
        context,
        Icons.air_rounded,
        'Strong Wind Advisory',
        'Wind speeds of ${(wind * 3.6).round()} km/h detected. Secure loose objects.',
        C.accent,
      ));
    }

    if (desc.contains('snow') || desc.contains('blizzard')) {
      alerts.add(_buildAlert(
        context,
        Icons.ac_unit_rounded,
        'Snowfall Warning',
        'Snow accumulation expected. Travel may be hazardous.',
        Colors.lightBlue,
      ));
    }

    if (temp > 38) {
      alerts.add(_buildAlert(
        context,
        Icons.whatshot_rounded,
        'Extreme Heat Warning',
        'Temperature reaching ${temp.round()}°C. Stay hydrated and avoid direct sun.',
        Colors.red,
      ));
    }

    if (desc.contains('fog') || desc.contains('mist')) {
      alerts.add(_buildAlert(
        context,
        Icons.blur_on_rounded,
        'Low Visibility Alert',
        'Foggy conditions reducing visibility. Drive carefully.',
        Colors.blueGrey,
      ));
    }

    if (alerts.isEmpty) {
      alerts.add(_buildAlert(
        context,
        Icons.check_circle_outline_rounded,
        'No Active Alerts',
        'Weather conditions appear normal in your area.',
        Colors.green,
      ));
    }

    return alerts;
  }

  Widget _buildAlert(BuildContext context, IconData icon,
      String title, String desc, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Dims.itemGap),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                      color: color,
                      fontSize: R.font(context, 14),
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text(desc,
                    style: TextStyle(
                        color: C.grey, fontSize: R.font(context, 12))),
              ],
            ),
          ),
        ]),
      ),
    );
  }
}

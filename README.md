# Weather App

A Flutter weather application optimized for **Realme C35** (Android 11, FHD+ 1080x2408, 20:9 aspect ratio).

## Features

- **Live Weather** — Current temperature, feels-like, humidity, wind speed, visibility, pressure, and cloud cover for any city
- **Hourly Forecast** — 6-hour lookahead with temperature and weather icons
- **Interactive Globe** — Animated 3D globe with draggable rotation and country pins for instant weather lookup
- **City Search** — Search and save weather for any location worldwide
- **Weather Alerts** — Simulated warning cards for thunderstorm, flood, and strong wind events
- **Responsive Design** — Scales fluidly across screen sizes; locked to portrait orientation
- **Dark Theme** — Deep navy/blue dark UI optimized for AMOLED displays

## Screenshots

<!-- TODO: Add screenshots here -->
| Home | Globe | Search | Alerts |
|------|-------|--------|--------|
|      |       |        |        |

## Setup

1. **Clone the repo**
   ```bash
   git clone https://github.com/Bitr3e/Flutter_WeatherApp.git
   cd Flutter_WeatherApp
   ```

2. **Get dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API key**  
   The app uses OpenWeatherMap's free API. Replace the key in `lib/constants/config.dart`:
   ```dart
   static const weatherApiKey = 'your_api_key_here';
   ```
   Get a free key at [openweathermap.org](https://openweathermap.org/api).

4. **Run**
   ```bash
   flutter run
   ```

## Build

**Debug APK:**
```bash
flutter build apk --debug
```

**Release APK:**
```bash
flutter build apk --release --split-per-abi
```

## Dependencies

- `http` — REST API calls to OpenWeatherMap
- `flutter` — Material Design 3 UI framework

## Project Structure

```
lib/
├── constants/        # Colors, dimensions, config (API key, URLs)
├── models/           # WeatherData, HourlyForecast data classes
├── pages/            # Home, Search, Alerts, Map (globe) screens
├── services/         # WeatherService — HTTP client for OpenWeatherMap
├── utils/            # Responsive scaling, JSON cast helpers, forecast generator
└── widgets/          # Reusable UI components (bottom nav, cards, hourly list, etc.)
```

## License

MIT

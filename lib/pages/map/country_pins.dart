class MapCountryPin {
  final String name;
  final String city;
  final String emoji;
  final double lon;
  final double lat;

  const MapCountryPin({
    required this.name,
    required this.city,
    required this.emoji,
    required this.lon,
    required this.lat,
  });
}

const countryPins = <MapCountryPin>[
  // Asia & Pacific
  MapCountryPin(name:'Philippines', city:'Manila',        emoji:'🇵🇭', lon: 121.0, lat: 14.6),
  MapCountryPin(name:'Japan',       city:'Tokyo',         emoji:'🇯🇵', lon: 139.7, lat: 35.7),
  MapCountryPin(name:'China',       city:'Beijing',       emoji:'🇨🇳', lon: 116.4, lat: 39.9),
  MapCountryPin(name:'India',       city:'New Delhi',     emoji:'🇮🇳', lon: 77.2,  lat: 28.6),
  MapCountryPin(name:'South Korea', city:'Seoul',         emoji:'🇰🇷', lon: 126.9, lat: 37.6),
  MapCountryPin(name:'Thailand',    city:'Bangkok',       emoji:'🇹🇭', lon: 100.5, lat: 13.7),
  MapCountryPin(name:'Indonesia',   city:'Jakarta',       emoji:'🇮🇩', lon: 106.8, lat: -6.2),
  MapCountryPin(name:'Singapore',   city:'Singapore',     emoji:'🇸🇬', lon: 103.8, lat: 1.3),
  MapCountryPin(name:'Australia',   city:'Sydney',        emoji:'🇦🇺', lon: 151.2, lat: -33.9),
  MapCountryPin(name:'UAE',         city:'Dubai',         emoji:'🇦🇪', lon: 55.3,  lat: 25.2),
  MapCountryPin(name:'Saudi Arabia',city:'Riyadh',        emoji:'🇸🇦', lon: 46.7,  lat: 24.7),

  // Europe
  MapCountryPin(name:'UK',          city:'London',        emoji:'🇬🇧', lon: -0.1,  lat: 51.5),
  MapCountryPin(name:'France',      city:'Paris',         emoji:'🇫🇷', lon: 2.3,   lat: 48.9),
  MapCountryPin(name:'Germany',     city:'Berlin',        emoji:'🇩🇪', lon: 13.4,  lat: 52.5),
  MapCountryPin(name:'Italy',       city:'Rome',          emoji:'🇮🇹', lon: 12.5,  lat: 41.9),
  MapCountryPin(name:'Spain',       city:'Madrid',        emoji:'🇪🇸', lon: -3.7,  lat: 40.4),
  MapCountryPin(name:'Russia',      city:'Moscow',        emoji:'🇷🇺', lon: 37.6,  lat: 55.8),

  // Americas
  MapCountryPin(name:'USA',         city:'New York',      emoji:'🇺🇸', lon: -74.0, lat: 40.7),
  MapCountryPin(name:'Canada',      city:'Toronto',       emoji:'🇨🇦', lon: -79.4, lat: 43.7),
  MapCountryPin(name:'Brazil',      city:'Sao Paulo',     emoji:'🇧🇷', lon: -46.6, lat: -23.5),
  MapCountryPin(name:'Mexico',      city:'Mexico City',   emoji:'🇲🇽', lon: -99.1, lat: 19.4),
  MapCountryPin(name:'Argentina',   city:'Buenos Aires',  emoji:'🇦🇷', lon: -58.4, lat: -34.6),

  // Africa
  MapCountryPin(name:'Egypt',       city:'Cairo',         emoji:'🇪🇬', lon: 31.2,  lat: 30.0),
  MapCountryPin(name:'Nigeria',     city:'Lagos',         emoji:'🇳🇬', lon: 3.4,   lat: 6.5),
  MapCountryPin(name:'South Africa',city:'Cape Town',     emoji:'🇿🇦', lon: 18.4,  lat: -33.9),
];

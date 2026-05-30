import 'package:flutter/material.dart';

class MapCoord {
  final double lon, lat;
  const MapCoord(this.lon, this.lat);
}

const landColor    = Color(0xFF3A7D44);
const desertColor  = Color(0xFFC8A96E);
const tundraColor  = Color(0xFF8B9D6E);
const forestColor  = Color(0xFF2D6B30);
const iceColor     = Color(0xDDEEF5FF);
const borderColor  = Color(0x442D6035);
const savannaColor = Color(0xFF8B9B5A);
const mountainColor = Color(0xFF6B4423);

const northAmerica = <MapCoord>[
  MapCoord(-168, 66), MapCoord(-162, 68), MapCoord(-152, 64), MapCoord(-142, 62),
  MapCoord(-135, 60), MapCoord(-130, 56), MapCoord(-125, 50), MapCoord(-124, 44),
  MapCoord(-122, 38), MapCoord(-118, 34), MapCoord(-114, 30), MapCoord(-110, 28),
  MapCoord(-106, 24), MapCoord(-100, 20), MapCoord(-92, 18), MapCoord(-86, 22),
  MapCoord(-83, 26), MapCoord(-80, 28), MapCoord(-81, 31), MapCoord(-78, 34),
  MapCoord(-76, 38), MapCoord(-74, 42), MapCoord(-70, 44), MapCoord(-66, 48),
  MapCoord(-60, 50), MapCoord(-56, 50), MapCoord(-58, 54), MapCoord(-62, 58),
  MapCoord(-66, 62), MapCoord(-72, 66), MapCoord(-80, 70), MapCoord(-90, 72),
  MapCoord(-100, 72), MapCoord(-112, 70), MapCoord(-125, 70), MapCoord(-140, 68),
  MapCoord(-152, 68), MapCoord(-162, 68),
];

const southAmerica = <MapCoord>[
  MapCoord(-80, 10), MapCoord(-77, 8), MapCoord(-76, 2), MapCoord(-72, 0),
  MapCoord(-62, 2), MapCoord(-52, 0), MapCoord(-38, -2), MapCoord(-35, -6),
  MapCoord(-36, -12), MapCoord(-38, -18), MapCoord(-42, -22), MapCoord(-48, -28),
  MapCoord(-52, -33), MapCoord(-58, -36), MapCoord(-64, -42), MapCoord(-68, -48),
  MapCoord(-72, -52), MapCoord(-76, -52), MapCoord(-74, -46), MapCoord(-72, -38),
  MapCoord(-72, -28), MapCoord(-74, -18), MapCoord(-76, -8), MapCoord(-78, -2),
];

const europe = <MapCoord>[
  MapCoord(-10, 36), MapCoord(-8, 42), MapCoord(-2, 44), MapCoord(2, 48),
  MapCoord(6, 52), MapCoord(8, 56), MapCoord(10, 58), MapCoord(12, 60),
  MapCoord(16, 62), MapCoord(20, 64), MapCoord(24, 66), MapCoord(28, 68),
  MapCoord(32, 70), MapCoord(30, 66), MapCoord(26, 62), MapCoord(24, 58),
  MapCoord(22, 54), MapCoord(20, 50), MapCoord(18, 46), MapCoord(14, 44),
  MapCoord(12, 42), MapCoord(14, 40), MapCoord(16, 38), MapCoord(18, 36),
  MapCoord(22, 38), MapCoord(26, 40), MapCoord(28, 42), MapCoord(30, 46),
  MapCoord(28, 48), MapCoord(26, 52), MapCoord(22, 48), MapCoord(18, 46),
  MapCoord(14, 44), MapCoord(12, 42), MapCoord(8, 40), MapCoord(4, 38),
];

const africa = <MapCoord>[
  MapCoord(-16, 35), MapCoord(-12, 32), MapCoord(-6, 30), MapCoord(0, 32),
  MapCoord(6, 34), MapCoord(10, 32), MapCoord(12, 30), MapCoord(18, 28),
  MapCoord(24, 26), MapCoord(28, 22), MapCoord(32, 18), MapCoord(38, 14),
  MapCoord(40, 10), MapCoord(42, 4), MapCoord(44, 0), MapCoord(42, -4),
  MapCoord(40, -8), MapCoord(38, -12), MapCoord(36, -18), MapCoord(32, -24),
  MapCoord(28, -28), MapCoord(22, -32), MapCoord(18, -34), MapCoord(16, -32),
  MapCoord(12, -28), MapCoord(10, -22), MapCoord(10, -16), MapCoord(8, -10),
  MapCoord(4, -4), MapCoord(0, 0), MapCoord(-4, 4), MapCoord(-8, 8),
  MapCoord(-12, 12), MapCoord(-16, 16), MapCoord(-18, 20), MapCoord(-16, 24),
  MapCoord(-16, 28), MapCoord(-16, 32),
];

const asia = <MapCoord>[
  MapCoord(30, 70), MapCoord(40, 72), MapCoord(50, 74), MapCoord(60, 76),
  MapCoord(70, 74), MapCoord(80, 74), MapCoord(90, 74), MapCoord(100, 74),
  MapCoord(110, 74), MapCoord(120, 74), MapCoord(130, 72), MapCoord(140, 70),
  MapCoord(150, 68), MapCoord(156, 64), MapCoord(160, 62), MapCoord(158, 58),
  MapCoord(154, 54), MapCoord(148, 50), MapCoord(142, 48), MapCoord(136, 46),
  MapCoord(130, 44), MapCoord(126, 40), MapCoord(122, 38), MapCoord(118, 36),
  MapCoord(112, 34), MapCoord(108, 32), MapCoord(104, 30), MapCoord(100, 28),
  MapCoord(96, 24), MapCoord(100, 20), MapCoord(104, 16), MapCoord(106, 10),
  MapCoord(104, 6), MapCoord(102, 2), MapCoord(100, -2), MapCoord(104, -6),
  MapCoord(106, -8), MapCoord(110, -8), MapCoord(112, -6), MapCoord(114, -2),
  MapCoord(116, 0), MapCoord(118, 4), MapCoord(120, 8), MapCoord(120, 12),
  MapCoord(118, 14), MapCoord(116, 18), MapCoord(114, 22), MapCoord(110, 24),
  MapCoord(106, 26), MapCoord(102, 28), MapCoord(98, 28), MapCoord(92, 28),
  MapCoord(88, 26), MapCoord(84, 24), MapCoord(80, 22), MapCoord(76, 20),
  MapCoord(72, 18), MapCoord(68, 20), MapCoord(64, 22), MapCoord(60, 24),
  MapCoord(56, 26), MapCoord(52, 28), MapCoord(48, 28), MapCoord(44, 30),
  MapCoord(40, 32), MapCoord(36, 34), MapCoord(32, 36), MapCoord(30, 40),
  MapCoord(28, 44), MapCoord(28, 48), MapCoord(30, 52), MapCoord(30, 56),
  MapCoord(32, 60), MapCoord(30, 64), MapCoord(30, 68),
];

const australia = <MapCoord>[
  MapCoord(116, -14), MapCoord(120, -12), MapCoord(126, -12), MapCoord(132, -12),
  MapCoord(138, -12), MapCoord(142, -14), MapCoord(146, -16), MapCoord(150, -20),
  MapCoord(152, -24), MapCoord(150, -28), MapCoord(148, -32), MapCoord(146, -36),
  MapCoord(140, -38), MapCoord(136, -36), MapCoord(132, -34), MapCoord(128, -32),
  MapCoord(124, -34), MapCoord(120, -34), MapCoord(116, -34), MapCoord(114, -32),
  MapCoord(112, -24), MapCoord(112, -18), MapCoord(114, -16),
];

const greenland = <MapCoord>[
  MapCoord(-52, 76), MapCoord(-44, 78), MapCoord(-32, 80), MapCoord(-20, 80),
  MapCoord(-18, 78), MapCoord(-18, 74), MapCoord(-22, 70), MapCoord(-28, 68),
  MapCoord(-36, 66), MapCoord(-44, 64), MapCoord(-52, 64), MapCoord(-56, 66),
  MapCoord(-58, 70), MapCoord(-56, 74),
];

const antarctica = <MapCoord>[
  MapCoord(-180, -70), MapCoord(-120, -72), MapCoord(-60, -72), MapCoord(0, -72),
  MapCoord(60, -72), MapCoord(120, -72), MapCoord(180, -70), MapCoord(180, -80),
  MapCoord(120, -82), MapCoord(60, -82), MapCoord(0, -82), MapCoord(-60, -82),
  MapCoord(-120, -82), MapCoord(-180, -80),
];

const saharaDesert = <MapCoord>[
  MapCoord(-16, 32), MapCoord(-10, 34), MapCoord(0, 35), MapCoord(10, 34),
  MapCoord(20, 32), MapCoord(28, 28), MapCoord(32, 24), MapCoord(36, 18),
  MapCoord(34, 14), MapCoord(28, 12), MapCoord(20, 14), MapCoord(12, 16),
  MapCoord(4, 16), MapCoord(-4, 16), MapCoord(-12, 18), MapCoord(-16, 22),
];

const amazonRainforest = <MapCoord>[
  MapCoord(-78, -2), MapCoord(-72, 2), MapCoord(-64, 2), MapCoord(-56, 0),
  MapCoord(-50, -2), MapCoord(-46, -6), MapCoord(-48, -10), MapCoord(-52, -14),
  MapCoord(-58, -14), MapCoord(-64, -12), MapCoord(-70, -8), MapCoord(-74, -6),
];

const himalayas = <MapCoord>[
  MapCoord(74, 34), MapCoord(78, 36), MapCoord(82, 34), MapCoord(86, 32),
  MapCoord(90, 32), MapCoord(94, 30), MapCoord(98, 30), MapCoord(100, 28),
  MapCoord(96, 26), MapCoord(92, 26), MapCoord(88, 28), MapCoord(84, 28),
  MapCoord(80, 30), MapCoord(76, 32),
];

const scandinavianMtns = <MapCoord>[
  MapCoord(6, 62), MapCoord(8, 64), MapCoord(12, 66), MapCoord(16, 68),
  MapCoord(20, 70), MapCoord(24, 70), MapCoord(22, 68), MapCoord(18, 66),
  MapCoord(14, 64), MapCoord(10, 62),
];

const centralAsiaSteppe = <MapCoord>[
  MapCoord(50, 52), MapCoord(60, 54), MapCoord(70, 54), MapCoord(80, 54),
  MapCoord(90, 52), MapCoord(100, 50), MapCoord(110, 48), MapCoord(120, 46),
  MapCoord(110, 44), MapCoord(100, 44), MapCoord(90, 44), MapCoord(80, 46),
  MapCoord(70, 48), MapCoord(60, 50),
];

const arabianDesert = <MapCoord>[
  MapCoord(36, 28), MapCoord(40, 30), MapCoord(44, 28), MapCoord(48, 26),
  MapCoord(52, 24), MapCoord(56, 22), MapCoord(54, 18), MapCoord(50, 16),
  MapCoord(46, 14), MapCoord(42, 14), MapCoord(40, 18), MapCoord(38, 22),
];

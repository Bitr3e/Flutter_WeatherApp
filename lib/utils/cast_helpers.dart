/// Safe null-tolerant casting helpers for JSON parsing.
int asInt(dynamic v, [int fallback = 0]) =>
    v == null ? fallback : (v as num).toInt();

double asDouble(dynamic v, [double fallback = 0.0]) =>
    v == null ? fallback : (v as num).toDouble();
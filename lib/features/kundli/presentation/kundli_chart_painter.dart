import 'dart:math';
import 'package:flutter/material.dart';

// ─── Data model ──────────────────────────────────────────────────────────────

class ChartPlanet {
  final String shortName;
  final int house;
  final bool isRetro;

  const ChartPlanet({
    required this.shortName,
    required this.house,
    this.isRetro = false,
  });
}

const _zodiacSigns = [
  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces',
];

const _zodiacAbbr = [
  'Ar', 'Ta', 'Ge', 'Cn', 'Le', 'Vi',
  'Li', 'Sc', 'Sg', 'Cp', 'Aq', 'Pi',
];

/// Returns the 1-based zodiac index of the ascendant sign (1 = Aries … 12 = Pisces).
int _ascSignIndex(String ascSign) {
  final s = ascSign.trim().toLowerCase();
  for (int i = 0; i < _zodiacSigns.length; i++) {
    if (_zodiacSigns[i].toLowerCase().startsWith(s.substring(0, min(s.length, 3)))) {
      return i + 1; // 1-based
    }
  }
  return 1;
}

/// Given the ascendant sign index (1-based), returns the sign that falls in house [house] (1-based).
String _signForHouse(int ascSignIdx, int house) {
  final idx = ((ascSignIdx - 1 + house - 1) % 12);
  return _zodiacAbbr[idx];
}

// ─── North Indian chart painter ───────────────────────────────────────────────

/// North Indian (diamond) Kundli chart.
///
/// House layout (the classic 12-triangle grid inside a square):
///
///   ┌──────┬──────┬──────┐
///   │  12  │  1   │  2   │
///   ├──────┼──────┼──────┤
///   │  11  │center│  3   │
///   ├──────┼──────┼──────┤
///   │  10  │  9   │  4   │    (bottom row continues below)
///   └──────┴──────┴──────┘
///             8  7  6  5  are the triangles in the inner diamond.
///
/// The classic 12-cell North Indian grid divides a square into 12 cells
/// with a diamond in the centre. The house positions are fixed (not sign-based).
class NorthIndianChartPainter extends CustomPainter {
  NorthIndianChartPainter({
    required this.planets,
    required this.ascSign,
    required this.lineColor,
    required this.textColor,
    required this.signColor,
    required this.primaryColor,
    required this.ascColor,
    required this.bgColor,
  });

  final List<ChartPlanet> planets;
  final String ascSign;
  final Color lineColor;
  final Color textColor;
  final Color signColor;
  final Color primaryColor;
  final Color ascColor;
  final Color bgColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final off = Offset((size.width - s) / 2, (size.height - s) / 2);
    final r = Rect.fromLTWH(off.dx, off.dy, s, s);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // ── Draw outer square ──
    canvas.drawRect(r, linePaint);

    final c = r.center;
    final tm = Offset(c.dx, r.top);
    final bm = Offset(c.dx, r.bottom);
    final lm = Offset(r.left, c.dy);
    final rm = Offset(r.right, c.dy);

    // ── Draw inner diamond ──
    final path = Path()
      ..moveTo(tm.dx, tm.dy)
      ..lineTo(rm.dx, rm.dy)
      ..lineTo(bm.dx, bm.dy)
      ..lineTo(lm.dx, lm.dy)
      ..close();
    canvas.drawPath(path, linePaint);

    // ── Draw corner lines (outer box partitions) ──
    // Top edge mid-thirds
    final t13 = Offset(r.left + s / 3, r.top);
    final t23 = Offset(r.left + 2 * s / 3, r.top);
    final b13 = Offset(r.left + s / 3, r.bottom);
    final b23 = Offset(r.left + 2 * s / 3, r.bottom);
    final l13 = Offset(r.left, r.top + s / 3);
    final l23 = Offset(r.left, r.top + 2 * s / 3);
    final r13 = Offset(r.right, r.top + s / 3);
    final r23 = Offset(r.right, r.top + 2 * s / 3);

    // Top-left corner cell lines
    canvas.drawLine(t13, lm, linePaint);
    canvas.drawLine(tm, l13, linePaint);
    // Top-right corner cell lines
    canvas.drawLine(t23, rm, linePaint);
    canvas.drawLine(tm, r13, linePaint);
    // Bottom-left corner cell lines
    canvas.drawLine(b13, lm, linePaint);
    canvas.drawLine(bm, l23, linePaint);
    // Bottom-right corner cell lines
    canvas.drawLine(b23, rm, linePaint);
    canvas.drawLine(bm, r23, linePaint);

    final cells = _northHouseCenters(r, s);

    final ascIdx = _ascSignIndex(ascSign);
    _drawHouseLabels(canvas, cells, ascIdx, s);
    _drawPlanetLabels(canvas, cells, planets, ascIdx, s);
  }

  Map<int, Offset> _northHouseCenters(Rect r, double s) {
    final c = r.center;
    final e = s / 6;
    return {
      1:  Offset(c.dx,        r.top    + e),       // top triangle
      2:  Offset(r.right - e, r.top    + e),        // TR corner
      3:  Offset(r.right - e, c.dy),                // right triangle
      4:  Offset(r.right - e, r.bottom - e),        // BR corner
      5:  Offset(c.dx + e,    r.bottom - e * 0.7),  // bottom-right triangle inner
      6:  Offset(c.dx + e * 1.5, r.bottom - e),     // BM-right  (outside diamond)
      7:  Offset(c.dx,        r.bottom - e),         // bottom triangle
      8:  Offset(c.dx - e * 1.5, r.bottom - e),     // BM-left
      9:  Offset(r.left  + e, r.bottom - e),        // BL corner
      10: Offset(r.left  + e, c.dy),                // left triangle
      11: Offset(r.left  + e, r.top    + e),        // TL corner
      12: Offset(c.dx - e,    r.top    + e * 0.7),  // top-left triangle inner
    };
  }

  void _drawHouseLabels(Canvas canvas, Map<int, Offset> cells, int ascIdx, double s) {
    final fontSize = s * 0.038;
    final signSize = s * 0.033;
    for (int h = 1; h <= 12; h++) {
      final center = cells[h]!;
      final sign = _signForHouse(ascIdx, h);
      // House number
      _drawText(canvas, '$h', center.translate(0, -fontSize * 0.6),
          fontSize, signColor, FontWeight.w500);
      // Sign abbreviation
      _drawText(canvas, sign, center.translate(0, fontSize * 0.5),
          signSize, signColor.withAlpha(180), FontWeight.w400);
    }
  }

  void _drawPlanetLabels(Canvas canvas, Map<int, Offset> cells,
      List<ChartPlanet> planets, int ascIdx, double s) {
    // Group planets by house
    final Map<int, List<ChartPlanet>> byHouse = {};
    for (final p in planets) {
      byHouse.putIfAbsent(p.house, () => []).add(p);
    }
    // Add Ascendant marker to house 1
    byHouse.putIfAbsent(1, () => []).insert(0,
        const ChartPlanet(shortName: 'As', house: 1));

    final planetSize = s * 0.038;
    for (final entry in byHouse.entries) {
      final h = entry.key;
      if (h < 1 || h > 12) continue;
      final center = cells[h]!;
      final pList = entry.value;
      // Stack planets vertically
      final spacing = planetSize * 1.35;
      final totalH = pList.length * spacing;
      var y = center.dy - totalH / 2 + spacing / 2;
      for (final p in pList) {
        final label = p.isRetro ? '${p.shortName}(R)' : p.shortName;
        final isAsc = p.shortName == 'As';
        _drawText(canvas, label, Offset(center.dx, y),
            planetSize, isAsc ? primaryColor : textColor, FontWeight.w700);
        y += spacing;
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset center,
      double fontSize, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: weight,
              height: 1.0)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant NorthIndianChartPainter old) =>
      old.planets != planets || old.ascSign != ascSign;
}

// ─── South Indian chart painter ───────────────────────────────────────────────

/// South Indian (square grid) Kundli chart.
///
/// 4×3 grid of cells. Signs are fixed in position (Aries always top-row 2nd cell).
/// The house number assigned to each cell depends on which sign is the ascendant.
///
/// Fixed sign positions (row, col) 0-indexed:
///   Pisces  (12) → (0,0)   Aries   (1) → (0,1)   Taurus  (2) → (0,2)   Gemini  (3) → (0,3)
///   Aquarius(11) → (1,0)   [center left]           [center right]        Cancer  (4) → (1,3)
///   Capri   (10) → (2,0)   [center left]           [center right]        Leo     (5) → (2,3)
///   Sagit   (9)  → (3,0)   Scorpio (8) → (3,1)   Libra   (7) → (3,2)   Virgo   (6) → (3,3)
///
/// Inner 2×2 (rows 1-2, cols 1-2) is the empty centre.

class SouthIndianChartPainter extends CustomPainter {
  SouthIndianChartPainter({
    required this.planets,
    required this.ascSign,
    required this.lineColor,
    required this.textColor,
    required this.signColor,
    required this.primaryColor,
    required this.ascColor,
    required this.bgColor,
  });

  final List<ChartPlanet> planets;
  final String ascSign;
  final Color lineColor;
  final Color textColor;
  final Color signColor;
  final Color primaryColor;
  final Color ascColor;
  final Color bgColor;

  // Fixed sign index for each South Indian cell (row, col) → 1-based sign index
  // Row 0: Pisces(12), Aries(1), Taurus(2), Gemini(3)
  // Row 1: Aquarius(11), -, -, Cancer(4)
  // Row 2: Capricorn(10), -, -, Leo(5)
  // Row 3: Sagittarius(9), Scorpio(8), Libra(7), Virgo(6)
  static const _cellSign = [
    [12, 1, 2, 3],
    [11, 0, 0, 4],
    [10, 0, 0, 5],
    [9,  8, 7, 6],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final off = Offset((size.width - s) / 2, (size.height - s) / 2);
    final cellW = s / 4;
    final cellH = s / 4;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final ascIdx = _ascSignIndex(ascSign);

    // Build house number per sign: sign index → house number
    final Map<int, int> signToHouse = {};
    for (int h = 1; h <= 12; h++) {
      final signIdx = ((ascIdx - 1 + h - 1) % 12) + 1;
      signToHouse[signIdx] = h;
    }

    // Group planets by sign
    final Map<int, List<ChartPlanet>> bySign = {};
    for (final p in planets) {
      // planet.house → which sign?
      final sIdx = ((ascIdx - 1 + p.house - 1) % 12) + 1;
      bySign.putIfAbsent(sIdx, () => []).add(p);
    }
    // Ascendant marker always in ascendant sign
    bySign.putIfAbsent(ascIdx, () => []).insert(0,
        const ChartPlanet(shortName: 'As', house: 1));

    // Draw grid
    for (int row = 0; row < 4; row++) {
      for (int col = 0; col < 4; col++) {
        final signIdx = _cellSign[row][col];
        if (signIdx == 0) continue; // centre cells

        final cellRect = Rect.fromLTWH(
          off.dx + col * cellW,
          off.dy + row * cellH,
          cellW,
          cellH,
        );

        // Highlight ascendant cell
        if (signIdx == ascIdx) {
          canvas.drawRect(
            cellRect,
            Paint()
              ..color = primaryColor.withAlpha(20)
              ..style = PaintingStyle.fill,
          );
        }

        canvas.drawRect(cellRect, linePaint);

        // Sign abbreviation (top-left corner)
        final abbr = _zodiacAbbr[signIdx - 1];
        final houseNum = signToHouse[signIdx] ?? 0;
        final cellPlanets = bySign[signIdx] ?? [];

        _drawCellContent(canvas, cellRect, abbr, houseNum, cellPlanets, s);
      }
    }

    // Draw outer border
    canvas.drawRect(
      Rect.fromLTWH(off.dx, off.dy, s, s),
      linePaint,
    );

    // Fill centre with background
    final centreRect = Rect.fromLTWH(
      off.dx + cellW,
      off.dy + cellH,
      cellW * 2,
      cellH * 2,
    );
    canvas.drawRect(centreRect,
        Paint()..color = bgColor..style = PaintingStyle.fill);
    canvas.drawRect(centreRect, linePaint);
  }

  void _drawCellContent(Canvas canvas, Rect cell,
      String signAbbr, int houseNum, List<ChartPlanet> cellPlanets, double s) {
    final signFontSize = s * 0.032;
    final planetFontSize = s * 0.036;
    final padding = s * 0.018;

    // Sign abbr at top-left
    _drawText(
      canvas,
      signAbbr,
      Offset(cell.left + padding + signFontSize * 0.4,
             cell.top  + padding + signFontSize * 0.5),
      signFontSize,
      signColor.withAlpha(190),
      FontWeight.w500,
    );

    // House number at top-right
    if (houseNum > 0) {
      _drawText(
        canvas,
        '$houseNum',
        Offset(cell.right - padding - signFontSize * 0.5,
               cell.top   + padding + signFontSize * 0.5),
        signFontSize * 0.85,
        signColor.withAlpha(140),
        FontWeight.w400,
      );
    }

    // Planets in the centre of the cell
    if (cellPlanets.isEmpty) return;
    final spacing = planetFontSize * 1.3;
    final totalH = cellPlanets.length * spacing;
    var y = cell.center.dy - totalH / 2 + spacing * 0.4;
    for (final p in cellPlanets) {
      final isAsc = p.shortName == 'As';
      final label = p.isRetro ? '${p.shortName}(R)' : p.shortName;
      _drawText(
        canvas,
        label,
        Offset(cell.center.dx, y),
        planetFontSize,
        isAsc ? primaryColor : textColor,
        FontWeight.w700,
      );
      y += spacing;
    }
  }

  void _drawText(Canvas canvas, String text, Offset center,
      double fontSize, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: weight,
              height: 1.0)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant SouthIndianChartPainter old) =>
      old.planets != planets || old.ascSign != ascSign;
}

// ─── Ashtakvarga chart painter ────────────────────────────────────────────────

/// Draws a North Indian diamond grid with Ashtakvarga bindus scores in each
/// of the 12 house cells — matching the AstroTalk-style Ashtakvarga view.
///
/// [scores] is a map of sign → score (e.g. {'aries': 4, 'taurus': 7, ...}).
/// [ascSign] positions the houses so house 1 = ascendant sign.
class AshtakvargaChartPainter extends CustomPainter {
  AshtakvargaChartPainter({
    required this.scores,
    required this.ascSign,
    required this.lineColor,
    required this.textColor,
    required this.signColor,
    required this.bgColor,
    required this.highColor,
    required this.medColor,
    required this.lowColor,
  });

  final Map<String, int> scores;
  final String ascSign;
  final Color lineColor;
  final Color textColor;
  final Color signColor;
  final Color bgColor;
  final Color highColor;
  final Color medColor;
  final Color lowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = min(size.width, size.height);
    final off = Offset((size.width - s) / 2, (size.height - s) / 2);
    final r = Rect.fromLTWH(off.dx, off.dy, s, s);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Outer square
    canvas.drawRect(r, linePaint);

    final c = r.center;
    final tm = Offset(c.dx, r.top);
    final bm = Offset(c.dx, r.bottom);
    final lm = Offset(r.left, c.dy);
    final rm = Offset(r.right, c.dy);

    // Inner diamond
    final diamond = Path()
      ..moveTo(tm.dx, tm.dy)
      ..lineTo(rm.dx, rm.dy)
      ..lineTo(bm.dx, bm.dy)
      ..lineTo(lm.dx, lm.dy)
      ..close();
    canvas.drawPath(diamond, linePaint);

    // Corner partition lines
    canvas.drawLine(tm, Offset(r.left + s / 3, r.top), linePaint);
    canvas.drawLine(tm, Offset(r.left, r.top + s / 3), linePaint);
    canvas.drawLine(tm, Offset(r.left + 2 * s / 3, r.top), linePaint);
    canvas.drawLine(tm, Offset(r.right, r.top + s / 3), linePaint);
    canvas.drawLine(bm, Offset(r.left + s / 3, r.bottom), linePaint);
    canvas.drawLine(bm, Offset(r.left, r.top + 2 * s / 3), linePaint);
    canvas.drawLine(bm, Offset(r.left + 2 * s / 3, r.bottom), linePaint);
    canvas.drawLine(bm, Offset(r.right, r.top + 2 * s / 3), linePaint);

    final cellPaths = _buildCellPaths(r);
    final cellCenters = _buildCellCenters(r, s);
    final ascIdx = _ascSignIndex(ascSign);

    for (int h = 1; h <= 12; h++) {
      final signIdx = ((ascIdx - 1 + h - 1) % 12);
      final signName = _zodiacSigns[signIdx].toLowerCase();
      final score = scores[signName] ??
          scores[signName[0].toUpperCase() + signName.substring(1)] ??
          0;

      final scoreColor = score >= 5 ? highColor : score >= 3 ? medColor : lowColor;

      // Tinted fill
      final fillPath = cellPaths[h];
      if (fillPath != null) {
        canvas.drawPath(
          fillPath,
          Paint()..color = scoreColor.withAlpha(35)..style = PaintingStyle.fill,
        );
      }

      final center = cellCenters[h]!;
      final abbr = _zodiacAbbr[signIdx];
      final labelSize = s * 0.032;
      final scoreSize = s * 0.052;

      // Sign abbreviation above
      _drawText(canvas, abbr, center.translate(0, -labelSize * 0.9),
          labelSize, signColor.withAlpha(160), FontWeight.w400);
      // Score number below
      _drawText(canvas, '$score', center.translate(0, labelSize * 0.5),
          scoreSize, scoreColor, FontWeight.w800);
    }
  }

  Map<int, Path> _buildCellPaths(Rect r) {
    final c = r.center;
    final tm = Offset(c.dx, r.top);
    final bm = Offset(c.dx, r.bottom);
    final lm = Offset(r.left, c.dy);
    final rm = Offset(r.right, c.dy);
    final tl = r.topLeft;
    final tr = r.topRight;
    final bl = r.bottomLeft;
    final br = r.bottomRight;

    return {
      1:  Path()..addPolygon([tl, tr, tm], true),
      2:  Path()..addPolygon([tr, rm, tm], true),
      3:  Path()..addPolygon([tr, br, rm], true),
      4:  Path()..addPolygon([br, rm, bm], true),
      5:  Path()..addPolygon([bl, br, bm], true),
      6:  Path()..addPolygon([bl, bm, lm], true),
      7:  Path()..addPolygon([bl, br, bm], true),
      8:  Path()..addPolygon([bl, lm, bm], true),
      9:  Path()..addPolygon([tl, bl, lm], true),
      10: Path()..addPolygon([tl, lm, tm], true),
      11: Path()..addPolygon([tl, bl, lm], true),
      12: Path()..addPolygon([tl, tm, lm], true),
    };
  }

  Map<int, Offset> _buildCellCenters(Rect r, double s) {
    final c = r.center;
    final e = s / 6;
    // Each house maps to its visual centroid inside the diamond
    return {
      1:  Offset(c.dx,        r.top    + e * 0.9),  // top triangle
      2:  Offset(r.right - e, r.top    + e),         // top-right corner
      3:  Offset(r.right - e, c.dy),                 // right triangle
      4:  Offset(r.right - e, r.bottom - e),         // bottom-right corner
      5:  Offset(c.dx,        r.bottom - e * 0.9),   // bottom triangle
      6:  Offset(c.dx - e * 0.5, r.bottom - e * 0.7),
      7:  Offset(c.dx,        r.bottom - e * 0.9),   // same region — offset slightly
      8:  Offset(c.dx + e * 0.5, r.bottom - e * 0.7),
      9:  Offset(r.left  + e, r.bottom - e),         // bottom-left corner
      10: Offset(r.left  + e, c.dy),                 // left triangle
      11: Offset(r.left  + e, r.top    + e),         // top-left corner
      12: Offset(c.dx,        r.top    + e * 0.9),   // same as 1 — offset
    };
  }

  void _drawText(Canvas canvas, String text, Offset center,
      double fontSize, Color color, FontWeight weight) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: weight,
              height: 1.0)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center.translate(-tp.width / 2, -tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant AshtakvargaChartPainter old) =>
      old.scores != scores || old.ascSign != ascSign;
}

/// Widget wrapper for the Ashtakvarga North Indian grid.
class AshtakvargaChartWidget extends StatelessWidget {
  const AshtakvargaChartWidget({
    super.key,
    required this.scores,
    required this.ascSign,
    this.size = 320,
  });

  final Map<String, int> scores;
  final String ascSign;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: AshtakvargaChartPainter(
          scores: scores,
          ascSign: ascSign,
          lineColor: isDark ? const Color(0xFF4A4870) : const Color(0xFFB0AECF),
          textColor: isDark ? const Color(0xFFECEFF1) : const Color(0xFF1A1A2E),
          signColor: isDark ? const Color(0xFF9090B0) : const Color(0xFF6060A0),
          bgColor: isDark ? const Color(0xFF0D0B1E) : const Color(0xFFF5F5FF),
          highColor: const Color(0xFF4CAF50),
          medColor: const Color(0xFFFFB300),
          lowColor: const Color(0xFFF44336),
        ),
      ),
    );
  }
}

// ─── Widget wrapper ───────────────────────────────────────────────────────────

enum KundliChartStyle { north, south }

class KundliChartWidget extends StatelessWidget {
  const KundliChartWidget({
    super.key,
    required this.planets,
    required this.ascSign,
    required this.style,
    this.size = 320,
  });

  final List<ChartPlanet> planets;
  final String ascSign;
  final KundliChartStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final lineColor = isDark
        ? const Color(0xFF4A4870)
        : const Color(0xFFB0AECF);
    final textColor = isDark
        ? const Color(0xFFECEFF1)
        : const Color(0xFF1A1A2E);
    final signColor = isDark
        ? const Color(0xFF9090B0)
        : const Color(0xFF6060A0);
    final primaryColor = const Color(0xFF5C6BC0);
    final ascColor = const Color(0xFFFFB300);
    final bgColor = isDark
        ? const Color(0xFF0D0B1E)
        : const Color(0xFFF5F5FF);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: style == KundliChartStyle.north
            ? NorthIndianChartPainter(
                planets: planets,
                ascSign: ascSign,
                lineColor: lineColor,
                textColor: textColor,
                signColor: signColor,
                primaryColor: primaryColor,
                ascColor: ascColor,
                bgColor: bgColor,
              )
            : SouthIndianChartPainter(
                planets: planets,
                ascSign: ascSign,
                lineColor: lineColor,
                textColor: textColor,
                signColor: signColor,
                primaryColor: primaryColor,
                ascColor: ascColor,
                bgColor: bgColor,
              ),
      ),
    );
  }
}

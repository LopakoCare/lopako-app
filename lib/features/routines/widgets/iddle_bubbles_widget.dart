import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:lopako_app_lis/features/routines/widgets/routine_bubble_widget.dart';
import 'package:lopako_app_lis/features/routines/models/routine_model.dart';

class IdleRoutineBubbles extends StatefulWidget {
  final void Function(Routine)? onTap;
  const IdleRoutineBubbles({super.key, required this.routines, this.onTap});

  final List<Routine> routines; // las que trae tu FamilyCircle

  @override
  State<IdleRoutineBubbles> createState() => _IdleRoutineBubblesState();
}

/* ----------  MODELO FÍSICO ---------- */

class _Bubble {
  _Bubble({
    required this.radius,
    required this.axis,
    required this.routine,
  });

  final double radius;
  final Offset axis;            // eje angular fijo
  final Routine routine;   // datos UI

  Offset pos = Offset.zero;
  Offset vel = Offset.zero;
}

/* ----------  STATE ---------- */

class _IdleRoutineBubblesState extends State<IdleRoutineBubbles>
    with SingleTickerProviderStateMixin {

  /* Constantes físicas (heredadas + eje) */
  static const double _extraSpacing   = 30;
  static const double _springK        = 20;
  static const double _axisK          = 80;
  static const double _damping        = 6;
  static const double _friction       = 0.92;
  static const double _springDeadZone = 25;
  static const double _silentVel      = 5;

  late final Ticker _ticker;
  late final List<_Bubble> _bubbles;
  late Size _box;
  Duration _last = Duration.zero;
  final _rand = math.Random();

  /* Drag */
  _Bubble? _dragging;
  Offset _dragOffset = Offset.zero;
  VelocityTracker? _vt;

  @override
  void initState() {
    super.initState();

    /* --- Selecciono máx. 3 rutinas y les asigno radios --- */
    final routines = widget.routines.take(3).toList();
    final radii = <double>[70, 55, 40]; // grande / medio / pequeño
    const baseAngles = [0.0, 2 * math.pi / 3, 4 * math.pi / 3];

    _bubbles = List.generate(routines.length, (i) {
      final jitter = _rand.nextDouble() * math.pi / 9 - math.pi / 18; // ±10°
      final angle  = baseAngles[i] + jitter;
      final axis   = Offset(math.cos(angle), math.sin(angle));
      return _Bubble(radius: radii[i], axis: axis, routine: routines[i]);
    });

    _ticker = createTicker(_tick)..start();
  }

  /* ----------  FÍSICA ---------- */

  void _tick(Duration now) {
    if (_last == Duration.zero || _box == Size.zero) {
      _last = now;
      return;
    }
    final dt = (now - _last).inMicroseconds / 1e6;
    _last = now;
    final center = Offset(_box.width / 2, _box.height / 2);

    for (final b in _bubbles) {
      if (b == _dragging) continue;

      final r = b.pos - center;

      /* Radial spring */
      if (r.distance > _springDeadZone) {
        b.vel += (-r * _springK - b.vel * _damping) * dt;
      }

      /* Corrección al eje */
      final proj = b.axis * (r.dx * b.axis.dx + r.dy * b.axis.dy);
      final tangErr = r - proj;
      b.vel += -tangErr * _axisK * dt;

      /* Fricción + movimiento */
      b.vel *= _friction;
      b.pos += b.vel * dt;

      /* Paredes */
      if (b.pos.dx - b.radius < 0 && b.vel.dx < 0 ||
          b.pos.dx + b.radius > _box.width && b.vel.dx > 0) {
        b.vel = Offset(-b.vel.dx, b.vel.dy);
      }
      if (b.pos.dy - b.radius < 0 && b.vel.dy < 0 ||
          b.pos.dy + b.radius > _box.height && b.vel.dy > 0) {
        b.vel = Offset(b.vel.dx, -b.vel.dy);
      }
      b.pos = Offset(
        b.pos.dx.clamp(b.radius, _box.width - b.radius),
        b.pos.dy.clamp(b.radius, _box.height - b.radius),
      );

      /* Silent zone */
      if (b.vel.distance < _silentVel) b.vel = Offset.zero;
    }

    /* Colisiones burbuja-burbuja */
    for (var i = 0; i < _bubbles.length; i++) {
      for (var j = i + 1; j < _bubbles.length; j++) {
        if (_bubbles[i] == _dragging || _bubbles[j] == _dragging) continue;
        _resolveCollision(_bubbles[i], _bubbles[j]);
      }
    }

    setState(() {});
  }

  void _resolveCollision(_Bubble a, _Bubble b) {
    final delta = b.pos - a.pos;
    final dist  = delta.distance;
    final minDist = a.radius + b.radius + _extraSpacing;
    if (dist < minDist && dist > 0) {
      final n = delta / dist;
      final overlap = minDist - dist;
      a.pos -= n * overlap / 2;
      b.pos += n * overlap / 2;
      final p = a.vel;
      a.vel = b.vel;
      b.vel = p;
    }
  }

  /* ----------  DRAG ---------- */

  void _startDrag(Offset global, Offset local) {
    for (final b in _bubbles.reversed) {
      if ((local - b.pos).distance <= b.radius) {
        _dragging = b;
        _dragOffset = local - b.pos;
        _vt = VelocityTracker.withKind(PointerDeviceKind.touch);
        break;
      }
    }
  }

  void _updateDrag(Offset global, Offset local) {
    if (_dragging != null) {
      _dragging!.pos = local - _dragOffset;
      _vt?.addPosition(Duration.zero, global);
      setState(() {});
    }
  }

  void _endDrag() {
    if (_dragging != null && _vt != null) {
      final v = _vt!.getVelocity();
      _dragging!.vel = v.pixelsPerSecond / 1000; // px/ms → px/s
    }
    _dragging = null;
    _vt = null;
  }

  /* ----------  BUILD ---------- */

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _box = constraints.biggest;
        if (_bubbles.first.pos == Offset.zero) _initialisePositions();
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (d) =>
              _startDrag(d.globalPosition, d.localPosition),
          onPanUpdate: (d) =>
              _updateDrag(d.globalPosition, d.localPosition),
          onPanEnd: (_) => _endDrag(),
          onPanCancel: _endDrag,
          child: Stack(
            children: _bubbles.map(_buildBubble).toList(),
          ),
        );
      },
    );
  }

  /* Posiciono el widget en la pantalla */
  Widget _buildBubble(_Bubble b) {
    return Positioned(
      left: b.pos.dx - b.radius,
      top:  b.pos.dy - b.radius,
      width: b.radius * 2,
      height: b.radius * 2,
      child: RoutineBubble(
        routine: b.routine,
        size: b.radius * 2,
        onTap: widget.onTap
      ),
    );
  }

  void _initialisePositions() {
    for (final b in _bubbles) {
      final r = 80 + _rand.nextDouble() * 40; // 80-120 px radio polar
      b.pos = Offset(_box.width / 2, _box.height / 2) + b.axis * r;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }
}

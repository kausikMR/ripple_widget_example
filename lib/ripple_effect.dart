import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class RippleEffect extends StatefulWidget {
  const RippleEffect({
    super.key,
    this.controller,
    this.backgroundColor,
    this.width,
    this.height,
    this.rippleColor,
    this.rippleDuration,
    this.fadeDuration,
    this.onTap,
    this.onTapDown,
    this.onDoubleTap,
    this.onDoubleTapDown,
    this.child,
  });

  /// rippleController [controller]
  final RippleController? controller;

  /// child widget [child]
  final Widget? child;

  /// touch effect color of widget [rippleColor]
  final Color? rippleColor;

  /// TouchRippleEffect widget background color [backgroundColor]
  final Color? backgroundColor;

  /// animation duration of Ripple effect. [rippleDuration]
  final Duration? rippleDuration;

  /// animation duration of Fade Effect [fadeDuration]
  final Duration? fadeDuration;

  /// onTap
  final VoidCallback? onTap;

  /// onTapDown
  final void Function(TapDownDetails details)? onTapDown;

  /// onDoubleTap
  final VoidCallback? onDoubleTap;

  /// onDoubleTapDown
  final void Function(TapDownDetails details)? onDoubleTapDown;

  /// TouchRippleEffect widget width size [width]
  final double? width;

  /// TouchRippleEffect widget height size [height]
  final double? height;

  @override
  RippleEffectState createState() => RippleEffectState();
}

class RippleEffectState extends State<RippleEffect> with SingleTickerProviderStateMixin {
  final GlobalKey _globalKey = GlobalKey();

  /// List to hold the Ripple Widgets
  final List<Widget> _ripples = [];

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.addListener(() {
        _addRipple(widget.controller!.offset);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: widget.onTapDown,
      onDoubleTap: widget.onDoubleTap,
      onDoubleTapDown: widget.onDoubleTapDown,
      child: Container(
        width: widget.width,
        height: widget.height,
        key: _globalKey,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: widget.backgroundColor ?? Colors.transparent,
        ),
        child: Stack(
          children: [
            widget.child ?? Container(),
            ..._ripples,
          ],
        ),
      ),
    );
  }

  void _addRipple(Offset offset) {
    final ValueKey<String> valueKey = ValueKey(const Uuid().v4());
    late final Ripple newRipple;

    final Size widgetSize = _globalKey.currentState?.context.size ?? Size.zero;
    final double mWidth = widget.width ?? widgetSize.width;
    final double mHeight = widget.height ?? widgetSize.height;
    final double maxRadius = mWidth * 2 + mHeight * 2;

    newRipple = Ripple(
      key: valueKey,
      offset: offset,
      minRadius: 40,
      maxRadius: maxRadius,
      color: Colors.white.withOpacity(0.3),
      onCompleted: (key) {
        setState(() {
          _ripples.removeWhere((ripple) => (ripple.key as ValueKey<String>).value == key.value);
        });
      },
    );
    setState(() {
      _ripples.add(newRipple);
    });
  }
}

/// RipplePainter
class _RipplePainter extends CustomPainter {
  final Offset offset;
  final double rippleRadius;
  final Color fillColor;

  const _RipplePainter({
    required this.offset,
    required this.rippleRadius,
    required this.fillColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = fillColor
      ..isAntiAlias = true;
    canvas.drawCircle(offset, rippleRadius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// RippleController
class RippleController extends ChangeNotifier {
  Offset _offset = Offset.zero;

  Offset get offset => _offset;

  void ripple(Offset offset) {
    _offset = offset;
    notifyListeners();
  }
}

/// Ripple
class Ripple extends StatefulWidget {
  const Ripple({
    super.key,
    required this.offset,
    required this.minRadius,
    required this.maxRadius,
    this.rippleDuration = const Duration(milliseconds: 1000),
    this.fadeDuration = const Duration(milliseconds: 800),
    required this.color,
    required this.onCompleted,
  });

  final Offset offset;
  final double minRadius;
  final double maxRadius;
  final Duration rippleDuration;
  final Duration fadeDuration;
  final Color color;
  final void Function(ValueKey<String> key) onCompleted;

  @override
  State<Ripple> createState() => _RippleState();
}

class _RippleState extends State<Ripple> with TickerProviderStateMixin {
  late final AnimationController _radiusAnimController;
  late final Animation<double> _radiusAnim;
  late final AnimationController _fadeAnimController;
  late final Animation<double> _opacityAnim;

  @override
  void initState() {
    super.initState();
    _radiusAnimController = AnimationController(vsync: this, duration: widget.rippleDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _fadeAnimController.forward();
        }
      });
    _radiusAnim = Tween<double>(begin: 40, end: widget.maxRadius).animate(CurvedAnimation(parent: _radiusAnimController, curve: Curves.easeIn))
      ..addListener(() {
        setState(() {});
      });
    _fadeAnimController = AnimationController(vsync: this, duration: widget.fadeDuration)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onCompleted.call(widget.key! as ValueKey<String>);
        }
      });
    _opacityAnim = Tween<double>(begin: 0.25, end: 0).animate(_fadeAnimController)
      ..addListener(() {
        setState(() {});
      });
    _radiusAnimController.forward();
  }

  @override
  void dispose() {
    _radiusAnimController.dispose();
    _fadeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _RipplePainter(
        offset: widget.offset,
        rippleRadius: _radiusAnim.value,
        fillColor: widget.color.withOpacity(_opacityAnim.value),
      ),
    );
  }
}

/// Utils
///
/// Debounce
class Debounce {
  Debounce(this._duration);

  Timer? _timer;
  final Duration _duration;

  void run(VoidCallback callback) {
    if (_timer != null) _timer!.cancel();
    _timer = Timer(_duration, callback);
  }

  void cancel() {
    if (_timer != null) _timer!.cancel();
    _timer = null;
  }
}

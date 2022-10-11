import 'package:flutter/material.dart';
import 'package:ripple_widget/ripple_effect.dart';

import 'sized_colored_box.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: RippleEffectWidget()),
    );
  }
}

class RippleEffectWidget extends StatefulWidget {
  const RippleEffectWidget({super.key});

  @override
  State<RippleEffectWidget> createState() => _RippleEffectWidgetState();
}

class _RippleEffectWidgetState extends State<RippleEffectWidget> {
  late final RippleController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = RippleController();
  }

  @override
  Widget build(BuildContext context) {
    return RippleEffect(
      controller: _rippleController,
      rippleColor: Colors.white,
      height: 200,
      width: 200,
      onTapDown: (details) {
        _rippleController.ripple(details.localPosition);
      },
      child: const SizedColoredBox(
        color: Colors.black,
        width: 200,
        height: 200,
      ),
    );
  }
}

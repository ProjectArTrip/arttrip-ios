import 'package:flutter/widgets.dart';

class InitWidget extends StatefulWidget {
  const InitWidget({super.key, this.init, required this.child});

  final Function()? init;
  final Widget child;

  @override
  State<InitWidget> createState() => _InitWidgetState();
}

class _InitWidgetState extends State<InitWidget> {
  bool _initialized = false;

  void _call() async {
    if (widget.init != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.init!();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _call();
      _initialized = true;
    }

    return widget.child;
  }
}

import 'package:flutter/material.dart';
import 'package:rate_my_app/rate_my_app.dart';

class RatingApp extends StatefulWidget {
  final Widget Function(RateMyApp) builder;
  const RatingApp({super.key, required this.builder});

  @override
  _RatingAppState createState() => _RatingAppState();
}

class _RatingAppState extends State<RatingApp> {
  late RateMyApp rateMyApp;
  @override
  Widget build(BuildContext context) => RateMyAppBuilder(
    rateMyApp: RateMyApp(),
    onInitialized: (context, rateMyApp) {
      setState(() => this.rateMyApp = rateMyApp);
    },
    builder: (context) => widget.builder(rateMyApp),
  );
}

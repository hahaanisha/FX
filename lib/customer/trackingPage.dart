import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TrackVehiclePage extends StatefulWidget {
  final String routeId;

  TrackVehiclePage({super.key, required this.routeId});

  @override
  _TrackVehiclePageState createState() => _TrackVehiclePageState();
}

class _TrackVehiclePageState extends State<TrackVehiclePage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://tracking-blush.vercel.app/join/${widget.routeId}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Vehicle')),
      body: WebViewWidget(controller: _controller),
    );
  }
}

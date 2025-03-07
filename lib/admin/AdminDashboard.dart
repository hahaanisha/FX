import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AdminDashboard extends StatefulWidget {

  AdminDashboard({super.key});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(
          'https://optiway-chart.vercel.app'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: Text('Admin Dashboard',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),)),
      body: WebViewWidget(controller: _controller),
    );
  }
}

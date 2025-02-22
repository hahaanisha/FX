import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class TrackingPage extends StatefulWidget {
  final List<dynamic> steps;

  const TrackingPage({Key? key, required this.steps}) : super(key: key);

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  late final WebViewController _controller;
  bool isLoading = true;
  int currentStepIndex = 0;
  String trackingUrl = "";

  @override
  void initState() {
    super.initState();
    loadStep();
  }

  void loadStep() {
    if (currentStepIndex < widget.steps.length - 1) {
      final start = widget.steps[currentStepIndex]['location'];
      final end = widget.steps[currentStepIndex + 1]['location'];

      if (start is List && end is List && start.length == 2 && end.length == 2) {
        setState(() {
          trackingUrl =
          "https://tracking-blush.vercel.app/create/111/${start[1]}/${start[0]}/${end[1]}/${end[0]}";
        });

        // Load WebView
        initWebView();
      } else {
        showErrorDialog("Navigation Error", "Invalid coordinates format.");
      }
    } else {
      showCompletionDialog();
    }
  }

  void initWebView() {
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
    WebViewController.fromPlatformCreationParams(params);

    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress: $progress%)');
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  Code: ${error.errorCode}
  Description: ${error.description}
  Error Type: ${error.errorType}
  Is Main Frame: ${error.isForMainFrame}
            ''');
          },
        ),
      )
      ..loadRequest(Uri.parse(trackingUrl));

    _controller = controller;
  }

  void navigateToNextStep() {
    if (currentStepIndex < widget.steps.length - 1) {
      setState(() {
        currentStepIndex++;
      });
      loadStep();
    } else {
      showCompletionDialog();
    }
  }

  void showCompletionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Route Completed'),
        content: Text('You have completed all stops!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WebViewWidget(controller: _controller),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToNextStep,
        child: const Icon(Icons.arrow_forward),
      ),
    );
  }
}

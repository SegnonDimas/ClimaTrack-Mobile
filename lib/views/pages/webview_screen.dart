import 'dart:async';
import 'package:flutter/material.dart';
import 'package:galactic_heroes/views/app_colors.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'no_connection_screen.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasConnection = true;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
    _setupConnectivity();
  }

  void _initializeWebView() {
    controller = WebViewController();

    // Configuration de base
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..enableZoom(true);

    // Configuration du cache et du stockage
    controller
      ..clearCache()
      ..clearLocalStorage()
      ..setUserAgent(
        'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/116.0.0.0 Mobile Safari/537.36',
      );

    // Configuration de la navigation
    controller.setNavigationDelegate(
      NavigationDelegate(
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
        onNavigationRequest: (NavigationRequest request) {
          // Autoriser toutes les navigations pour le moment
          return NavigationDecision.navigate;
        },
        onWebResourceError: (WebResourceError error) {
          print('WebView Error: ${error.description}');
          _checkConnectivity();
        },
      ),
    );

    // Configuration des paramètres supplémentaires
    controller..setOnConsoleMessage((JavaScriptConsoleMessage message) {
      print('WebView Console: ${message.message}');
    });

    // Chargement de l'URL avec les en-têtes personnalisés
    controller.loadRequest(
      Uri.parse(widget.url),
      method: LoadRequestMethod.get,
      headers: {
        'Cache-Control': 'no-cache',
        'Pragma': 'no-cache',
        'Accept':
            'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'fr,en-US;q=0.7,en;q=0.3',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1',
      },
    );
  }

  Future<void> _setupConnectivity() async {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      ConnectivityResult result,
    ) {
      if (result != ConnectivityResult.none) {
        setState(() {
          hasConnection = true;
        });
        _retryLoading();
      } else {
        setState(() {
          hasConnection = false;
        });
      }
    });

    await _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    setState(() {
      hasConnection = result != ConnectivityResult.none;
    });
  }

  Future<void> _retryLoading() async {
    setState(() {
      isLoading = true;
    });

    try {
      await controller.clearCache();
      await controller.clearLocalStorage();

      await controller.loadRequest(
        Uri.parse(widget.url),
        method: LoadRequestMethod.get,
        headers: {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
          'Accept':
              'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
          'Accept-Language': 'fr,en-US;q=0.7,en;q=0.3',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      );
    } catch (e) {
      print('WebView Error during reload: $e');
      // En cas d'échec, on attend un peu et on réessaie
      await Future.delayed(const Duration(seconds: 1));
      try {
        await controller.loadRequest(
          Uri.parse(widget.url),
          method: LoadRequestMethod.get,
        );
      } catch (e) {
        print('WebView Second Error: $e');
        _checkConnectivity();
      }
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (await controller.canGoBack()) {
          controller.goBack();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 12, 18, 28),
          toolbarHeight: 0,
        ),
        /*appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Text(
            widget.title,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _retryLoading,
            ),
          ],
        ),*/
        body: Stack(
          children: [
            if (hasConnection) WebViewWidget(controller: controller),
            if (!hasConnection)
              NoConnectionScreen(
                onRetry: () {
                  _checkConnectivity();
                  _retryLoading();
                },
              ),
            if (isLoading && hasConnection)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          onPressed: _retryLoading,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

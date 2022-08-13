import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:oxytocin/configers/images_config.dart';
import 'package:oxytocin/helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../widgets/text_app.dart';

class Contactscreen extends StatefulWidget {
  const Contactscreen({Key? key}) : super(key: key);

  @override
  State<Contactscreen> createState() => _ContactscreenState();
}

class _ContactscreenState extends State<Contactscreen> with Helpers{
  bool isLoading = false;
  bool hasInternet = false;
  DateTime timeBackPressed = DateTime.now();

  final Completer<WebViewController> _webViewController =
  Completer<WebViewController>();
  final _key = UniqueKey();
  late WebViewController webViewControllerController;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    initConnectivity();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;
    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      return;
    }
    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
    print(result);
    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      setState(() {
        hasInternet = true;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final differences = DateTime.now().difference(timeBackPressed);
        final isExitWarning = differences >= const Duration(seconds: 2);
        timeBackPressed = DateTime.now();
        if (isExitWarning) {
          if (await webViewControllerController.canGoBack()) {
            webViewControllerController.goBack();
            return false;
          }
         // const msg = "يرجى الضغط مرة اخرى للخروج من التطبيق !";
         // print(msg);
        //  showSnackBar(context: context, message: msg, error: false);
          return false;
        } else if (!isExitWarning) {
          return true;
        }
        return false;
      },
      child: Scaffold(   appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Oxytocin Call",
          style: TextStyle(
            fontSize: 25.sp,
            color: Colors.white,
          ),
        ),
      ),


      body: webSitePage(),),
    );
  }

  Widget webSitePage() {
    return hasInternet == true
        ? Stack(
      children: [
        isLoading == true
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Colors.pinkAccent,
              ),
              DefaultTextStyle(
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.pinkAccent,
                ),
                child: AnimatedTextKit(
                  animatedTexts: [
                    FadeAnimatedText('جاري تحميل الموقع...'),
                    FadeAnimatedText('يرجي الانتظار بضع ثواني... '),
                  ],
                ),
              ),
            ],
          ),
        )
            : const SizedBox(),
        WebView(
            javascriptMode: JavascriptMode.unrestricted,
            initialUrl: callSiteLink,
            backgroundColor: Colors.transparent,
            key: _key,
            onPageStarted: (start) {
              setState(() {
                isLoading = true;
              });
            },
            onPageFinished: (finish) {
              setState(() {
                isLoading = false;
              });
            },
            onWebViewCreated: (WebViewController controller) {
              setState(() {
                isLoading = true;
              });

              webViewControllerController = controller;
              _webViewController.complete(controller);
              setState(() {
                isLoading = false;
              });
              //  controller.
            },
            zoomEnabled: true,
            initialMediaPlaybackPolicy:
            AutoMediaPlaybackPolicy.always_allow,
            allowsInlineMediaPlayback: true,
            debuggingEnabled: false,
            gestureNavigationEnabled: true,
            navigationDelegate: (NavigationRequest request) {
              if (request.url.startsWith("https://wa.me/")) {
                print(request.url);
                launch(request.url);
                return NavigationDecision.prevent;
              } else if (!Platform.isIOS) {
                if (request.url.contains("twitter")) {
                  launch(request.url);
                  return NavigationDecision.prevent;
                }
                return NavigationDecision.navigate;
              } else if (request.url.contains("instagram")) {
                launch(request.url);
                return NavigationDecision.prevent;
              } else if (request.url.contains("snapchat")) {
                launch(request.url);
                return NavigationDecision.prevent;
              } else {
                return NavigationDecision.navigate;
              }
            }),
      ],
    )
        : noConnection();
  }

  Center noConnection() {
    return Center(
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(noInternet),
            TextApp(
              text: "لايوجد اتصال بالانترنت!",
              fontSize: 30.sp,
              fontColor: Colors.pink,
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:oxytocin/helpers/helpers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../configers/images_config.dart';
import '../helpers/dialog_helper.dart';

import '../widgets/text_app.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with Helpers, showDialogHelper {
  DateTime timeBackPressed = DateTime.now();
  late bool isLoading;
  bool hasInternet = false;
  final Completer<WebViewController> _webViewController =
      Completer<WebViewController>();
  final _key = UniqueKey();
  late WebViewController webViewControllerController;
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    isLoading = false;
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

    if (result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile) {
      setState(() {
        hasInternet = true;
      });
    }
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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,

                        color: Colors.pinkAccent,
                      ),
                      child: AnimatedTextKit(

                        animatedTexts: [
                          FadeAnimatedText("اهلا وسهلا بكم في متجرنا" , textAlign: TextAlign.center , textStyle: GoogleFonts.lateef(fontSize: 28.sp , color: Colors.blue)),
                          FadeAnimatedText("كل ما تريده موجود لدينا", textAlign: TextAlign.center , textStyle: GoogleFonts.lateef(fontSize: 28.sp , color: Colors.blue)),
                          FadeAnimatedText('جولة تسويقية سعيدة ', textAlign: TextAlign.center , textStyle: GoogleFonts.lateef(fontSize: 28.sp , color: Colors.blue)),
                        ],
                      ),
                    ),
                  ],
                ),
              )
                  : const SizedBox(),
              WebView(
                  javascriptMode: JavascriptMode.unrestricted,
                  initialUrl: mainPage,
                  backgroundColor: Colors.white,
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
          const msg = "يرجى الضغط مرة اخرى للخروج من التطبيق !";

          showSnackBar(context: context, message: msg, error: false);
          return false;
        } else if (!isExitWarning) {
          return true;
        }
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        extendBodyBehindAppBar: false,
        drawer: drawerWidget(context),
        appBar: AppBar(
          backgroundColor: Colors.blue.shade300,
          centerTitle: true,
          title: TextApp(
            text: "OXYTOCIN",
            fontSize: 20.sp,
          ),
        ),
        body: SafeArea(
          child: webSitePage(),
        ),
      ),
    );
  }

  Drawer drawerWidget(BuildContext context) {
    return Drawer(
      elevation: 10.sp,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.sp),
        side: BorderSide(
          color: Colors.blue,
          width: 4.sp,
        ),
      ),
      backgroundColor: Colors.white60,
      child: ListView(
        shrinkWrap: false,
        padding: EdgeInsets.symmetric(
          horizontal: 15.sp,
          vertical: 15.sp,
        ),
        children: [
          Container(
            height: 300.h,
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(logoWithRemoveBackground),
                    fit: BoxFit.fill)),
          ),
          Divider(
            height: 2.sp,
            color: Colors.blue.shade300,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15.sp),
            ),
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, "/infoScreen");
              },
              leading: const Icon(
                Icons.info,
              ),
              title: TextApp(
                text: "من نحن ",
                fontColor: Colors.blue.shade800,
                textAlign: TextAlign.start,
                fontSize: 25.sp,
              ),
              iconColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.sp)),
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Divider(
            height: 2.sp,
            color: Colors.blue.shade300,
          ),
          SizedBox(
            height: 15.h,
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15.sp),
            ),
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, "/contactUsScreen");
              },
              leading: const Icon(
                Icons.call,
              ),
              title: TextApp(
                text: "تواصل معنا",
                fontColor: Colors.blue.shade800,
                textAlign: TextAlign.start,
                fontSize: 25.sp,
              ),
              iconColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.sp)),
            ),
          ),
          SizedBox(
            height: 15.h,
          ),
          Divider(
            height: 2.sp,
            color: Colors.blue.shade300,
          ),
          SizedBox(
            height: 15.h,
          ),
        ],
      ),
    );
  }
}
